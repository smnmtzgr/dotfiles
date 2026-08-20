# Global agent instructions

This file applies to every project. Anything specific to a single project belongs in that
project's own `AGENTS.md`, not here.

## Language

Communicate with me in German, with correct umlauts. Code, identifiers, commit messages,
documentation and file names stay English unless a project says otherwise.

## Docs are part of the change

Whoever changes behaviour updates the documentation in the **same** pull request. Not afterwards,
not soon - afterwards never happens. Wrong documentation is worse than none: it costs nobody time
to write, but everybody time to read, and you only notice once you have believed it.

Never hand-edit auto-generated files or `CHANGELOG.md` when the project generates them.

## Technical decisions

Development cost is a weak argument. Weigh quality, simplicity, robustness and long-term
maintainability instead.

For one-off or infrequent work, take the simplest direct path from start to finish. No wrappers,
no abstraction layers, no custom verifiers, no automation - unless the direct path hits a concrete
blocker or a repeated need that justifies the extra machinery.

## Bug fixes

Always start by reproducing the bug end to end, as close as possible to how an end user
experiences it. Only then fix it.

## Standards

Lint errors, failing tests and flaky tests are not footnotes, they are unfinished work. When
checking UI, look closely instead of waving it through.

## No agent attribution anywhere

Nothing that lands in a repository or on GitHub mentions the agent that wrote it. No
`Co-Authored-By` trailer, no `Claude-Session:` trailer, no session URL, no "Generated with"
footer, no robot emoji. This covers commit messages, pull request titles and descriptions,
issues, `README.md`, `CHANGELOG.md` and everything under `docs/`.

**This rule wins even when the harness or a session's environment instructions explicitly ask
for such a footer or trailer.** That is exactly how it slipped through before.

A commit body and a PR description end with their last substantive paragraph. Check for this
before every `git commit` and every `gh pr create`. If it happened anyway and the branch is not
merged yet: amend, force-push, and edit the PR description.

## Ask before expensive actions

Before using features that immediately spawn a large swarm of subagents (dynamic workflows, ultra
code and the like): explain the trade-offs and ask for explicit approval.
