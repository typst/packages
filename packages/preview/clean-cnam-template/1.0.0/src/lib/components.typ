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
 * Creates a styled quote block with left border accent and subtle background.
 * Perfect for highlighting important quotes or references.
 *
 * @param color - The stroke color (default: luma(170))
 * @param fill - The background fill color (default: luma(230))
 * @param inset - The padding inside the block (default: custom spacing)
 * @param radius - The border radius (default: rounded right side)
 * @param stroke - The stroke configuration (default: left border only)
 * @param content - The content to display
 * @returns A styled blockquote element
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
  content,
) => {
  rect(
    stroke: stroke,
    inset: inset,
    fill: fill,
    radius: radius,
    content
  )
}

/**
 * Create a custom block with configurable styling.
 *
 * A general-purpose content block that can be styled and positioned
 * according to your needs. Useful for callouts, notes, or highlighting content.
 *
 * @param fill - The background color (default: luma(230))
 * @param inset - The padding of the block (default: 15pt)
 * @param radius - The radius of the block (default: 4pt)
 * @param outline - The outline stroke of the block (default: none)
 * @param alignment - The alignment of the block (default: center)
 * @param content - The content of the block
 * @returns A styled content block
 */
#let my-block = (
  fill: luma(230),
  inset: 15pt,
  radius: 4pt,
  outline: none,
  alignment: center,
  content
) => {
  align(
    alignment,
    block(
      fill: fill,
      inset: inset,
      radius: radius,
      stroke: outline,
      content
    )
  )
}

/**
 * Enhanced and modernized code block with line numbers, syntax highlighting, and language display.
 *
 * This component provides a feature-rich code display with:
 * - Configurable line numbering with custom alignment
 * - Syntax highlighting support for various languages
 * - Language label badges
 * - Customizable styling and theming
 * - Label support for referencing specific lines
 * - Line range selection for partial code display
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
 * @param line-spacing - Vertical spacing between code lines (default: 5pt)
 * @param line-offset - Horizontal offset for line numbers (default: 5pt)
 * @param numbering - Whether to display line numbers (default: true)
 * @param inset - Inner padding around the code block (default: 5pt)
 * @param radius - Border radius for rounded corners (default: 3pt)
 * @param number-align - Alignment of line numbers: left, center, right (default: right)
 * @param stroke - Border stroke style and color (default: 1pt + luma(180))
 * @param fill - Background fill color (default: luma(250))
 * @param text-style - Text styling configuration: (size, font) (default: (size: 8pt, font: "Zed Plex Mono"))
 * @param width - Block width, can be length or percentage (default: 100%)
 * @param lines - Line range to display: (start, end) or auto for all (default: auto)
 * @param lang - Programming language for syntax highlighting (default: none)
 * @param filename - Optional filename to display before the language (default: none)
 * @param lang-box - Language label styling configuration (default: red theme)
 * @param source - The source code content as raw text block
 */
#let code(
  line-spacing: 5pt,
  line-offset: 5pt,
  numbering: true,
  inset: 5pt,
  radius: 3pt,
  number-align: right,
  stroke: 1pt + luma(180),
  fill: luma(250),
  text-style: (size: 8pt, font: "Zed Plex Mono"),
  width: 100%,
  lines: auto,
  lang: none,
  filename: none,
  lang-box: (
    gutter: 5pt,
    radius: 3pt,
    outset: 1.75pt,
  ),
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
  let create-line-number(number) = text(
    size: 1.25em,
    fill: gray,
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
      measure(create-line-number(line-range.at(1))).width
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
                create-line-number(line.number)
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

    // Create a stack with language label above the code block
    stack(
      dir: ttb,
      spacing: 0pt,
      // Language/filename label outside and above the code block
      if filename != none or lang != none {
        align(left,
          rect(
            width: 100%,
            inset: 6pt,
            radius: (top: lang-box.radius),
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
        )
      },
      // Code block
      raw(
          block: true,
          lang: source.lang,
          unlabelled-source
      )
    )
  }
}

