#import "design.typ": *
#import "question.typ": show-question
#import "theorems.typ": show-statement, chapter-number, chapter-number-at
#let numberer(o, n) = context {
  if o.mode == "report" { chapter-number() + "." + str(n) } else { str(n) }
}
#let number-at(o, target) = {
  let c = if target.func() == math.equation {
    counter(math.equation)
  } else { counter(figure.where(kind: target.kind)) }
  let n = str(c.at(target.location()).first())
  if o.mode == "report" and not (target.func() == figure and target.kind == "question") {
    n = chapter-number-at(target.location()) + "." + n
  }
  if target.func() == math.equation { "(" + n + ")" } else { n }
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
      size: label-size, hyphenate: false,
      top-edge: body-top-edge, bottom-edge: body-bottom-edge,
    )
    if it.has("label") and it.label == <monash-three-line-table> { it } else {
      let fields = it.fields()
      let children = fields.remove("children")
      fields.remove("label", default: none)
      let styled = [#table(
        ..fields,
        table.hline(stroke: table-rule + monash-black),
        ..children,
        table.hline(stroke: table-rule + monash-black),
      )<monash-three-line-table>]
      layout(size => {
        let width = measure(styled).width
        let fitted = if width > size.width {
          let ratio = size.width / width * full
          scale(x: ratio, y: ratio, reflow: true, styled)
        } else { styled }
        align(center, fitted)
      })
    }
  }
  show figure.where(kind: table): set figure.caption(position: top)
  show figure.where(kind: table): set figure(gap: table-caption-gap)
  show figure.where(kind: table): it => { v(table-above-extra); it }
  show figure.where(kind: image): it => { v(figure-above-extra); it }
  show math.equation.where(block: true): it => {
    set text(size: equation-size)
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
  show figure.where(kind: raw): it => { v(code-figure-above); it }
  show figure.caption: it => context {
    set align(center)
    set text(size: caption-size, top-edge: body-top-edge, bottom-edge: body-bottom-edge)
    if it.numbering != none {
      let supplement = if it.supplement != none { [#it.supplement ] }
      text(font: o.heading-font, size: caption-size, weight: "bold", fill: o.accent)[
        #supplement#it.counter.display(it.numbering).]
      [ ]
    }
    it.body
  }
  // Native ref evaluates contextual numbering at the reference location.
  // Resolve both counters at the target, including references across chapters.
  show ref: it => context {
    let targets = query(it.target)
    let target = targets.at(0, default: none)
    let ours = target != none and (
      target.func() == math.equation and target.numbering == equation-numbering
      or target.func() == figure and (
        target.kind in ("theorem", "question") or target.numbering == figure-numbering
      )
    )
    if it.form == "normal" and targets.len() == 1 and ours {
      let supplement = if it.supplement == auto {
        if target.func() == figure and target.kind == "question" {
          o.labels.question
        } else if target.func() == figure and target.kind == "theorem" {
          o.labels.at(target.body.value.kind)
        } else { target.supplement }
      } else if type(it.supplement) == function {
        it.supplement(target)
      } else { it.supplement }
      let prefix = if supplement != none and supplement != [] { [#supplement~] } else { [] }
      link(target.location(), [#prefix#number-at(o, target)])
    } else { it }
  }
  show figure.where(kind: "question"): show-question
  show figure.where(kind: "theorem"): show-statement
  body
}
