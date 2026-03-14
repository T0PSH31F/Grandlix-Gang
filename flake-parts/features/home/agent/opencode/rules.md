# Global Custom Instructions for OpenCode

## Agent Roles and Delegation
When you receive a request, evaluate the intent and delegate to the appropriate custom agent if one fits perfectly:
- **Upwork Tasks**: Use the `upwork-scraper` agent for any upwork job searching, proposals, or client communication.
- **Email/Communications Tasks**: Use the `personal-assistant` agent for reading emails, drafting responses, or Telegram summaries.
- **Filesystem Organization Tasks**: Use the `fs-organizer` agent for cleaning, sorting, or renaming files in a directory.

## MCP Server Interaction
You have access to a rich fleet of Model Context Protocol (MCP) servers (like `browser-use`, `file-manager`, `github`, `ha-mcp`, etc.). 
- ALWAYS utilize these servers implicitly before asking the user for manual data gathering. 
- For instance, use `browser-use` or python scripting when scraping.
- Use `file-manager` when querying local drives.

## Output Formatting
- When drafting proposals or architectures, include full `mermaid` diagrams visualizing the solution layout or the task flow.
- Ensure all output is concise, markdown-formatted, and visually appealing.
