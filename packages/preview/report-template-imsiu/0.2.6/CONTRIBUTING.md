# Contributing to IMAMU CCIS Report Template

Thanks for your interest in improving this Typst template. This guide explains how to propose changes so they are easy to review and safe to publish on Typst Universe.

This project follows Typst Universe package guidelines. If anything below seems unclear, the upstream docs are the source of truth:

- Package submission and quality rules: <https://github.com/typst/packages/tree/main/docs>
- Manifest requirements: <https://github.com/typst/packages/blob/main/docs/manifest.md>
- Documentation/README rules: <https://github.com/typst/packages/blob/main/docs/documentation.md>
- Tips on what to commit/exclude: <https://github.com/typst/packages/blob/main/docs/tips.md>
- High‑quality Typst files: <https://github.com/typst/packages/blob/main/docs/typst.md>

## How you can help

- Report bugs or request features via Issues.
- Improve documentation and examples.
- Fix bugs or add small features that align with the template’s goals.
- Add or improve supported languages in `resources/i18n/`.

## Development setup

- Install Typst CLI: <https://typst.app/docs>
- Optional but recommended tools:
  - typst-package-check (lint): <https://github.com/typst/package-check>
  - tytanic (tests): <https://typst-community.github.io/tytanic/>
  - typos (spelling): <https://github.com/crate-ci/typos>

Typical workflow

1. Fork the repo and create a feature branch.
2. Make your changes.
3. Validate locally:

   - Compile the template: `typst compile template/main.typ` (or open in Typst app). It should compile out-of-the-box.
   - Lint: run `typst-package-check` and address findings.

4. Open a pull request.

## Coding and template guidelines (Universe‑friendly)

- Use two spaces for indentation.
- Prefer kebab-case for variable/function names when possible.
- Examples and template code must use absolute “package-style” imports, not relative file imports. For example:
  - Good: `#import "@preview/report-template-imsiu:0.x.y": report`
  - Avoid: `#import "../lib.typ": report`
- Public API pattern: import and re-export only what you want public from `lib.typ` (see docs/typst.md “Only exposing specific functions publicly”).
- Thumbnail: Keep the template thumbnail a PNG/WebP, longest edge ≥ 1080px, ≤ 3 MiB. Don’t reference the thumbnail in code; it’s auto-excluded.
- Keep the package small: Large PDFs, images, and generated artifacts should be excluded from the bundle (see “What to exclude”).

## Manifest updates (typst.toml)

When your change affects behavior, documentation, or assets, ensure the manifest stays compliant with Typst Universe:

- Required fields are present and correct: `name`, `version` (SemVer), `entrypoint`, `authors`, `license`, `description`.
- Template section exists and is valid:
  - `[template]` with `path`, `entrypoint`, and `thumbnail`.
  - At least one `categories` entry under `[package]` (e.g., `"report"`).
- Description style: Concise (ideally 40–60 chars), ends with a period, no redundant “Typst”/“template” wording for templates.
- Use `repository` (and optionally `homepage`).
- Use `exclude` to keep the downloadable bundle lean (docs/images can still be browsed on Universe).
- Do not include submodules; copy real files.

When you change anything user‑visible (features, defaults, assets, docs), bump the `version` in `typst.toml` following SemVer:

- Patch: fixes and documentation-only improvements.
- Minor: backwards‑compatible features.
- Major: breaking changes.

## Documentation and README

- README must briefly explain the template and show how to use it.
- Any usage examples must import via `@preview/{name}:{version}` and be kept up to date when releasing.
- If you add manuals/examples/images under `docs/` or `images/`, link them from the README. Large files should be excluded in the manifest.

## Internationalization (i18n)

- Translations live in `resources/i18n/{lang}.json`.
- Keep keys consistent across languages. If you add a new key, add it to all languages (at least `en`, `ar`, `fr`).
- Validate JSON syntax and ensure the template still compiles in all supported languages.

## Changelog policy (docs/changelog.md)

- Maintain a human‑readable changelog.
- Add entries under an “Unreleased” section in your PR, or directly under the new version if you also bump the version.
- On release, set the date and move “Unreleased” content under the new version.
- Mention: features, fixes, documentation, manifest tweaks, i18n updates.

Suggested format (follow existing file style):

```markdown
## 0.2.6 – 2025‑11‑12

- Added CONTRIBUTING.md and README Contributing section.
- Aligned manifest description with Typst Universe guidance.
```

## Pull request checklist

- [ ] Template compiles out-of-the-box (`template/main.typ`).
- [ ] README is accurate; examples (if any) compile and use `@preview` imports.
- [ ] `typst.toml` updated (version bump, description, categories, exclude, etc.).
- [ ] `docs/changelog.md` updated.
- [ ] No large or unnecessary files added to the bundle; thumbnails within limits.
- [ ] Ran `typst-package-check` and addressed issues.
- [ ] Spelling checked (optional: `typos`).

## Release process (maintainers)

- Merge PRs after review.
- Bump version in `typst.toml` if not already bumped, adjust README import versions if present.
- Update `docs/changelog.md` with the release entry and date.
- Tag the release (`vX.Y.Z`) only when ready to publish to typst universe.
- Generate a new thumbnail if needed here is the command

```sh
magick -density 250 template/main.pdf[0] -flatten template/thumbnail.png
```

Thanks again for contributing!
