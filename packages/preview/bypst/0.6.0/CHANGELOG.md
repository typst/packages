# Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [0.6.0] - October 2026

### Added

- `lang` parameter on `bips-theme()` (default `auto`) plus German translations of every string the theme renders itself: the thank-you line, the contact block heading, the references slide title, and the institution name. With `auto` the theme follows the document's `text.lang`, so `#set text(lang: "de")` alone now yields a fully German deck; passing `lang:` explicitly sets `text.lang` too, so the theme's strings and Typst's built-in ones (figure supplements, quotation marks, hyphenation, bibliography terms) can never disagree. Unsupported languages fall back to English.
- `thanks-slide()` gained `contact-title`, `institution`, `address` and `website` parameters. The contact block was previously hardcoded to BIPS's English name and Bremen address with no way to change it; all four now default to the language-appropriate BIPS values.
- `gallery/german.typ`: a German-language deck showing that one `#set text(lang: "de")` localizes Typst's output and the theme's chrome together.
- `gallery/knitr.Rtyp`: R code chunks, inline R results, figures and tables in a bips deck via knitr's `.Rtyp` format (knitr >= 1.52). Build with `just knitr`.
- `callout-icons` parameter on `bips-theme()`: `"symbol"` (default), `"emoji"`, `"drawn"` (font-independent shapes) or `none`.
- `#card()`: a titled content box: a solid title bar over a shaded body, in the spirit of a Beamer theorem block. For framing a definition, a result, or an aside that wants more weight than a `#callout()` and no icon. `color:` sets the bar and, unless `fill:` overrides it, a light tint of the same color for the body; `title-color:`, `radius:`, `width:` and `inset:` are available for the rest. Without `title:` it degrades to a plain shaded panel.

### Changed

- Body text font fallback is now Arial, then DejaVu Sans (was Noto Sans), so decks without Fira Sans render in a sans-serif font on Windows, macOS and Linux instead of falling through to Typst's built-in serif.
- README lists the exact Fira font files the theme uses and how to point Typst at them; `just fonts [dir]` downloads them.
- **Breaking:** slide functions now reject unknown named arguments with an error naming them (e.g. `title-slide: unexpected argument: institute`). Previously a typo or a renamed parameter was silently ignored. `bips-slide()` and `empty-slide()` report it as `base-slide`. Remove or rename the argument at the call site.
- **Touying 0.7.4 → 0.8.0.** No API changes in bypst; every slide type, gallery deck, and test compiles and renders identically. Typst floor is unchanged (0.15.0 — Touying 0.8.0 requires exactly that).
- **Breaking (Touying, affects your decks):** a `#pause` following `#uncover`/`#only`/`#alternatives` no longer skips the subslides those reserve. `#uncover("2")[..] one #pause two` now produces 2 subslides, not 3. Add an explicit `#pause` (or a `#waypoint`) where you relied on the old snap. No bypst slide type or gallery deck depended on it.
- Term lists (`/ Term: definition`) now use the same line metrics and item spacing as bullet and numbered lists. Previously they inherited Typst defaults and rendered roughly half an em tighter per row than the surrounding lists. `#compact[]` and nesting inside a list/enum tighten them alongside the other list types.
- Block quotes (`#quote(block: true)`) now carry a thin left rule in the same light blue as table borders, with the attribution set small and blue below. Typst's default renders a block quote flush left with no marker, so it read as ordinary body text. `#callout()` keeps the heavier 4pt rule plus fill, so the two stay tellable apart. Inline quotes are untouched.
- Figure captions are set at `caption-scale` (0.8) of the surrounding text size instead of full body size. Relative, so `#small[]` and a changed `base-size` both carry through.
- Package templates: `basic` reads its title fields from `config-info()` and shows a reveal and a callout; `complete` now tours the theme's features (cards, callouts, citations with a bundled `references.bib`, styled tables, figures and quotes, composer panes, progress bar, references and thanks slides).

### Fixed

- Callout icons no longer need an emoji font. The default is now Unicode symbols (ℹ ✓ ⚠ ‼) that Typst's bundled fonts always cover, drawn in the callout's colour; the emoji, which rendered as empty boxes without an emoji font and ignored the colour, are opt-in.
- The `basic` package template passed `institute:` to `title-slide()`, a parameter renamed to `institution:` in 0.5.0. It was silently ignored, so editing it had no effect.
- Speaker-note second-screen output (`config-common(show-notes-on-second-screen: right)`) now renders the BIPS logo and confines the slide background to the slide half. Touying 0.7.x placed the page background/foreground across the full spread, which clipped the logo away.

