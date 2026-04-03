# 오케스트레이션 워크플로우

이 문서는 날씨 데이터 수집과 SVG 렌더링 시스템을 예시로 사용해 **Agent → Skill** 오케스트레이션 워크플로우를 설명합니다.

<table width="100%">
<tr>
<td><a href="../">← Codex CLI 모범 사례로 돌아가기</a></td>
<td align="right"><img src="../!/codex-jumping.svg" alt="Codex" width="60" /></td>
</tr>
</table>

## 시스템 개요

날씨 시스템은 하나의 오케스트레이션 워크플로우 안에서 두 가지 컴포넌트 패턴을 보여줍니다.
- **Agent**: `weather-agent`가 인라인 `developer_instructions`를 사용해 Open-Meteo에서 기온을 가져옵니다
- **Skill** (독립형): `weather-svg-creator`는 에이전트에 의해 호출되어 시각적 출력을 만듭니다

이는 다음과 같은 **Agent → Skill** 아키텍처 패턴을 보여줍니다.
- 에이전트가 데이터를 가져오고 워크플로우를 오케스트레이션합니다
- skill은 독립적으로 시각적 출력을 생성합니다

## ![How to Use](../!/tags/how-to-use.svg)

```bash
codex
> Fetch the current weather for Dubai in Celsius and create the SVG weather card output using the repo.
```

단위를 바꾸려면 프롬프트에 "in Fahrenheit"를 명시하면 됩니다. 선호가 지정되지 않으면 agent는 기본적으로 Celsius를 사용합니다.

출력 파일:
- `orchestration-workflow/weather.svg` — SVG weather card
- `orchestration-workflow/output.md` — Markdown summary

