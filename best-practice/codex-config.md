# Best Practice: config.toml

Codex CLI uses TOML for configuration, providing a human-readable alternative to JSON. Configuration supports layered precedence and named profiles.

## Config File Locations

| Location | Scope | Purpose |
|---|---|---|
| `~/.codex/config.toml` | Global | User-wide defaults |
| `./codex.toml` | Project | Team-shared project settings |
| `./codex.local.toml` | Local | Personal overrides (git-ignored) |

**Precedence**: Local > Project > Global. More specific settings override general ones.

## Basic Configuration

```toml
# codex.toml — project-level config
model = "o4-mini"
approval_policy = "auto-edit"

[sandbox]
mode = "network-only"

[permissions]
auto_approve = [
  "bash(git:*)",
  "read",
  "glob",
  "grep"
]
```

## Named Profiles

Profiles let you switch between configurations without editing files:

```toml
# Default settings
model = "o4-mini"
approval_policy = "suggest"

[sandbox]
mode = "full"

# CI profile: headless, fast, locked-down
[profile.ci]
model = "o4-mini"
approval_policy = "full-auto"
sandbox.mode = "full"

# Development profile: permissive for local work
[profile.dev]
model = "o3"
approval_policy = "auto-edit"
sandbox.mode = "network-only"

# Review profile: read-only analysis
[profile.review]
model = "o4-mini"
approval_policy = "suggest"
sandbox.mode = "full"
```

Activate with: `codex --profile ci exec "run the test suite"`

## Layer Strategy

### Global Config (`~/.codex/config.toml`)
Set personal defaults that apply everywhere:
```toml
model = "o4-mini"
approval_policy = "suggest"
```

### Project Config (`codex.toml`)
Commit to version control. Contains team-agreed settings:
```toml
model = "o4-mini"
approval_policy = "auto-edit"

[sandbox]
mode = "network-only"

[permissions]
auto_approve = ["bash(npm:*)", "bash(git:*)"]
```

### Local Config (`codex.local.toml`)
Git-ignored. Personal overrides for your workflow:
```toml
model = "o3"
approval_policy = "full-auto"

[permissions]
auto_approve = ["bash(*)"]
```

## Key Patterns

### Principle of Least Privilege
Start restrictive, open up as needed:
1. Begin with `approval_policy = "suggest"` and `sandbox.mode = "full"`
2. Add specific `auto_approve` patterns as trust builds
3. Only use `full-auto` with comprehensive allow-lists

### Environment-Specific Overrides
Use profiles rather than editing config between tasks:
- `--profile ci` for automated pipelines
- `--profile dev` for local development
- `--profile review` for code review sessions

### MCP Server Configuration
```toml
[mcp.servers.filesystem]
command = "npx"
args = ["-y", "@modelcontextprotocol/server-filesystem", "/path/to/allowed"]

[mcp.servers.github]
command = "npx"
args = ["-y", "@modelcontextprotocol/server-github"]
env = { GITHUB_TOKEN = "$GITHUB_TOKEN" }
```

## Anti-Patterns

- **Committing `codex.local.toml`**: Always git-ignore personal overrides
- **Using `full-auto` without allow-lists**: Grants unrestricted execution
- **Hardcoding paths**: Use environment variables for machine-specific values
- **Mixing concerns in one profile**: Keep profiles focused (CI, dev, review)
