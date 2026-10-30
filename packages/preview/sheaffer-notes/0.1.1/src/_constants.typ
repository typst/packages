/// Constant values.
///
/// Colors and fonts are re-exported from `lib.typ` and can be used from the
/// document directly; fonts are overridden with `#show: style.with(fonts: ..)`.
/// To change the remaining values, you are recommended to make your own fork
/// of the template.

/// Public palette, defined in RGB.
///
/// Re-exported from `lib.typ`, so it can be used anywhere in the document:
/// `#text(fill: BLUE)[...]`, `#wrappar(color: BLUE)[...]`.
///
/// Colorblindness-friendly blue-orange palette.
/// Bright blue.
#let BLUE = color.rgb("#07b")
/// Orange.
#let ORANGE = color.rgb("#e73")
/// Cyan.
#let CYAN = color.rgb("#3be")
/// Vermilion.
#let VERMILION = color.rgb("#c31")
/// Light gray, used as the background of code blocks.
#let GRAY = color.rgb("#eee")


/// Accent color used by headings, links and reference numbers.
#let ACCENT = ORANGE

/// Horizontal size of indentations.
#let INDENT = 1.4em

/// How far the page header sits below the vertical center of the top margin.
/// Bigger values move the header further from the top edge of the page.
#let HEADER-DY = 3mm

/// Spacing within paragraphs
#let LEADING = 0.55em + 1pt
/// Spacing between paragraphs
#let SPACING = 0.4em + 1pt

/// Fonts used by `style`. Override them with
/// `#show: style.with(fonts: (...))` instead of editing this file.
#let FONTS = (
  body: "New Computer Modern",
  heading: "New Computer Modern",
  math: "New Computer Modern Math",
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
