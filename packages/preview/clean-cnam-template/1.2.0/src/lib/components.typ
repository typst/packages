/**
 * UI Components for the TYPST template
 *
 * @author Tom Planche
 * @license MIT
 */

#import "fonts.typ": get-fonts

/**
 * Create a blockquote with customizable styling.
 *
 * Creates a styled quote block with border accent and subtle background.
 * Perfect for highlighting important quotes or references.
 * Supports optional attribution/source, flexible alignment, and border positioning.
 *
 * @param color - The stroke color (default: luma(170))
 * @param fill - The background fill color (default: luma(230))
 * @param inset - The padding inside the block (default: custom spacing)
 * @param radius - The border radius (default: rounded right side)
 * @param stroke - The stroke configuration (default: left border only)
 * @param block-align - The alignment of the block itself (default: left)
 * @param content-align - The alignment of the content inside the block (default: left)
 * @param width - The width of the block: auto for content width, 100% for full width, or custom length (default: 100%)
 * @param border-side - Which side to show the accent border: left, right, top, bottom, or all (default: left)
 * @param attribution - Optional attribution/source text to display at the bottom (default: none)
 * @param attribution-align - The alignment of the attribution: left, center, or right (default: right)
 * @param attribution-style - Text styling for the attribution: (size, weight, fill, style) (default: (size: 0.9em, style: "italic", fill: luma(100)))
 * @param attribution-inset - The padding around the attribution (default: (top: 8pt))
 * @param content - The content to display
 * @returns A styled blockquote element
 *
 * ## Usage Examples
 *
 * Basic usage with attribution:
 * ```typst
 * #blockquote(
 *   attribution: "— Albert Einstein",
 *   [Imagination is more important than knowledge.]
 * )
 * ```
 *
 * Right-side border with centered content:
 * ```typst
 * #blockquote(
 *   border-side: right,
 *   content-align: center,
 *   attribution: "— Confucius",
 *   attribution-align: center,
 *   [I hear and I forget. I see and I remember. I do and I understand.]
 * )
 * ```
 *
 * Full border with custom styling:
 * ```typst
 * #blockquote(
 *   border-side: all,
 *   color: blue,
 *   fill: blue.lighten(95%),
 *   attribution: "— Marie Curie",
 *   attribution-style: (size: 0.85em, style: "italic", fill: blue.darken(20%)),
 *   [Nothing in life is to be feared, it is only to be understood.]
 * )
 * ```
 *
 * Centered block with auto width:
 * ```typst
 * #blockquote(
 *   block-align: center,
 *   width: auto,
 *   [Short quote that fits content width]
 * )
 * ```
 */
#let blockquote = (
  color: luma(170),
  fill: luma(230),
  inset: (left: 1em, top: 10pt, right: 10pt, bottom: 10pt),
  radius: (
    top-right: 5pt,
    bottom-right: 5pt,
  ),
  stroke: (left: 2.5pt),
  block-align: left,
  content-align: left,
  width: 100%,
  border-side: "left",
  attribution: none,
  attribution-align: right,
  attribution-style: (size: 0.9em, style: "italic", fill: luma(100)),
  attribution-inset: (top: 8pt),
  content,
) => {
  // Helper to create stroke configuration based on border-side
  let get-stroke(side, color) = {
    if side == "all" {
      2.5pt + color
    } else if side == "left" {
      (left: 2.5pt + color)
    } else if side == "right" {
      (right: 2.5pt + color)
    } else if side == "top" {
      (top: 2.5pt + color)
    } else if side == "bottom" {
      (bottom: 2.5pt + color)
    } else {
      stroke
    }
  }

  // Adjust radius based on border side
  let get-radius(side) = {
    if side == "all" {
      5pt
    } else if side == "left" {
      (top-right: 5pt, bottom-right: 5pt)
    } else if side == "right" {
      (top-left: 5pt, bottom-left: 5pt)
    } else if side == "top" {
      (bottom-left: 5pt, bottom-right: 5pt)
    } else if side == "bottom" {
      (top-left: 5pt, top-right: 5pt)
    } else {
      radius
    }
  }

  align(
    block-align,
    rect(
      stroke: get-stroke(border-side, color),
      inset: inset,
      fill: fill,
      radius: get-radius(border-side),
      width: width,
      {
        align(content-align, content)
        if attribution != none {
          v(attribution-inset.at("top", default: 8pt))
          align(
            attribution-align,
            text(
              size: attribution-style.at("size", default: 0.9em),
              weight: attribution-style.at("weight", default: "regular"),
              fill: attribution-style.at("fill", default: luma(100)),
              style: attribution-style.at("style", default: "italic"),
              attribution
            )
          )
        }
      }
    )
  )
}

