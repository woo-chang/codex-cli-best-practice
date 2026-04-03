# HOOKS-README
훅에 대한 상세 정보, 스크립트, 사용 지침을 정리한 문서입니다.

## Hook 이벤트 개요 - [공식 22개 Hook](https://code.claude.com/docs/en/hooks)
Claude Code는 워크플로우의 여러 시점에서 실행되는 다양한 hook 이벤트를 제공합니다.

| # | Hook | 설명 | 옵션 |
|:-:|------|-------------|---------|
| 1 | `PreToolUse` | 도구 호출 전에 실행됨. 호출을 차단할 수 있음 | `async`, `timeout: 5000`, `tool_use_id` |
| 2 | `PermissionRequest` | Claude Code가 사용자에게 권한을 요청할 때 실행됨 | `async`, `timeout: 5000`, `permission_suggestions` |
| 3 | `PostToolUse` | 도구 호출이 성공적으로 끝난 뒤 실행됨 | `async`, `timeout: 5000`, `tool_response`, `tool_use_id` |
| 4 | `PostToolUseFailure` | 도구 호출이 실패한 뒤 실행됨 | `async`, `timeout: 5000`, `error`, `is_interrupt`, `tool_use_id` |
| 5 | `UserPromptSubmit` | 사용자가 프롬프트를 제출한 뒤, Claude가 처리하기 전에 실행됨 | `async`, `timeout: 5000`, `prompt` |
| 6 | `Notification` | Claude Code가 알림을 보낼 때 실행됨 | `async`, `timeout: 5000`, `notification_type`, `message`, `title` |
| 7 | `Stop` | Claude Code의 응답이 끝날 때 실행됨 | `async`, `timeout: 5000`, `last_assistant_message`, `stop_hook_active` |
| 8 | `SubagentStart` | subagent 작업이 시작될 때 실행됨 | `async`, `timeout: 5000`, `agent_id`, `agent_type` |
| 9 | `SubagentStop` | subagent 작업이 끝날 때 실행됨 | `async`, `timeout: 5000`, `agent_id`, `agent_type`, `last_assistant_message`, `agent_transcript_path`, `stop_hook_active` |
| 10 | `PreCompact` | Claude Code가 compact 작업을 시작하기 직전에 실행됨 | `async`, `timeout: 5000`, `once`, `trigger`, `custom_instructions` |
| 11 | `PostCompact` | Claude Code가 compact 작업을 끝낸 뒤 실행됨 | `async`, `timeout: 5000`, `trigger`, `compact_summary` |
| 12 | `SessionStart` | Claude Code가 새 세션을 시작하거나 기존 세션을 재개할 때 실행됨 | `async`, `timeout: 5000`, `once`, `agent_type`, `model`, `source` |
| 13 | `SessionEnd` | Claude Code 세션이 종료될 때 실행됨 | `async`, `timeout: 5000`, `once`, `reason` |
| 14 | `Setup` | Claude Code가 프로젝트 초기화를 위해 `/setup` 명령을 실행할 때 동작함 | `async`, `timeout: 30000` |
| 15 | `TeammateIdle` | 팀 동료 agent가 idle 상태가 될 때 실행됨. experimental agent teams 필요 | `async`, `timeout: 5000`, `teammate_name`, `team_name` |
| 16 | `TaskCompleted` | 백그라운드 작업이 끝날 때 실행됨. experimental agent teams 필요 | `async`, `timeout: 5000`, `task_id`, `task_subject`, `task_description`, `teammate_name`, `team_name` |
| 17 | `ConfigChange` | 세션 중 설정 파일이 변경되면 실행됨 | `async`, `timeout: 5000`, `file_path`, `source` |
| 18 | `WorktreeCreate` | agent worktree isolation이 사용자 정의 VCS 설정용 worktree를 만들 때 실행됨 | `async`, `timeout: 5000`, `name` |
| 19 | `WorktreeRemove` | agent worktree isolation이 사용자 정의 VCS 정리용 worktree를 제거할 때 실행됨 | `async`, `timeout: 5000`, `worktree_path` |
| 20 | `InstructionsLoaded` | `CLAUDE.md` 또는 `.claude/rules/*.md` 파일이 컨텍스트에 로드될 때 실행됨 | `async`, `timeout: 5000`, `file_path`, `memory_type`, `load_reason`, `globs`, `trigger_file_path`, `parent_file_path` |
| 21 | `Elicitation` | MCP 서버가 도구 호출 중 사용자 입력을 요청할 때 실행됨 | `async`, `timeout: 5000`, `mcp_server_name`, `message`, `mode`, `url`, `elicitation_id`, `requested_schema` |
| 22 | `ElicitationResult` | 사용자가 MCP elicitation에 응답한 뒤, 결과가 서버로 전송되기 전에 실행됨 | `async`, `timeout: 5000`, `mcp_server_name`, `action`, `content`, `mode`, `elicitation_id` |

