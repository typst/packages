# Changelog

# [v0.8.1](https://github.com/ISC-HEI/isc-hei-typst-templates/releases/tag/0.8.1), June 2026

## Added
- **Full German (DE) localisation.** Completed the missing `de` UI strings (faculty, HES-SO, programme / study-course titles, supervising roles, thesis reference & submission, keywords, …) and made the **declaration of honour trilingual (FR/DE/EN)**. German theses, executive summaries and documents now render fully localised covers. New i18n key `summary-too-long`.
- **Per-document-type aliases** `thesis` / `report` / `exec-summary` / `tb-assignment` (thin `project.with(doc-type: …)` shims): example files now write `#show: thesis.with(…)` and never pass `doc-type` (the thesis also drops `split-chapters`). `project()` stays the canonical entry; there is deliberately **no `document` alias** — it would shadow Typst's built-in `document` element.
- **Shared `majors` enum + validation** (`lib/settings.typ`): the five ISC majors as a single FR/EN/DE source of truth. The value is validated on every cover (`validate-major`) and rendered in the document's language (`resolve-major`), so a major shows correctly localised on every document type.
- **`#acronym-table()` helper** in the example files, collapsing the verbose appendix `#print-index(…)` block to a single call — kept example-side, so `acrostiche` stays out of the package dependencies.
- **Nix dev environment** (`flake.nix` + `.envrc`, by @MadeInShineA — #30): a reproducible `nix develop` shell with `typst`, `tinymist`, `just`, `pngquant`, `zopfli` and the ISC fonts (Fira Code, Source Sans / Source Sans Pro, Inria) preconfigured.

## Changed
- **Declaration of honour moved into the package** as `#declaration-of-honour()` (was the user-facing `src/pages/honneur.typ`, now `lib/pages/honour.typ`). Students only set `signature:` and call the function — they never edit the wording. Output is byte-identical for FR/EN.
- **The executive-summary over-length summary is now a soft warning** in the cover's warning box instead of a hard `panic`: the blurb is *measured* against its box and flagged only if it would actually overflow (an entirely missing summary still hard-fails). The shared layout-warning header was generalised to *"LAYOUT WARNING — content may overflow"* since the box now also carries the summary.
- **Consistent major naming.** The label had drifted between templates (thesis said "Security" and omitted "Data engineering"; exec said "Computer security"; the poster "Data Engineering") — all six now draw from the shared enum, with French as canonical.
- Removed the now-unnecessary `doc-type` / `split-chapters` plumbing from the bachelor-thesis and executive-summary examples.

## Fixed / Internal
- **Bibliography rendering fixed** (by @MadeInShineA — #31): `the-bibliography(bib-file: …)` now takes the file *contents* via `read("bibliography.bib", encoding: none)` instead of a path string, and the package no longer hard-codes a `../src/` prefix — so the bibliography resolves correctly after the `lib/` refactor.
- **One dev command, `just dev`** — re-links `@preview` to live source and compiles all six examples. It **self-heals** the dev symlinks, so it works even right after a `pack` / `test-all`; `test-all` and `bump-version` now restore the symlinks automatically too. Hardened `scripts/dev_link` so re-linking reliably *replaces* a leftover packed dir (it could previously nest the symlink inside it). `install-symblinks` is now internal plumbing — hidden from `just --list`, still callable directly.
- Refreshed example PDFs, preview thumbnails, `CLAUDE.md` and `CONTRIBUTING.md`; bumped the root and all six `templates/*/typst.toml` to `0.8.1`.

# [v0.8.0](https://github.com/ISC-HEI/isc-hei-typst-templates/releases/tag/0.8.0), June 2026

## Added
- **Title & subtitle overflow warnings** across all six templates (new `lib/overflow.typ`). Titles/subtitles are *measured* (not character-counted) against a single shared reference cover — the bachelor thesis, the narrowest layout — so the same title is flagged identically on every document type. Tunable via `max-title-lines` / `max-subtitle-lines` in `lib/settings.typ`. On the poster the warning is a foreground overlay, so it never pushes content onto a second A1 page.
- **Completeness / sanity check on the TB assignment cover**: once any field is edited, the sheet flags a still-placeholder student, ID, supervisor or milestone dates, and an invalid `ISC-XX-YY-N` ID format — folding the overflow warnings into the same box.
- **Subtitle support on the executive summary**, rendered under the title.
- New FR / EN / DE i18n keys: `layout-warning-header`, `completeness-warning-header`, `title-too-long`, `subtitle-too-long`.

## Changed
- **The TB assignment now supports theses carried out abroad** (e.g. the MOVE exchange programme): the supervisor is shown as the "HES-SO supervisor", the expert field is dropped, and the co-supervisor is replaced by host-institution supervisor + (optional) first-line mentor fields.
- **The bachelor-thesis running header/footer now turns on automatically** at the first numbered chapter — students no longer place `#set-header-footer(true)` by hand (it stays exported as an escape hatch). Output is byte-identical to the old manual call.
- The TB assignment subtitle is now rendered under the title (previously accepted but unused).
- Thesis drafting warning box renamed *DOCUMENT INCOMPLET* → *ATTENTION REQUISE*.
- Updated the thesis-showcase website link printed on the poster to `https://tbs.isc-vs.ch`.
- Minimum supported Typst compiler relaxed to `0.14.0` for flexibility.

## Fixed / Internal
- **Deterministic re-renders**: removed encoder- and timestamp-level nondeterminism from the build, so thumbnails (now also smaller) and PDFs are byte-reproducible given the same compiler, fonts and document content.
- Removed a stale committed `src/poster.pdf`.
- Refreshed the example PDFs, preview thumbnails, READMEs and `CLAUDE.md`; bumped the root and all six `templates/*/typst.toml` to `0.8.0`.

# [v0.7.9](https://github.com/ISC-HEI/isc-hei-typst-templates/releases/tag/0.7.9), May 2026

This is a large release that grows the suite from five to **six packages**, restructures the whole codebase into a modular library, and ships a complete contributor release pipeline. Highlights below.

## Added

### New `isc-hei-poster` package
- A sixth template for **A1 scientific posters**, with `isc-poster()`, `isc-card()` and `isc-colbreak()` for column-based layouts.
- Dedicated README, thumbnail, `typst.toml` metadata, runnable `src/poster.typ` example and example PDF.
- Layout regression tests (`scripts/test-poster.sh`, `scripts/test-poster-variants.sh`, `just test-poster`).

### Declaration of honour (thesis)
- New bilingual (FR/EN) *déclaration sur l'honneur* page (`src/pages/honneur.typ`), included in the bachelor thesis between the résumé and acknowledgements.
- Auto-fills author / title / academic year / date from project metadata — the student only sets `date:` and `signature:`. A missing signature renders a flagged placeholder instead of failing.

### Completeness check on the thesis cover
- A red "DOCUMENT INCOMPLET / INCOMPLETE DOCUMENT" warning box lists unfilled required fields (`thesis-id`, `signature`, `project-repos`, `keywords`) as a drafting aid.
- New `hide-completeness-warning` option suppresses the box, leaving a discreet red dot in the margin as a record of the override.

### Fonts-not-installed guard
- When the ISC fonts are missing, both `project()` and `isc-poster()` now render a clear "fonts not installed" page instead of silently falling back to system fonts.

### Release & packaging tooling
- **Typst Universe release automation**: `just universe-stage` / `universe-check` / `universe-push` / `update-pr` recipes plus supporting scripts to open and refresh release PRs against `typst/packages`.
- **Allow-list-driven packing**: `scripts/template-files` is the single source of truth for each package's required files; `just check-pack` verifies packed packages contain exactly those files (no dangling leaks, e.g. the thesis-only signature placeholder no longer bleeds into other packages).
- **Version bumping**: `scripts/bump-version` / `just bump-version` updates all `typst.toml` files and `src/` imports at once.
- Project guidance file `.gitattributes`.

## Changed

### Major library refactor
- The monolithic source was split into a modular `lib/` tree (`includes`, `settings`, `fonts`, `i18n`, `decorations`, `content`, `code`, `covers`, `project`, `poster`, `pages/cover_*`). `isc_templates.typ` is now a thin façade that re-exports the modules, so existing `#import "@preview/isc-hei-*": *` usage is unchanged.

### Layout & typography
- **Chapter rule** completely rewritten; **margins fixed**.
- Hashed cover line now matches the title text width.
- Improved, more informative running footers.
- `exec-summary` gains a web-usage opt-out disclaimer; thesis declaration-of-honour wording reworked.

### Build experience
- **Parallel compilation** in the Justfile; detection of symlinked vs. packed `@preview` installs.
- Normalised casing for "ISC"; consistent lowercase `s` in "systèmes" across the programme name.
- Reduced user-facing boilerplate; default document language is now **`fr`**.
- Reworked font installation script and documentation.

### Fixes
- Fixed font warnings both locally and on the web (closes #25).
- Fixed the `document` template's header; corrected several wrong default values.
- Cleaned up dangling/ignored files and refreshed examples and thumbnails for the release.

**Full Changelog**: https://github.com/ISC-HEI/isc-hei-typst-templates/compare/0.7.1...0.7.9

# [v0.7.1](https://github.com/ISC-HEI/isc-hei-report/releases/tag/0.7.1), March 2026

## Added
- New `fancy-chapter-rule` option in the bachelor thesis template
- Dedicated assignment cover renderer in `lib/pages/cover_assignment.typ` for clearer TB assignment sheet composition
- Template-local `typst.toml` package metadata across templates for version management

## Changed
- Updated templates and dependencies to version `0.7.1`
- Refactored TB assignment translation handling and document title retrieval in cover rendering
- Improved TB assignment variable naming and comments for better readability and consistency
- Updated README and contributor-facing documentation links
- Refreshed generated examples and preview thumbnails for the `0.7.1` submission

# [v0.7.0]((https://github.com/ISC-HEI/isc-hei-report/releases/tag/0.7.0)), March 2026

## Added
- New **TB assignment sheet** template (`tb-assignment`) with full rendering logic, i18n support (FR/EN/DE), and addendum section
- `project-types` dictionary exported from the template for type-safe project type selection (`exploratoire` / `implementation`)
- Revision field in i18n and enhanced template styling
- Additional document examples in README

## Changed
- Improved and unified date formatting logic across all templates
- Nicer title display for bachelor thesis
- Refactored TOC inclusion
- Updated ISC logo across all README files
- Code structure refactored for improved readability

# [v0.6.0](https://github.com/ISC-HEI/isc-hei-report/releases/tag/0.6.0)
- Changes after the first student handout
- Document check script (for fonts & info)
- Added template version in document template metadata
- Panic message if no URL for repos
- Panic message if no document ID
- Typos fixed
- Header modified for right and left pages
- Header modifier for executive summary, only space for 2 lines
- Subtitles for long titles
- README.md corrected with correct refs, image of templates corrected as well for Typst universe

# [v0.5.3](https://github.com/ISC-HEI/isc-hei-report/releases/tag/0.5.3)
- Official repository field and official ID of the thesis added
- Title page of bachelor thesis now shows the official thesis ID
- The abstract / résumé display the keywords as well as the official repos, with a function a no clutter
- Minor tweaks to the first and second page of the bachelor thesis
- Corrected typos in README.MD

# [v0.5.2](https://github.com/ISC-HEI/isc-hei-report/releases/tag/0.5.2)
- Executive summary template added
- Title page 2 for `b-thesis` has now correct colons for `fr` and `en`, corrected typo in `fr` (thanks M. Ribeiro)
- Lorem-ipsum paragraphs to have a better representation of final output
- Minor changes in template declaration comments
- Updated repos URL

# [v0.3.1](https://github.com/ISC-HEI/isc-hei-report/releases/tag/0.3.1)
- Rewrote most of the template because it is now merged with the bachelor thesis as well
- using `Justfile` for building, based on https://github.com/typst-community/typst-package-template/tree/main
- update process for pushing to typst universe
- much cleaner user experience in file and more flexibility for printing out table of contents etc...
- `typst` v0.13.1 now supported
- removed extra spaces
- removed eval calls
- updated `codelst` and `showybox`

# [v0.1.5](https://github.com/ISC-HEI/isc-hei-report/releases/tag/0.1.5)
- Cover image kind and supplement
- `toc-title` project parameter
- multi-language support
- captions as markdown
- multi-pages code listings
- new listing format for line numbers
- headers

# [v0.1.3](https://github.com/ISC-HEI/isc-hei-report/releases/tag/0.1.3)
Cosmetic and minor changes only

# [v0.1.0](https://github.com/ISC-HEI/isc-hei-report/releases/tag/0.1.0)
Initial Release
