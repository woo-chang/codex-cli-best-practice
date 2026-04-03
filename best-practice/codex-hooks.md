# 모범 사례: Hooks

Hooks는 Codex agentic loop에 custom script를 주입하는 확장 프레임워크입니다. 이를 통해 로깅, 보안 스캔, 검증, 대화 요약, 문맥 인식 프롬프팅을 결정적으로 자동화할 수 있습니다.

<table width="100%">
<tr>
<td><a href="../">← Codex CLI 모범 사례로 돌아가기</a></td>
<td align="right"><img src="../!/codex-jumping.svg" alt="Codex" width="60" /></td>
</tr>
</table>

> **상태:** Experimental 단계이며 활발히 개발 중입니다. Windows 지원은 일시적으로 비활성화되어 있습니다.

## Feature Flag

Hooks를 쓰려면 `config.toml`에서 기능을 켜야 합니다.

```toml
[features]
codex_hooks = true
```

## 탐색 위치

Codex는 두 수준에서 `hooks.json` 파일을 찾습니다. 두 파일은 동시에 로드되며, 우선순위가 높은 계층이 낮은 계층을 대체하지는 않습니다.

| 우선순위 | 위치 | 범위 |
|----------|----------|-------|
| 1 | `.codex/hooks.json` | Project (팀 공유) |
| 2 | `~/.codex/hooks.json` | Global (개인) |

## Hook 이벤트

| 이벤트 | Matcher | 설명 |
|-------|---------|-------------|
| `SessionStart` | `startup \| resume` | 세션 초기화 시 실행 |
| `PreToolUse` | `Bash` | 도구 실행 전에 가로챔. 현재는 Bash만 지원 |
| `PostToolUse` | `Bash` | 도구 실행 결과를 사후 검토. 현재는 Bash만 지원 |
| `UserPromptSubmit` | 지원 안 됨 | 사용자가 프롬프트를 제출할 때 실행 |
| `Stop` | 지원 안 됨 | 한 턴이 끝날 때 실행되며 계속 진행할지 판단 |

## 설정 구조

Hooks는 **event → matcher group → hook handlers**의 세 단계로 구성됩니다.

```json
{
  "hooks": {
    "EventName": [
      {
        "matcher": "pattern|regex",
        "hooks": [
          {
            "type": "command",
            "command": "script_path",
            "statusMessage": "optional UI feedback",
            "timeout": 600
          }
        ]
      }
    ]
  }
}
```

### 주요 옵션

| 옵션 | 기본값 | 설명 |
|--------|---------|-------------|
| `timeout` / `timeoutSec` | 600s | 초 단위 실행 시간 제한 |
| `statusMessage` | — | 실행 중 표시할 선택적 UI 피드백 |
| `matcher` | 전체 매치 | 이벤트 발동을 필터링하는 regex (`"*"`, `""`, 또는 생략 시 전체) |

## 런타임 동작

- 여러 파일에서 매치된 hooks는 모두 실행됩니다
- 동일 이벤트의 여러 command hook은 **동시에** 실행됩니다
- 하나의 hook이 다른 hook의 실행을 막을 수는 없습니다
- 명령은 세션의 `cwd`를 작업 디렉토리로 사용합니다

## Hook 이벤트 상세

### SessionStart

세션 초기화 시 컨텍스트를 주입합니다.

**입력 필드:** `source`, `session_id`, `transcript_path`, `cwd`, `hook_event_name`, `model`

**출력:** stdout의 일반 텍스트는 developer context로 추가됩니다. JSON 출력은 다음 형식을 지원합니다.

```json
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "text added as context"
  }
}
```

### PreToolUse

도구 실행 전에 가로챕니다. 현재는 Bash만 지원합니다.

> **참고:** 모델은 스크립트를 직접 작성하고 실행해 이를 우회할 수 있습니다. 완전한 강제 경계라기보다 유용한 가드레일로 봐야 합니다.

**입력 필드:** `turn_id`, `tool_name`, `tool_use_id`, `tool_input.command`와 공통 필드

**실행 거부:**

```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "reason text"
  }
}
```

**대안:** stderr에 차단 이유를 출력하고 종료 코드 `2`를 반환합니다.

### PostToolUse

도구 실행 후 결과를 검토합니다. 현재는 Bash만 지원합니다. 이미 발생한 부작용을 되돌릴 수는 없지만, 도구 결과를 피드백으로 대체할 수는 있습니다.

**입력 필드:** `turn_id`, `tool_name`, `tool_use_id`, `tool_input.command`, `tool_response`와 공통 필드

