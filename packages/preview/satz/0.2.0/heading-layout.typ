/// Apply measured KOMA-style heading spacing to document content.
///
/// Measures the active body and heading font metrics to translate baseline
/// skips into Typst block gaps. Explicit headings.hN-above and
/// headings.hN-below lengths override the measured values; auto uses the
/// KOMA-derived gaps. Level four remains a block heading. The wrapper preserves
/// native heading counters and labels, and optionally starts h1 headings on a
/// new page when headings.h1-pagebreak is enabled. Journal h1 text is rendered
/// in small caps.
///
/// - c (dictionary): resolved document config with typography.size and
///   headings settings
/// - kind (str): document kind; journal enables small caps for h1
/// - body (content): content whose headings should use the measured spacing
/// -> content: content with the heading show rule applied
#let koma-headings(c, kind, body) = {
  show par: it => {
    state("satz-heading-previous", none).update("body")
    it
  }
  show list: it => {
    it
    state("satz-heading-previous", none).update("body")
  }
  show enum: it => {
    it
    state("satz-heading-previous", none).update("body")
  }
  show math.equation.where(block: true): it => {
    it
    state("satz-heading-previous", none).update("body")
  }
  show table: it => {
    it
    state("satz-heading-previous", none).update("body")
  }
  show figure: it => {
    it
    state("satz-heading-previous", none).update("body")
  }
  show heading: it => context {
    let level = calc.min(it.level, 4)
    let size = c.headings.at("h" + str(level) + "-size")
    let metrics(size, weight) = {
      let box-of(content) = text(size: size, weight: weight, top-edge: "cap-height", bottom-edge: "baseline", content)
      let cap = measure(box-of([H])).height
      let baseline = measure(box-of([H#linebreak()H])).height - cap
      let paragraph = measure(box-of([H#parbreak()H])).height - cap - baseline
      (cap: cap, baseline: baseline, paragraph: paragraph,
       x: measure(text(size: size, weight: weight, top-edge: "x-height", bottom-edge: "baseline", [x])).height)
    }
    let normal = metrics(c.typography.size, "regular")
    let head = metrics(size, "bold")
    let previous = state("satz-heading-previous", none).get()
    let stacked = type(previous) == int
    let before = (3.5, 3.25, 3.25, 3.25).at(level - 1) * normal.x
    // Satz keeps level four as a block; KOMA's paragraph is normally run-in.
    let after = (2.3, 1.5, 1.5, 0).at(level - 1) * normal.x
    let configured-above = c.headings.at("h" + str(level) + "-above")
    let configured-below = c.headings.at("h" + str(level) + "-below")
    let above = if stacked { 0pt } else if configured-above == auto {
      head.baseline + normal.paragraph + before - head.cap
    } else { configured-above }
    let below = if configured-below == auto {
      normal.baseline + normal.paragraph + after - normal.cap
    } else { configured-below }
    // A consecutive heading uses its own leading in the preceding afterskip.
    let correction = if stacked and c.headings.at("h" + str(previous) + "-below") == auto {
      head.baseline - head.cap - (normal.baseline - normal.cap)
    } else { 0pt }
    let prefix = if it.numbering == none { none } else {
      numbering(it.numbering, ..counter(heading).at(it.location()))
    }
    let indent = if prefix == none { 0pt } else { measure(prefix).width + 0.5em }
    if level == 1 and c.headings.h1-pagebreak { pagebreak(weak: true) }
    block(above: above, below: below, sticky: true, breakable: false)[
      #set text(top-edge: "cap-height", bottom-edge: "baseline")
      #set par(justify: false, first-line-indent: 0pt)
      #v(correction)
      #grid(columns: (indent, 1fr), if prefix != none { prefix } else { [] },
        if kind == "journal" and level == 1 { smallcaps(it.body) } else { it.body })
    ]
    state("satz-heading-previous", none).update(level)
  }
  body
}
