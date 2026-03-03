# Best Practice: Sandbox Modes

Codex CLI provides built-in sandboxing that restricts file system and network access during execution. This is a key differentiator from other coding agents.

## Sandbox Modes

| Mode | File System | Network | Use Case |
|---|---|---|---|
| `full` | Read-only (writes to tmpfs) | Blocked | CI, code review, untrusted repos |
| `network-only` | Full read/write | Blocked | Local development, file generation |
| `off` | Full read/write | Full access | Trusted projects needing APIs/installs |

## Configuration

```toml
# codex.toml
[sandbox]
mode = "network-only"  # default recommendation
```

Override per-profile:
```toml
[profile.ci]
sandbox.mode = "full"

[profile.dev]
sandbox.mode = "network-only"

[profile.trusted]
sandbox.mode = "off"
```

## Mode Details

### Full Sandbox (`full`)

The most restrictive mode. All file writes go to a temporary filesystem overlay:

- **File system**: Read-only view of the real filesystem; writes redirected to tmpfs
- **Network**: All outbound connections blocked
- **Process**: Restricted to the sandbox environment

**When to use**:
- CI/CD pipelines where you want deterministic, safe execution
- Reviewing code from untrusted sources
- Running analysis tasks that should never modify files
- Security audits

**Limitations**:
- Cannot install packages (`npm install`, `pip install`)
- Cannot fetch remote data (APIs, git clone)
- File modifications are lost when the session ends

### Network-Only Sandbox (`network-only`)

Balanced mode — allows file changes but blocks network:

- **File system**: Full read/write access to the project directory
- **Network**: All outbound connections blocked
- **Process**: Can execute local commands

**When to use**:
- Day-to-day development with pre-installed dependencies
- Refactoring, code generation, test writing
- Any task that doesn't need external API calls

**This is the recommended default** — it prevents accidental data exfiltration while allowing productive file operations.

### No Sandbox (`off`)

Full access to filesystem and network:

- **File system**: Unrestricted
- **Network**: Unrestricted
- **Process**: Unrestricted

**When to use**:
- Projects requiring package installation during tasks
- Tasks that call external APIs (fetching data, deploying)
- Working with MCP servers that need network access

**Always pair with**: `approval_policy = "auto-edit"` or `"suggest"` to maintain a human review checkpoint.

## Security Implications

### Threat Model

| Threat | `full` | `network-only` | `off` |
|---|---|---|---|
| Malicious file writes | Blocked (tmpfs) | Possible | Possible |
| Data exfiltration | Blocked | Blocked | Possible |
| Supply chain attacks | Blocked | Blocked | Possible |
| Destructive commands | Limited (read-only) | Possible | Possible |

### Defense in Depth

Sandbox mode is one layer. Combine with:

1. **Approval policy**: `suggest` or `auto-edit` for human review
2. **Permission allow-lists**: Restrict which commands auto-execute
3. **Git safety**: Work on branches, never force-push main

## Decision Matrix

```
Is this a CI/CD pipeline?
  YES → full sandbox
  NO ↓

Does the task need network access?
  YES → off (with auto-edit approval)
  NO ↓

Does the task need to write files?
  YES → network-only (recommended default)
  NO → full sandbox
```

## Common Patterns

### CI Pipeline
```toml
[profile.ci]
sandbox.mode = "full"
approval_policy = "full-auto"
# Safe because full sandbox prevents all writes and network
```

### Local Development
```toml
[profile.dev]
sandbox.mode = "network-only"
approval_policy = "auto-edit"
```

### Deployment Tasks
```toml
[profile.deploy]
sandbox.mode = "off"
approval_policy = "suggest"
# Human approves every action during deployment
```
