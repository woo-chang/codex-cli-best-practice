# Best Practice: Approval Policies

Approval policies control how much autonomy Codex CLI has when executing commands and making changes. They are the primary mechanism for balancing productivity with safety.

## Policy Levels

| Policy | File Edits | Commands | User Interaction |
|---|---|---|---|
| `suggest` | Proposed, not applied | Proposed, not executed | Approve every action |
| `auto-edit` | Applied automatically | Require approval | Approve commands only |
| `full-auto` | Applied automatically | Auto-executed (if in allow-list) | Minimal interaction |

## Configuration

```toml
# codex.toml
approval_policy = "auto-edit"  # recommended default
```

## Policy Details

### Suggest Mode

Every action is proposed and requires explicit approval:

```toml
approval_policy = "suggest"
```

**Best for**:
- Learning Codex CLI's behavior on a new project
- Code review tasks where you want to see reasoning before changes
- High-stakes operations (production configs, security-sensitive code)
- Onboarding new team members to Codex workflows

**Trade-off**: Safest but slowest — every file edit and command needs a "yes."

### Auto-Edit Mode

File modifications are applied automatically; shell commands still require approval:

```toml
approval_policy = "auto-edit"
```

**Best for**:
- Day-to-day development (the recommended default)
- Refactoring tasks where file edits are the primary output
- Situations where you trust file changes but want to review commands

**Trade-off**: Good balance of speed and safety. File edits are reversible via git, but commands might not be.

### Full-Auto Mode

Both file edits and commands execute without approval, subject to the allow-list:

```toml
approval_policy = "full-auto"

[permissions]
auto_approve = [
  "bash(git:*)",
  "bash(npm test:*)",
  "bash(npm run lint:*)",
  "read",
  "write",
  "edit",
  "glob",
  "grep"
]
```

**Best for**:
- CI/CD pipelines (always pair with `sandbox.mode = "full"`)
- Well-understood, repetitive tasks
- Experienced users with comprehensive allow-lists

**Trade-off**: Fastest but riskiest. Commands outside the allow-list still prompt for approval.

## Allow-List Patterns

The `auto_approve` list uses glob patterns to match tool invocations:

```toml
[permissions]
auto_approve = [
  # Git operations
  "bash(git:*)",

  # Test and lint (safe, read-only-ish)
  "bash(npm test:*)",
  "bash(npm run lint:*)",
  "bash(pytest:*)",

  # File operations
  "read",
  "write",
  "edit",
  "glob",
  "grep",

  # Specific commands
  "bash(ls:*)",
  "bash(cat:*)",
  "bash(wc:*)"
]
```

### Pattern Best Practices

| Pattern | Matches | Risk Level |
|---|---|---|
| `bash(git:*)` | All git commands | Low |
| `bash(npm test:*)` | Test execution | Low |
| `bash(npm:*)` | All npm commands including `npm publish` | Medium |
| `bash(rm:*)` | All rm commands | High |
| `bash(*)` | Everything | Very High |

**Rule of thumb**: Start with the narrowest patterns and expand only when you hit friction repeatedly.

## Combining Sandbox + Approval

The safest configurations pair restrictive sandbox with appropriate approval:

| Configuration | Safety | Speed | Use Case |
|---|---|---|---|
| `full` + `suggest` | Maximum | Minimum | Security audits |
| `full` + `full-auto` | High | High | CI pipelines |
| `network-only` + `auto-edit` | Medium | Medium | Daily development |
| `off` + `suggest` | Medium | Low | API-dependent tasks |
| `off` + `full-auto` | Low | Maximum | Trusted automation |

## Profile-Based Policies

```toml
# Conservative default
approval_policy = "suggest"

# Open up for known-safe tasks
[profile.dev]
approval_policy = "auto-edit"

# Full automation for CI
[profile.ci]
approval_policy = "full-auto"
sandbox.mode = "full"
```

## Anti-Patterns

- **`full-auto` without an allow-list**: Grants unrestricted command execution
- **`full-auto` + `sandbox.mode = "off"`**: Maximum risk — no safety net
- **`bash(*)` in allow-list**: Bypasses all command approval
- **Never reviewing what `auto-edit` changed**: Use `git diff` regularly
- **Same policy for all tasks**: Use profiles to match policy to context
