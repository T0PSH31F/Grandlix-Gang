/**
 * context-capture — OpenCode plugin for automatic session context persistence
 *
 * Captures session messages to context-mode's FTS5 knowledge base on:
 *   - session.idle    (session went quiet — good incremental checkpoint)
 *   - session.compacted (context window was compacted — capture pre-compaction)
 *   - session.created (index the new session shell so it's searchable immediately)
 *
 * Storage: ~/.opencode/context-capture/sessions/<sessionID>.md
 * Indexed via: context-mode index --source opencode-session:<sessionID>
 *
 * Requires: context-mode CLI in PATH (installed via npx or globally)
 */

import { spawn } from "node:child_process";
import { mkdir, writeFile, readFile } from "node:fs/promises";
import { join } from "node:path";
import { homedir } from "node:os";

const CAPTURE_DIR = join(homedir(), ".opencode", "context-capture", "sessions");
const CONTEXT_MODE_BIN = "npx";
const CONTEXT_MODE_ARGS = ["-y", "context-mode"];

/** Debounce map: sessionID → timeout handle */
const debounceTimers = new Map();
const DEBOUNCE_MS = 5_000; // wait 5s after last event before indexing

/**
 * Format a single message + its parts into markdown.
 */
function formatMessage(info, parts) {
  const role = info.role === "user" ? "## User" : "## Assistant";
  const ts = info.time?.created
    ? new Date(info.time.created * 1000).toISOString()
    : "";
  const agent = info.agent ? ` [${info.agent}]` : "";
  const model =
    info.modelID || info.model?.modelID
      ? ` (${info.modelID || info.model?.modelID})`
      : "";

  const lines = [`${role}${agent}${model}`, ts ? `> ${ts}` : "", ""];

  // Extract text parts
  for (const part of parts) {
    if (part.type === "text" && part.text?.trim()) {
      lines.push(part.text.trim(), "");
    } else if (part.type === "tool-invocation") {
      const toolName = part.toolInvocation?.toolName || "unknown";
      const state = part.toolInvocation?.state || "";
      lines.push(`> [tool: ${toolName} — ${state}]`, "");
    } else if (part.type === "reasoning" && part.text?.trim()) {
      lines.push(`<details><summary>Reasoning</summary>`, "");
      lines.push(part.text.trim(), "");
      lines.push(`</details>`, "");
    }
  }

  return lines.join("\n");
}

/**
 * Index a markdown file into context-mode's FTS5 knowledge base.
 */
function indexFile(filePath, source) {
  return new Promise((resolve, reject) => {
    const child = spawn(CONTEXT_MODE_BIN, [
      ...CONTEXT_MODE_ARGS,
      "index",
      filePath,
      "--source",
      source,
    ], {
      stdio: ["ignore", "pipe", "pipe"],
      timeout: 30_000,
    });

    let stderr = "";
    child.stderr?.on("data", (d) => (stderr += d));

    child.on("close", (code) => {
      if (code === 0) resolve();
      else reject(new Error(`context-mode index exited ${code}: ${stderr}`));
    });

    child.on("error", reject);
  });
}

/**
 * Fetch messages for a session and write/index them.
 */
async function captureSession(client, sessionID) {
  try {
    // Fetch messages via OpenCode SDK
    const result = await client.session.messages({
      path: { id: sessionID },
      query: { limit: 200 },
    });

    if (result.error) {
      console.error(`[context-capture] Failed to fetch messages for ${sessionID}:`, result.error);
      return;
    }

    const messages = result.data;
    if (!messages?.length) return;

    // Format all messages as markdown
    const sections = messages.map(({ info, parts }) =>
      formatMessage(info, parts)
    );

    const header = `# OpenCode Session: ${sessionID}\n\nCaptured: ${new Date().toISOString()}\nMessages: ${messages.length}\n\n---\n\n`;
    const markdown = header + sections.join("\n---\n\n");

    // Write to disk
    await mkdir(CAPTURE_DIR, { recursive: true });
    const filePath = join(CAPTURE_DIR, `${sessionID}.md`);
    await writeFile(filePath, markdown, "utf-8");

    // Index into context-mode
    const source = `opencode-session:${sessionID}`;
    await indexFile(filePath, source);

    console.error(`[context-capture] Indexed ${messages.length} messages for session ${sessionID}`);
  } catch (err) {
    console.error(`[context-capture] Error capturing session ${sessionID}:`, err.message);
  }
}

/**
 * Debounced capture — avoids rapid re-indexing during active sessions.
 */
function debouncedCapture(client, sessionID) {
  if (debounceTimers.has(sessionID)) {
    clearTimeout(debounceTimers.get(sessionID));
  }
  debounceTimers.set(
    sessionID,
    setTimeout(() => {
      debounceTimers.delete(sessionID);
      captureSession(client, sessionID);
    }, DEBOUNCE_MS)
  );
}

/**
 * OpenCode plugin entry point.
 */
export default async function ContextCapturePlugin(ctx) {
  const { client } = ctx;

  console.error("[context-capture] Plugin loaded — automatic session capture active");

  return {
    event: async ({ event }) => {
      const { type, properties } = event;

      switch (type) {
        case "session.idle": {
          // Session went quiet — good time to checkpoint
          const sessionID = properties?.sessionID;
          if (sessionID) {
            debouncedCapture(client, sessionID);
          }
          break;
        }

        case "session.compacted": {
          // Context was compacted — capture NOW before more messages arrive
          const sessionID = properties?.sessionID;
          if (sessionID) {
            // Don't debounce compacted — capture immediately
            captureSession(client, sessionID);
          }
          break;
        }

        case "session.created": {
          // Index the session shell so it's findable immediately
          const session = properties?.info;
          if (session?.id) {
            const filePath = join(CAPTURE_DIR, `${session.id}.md`);
            const header = `# OpenCode Session: ${session.id}\n\nCreated: ${new Date().toISOString()}\nStatus: active\n`;
            try {
              await mkdir(CAPTURE_DIR, { recursive: true });
              await writeFile(filePath, header, "utf-8");
              await indexFile(filePath, `opencode-session:${session.id}`);
            } catch (err) {
              // Non-fatal — session will be captured on idle
            }
          }
          break;
        }

        case "session.error": {
          // Capture on error to preserve context before potential crash
          const sessionID = properties?.sessionID;
          if (sessionID) {
            captureSession(client, sessionID);
          }
          break;
        }
      }
    },
  };
}
