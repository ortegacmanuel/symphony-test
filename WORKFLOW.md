---
tracker:
  kind: github
  github_repo: ortegacmanuel/symphony-test
workspace:
  root: /home/covertech/kodo/elixir/symphony-test-workspaces
hooks:
  after_create: |
    GH_TOKEN=$(gh auth token)
    git clone "https://ortegacmanuel:${GH_TOKEN}@github.com/ortegacmanuel/symphony-test.git" .
  after_run: |
    set -e
    BRANCH="symphony/${SYMPHONY_ISSUE_ID:-unknown}"
    TITLE="${SYMPHONY_ISSUE_TITLE:-work for $BRANCH}"
    # Stage and commit any uncommitted changes
    git add -A
    git diff --cached --quiet || git commit -m "feat: ${TITLE}" || true
    # Create/reset feature branch at current HEAD (picks up agent's commits too)
    git branch -f "$BRANCH" HEAD 2>/dev/null || git checkout -B "$BRANCH"
    git checkout "$BRANCH"
    # Rebase on latest trunk
    git fetch origin master 2>/dev/null || git fetch origin main 2>/dev/null || true
    DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "master")
    git rebase "origin/$DEFAULT_BRANCH" 2>/dev/null || git rebase --abort 2>/dev/null || true
    # Push feature branch
    git push origin "$BRANCH" --force-with-lease
    # Create PR if one doesn't exist yet for this branch
    EXISTING_PR=$(gh pr list --repo ortegacmanuel/symphony-test --head "$BRANCH" --json number --jq '.[0].number' 2>/dev/null || echo "")
    if [ -z "$EXISTING_PR" ]; then
      gh pr create \
        --repo ortegacmanuel/symphony-test \
        --head "$BRANCH" \
        --base master \
        --title "feat: ${TITLE}" \
        --body "Automated PR from Symphony agent for issue #${SYMPHONY_ISSUE_ID}." \
        2>/dev/null || true
    fi
agent:
  kind: claude
  max_concurrent_agents: 1
  max_turns: 10
  auto_merge: false
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
