# Alias

Alias is an iOS 17.5 SwiftUI party game in which teams take turns explaining
words against a timer and race to a target score.

## Repository map

- `Alias/Alias.xcodeproj` — Xcode project and shared `Alias` scheme.
- `Alias/Alias/` — application source organized by feature modules.
- `openspec/specs/` — current product behavior and acceptance scenarios.
- `openspec/changes/` — proposed behavior changes and implementation plans.
- `openspec/config.yaml` — project context and OpenSpec authoring rules.
- `.codex/skills/openspec-*` — project-local OpenSpec workflows for Codex.
- `docs/ARCHITECTURE.md` — current implementation architecture.
- `docs/IMPLEMENTATION_GAPS.md` — known spec/code mismatches and unfinished
  product paths.
- `AGENTS.md` — repository workflow and engineering constraints for AI agents.

## Development workflow

Behavior changes follow State + Delta:

```text
current specs + approved delta → implementation → verification → new specs
```

Start by reading `AGENTS.md`, the affected capability specs, and the known-gap
register. Create an OpenSpec change before implementing new or changed behavior.

Validate all specifications with:

```bash
openspec validate --all --strict --no-interactive
```

Build the shared scheme with:

```bash
xcodebuild \
  -project Alias/Alias.xcodeproj \
  -scheme Alias \
  -destination 'generic/platform=iOS Simulator' \
  build
```