/**
 * Create a custom block with configurable styling.
 *
 * A highly customizable content block that can be styled and positioned
 * according to your needs. Useful for callouts, notes, or highlighting content.
 * Supports optional titles and flexible alignment options.
 *
 * @param fill - The background color (default: luma(230))
 * @param inset - The padding of the block (default: 15pt)
 * @param radius - The radius of the block (default: 4pt)
 * @param outline - The outline stroke of the block (default: none)
 * @param block-align - The alignment of the block itself (default: center)
 * @param content-align - The alignment of the content inside the block (default: left)
 * @param width - The width of the block: auto for content width, 100% for full width, or custom length (default: auto)
 * @param title - Optional title text to display at the top (default: none)
 * @param title-align - The alignment of the title: left, center, or right (default: left)
 * @param title-style - Text styling for the title: (size, weight, fill) (default: (size: 1.1em, weight: "bold", fill: black))
 * @param title-inset - The padding around the title (default: (bottom: 8pt))
 * @param content - The content of the block
 * @returns A styled content block
 *
 * ## Usage Examples
 *
 * Basic usage with title:
 * ```typst
 * #my-block(
 *   title: "Important Note",
 *   [This is some important content.]
 * )
 * ```
 *
 * Centered title with custom styling:
 * ```typst
 * #my-block(
 *   title: "Warning",
 *   title-align: center,
 *   title-style: (size: 1.2em, weight: "bold", fill: red),
 *   fill: rgb("#fff3cd"),
 *   [Be careful with this operation!]
 * )
 * ```
 *
 * Full-width block with centered content:
 * ```typst
 * #my-block(
 *   width: 100%,
 *   content-align: center,
 *   [Centered content in full-width block]
 * )
 * ```
 *
 * Content-width block aligned to the right:
 * ```typst
 * #my-block(
 *   block-align: right,
 *   width: auto,
 *   [This block fits its content and is aligned to the right]
 * )
 * ```
 */
#let my-block = (
  fill: luma(230),
  inset: 15pt,
  radius: 4pt,
  outline: none,
  block-align: center,
  content-align: left,
  width: auto,
  title: none,
  title-align: left,
  title-style: (size: 1.1em, weight: "bold", fill: black),
  title-inset: (bottom: 8pt),
  content
) => {
  align(
    block-align,
    block(
      fill: fill,
      inset: inset,
      radius: radius,
      stroke: outline,
      width: width,
      {
        if title != none {
          align(
            title-align,
            text(
              size: title-style.at("size", default: 1.1em),
              weight: title-style.at("weight", default: "bold"),
              fill: title-style.at("fill", default: black),
              title
            )
          )
          v(title-inset.at("bottom", default: 8pt))
        }
        align(content-align, content)
      }
    )
  )
}

/**
 * Enhanced and modernized code block with line numbers, syntax highlighting, and language display.
 *
 * This component provides a feature-rich code display with:
 * - Configurable line numbering with custom alignment and styling
 * - Syntax highlighting support for various languages
 * - Language and filename label badges
 * - Customizable styling and theming
 * - Label support for referencing specific lines
 * - Line range selection for partial code display
 * - Optional title/caption support
 * - Flexible alignment options
 *
 * ## Usage Examples
 *
 * Basic usage:
 * ```typst
 * #code(lang: "Python", ```python
 * def hello_world():
 *     print("Hello, World!")
 * ```)
 * ```
 *
 * With custom styling:
 * ```typst
 * #code(
 *   numbering: false,
 *   fill: rgb("#f8f8f8"),
 *   text-style: (size: 10pt),
 *   lang: "Rust",
 *   source
 * )
 * ```
 *
 * With title and custom colors:
 * ```typst
 * #code(
 *   title: "Example Implementation",
 *   title-align: center,
 *   lang: "JavaScript",
 *   filename: "app.js",
 *   fill: rgb("#1e1e1e"),
 *   text-style: (size: 9pt, fill: rgb("#d4d4d4")),
 *   number-style: (fill: rgb("#858585")),
 *   source
 * )
 * ```
 *
 * Centered block with line range:
 * ```typst
 * #code(
 *   block-align: center,
 *   width: 80%,
 *   lines: (5, 15),
 *   lang: "Python",
 *   source
 * )
 * ```
 *
 * @param line-spacing - Vertical spacing between code lines (default: 5pt)
 * @param line-offset - Horizontal offset for line numbers (default: 5pt)
 * @param numbering - Whether to display line numbers (default: true)
 * @param inset - Inner padding around the code block (default: 5pt)
 * @param radius - Border radius for rounded corners (default: 3pt)
 * @param number-align - Alignment of line numbers: left, center, right (default: right)
 * @param number-style - Styling for line numbers: (size, fill, weight) (default: (size: 8pt, fill: gray))
 * @param stroke - Border stroke style and color (default: 1pt + luma(180))
 * @param fill - Background fill color (default: luma(250))
 * @param text-style - Text styling configuration: (size, font, fill) (default: (size: 8pt, font: "Zed Plex Mono"))
 * @param width - Block width, can be length or percentage (default: 100%)
 * @param block-align - The alignment of the block itself (default: left)
 * @param lines - Line range to display: (start, end) or auto for all (default: auto)
 * @param lang - Programming language for syntax highlighting (default: none)
 * @param filename - Optional filename to display before the language (default: none)
 * @param lang-box - Language label styling configuration: (gutter, radius, outset, fill, text-style) (default: custom)
 * @param title - Optional title to display above the code block (default: none)
 * @param title-align - The alignment of the title: left, center, or right (default: left)
 * @param title-style - Text styling for the title: (size, weight, fill) (default: (size: 1em, weight: "bold", fill: black))
 * @param title-inset - The padding around the title (default: (bottom: 8pt))
 * @param source - The source code content as raw text block
 */
