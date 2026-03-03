# Report: Headless CI/CD with Codex CLI

## Overview

`codex exec` is the headless execution mode of Codex CLI, purpose-built for non-interactive environments like CI/CD pipelines, cron jobs, and automated scripts. Unlike the interactive mode, it runs a single prompt to completion and exits.

## How codex exec Works

```bash
codex exec [options] "prompt"
```

1. Loads configuration (config.toml + profile + CLI flags)
2. Reads AGENTS.md from the working directory
3. Executes the prompt with the specified approval policy
4. Outputs results to stdout
5. Exits with status code 0 (success) or non-zero (failure)

## CI Platform Integration

### GitHub Actions

```yaml
name: Codex Review
on: [pull_request]

jobs:
  review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install Codex
        run: npm install -g @openai/codex
      - name: Run Review
        run: |
          codex --profile ci exec \
            "Review the PR diff and output a markdown summary of issues found."
        env:
          OPENAI_API_KEY: ${{ secrets.OPENAI_API_KEY }}
```

### GitLab CI

```yaml
codex-analysis:
  image: node:20
  before_script:
    - npm install -g @openai/codex
  script:
    - codex --profile ci exec "analyze code quality of changed files"
  variables:
    OPENAI_API_KEY: $OPENAI_API_KEY
```

### Jenkins

```groovy
pipeline {
  agent any
  environment {
    OPENAI_API_KEY = credentials('openai-api-key')
  }
  stages {
    stage('Codex Analysis') {
      steps {
        sh 'codex --profile ci exec "run tests and report results"'
      }
    }
  }
}
```

## Configuration for CI

The recommended CI profile:

```toml
[profile.ci]
model = "o4-mini"
approval_policy = "full-auto"

[profile.ci.sandbox]
mode = "full"

[profile.ci.permissions]
auto_approve = [
  "read", "glob", "grep",
  "bash(git:*)",
  "bash(npm test:*)",
  "bash(npm run:*)"
]
```

**Rationale**:
- `full-auto`: No human available to approve in CI
- `full` sandbox: Maximum isolation protects the CI environment
- `o4-mini`: Fast and cost-effective for automated tasks
- Scoped allow-list: Only necessary commands auto-approved

## Common CI Workflows

### Automated PR Review
Analyze pull request diffs and post feedback:
```bash
DIFF=$(git diff origin/main...HEAD)
codex --profile ci exec "Review this diff and list issues: $DIFF"
```

### Test Failure Analysis
When tests fail, use Codex to diagnose:
```bash
npm test 2>&1 | tee test-output.txt
if [ $? -ne 0 ]; then
  codex --profile ci exec "Analyze test-output.txt and suggest fixes"
fi
```

### Documentation Validation
Check that code and docs are in sync:
```bash
codex --profile ci exec \
  "Verify that README.md accurately describes the current API in src/api/"
```

### Security Scanning
Lightweight security review:
```bash
codex --profile ci exec \
  "Scan src/ for common security vulnerabilities (SQL injection, XSS, etc.)"
```

## Cost and Performance

| Factor | Recommendation |
|---|---|
| Model | `o4-mini` for routine tasks; `o3` for complex analysis |
| Max turns | Set `maxTurns` in agent config to cap execution length |
| Caching | Skip Codex steps when no relevant files changed |
| Parallelism | Run independent Codex tasks in parallel CI jobs |

### Cost Estimation
A typical CI run with `o4-mini`:
- Simple review (~5 files): ~2K-5K tokens
- Full test analysis: ~5K-15K tokens
- Complex codebase scan: ~15K-50K tokens

## Exit Codes

| Code | Meaning |
|---|---|
| 0 | Task completed successfully |
| 1 | Task completed with reported issues |
| 2 | Configuration error |
| Non-zero | Execution failure |

## Limitations

- No interactive approval: everything must be pre-configured
- Long tasks may time out in CI environments (set appropriate timeouts)
- Network access depends on sandbox mode — `full` sandbox blocks all network
- Output is plain text; structured output requires prompt engineering
