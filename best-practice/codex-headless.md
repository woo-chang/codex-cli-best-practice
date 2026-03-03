# Best Practice: Headless Execution (codex exec)

`codex exec` runs Codex CLI in non-interactive mode, designed for CI/CD pipelines, scripts, and automated workflows. It accepts a prompt, executes the task, and exits with structured output.

## Basic Usage

```bash
# Simple task execution
codex exec "describe the architecture of this project"

# With a specific model
codex exec --model o4-mini "list all TODO comments in the codebase"

# With a profile
codex --profile ci exec "run the test suite and report failures"
```

## CI/CD Integration

### GitHub Actions

```yaml
- name: Run Codex Analysis
  run: |
    codex --profile ci exec "review the changed files and report issues"
  env:
    OPENAI_API_KEY: ${{ secrets.OPENAI_API_KEY }}
```

### GitLab CI

```yaml
codex-review:
  script:
    - codex --profile ci exec "analyze the MR diff for potential issues"
  variables:
    OPENAI_API_KEY: $OPENAI_API_KEY
```

## Recommended CI Configuration

Always use the strictest settings for CI:

```toml
[profile.ci]
model = "o4-mini"
approval_policy = "full-auto"

[profile.ci.sandbox]
mode = "full"

[profile.ci.permissions]
auto_approve = [
  "read",
  "glob",
  "grep",
  "bash(git:*)",
  "bash(npm test:*)"
]
```

**Key principles for CI**:
1. **Full sandbox**: CI tasks should never write to the real filesystem or access the network
2. **Full-auto approval**: No human to approve in CI — but sandbox provides safety
3. **Minimal allow-list**: Only approve commands the task actually needs
4. **Fast model**: Use `o4-mini` for speed and cost efficiency

## Structured Output

`codex exec` can return structured output for downstream processing:

```bash
# Plain text output (default)
codex exec "summarize recent changes"

# Pipe to other tools
codex exec "list files that need updating" | xargs -I{} echo "TODO: {}"
```

## Common CI Workflows

### PR Review Bot
```bash
codex --profile ci exec \
  "Review the diff from 'git diff origin/main...HEAD'. \
   Report: critical issues, warnings, and suggestions. \
   Output as markdown."
```

### Test Analysis
```bash
codex --profile ci exec \
  "Run 'npm test' and if any tests fail, analyze the failures \
   and suggest fixes. Output as a JSON array of {test, issue, fix}."
```

### Documentation Check
```bash
codex --profile ci exec \
  "Check if all public functions in src/ have JSDoc comments. \
   List any undocumented functions."
```

### Changelog Generation
```bash
codex --profile ci exec \
  "Generate a changelog entry for the commits since the last tag. \
   Follow the Keep a Changelog format."
```

## Environment Variables

| Variable | Purpose |
|---|---|
| `OPENAI_API_KEY` | Authentication (required) |
| `CODEX_PROFILE` | Default profile (alternative to `--profile`) |
| `CODEX_MODEL` | Default model (alternative to `--model`) |

## Error Handling

```bash
# Check exit code
if codex --profile ci exec "run tests"; then
  echo "All checks passed"
else
  echo "Codex reported issues"
  exit 1
fi
```

## Cost Management

- Use `o4-mini` for CI tasks — it is fast and cost-effective
- Set `maxTurns` in agent definitions to cap execution length
- Monitor usage via `codex usage` command
- Consider caching: skip Codex runs when no relevant files changed

## Anti-Patterns

- **Using `sandbox.mode = "off"` in CI**: Unnecessary risk in automated pipelines
- **Using expensive models (`o3`) for routine CI checks**: Wastes budget
- **No `full-auto` in CI**: Without it, the pipeline hangs waiting for approval
- **Overly broad prompts**: "Fix everything" — be specific about what the task should do
- **Not checking exit codes**: Always handle failure cases in your pipeline