#let code(
  line-spacing: 5pt,
  line-offset: 5pt,
  numbering: true,
  inset: 5pt,
  radius: 3pt,
  number-align: right,
  number-style: (size: 8pt, fill: gray),
  stroke: 1pt + luma(180),
  fill: luma(250),
  text-style: (size: 8pt, font: "Zed Plex Mono"),
  width: 100%,
  block-align: left,
  lines: auto,
  lang: none,
  filename: none,
  lang-box: (
    gutter: 5pt,
    radius: 3pt,
    outset: 1.75pt,
  ),
  title: none,
  title-align: left,
  title-style: (size: 1em, weight: "bold", fill: black),
  title-inset: (bottom: 8pt),
  source
) = {
  // Helper function to extract labels from source code
  let extract-labels(source-text) = {
    let label-regex = regex("<((\w|_|-)+)>[ \t\r\f]*(\n|$)")
    source-text
      .split("\n")
      .map(line => {
        let match = line.match(label-regex)
        if match != none {
          match.captures.at(0)
        } else {
          none
        }
      })
  }

  // Helper function to create styled line numbers
  let create-line-number(number, style) = text(
    size: style.at("size", default: 8pt),
    fill: style.at("fill", default: gray),
    weight: style.at("weight", default: "regular"),
    str(number)
  )

  // Helper function to clean source code from labels
  let clean-source(source-text) = {
    let label-regex = regex("<((\w|_|-)+)>[ \t\r\f]*(\n|$)")
    source-text.replace(label-regex, "\n")
  }

  // Helper function to normalize line range
  let normalize-line-range(lines, total-lines) = {
    let result = lines
    if result == auto {
      result = (auto, auto)
    }
    if result.at(0) == auto {
      result.at(0) = 1
    }
    if result.at(1) == auto {
      result.at(1) = total-lines
    }
    (result.at(0) - 1, result.at(1))
  }

  // Process source code
  let labels = extract-labels(source.text)
  let unlabelled-source = clean-source(source.text)

  context {
    let fonts = get-fonts()
    let final-text-style = (..text-style, font: fonts.code)

    // Apply text styling to raw content
    show raw.line: set text(..final-text-style)
    show raw: set text(..final-text-style)
    set par(justify: false, leading: line-spacing)

    show raw.where(block: true): it => context {
    // Normalize line range using helper function
    let line-range = normalize-line-range(lines, it.lines.len())

    // Calculate maximum line number width for proper alignment
    let maximum-number-length = if numbering {
      measure(create-line-number(line-range.at(1), number-style)).width
    } else {
      0pt
    }

    block(
      inset: inset,
      radius: (bottom: radius),
      stroke: stroke,
      fill: fill,
      width: width,
      {
        stack(
          dir: ttb,
          spacing: line-spacing,
          // Code lines without language label
          ..it
            .lines
            .slice(..line-range)
            .map(line => table(
              stroke: none,
              inset: 0pt,
              columns: (maximum-number-length, 1fr),
              column-gutter: line-offset,
              align: (number-align, left),
              if numbering {
                create-line-number(line.number, number-style)
              },
              {
                let line-label = labels.at(line.number - 1)

                if line-label != none {
                  show figure: it => it.body

                  counter(figure.where(kind: "sourcerer")).update(line.number - 1)
                  [
                    #figure(supplement: "Line", kind: "sourcerer", outlined: false, line)
                    #label(line-label)
                  ]
                } else {
                  line
                }
              }
            ))
            .flatten()
        )
      }
    )
  }

    // Create the complete code block with optional title and language label
    align(
      block-align,
      stack(
        dir: ttb,
        spacing: 0pt,
        // Optional title above everything
        if title != none {
          block(
            width: width,
            inset: (bottom: title-inset.at("bottom", default: 8pt)),
            align(
              title-align,
              text(
                size: title-style.at("size", default: 1em),
                weight: title-style.at("weight", default: "bold"),
                fill: title-style.at("fill", default: black),
                title
              )
            )
          )
        },
        // Language/filename label outside and above the code block
        if filename != none or lang != none {
          rect(
            width: width,
            inset: 6pt,
            radius: (top: lang-box.at("radius", default: 3pt)),
            fill: fill,
            stroke: stroke,
            text(
                font: fonts.code,
                size: .75em,
                {
              if filename != none {
                filename
              }
              if filename != none and lang != none {
                " | "
              }
              if lang != none {
                lang
              }
            })
          )
        },
        // Code block
        raw(
            block: true,
            lang: source.lang,
            unlabelled-source
        )
      )
    )
  }
}
