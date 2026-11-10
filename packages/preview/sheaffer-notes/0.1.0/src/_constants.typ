/// Constant values.
///
/// To change these values, you are recommended to make your own fork of the
/// template.

/// Single spot-color accent, defined in RGB.
/// Adjust this value to change the accent throughout the template.
// Colorblindness general blue-orange pallete
#let BLUE = color.rgb("#07b")
#let ORANGE = color.rgb("#e73")
#let CYAN = color.rgb("#3be")
#let VERMILION = color.rgb("#c31")
#let GRAY = color.rgb("#eee")


#let ACCENT = ORANGE

/// Horizontal size of indentations.
#let INDENT = 1.4em

/// Spacing within paragraphs
#let LEADING = 0.6em + 1pt
/// Spacing between paragraphs
#let SPACING = LEADING

#let FONTS = (
  body: "STIX Two Text",
  heading: "Libertinus Serif",
  math: "Stix Two Math",
  code: "JetBrains Mono"
)

/// The `space` element type.
#let space = {
  [
    a
  ]
    .children
    .at(0)
    .func()
}
