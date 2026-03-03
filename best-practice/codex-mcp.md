# Best Practice: MCP (Model Context Protocol)

Codex CLI supports MCP for extending its capabilities with external tools. Uniquely, Codex CLI can also expose itself as an MCP server, enabling other agents to use it as a tool.

## MCP Server Configuration

Configure MCP servers in `codex.toml`:

```toml
[mcp.servers.filesystem]
command = "npx"
args = ["-y", "@modelcontextprotocol/server-filesystem", "/path/to/dir"]

[mcp.servers.github]
command = "npx"
args = ["-y", "@modelcontextprotocol/server-github"]
env = { GITHUB_TOKEN = "$GITHUB_TOKEN" }

[mcp.servers.postgres]
command = "npx"
args = ["-y", "@modelcontextprotocol/server-postgres"]
env = { DATABASE_URL = "$DATABASE_URL" }
```

## Agent-Scoped MCP Servers

Restrict MCP servers to specific agents to follow least-privilege:

```yaml
# agents/data-analyst.md
---
name: data-analyst
mcpServers:
  - postgres
  - filesystem
---
```

Only the `data-analyst` agent can access the database — other agents cannot.

## Environment Variables

Use `$ENV_VAR` syntax for secrets. Never hardcode tokens:

```toml
# Good: references environment variable
[mcp.servers.github]
env = { GITHUB_TOKEN = "$GITHUB_TOKEN" }

# Bad: hardcoded secret
[mcp.servers.github]
env = { GITHUB_TOKEN = "ghp_abc123..." }
```

## Codex-as-MCP-Server

Codex CLI can expose itself as an MCP tool, allowing other AI agents or applications to use it:

```bash
# Start Codex as an MCP server
codex --as-mcp-server
```

This enables:
- **Agent composition**: One AI agent uses Codex CLI as a coding tool
- **IDE integration**: Editors can call Codex through the MCP protocol
- **Pipeline orchestration**: CI systems can invoke Codex via MCP

### Configuration for Consumers

Other MCP-compatible tools can connect to Codex:

```json
{
  "mcpServers": {
    "codex": {
      "command": "codex",
      "args": ["--as-mcp-server"]
    }
  }
}
```

## Common MCP Patterns

### File System Access
```toml
[mcp.servers.filesystem]
command = "npx"
args = ["-y", "@modelcontextprotocol/server-filesystem", "."]
```
Provides structured file operations beyond Codex's built-in tools.

### Database Access
```toml
[mcp.servers.postgres]
command = "npx"
args = ["-y", "@modelcontextprotocol/server-postgres"]
env = { DATABASE_URL = "$DATABASE_URL" }
```
Allows Codex to query databases for context during development.

### Web Search
```toml
[mcp.servers.tavily]
command = "npx"
args = ["-y", "@tavily/mcp-server"]
env = { TAVILY_API_KEY = "$TAVILY_API_KEY" }
```

## Security Considerations

1. **Sandbox interaction**: MCP servers that need network access require `sandbox.mode = "off"` or `"network-only"`
2. **Secret management**: Always use environment variables for tokens and credentials
3. **Scope servers to agents**: Don't give every agent access to every MCP server
4. **Audit MCP packages**: Review what tools an MCP server exposes before adding it
5. **Approval policy**: MCP tool calls respect your approval policy — `suggest` mode will prompt before each MCP tool use

## Anti-Patterns

- **Running MCP servers with `sandbox.mode = "full"`**: MCP servers need at minimum `network-only` to function
- **Hardcoding secrets in config**: Use `$ENV_VAR` references
- **Granting all agents access to all MCP servers**: Scope by agent
- **Ignoring MCP server permissions**: Some MCP servers have broad capabilities (filesystem write, database drop) — review their tool lists
