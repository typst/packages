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

#let monash-page-margin-x = 1.0cm
#let monash-page-margin-top = 1.0cm
#let monash-page-margin-bottom = .1cm
#let monash-title-bar-height = 1.7cm
#let monash-footer-height = .18cm

#let monash-space-xs = .24em
#let monash-space-sm = .42em
#let monash-space-md = .72em
#let monash-space-lg = 1.05em
#let monash-space-xl = 1.55em
#let monash-space-2xl = 2.25em

#let monash-body-size = 22pt
#let monash-title-font-size = 36pt
#let monash-cover-title-size = 36pt
#let monash-title-bar-font-size = 1.3em
#let monash-heading-three-size = .86em
#let monash-footer-size = .5em
#let monash-logo-cover-height = 1.25em
#let monash-logo-content-height = 1.25em

#let monash-rule-thin = 2pt
#let monash-frame-rule = 2.4pt

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
