#import "constants.typ": *

/// The main function for easy typography setup.
///
/// - body-size (): The size of body text (default 10pt).
/// - fonts (): A dictionary specifying heading/body fonts.
/// - paper (str): The paper size to use (none to skip).
/// - margin (): Margin for the page (none to skip).
/// -> content
#let easy-typography(
  body-size: 10pt,
  fonts: (heading: "Libertinus Sans", body: "Libertinus Serif"),
  paper: none,
  margin: none,
  body
) = {
  // Optional page setup
  if paper != none {
    set page(paper: paper)
  }
  if margin != none {
    set page(margin: margin)
  }

  // Paragraphs
  set par(
    leading: line-spacing * 0.5em,
    spacing: paragraph-spacing * 0.5em,
    justify: true,
    linebreaks: "optimized",
  )

  // Body text
  set text(
    font: fonts.body,
    fallback: false,
    style: "normal",
    weight: body-weight,
    stretch: 100%,
    size: body-size,
    tracking: 0pt,
    spacing: 100% + 0pt,
    baseline: 0pt,
    overhang: true,
    hyphenate: true,
    kerning: true,
    ligatures: true,
    number-width: "proportional",
    // number-type: "lining", // commented: intentionally left up to the font to choose
  )

  show table: set text(number-width: "tabular")

  /// Top-heavy easing function for heading sizes/spacing.
  ///
  /// `sqrt(t)` gives biggest decrease at top, gentlest at bottom.
  ///
  /// - max (length): Biggest size (H1)
  /// - min (length): Smallest size (H5)
  /// - level (length): From 1 to 5
  /// -> length
  let compute-size(max, min, level) = {
    if level <= 1 {
      max
    } else if level >= 5 {
      min
    } else {
      let t = (level - 1) / 4
      max - (max - min) * calc.sqrt(t)
    }
  }

  // Heading weight logic
  let compute-weight(level) = {
    if level <= 1 {
      "bold"
    } else if level == 2 {
      "semibold"
    } else if level == 3 {
      "medium"
    } else {
      "regular"
    }
  }

  // Show headings using computed size/spacing values
  show heading: it => block(
    breakable: false,
    sticky: true,
    above: compute-size(heading-above-max, heading-above-min, it.level),
    below: compute-size(heading-below-max, heading-below-min, it.level),
    text(
      font: fonts.heading,
      size: compute-size(heading-size-max, heading-size-min, it.level),
      weight: compute-weight(it.level),
      it
    )
  )

  // Finally, render the body
  body
}
