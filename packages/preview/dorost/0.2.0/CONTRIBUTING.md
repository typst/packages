# Contributing

Issues and pull requests are welcome. Keep changes focused, explain the user-facing behavior, and preserve Dorost's use-case-neutral scope.

## Before opening a pull request

- Keep the public API small and document every public option or helper.
- Preserve independent language, direction, font, and numeral settings.
- Add or update a focused Typst fixture for behavior changes.
- Run `./scripts/check.sh` and `git diff --check`.
- Inspect at least one rendered English and Persian/mixed-script example when changing layout or typography.
- Do not add font binaries to the published package, or add unlicensed fonts, logos, or generated PDFs. Test-only font fixtures belong under `tests/fonts/` with upstream licenses and provenance.

## Releases

Contributors add user-facing changes under `[Unreleased]` in `CHANGELOG.md`. For a release, the maintainer:

1. Updates the package version in `typst.toml`, all pinned `@preview/dorost` imports, and the template version references together.
2. Moves the release notes into a dated `CHANGELOG.md` section named `## [X.Y.Z] - YYYY-MM-DD`.
3. Runs `./scripts/check.sh`, `git diff --check`, and `python3 scripts/release-notes.py vX.Y.Z`.
4. Creates and pushes an annotated `vX.Y.Z` tag from the verified commit. GitHub Actions checks the tag against the manifest and changelog, then creates the GitHub Release.
5. Submits that exact package version to Typst Universe in a separate reviewed PR. GitHub releases do not publish to the Typst package registry.

Published package versions are immutable; make a new SemVer version for every registry update. Do not publish an unreviewed API, font, or license change.

See [AGENTS.md](AGENTS.md) for repository-specific implementation guidance.
