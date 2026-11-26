/*
 * ============================================================
 * BASE DOCUMENT STYLES
 * ============================================================
 *
 * Defines global document layout and typography.
 *
 * Responsibilities:
 * - Page dimensions and margins
 * - Body text formatting
 * - Paragraph spacing and line spacing
 * - Heading typography and numbering
 * - Footnote formatting
 * - Inline code formatting
 *
 * All configurable values are provided by the caller.
 * Page numbering is managed separately.
 * ============================================================
 */


// ------------------------------------------------------------
// SHARED COMPONENT CONSTANTS
// ------------------------------------------------------------

// Internal constants used by figure and table components.
#let caption-font-size = 10pt
#let caption-leading = 2pt
#let note-source-gap = 5pt


// ============================================================
// MAIN DOCUMENT STYLE
// ============================================================

#let base-style(body, formatting, language) = {

  // ----------------------------------------------------------
  // BODY TYPOGRAPHY
  // ----------------------------------------------------------

  let font = formatting.at("font")
  let font-size = formatting.at("font-size")
  let hyphenate = formatting.at("hyphenate")


  // ----------------------------------------------------------
  // PARAGRAPH FORMATTING
  // ----------------------------------------------------------

  let justify = formatting.at("justify")
  let paragraph-spacing = formatting.at("paragraph-spacing")
  let line-spacing = formatting.at("line-spacing")

  // Preserve the existing line-spacing calculation.
  let line-leading = (line-spacing - 1) * 1em


  // ----------------------------------------------------------
  // HEADINGS
  // ----------------------------------------------------------

  let heading-sizes = formatting.at("heading-sizes")

  let heading-level-1-size = heading-sizes.at(0)
  let heading-level-2-size = heading-sizes.at(1)
  let heading-level-3-size = heading-sizes.at(2)

  let heading-numbering = formatting.at("heading-numbering")


  // ----------------------------------------------------------
  // FOOTNOTES
  // ----------------------------------------------------------

  let footnote-font-size = formatting.at("footnote-size")


  // ----------------------------------------------------------
  // PAGE LAYOUT
  // ----------------------------------------------------------

  let paper = formatting.at("paper")
  let margin = formatting.at("margin")


  // ==========================================================
  // DOCUMENT STYLES
  // ==========================================================

  [

    // --------------------------------------------------------
    // PAGE LAYOUT
    // --------------------------------------------------------

    #set page(
      paper: paper,
      margin: margin,
    )


    // --------------------------------------------------------
    // BODY TYPOGRAPHY
    // --------------------------------------------------------

    #set text(
      font: font,
      size: font-size,
      lang: language,
      fill: black,
      hyphenate: hyphenate,
      top-edge: 0.8em,
      bottom-edge: -0.2em,
    )


    // --------------------------------------------------------
    // PARAGRAPH FORMATTING
    // --------------------------------------------------------

    #set par(
      justify: justify,
      leading: line-leading,
      first-line-indent: 0pt,
      spacing: paragraph-spacing,
    )


    // --------------------------------------------------------
    // TABLE FORMATTING
    // --------------------------------------------------------

    #set table(
      align: left,
    )


    // --------------------------------------------------------
    // HEADING NUMBERING
    // --------------------------------------------------------

    #set heading(
      numbering: heading-numbering,
    )


    // --------------------------------------------------------
    // HEADING FORMATTING
    // --------------------------------------------------------

    #show heading: set align(left)

    #show heading: set text(
      font: font,
      weight: "bold",
      fill: black,
    )


    // Level 1
    #show heading.where(level: 1): set text(
      size: heading-level-1-size,
    )

    #show heading.where(level: 1): set block(
      above: 12pt,
      below: 12pt,
    )


    // Level 2
    #show heading.where(level: 2): set text(
      size: heading-level-2-size,
    )

    #show heading.where(level: 2): set block(
      above: 12pt,
      below: 6pt,
    )


    // Level 3
    #show heading.where(level: 3): set text(
      size: heading-level-3-size,
    )

    #show heading.where(level: 3): set block(
      above: 12pt,
      below: 6pt,
    )


    // --------------------------------------------------------
    // FOOTNOTE FORMATTING
    // --------------------------------------------------------

    #show footnote.entry: it => {
      let loc = it.note.location()
      let number = numbering(
        it.note.numbering,
        ..counter(footnote).at(loc),
      )

      set text(
        font: font,
        size: footnote-font-size,
        fill: black,
      )

      set par(
        justify: justify,
        leading: line-leading,
        first-line-indent: 0pt,
        spacing: 0pt,
      )

      grid(
        columns: (auto, 1fr),
        column-gutter: 0.35em,
        link(loc, super(number)),
        it.note.body,
      )
    }


    // --------------------------------------------------------
    // INLINE CODE FORMATTING
    // --------------------------------------------------------

    #show raw.where(block: false): code => box(
      fill: rgb("f2f2f2"),
      inset: (
        x: 3pt,
        y: 1pt,
      ),
      radius: 2pt,
      code,
    )


    // --------------------------------------------------------
    // DOCUMENT CONTENT
    // --------------------------------------------------------

    #body

  ]
}