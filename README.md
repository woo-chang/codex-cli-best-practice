# codex-cli-best-practice
practice makes codex perfect

![Last Updated](https://img.shields.io/badge/Last_Updated-Mar_17%2C_2026_12%3A00_PM_PKT-white?style=flat&labelColor=555) <a href="https://github.com/shanraisshan/codex-cli-best-practice/stargazers"><img src="https://img.shields.io/github/stars/shanraisshan/codex-cli-best-practice?style=flat&label=%E2%98%85&labelColor=555&color=white" alt="GitHub Stars"></a>

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
| [**Agents**](https://developers.openai.com/codex/cli/features) | [`.codex/config.toml`](.codex/config.toml) + [`.codex/agents/<name>.toml`](.codex/agents/) | [![Implemented](!/tags/implemented.svg)](.codex/agents/) Specialized subagents registered under `[agents.<name>]`, optionally backed by dedicated TOML role configs |
| [**Headless / CI**](https://developers.openai.com/codex/noninteractive) | `codex exec "prompt"` | [![Best Practice](!/tags/best-practice.svg)](best-practice/codex-headless.md) Non-interactive execution for pipelines and scripts |
| [**Sessions**](https://developers.openai.com/codex/cli/features) | `--resume`, `--fork` | [![Best Practice](!/tags/best-practice.svg)](best-practice/codex-sessions.md) Persistent sessions: resume where you left off or fork to explore alternatives |
| [**Override**](https://developers.openai.com/codex/rules) | [`AGENTS.override.md`](AGENTS.override.md) | Personal instruction overrides — loaded before `AGENTS.md`, not committed to git |
| [**Workflows**](https://developers.openai.com/codex/workflows/) | IDE, CLI, Cloud | [![Implemented](!/tags/implemented.svg)](orchestration-workflow/orchestration-workflow.md) End-to-end usage patterns — bug fixes, reviews, refactors, prototyping, and documentation updates |
| **AI Terms** | | [![Best Practice](!/tags/best-practice.svg)](https://github.com/shanraisshan/claude-code-codex-cursor-gemini/blob/main/reports/ai-terms.md) Agentic Engineering · Context Engineering · Vibe Coding |
| [**Best Practices**](https://developers.openai.com/codex/learn/best-practices) | | Official best practices · [Prompt Engineering](https://platform.openai.com/docs/guides/prompt-engineering) · [Codex Guides](https://developers.openai.com/codex/overview) |

### 🔥 Hot

| Feature | Location | Description |
|---------|----------|-------------|
| [**Subagents**](https://developers.openai.com/codex/subagents) | [`.codex/agents/<name>.toml`](.codex/agents/) | [![Best Practice](!/tags/best-practice.svg)](best-practice/codex-subagents.md) Custom agents, CSV batch processing, and multi-agent orchestration |
| [**Multi-Agent**](https://developers.openai.com/codex/multi-agent/) | `/experimental` → Multi-agents | Spawn specialized sub-agents in parallel — fan-out work, collect results, and synthesize in one response |

[![Orchestration Workflow](!/tags/orchestration-workflow-hd.svg)](orchestration-workflow/orchestration-workflow.md)

See [orchestration-workflow](orchestration-workflow/orchestration-workflow.md) for full implementation details of the **Skill → Skill** sequential pipeline pattern.

<p align="center">
  <img src="!/orchestration-workflow-diagram.svg" alt="Orchestration Workflow: Skill → Skill → Output" width="100%">
</p>

| Component | Role | Location |
|-----------|------|----------|
| **weather-fetcher** | Fetches current temperature from Open-Meteo API | [`.agents/skills/weather-fetcher/SKILL.md`](.agents/skills/weather-fetcher/SKILL.md) |
| **weather-svg-creator** | Creates SVG weather card | [`.agents/skills/weather-svg-creator/SKILL.md`](.agents/skills/weather-svg-creator/SKILL.md) |
| **weather-agent** | Agent with preloaded weather-fetcher skill | [`.codex/agents/weather-agent.toml`](.codex/agents/weather-agent.toml) |
| **output.md** | Generated weather report | [`orchestration-workflow/output.md`](orchestration-workflow/output.md) |

## DEVELOPMENT WORKFLOWS
- [Cross-Model Claude Code + Codex](https://github.com/shanraisshan/claude-code-best-practice/blob/main/development-workflows/cross-model-workflow/cross-model-workflow.md) [![Implemented](!/tags/implemented.svg)](https://github.com/shanraisshan/claude-code-best-practice/blob/main/development-workflows/cross-model-workflow/cross-model-workflow.md)

## TIPS AND TRICKS

![Community](!/tags/community.svg)

■ **Planning (2)**
- use [`/plan`](https://developers.openai.com/codex/cli/slash-commands) when you want an explicit plan — Codex may also plan automatically for multi-step tasks
- use [cross-model](https://github.com/shanraisshan/claude-code-best-practice/blob/main/development-workflows/cross-model-workflow/cross-model-workflow.md) (e.g., Claude Code) to review your plan before execution

■ **Workflows (8)**
- keep [`AGENTS.md`](https://developers.openai.com/codex/guides/agents-md) concise — 150 lines is a useful heuristic, but the actual limit is byte-based
- use [skills](https://developers.openai.com/codex/skills) with clear `name` and `description` frontmatter for auto-discovery
- use [`AGENTS.override.md`](https://developers.openai.com/codex/rules) for personal preferences without affecting the team
- use [profiles](https://developers.openai.com/codex/config-basic) to switch between project-defined safety levels — in this repo, `conservative` and `trusted` are examples
- use the built-in skill creator to scaffold new skills, and document one invocation style consistently across the repo
- start with [`on-request`](https://developers.openai.com/codex/cli/features) approval policy — only escalate to `never` when confident
- use [`--fork`](https://developers.openai.com/codex/cli/features) to explore alternatives without losing your session, [`--resume`](https://developers.openai.com/codex/cli/features) to pick up where you left off
- commit often — as soon as a task is completed, commit

■ **Workflows Advanced (4)**
- use [multi-agent](https://developers.openai.com/codex/multi-agent/) (`/experimental`) to spawn sub-agents for parallel fan-out work
- use [`codex exec`](https://developers.openai.com/codex/noninteractive) for headless/CI pipelines
- combine [sandbox modes](https://developers.openai.com/codex/cli/features) with [approval policies](https://developers.openai.com/codex/cli/features) — `workspace-write` + `on-request` is a good default
- [git worktrees](https://git-scm.com/docs/git-worktree) for parallel development

■ **Debugging (4)**
- always ask Codex to run the terminal (you want to see logs of) as a background task for better debugging
- use MCP ([Chrome DevTools](https://developer.chrome.com/blog/chrome-devtools-mcp), [Playwright](https://github.com/microsoft/playwright-mcp)) to let Codex see browser console logs on its own
- make it a habit to take screenshots and share with Codex whenever you are stuck with any issue
- use a different model for QA — e.g. [Claude Code](https://github.com/shanraisshan/claude-code-best-practice) for plan and implementation review

■ **Utilities (4)**
- [iTerm](https://iterm2.com/) terminal instead of IDE (crash issue)
- [Wispr Flow](https://wisprflow.ai) for voice prompting (10x productivity)
- [codex-cli-voice-hooks](https://github.com/shanraisshan/codex-cli-voice-hooks) for Codex feedback
- explore `config.toml` features like [profiles](https://developers.openai.com/codex/config-basic), [sandbox modes](https://developers.openai.com/codex/cli/features), and [MCP](https://developers.openai.com/codex/mcp) for a personalized experience

■ **Daily (2)**
- update Codex CLI daily and start your day by reading the [changelog](https://github.com/openai/codex/releases)
- follow [Tibo](https://x.com/thsottiaux), [Embiricos](https://x.com/embirico), [Fouad](https://x.com/fouadmatin), [Bolin](https://x.com/bolinfest), [Romain](https://x.com/romainhuet) on X

![Codex Team](!/tags/codex-team.svg)

- [Codex CLI — open-source local coding agent, first look (Fouad + Romain) | Apr 2025](https://www.youtube.com/watch?v=FUq9qRwrDrI) ● [Tweet](https://x.com/OpenAIDevs/status/1912556874211422572)
- [AMA with Codex team — CLI, sandbox, agents (Embiricos, Fouad, Tibo + team) | May 2025](https://www.reddit.com/r/ChatGPT/comments/1ko3tp1/ama_with_openai_codex_team/) ● [Reddit](https://www.reddit.com/r/ChatGPT/comments/1ko3tp1/ama_with_openai_codex_team/)
- [Skills in Codex — standardizing .agents/skills across agents (Embiricos) | Feb 2026](https://x.com/embirico/status/2002102889653924111) ● [Tweet](https://x.com/embirico/status/2002102889653924111)
- [Unrolling the Codex agent loop — how Codex works internally (Bolin) | Jan 2026](https://x.com/OpenAIDevs/status/2014794871962533970) ● [Tweet](https://x.com/OpenAIDevs/status/2014794871962533970)
- [How Codex is built — 90% self-built in Rust (Tibo, Pragmatic Engineer) | 17 Feb 2026](https://newsletter.pragmaticengineer.com/p/how-codex-is-built) ● [Post](https://newsletter.pragmaticengineer.com/p/how-codex-is-built)
- [Dogfood — Codex team uses Codex to build Codex (Tibo, Stack Overflow) | 24 Feb 2026](https://stackoverflow.blog/2026/02/24/dogfood-so-nutritious-it-s-building-the-future-of-sdlcs/) ● [Podcast](https://stackoverflow.blog/2026/02/24/dogfood-so-nutritious-it-s-building-the-future-of-sdlcs/)
- [Why humans are AI's biggest bottleneck — Codex product vision (Embiricos, Lenny's) | Feb 2026](https://www.lennysnewsletter.com/p/why-humans-are-ais-biggest-bottleneck) ● [Podcast](https://www.lennysnewsletter.com/p/why-humans-are-ais-biggest-bottleneck)
- [How Codex team uses their coding agent (Tibo + Andrew, Every) | 18 Feb 2026](https://every.to/podcast/transcript-how-openai-s-codex-team-uses-their-coding-agent) ● [Podcast](https://every.to/podcast/transcript-how-openai-s-codex-team-uses-their-coding-agent)

<a href="https://github.com/shanraisshan/claude-code-best-practice#billion-dollar-questions"><img src="!/tags/billion-dollar-questions.svg" alt="Billion-Dollar Questions"></a>

---

<a href="https://openai.com/form/codex-for-oss/"><img src="!/tags/codex-for-oss.svg" alt="Codex for Open Source" width="720"></a>

<table width="100%"><tr><td align="left"><a href="https://github.com/shanraisshan/claude-code-best-practice">← Back to Claude Code Best Practice</a></td><td align="right"><img src="!/claude-jumping.svg" alt="Claude jumping" width="60" height="54"></td></tr></table>
