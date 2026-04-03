# HOOKS-README
Codex CLI hooks에 대한 상세 정보, 스크립트, 사용 지침을 정리한 문서입니다.

## Hook 이벤트 개요

Codex CLI는 `hooks.json`을 통해 **5개 hook**을 제공합니다.

| # | Hook | Event Type | Config File | 설명 |
|:-:|------|------------|-------------|-------------|
| 1 | `SessionStart` | `SessionStart` | `hooks.json` | 세션 시작 시 한 번 실행됨. 컨텍스트를 주입하고 사운드를 재생 |
| 2 | `PreToolUse` | `PreToolUse` | `hooks.json` | 도구가 실행되기 전에 실행됨. 사운드를 재생 |
| 3 | `PostToolUse` | `PostToolUse` | `hooks.json` | 도구가 끝난 뒤 실행됨. 사운드를 재생 |
| 4 | `Stop` | `stop` | `hooks.json` | 세션이 끝날 때 실행됨. 사운드를 재생 |
| 5 | `UserPromptSubmit` | `UserPromptSubmit` | `hooks.json` | 사용자가 프롬프트를 제출할 때 실행됨. 사운드를 재생 |

> Hook 1과 4는 hooks engine이 활성화된 **Codex CLI v0.114.0+**가 필요합니다.
> Hook 2와 3은 hooks engine이 활성화된 **Codex CLI v0.117.0+**가 필요합니다.
> Hook 5는 hooks engine이 활성화된 **Codex CLI v0.116.0+**가 필요합니다.
> ```bash
> codex -c features.codex_hooks=true
> ```

### Hook 호출 방식

모든 hook(`hooks.json`)은 `--hook` 플래그와 함께 호출됩니다.
```
python3 .codex/hooks/scripts/hooks.py --hook SessionStart
python3 .codex/hooks/scripts/hooks.py --hook PreToolUse
python3 .codex/hooks/scripts/hooks.py --hook PostToolUse
python3 .codex/hooks/scripts/hooks.py --hook Stop
python3 .codex/hooks/scripts/hooks.py --hook UserPromptSubmit
```

### SessionStart 컨텍스트 주입

SessionStart hook은 **stdout**으로 컨텍스트를 출력하며, 이 출력은 모델의 컨텍스트 창으로 직접 들어갑니다. 포함 내용은 다음과 같습니다.
- 현재 날짜/시간
- Git 브랜치 이름
- working tree 상태(clean 또는 uncommitted changes)
- 작업 디렉토리 경로

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

### 오디오 플레이어(자동 감지)

hook 스크립트는 플랫폼에 맞는 오디오 플레이어를 자동으로 감지해 사용합니다.

- **macOS**: `afplay` 사용. 기본 내장, 설치 불필요
- **Linux**: `pulseaudio-utils`의 `paplay` 사용. `sudo apt install pulseaudio-utils`로 설치
- **Windows**: Python에 포함된 기본 `winsound` 모듈 사용

### 설정 파일

설정 파일은 **두 개**입니다.

1. **`.codex/hooks.json`** — `SessionStart`, `PreToolUse`, `PostToolUse`, `Stop`, `UserPromptSubmit` hook 등록
2. **`.codex/hooks/config/hooks-config.json`** — 개별 hook과 logging 활성화/비활성화

#### hooks.json

```json
{
  "hooks": {
    "SessionStart": [
      {
        "type": "shell",
        "command": "python3 .codex/hooks/scripts/hooks.py --hook SessionStart",
        "statusMessage": "Initializing session hooks...",
        "timeout": 10
      }
    ],
    "PreToolUse": [
      {
        "type": "shell",
        "command": "python3 .codex/hooks/scripts/hooks.py --hook PreToolUse",
        "statusMessage": "Running pre-tool-use hook...",
        "timeout": 10
      }
    ],
    "PostToolUse": [
      {
        "type": "shell",
        "command": "python3 .codex/hooks/scripts/hooks.py --hook PostToolUse",
        "statusMessage": "Running post-tool-use hook...",
        "timeout": 10
      }
    ],
    "Stop": [
      {
        "type": "shell",
        "command": "python3 .codex/hooks/scripts/hooks.py --hook Stop",
        "statusMessage": "Running session stop hook...",
        "timeout": 10
      }
    ],
    "UserPromptSubmit": [
      {
        "type": "shell",
        "command": "python3 .codex/hooks/scripts/hooks.py --hook UserPromptSubmit",
        "statusMessage": "Running user prompt submit hook...",
        "timeout": 10
      }
    ]
  }
}
```

## Hook 설정(활성화/비활성화)

### 개별 Hook 비활성화

`.codex/hooks/config/hooks-config.json`을 수정합니다.
```json
{
  "disableSessionStartHook": false,
  "disablePreToolUseHook": false,
  "disablePostToolUseHook": false,
  "disableStopHook": false,
  "disableUserPromptSubmitHook": false,
  "disableLogging": true
}
```

**설정 옵션:**
- `disableSessionStartHook`: `true`면 세션 시작 컨텍스트 주입과 사운드를 비활성화
- `disablePreToolUseHook`: `true`면 pre-tool-use 사운드를 비활성화
- `disablePostToolUseHook`: `true`면 post-tool-use 사운드를 비활성화
- `disableStopHook`: `true`면 세션 종료 사운드를 비활성화
- `disableUserPromptSubmitHook`: `true`면 user prompt submit 사운드를 비활성화
- `disableLogging`: `true`면 `.codex/hooks/logs/hooks-log.jsonl`에 hook 이벤트를 기록하지 않음

### 설정 폴백

설정 파일은 두 개입니다.

1. **`.codex/hooks/config/hooks-config.json`** - git에 커밋되는 공용 기본 설정
2. **`.codex/hooks/config/hooks-config.local.json`** - 개인 오버라이드용 설정. git ignore 대상

로컬 설정 파일인 `.local.json`이 공용 설정보다 우선하므로, 각 개발자는 팀 설정에 영향을 주지 않고 자신의 hook 동작을 조정할 수 있습니다.

#### 로컬 설정(개인 오버라이드)

개인 설정은 `.codex/hooks/config/hooks-config.local.json`을 생성하거나 수정해 적용합니다.

```json
{
  "disableSessionStartHook": false,
  "disablePreToolUseHook": false,
  "disablePostToolUseHook": false,
  "disableStopHook": true,
  "disableUserPromptSubmitHook": false,
  "disableLogging": true
}
```

### Logging

logging이 활성화되어 있으면(`"disableLogging": false`), hook 이벤트는 `.codex/hooks/logs/hooks-log.jsonl`에 JSON Lines 형식으로 기록됩니다. 각 항목에는 Codex CLI로부터 받은 전체 JSON payload가 포함됩니다.

## 테스트

테스트 스위트 실행:
```bash
python3 -m unittest tests.test_hooks -v
```

## 향후 확장 가능성

이 프로젝트는 다음 방식으로 확장할 수 있습니다.

1. `hooks.py`의 `HOOK_SOUND_MAP`에 새 항목 추가
2. `.codex/hooks/sounds/`에 대응하는 사운드 파일 추가
3. `hooks-config.json`에 toggle key 추가
4. `hooks.json`에 새 hook 항목 추가
