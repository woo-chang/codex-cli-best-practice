# Report: Codex CLI Configuration Hierarchy

## Overview

Codex CLI uses a layered TOML configuration system that merges settings from multiple sources. Understanding the merge order is essential for predictable behavior across different environments.

## Configuration Sources (Priority Order)

```
1. CLI flags          (highest priority — overrides everything)
2. codex.local.toml   (personal, git-ignored)
3. codex.toml         (project, version-controlled)
4. ~/.codex/config.toml (global user defaults)
5. Built-in defaults  (lowest priority)
```

## Merge Behavior

Settings are merged at the key level, not the file level:

```toml
# ~/.codex/config.toml (global)
model = "o4-mini"
approval_policy = "suggest"

# codex.toml (project)
approval_policy = "auto-edit"
# model is NOT set — inherits from global

# Result: model = "o4-mini", approval_policy = "auto-edit"
```

**Key rule**: A more specific source only overrides keys it explicitly sets. Unset keys fall through to less specific sources.

## AGENTS.md Hierarchy

Instruction files follow a separate but parallel hierarchy:

```
/repo/AGENTS.md                    # Root instructions
/repo/packages/api/AGENTS.md      # Package-level overrides
/repo/packages/api/src/AGENTS.md  # Directory-level overrides
```

All matching AGENTS.md files are loaded and concatenated, with deeper files appearing later in context. This means deeper files effectively override earlier ones when instructions conflict.

## Profile Interaction

Profiles are overlays applied on top of the merged base config:

```toml
# Base config (after merge)
model = "o4-mini"
approval_policy = "auto-edit"

[sandbox]
mode = "network-only"

# Profile overlay
[profile.ci]
approval_policy = "full-auto"
sandbox.mode = "full"

# When --profile ci is active:
# model = "o4-mini" (from base, profile didn't set it)
# approval_policy = "full-auto" (from profile)
# sandbox.mode = "full" (from profile)
```

## Environment Variable Expansion

TOML values can reference environment variables with `$VAR` syntax:

```toml
[mcp.servers.github]
env = { GITHUB_TOKEN = "$GITHUB_TOKEN" }
```

Expansion happens at runtime, after all config layers are merged. This means the same config file works across machines with different environment setups.

## Debugging Configuration

To understand which settings are active and where they come from:

```bash
# Show effective config
codex config show

# Show with source annotations
codex config show --verbose
```

## Recommendations

1. **Global config**: Set only personal defaults (model preference, default approval policy)
2. **Project config**: Set team-agreed standards (sandbox mode, approval policy, MCP servers)
3. **Local config**: Override for personal workflow (more permissive approval during active dev)
4. **Profiles**: Context-specific overrides (CI, review, deploy)
5. **CLI flags**: One-off overrides for specific invocations

## Common Pitfalls

- **Forgetting local overrides exist**: If Codex behaves differently than expected, check `codex.local.toml`
- **Profile key typos**: A misspelled profile name silently creates a new unused profile
- **Assuming file-level override**: Setting one key in local config does NOT blank out all other keys from project config
- **Not git-ignoring local config**: `codex.local.toml` should always be in `.gitignore`
