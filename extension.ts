/**
 * Pi RLM Extension
 *
 * Registers an "rlm" provider that routes completions through
 * a Python bridge running the RLM library.
 *
 * Usage:
 *   # Start the bridge first
 *   cd rlm_bridge && source .venv/bin/activate && python server.py
 *
 *   # Then run pi with this extension
 *   pi -e ./path/to/pi-rlm-extension
 *
 *   # Switch to RLM model
 *   /model rlm/rlm-default
 */

import {
	type AssistantMessage,
	type AssistantMessageEventStream,
	type Context,
	type Model,
	type Api,
	type SimpleStreamOptions,
	createAssistantMessageEventStream,
} from "@mariozechner/pi-ai";
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

// Bridge configuration
const BRIDGE_URL = process.env.RLM_BRIDGE_URL || "http://localhost:8765";

interface RlmBridgeResponse {
	text: string;
	usage?: {
		promptTokens: number;
		completionTokens: number;
	};
	metadata?: {
		recursionDepth: number;
		totalCalls: number;
	};
}

/**
 * Convert Pi context messages to a flat array for the bridge
 */
function contextToBridgeMessages(context: Context): Array<{ role: string; content: string }> {
	return context.messages.map((msg) => {
		let content: string;
		if (msg.role === "user") {
			if (typeof msg.content === "string") {
				content = msg.content;
			} else if (Array.isArray(msg.content)) {
				content = msg.content
					.filter((block): block is { type: "text"; text: string } => block.type === "text")
					.map((block) => block.text)
					.join("\n");
			} else {
				content = String(msg.content);
			}
		} else if (msg.role === "assistant") {
			content = msg.content
				.filter((block): block is { type: "text"; text: string } => block.type === "text")
				.map((block) => block.text)
				.join("\n");
		} else if (msg.role === "toolResult") {
			content = msg.content
				.filter((block): block is { type: "text"; text: string } => block.type === "text")
				.map((block) => block.text)
				.join("\n");
		} else {
			content = "";
		}
		return { role: msg.role, content };
	});
}

/**
 * Custom streaming implementation that calls the RLM Python bridge.
 * Phase 1: returns entire response as a single text block (no real streaming).
 */
function streamRlm(
	model: Model<Api>,
	context: Context,
	options?: SimpleStreamOptions,
): AssistantMessageEventStream {
	const stream = createAssistantMessageEventStream();

	(async () => {
		const output: AssistantMessage = {
			role: "assistant",
			content: [],
			api: model.api,
			provider: model.provider,
			model: model.id,
			usage: {
				input: 0,
				output: 0,
				cacheRead: 0,
				cacheWrite: 0,
				totalTokens: 0,
				cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0, total: 0 },
			},
			stopReason: "stop",
			timestamp: Date.now(),
		};

		try {
			stream.push({ type: "start", partial: output });

			// Build bridge request
			const bridgeMessages = contextToBridgeMessages(context);

			// Include system prompt as first message if present
			if (context.systemPrompt) {
				bridgeMessages.unshift({ role: "system", content: context.systemPrompt });
			}

			const response = await fetch(`${BRIDGE_URL}/completion`, {
				method: "POST",
				headers: { "Content-Type": "application/json" },
				body: JSON.stringify({
					messages: bridgeMessages,
					model: model.id,
					rlmConfig: {
						backend: "openrouter",
						maxRecursionDepth: 10,
						environment: "local",
					},
				}),
				signal: options?.signal,
			});

			if (!response.ok) {
				const errorText = await response.text();
				throw new Error(`RLM bridge error: ${response.status} - ${errorText}`);
			}

			const result: RlmBridgeResponse = await response.json();

			// Emit text as a single block
			output.content.push({ type: "text", text: "" });
			stream.push({ type: "text_start", contentIndex: 0, partial: output });

			const textBlock = output.content[0];
			if (textBlock.type === "text") {
				textBlock.text = result.text;
			}
			stream.push({ type: "text_delta", contentIndex: 0, delta: result.text, partial: output });
			stream.push({ type: "text_end", contentIndex: 0, content: result.text, partial: output });

			// Update usage if available
			if (result.usage) {
				output.usage.input = result.usage.promptTokens || 0;
				output.usage.output = result.usage.completionTokens || 0;
				output.usage.totalTokens = output.usage.input + output.usage.output;
			}

			stream.push({ type: "done", reason: "stop", message: output });
			stream.end();
		} catch (error) {
			output.stopReason = options?.signal?.aborted ? "aborted" : "error";
			output.errorMessage = error instanceof Error ? error.message : String(error);
			stream.push({ type: "error", reason: output.stopReason, error: output });
			stream.end();
		}
	})();

	return stream;
}

/**
 * Extension entry point
 */
export default function (pi: ExtensionAPI) {
	// Register RLM as a custom provider
	pi.registerProvider("rlm", {
		baseUrl: BRIDGE_URL,
		apiKey: "RLM_DUMMY_KEY", // Not used, bridge handles auth
		api: "rlm-bridge-api",
		models: [
			{
				id: "rlm-default",
				name: "RLM Default",
				reasoning: false,
				input: ["text"],
				cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
				contextWindow: 128000,
				maxTokens: 16384,
			},
		],
		streamSimple: streamRlm,
	});

	// Register /rlm command
	pi.registerCommand("rlm", {
		description: "Check RLM bridge status",
		handler: async (_args, ctx) => {
			try {
				const response = await fetch(`${BRIDGE_URL}/health`, {
					method: "GET",
					signal: AbortSignal.timeout(3000),
				});
				if (response.ok) {
					const data = await response.json();
					ctx.ui.notify(
						`RLM Bridge: ✓ Connected\n` +
							`  Backend: ${data.default_backend}\n` +
							`  Model: ${data.default_model}\n` +
							`  RLM available: ${data.rlm_available}`,
						"info",
					);
				} else {
					ctx.ui.notify(`RLM Bridge: ✗ Error ${response.status}`, "error");
				}
			} catch {
				ctx.ui.notify(`RLM Bridge: ✗ Not reachable at ${BRIDGE_URL}`, "error");
			}
		},
	});

	pi.on("session_start", async (_event, ctx) => {
		// Quick health check on startup
		try {
			const response = await fetch(`${BRIDGE_URL}/health`, {
				method: "GET",
				signal: AbortSignal.timeout(2000),
			});
			if (response.ok) {
				ctx.ui.setStatus("rlm", "RLM: ✓");
			} else {
				ctx.ui.setStatus("rlm", "RLM: ✗");
			}
		} catch {
			ctx.ui.setStatus("rlm", "RLM: ✗ offline");
		}
	});
}