## [0.5.0] - September 2026

### Added

- `footnote-scale` parameter on `bips-theme()` to size footnote text as a fraction of the base body size (default `0.8`, a small reduction from Typst's ~0.85 default). Scales with `base-size`; applies to all footnotes including `footcite`.
- Citation helpers wrapping `cite()`: `#citet()` (textual "Author (Year)"), `#citep()` (parenthetical), `#sideref()` (small, right-aligned side citation), and `#footcite()` (footnote-area citation). natbib-style convenience for the LaTeX crowd.
- `#callout()` shorthands `#callout-note()`, `#callout-tip()`, `#callout-warning()`, and `#callout-important()` for the corresponding callout types (each forwards `title:` and the body to `callout(type: ...)`).
- `progress-bar` parameter on `bips-theme()` (default `false`) rendering a full-bleed BIPS-blue progress bar at the bottom page edge, filling as the deck advances. Shown only on counted content slides, so title, section, thanks, and uncounted `empty-slide`s stay clean. Override per slide with `base-slide(progress-bar: false)` (or `bips-slide(progress-bar: false)`); `progress-bar: true` is a no-op unless the slide is also counted (`count: true`).
- Three annotated gallery decks: `typst-basics` (Typst syntax for Beamer refugees), `diagrams` (cetz + fletcher), and `dataviz` (gribouille). Each is a self-documenting deck showing the theme alongside the wider Typst ecosystem.

### Changed

- **Breaking:** raised the minimum supported Typst version to 0.15.0 (from 0.13.0). Typst ships as a self-contained static binary and does not backport fixes to superseded minors, so tracking the current release keeps the theme and its gallery dependencies on maintained versions. Update with your usual installer, or grab a binary from [the Typst releases page](https://github.com/typst/typst/releases).
- Default `#callout()` (no `type:`) now renders as a neutral shaded box (light gray background, blue left accent, no icon) instead of mirroring the `note` styling.
- **Breaking:** `title-slide()` parameters `institute`/`institutes`/`institute-size` renamed to `institution`/`institutions`/`institution-size`, matching Touying's `config-info(institution: ...)` key (removing the institute-vs-institution ambiguity). Rectify by renaming the arguments at the call site.
- `institution` now defaults to the BIPS English name (`bips-en`) for the whole document, since the theme is institution-specific; `title-slide()` shows it with no setup. Override via `config-info(institution: ...)` (e.g. `bips-de`) or the `title-slide(institution: ...)` argument.

## 0.4.0

### Added
- `base-slide()` — the flexible base content slide: title/subtitle in a native Touying header block over a native body, with every BIPS chrome component independently toggleable (`show-logo`, `page-number`, `show-line`, `count`). `bips-slide` and `empty-slide` are presets over it. Use `base-slide` directly when you need a chrome combination the presets don't cover
- `empty-slide()` gained `show-logo` and `page-number` toggles, so a minimal slide can still carry the logo and/or a page number (the number defaults to following `count`)
- `bips-theme()` now forwards arbitrary Touying config dicts via `..args`, so `#show: bips-theme.with(config-info(...), config-common(...), config-page(...))` works. This unlocks Touying capabilities the theme previously hid: PDF document metadata, pdfpc export, presenter notes (`show-notes-on-second-screen`), appendix mode, and extra page overrides. User config deep-merges after the theme's own config, so it wins on conflict
- `title-slide()` fields (`title`, `subtitle`, `author`, `date`, `institute`) now fall back to the theme's `config-info(...)` when not passed explicitly, so a single `config-info()` populates both the PDF metadata and the title slide. Explicit `title-slide()` arguments still override
- `title-slide()`, `section-slide()`, `thanks-slide()`, and `empty-slide()` now forward Touying `slide()` overrides (`config`, `repeat`, and `setting` where the slide doesn't own its layout), matching `bips-slide()`. This makes the non-content slide types fully composable — e.g. a full-bleed background on `empty-slide` via `config: config-page(fill: ...)`, or animation steps via `repeat:` + `#only`/`#uncover`. Slide-specific config deep-merges over the theme's defaults
- `empty-slide()` accepts a `composer` (e.g. `composer: (1fr, 1fr)`) with multiple trailing content blocks for full-bleed multi-pane layouts, where animations split correctly across panes (`content-align` is ignored in this mode, since the composer owns the layout)
- `bibliography-slide()` can now build the bibliography itself: pass the `.bib` file via `bib: read("references.bib")` plus optional `style`/`full`, instead of wrapping a manual `#bibliography(...)` call. Use `read()` rather than a bare path — `bibliography()` resolves paths relative to where it is called (inside the package), but `read()` runs in your document so its path resolves there; the slide accepts the resulting string (or bytes) and forwards it. `style` defaults to `"springer-basic-author-date"` (override per call, or `auto` for Typst's built-in default), and the bibliography's own heading is suppressed by default (`bib-title: none`) since the slide already has a "References" title. Passing pre-built content as a trailing block still works
- `empty-slide()` now accepts a `content-align` argument (matching `bips-slide()`), so content can be centered/bottom-aligned without a manual `#align` wrapper
- `section-slide()` now accepts optional trailing content (e.g. `#section-slide("Paper 1")[Full descriptive title]`) shown centered below the section title at normal text size; the title alone remains the PDF outline entry
- `handout` parameter on `bips-theme()` (default `auto`) that forwards to Touying's `config-common(handout: ...)`, collapsing all `#pause`/`#uncover`/`#only` steps into a compact one-page-per-slide PDF. With the default `auto`, the theme watches the `handout` CLI input flag, so `typst compile --input handout=true` builds a handout from the same source with no document changes. Set `handout: true`/`false` explicitly in `bips-theme()` to override the flag

### Changed
- `bips-slide()` is now a preset over `base-slide()` (native-body model). Its public signature is unchanged, but the body is now native Touying content, so `#pause`, `composer`, and multi-block bodies work directly in `bips-slide`. Overlong titles now shrink to fit the header box so the divider line stays at a static position
- Slide header alignment polished: the logo sits closer to the top-right corner (0.5cm inset, matching the BIPS beamer template) and the gradient divider line now lands flush with the logo's lower edge. The page number is centered under the logo, just below it (clear of the content area), with a small conservative gap separating the divider from the body. The title and subtitle are spaced to read as a balanced unit (the title-to-subtitle gap matched against the subtitle-to-divider gap); a lone title is vertically centered in the header area while a title+subtitle stack is bottom-aligned above the divider.
- Internals refactored to idiomatic Touying: all slide functions are now `touying-slide-wrapper` functions reading `self.store`/`self.info` instead of hand-rolled module `state()` bridges (`_bips-sizes`, `_bips-info`, `_bips-logo`). No change to the public API beyond the removals below.
- `small`/`tiny`/`large`/`huge` text helpers are now em-relative, so they scale with `base-size` and any surrounding text size.
- Submodules use named Touying imports; bypst no longer re-exports Touying's own `title-slide`/`empty-slide`, removing the previous import-order requirement.

### Removed
- `bips-theme` parameters `small-size`, `tiny-size`, `large-size`, `huge-size` (the size helpers are now em-relative; use `base-size` to scale, or wrap content in an explicit `text(size: ...)`).

### Fixed
- Enum markers no longer shift horizontally when a list is revealed item-by-item with `#pause`. Fira Sans uses proportional figures, so the marker gutter (right-aligned by Typst's default `number-align: end`) widened as `2.`/`3.` appeared, nudging `1.` rightward across reveal steps; enum text now uses tabular figures (`number-width: "tabular"`) to keep the gutter a fixed width

## [0.3.0] - May 2026

### Added
- `show-line` parameter on `bips-slide()` to hide the gradient separator under the title while keeping the slide counter running, useful for full-bleed or transparent graphics (contributed by @rforaita)
- `count` parameter on `empty-slide()` to keep a chrome-free slide in the numbered sequence and show its page number (default `false` preserves the unnumbered behavior), useful for a full-bleed figure that should still count as a slide

## [0.2.0] - April 2026

### Added
- `title-align` parameter on `bips-theme()` for horizontal alignment of slide titles (left, center, right)
- `base-size` parameter on `bips-theme()` to scale all text proportionally; headings, page numbers, `#small[]`, and `#tiny[]` adjust automatically via em-based sizing
- Size override parameters on `bips-theme()`: `slide-title-size`, `slide-subtitle-size`, `heading-1-size`, `heading-2-size`, `heading-3-size`, `page-number-size`, `small-size`, `tiny-size`
- `#huge[]`, `#large[]`, `#small[]`, and `#tiny[]` text size utility functions that scale proportionally with `base-size`
- `#compact[]` utility for tighter list/enum spacing (applies recursively to nested lists)
- `#vfill` shorthand (equivalent to `#v(1fr)`)
- Color helpers: `#blue[]`, `#orange[]`, `#green[]`, `#gray[]`
- `callout()` blocks with types note, tip, warning, important and optional `title:` parameter
- `two-columns[][]` and `three-columns[][][]` layout helpers with customizable widths and gutter
- `content-align` parameter on `bips-slide()` for body content alignment (e.g. `center + horizon`)
- Per-slide overrides: `text-size`, `title-size`, `subtitle-size`, `code-block-scale`, `code-inline-scale` on `bips-slide()`
- Code scaling parameters `code-block-scale` and `code-inline-scale` on `bips-theme()`
- Heading show rules for levels 1, 2, and 3 in BIPS blue with em-based sizing (1.11em, 1em, 0.89em)
- `bibliography-slide()` for reference lists
- `empty-slide[]` for minimal slides without branding
- tytanic test suite with 10 compile-only tests covering all slide types and features
- typstyle formatting for consistent code style
- GitHub Actions workflow to compile gallery demos and deploy previews to GitHub Pages

### Changed
- Renamed built-in institute name variables to kebab case for consistency: `bips_en` -> `bips-en`, `bips_de` -> `bips-de`.
- **Upgraded Touying from 0.6.1 to 0.7.0** with new API for aspect ratios, config parameters, and page setup
- Page numbers use Touying's logical slide counter rendered in slide content via `place()`, fixing off-by-one errors on animated slides
- Slides without page numbers (`title-slide`, `section-slide`, `thanks-slide`, `empty-slide`) freeze the slide counter so numbering is sequential without gaps
- Page background overrides use `config: config-page(...)` instead of `set page()` in `setting:` callbacks (Touying 0.7.0 requirement)
- Aspect ratio uses `utils.page-args-from-aspect-ratio()` instead of `paper: "presentation-..."`
- Font size overrides use a state bridge (`_bips-sizes`) to pass computed values from `bips-theme()` to slide functions
- `thanks-slide` uses the `setting:` callback pattern consistently with other slide types
- `empty-slide` simplified from variadic `..content` to single `body` parameter
- `title-slide` no longer redundantly re-sets the page background
- **Renamed package from `bips-typst` to `bypst`** for Typst Universe naming compliance
- Multi-author title slides separate names with horizontal space instead of commas
- Gallery condensed from 13 demos to 5 focused examples (basic, complete, bibliography, aspect-ratio, lecture-demo)
- Emphasis (`_text_`) renders as blue italic; strong (`*text*`) renders as blue bold
- List/enum styling uses ascender/descender edges for consistent bullet alignment
- Nested lists use tighter spacing
- Gallery and test files use relative imports instead of versioned `@local` imports

### Removed
- Dead `show-page-number` parameter from `section-slide` (was accepted but silently ignored)
- Unused typography variables: `font-weight-base`, `font-color-small`, `font-weight-small`, `font-color-tiny`, `font-weight-tiny`, `font-size-heading-*`
- 8 redundant gallery demos (animations, callouts, columns, content-elements, customization, font-customization, multi-author, qr-code) — all covered by `complete.typ`

### Fixed
- Size override parameters in `bips-theme()` were silently ignored — now functional
- Heading levels 1–3 had no styling (rendered as default black text) — now styled globally with BIPS blue (h1/h2) and gray (h3)
- Page numbers remain stable across `#pause` subslides
- Content overflow on animated slides no longer creates blank pages for all subslides

## [0.1.1] - 2025

### Changed
- Restructured project layout: moved theme files from `lib/` to project root
- Improved slide number logic to handle presentations with or without title slide
- Expanded and consolidated test suite into single `test-suite.typ`

### Fixed
- Slide counter properly adjusts numbering based on title slide presence

## [0.1.0] - 2025

### Added
- Initial release of BIPS Typst presentation template
- Core slide types: title-slide, bips-slide, section-slide, thanks-slide, empty-slide
- Multi-author support with institute affiliations via `inst()`
- QR code generation for contact slides via codetastic
- Animation support via Touying (`#pause`, `#uncover`, `#only`, `#alternatives`, `#meanwhile`)
- Bibliography slide helper
- Customizable font sizes and styling
- BIPS branding (colors, logo, Fira Sans / Fira Mono fonts)
- 16:9 and 4:3 aspect ratio support
- Gallery of example presentations
- Test suite for validation

[0.6.0]: https://github.com/bips-hb/bips-typst/compare/v0.5.0...HEAD
[0.5.0]: https://github.com/bips-hb/bips-typst/compare/v0.4.0...v0.5.0
[0.4.0]: https://github.com/bips-hb/bips-typst/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/bips-hb/bips-typst/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/bips-hb/bips-typst/compare/v0.1.1...v0.2.0
[0.1.1]: https://github.com/bips-hb/bips-typst/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/bips-hb/bips-typst/releases/tag/v0.1.0
