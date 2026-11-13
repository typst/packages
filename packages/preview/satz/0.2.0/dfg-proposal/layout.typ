/// Render DFG headings with form-specific numbering and spacing.
///
/// Preserves each native heading's counter, location, and label while drawing
/// its visible block with configured DFG heading sizes and gaps. Levels above
/// four use level-four styling. The helper tracks preceding body blocks to
/// suppress above-spacing at the top of a heading sequence and applies the
/// measured form topskip at page top. It is an internal show-rule wrapper.
///
/// - c (dictionary): resolved DFG document config with headings.* and
///   page.margin.top values
/// - body (content): document content whose native headings should be rendered
/// -> content: content with DFG heading show rules applied
#let proposal-headings(c, body) = {
  show par: it => {
    state("satz-dfg-previous-block", none).update("body")
    it
  }
  show list: it => {
    it
    state("satz-dfg-previous-block", none).update("body")
  }
  show enum: it => {
    it
    state("satz-dfg-previous-block", none).update("body")
  }
  show math.equation.where(block: true): it => {
    it
    state("satz-dfg-previous-block", none).update("body")
  }
  show table: it => {
    it
    state("satz-dfg-previous-block", none).update("body")
  }
  show figure: it => {
    it
    state("satz-dfg-previous-block", none).update("body")
  }
  show heading: it => {
    context {
      let level = calc.min(it.level, 4)
      let previous = state("satz-dfg-previous-block", none).get()
      let above = if previous == "heading" { 0pt } else { c.headings.at("h" + str(level) + "-above") }
      let below = c.headings.at("h" + str(level) + "-below")
      let prefix = if it.numbering == none { none } else {
        numbering(it.numbering, ..counter(heading).at(it.location()))
      }
      let indent = if prefix == none { 0pt } else { measure(prefix).width + 0.5em }
      let spacing = if above == auto { (:) } else { (above: above) }
      // TeX's page-top baseline uses topskip, even for headings.
      let advance = 11 * 72 / 72.27 * 1pt - 1467 / 2048 * 11pt
      let at-top = it.location().position().y <= c.page.margin.top + advance + 0.1pt
      block(..spacing, below: below, sticky: true, breakable: false)[
        #if at-top { v(advance) }
        #set par(first-line-indent: 0pt, justify: false)
        #grid(columns: (indent, 1fr), if prefix != none { prefix } else { [] }, it.body)
      ]
    }
    state("satz-dfg-previous-block", none).update("heading")
  }
  body
}

/// Render the five-row DFG title block, with a rule on its fourth row.
///
/// Rows use the resolved paragraph spacing as their gutter. The rule's
/// thickness and vertical offset use the DFG form's measured 11pt geometry.
///
/// - c (dictionary): resolved DFG config; reads typography.paragraph-spacing
/// - title (content): proposal title
/// - applicant (content): applicant name or block
/// - project (content): project title
/// - description (content): project description
/// -> content: bold, single-column title block
#let proposal-title(c, title, applicant, project, description) = {
  set text(weight: "bold")
  grid(
    columns: (1fr,), row-gutter: c.typography.paragraph-spacing,
    title, applicant, project,
    box(width: 100%, height: 1467 / 2048 * 1em)[
      #place(bottom, dy: -0.25 * 72 / 72.27 * 1pt, line(length: 100%, stroke: 0.5 * 72 / 72.27 * 1pt))
    ],
    description,
  )
}
