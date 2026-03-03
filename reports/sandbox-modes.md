# Report: Sandbox Modes in Codex CLI

## Overview

Codex CLI's sandbox system provides OS-level isolation for code execution. Unlike permission-based systems that rely on the model's compliance, sandboxing enforces restrictions at the operating system level, making it a true security boundary.

## Architecture

The sandbox uses platform-specific isolation mechanisms:

- **macOS**: Apple Sandbox profiles (`sandbox-exec`) restricting file and network access
- **Linux**: Combination of namespaces, seccomp filters, and network restrictions
- **Fallback**: On unsupported platforms, sandbox restrictions are advisory (logged but not enforced)

## Mode Comparison

### Full Sandbox

| Aspect | Behavior |
|---|---|
| File reads | Allowed (real filesystem) |
| File writes | Redirected to tmpfs overlay |
| Network | Completely blocked |
| Process spawning | Allowed within sandbox |
| Persistence | All changes lost on exit |

**Implementation**: Creates a filesystem overlay where writes go to a temporary layer. The original files remain untouched regardless of what commands execute.

### Network-Only Sandbox

| Aspect | Behavior |
|---|---|
| File reads | Allowed |
| File writes | Allowed (real filesystem) |
| Network | Completely blocked |
| Process spawning | Allowed |
| Persistence | File changes persist |

**Implementation**: Only network access is restricted. File operations work normally against the real filesystem.

### No Sandbox

| Aspect | Behavior |
|---|---|
| File reads | Allowed |
| File writes | Allowed |
| Network | Allowed |
| Process spawning | Allowed |
| Persistence | Full persistence |

**Implementation**: No isolation applied. Codex operates with the same permissions as the user's shell.

## Security Analysis

### What Sandbox Protects Against

1. **Accidental data exfiltration**: `full` and `network-only` prevent any outbound connections
2. **Destructive writes**: `full` mode ensures no permanent file changes
3. **Supply chain attacks**: Blocking network prevents downloading malicious payloads
4. **Lateral movement**: Sandbox restricts access to files outside the project

### What Sandbox Does NOT Protect Against

1. **In-memory data access**: The model can still read sensitive data within allowed paths
2. **Side channels**: Timing attacks or other side channels are not mitigated
3. **Pre-existing malware**: If malicious code already exists in the project, sandbox doesn't detect it
4. **Social engineering**: The model could still suggest harmful code for the user to run outside the sandbox

## Performance Impact

| Mode | Overhead |
|---|---|
| `full` | Moderate (tmpfs overlay adds I/O redirection) |
| `network-only` | Minimal (only network syscalls filtered) |
| `off` | None |

For most development tasks, the overhead is imperceptible. CI pipelines with heavy I/O may see a small slowdown with `full` sandbox.

## Interaction with Other Features

- **MCP servers**: Require `network-only` or `off` if they make network calls
- **Package installation**: Requires `off` (needs both write and network)
- **Git operations**: `git push` needs network; `git add/commit` works in `network-only`
- **Approval policy**: Sandbox and approval are independent — both can be configured separately

## Recommendation Matrix

| Scenario | Recommended Mode | Rationale |
|---|---|---|
| CI/CD pipeline | `full` | Maximum isolation, no persistence needed |
| Code review | `full` | Read-only analysis, no changes needed |
| Local development | `network-only` | Need to write files, don't need network |
| API integration work | `off` + `auto-edit` | Needs network, keep human in the loop |
| Untrusted repository | `full` + `suggest` | Maximum caution |
