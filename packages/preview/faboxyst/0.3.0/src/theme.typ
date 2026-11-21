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

// --- the antique vintage palette & fonts (src/antique.typ) ----------------
#import "antique.typ": antique-palette as _antique-palette, antique-fonts as _antique-fonts

// --- font stacks -----------------------------------------------------------
// Latin first, then Arabic, then a generic fallback. Typst picks per script.
#let fonts = (
  body:    ("xkcd Script", "Tajawal", "DejaVu Sans"),
  heading: ("Libertinus Serif", "Lalezar", "xkcd Script", "DejaVu Sans"),
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

/// Convert a shadow paint to grayscale without changing its relative tone.
/// Structured gradient-shadow dictionaries keep their modes and opacity logic.
#let grayscale-paint(paint, fallback: luma(120)) = {
  if paint == auto { fallback }
  else if type(paint) == color { luma(paint) }
  else if type(paint) == dictionary {
    let mono = paint
    for (key, value) in paint.pairs() {
      if type(value) == color { mono.insert(key, luma(value)) }
    }
    mono
  } else { paint }
}

// --- the default theme -----------------------------------------------------
#let default-theme = (
  // colours
  palette: palette,
  accent: palette.pink,          // default block colour
  ink: palette.ink,
  paper: palette.paper,
  mode: "normal",             // normal | print

  // typography
  fonts: fonts,
  size: 10.5pt,
  leading: 0.65em,

  // sketchiness
  roughness: 1.0,                // multiplies every wobble amplitude
  rough: auto,                   // fabox & co.: true/false, or auto = hand-drawn when `roughness` was set explicitly (> 0)
  roughness-set: false,          // true once the user gave `roughness` (make-theme / faboxyst.with)
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

  // Blockst's print convention: every primary surface white, every rule and
  // label black; secondary inset/details use #e0e0e0. Keep geometry intact.
  print: default-theme + (
    mode: "print",
    accent: white,
    ink: black,
    paper: white,
    palette: palette + (
      ink: black, paper: white, rule: luma(224), margin: luma(224),
      grid: luma(224), cream: white, cream-edge: black,
      pink: white, sky: white, lime: white, gold: white, orchid: white,
      red: white, navy: white, green: white, orange: white, cyan: white,
      hilite: luma(224), pltblue: white,
    ),
    roughness: 0.0,
    stroke-weight: 1.2pt,
  ),

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

  // The "antique" vintage effect:
  // aged paper, sepia ink, a Garamond serif and thin, nearly-straight
  // engraved strokes. Pairs with plate-page / patent-page / engraved-frame.
  antique: default-theme + (
    palette: palette + (
      ink: _antique-palette.ink,
      paper: _antique-palette.paper,
      rule: rgb("#D9CDB2"),
      margin: rgb("#C39B8B"),
      grid: rgb("#DFD4BB"),
      cream: _antique-palette.paper,
      cream-edge: rgb("#E3D8C0"),
      pink: rgb("#BF8578"),
      sky: rgb("#8CA6A8"),
      lime: rgb("#A9A26B"),
      gold: rgb("#C09A4E"),
      orchid: rgb("#A58CA4"),
      red: rgb("#A5402F"),
      navy: rgb("#3E5C6E"),
      green: rgb("#5E7251"),
      orange: rgb("#B5723E"),
      cyan: rgb("#7E9CA5"),
      hilite: rgb("#E9DAA2"),
      pltblue: rgb("#4A6572"),
    ),
    ink: _antique-palette.ink,
    paper: _antique-palette.paper,
    accent: _antique-palette.pale-ink,
    fonts: _antique-fonts,
    roughness: 0.35,
    stroke-weight: 1.1pt,
  ),
)

// --- state so blocks can read the active theme -----------------------------
#let theme-state = state("sketchbook-theme", default-theme)
#let counter-state = state("sketchbook-seed", 0)

/// Read the active theme inside a `context`.
#let get-theme() = theme-state.get()

/// Whether the active document uses the monochrome print treatment.
#let is-print() = theme-state.get().mode == "print"

/// Blockst-compatible print inks: white surface, black rule/text, pale inset.
#let print-colours = (surface: white, ink: black, secondary: luma(224))

/// Merge user overrides over a base theme.
#let make-theme(base: default-theme, ..over) = {
  let o = over.named()
  base + o + (if "roughness" in o { (roughness-set: true) } else { (:) })
}
