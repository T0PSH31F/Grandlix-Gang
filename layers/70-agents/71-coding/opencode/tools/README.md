# OpenCode Tools Directory

This directory contains custom `.ts` or `.js` tools that extend OpenCode's capabilities securely.

## How to add tools:
Place your javascript/typescript files in this folder. OpenCode will dynamically load them and they will be available to all your agents.

Example `greet.ts`:
```typescript
import { tool } from "@opencode-ai/plugin"

export default tool({
  description: "Greets the user",
  args: {
    name: tool.schema.string().describe("The name to greet"),
  },
  async execute(args) {
    return `Hello, ${args.name}!`
  },
})
```
