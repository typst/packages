# Contributing

Thanks for taking the time to look. This project is small enough that almost any thoughtful contribution will be welcomed — but a couple of conventions keep the release pipeline (release-please + Typst Universe) running smoothly.

## Submitting a PR

1. Fork the repository on GitHub.
2. Clone your fork locally and create a branch for your change.
3. Make the changes, commit, and push to your fork.
4. Open a Pull Request against `main` on this repository.

Security issues should be reported privately per [`SECURITY.md`](SECURITY.md) instead of as a PR or issue.

## Project layout

```text
lib.typ           # public entry — re-exports + `alta()`
internal/         # shared infrastructure, one concern per file
sections/         # one renderer per dispatched CV section
assets/           # in-package raster/SVG resources (e.g. avatar-placeholder)
examples/         # example CVs + shared `_dates.typ` helper
tests/            # fixtures — CI renders each into examples/tests/*.pdf
```

Each `internal/*.typ` and `sections/*.typ` opens with a docstring describing its responsibility — `grep -nE '^//' internal/*.typ` for a quick directory.

Modules under `internal/` are leading-underscore private; only what `lib.typ` re-exports is part of the public API (`alta`, `alta-from-json`, `from-json-resume`, `avatar-placeholder`, `palettes`, `maps-providers`, `icon`, `name`, `term`, `tag`, `divider`, `rating`, `styled-link`). Cross-file imports use relative paths (`#import "../internal/state.typ": ...` from `sections/`).

## Development loop

Install Typst at the version CI uses — see `TYPST_VERSION` in `.github/workflows/build.yml`. Two fonts must also be available on the system font path: **Lato** (the default body font, override via `preferences.font`) and the desktop **FontAwesome** set (read by [`@preview/fontawesome`](https://typst.app/universe/package/fontawesome) for icons — without it, icons render as tofu).

On macOS, one block sets up everything Homebrew can provide:

```bash
brew install typst
brew install --cask font-lato font-fontawesome
```

Linux / Windows / manual install paths: see the [Fonts section in the README](README.md#fonts). Run `typst fonts` to confirm both are visible to Typst.

Most everyday tasks go through the `Makefile`:

```sh
make             # build every example PDF + cv preview + per-fixture PDFs
make cv          # build examples/cv.pdf + examples/cv.png from template/cv.typ
make example-full # build examples/example_full.pdf + per-page gallery PNGs
make thumbnail   # build thumbnail.png (Universe package-card image)
make test        # compile every example + fixture (same shape as CI lint)
make clean       # remove generated PDFs and PNGs
make help        # summarise the available targets
```

`make test` is the local equivalent of the CI lint job — green here means CI lint will pass too. `make` (default) regenerates `examples/cv.png` at 150 DPI; pass `PPI=300` for a higher-resolution render.

### Regenerating PDF fixtures (Docker)

CI byte-compares the committed `examples/tests/*.pdf` against a fresh render every PR (`make test-pdfs` then `git diff --exit-code -- examples/tests`). Local renders on macOS, or against a non-pinned Lato/FontAwesome install, drift from the CI bytes — so any change that touches rendering (icon glyphs, `lib.typ`, anything under `internal/` or `sections/`, the FA version) needs the fixtures regenerated inside the pinned CI image:

```sh
make docker-pdfs   # pulls the pinned ghcr.io/smur89/alta-typst-ci image and runs `make all`
make docker-shell  # drop into the image with the workspace mounted, for ad-hoc work
```

`--platform linux/amd64` is forced so the output is byte-identical regardless of host architecture (Apple Silicon falls back to emulation — slower but reproducible). The image is published by [`.github/workflows/image.yml`](.github/workflows/image.yml); the pinned tag lives in the `Makefile` (`DOCKER_IMAGE`) and — once the follow-up PR adds `container:` to `build.yml` — must also be kept in sync there.

If you'd rather drive Typst directly, the manual incantations are:

```sh
typst compile --root . examples/example_full.typ examples/example_full.pdf
for f in tests/*.typ; do typst compile --root . --format pdf "$f" /dev/null; done
```

`--format pdf` is required when the output path is `/dev/null` — Typst cannot infer the format from a path with no extension.

CI runs the same compile sweep on every PR and uploads `cv-pdf` and `example-full-pdf` artifacts, so reviewers can see your output without checking out locally.

## Conventional commits

The repo uses [release-please](https://github.com/googleapis/release-please) to cut releases. Versioning is derived from commit messages on `main`, so each merged PR needs a clean conventional-commit message.

| Prefix | Bump | Use for |
|---|---|---|
| `fix:` | patch | Bug fix, doc correction, broken link, cosmetic polish |
| `feat:` | minor | New section, new `preferences` or `labels` key, new profile network |
| `feat!:` or `BREAKING CHANGE:` footer | major | API change that existing users would need to migrate |
| `chore:`, `docs:`, `ci:`, `refactor:`, `test:` | none | Internal changes that shouldn't trigger a release |

PRs squash-merge with the PR title as the commit subject, so just make the **PR title** a conventional commit. The body of the squash commit comes from the PR description.

## Adding a profile-network icon

This is the most common shape of contribution. Two changes:

1. Add a row to `_network_icons` in `internal/icons.typ`. Use the lowercase key (the lookup runs through `lower(profile.network)`) and map it to the canonical FontAwesome glyph name — browse [fontawesome.com/search](https://fontawesome.com/search) to find the right one (e.g. `"linkedin"`, `"x-twitter"`, `"github"`). `@preview/fontawesome` handles the brand-vs-solid font selection automatically.
2. Add the canonical capitalised name to the supported-networks list in `README.md` (under "Profile networks").

`feat:` commit. The icon will render automatically wherever a `basics.profiles` entry uses the new network. If the new icon is a utility / Free Solid glyph rather than a brand mark (e.g. a generic globe-style fallback), also add the lowercase key to `_solid_names` in `internal/icons.typ` so `fa-icon` is called with `solid: true`.

## Adding a section, preference, or label

For a **new section**: add the renderer under `sections/<name>.typ`, register it in `_sections` in `internal/layout.typ` (column + dispatch closure), and add the heading to `_default_labels` in `internal/defaults.typ`. For a **new preference**: add it to `_default_preferences` in `internal/layout.typ`, validate it inside `alta()` in `lib.typ`, and thread it through to the consumer. Any change to the data shape or the rendered surface should also add a fixture under `tests/` exercising it — `tests/publication_types.typ` is a small self-contained example.

The `tests/` suite doubles as a regression guard: `make test-pdfs` regenerates `examples/tests/*.pdf` from each fixture, and CI fails the lint job if the rendered output drifts from the committed PDF. After making a change that intentionally affects output, run `make test-pdfs` locally and commit the updated PDFs alongside your source change.

## Security

See [`SECURITY.md`](SECURITY.md) for how to report a vulnerability.
