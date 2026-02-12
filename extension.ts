/**
 * Pi RLM Extension — Status indicator for recursive mode.
 *
 * Shows "RLM ↻{depth}" in the status bar when running under ypi.
 * No custom provider — ypi uses Pi's native model with a system prompt.
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

export default function (pi: ExtensionAPI) {
	pi.on("session_start", async (_event, ctx) => {
		const depth = process.env.RLM_MAX_DEPTH || "3";
		ctx.ui.setStatus("rlm", `RLM ↻${depth}`);
	});
}
