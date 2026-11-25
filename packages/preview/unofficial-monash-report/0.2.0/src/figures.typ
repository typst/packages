#import "design.typ": *
#import "question.typ": show-question
#import "theorems.typ": show-statement, chapter-prefixed
#let numberer(o, n) = context {
  if o.mode == "report" { chapter-prefixed(n, here()) } else { str(n) }
}
#let number-at(o, target) = {
  let c = if target.func() == math.equation {
    counter(math.equation)
  } else { counter(figure.where(kind: target.kind)) }
  let n = c.at(target.location()).first()
  n = if o.mode == "report" and not (target.func() == figure and target.kind == "question") {
    chapter-prefixed(n, target.location())
  } else { str(n) }
  if target.func() == math.equation { "(" + n + ")" } else { n }
}
#let default-supplement(o, target) = if target.func() == figure and target.kind == "question" {
  o.labels.question
} else if target.func() == figure and target.kind == "theorem" {
  o.labels.at(target.body.value.kind)
} else { target.supplement }
// Outline prefix, such as "Figure 2.1", numbered at the element rather than the outline.
#let entry-prefix(o, target) = {
  let supplement = default-supplement(o, target)
  let number = number-at(o, target)
  if supplement in (none, [], "") { [#number] } else { [#supplement #number] }
}
// The width a table needs whatever its cells contain: fixed columns and gutters.
#let fixed-width(table, available) = {
  let resolve(track) = if type(track) == length { track } else if type(track) == ratio {
    track * available
  } else if type(track) == relative { track.ratio * available + track.length } else { zero }
  let columns = if type(table.columns) == array { table.columns } else { () }
  let gutter = table.at("column-gutter", default: ())
  let gutters = if type(gutter) == array { gutter } else {
    (gutter,) * calc.max(columns.len() - 1, 0)
  }
  (columns + gutters).map(resolve).sum(default: zero)
}
#let figure-style(o, body) = {
  let figure-numbering = n => numberer(o, n)
  let equation-numbering = n => [(#numberer(o, n))]
  set figure(numbering: figure-numbering, gap: caption-gap)
  set figure.caption(separator: [. ])
  set math.equation(numbering: equation-numbering, number-align: right)
  set table(
    stroke: (x, y) => (bottom: if y == 0 { hairline + monash-black }),
    inset: (x, y) => if y == 0 { table-header-inset } else { table-body-inset },
    align: (x, y) => if x == 0 { left } else { right },
  )
  show table.cell: set text(top-edge: body-top-edge, bottom-edge: body-bottom-edge)
  show table: it => {
    set text(
      size: scaled(o, label-size), hyphenate: false,
      top-edge: body-top-edge, bottom-edge: body-bottom-edge,
    )
    set par(justify: false)
    if it.has("label") and it.label == <monash-three-line-table> { it } else {
      let fields = it.fields()
      let children = fields.remove("children")
      // The label stays on the original element, so it remains queryable and linkable.
      let _ = fields.remove("label", default: none)
      let styled = [#table(
        ..fields,
        table.hline(stroke: table-rule + monash-black),
        ..children,
        table.hline(stroke: table-rule + monash-black),
      )<monash-three-line-table>]
      // Auto and fractional columns wrap their text. Only fixed widths wider than the
      // text column shrink the whole table.
      layout(size => {
        let fitted = if fixed-width(it, size.width) > size.width {
          let ratio = size.width / measure(styled).width * full
          scale(x: ratio, y: ratio, reflow: true, styled)
        } else { styled }
        align(center, fitted)
      })
    }
  }
  show figure.where(kind: table): set figure.caption(position: top)
  // Long tables continue on the next page; the caption stays above the first part.
  show figure.where(kind: table): set block(breakable: true)
  show figure.where(kind: table): set figure(gap: table-caption-gap)
  // Extra space above in-flow figures only; a floating figure leaves none behind.
  let above(space) = it => { if it.placement == none { v(space) }; it }
  show figure.where(kind: table): above(table-above-extra)
  show figure.where(kind: image): above(figure-above-extra)
  show math.equation.where(block: true): it => {
    set text(size: scaled(o, equation-size))
    block(
      above: zero, below: zero,
      inset: (
        top: if o.mode == "report" { equation-top-report } else { equation-top-assignment },
        bottom: equation-inset,
      ),
      it,
    )
  }
  show figure.where(kind: raw): set figure(supplement: o.labels.listing)
  show figure.where(kind: raw): above(code-figure-above)
  show figure.caption: it => context {
    set align(center)
    let caption-size = scaled(o, caption-size)
    set text(size: caption-size, top-edge: body-top-edge, bottom-edge: body-bottom-edge)
    if it.numbering != none {
      let supplement = if it.supplement != none { [#it.supplement ] }
      text(font: o.heading-font, size: caption-size, weight: "bold", fill: o.accent)[
        #supplement#it.counter.display(it.numbering).]
      [ ]
    }
    it.body
  }
  // Native ref and outline entries evaluate contextual numbering where they appear.
  // Resolve both counters at the target, including references across chapters.
  let ours(target) = target != none and (
    target.func() == math.equation and target.numbering == equation-numbering
    or target.func() == figure and (
      target.kind in ("theorem", "question") or target.numbering == figure-numbering
    )
  )
  show ref: it => context {
    let targets = query(it.target)
    let target = targets.at(0, default: none)
    if it.form == "normal" and targets.len() == 1 and ours(target) {
      let supplement = if it.supplement == auto { default-supplement(o, target) } else if (
        type(it.supplement) == function
      ) { it.supplement(target) } else { it.supplement }
      let prefix = if supplement != none and supplement != [] { [#supplement~] } else { [] }
      link(target.location(), [#prefix#number-at(o, target)])
    } else { it }
  }
  show outline.entry: it => if ours(it.element) and it.element.numbering != none {
    link(it.element.location(), it.indented(entry-prefix(o, it.element), it.inner()))
  } else { it }
  show figure.where(kind: "question"): show-question
  show figure.where(kind: "theorem"): show-statement
  body
}
