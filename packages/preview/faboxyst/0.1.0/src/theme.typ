// ===========================================================================
//  sketchbook/theme.typ — palettes, fonts and global configuration.
//
//  Everything the blocks draw reads from a single theme dictionary, so a book
//  can be restyled from one place:
//
//    #show: sketchbook.with(theme: sketchbook.themes.blueprint)
//    #show: sketchbook.with(theme: (accent: red, roughness: 1.4))
// ===========================================================================

// --- the palette used by the reference artwork -----------------------------
#let palette = (
  ink:      rgb("#231F20"),
  paper:    rgb("#FFFFFF"),
  rule:     rgb("#B2E6FA"),
  margin:   rgb("#F9ABD9"),
  grid:     rgb("#D1EED1"),
  cream:    rgb("#F7F6EF"),
  cream-edge: rgb("#E6E3D8"),

  pink:     rgb("#F799D1"),
  sky:      rgb("#8CDAF8"),
  lime:     rgb("#BFDF14"),
  gold:     rgb("#FBC707"),
  orchid:   rgb("#D8AFDC"),
  red:      rgb("#ED1C24"),
  navy:     rgb("#1E5CB3"),
  green:    rgb("#00A14B"),
  orange:   rgb("#F05800"),
  cyan:     rgb("#33BDF2"),
  hilite:   rgb("#FFF421"),
  pltblue:  rgb("#1F77B4"),
)

// --- font stacks -----------------------------------------------------------
// Latin first, then Arabic, then a generic fallback. Typst picks per script.
#let fonts = (
  body:    ("xkcd Script", "Tajawal", "DejaVu Sans"),
  heading: ("Bevan", "Lalezar", "xkcd Script", "DejaVu Sans"),
  bubble:  ("Comic Neue", "Lalezar", "xkcd Script", "DejaVu Sans"),
  mono:    ("DejaVu Sans Mono",),
  // A LIST, not a single family: the zip ships without fonts-emoji/, and a
  // bare "Noto Color Emoji" makes every icon warn and fall back to tofu.
  // With DejaVu behind it, the substituted glyphs (\u{270E}, \u{2605}, ...)
  // resolve and only real emoji are missing.
  emoji:   ("Noto Color Emoji", "DejaVu Sans"),
)

// Lalezar (the Arabic display face) has no bold cut: asking for one makes
// Typst silently substitute a different family.
#let heading-weight(dir) = if dir == rtl { "regular" } else { "bold" }

// --- the default theme -----------------------------------------------------
#let default-theme = (
  // colours
  palette: palette,
  accent: palette.pink,          // default block colour
  ink: palette.ink,
  paper: palette.paper,

  // typography
  fonts: fonts,
  size: 10.5pt,
  leading: 0.65em,

  // sketchiness
  roughness: 1.0,                // multiplies every wobble amplitude
  seed: 1,                       // base seed for the whole document
  stroke-weight: 1.6pt,

  // geometry defaults, in pt so they scale with the text
  pad: 9pt,                      // inner padding of blocks
  radius: 0.30,                  // corner radius, in cm
  gap: 8pt,                      // vertical gap after a block

  // direction
  dir: ltr,
  lang: "en",

  // page decoration
  rules: false,                  // ruled-paper background
  rule-spacing: auto,            // auto = follow par(leading) exactly
  rule-weight: 0.8pt,
  rule-bleed: true,              // rules run to the paper edge
  margin-rule: false,
)

// --- ready-made variants ---------------------------------------------------
#let themes = (
  notebook: default-theme,

  blueprint: default-theme + (
    accent: palette.cyan,
    ink: rgb("#0B3C5D"),
    rules: true,
    palette: palette + (rule: rgb("#CFE8F5")),
  ),

  bold: default-theme + (
    accent: palette.lime,
    roughness: 1.6,
    stroke-weight: 2.4pt,
  ),

  quiet: default-theme + (
    accent: luma(120),
    roughness: 0.55,
    stroke-weight: 1.1pt,
  ),

  arabic: default-theme + (
    dir: rtl,
    lang: "ar",
    fonts: fonts + (body: ("Tajawal", "xkcd Script", "DejaVu Sans")),
  ),
)

// --- state so blocks can read the active theme -----------------------------
#let theme-state = state("sketchbook-theme", default-theme)
#let counter-state = state("sketchbook-seed", 0)

/// Read the active theme inside a `context`.
#let get-theme() = theme-state.get()

/// Merge user overrides over a base theme.
#let make-theme(base: default-theme, ..over) = base + over.named()
