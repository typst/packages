# Contributing

Thanks for taking the time to look. This project is small enough that almost any thoughtful contribution will be welcomed — but a couple of conventions keep the release pipeline (release-please + Typst Universe) running smoothly.

## Submitting a PR

1. Fork the repository on GitHub.
2. Clone your fork locally and create a branch for your change.
3. Make the changes, commit, and push to your fork.
4. Open a Pull Request against `main` on this repository.

Security issues should be reported privately per [`SECURITY.md`](SECURITY.md) instead of as a PR or issue.

## Project layout

[ARCHITECTURE.md](ARCHITECTURE.md) explains the layers, what each may import, and how a render flows; keep new code to it.

```text
lib.typ           # public entry — re-exports only (`altacv` and `alta()` are in internal/render.typ)
adapter/          # the JSON Resume mapping `alta()` draws with in the template, written to be copied
internal/         # the render pipeline, the markup blocks, the footers, the `adapter` helpers, render-time context, primitives and icons
internal/util/    # generic helpers: field reads, joins, checks, date formatting
internal/data/    # reading and checking the CV, labels and preferences, and their defaults
internal/design/  # the theme and its checks, document-wide styles, built-in themes and palettes, the icon set
internal/components/ # the layout components the sections and blocks map onto
sections/         # standalone `alta()`'s renderers, one per part of the CV (removed in the next major, #239)
template/         # the `typst init` starter; cv.typ is also the demo behind examples/cv.png, thumbnail.png and the preview frames
docs/             # reference.md, the full reference the README links to
assets/           # in-package raster/SVG resources (e.g. avatar-placeholder)
examples/         # example CVs + shared `_dates.typ` / `_cv.typ` helpers
tests/            # fixtures — CI renders each into examples/tests/*.pdf
tests/components.typ # the component gallery: each component, each variant
tests/panics/     # must-fail fixtures — each names the error it expects
tests/unit/       # `assert` checks of the side-effect-free helpers (dates, fields, header, …)
```

Each `internal/**/*.typ` and `sections/*.typ` opens with a docstring describing its responsibility — `grep -nE '^//' internal/*.typ internal/*/*.typ sections/*.typ` for a quick directory.

