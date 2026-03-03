# codex-cli-best-practice
practice makes codex perfect

![Last Updated](https://img.shields.io/badge/Last_Updated-Mar_03%2C_2026_02%3A50_PM_PKT-white?style=flat&labelColor=555) <a href="https://github.com/shanraisshan/codex-cli-best-practice/stargazers"><img src="https://img.shields.io/github/stars/shanraisshan/codex-cli-best-practice?style=flat&label=%E2%98%85&labelColor=555&color=white" alt="GitHub Stars"></a>

[![Best Practice](!/tags/best-practice.svg)](best-practice/) *Click on this badge to show the latest best practice*<br>
[![Implemented](!/tags/implemented.svg)](.codex/) *Click on this badge to show implementation in this repo*<br>
[![Orchestration Workflow](!/tags/orchestration-workflow.svg)](orchestration-workflow/orchestration-workflow.md) *Click on this badge to see the Skill → Skill orchestration workflow*

<p align="center">
  <img src="!/codex-jumping.svg" alt="Codex CLI mascot jumping" width="120" height="100">
</p>

## CONCEPTS

| Feature | Location | Description |
|---------|----------|-------------|
| [**Instructions**](https://developers.openai.com/codex/guides/agents-md) | [`AGENTS.md`](AGENTS.md) | [![Best Practice](!/tags/best-practice.svg)](best-practice/codex-agents-md.md) Project-level context for Codex CLI — loaded from every directory up to repo root, capped at 32 KiB. Fallback: `CODEX.md` |
| [**Configuration**](https://developers.openai.com/codex/config-basic) | [`.codex/config.toml`](.codex/config.toml) | [![Best Practice](!/tags/best-practice.svg)](best-practice/codex-config.md) [![Implemented](!/tags/implemented.svg)](.codex/config.toml) TOML-based layered config: global (`~/.codex/`) → project (`.codex/`) → CLI flags |
| [**Profiles**](https://developers.openai.com/codex/config-basic) | [`.codex/config.toml`](.codex/config.toml) | [![Best Practice](!/tags/best-practice.svg)](best-practice/codex-config.md) [![Implemented](!/tags/implemented.svg)](.codex/config.toml) Named config presets — `codex --profile ci`, `--profile conservative`, `--profile trusted` |
| [**Skills**](https://developers.openai.com/codex/skills) | [`.agents/skills/<name>/SKILL.md`](.agents/skills/) | [![Best Practice](!/tags/best-practice.svg)](best-practice/codex-skills.md) [![Implemented](!/tags/implemented.svg)](.agents/skills/) [Reference](docs/SKILLS.md) Reusable instruction packages with YAML frontmatter — invoke with `/skill-name` or preload into agents |
| [**Built-in Skills**](https://developers.openai.com/codex/skills) | `$plan`, `$skill-creator`, `$web-search` | Skills shipped with Codex CLI — planning, skill generation, and web search |
| [**Sandbox**](https://developers.openai.com/codex/cli/features) | `config.toml` → `sandbox_mode` | [![Best Practice](!/tags/best-practice.svg)](best-practice/codex-sandbox.md) OS-level isolation: `read-only` (no writes), `workspace-write` (no network), `danger-full-access` |
| [**Approval Policy**](https://developers.openai.com/codex/cli/features) | `config.toml` → `approval_policy` | [![Best Practice](!/tags/best-practice.svg)](best-practice/codex-approval-policies.md) Autonomy levels: `untrusted` (ask everything), `on-request` (model decides), `never` (full auto) |
| [**MCP Servers**](https://developers.openai.com/codex/mcp) | `config.toml` → `[mcp_servers.*]` | [![Best Practice](!/tags/best-practice.svg)](best-practice/codex-mcp.md) [![Implemented](!/tags/implemented.svg)](.codex/config.toml) Model Context Protocol for external tools — plus Codex-as-MCP-server pattern |
| [**Agents**](https://developers.openai.com/codex/cli/features) | [`.codex/agents/<name>.md`](.codex/agents/) | [![Implemented](!/tags/implemented.svg)](.codex/agents/) Specialized subagents with their own model, tools, and preloaded skills |
| [**Headless / CI**](https://developers.openai.com/codex/noninteractive) | `codex exec "prompt"` | [![Best Practice](!/tags/best-practice.svg)](best-practice/codex-headless.md) Non-interactive execution for pipelines and scripts |
| [**Sessions**](https://developers.openai.com/codex/cli/features) | `--resume`, `--fork` | [![Best Practice](!/tags/best-practice.svg)](best-practice/codex-sessions.md) Persistent sessions: resume where you left off or fork to explore alternatives |
| [**Override**](https://developers.openai.com/codex/rules) | [`AGENTS.override.md`](AGENTS.override.md) | Personal instruction overrides — loaded before `AGENTS.md`, not committed to git |

[![Orchestration Workflow](!/tags/orchestration-workflow-hd.svg)](orchestration-workflow/orchestration-workflow.md)

See [orchestration-workflow](orchestration-workflow/orchestration-workflow.md) for full implementation details of the **Skill → Skill** sequential pipeline pattern.

<p align="center">
  <img src="!/orchestration-workflow-diagram.svg" alt="Orchestration Workflow: Skill → Skill → Output" width="100%">
</p>

| Component | Role | Location |
|-----------|------|----------|
| **weather-fetcher** | Fetches current temperature from Open-Meteo API | [`.agents/skills/weather-fetcher/SKILL.md`](.agents/skills/weather-fetcher/SKILL.md) |
| **weather-svg-creator** | Creates SVG weather card | [`.agents/skills/weather-svg-creator/SKILL.md`](.agents/skills/weather-svg-creator/SKILL.md) |
| **weather-agent** | Agent with preloaded weather-fetcher skill | [`.codex/agents/weather-agent.md`](.codex/agents/weather-agent.md) |
| **output.md** | Generated weather report | [`orchestration-workflow/output.md`](orchestration-workflow/output.md) |

## TIPS AND TRICKS

**Workflows**
- Keep `AGENTS.md` under 150 lines — content beyond this is increasingly ignored
- Use skills with clear `name` and `description` frontmatter for auto-discovery
- Organize skills by feature domain (`weather-fetcher`, `weather-svg-creator`)
- Use profiles to switch between safety levels (`conservative` for review, `trusted` for dev)
- Use `AGENTS.override.md` for personal preferences without affecting the team
- Break complex tasks into composable skills rather than monolithic instructions
- Start with `approval_policy = "untrusted"` on new projects, then relax as trust builds

**Security**
- Default to `sandbox_mode = "workspace-write"` — blocks network access while allowing file edits
- Use `read-only` sandbox for code review and audit tasks
- Pair `approval_policy = "never"` with `read-only` sandbox in CI (safety from isolation)
- Never use `danger-full-access` + `never` approval without understanding the risks
- Use `$ENV_VAR` references for MCP server secrets — never hardcode tokens in config.toml
- Scope MCP servers to specific agents via agent frontmatter

**Debugging**
- Use `codex --profile conservative` when investigating unexpected behavior
- Check effective config with `codex config show --verbose`
- Run `codex exec` with a simple prompt to validate CI configuration
- Review auto-approved actions via `git log` and `git diff`

## REPORTS

| Report | Description |
|--------|-------------|
| [Configuration Hierarchy](reports/config-hierarchy.md) | Config merge order, layer precedence, profile interaction, and environment variable expansion |
| [Sandbox Modes](reports/sandbox-modes.md) | OS-level isolation architecture, security analysis, and performance impact by mode |
| [Approval Policies](reports/approval-policies.md) | Policy mechanics, allow-list design patterns, and the sandbox + approval safety matrix |
| [MCP Patterns](reports/mcp-patterns.md) | Client/server MCP, agent-scoped servers, Codex-as-MCP-server, and sandbox interaction |
| [Headless CI/CD](reports/headless-ci-cd.md) | `codex exec` integration with GitHub Actions, GitLab CI, and Jenkins |
