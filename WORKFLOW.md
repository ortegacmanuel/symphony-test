---
tracker:
  kind: github
  github_repo: ortegacmanuel/symphony-test
workspace:
  root: /home/covertech/kodo/elixir/symphony-test-workspaces
hooks:
  after_create: |
    git clone /home/covertech/kodo/elixir/symphony-test .
  after_run: |
    set -e
    BRANCH="symphony/${SYMPHONY_ISSUE_ID:-unknown}"
    git checkout -B "$BRANCH"
    if ! git diff --quiet HEAD || ! git diff --cached --quiet; then
      git add -A
      git commit -m "feat: ${SYMPHONY_ISSUE_TITLE:-work for $BRANCH}" --allow-empty || true
    fi
    git fetch origin master 2>/dev/null || git fetch origin main 2>/dev/null || true
    DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "master")
    git rebase "origin/$DEFAULT_BRANCH" || git rebase --abort
    git push origin "$BRANCH" --force-with-lease
agent:
  kind: claude
  max_concurrent_agents: 1
  max_turns: 10
claude:
  model: sonnet
  permission_mode: bypassPermissions
  max_budget_usd: 2.0
polling:
  interval_ms: 10000
---

You are working on issue `{{ issue.identifier }}`.

{% if attempt %}
Continuation context:

- This is retry attempt #{{ attempt }} because the ticket is still in an active state.
- Resume from the current workspace state instead of restarting from scratch.
{% endif %}

Issue context:
Identifier: {{ issue.identifier }}
Title: {{ issue.title }}
Current status: {{ issue.state }}
Labels: {{ issue.labels }}

Description:
{% if issue.description %}
{{ issue.description }}
{% else %}
No description provided.
{% endif %}

Instructions:

1. This is an unattended orchestration session. Never ask a human to perform follow-up actions.
2. Only stop early for a true blocker (missing required auth/permissions/secrets).
3. Work only in the provided repository copy. Do not touch any other path.
4. Write clean, working code.
5. Do NOT run `git push`. The after_run hook handles that.
6. Do NOT ask for confirmation. Just do the work.