Identifiers and `.typ` file names are kebab-case, matching Typst's standard library (`from-unicode`, `hanging-indent`); a leading `_` marks a shared helper rather than a document (`examples/_cv.typ`), and shipped assets keep their published names (`examples/example_full.pdf`); option names (preferences, labels, colour roles, theme tokens) are kebab-case too (`column-ratio`), while [JSON Resume](https://jsonresume.org/schema/)'s data keeps its camelCase (`startDate`) as input. `data/` checks it under those names, so a message names what the caller wrote; the template's mapping (`adapter/json-resume.typ`) reads the checked CV in camelCase, and `_read-cv` maps it to kebab-case (`_kebab-fields`) for the standalone renderers (`start-date`). Section keys are kebab-case (`"focus-areas"`). A top-level name that `lib.typ` doesn't re-export starts with `_` (`_page-header`); any module may import it, within the layers in [ARCHITECTURE.md](ARCHITECTURE.md). Only what `lib.typ` re-exports is part of the public API: the template `altacv`, `alta`, the footers `cv-footer` and `cv-updated-footer`, `themes`, `maps-providers`, `avatar-placeholder`, `icon`, the blocks (`cv-header`, `contact`, `entry`, `publication`, `skill-row`, `rating`, `label-row`, `tag`, `divider`, `cv-columns`), the `adapter` module, whose `internal/adapter.typ` likewise imports only its helpers, and the deprecated `alta-from-json`, `from-json-resume`, `name`, `term`, `styled-link` and `palettes`. [docs/reference.md](docs/reference.md#exports) documents each. `lib.typ` imports nothing but what it re-exports: Typst re-exports every name a module imports, so anything else would leak into a user's `#import "@preview/altacv:…": *` (`tests/unit/api.typ` pins the exported names). Internal code calls the merged preferences `prefs`; `preferences` is the caller-facing parameter. Cross-file imports use relative paths (`#import "../internal/context.typ": ...` from `sections/`).

## Design conventions

Three rules decide what a change may add. Reviews hold new work to them.

### The data is JSON Resume, whichever way it arrives

The `cv` dict is the [JSON Resume schema](https://jsonresume.org/schema/): spec fields only, in the spec's shape, read only in the sections the spec gives them to (`work[].keywords` is in the spec; `volunteer[].keywords` isn't, so it doesn't render). Both ways in, an inline dict and a `resume.json` through [`@preview/gairm-import`](https://typst.app/universe/package/gairm-import)'s `parse`, take the same data: there are no dict-only features.

- **No new non-spec fields.** The `custom.altacv` [extensions](docs/reference.md#extensions) predate this rule; don't add to them.
- **Typst-only values are conveniences over a spec value**, never a field of their own: markup (`[Led the *platform* team]`) where the spec has a string, a `path()` or bytes where it has a URL.
- **Parity gates a release.** A field `alta()` renders ships only in a release whose pinned gairm-import schema (`internal/data/json-resume.typ`) accepts it, so the docs never document a route-specific gap.

### New looks go through parts and theme tokens

The default look is opinionated (only skills are tags). A new alternative look is opt-in through parts and theme tokens, not a new preference. The look preferences from 1.8.0, such as `uppercase-name` and `photo-size`, predate this rule; keep them, but don't extend the pattern. Preferences are for layout and behaviour: which column a section takes, `date-format`, `maps-provider`, `owner-names`.

- **A part per element a user may restyle or replace, and a paragraph part per row that lays such elements out**, labelled with `_part` (see [ARCHITECTURE.md](ARCHITECTURE.md#layers)): each keyword is `<alta-keyword>`, and the line they sit on `<alta-keywords>`, so one rule replaces a keyword and another spaces the row. A layout need a show rule can reach through a paragraph part doesn't get a token. Parts are public API, listed with their kind in the reference's [Part labels](docs/reference.md#part-labels).
- **A replacement rule's `it` is opaque.** The reference promises a part's kind, not its element: use `it` whole (`tag(it)`), and keep a part's value free to be text, a sequence or a `context`.
- **A theme token for any value the default fixes**: a separator, size or treatment (`separator.keywords`, `treatment.link: emph`). A token holds a value, never a choice of component: not `keywords: "tags"`.

### Work with Typst, not around it

A Typst user should be able to style a CV the way they style any document. Where Typst already has a rule, an element or a value for something, the template uses it rather than an option of its own. [#381](https://github.com/smur89/alta-typst/issues/381) tracks bringing the older options in line.

- **A setting Typst already has is Typst's, not a preference**: the language is `set text(lang: ..)`, which also picks the labels. The preferences from 1.8.0 that duplicate one (`paper`, `margin`, `font`, `body-size`) predate this rule ([#376](https://github.com/smur89/alta-typst/issues/376)); don't add more.
- **An element Typst already has is restyled through that element, not a part**: the list bullet through `show list`, the line between entries through `show divider`. A part label is for what Typst has no element for.
- **Typst's own values where they exist**: an alignment, a function or a `datetime`, not a name in a string. The string options from 1.8.0 (`photo-position`, `header-text-align`) predate this rule ([#377](https://github.com/smur89/alta-typst/issues/377)).
- **Moving to Typst's way doesn't break a CV.** The old form keeps working, rewritten in `internal/data/canonical.typ` where it needs one, the reference lists it as deprecated, and its removal is listed in [#239](https://github.com/smur89/alta-typst/issues/239) for the next major.

## Development loop

Install Typst at the version CI uses — the `FROM ghcr.io/typst/typst:<version>` line in the `Dockerfile`. Two fonts must also be available on the system font path: **Lato** (the default theme's font) and the desktop **FontAwesome** set (read by [`@preview/fontawesome`](https://typst.app/universe/package/fontawesome) for icons — without it, icons render as tofu).

On macOS, one block sets up everything Homebrew can provide:

```bash
brew install typst pngquant webp
brew install --cask font-lato font-fontawesome
```

`pngquant` compresses the committed PNG renders (the thumbnail, the gallery pages) and `webp`'s `img2webp` builds the README's animated preview (`make preview-webp`); `make check` needs neither.

Linux / Windows / manual install paths: see the [Quick start in the README](README.md#quick-start). Run `typst fonts` to confirm both are visible to Typst.

Most everyday tasks go through the `Makefile`; `make help` lists every target. The ones you'll use most:

```sh
make check        # test + fmt-check; `make -k -j8 check` runs in parallel and reports every failure
make fmt          # format every tracked .typ in place (typstyle)
make docker-pdfs  # regenerate the committed renders in the pinned image (see below)
```

`make check` runs the checks of CI's lint and `typstyle` jobs: every example, template and fixture compiled against PDF/A-2b and PDF/UA-1 and failing on a warning, plus the panic, unit and format checks. It runs them against your fonts, where CI uses the pinned image's, and it skips the checks that need that image or the packaging, so a green `make check` can still fail a PR on:

- **render drift**: CI byte-compares the committed fixture PDFs and `thumbnail.png` against a fresh render in the image. Run `make docker-pdfs` after a rendering change ([below](#regenerating-pdf-fixtures-docker)).
- **`typst-package-check`**: the package checked as typst/packages will check it.

### Helper unit tests

Helpers that only compute a value are checked with `assert.eq` under `tests/unit/`, one file per module; `make test-unit` (part of `make test`) runs them. That's quicker and more precise than a PDF fixture. For helpers that return content, `tests/unit/_plain.typ` flattens it to text.

### Error-path tests

Every panic a user can hit has a fixture under `tests/panics/` whose first line is `// expect: <part of the message>`. `make test-panics` (part of `make test`) compiles each one and fails if it compiles, or fails without that text. Adding a validator? Add a fixture for it.

### Formatting

Typst sources are formatted with [typstyle](https://github.com/Enter-tainer/typstyle). CI runs `make fmt-check` and fails on any unformatted file, so run `make fmt` before committing (or wire it into your editor). Pin the same version CI uses — `TYPSTYLE_VERSION` in [`.github/workflows/build.yml`](.github/workflows/build.yml) — since formatter output can shift between releases; `brew install typstyle` on macOS. Formatting is purely mechanical and never changes rendered output.

### Regenerating PDF fixtures (Docker)

CI byte-compares the committed `examples/tests/*.pdf` against a fresh render every PR (`make in-image TARGETS='-k -B -j4 -O test-pdfs test'` then `make check-drift DRIFT_PATHS='examples/tests/*.pdf'`). Local renders on macOS, or against a non-pinned Lato/FontAwesome install, drift from the CI bytes — so any change that touches rendering (icon glyphs, `lib.typ`, anything under `internal/` or `sections/`, the FA version) needs the fixtures regenerated inside the pinned CI image:

```sh
make docker-pdfs   # pulls the pinned ghcr.io/smur89/alta-typst-ci image and runs `make -B -j4 all` (every committed render but the README preview, rebuilt)
make docker-shell  # drop into the image with the workspace mounted, for ad-hoc work
```

`--platform linux/amd64` is forced so the output is byte-identical regardless of host architecture (Apple Silicon falls back to emulation — slower but reproducible). The image is published by [`.github/workflows/image.yml`](.github/workflows/image.yml); the pinned tag lives in the `Makefile` (`DOCKER_IMAGE`). CI's render jobs run in the same image (`make in-image`), so the lint job's re-rendered fixtures compare byte for byte with the committed ones.

If you'd rather drive Typst directly, the manual incantations are:

```sh
typst compile --root . examples/example-full.typ examples/example_full.pdf
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

PRs squash-merge with the PR title as the commit subject, so make the **PR title** a conventional commit. The squash commit's body is the PR's commit messages, one per line.

**No issue or PR number in a commit subject.** GitHub appends the PR's number to the squash subject, and release-please reads the commit messages in the body too, so a subject like `feat: add ORCID (#302)` lists the change twice in the release notes, once as `#302` and once as the PR. Reference the issue in the body instead: `Closes #302`.

**Fixing a merged PR's release notes.** If a squash still produces a wrong or duplicate entry, add a block to the merged PR's description with one conventional line per entry, including the PR number. Then re-run the `release-please` job of the latest `main` push:

```
BEGIN_COMMIT_OVERRIDE
feat: add ORCID as a profile network (#313)
END_COMMIT_OVERRIDE
```

A `chore:` line drops a PR from the notes entirely.

## Merging

- **Merge only when the PR is up to date with `main`.** Two PRs can each pass CI and still break `main` together, for example when one changes a render the other's new fixture captured. Update the branch, let CI run on the combination, then merge.
- **Merge a stack bottom-up, each PR against `main`.** A PR stacked on another branch merges into that branch, not `main`. Retarget it to `main` once the PR below it lands, merge `main` into it (force-pushing is blocked), and check CI before merging.

## Adding a profile-network icon

This is the most common shape of contribution. A user can already draw any network with `preferences.profile-icons`; a built-in entry saves everyone the mapping. Two changes:

1. Add a row to `_network-icons` in `internal/design/icon-set.typ`. Use the lowercase key (`_profile-network` in `internal/data/cv.typ` lowercases the network before the lookup) and map it to the canonical FontAwesome glyph name — browse [fontawesome.com/search](https://fontawesome.com/search) to find the right one (e.g. `"linkedin"`, `"x-twitter"`, `"github"`). `@preview/fontawesome` handles the brand-vs-solid font selection automatically.
2. Add the canonical capitalised name to the supported-networks list in `docs/reference.md` (under "Profile networks").

`feat:` commit. The icon will render automatically wherever a `basics.profiles` entry uses the new network. If the new icon is a utility / Free Solid glyph rather than a brand mark (e.g. a generic globe-style fallback), also add the lowercase key to `_solid-names` in `internal/design/icon-set.typ` so `fa-icon` is called with `solid: true`.

## Adding a section, preference, or label

Check the [design conventions](#design-conventions) first: a new field must be in the [JSON Resume spec](https://jsonresume.org/schema/), and a new look is a part or a theme token, not a preference.

For a **new section**: add its spec to `_section-specs` in `internal/data/sections.typ` (column; `read` / `items` when it isn't a plain entry array; `fields`, a type rule per field it draws; `keep`, when some entries shouldn't render; `check`, for checks that need more than a type, in `internal/data/cv-checks.typ`); draw it in the mapping, `adapter/json-resume.typ`, as a function `(cv, ctx)` added to its `sections` dict (`ctx` is `(labels, prefs, owners)`; read the entries with `adapter.entries(cv, key)` and draw them with the public blocks only, so the mapping stays copyable; a unit test pins its keys to `_section-specs`); add the standalone renderer under `sections/<name>.typ` and to `_renderers` in `internal/registry.typ` (every renderer takes `(entries, ctx)`, where `entries` are the checked entries `keep` let through and `ctx` is `(labels, prefs, format-date, owner, owners)`, usually destructured as `(labels, format-date, ..)`); add the heading to `internal/data/labels-en.toml`; and document its fields in `docs/reference.md`. For a **new part**: label it with `_part`, add its row to the reference's [Part labels](docs/reference.md#part-labels) table and a rule for it to `tests/show-rules.typ`; a recipe the reference documents for it (`tests/keyword-pills.typ`) gets a fixture. For a **new preference**: add it to `_default-preferences` in `internal/data/defaults.typ`, give it a rule or checker in `_preference-rules` (`internal/data/validation.typ`; `tests/unit/validation.typ` fails until you do) with a `tests/panics/` fixture, read it from `ctx.prefs`, and add its row to the reference's [Preferences](docs/reference.md#preferences). Deprecating an input shape? Rewrite it into the current one in `internal/data/canonical.typ` rather than in a renderer. A new component, or a new variant of one, gets an entry in the component gallery (`tests/components.typ`). Any change to the data shape or the rendered surface should also add a fixture under `tests/` exercising it — `tests/awards.typ` is a small self-contained example.

The `tests/` suite doubles as a regression guard: `make test-pdfs` regenerates `examples/tests/*.pdf` from each fixture, and CI fails the lint job if the rendered output drifts from the committed PDF. After making a change that intentionally affects output, run `make docker-pdfs` (see [Regenerating PDF fixtures](#regenerating-pdf-fixtures-docker)) and commit the updated PDFs alongside your source change.

## Security

See [`SECURITY.md`](SECURITY.md) for how to report a vulnerability.
