/**
 * Main layout and styling configuration for the template
 *
 * @author Tom Planche
 * @license MIT
 */

#import "@preview/i-figured:0.2.4"
#import "@preview/great-theorems:0.1.2": *
#import "headers.typ": get-header
#import "utils.typ": date-format

// Global font size setting
#let body-font-size = 12pt

/**
 * Apply document styling and layout configuration.
 *
 * @param primary-color - The primary theme color
 * @param secondary-color - The secondary theme color
 * @param body-font - The body font family
 * @param title-font - The title/heading font family
 * @param author - The document author
 * @param color-words - Array of words to highlight with primary color
 * @param show-secondary-header - Whether to show secondary headers (with sub-heading)
 * @param body - The document content
 */
#let apply-styling(
  primary-color,
  secondary-color,
  body-font,
  title-font,
  author,
  color-words,
  show-secondary-header,
  body
) = {
  // Main document settings
  set page(
    header-ascent: 50%,
    footer-descent: 50%,
    margin: (
        top: 3cm,
        right: 1cm,
        bottom: 1.75cm,
        left: 1cm
    ),
    numbering: "1 / 1",
    number-align: bottom + right,
  )

  show: great-theorems-init

  // Typography settings
  set par(justify: true)
  set text(font: body-font, size: body-font-size)

  // Figure customization
  set figure.caption(separator: [ --- ], position: top)

  // Headings styling
  show heading: set text(font: title-font, fill: primary-color)

  // Heading numbering
  set heading(numbering: (..nums) => {
    let level = nums.pos().len()

    let pattern = if level == 1 {
      "I -"
    } else if level == 2 {
      "  I. I -"
    } else if level == 3 {
      "    I. I .I -"
    } else if level == 4 {
      "     I. I. I. 1 -"
    }

    if pattern != none {
      numbering(pattern, ..nums)
    }
  })

  // Heading spacing
  show heading: it => it + v(.5em)

  // Link styling
  show link: it => underline(text(fill: primary-color, it))

  // List styling
  set enum(indent: 1em, numbering: n => [#text(fill: primary-color, numbering("1.", n))])
  set list(indent: 1em, marker: n => [#text(fill: primary-color, "•")])

  // Math equation configuration
  show heading: i-figured.reset-counters
  show math.equation: i-figured.show-equation.with(
    level: 3,
    zero-fill: false,
    leading-zero: true,
    numbering: "(1.1)",
    prefix: "eqt:",
    only-labeled: false,
    unnumbered-label: "-",
  )
  set math.equation(number-align: bottom)

  // Text highlighting for specific words
  show regex(if color-words.len() == 0 { "$ " } else { color-words.join("|") }): text.with(fill: primary-color)

  // Inline code styling
  let side-padding = .35em;
  show raw.where(block: false) : it => h(side-padding) + box(fill: primary-color.lighten(90%), outset: (x: .25em, y: .5em), radius: 2pt, it) + h(side-padding)

  // Outline styling
  show outline.entry: it => text(size: 12pt, weight: "regular", it)

  // Set header after initial pages
  set page(header: get-header(author: author, show-secondary-header: show-secondary-header))

  body
}

/**
 * Create decorative elements for the document.
 *
 * @param primary-color - The primary color for decorations
 * @param secondary-color - The secondary color for decorations
 */
#let add-decorations(primary-color, secondary-color) = {
  // Top left decoration
  place(top + left, dx: -25%, dy: -28%, circle(radius: 150pt, fill: primary-color))
  place(top + left, circle(radius: 75pt, fill: secondary-color))

  // Bottom right decoration
  place(bottom + right, dx: 25%, dy: 25%, circle(radius: 100pt, fill: secondary-color))
}

/**
 * Create the title page layout.
 *
 * @param title - The document title
 * @param subtitle - The document subtitle
 * @param author - The author name
 * @param affiliation - The author's affiliation
 * @param class - The class/course name
 * @param start-date - The document start date
 * @param last-updated-date - The last updated date
 * @param year - The year for school year calculation
 * @param primary-color - The primary theme color
 * @param title-font - The font for titles
 * @param logo - Optional logo to display
 * @param outline-code - Custom outline code (none for default, false to disable, or custom content)
 */
#let create-title-page(
  title,
  subtitle,
  author,
  affiliation,
  class,
  start-date,
  last-updated-date,
  year,
  primary-color,
  title-font,
  logo,
  outline-code
) = {
  // Logo placement
  if logo != none {
    set image(width: 6cm)
    place(
      top + right,
      dx: .5cm,
      dy: -1.5cm,
      logo
    )
  }

  v(2fr)

  line(length: 100%, stroke: primary-color)

  // Title
  align(center, text(font: title-font, 2.5em, weight: 700, title))
  v(2em, weak: true)

  // Subtitle
  align(center, text(font: title-font, 2em, weight: 700, subtitle))
  v(2em, weak: true)

  // Date
  align(
      center,
      text(1.1em,
        if start-date == last-updated-date {
          date-format(start-date)
        } else {
          date-format(start-date) + " - " + date-format(last-updated-date)
        }
      )
  )
  v(2em, weak: true)
  line(length: 100%, stroke: primary-color)

  v(2fr)

  // Author information
  let school-year = if start-date.month() < 9 { int(year) - 1 } else { int(year) }
  let next-year = str(school-year + 1)

  let bottom-text = text(
    author + "\n" +
    if (affiliation != "") {
      affiliation + "\n"
    } else {
      ""
    },
    14pt,
    weight: "bold"
  ) + if (class != "") {
    text(
      str(school-year) + "-" + str(next-year) + "\n" + emph[#class],
      14pt)
  }

  place(
    bottom + center,
    dy: 5%,
    align(center)[
      #bottom-text
    ]
  )

  pagebreak()

  // Conditional outline rendering
  if outline-code == none {
    // Default outline
    outline()
  } else if outline-code != false {
    // Custom outline code provided by user
    outline-code
  }
  // If outline-code == false, no outline is rendered

  pagebreak()
}
