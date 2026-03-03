# Report: MCP Patterns in Codex CLI

## Overview

Model Context Protocol (MCP) extends Codex CLI with external tool capabilities. Codex CLI's MCP support includes both client-side (consuming MCP servers) and server-side (exposing Codex as an MCP server), making it uniquely versatile in multi-agent architectures.

## Client-Side MCP: Consuming External Tools

### Configuration

MCP servers are declared in `codex.toml`:

```toml
[mcp.servers.name]
command = "executable"
args = ["arg1", "arg2"]
env = { KEY = "$ENV_VAR" }
```

### Common Server Types

**File System Server**: Structured file access beyond built-in tools.
```toml
[mcp.servers.filesystem]
command = "npx"
args = ["-y", "@modelcontextprotocol/server-filesystem", "./src"]
```

**Database Server**: SQL query capability for development context.
```toml
[mcp.servers.postgres]
command = "npx"
args = ["-y", "@modelcontextprotocol/server-postgres"]
env = { DATABASE_URL = "$DATABASE_URL" }
```

**GitHub Server**: Rich GitHub API access (issues, PRs, repos).
```toml
[mcp.servers.github]
command = "npx"
args = ["-y", "@modelcontextprotocol/server-github"]
env = { GITHUB_TOKEN = "$GITHUB_TOKEN" }
```

**Web Search Server**: Real-time web search for current information.
```toml
[mcp.servers.tavily]
command = "npx"
args = ["-y", "@tavily/mcp-server"]
env = { TAVILY_API_KEY = "$TAVILY_API_KEY" }
```

## Server-Side MCP: Codex as a Tool

Codex CLI can expose itself as an MCP server, enabling other agents or tools to invoke it:

```bash
codex --as-mcp-server
```

### Use Cases

1. **IDE Integration**: An editor plugin connects to Codex via MCP for inline code assistance
2. **Agent Composition**: A higher-level orchestrator uses Codex as its coding tool
3. **Pipeline Integration**: CI systems call Codex through standardized MCP protocol
4. **Multi-Agent Systems**: Multiple specialized agents coordinate, with Codex handling code tasks

### Configuration for Consumers

Any MCP-compatible client can add Codex as a server:

```json
{
  "mcpServers": {
    "codex": {
      "command": "codex",
      "args": ["--as-mcp-server"],
      "env": { "OPENAI_API_KEY": "..." }
    }
  }
}
```

## Agent-Scoped MCP

A key pattern: restrict MCP servers to specific agents:

```yaml
# agents/data-analyst.md
---
name: data-analyst
mcpServers:
  - postgres
---

# agents/frontend-dev.md
---
name: frontend-dev
mcpServers:
  - filesystem
---
```

**Benefits**:
- Least-privilege: agents only access the tools they need
- Reduced context pollution: fewer tools means clearer tool selection
- Security: database access is limited to the data agent

## Sandbox Interaction

MCP servers run as child processes of Codex. Sandbox mode affects them:

| Sandbox Mode | MCP Server Behavior |
|---|---|
| `full` | Network-dependent MCP servers will fail |
| `network-only` | MCP servers can run but cannot make outbound connections |
| `off` | Full MCP server functionality |

**Practical implication**: If you use MCP servers that need network (GitHub, web search, external APIs), you need `sandbox.mode = "off"`.

## Patterns and Anti-Patterns

### Pattern: Layered MCP Access
```toml
# Available to all agents
[mcp.servers.filesystem]
command = "npx"
args = ["-y", "@modelcontextprotocol/server-filesystem", "."]

# Scoped to specific agents via agent frontmatter
[mcp.servers.postgres]
command = "npx"
args = ["-y", "@modelcontextprotocol/server-postgres"]
env = { DATABASE_URL = "$DATABASE_URL" }
```

### Pattern: Environment-Specific MCP
```toml
# Development: real database
[mcp.servers.postgres]
env = { DATABASE_URL = "$DEV_DATABASE_URL" }

# CI: test database
[profile.ci.mcp.servers.postgres]
env = { DATABASE_URL = "$TEST_DATABASE_URL" }
```

### Anti-Pattern: Unrestricted MCP
Giving all agents access to all MCP servers (database, GitHub, filesystem) with `sandbox.mode = "off"` and `approval_policy = "full-auto"`. This is the maximum risk configuration.

## Security Recommendations

1. Audit each MCP server's tool list before adding it
2. Use agent-scoped MCP for sensitive servers (databases, APIs with write access)
3. Keep `sandbox.mode` as restrictive as your MCP servers allow
4. Never hardcode secrets — always use `$ENV_VAR` references
5. Review MCP server npm packages for known vulnerabilities
