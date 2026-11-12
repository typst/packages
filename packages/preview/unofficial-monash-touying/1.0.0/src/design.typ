// Colour tokens (exported) and layout constants (internal).

#let monash-blue = rgb("#1969AA")
#let monash-blue-dark = rgb("#005C91")
#let monash-orange = rgb("#C14B14")
#let monash-orange-soft = rgb("#E7A385")
#let monash-charcoal = rgb("#111111")
#let monash-dark-grey = rgb("#646464")
#let monash-muted = rgb("#7F7F7F")
#let monash-slate = rgb("#505050")
#let monash-grey = rgb("#BFBFBF")
#let monash-grey-soft = rgb("#E7E7E7")
#let monash-grey-light = rgb("#F1F3F5")
#let monash-blue-wash = rgb("#EAF3FA")
#let monash-paper = rgb("#FFFFFF")
#let monash-green = rgb("#20794D")
#let monash-blue-grey = rgb("#557A95")
#let monash-teal = rgb("#007C89")

// Layout constants. Lengths that scale with the body size are factors of
// `font-size`; the rest are absolute.
#let page-margin-x = 1.0cm
#let bar-height-factor = 2.2 // single-line title bar height / font-size
#let bar-text-factor = 1.3 // title bar text size / font-size
#let bar-min-text-ratio = .75 // floor for shrinking a long slide heading
#let bar-gap-factor = .9 // space between title bar and body / font-size
#let footer-height-factor = 1.5 // bottom margin / font-size
#let progress-height = 2pt
#let frame-rule = 2.4pt

#let space-xs = .24em
#let space-sm = .42em
#let space-md = .72em

/// Draws a small Monash accent rule.
///
/// Use this for lightweight visual emphasis in custom slides when the full
/// frame environments are too heavy.
///
/// ```typst
/// #monash-accent-rule()
/// #monash-accent-rule(vertical: true, paint: monash-orange)
/// ```
#let monash-accent-rule(
  /// Rule width when `vertical` is `false`, or rule thickness when vertical.
  width: 4.7em,
  /// Rule height when `vertical` is `false`, or rule length when vertical.
  height: .14em,
  /// Rotate the rule into a vertical accent.
  vertical: false,
  /// Rule colour. Defaults to the primary Monash blue.
  paint: monash-blue,
) = rect(
  width: if vertical { height } else { width },
  height: if vertical { width } else { height },
  fill: paint,
  stroke: none,
)
