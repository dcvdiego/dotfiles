#!/bin/sh
set -eu

# Install skills.sh-managed skills (github.com/vercel-labs/skills). Idempotent;
# each apply refreshes to latest (no pin), mirroring the herdr plugin postinstall.
# Everything with `Source: local` in `npx skills list -g` — the Datadog suite,
# Fonoa skills (lkup-*, db-tunnel, fonoa-ops-triage), peon-ping-*, pieces-mcp,
# continue-from-*, ai-commit-metadata — is machine-local work and intentionally
# NOT reproduced here. `npx -y skills remove <name> -a <agent>` toggles per agent.
export DISABLE_TELEMETRY=1

echo "skills: mattpocock/skills (23)"
if ! npx -y skills add mattpocock/skills -g -y \
    --skill ask-matt --skill claude-handoff --skill domain-modeling \
    --skill git-guardrails-claude-code --skill grill-me --skill grill-with-docs \
    --skill grilling --skill handoff --skill implement \
    --skill improve-codebase-architecture --skill pr --skill research \
    --skill resolving-merge-conflicts --skill setup-matt-pocock-skills \
    --skill tdd --skill teach --skill to-questionnaire --skill to-spec \
    --skill to-tickets --skill wait-what --skill wayfinder --skill wizard \
    --skill writing-for-agents >/dev/null 2>&1; then
    echo "  WARN: failed to install skills mattpocock/skills" >&2
fi

echo "skills: herdrdev/herdr"
if ! npx -y skills add herdrdev/herdr -g -y --skill herdr >/dev/null 2>&1; then
    echo "  WARN: failed to install skills herdrdev/herdr" >&2
fi

echo "skills: vercel-labs/skills"
if ! npx -y skills add vercel-labs/skills -g -y --skill find-skills >/dev/null 2>&1; then
    echo "  WARN: failed to install skills vercel-labs/skills" >&2
fi

echo "skills installed."
