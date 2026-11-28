# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.4.0] - 2026-11-28

### Added

- `card` and `card-grid`: tinted panels with an accent bar, laid out the way
  `grid` places its cells (`colspan`, `rowspan`, `x`, `y`), with per-row
  equal-height cards, reading-order numbering, a cycling `edge`/`accent`/`fill`,
  and passthrough of `grid.cell`, `grid.hline`, `grid.header` and `grid.footer`.
- Theme color API: `resolve-theme`, `active-theme`, `theme-color`, `theme-text`,
  `theme-box`, `with-theme`, `theme-block-code-background`,
  `theme-card-code-background` and `theme-header-dim-color` let user content read
  the resolved theme.
- The theme dictionaries now expose every color the template uses, including
  `dark`, `toc-background`, `toc-text`, `toc-stroke` and `card-background`.
- `tracker: false` disables the header progress dots while keeping the header.
- Header links: section names jump to the first slide of their section, and
  progress dots jump to the slide they mark. The collapsed glyphs of an
  overlong tracker (a trailing ellipsis or a run marker) are not clickable.
  Header links stay plain even when the document styles links.
- `speaker-note`: invisible notes attached to a slide, collected with
  `setup-presentation(speaker-notes: true)` into a `<pepentation-pdfpc>`
  payload. `pdfpc-bundle-assets()` writes it to a `.pdfpc` sidecar read by
  pdfpc, next to the PDF in a single bundle compile; outside a bundle the
  payload can be extracted with `typst eval` or `typst query`.
- `theme-ferris` and `theme-ferris-dark`: a warm Rust-orange preset with a
  neutral gray backdrop.

### Changed

- The minimum compiler is now Typst 0.15.0. In that target,
  `pdfpc-bundle-assets()` writes the speaker-note sidecar next to the PDF in a
  single bundle compile (`typst compile --features bundle --format bundle`);
  bundle export is experimental and unavailable in the web app.
- The footer no longer truncates: it shrinks its text toward
  `footer.min-text-size` and grows the band within `footer.max-lines`, and fails
  the build with a message instead of dropping information when it cannot fit.
- Header sizing now matches the footer, so the two bands scale together.
- Configuration dictionaries (`title-slide`, `footer`, `theme`) now reject
  unknown keys with a build error naming the key and listing the valid ones,
  instead of silently ignoring them.
- The theme accessors were renamed for a consistent `theme-*` namespace:
  `block-code-background` is now `theme-block-code-background`,
  `card-code-background` is now `theme-card-code-background`, and
  `header-dim-color` is now `theme-header-dim-color`.
- The example deck's cards slide now combines a warning block with numbered
  cards whose accent bars move between edges.

### Removed

- The top-level `theme-state` binding is no longer exported; read the live theme
  with `active-theme()` (or the `theme-color`, `theme-text` and `theme-box`
  helpers).
- The internal modules (`utils`, `layout`, `blocks`, `cards`, `notes`, `toc`)
  are no longer part of the public surface: `import ...: *` brings the
  documented API and the `themes` presets only.

### Fixed

- Section slide titles are no longer hyphenated or justified.
- Footer and bullet-point tracker misalignment.
- A `card-grid` `none` placed after cells with explicit coordinates no longer
  collides with them.
- Package hygiene: the template imports the registry path, and the README
  examples compile.

### Documentation

- Reworked the documentation into a short README and a `docs/` tree with guides
  for slides, content blocks, cards, themes, the header and footer, speaker
  notes, configuration, the API, development, upgrading, and troubleshooting.
- Replaced example names and organizations with neutral placeholders and
  refreshed the template PDF and screenshots.
- Documented combining cards with content blocks and refreshed the cards
  screenshot from the combined example.

## [0.3.0] - 2026-09-30

### Added

- Section subtitles, set through heading metadata or `section-slide`.
- A `section-slide: false` opt-out and per-section header labels.
- A bounded header: titles wrap to at most two lines and the tracker to three
  rows, so the slide body stays in place on every page.

### Changed

- Section heading metadata is parsed in one place.
- Table of contents and section slides use the full title, falling back to the
  header label for a titleless section.

### Fixed

- Section slide titles no longer hyphenated or justified.
- Footer and bullet-point tracker misalignment.

## [0.2.0] - 2026-05-09

### Added

- Improved table of contents.
- Heavily reworked slide styling.

### Fixed

- Spacing on slides without a title.

## [0.1.0] - 2025-11-27

### Added

- Initial release: title slide, navigation header with a progress tracker,
  interactive table of contents, three-column footer and nine styled content
  blocks.

[0.4.0]: https://github.com/Pepengu/pepentation/releases/tag/v0.4.0
[0.3.0]: https://github.com/Pepengu/pepentation/releases/tag/0.3.0
[0.2.0]: https://github.com/Pepengu/pepentation/releases/tag/0.2.0
[0.1.0]: https://github.com/Pepengu/pepentation/releases/tag/0.1.0