> **참고:** 이 워크플로우는 [Claude Code Best Practice](https://github.com/shanraisshan/claude-code-best-practice)의 orchestration workflow와 100% 일치하지는 않습니다. Codex CLI는 아직 [custom commands](https://developers.openai.com/codex/cli/slash-commands)(`.codex/commands/`)나 턴 중간 사용자 상호작용을 위한 안정적인 ask-user 도구를 지원하지 않습니다. [Codex App Server](https://developers.openai.com/codex) 문서에는 실험적인 `tool/requestUserInput`가 있고, codex-cli 0.115.0에는 개발 중인 feature flag 뒤에 내부 `request_user_input` 기능이 있지만, 둘 다 일반적인 CLI 사용에서는 아직 공개되어 있지 않습니다. 따라서 Codex 패턴은 **Command → Agent → Skill**이 아니라 **Agent → Skill**이며, 사용자가 agent에게 질문받는 대신 프롬프트에서 직접 선호값(예: Celsius/Fahrenheit)을 지정해야 합니다.

## 컴포넌트 요약

| 컴포넌트 | 역할 | 예시 |
|-----------|------|---------|
| **Agent** | 진입점, 데이터 수집, skill 호출 | [`weather-agent`](../.codex/agents/weather-agent.toml) |
| **Skill** | 독립적으로 출력 생성 | [`weather-svg-creator`](../.agents/skills/weather-svg-creator/SKILL.md) |

## 흐름도

<p align="center">
  <img src="../!/orchestration-workflow-diagram.svg" alt="오케스트레이션 워크플로우: Agent → Skill → Output" width="100%">
</p>

```
╔══════════════════════════════════════════════════════════════════╗
║              ORCHESTRATION WORKFLOW                              ║
║                    Agent  →  Skill                               ║
╚══════════════════════════════════════════════════════════════════╝

                         ┌───────────────────┐
                         │  User Prompt      │
                         │  (specifies C°/F°)│
                         └─────────┬─────────┘
                                   │
                         Step 1 — Agent
                                   │
                                   ▼
         ┌─────────────────────────────────────────────────────┐
         │  weather-agent — Agent ● developer_instructions     │
         └─────────────────────────┬───────────────────────────┘
                                   │
                          Returns: temp + unit
                                   │
                         Step 2 — Skill
                                   │
                                   ▼
         ┌─────────────────────────────────────────────────────┐
         │  weather-svg-creator — Skill ● SVG card + output    │
         └─────────────────────────┬───────────────────────────┘
                                   │
                          ┌────────┴────────┐
                          │                 │
                          ▼                 ▼
                   ┌────────────┐    ┌────────────┐
                   │weather.svg │    │ output.md  │
                   └────────────┘    └────────────┘
```

## 컴포넌트 상세

### 1. Agent

#### `weather-agent` (Agent)
- **Location**: `.codex/agents/weather-agent.toml`
- **Purpose**: 진입점. 기온을 가져오고 skill을 호출합니다
- **Model**: o4-mini
- **Registration**: `[agents.weather-agent]` in `.codex/config.toml`

에이전트의 `developer_instructions`에는 전체 워크플로우가 들어 있습니다. curl로 Open-Meteo API에서 데이터를 가져오고(호출자가 지정한 단위를 사용하며 기본값은 Celsius), 그 데이터를 사용해 `/weather-svg-creator`를 호출합니다.

### 2. Skill

#### `weather-svg-creator` (Skill)
- **Location**: `.agents/skills/weather-svg-creator/SKILL.md`
- **Purpose**: 시각적인 SVG 날씨 카드를 만들고 출력 파일을 기록합니다
- **Invocation**: agent가 skill 호출로 실행
- **Outputs**:
  - `orchestration-workflow/weather.svg` — SVG weather card
  - `orchestration-workflow/output.md` — Weather summary

## 실행 흐름

1. **User Prompt**: 사용자가 도시와 단위 선호를 포함해 Codex에 프롬프트를 보냅니다. 예: "Dubai in Celsius"
2. **Agent Start**: Codex가 작업에 맞춰 `weather-agent`를 자동 선택합니다
3. **Data Fetching**: agent가 curl로 Open-Meteo API에서 Dubai의 기온을 가져옵니다
4. **Skill Invocation**: agent가 `/weather-svg-creator` skill을 호출합니다
   - skill이 `orchestration-workflow/weather.svg`에 SVG 날씨 카드를 생성합니다
   - skill이 `orchestration-workflow/output.md`에 요약을 기록합니다
5. **Result Display**: 사용자에게 기온, SVG 위치, 출력 파일이 포함된 요약을 보여줍니다

## 실행 예시

```
Input: Fetch the current weather for Dubai in Celsius and create the SVG weather card
├─ Step 1: Agent fetches from Open-Meteo API
│  └─ Returns: temperature=29, unit=Celsius, city=Dubai
├─ Step 2: Agent invokes skill → /weather-svg-creator
│  ├─ Creates: orchestration-workflow/weather.svg
│  └─ Writes: orchestration-workflow/output.md
└─ Output:
   ├─ Unit: Celsius
   ├─ Temperature: 29°C
   ├─ SVG: orchestration-workflow/weather.svg
   └─ Summary: orchestration-workflow/output.md
```

## 핵심 설계 원칙

1. **Agent as Entry Point**: 별도 orchestrator 없이 agent가 데이터 수집과 skill 호출을 담당합니다
2. **Skill for Rendering**: SVG creator는 agent 컨텍스트의 데이터를 받아 독립적으로 실행됩니다
3. **Inlined Instructions**: Codex CLI subagent는 preloaded skill을 지원하지 않으므로, agent의 `developer_instructions`에 수집 로직을 직접 둡니다
4. **Clean Separation**: Fetch(agent) → Render(skill)로 분리해 각 컴포넌트가 단일 책임을 가집니다
5. **Idempotent Output**: 워크플로우를 다시 실행하면 이전 출력이 깔끔하게 덮어써집니다

## 아키텍처 패턴

### Agent (Developer Instructions)

```toml
# In agent definition (.codex/agents/weather-agent.toml)
name = "weather-agent"
description = "Fetches temperature from Open-Meteo, invokes skill."
developer_instructions = """
Step 1: Fetch from Open-Meteo API (use caller's unit preference, default Celsius)
Step 2: Invoke /weather-svg-creator skill
"""
```

- **Self-contained**: agent는 데이터 수집과 skill 호출에 필요한 모든 것을 자체적으로 가집니다
- **No preloaded skills**: Codex CLI subagent는 `skills:` preloading 패턴을 지원하지 않습니다
- **Prompt-driven skill invocation**: agent는 자연어 지시를 통해 Codex에게 `/weather-svg-creator`를 호출하라고 전달합니다

### Skill (Direct Invocation)

```yaml
# In skill definition (.agents/skills/weather-svg-creator/SKILL.md)
---
name: weather-svg-creator
description: Creates an SVG weather card...
---
```

- **Invoked by agent**: agent 지시가 Codex에게 `/weather-svg-creator` 호출을 지시합니다
- **Independent execution**: 대화 컨텍스트 안에서 기온 데이터가 이미 준비된 상태로 실행됩니다
- **Receives data from context**: 대화에 이미 존재하는 기온 데이터를 사용합니다

## Claude Code와 비교

| 측면 | Claude Code | Codex CLI |
|---|---|---|
| **Entry point** | Custom Command (`.claude/commands/`) | Agent (`.codex/agents/`) |
| **User interaction** | Command가 `AskUserQuestion` 도구로 질문 | 사용자가 프롬프트에 직접 지정. 중간 질문 없음 |
| **Data fetching** | preloaded skill이 있는 agent | 인라인 `developer_instructions`를 가진 agent |
| **Skill invocation** | `Skill()` tool call (deterministic) | `/skill-name` 지시 (prompt-driven) |
| **Agent knowledge** | `skills:` 필드로 preloaded skills 사용 | `developer_instructions`에 직접 포함 |
| **Pattern name** | Command → Agent → Skill | Agent → Skill |
| **Orchestration style** | Imperative (명시적 tool call) | Declarative (지시 기반) |