> **참고:** Hook 15-16인 `TeammateIdle`, `TaskCompleted`는 experimental agent teams 기능이 필요합니다. Claude Code 실행 시 `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`을 설정해야 활성화됩니다.

### 공식 문서에 없는 항목

아래 항목은 [Claude Code Changelog](https://github.com/anthropics/claude-code/blob/main/CHANGELOG.md)에는 있지만 [공식 Hooks Reference](https://code.claude.com/docs/en/hooks)에는 **나열되어 있지 않습니다**.

| 항목 | 추가 버전 | Changelog 참고 | 비고 |
|------|----------|-------------------|-------|
| `Setup` hook | [v2.1.10](https://github.com/anthropics/claude-code/blob/main/CHANGELOG.md#2110) | "Added new Setup hook event that can be triggered via `--init`, `--init-only`, or `--maintenance` CLI flags for repository setup and maintenance operations" | 공식 hooks reference 페이지에는 없음. 21개 hook만 나열되고 Setup은 제외됨 |
| Agent frontmatter hooks | [v2.1.0](https://github.com/anthropics/claude-code/blob/main/CHANGELOG.md#210) | "Added hooks support to agent frontmatter, allowing agents to define PreToolUse, PostToolUse, and Stop hooks scoped to the agent's lifecycle" | Changelog에는 3개 hook만 언급되지만, 테스트 결과 agent 세션에서는 실제로 **6개 hook**이 동작함: PreToolUse, PostToolUse, PermissionRequest, PostToolUseFailure, Stop, SubagentStop. 16개 전체가 지원되지는 않음 |

## 사전 요구 사항

hook을 사용하기 전에 시스템에 **Python 3**가 설치되어 있는지 확인합니다.

### 필요한 소프트웨어

#### 모든 플랫폼(Windows, macOS, Linux)
- **Python 3**: hook 스크립트 실행에 필요
- 설치 확인: `python3 --version`

**설치 방법:**
- **Windows**: [python.org](https://www.python.org/downloads/)에서 다운로드하거나 `winget install Python.Python.3`로 설치
- **macOS**: `brew install python3`로 설치. [Homebrew](https://brew.sh/) 필요
- **Linux**: `sudo apt install python3`(Ubuntu/Debian) 또는 `sudo yum install python3`(RHEL/CentOS)로 설치

### 오디오 플레이어(선택 사항, 자동 감지)

hook 스크립트는 플랫폼에 맞는 오디오 플레이어를 자동으로 감지해 사용합니다.

- **macOS**: `afplay` 사용. 기본 내장, 설치 불필요
- **Linux**: `pulseaudio-utils`의 `paplay` 사용. `sudo apt install pulseaudio-utils`로 설치
- **Windows**: Python에 포함된 기본 `winsound` 모듈 사용

### Hook 실행 방식

이 프로젝트의 hook은 `.claude/settings.json`에서 Python 3로 직접 실행되도록 설정됩니다.

```json
{
  "type": "command",
  "command": "python3 .claude/hooks/scripts/hooks.py"
}
```

## Hook 설정(활성화/비활성화)

hook은 전체 단위와 개별 단위 모두에서 쉽게 활성화하거나 비활성화할 수 있습니다.

### 모든 Hook 한 번에 비활성화

`.claude/settings.local.json`을 수정해 다음과 같이 설정합니다.
```json
{
  "disableAllHooks": true
}
```

**참고:** `.claude/settings.local.json` 파일은 git ignore 대상이므로, 각 사용자는 팀 공용 설정인 `.claude/settings.json`에 영향을 주지 않고 자신의 hook 설정을 조정할 수 있습니다.

> **Managed Settings:** 관리자가 managed policy settings를 통해 hook을 구성한 경우, user/project/local settings에 설정한 `disableAllHooks`로는 해당 managed hook을 비활성화할 수 없습니다. 이 동작은 v2.1.49에서 정리되었습니다.

### 개별 Hook 비활성화

세부 제어가 필요하면 hook 설정 파일을 수정해 특정 hook만 비활성화할 수 있습니다.

#### 설정 파일

개별 hook 관리를 위한 설정 파일은 두 개입니다.

1. **`.claude/hooks/config/hooks-config.json`** - git에 커밋되는 공용 기본 설정
2. **`.claude/hooks/config/hooks-config.local.json`** - 개인 오버라이드용 설정. git ignore 대상

로컬 설정 파일인 `.local.json`이 공용 설정보다 우선하며, 각 개발자는 팀 설정에 영향을 주지 않고 자신의 hook 동작을 조정할 수 있습니다.

#### 공용 설정

팀 공용 기본값은 `.claude/hooks/config/hooks-config.json`에서 설정합니다.

```json
{
  "disableLogging": false,
  "disablePreToolUseHook": false,
  "disablePermissionRequestHook": false,
  "disablePostToolUseHook": false,
  "disablePostToolUseFailureHook": false,
  "disableUserPromptSubmitHook": false,
  "disableNotificationHook": false,
  "disableStopHook": false,
  "disableSubagentStartHook": false,
  "disableSubagentStopHook": false,
  "disablePreCompactHook": false,
  "disablePostCompactHook": false,
  "disableElicitationHook": false,
  "disableElicitationResultHook": false,
  "disableSessionStartHook": false,
  "disableSessionEndHook": false,
  "disableSetupHook": false,
  "disableTeammateIdleHook": false,
  "disableTaskCompletedHook": false,
  "disableConfigChangeHook": false,
  "disableWorktreeCreateHook": false,
  "disableWorktreeRemoveHook": false,
  "disableInstructionsLoadedHook": false
}
```

**설정 옵션:**
- `disableLogging`: `true`로 설정하면 `.claude/hooks/logs/hooks-log.jsonl`에 hook 이벤트를 기록하지 않습니다. 로그 파일이 커지는 것을 막는 데 유용합니다

#### 로컬 설정(개인 오버라이드)

개인 설정은 `.claude/hooks/config/hooks-config.local.json`을 생성하거나 수정해 적용합니다.

```json
{
  "disableLogging": true,
  "disablePostToolUseHook": true,
  "disableSessionStartHook": true
}
```

위 예시에서는 logging이 비활성화되고, PostToolUse와 SessionStart hook만 로컬에서 오버라이드됩니다. 나머지 hook은 공용 설정값을 그대로 사용합니다.

**참고:** 개별 hook 토글은 hook 스크립트인 `.claude/hooks/scripts/hooks.py`에서 확인합니다. 로컬 설정이 공용 설정보다 우선하며, 어떤 hook이 비활성화되어 있으면 스크립트는 소리 재생이나 hook 로직 실행 없이 조용히 종료됩니다.

### Text to Speech(TTS)
사운드 생성에 사용한 사이트: https://elevenlabs.io/  
사용한 음성: Samara X

## Agent Frontmatter Hooks

Claude Code 2.1.0부터 agent frontmatter 파일에 정의하는 agent 전용 hook을 지원합니다. 이 hook은 agent 생명주기 안에서만 실행되며, 전체 hook 이벤트 중 일부만 지원합니다.

### 지원되는 Agent Hook

agent frontmatter hook은 **6개 hook**을 지원합니다. 16개 전체가 아닙니다. changelog에는 원래 3개만 언급됐지만, 테스트 결과 agent 세션에서 실제로 동작하는 hook은 6개입니다.
- `PreToolUse`: agent가 도구를 사용하기 전에 실행
- `PostToolUse`: agent의 도구 사용이 끝난 뒤 실행
- `PermissionRequest`: 도구가 사용자 권한을 요구할 때 실행
- `PostToolUseFailure`: 도구 호출이 실패한 뒤 실행
- `Stop`: agent가 종료될 때 실행
- `SubagentStop`: subagent가 끝날 때 실행

> **참고:** [v2.1.0 changelog](https://github.com/anthropics/claude-code/blob/main/CHANGELOG.md#210)에는 3개 hook만 언급되어 있습니다. *"Added hooks support to agent frontmatter, allowing agents to define PreToolUse, PostToolUse, and Stop hooks scoped to the agent's lifecycle"*. 하지만 `claude-code-voice-hook-agent` 테스트 결과, agent 세션에서는 실제로 6개 hook이 동작합니다. 나머지 10개 hook인 Notification, SessionStart, SessionEnd 등은 agent 컨텍스트에서 동작하지 않습니다.
>
> **Update (Feb 2026):** [공식 hooks reference](https://code.claude.com/docs/en/hooks)는 이제 skill/agent frontmatter hook에 대해 *"All hook events are supported"*라고 명시합니다. 이는 원래 테스트한 6개보다 지원 범위가 넓어졌을 가능성을 뜻합니다. agent 세션에서 추가 hook이 실제로 동작하는지는 재테스트를 권장합니다.

### Agent 사운드 폴더

agent 전용 사운드는 아래 별도 폴더에 저장됩니다.
- `.claude/hooks/sounds/agent_pretooluse/`
- `.claude/hooks/sounds/agent_posttooluse/`
- `.claude/hooks/sounds/agent_permissionrequest/`
- `.claude/hooks/sounds/agent_posttoolusefailure/`
- `.claude/hooks/sounds/agent_stop/`
- `.claude/hooks/sounds/agent_subagentstop/`

### Hook이 있는 Agent 만들기

1. `.claude/agents/`에 agent 정의 파일을 만듭니다.

```markdown
---
name: my-agent
description: Description of what this agent does
hooks:
  PreToolUse:
    - type: command
      command: python3 ${CLAUDE_PROJECT_DIR}/.claude/hooks/scripts/hooks.py --agent=my-agent
      timeout: 5000
      async: true
      statusMessage: PreToolUse
  PostToolUse:
    - type: command
      command: python3 ${CLAUDE_PROJECT_DIR}/.claude/hooks/scripts/hooks.py --agent=my-agent
      timeout: 5000
      async: true
      statusMessage: PostToolUse
  PermissionRequest:
    - type: command
      command: python3 ${CLAUDE_PROJECT_DIR}/.claude/hooks/scripts/hooks.py --agent=my-agent
      timeout: 5000
      async: true
      statusMessage: PermissionRequest
  PostToolUseFailure:
    - type: command
      command: python3 ${CLAUDE_PROJECT_DIR}/.claude/hooks/scripts/hooks.py --agent=my-agent
      timeout: 5000
      async: true
      statusMessage: PostToolUseFailure
  Stop:
    - type: command
      command: python3 ${CLAUDE_PROJECT_DIR}/.claude/hooks/scripts/hooks.py --agent=my-agent
      timeout: 5000
      async: true
      statusMessage: Stop
  SubagentStop:
    - type: command
      command: python3 ${CLAUDE_PROJECT_DIR}/.claude/hooks/scripts/hooks.py --agent=my-agent
      timeout: 5000
      async: true
      statusMessage: SubagentStop
---

여기에 agent 지침을 작성합니다...
```

2. agent 사운드 폴더에 사운드 파일을 추가합니다.
   - `agent_pretooluse/agent_pretooluse.wav`
   - `agent_posttooluse/agent_posttooluse.wav`
   - `agent_permissionrequest/agent_permissionrequest.wav`
   - `agent_posttoolusefailure/agent_posttoolusefailure.wav`
   - `agent_stop/agent_stop.wav`
   - `agent_subagentstop/agent_subagentstop.wav`

### 예시: Weather Fetcher Agent

hook이 설정된 전체 agent 예시는 `.claude/agents/claude-code-voice-hook-agent.md`를 참고합니다.

### Hook 옵션: `once: true`

`once: true` 옵션은 hook이 세션당 한 번만 실행되도록 보장합니다.

```json
{
  "type": "command",
  "command": "python3 .claude/hooks/scripts/hooks.py",
  "once": true
}
```

이 옵션은 `SessionStart`, `SessionEnd`, `PreCompact`처럼 한 번만 실행되어야 하는 hook에 유용합니다.

> **참고:** `once` 옵션은 **agent가 아니라 skills용**입니다. settings 기반 hook과 skill frontmatter에서는 동작하지만, agent frontmatter hook에서는 지원되지 않습니다.

### Hook 옵션: `async: true`

`"async": true`를 추가하면 Claude Code 실행을 막지 않고 hook을 백그라운드에서 실행할 수 있습니다.

```json
{
  "type": "command",
  "command": "python3 .claude/hooks/scripts/hooks.py",
  "timeout": 5000,
  "async": true
}
```

**async hook 사용 시점:**
- logging과 analytics
- notifications와 sound effects
- Claude Code를 느리게 만들면 안 되는 모든 side-effect

이 프로젝트는 음성 알림이 실행을 막을 필요가 없는 side-effect이므로 모든 hook에 `async: true`를 사용합니다. `timeout`은 async hook이 강제 종료되기 전까지 실행될 수 있는 최대 시간을 뜻합니다.

### Hook 옵션: `asyncRewake` (v2.1.72부터, 문서화되지 않음)

`asyncRewake` 옵션은 async 실행과 실패 시 모델을 다시 깨우는 기능을 결합합니다.

```json
{
  "type": "command",
  "command": "python3 .claude/hooks/scripts/hooks.py",
  "asyncRewake": true
}
```

`asyncRewake`가 `true`이면 hook은 백그라운드에서 실행됩니다. 즉 `async`를 내포합니다. 다만 종료 코드 2로 끝나면, 즉 차단성 오류가 발생하면 모델을 다시 깨워 오류를 처리하게 합니다. 평소에는 non-blocking이어야 하지만 치명적 실패는 드러내야 하는 hook에 유용합니다. 이 옵션은 settings schema의 `propertyNames`에서 확인됐고, 아직 공식 문서에는 없습니다.

### Hook 옵션: `statusMessage`

`statusMessage` 필드는 hook이 실행되는 동안 사용자에게 보여줄 커스텀 spinner 메시지를 지정합니다.

```json
{
  "type": "command",
  "command": "python3 .claude/hooks/scripts/hooks.py",
  "timeout": 5000,
  "async": true,
  "statusMessage": "PreToolUse"
}
```

이 프로젝트는 모든 hook에서 `statusMessage`를 hook 이벤트 이름으로 설정합니다. 따라서 spinner에 어떤 hook이 실행 중인지 잠시 표시됩니다. 예: `PreToolUse`, `SessionStart`, `Stop`. 이 효과는 동기 hook에서 더 잘 보이고, async hook에서는 백그라운드 실행 전에 잠깐만 표시됩니다.

## Hook 유형

Claude Code는 네 가지 hook handler 유형을 지원합니다. 이 프로젝트는 모든 사운드 재생에 `command` hook을 사용합니다.

### `type: "command"` (이 프로젝트에서 사용)

셸 명령을 실행합니다. stdin으로 JSON 입력을 받고, 종료 코드와 stdout으로 결과를 전달합니다.

```json
{
  "type": "command",
  "command": "python3 .claude/hooks/scripts/hooks.py",
  "timeout": 5000,
  "async": true
}
```

### `type: "prompt"`

Claude 모델에 single-turn 평가용 프롬프트를 보냅니다. 모델은 yes/no 결정을 JSON 형식인 `{"ok": true/false, "reason": "..."}`로 반환합니다. 결정적 규칙보다 판단이 필요한 경우에 유용합니다.

```json
{
  "type": "prompt",
  "prompt": "Check if all tasks are complete. $ARGUMENTS",
  "timeout": 30
}
```

**지원 이벤트:** PreToolUse, PostToolUse, PostToolUseFailure, PermissionRequest, UserPromptSubmit, Stop, SubagentStop, TaskCompleted. **Command 전용 이벤트(prompt/agent 타입 미지원):** ConfigChange, Elicitation, ElicitationResult, InstructionsLoaded, Notification, PostCompact, PreCompact, SessionEnd, SessionStart, Setup, SubagentStart, TeammateIdle, WorktreeCreate, WorktreeRemove.

### `type: "agent"`

multi-turn 도구 접근권한(Read, Grep, Glob)이 있는 subagent를 생성해 조건을 검증한 뒤 결정을 반환합니다. 응답 형식은 prompt hook과 동일합니다. 실제 파일이나 테스트 출력을 직접 확인해야 할 때 유용합니다.

```json
{
  "type": "agent",
  "prompt": "Verify that all unit tests pass. $ARGUMENTS",
  "timeout": 120
}
```

### `type: "http"` (v2.1.63부터)

셸 명령을 실행하는 대신 URL에 JSON을 POST하고 JSON 응답을 받습니다. 외부 서비스나 webhook과 연동할 때 유용합니다. sandboxing이 활성화된 경우 HTTP hook은 sandbox network proxy를 통해 라우팅됩니다.

```json
{
  "type": "http",
  "url": "http://localhost:8080/hooks/pre-tool-use",
  "timeout": 30,
  "headers": {
    "Authorization": "Bearer $MY_TOKEN"
  },
  "allowedEnvVars": ["MY_TOKEN"]
}
```

**미지원 이벤트:** ConfigChange, Elicitation, ElicitationResult, InstructionsLoaded, Notification, PostCompact, PreCompact, SessionEnd, SessionStart, Setup, SubagentStart, TeammateIdle, WorktreeCreate, WorktreeRemove. 즉 command 전용 이벤트입니다. Header에서는 `$VAR_NAME`으로 환경 변수 치환을 지원하지만, `allowedEnvVars`에 명시한 변수만 사용할 수 있습니다.

## 환경 변수

Claude Code는 hook 스크립트에 아래 환경 변수를 제공합니다.

| 변수 | 사용 가능 범위 | 설명 |
|----------|-------------|-------------|
| `$CLAUDE_PROJECT_DIR` | 모든 hook | 프로젝트 루트 디렉토리. 경로에 공백이 있으면 따옴표로 감싸야 함 |
| `$CLAUDE_ENV_FILE` | SessionStart 전용 | 이후 Bash 명령에서 사용할 환경 변수를 저장하는 파일 경로. 다른 hook의 변수를 보존하려면 append(`>>`) 사용 |
| `${CLAUDE_PLUGIN_ROOT}` | Plugin hook | plugin과 함께 배포된 스크립트용 plugin 루트 디렉토리 |
| `$CLAUDE_CODE_REMOTE` | 모든 hook | 원격 웹 환경에서는 `"true"`로 설정됨. 로컬 CLI에서는 설정되지 않음 |
| `${CLAUDE_SKILL_DIR}` | Skill hook | skill과 함께 배포된 스크립트용 skill 자체 디렉토리. v2.1.69부터 |
| `CLAUDE_CODE_SESSIONEND_HOOKS_TIMEOUT_MS` | SessionEnd hook | SessionEnd hook timeout을 밀리초 단위로 덮어씀. v2.1.74 이전에는 설정한 `timeout`과 관계없이 1.5초 후 강제 종료됐지만, 이제는 hook의 `timeout` 또는 이 환경 변수 값을 따름 |
| `session_id` (stdin JSON으로 전달) | 모든 hook | 현재 세션 ID. 환경 변수가 아니라 stdin JSON의 일부로 전달됨 |

### 공통 입력 필드(stdin JSON)

모든 hook은 위 표의 옵션 칼럼에 적힌 hook 전용 필드 외에도, 아래 공통 필드를 포함한 JSON 객체를 stdin으로 전달받습니다.

| 필드 | 타입 | 설명 |
|-------|------|-------------|
| `hook_event_name` | string | 실행된 hook 이벤트 이름. 예: `"PreToolUse"`, `"Stop"` |
| `session_id` | string | 현재 세션 식별자 |
| `transcript_path` | string | 대화 transcript JSON 파일 경로 |
| `cwd` | string | 현재 작업 디렉토리 |
| `permission_mode` | string | 현재 권한 모드. `default`, `plan`, `acceptEdits`, `dontAsk`, `bypassPermissions` 중 하나 |
| `agent_id` | string | subagent 고유 식별자. hook이 subagent 컨텍스트에서 실행될 때 존재. v2.1.69부터 |
| `agent_type` | string | agent 유형 이름. 예: `Bash`, `Explore`, `Plan`, 또는 custom name. `--agent <name>` 플래그를 쓰거나 subagent 내부일 때 존재. v2.1.69부터 |

> **참고:** hook 전용 필드인 `tool_name`(PreToolUse)이나 `last_assistant_message`(Stop) 같은 값은 위의 [Hook 이벤트 개요](#hook-이벤트-개요---공식-22개-hook) 표의 옵션 칼럼에 정리되어 있습니다.

## Hook 관리 명령

Claude Code는 hook 관리를 위한 내장 명령을 제공합니다.

- **`/hooks`** — 인터랙티브 hook 관리 UI. JSON 파일을 직접 수정하지 않고 hook을 조회, 추가, 삭제할 수 있습니다. hook은 `[User]`, `[Project]`, `[Local]`, `[Plugin]`처럼 출처별로 표시됩니다. 이 메뉴에서 `disableAllHooks`도 토글할 수 있습니다.
- **`claude hooks reload`** — 세션을 재시작하지 않고 hook 설정을 다시 불러옵니다. settings 파일을 수정한 뒤 유용합니다. v2.0.47부터 지원됩니다.

## MCP Tool Matcher

`PreToolUse`, `PostToolUse`, `PermissionRequest` hook에서는 `mcp__<server>__<tool>` 패턴으로 MCP(Model Context Protocol) 도구를 매칭할 수 있습니다.

```json
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "mcp__memory__.*",
      "hooks": [{ "type": "command", "command": "echo 'MCP memory tool used'" }]
    }]
  }
}
```

전체 정규식을 지원합니다. 예: `mcp__memory__.*`는 memory 서버의 모든 도구, `mcp__.*__write.*`는 모든 서버의 write 계열 도구를 의미합니다.

### Hook별 Matcher 참고

matcher는 어떤 이벤트가 hook을 실행시킬지 필터링합니다. 모든 hook이 matcher를 지원하는 것은 아니며, matcher를 지원하지 않는 hook은 항상 실행됩니다.

| Hook | Matcher 필드 | 가능한 값 | 예시 |
|------|--------------|-----------------|---------|
| `PreToolUse` | `tool_name` | 임의의 도구 이름. `Bash`, `Read`, `Edit`, `Write`, `Glob`, `Grep`, `Agent`, `WebFetch`, `WebSearch`, `mcp__*` 등 | `"matcher": "Bash"` |
| `PermissionRequest` | `tool_name` | PreToolUse와 동일 | `"matcher": "mcp__memory__.*"` |
| `PostToolUse` | `tool_name` | PreToolUse와 동일 | `"matcher": "Write"` |
| `PostToolUseFailure` | `tool_name` | PreToolUse와 동일 | `"matcher": "Bash"` |
| `Notification` | `notification_type` | `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog` | `"matcher": "permission_prompt"` |
| `SubagentStart` | `agent_type` | `Bash`, `Explore`, `Plan`, 또는 custom agent name | `"matcher": "Bash"` |
| `SubagentStop` | `agent_type` | `Bash`, `Explore`, `Plan`, 또는 custom agent name | `"matcher": "Bash"` |
| `SessionStart` | `source` | `startup`, `resume`, `clear`, `compact` | `"matcher": "startup"` |
| `SessionEnd` | `reason` | `clear`, `logout`, `prompt_input_exit`, `bypass_permissions_disabled`, `other` | `"matcher": "logout"` |
| `PreCompact` | `trigger` | `manual`, `auto` | `"matcher": "auto"` |
| `PostCompact` | `trigger` | `manual`, `auto` | `"matcher": "manual"` |
| `Elicitation` | `mcp_server_name` | MCP 서버 이름 | `"matcher": "my-mcp-server"` |
| `ElicitationResult` | `mcp_server_name` | MCP 서버 이름 | `"matcher": "my-mcp-server"` |
| `ConfigChange` | `source` | `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills` | `"matcher": "project_settings"` |
| `UserPromptSubmit` | — | matcher 미지원 | 항상 실행 |
| `Stop` | — | matcher 미지원 | 항상 실행 |
| `TeammateIdle` | — | matcher 미지원 | 항상 실행 |
| `TaskCompleted` | — | matcher 미지원 | 항상 실행 |
| `WorktreeCreate` | — | matcher 미지원 | 항상 실행 |
| `WorktreeRemove` | — | matcher 미지원 | 항상 실행 |
| `InstructionsLoaded` | — | matcher 미지원 | 항상 실행 |
| `Setup` | — | matcher 미지원 | 항상 실행 |

## 알려진 이슈와 우회 방법

### Agent Stop Hook 버그(SubagentStop vs Stop)

**Bug Report:** [GitHub Issue #19220](https://github.com/anthropics/claude-code/issues/19220)

**문제:** agent frontmatter에 `Stop` hook을 정의해도, hook 스크립트에 전달되는 `hook_event_name`은 `"Stop"`이 아니라 `"SubagentStop"`입니다. 이는 공식 문서와 어긋나며, 설정한 이름이 그대로 전달되는 다른 agent hook인 `PreToolUse`, `PostToolUse`와도 일관되지 않습니다.

| Hook | 정의 값 | 전달 값 | 상태 |
|------|------------|-------------|--------|
| PreToolUse | `PreToolUse:` | `"PreToolUse"` | ✅ 정상 |
| PostToolUse | `PostToolUse:` | `"PostToolUse"` | ✅ 정상 |
| Stop | `Stop:` | `"SubagentStop"` | ❌ 비일관적 |

**상태:** [공식 hooks reference](https://code.claude.com/docs/en/hooks#hooks-in-skills-and-agents)는 현재 이를 정상 동작으로 문서화하고 있습니다. *"For subagents, Stop hooks are automatically converted to SubagentStop since that is the event that fires when a subagent completes."* 이 프로젝트는 `hooks.py`의 `AGENT_HOOK_SOUND_MAP`에서 별도의 `SubagentStop` 항목을 두고 `agent_subagentstop` 사운드 폴더에 매핑해 처리합니다.

### PreToolUse Decision Control deprecated

`PreToolUse` hook은 과거에 top-level `decision`, `reason` 필드로 도구 호출을 차단했습니다. 이 방식은 이제 **deprecated**입니다. 대신 `hookSpecificOutput.permissionDecision`, `hookSpecificOutput.permissionDecisionReason`을 사용합니다.

| Deprecated | Current |
|-----------|---------|
| `"decision": "approve"` | `"hookSpecificOutput": { "permissionDecision": "allow" }` |
| `"decision": "block"` | `"hookSpecificOutput": { "permissionDecision": "deny" }` |

이 프로젝트는 `hooks.py`에서 async 사운드 재생만 사용하고 decision control은 사용하지 않으므로 직접적인 영향은 없습니다.

## Decision Control 패턴

hook마다 실행 차단 또는 제어를 위한 출력 스키마가 다릅니다. 이 프로젝트는 decision control을 사용하지 않고 모든 hook이 async 사운드 재생만 수행하지만, 참고용으로 정리합니다.

| Hook | 제어 방식 | 값 |
|---------|---------------|--------|
| PreToolUse | `hookSpecificOutput.permissionDecision` | `allow`, `deny`, `ask` |
| PreToolUse | `hookSpecificOutput.autoAllow` | `true` — auto-approve future uses of this tool (since v2.0.76) |
| PermissionRequest | `hookSpecificOutput.decision.behavior` | `allow`, `deny` |
| PostToolUse, PostToolUseFailure, Stop, SubagentStop, ConfigChange | top-level `decision` | `block` |
| TeammateIdle, TaskCompleted | `continue` + exit code 2 | `{"continue": false, "stopReason": "..."}` — JSON decision control added in v2.1.70 |
| UserPromptSubmit | Can modify `prompt` field | Returns modified prompt via stdout |
| WorktreeCreate | Non-zero exit + stdout path | Non-zero exit fails creation; stdout provides worktree path |
| Elicitation | `hookSpecificOutput.action` + `hookSpecificOutput.content` | `accept`, `decline`, `cancel` — control MCP elicitation response |
| ElicitationResult | `hookSpecificOutput.action` + `hookSpecificOutput.content` | `accept`, `decline`, `cancel` — override user response before sending to server |

### 공통 JSON 출력 필드

모든 hook은 stdout JSON으로 아래 필드를 반환할 수 있습니다.

| 필드 | 타입 | 설명 |
|-------|------|-------------|
| `continue` | bool | `false`면 Claude를 완전히 중단 |
| `stopReason` | string | `continue`가 `false`일 때 보여줄 메시지 |
| `suppressOutput` | bool | verbose mode에서 stdout 숨김 |
| `systemMessage` | string | 사용자에게 보여줄 경고 메시지 |
| `additionalContext` | string | Claude 대화에 추가할 컨텍스트 |

## Hook 중복 제거와 외부 변경

- **Hook deduplication:** 여러 settings 위치에 동일한 hook handler가 정의돼 있으면 병렬로 한 번만 실행되어 중복 실행을 막습니다.
- **External change detection:** 활성 세션 중 다른 프로세스가 settings 파일을 수정하는 등 외부에서 hook이 변경되면 Claude Code가 경고합니다.
