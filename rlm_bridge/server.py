#!/usr/bin/env python3
"""
RLM Bridge Server

A simple Flask server that wraps the RLM library and exposes it
as an HTTP API for the Pi extension to call.

Phase 1 MVP: Returns final text response (no streaming, no tool calls).
"""

import os
import json
import logging
from typing import Optional
from dataclasses import dataclass, asdict

from flask import Flask, request, jsonify
from flask_cors import CORS
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)
CORS(app)

# RLM configuration defaults
DEFAULT_BACKEND = os.getenv("RLM_BACKEND", "openrouter")
DEFAULT_MODEL = os.getenv("RLM_MODEL", "google/gemini-3-flash-preview")
DEFAULT_MAX_RECURSION = int(os.getenv("RLM_MAX_RECURSION", "10"))


@dataclass
class RlmConfig:
    """Configuration for RLM instance."""
    backend: str = DEFAULT_BACKEND
    model_name: str = DEFAULT_MODEL
    max_recursion_depth: int = DEFAULT_MAX_RECURSION
    environment: str = "local"  # "local" | "docker"


@dataclass 
class CompletionRequest:
    """Incoming completion request from Pi extension."""
    messages: list[dict]
    model: Optional[str] = None
    rlm_config: Optional[dict] = None


@dataclass
class CompletionResponse:
    """Response to send back to Pi extension."""
    text: str
    usage: Optional[dict] = None
    metadata: Optional[dict] = None


def messages_to_context(messages: list[dict]) -> tuple[str, str]:
    """
    Convert Pi-style messages into RLM context + query.
    
    RLM's model is: context lives in environment, query is the current turn.
    We treat all messages except the last as "context" and the last as "query".
    """
    if not messages:
        return "", ""
    
    # Build context from all messages except the last
    context_parts = []
    for msg in messages[:-1]:
        role = msg.get("role", "user")
        content = msg.get("content", "")
        context_parts.append(f"[{role.upper()}]: {content}")
    
    context = "\n\n".join(context_parts)
    
    # Last message is the query
    last_msg = messages[-1]
    query = last_msg.get("content", "")
    
    return context, query


def run_rlm_completion(context: str, query: str, config: RlmConfig) -> CompletionResponse:
    """
    Run RLM completion with the given context and query.
    
    Phase 1: Simple wrapper around RLM library.
    """
    try:
        from rlm import RLM
        
        # Initialize RLM with config
        # Get API key from environment based on backend
        api_key = None
        if config.backend == "openrouter":
            api_key = os.getenv("OPENROUTER_API_KEY")
        elif config.backend == "openai":
            api_key = os.getenv("OPENAI_API_KEY")
        elif config.backend == "anthropic":
            api_key = os.getenv("ANTHROPIC_API_KEY")
        
        backend_kwargs = {"model_name": config.model_name}
        if api_key:
            backend_kwargs["api_key"] = api_key
        
        # Build the full prompt
        # RLM handles context offloading internally
        if context:
            full_prompt = f"""Previous conversation context:
{context}

Current request:
{query}"""
        else:
            full_prompt = query
        
        logger.info(f"RLM config: backend={config.backend}, model={config.model_name}, max_depth={config.max_recursion_depth}")
        logger.info(f"Context length: {len(context)} chars, Query length: {len(query)} chars")
        logger.info(f"Full prompt length: {len(full_prompt)} chars")
        
        # Ensure we have a valid cwd (RLM's LocalREPL needs it)
        work_dir = os.path.dirname(os.path.abspath(__file__))
        os.chdir(work_dir)
        logger.info(f"Working directory: {work_dir}")
            
        rlm = RLM(
            backend=config.backend,
            backend_kwargs=backend_kwargs,
            max_depth=config.max_recursion_depth,
            verbose=True,
        )
        
        logger.info("RLM instance created, calling completion...")
        
        # Run completion
        result = rlm.completion(full_prompt)
        
        logger.info(f"RLM completion done. Response length: {len(result.response)} chars")
        logger.info(f"RLM result fields: {vars(result) if hasattr(result, '__dict__') else dir(result)}")
        
        # Extract usage from UsageSummary if available
        usage_summary = getattr(result, "usage_summary", None)
        usage = {}
        if usage_summary:
            logger.info(f"UsageSummary: {vars(usage_summary) if hasattr(usage_summary, '__dict__') else usage_summary}")
            usage = {
                "promptTokens": getattr(usage_summary, "prompt_tokens", 0) or getattr(usage_summary, "input_tokens", 0) or 0,
                "completionTokens": getattr(usage_summary, "completion_tokens", 0) or getattr(usage_summary, "output_tokens", 0) or 0,
            }
        
        return CompletionResponse(
            text=result.response,
            usage=usage,
            metadata={
                "recursionDepth": getattr(result, "depth", 0),
                "executionTime": getattr(result, "execution_time", 0),
            }
        )
        
    except ImportError:
        logger.error("RLM library not installed. Run: pip install rlms")
        # Fallback: return a mock response for testing
        return CompletionResponse(
            text=f"[RLM MOCK] Would process query: {query[:100]}...",
            metadata={"mock": True}
        )
    except Exception as e:
        logger.exception("RLM completion failed")
        raise


@app.route("/health", methods=["GET"])
def health():
    """Health check endpoint."""
    try:
        import rlm
        rlm_available = True
        rlm_version = getattr(rlm, "__version__", "unknown")
    except ImportError:
        rlm_available = False
        rlm_version = None
    
    return jsonify({
        "status": "ok",
        "rlm_available": rlm_available,
        "rlm_version": rlm_version,
        "default_backend": DEFAULT_BACKEND,
        "default_model": DEFAULT_MODEL,
    })


@app.route("/completion", methods=["POST"])
def completion():
    """
    Main completion endpoint.
    
    Accepts Pi-style messages and returns RLM completion.
    """
    try:
        data = request.get_json()
        
        if not data:
            return jsonify({"error": "No JSON body provided"}), 400
        
        messages = data.get("messages", [])
        if not messages:
            return jsonify({"error": "No messages provided"}), 400
        
        # Parse config
        rlm_config_data = data.get("rlmConfig", {})
        config = RlmConfig(
            backend=rlm_config_data.get("backend", DEFAULT_BACKEND),
            model_name=rlm_config_data.get("modelName", DEFAULT_MODEL),
            max_recursion_depth=rlm_config_data.get("maxRecursionDepth", DEFAULT_MAX_RECURSION),
            environment=rlm_config_data.get("environment", "local"),
        )
        
        logger.info(f"Completion request: {len(messages)} messages, backend={config.backend}")
        
        # Convert messages to RLM format
        context, query = messages_to_context(messages)
        
        # Run completion
        response = run_rlm_completion(context, query, config)
        
        return jsonify(asdict(response))
        
    except Exception as e:
        logger.exception("Completion endpoint error")
        return jsonify({"error": str(e)}), 500


@app.route("/", methods=["GET"])
def index():
    """Root endpoint with usage info."""
    return jsonify({
        "name": "RLM Bridge Server",
        "version": "0.1.0",
        "endpoints": {
            "GET /health": "Health check",
            "POST /completion": "Run RLM completion",
        },
        "phase": "1 - MVP (final text, no streaming, no tools)"
    })


if __name__ == "__main__":
    port = int(os.getenv("RLM_BRIDGE_PORT", "8765"))
    debug = os.getenv("RLM_BRIDGE_DEBUG", "false").lower() == "true"
    
    logger.info(f"Starting RLM Bridge Server on port {port}")
    app.run(host="0.0.0.0", port=port, debug=debug)
