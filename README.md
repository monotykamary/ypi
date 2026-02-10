# pi-rlm-extension

A [Pi](https://github.com/badlogic/pi-mono) extension that routes LLM completions through an [RLM (Recursive Language Model)](https://github.com/SuperAGI/recursive-lm) backend. Instead of a single-pass LLM call, every agent turn goes through `rlm.completion()` which recursively builds context.

## Architecture

```
┌─────────────────┐    HTTP    ┌──────────────────┐    API     ┌──────────────┐
│  Pi Extension   │◄──────────►│  Python Bridge   │◄──────────►│  OpenRouter/  │
│  (TypeScript)   │            │  (Flask + RLM)   │            │  OpenAI/etc  │
└─────────────────┘            └──────────────────┘            └──────────────┘
        │                               │
        ▼                               ▼
  Pi Agent Loop                  rlm.completion()
  (tools, context)               (recursive calls)
```

## Setup

### 1. Python Bridge

```bash
cd rlm_bridge
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

# Configure API key (default backend is openrouter)
export OPENROUTER_API_KEY=your-key-here

# Start the bridge
python server.py
```

### 2. Pi Extension

```bash
# Install dependencies
bun install

# Set the dummy API key (required for pi to accept the provider)
export RLM_DUMMY_KEY=dummy
```

## Usage

```bash
# Start the bridge in one terminal
cd rlm_bridge && source .venv/bin/activate && python server.py

# Run pi with the RLM extension in another terminal
export RLM_DUMMY_KEY=dummy
pi -e ./extension.ts --provider rlm --model rlm-default

# Or in print mode
pi -e ./extension.ts --provider rlm --model rlm-default -p "Your prompt here"

# Check bridge status
# (in interactive mode, type): /rlm
```

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `RLM_BRIDGE_URL` | `http://localhost:8765` | Bridge server URL |
| `RLM_DUMMY_KEY` | (required) | Set to any value for pi to accept the provider |
| `OPENROUTER_API_KEY` | - | OpenRouter API key (default backend) |
| `OPENAI_API_KEY` | - | OpenAI API key (if using openai backend) |
| `ANTHROPIC_API_KEY` | - | Anthropic API key (if using anthropic backend) |
| `RLM_BACKEND` | `openrouter` | Backend provider for RLM |
| `RLM_MODEL` | `google/gemini-3-flash-preview` | Model for the backend |
| `RLM_MAX_RECURSION` | `10` | Max recursion depth |

## Phase 1 MVP (Current)

- ✅ Pi extension registers `rlm` provider via `pi.registerProvider()`
- ✅ Python bridge wraps the RLM library (Flask server)
- ✅ Full completion flow: Pi → Bridge → RLM → OpenRouter → response
- ✅ Multi-turn conversation support
- ✅ Health check status in footer
- ✅ `/rlm` command for bridge status
- ⬚ No streaming (returns full response as single block)
- ⬚ No tool calling through RLM

## Roadmap

- [ ] Phase 2: Tool calling support
- [ ] Phase 3: Real streaming (text_delta events via SSE)
- [ ] Phase 4: Proper usage/token tracking from RLM's UsageSummary