**결과 차단 및 대체:**

```json
{
  "decision": "block",
  "reason": "feedback reason",
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": "context text"
  }
}
```

**대안:** stderr에 피드백 이유를 출력하고 종료 코드 `2`를 반환합니다.

### UserPromptSubmit

사용자가 프롬프트를 제출할 때 실행됩니다. Matcher는 지원되지 않습니다.

**Input fields:** `turn_id`, `prompt`, plus common fields

**제출 차단:**

```json
{
  "decision": "block",
  "reason": "reason text"
}
```

**컨텍스트 추가:**

```json
{
  "hookSpecificOutput": {
    "hookEventName": "UserPromptSubmit",
    "additionalContext": "context text"
  }
}
```

### Stop

한 턴이 끝날 때 실행되며 자동으로 계속 진행할지 결정합니다. Matcher는 지원되지 않습니다.

**Input fields:** `turn_id`, `stop_hook_active`, `last_assistant_message`, plus common fields

**자동 프롬프트로 계속 진행:**

```json
{
  "decision": "block",
  "reason": "continuation reason text"
}
```

> `decision: "block"`은 Codex에게 **거부가 아니라 계속 진행**하라고 지시합니다. reason은 다음 프롬프트 텍스트가 됩니다. 매치된 hook 중 하나라도 `continue: false`를 반환하면 그 값이 우선합니다.

## 공통 입력 필드

모든 command hook은 stdin으로 JSON을 받습니다.

| 필드 | 타입 | 설명 |
|-------|------|-------------|
| `session_id` | string | 세션/스레드 ID |
| `transcript_path` | string \| null | 세션 transcript 경로 |
| `cwd` | string | 작업 디렉토리 |
| `hook_event_name` | string | 현재 이벤트 이름 |
| `model` | string | 활성 모델 slug |
| `turn_id` | string | turn 범위 hook에서만 제공 |

## 공통 출력 필드

`SessionStart`, `UserPromptSubmit`, `Stop`은 다음 출력 필드를 지원합니다.

| 필드 | 타입 | 설명 |
|-------|------|-------------|
| `continue` | boolean | `false`면 hook이 중지된 것으로 표시 |
| `stopReason` | string | 중지 이유로 기록 |
| `systemMessage` | string | UI 경고로 표시 |
| `suppressOutput` | boolean | 파싱되지만 아직 구현되지 않음 |

출력 없이 `0`으로 종료하면 성공으로 간주되며 Codex는 정상적으로 계속 진행합니다.

## 경로 해석

repo-local hook은 Codex가 하위 디렉토리에서 시작될 때의 문제를 피하기 위해 git root 기준 경로를 권장합니다.

```
/usr/bin/python3 "$(git rev-parse --show-toplevel)/.codex/hooks/script.py"
```

## 전체 예시

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup|resume",
        "hooks": [
          {
            "type": "command",
            "command": "python3 ~/.codex/hooks/session_start.py",
            "statusMessage": "Loading session notes"
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "/usr/bin/python3 \"$(git rev-parse --show-toplevel)/.codex/hooks/pre_tool_use_policy.py\"",
            "statusMessage": "Checking Bash command"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "/usr/bin/python3 \"$(git rev-parse --show-toplevel)/.codex/hooks/post_tool_use_review.py\"",
            "statusMessage": "Reviewing Bash output"
          }
        ]
      }
    ],
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "/usr/bin/python3 \"$(git rev-parse --show-toplevel)/.codex/hooks/user_prompt_submit.py\""
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "/usr/bin/python3 \"$(git rev-parse --show-toplevel)/.codex/hooks/stop_continue.py\"",
            "timeout": 30
          }
        ]
      }
    ]
  }
}
```

## 안티패턴

| 안티패턴 | 해결책 |
|---|---|
| `PreToolUse`를 보안 경계로 믿기 | 우회 가능한 가드레일로만 취급 |
| hook 명령에서 상대 경로 사용 | 안정성을 위해 `$(git rev-parse --show-toplevel)` 사용 |
| `[features]` 플래그 누락 | `config.toml`에서 항상 `codex_hooks = true` 활성화 |
| 차단성 hook에 너무 긴 timeout 설정 | agent loop가 멈추지 않도록 짧게 유지 |
| hooks가 `PostToolUse` 부작용을 되돌릴 수 있다고 가정 | 되돌릴 수 없고 결과만 대체 가능 |
| JSON stdin 처리를 제대로 하지 않음 | 모든 hook은 stdin으로 JSON을 받으므로 정확히 파싱 |
