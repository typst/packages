#import "@preview/touying:0.7.4": *

// ===================================================================
// BYPST — BIPS PRESENTATION THEME
//
// A modern presentation template for BIPS using Typst and Touying
// https://github.com/bips-hb/bips-typst
//
// Entrypoint/orchestrator: imports and re-exports the submodules
// (config, helpers, slides, extras) and defines the bips-theme() function.
// ===================================================================

// Submodules use NAMED touying imports, so they no longer re-export touying's
// own `title-slide`/`empty-slide`. bypst's slide definitions are therefore the
// only ones in scope here and import order is not significant.
#import "config.typ": *
#import "helpers.typ": *
#import "extras.typ": *
#import "slides.typ": *

// ===================================================================
// MAIN THEME FUNCTION
// ===================================================================

#let bips-theme(
  aspect-ratio: "16-9",
  /// Logo image displayed in the top-right corner of content slides and on
  /// the thanks slide. Pass an `image()` call to override the default placeholder.
  /// Set to `none` to hide the logo entirely.
  logo: auto,
  // Title alignment inside the title area box (e.g. left, center, right)
  // Applies to the horizontal alignment of slide titles/subtitles.
  title-align: left,
  // Font family overrides (string or array of strings with fallbacks)
  font: none,
  code-font: none,
  math-font: none,
  // Global font size overrides (optional)
  base-size: none,
  slide-title-size: none,
  slide-subtitle-size: none,
  heading-1-size: none,
  heading-2-size: none,
  heading-3-size: none,
  page-number-size: none,
  code-block-scale: none,
  code-inline-scale: none,
  // Handout mode: collapse all pauses/uncover/only to final state,
  // emitting one page per slide (no incremental subslides).
  // `auto` (default) reads the `handout` CLI input flag
  // (`typst compile --input handout=true`); `true`/`false` override it.
  handout: auto,
  // Extra Touying config dicts (e.g. config-info(...), config-common(...),
  // config-page(...)) forwarded to touying-slides(). They deep-merge after
  // the theme's own config, so user values override on conflict. This is how
  // you set PDF metadata, enable pdfpc, presenter notes, appendix mode, etc.
  ..args,
  body,
) = {
  // Calculate effective font sizes (use override if provided, otherwise theme default)
  let effective-font-size-base = pick-first(base-size, font-size-base)
  let effective-code-block-scale = pick-first(
    code-block-scale,
    font-scale-code-block,
  )
  let effective-code-inline-scale = pick-first(
    code-inline-scale,
    font-scale-code-inline,
  ) // Resolve font families
  let effective-font = pick-first(font, font-family-text)
  let effective-code-font = pick-first(code-font, font-family-code)
  let effective-math-font = pick-first(math-font, font-family-math)
  // Handout: explicit true/false wins; `auto` falls back to the CLI input flag.
  let effective-handout = if handout == auto {
    sys.inputs.at("handout", default: "false") == "true"
  } else {
    handout
  } // Global text and styling configuration
  show: set text(
    font: effective-font,
    size: effective-font-size-base,
    fill: font-color-base,
  )
  show math.equation: set text(font: effective-math-font) // Heading styles use em-based defaults so they scale proportionally with base-size.
  // Explicit pt overrides take precedence over the em-based defaults.
  show heading.where(level: 1): set text(
    size: pick-first(heading-1-size, 1.11em),
    weight: heading-weight-1,
    fill: heading-color-1,
  )
  show heading.where(level: 2): set text(
    size: pick-first(heading-2-size, 1em),
    weight: heading-weight-2,
    fill: heading-color-2,
  )
  show heading.where(level: 3): set text(
    size: pick-first(heading-3-size, 1em),
    weight: heading-weight-3,
    fill: heading-color-3,
  )
  let effective-logo = if logo == auto { default-logo } else { logo }
  // Emphasis (_text_) in BIPS blue (color only, no italic)
  show emph: it => text(
    fill: font-color-emphasis,
    style: "italic",
    weight: "regular",
  )[#it.body] // Strong text (*text*) in BIPS blue (color only, no bold)
  show strong: it => text(fill: font-color-strong, weight: "bold")[#it.body] // Links in BIPS blue with thin underline to distinguish from emphasis
  show link: it => underline(text(fill: bips-blue)[#it]) // Table styling - set elegant defaults
  set table(
    stroke: none,
    fill: (_, y) => if y == 0 { bips-blue.lighten(85%) } else { none },
    inset: (x: 0.7em, y: 0.6em),
  ) // Add subtle borders around tables
  show table: it => block(
    stroke: (
      top: 1pt + bips-blue.lighten(50%),
      bottom: 1pt + bips-blue.lighten(50%),
    ),
    inset: 0pt,
    it,
  ) // List styling with configurable spacing
  // Spacing uses `set` (not `show`) so users can override with local `#set list(spacing: ...)`
  set list(spacing: list-spacing)
  set enum(spacing: enum-spacing)
  // top-edge/bottom-edge ensure consistent line metrics so bullet markers
  // stay aligned with text even when emojis or other tall glyphs are present.
  // Tighter par leading compensates for the taller ascender line height on line breaks within items.
  show list: set text(
    fill: font-color-base,
    top-edge: "ascender",
    bottom-edge: "descender",
  )
  show list: set par(leading: 0.4em)
  // Nested lists/enums get tighter spacing (including cross-type nesting)
  show list: it => {
    show list: set list(spacing: 0.4em)
    show enum: set enum(spacing: 0.4em)
    it
  }
  show enum: set text(
    fill: font-color-base,
    top-edge: "ascender",
    bottom-edge: "descender",
    // Tabular figures keep the marker gutter a fixed width. With Fira Sans's
    // proportional digits the gutter is sized to the widest marker, so a list
    // revealed item-by-item (Touying #pause) shifts "1." right as "2."/"3."
    // appear. Equal-width digits pin the marker in place.
    number-width: "tabular",
  )
  show enum: set par(leading: 0.4em)
  show enum: it => {
    show enum: set enum(spacing: 0.4em)
    show list: set list(spacing: 0.4em)
    it
  } // Code styling - Fira Mono pairs with Fira Sans for consistent metrics
  show raw: set text(font: effective-code-font)
  show raw.where(block: true): set text(size: effective-code-block-scale * 1em)
  show raw.where(block: false): set text(
    size: effective-code-inline-scale * 1em,
  )
  // Use Touying's infrastructure with BIPS customizations. config-info(...)
  // dicts in ..args.pos() flow into self.info natively (read by title-slide);
  // config-store(...) publishes sizes/align/logo into self.store for the slides.
  touying-slides(
    config-common(handout: effective-handout),
    config-store(
      slide-title: pick-first(slide-title-size, font-size-slide-title),
      slide-title-only: font-size-slide-title-only,
      slide-subtitle: pick-first(slide-subtitle-size, font-size-slide-subtitle),
      page-number: pick-first(page-number-size, font-size-page-number),
      title-align: title-align,
      logo: effective-logo,
    ),
    config-page(
      ..utils.page-args-from-aspect-ratio(aspect-ratio),
      margin: (top: 1.55cm, bottom: 1.55cm, left: 1.55cm, right: 1.75cm),
      background: bips-background(logo: effective-logo, show-logo: true),
    ),
    // User-supplied config dicts override the above via Touying's deep merge.
    ..args.pos(),
    body,
  )
}
