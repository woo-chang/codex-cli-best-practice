# Report: Approval Policies in Codex CLI

## Overview

Approval policies define the level of autonomy Codex CLI has when performing actions. They operate independently from sandbox modes, creating a two-dimensional safety matrix: sandbox controls what is physically possible, while approval policies control what is permitted without human review.

## Policy Mechanics

### Suggest

The most conservative policy. Every action is presented to the user for review before execution:

- File edits are shown as diffs, not applied
- Commands are displayed, not executed
- The user must explicitly approve each action

**Execution flow**: Codex proposes → User reviews → User approves/rejects → Codex applies (if approved)

### Auto-Edit

A balanced policy. File operations execute automatically, but shell commands require approval:

- File writes, edits, and creations are applied immediately
- Shell commands (Bash tool) are presented for review
- File operations are considered low-risk because they are easily reversible via git

**Execution flow**: File ops execute immediately; Commands wait for approval

### Full-Auto

Maximum autonomy. Both file operations and commands execute without approval, subject to an allow-list:

- Commands matching `auto_approve` patterns execute immediately
- Commands NOT matching the allow-list still require approval
- An empty allow-list means no commands auto-execute (equivalent to `auto-edit`)

**Execution flow**: Matching actions execute immediately; non-matching actions wait for approval

## Allow-List Design Patterns

### Conservative Allow-List (Recommended Starting Point)

```toml
[permissions]
auto_approve = [
  "read",
  "glob",
  "grep",
  "bash(git status:*)",
  "bash(git diff:*)",
  "bash(git log:*)"
]
```

Only read operations and non-destructive git commands.

### Development Allow-List

```toml
[permissions]
auto_approve = [
  "read", "write", "edit", "glob", "grep",
  "bash(git:*)",
  "bash(npm test:*)",
  "bash(npm run lint:*)",
  "bash(npm run build:*)",
  "bash(ls:*)",
  "bash(cat:*)"
]
```

Adds file operations, all git commands, and build/test tooling.

### CI Allow-List

```toml
[permissions]
auto_approve = [
  "read", "glob", "grep",
  "bash(git:*)",
  "bash(npm:*)",
  "bash(pytest:*)"
]
```

Broad enough for automated pipelines, but sandbox provides the safety net.

## Safety Matrix

Combining sandbox mode and approval policy creates a risk profile:

| | `suggest` | `auto-edit` | `full-auto` |
|---|---|---|---|
| **`full` sandbox** | Ultra-safe | Safe | Safe (sandbox limits damage) |
| **`network-only`** | Safe | Balanced | Risky (file writes auto-execute) |
| **`off`** | Moderate | Moderate risk | High risk |

**Recommended combinations**:
- Daily dev: `network-only` + `auto-edit`
- CI/CD: `full` + `full-auto`
- Security review: `full` + `suggest`

## Behavioral Observations

1. **Auto-edit feels natural**: Most developer interactions are file edits. Auto-applying them keeps flow smooth while maintaining a checkpoint for commands.

2. **Full-auto needs good allow-lists**: Without patterns, full-auto is identical to auto-edit. The value comes from carefully curated allow-lists.

3. **Suggest mode is educational**: New users should start here to observe Codex's decision-making before trusting automation.

4. **Allow-list patterns are glob-based**: Use `*` wildcards. More specific patterns are safer: `bash(git commit:*)` is better than `bash(git:*)`.

## Recommendations

1. Start all new projects with `auto-edit` as the default policy
2. Use `suggest` for the first few sessions to build trust
3. Graduate to `full-auto` only with a well-tested allow-list
4. Always pair `full-auto` with at least `network-only` sandbox
5. Use profiles to switch policies by context rather than editing config
6. Review auto-approved actions periodically via `git log` and `git diff`
