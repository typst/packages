/// Expose these to the end user
#import "internal/helpers.typ": appendices-section, appendix

#let ttuile(
  /// Title of the report ; `dictionary<str, content> | content?`
  headline: none,
  /// Authors of the report ; `array<str | content> | content?`
  authors: none,
  /// Group number ; `content?`
  group: none,
  /// Usually the lab bench number ; `content?`
  footer-left: none,
  /// Usually the date at which the lab work/practical was carried out ; `content?`
  footer-right: none,
  /// Display the table of contents ? ; `bool`
  outlined: true,
  /// University logo to display ; `image | content?`
  logo: image("internal/logo-insa-lyon.png"),
  /// Body of the report
  doc,
) = {
  /// Private imports
  import "internal/helpers.typ": authors-helper, headline-helper
  import "internal/defaults.typ": *

  /* -------------------------------------------------------------------------- */
  /*                                   Styling                                  */
  /* -------------------------------------------------------------------------- */

  /// Language and text
  set text(
    lang: "fr",
    size: fsize-base,
    font: ffam-base,
    weight: "regular",
    stretch: 100%,
  )

  /// Paragraphs
  set align(left)
  set par(justify: true)

  /// Page format
  set page(
    paper: "a4",
    margin: (
      left: 2cm,
      right: 2cm,
      top: 2.5cm,
      bottom: 2.5cm,
    ),
    header-ascent: 30%,
    // Header with authors and uni logo
    header: [
      #set text(
        font: ffam-special,
        size: fsize-header,
      )
      // Spacing from the top of the page, somewhat of a magic number
      #v(38.51pt)
      #grid(
        columns: (5fr, 1fr),
        column-gutter: 1em,
        // Authors, left aligned
        align(left + horizon)[
          #authors-helper(group, authors)
        ],
        // Uni logo (if applicable)
        if (logo != none) {
          set image(fit: "contain")
          align(center + horizon, logo)
        },
      )
    ],
    footer-descent: 30%,
    // Footer with page numbers
    footer: [
      // Formatting
      #set text(
        font: ffam-special,
        size: fsize-footer,
      )
      #grid(
        columns: (1fr, 1fr, 1fr),
        align(left)[#footer-left],
        // Page number
        align(center)[
          #context counter(page).display(
            "﹣1 / 1﹣",
            both: true,
          )
        ],
        align(right)[#footer-right],
      )
    ],
  )

  /// Underline outgoing links only
  show link: it => {
    if (type(it.dest) == str) {
      underline(it)
    } else { it }
  }

  /// Heading numbering
  /// See : https://www.reddit.com/r/typst/comments/18exrv5/hide_previous_level_heading_counters/
  set heading(
    numbering: (..nums) => {
      let nums = nums.pos()
      // Level of the current heading
      let level = nums.len()

      if level < 3 {
        let style = style-numbering-h1 + style-numbering-h2
        let num = nums
        return numbering(style, ..num)
      } else if level == 3 {
        let style = style-numbering-h3
        let num = nums.last()
        return numbering(style, num)
      } else { return none }
    },
  )

  /// Lists
  set list(
    marker: ([•], [--]),
    indent: indent-base,
  )

  /// Footnotes
  show footnote.entry: set text(size: fsize-footnote)

  /// Figures
  show figure.caption: set text(
    size: fsize-caption,
    fill: color-blue-caption,
    weight: "bold",
  )
  show figure.caption: it => [
    #it.supplement #context it.counter.display() :
    #set text(style: "italic"); #it.body
  ]

  /// Equations
  set math.equation(numbering: "(1)")

  /// References
  show ref: it => {
    // Default return value
    let _content = it

    // Underlining style
    let stroke-style = (dash: "dotted", thickness: 0.8pt)

    if it.element != none and (it.element.func() == heading) {
      // Array of headings from the appendices section
      let _appendix-headings = query(
        heading.where().after(label(metadata-appendices-start)).before(label(metadata-appendices-end)),
      )

      if (it.element not in _appendix-headings) {
        if it.element.level <= 3 {
          let number = numbering(
            // Cannot use `it.element.numbering` because for level 3 headings it's not the same as `style-numbering-base`
            style-numbering-base,
            // Here we specifically want the whole "I.1.A." do be displayed
            ..counter(heading).at(it.element.location()),
          )
          _content = text(weight: 500, number)
        } else if it.element.level == 4 {
          _content = text(weight: 400, it.element.body)
        } else {
          panic(
            prefix-errors
              + "Cannot reference headings of `level >= 5` at the moment. Try defining your own `show ref: it => if it.element != none and (it.element.func() == heading) and it.element.level == _ {...} else {it}` for the levels you're interested in referencing.",
          )
        }
      } else {
        // Else, we are referencing a heading from the appendices section
        let number = numbering(
          style-numbering-appendices,
          ..counter(heading).at(it.element.location()),
        )
        if it.element.level == 1 {
          _content = text(weight: 500, style: "normal")[#it.element.supplement #number]
        } else {
          // TODO For now the author is free to add `Annexe` before reference to subsections. Maybe enforce `Annexe #number` ?
          _content = text(number)
        }
      }
      // Don't forget to link to the element
      _content = link(it.target, _content)
    }
    return underline(stroke: stroke-style, _content)
  }

  /* -------------------------------- Headings -------------------------------- */

  /// Waiting on https://github.com/typst/typst/issues/1699 to adjust heading spacing
  /// See : https://github.com/typst/typst/issues/1699#issuecomment-2144928281

  /// Positioning
  show heading: set block(width: 100%)
  show heading: set align(left)

  /// Spacing
  show heading: set block(above: vspacing-heading.at(0), below: vspacing-heading.at(1))

  /// Formatting
  show heading: it => {
    // Counter or decoration
    if it.level < 4 { context counter(heading).display() } else if it.level == 4 {
      str.from-unicode(10146) // ➢
    }
    // Spacing between the decoration and the body
    h(indent-numbering)
    // Only underline level 1 through 3
    if it.level < 4 { underline(it.body) } else { it.body }
  }

  /// Styling
  show heading: it => {
    // For headings level 1 through 4
    set text(
      size: fsize-heading.at(it.level - 1),
      fill: color-heading.at(it.level - 1),
    ) if it.level <= 4

    set text(
      font: ffam-heading,
      weight: if (it.level == 4) { 600 } else { "bold" },
    )

    it
  }

  /// Indenting
  ///
  /// See also :
  /// * https://github.com/typst/typst/discussions/2812
  /// * https://forum.typst.app/t/how-can-i-indent-my-headings/3185/4
  show heading: it => pad(
    left: if (it.level < 4) { (it.level - 1) * indent-heading } else { 1.5 * indent-heading },
    it,
  )

  /// Safeguard, there is no style defined for level 5 and above.
  /// Has to be implemented this way, see https://github.com/typst/typst/issues/4950
  ///
  /// This snippet also has to come after the others, because at some point we return `it.body`
  /// instead of `it`, which "strips" this very safeguard (that was acting on `it` only).
  show heading: it => if it.level > 4 {
    panic(
      prefix-errors
        + "Headings of `level > 4` aren't supported by the template ; but you can define your own style `show heading.where(level: _): it => ...`. Get rid of the error by replacing the dots with `it.body` for example.",
    )
  } else { it }

  /* -------------------------------------------------------------------------- */
  /*                                   Display                                  */
  /* -------------------------------------------------------------------------- */

  /// Headline
  {
    set align(center)
    set text(font: ffam-special)
    set rect(
      width: 100%,
      radius: 0%,
      inset: (top: 10pt, bottom: 10pt),
      stroke: 0.7pt,
    )
    if headline != none {
      rect(headline-helper(headline))
    }
  }

  /// Outline
  set outline(
    title: none,
    indent: indent-outline,
    depth: outline-depth,
    target: heading
      .where()
      .before(label(metadata-appendices-start))
      .or(heading.where().after(label(metadata-appendices-end))),
  )

  show outline: set text(size: fsize-base, font: ffam-outline)

  if outlined {
    // Spacing under the headline
    if headline != none { v(0.3cm) }
    outline()
  }

  /// Document body
  doc
}
