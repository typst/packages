#let ind = metadata("lovelace indent")
#let ded = metadata("lovelace dedent")
#let no-number = metadata("lovelace no number")

#let pseudocode(
  line-numbering: true,
  line-number-transform: it => it,
  indentation-guide-stroke: none,
  ..children
) = {
  let lines = ()
  let indentation = 0
  let line-no = 1
  let curr-label = none
  let numbered-line = true
  let indentation-box = box.with(
    inset: (left: 1em, rest: 0pt),
    stroke: (left: indentation-guide-stroke, rest: none)
  )
  let rep-app(fn, init, num) = {
    let x = init
    for i in range(num) {
      x = fn(x)
    }
    x
  }

  for child in children.pos() {
    if child == ind {
      indentation += 1
    } else if child == ded {
      indentation -= 1
    } else if child == no-number {
      numbered-line = false
    } else if type(child) == "label" {
      curr-label = child
    } else {
      lines.push((
        no: if numbered-line and line-numbering {
          align(right + horizon)[
            #figure(
              kind: "lovelace-line-no",
              supplement: "Line",
              [#line-number-transform(line-no)]
            )
            #curr-label
          ]
        },
        line: rep-app(
          indentation-box,
          pad(left: -2pt, rest: 4pt, child),
          indentation
        )
      ))
      if numbered-line {
        line-no += 1
      }
      curr-label = none
      numbered-line = true
    }
  }

  set par(hanging-indent: .5em)
  let columns = if line-numbering { 2 } else { 1 }
  let cells = if line-numbering {
    lines.map(line => ( line.no, line.line ) ).flatten()
  } else {
    lines.map(line => line.line)
  }
  
  grid(
    columns: columns,
    column-gutter: 1em,
    row-gutter: .0em,
    ..cells
  )
}

#let algorithm = figure.with(kind: "lovelace", supplement: "Algorithm")

#let setup-lovelace(
  line-number-style: text.with(size: .7em),
  line-number-supplement: "Line",
  body
) = {
  show ref: it => if (
    it.element != none and
    it.element.func() == figure and
    it.element.kind == "lovelace-line-no"
  ) {
    link(
      it.element.location(),
      { line-number-supplement; sym.space; it.element.body }
    )
  } else {
    it
  }
  show figure.where(kind: "lovelace-line-no"): it => line-number-style(it.body)
  show figure.where(kind: "lovelace"): it => {
    let booktabbed = block(
      stroke: (y: 1.3pt),
      inset: 0pt,
      breakable: true,
      width: 100%,
      {
        set align(left)
        block(
          inset: (y: 5pt),
          width: 100%,
          stroke: (bottom: .8pt),
          {
            strong({
              it.supplement
              sym.space.nobreak
              counter(figure.where(kind: "lovelace")).display(it.numbering)
              [: ]
            })
            it.caption
          }

        )
        block(
          inset: (bottom: 5pt),
          breakable: true,
          it.body
        )
      }
    )
    let centered = pad(x: 5%, booktabbed)
    if it.placement in (auto, top, bottom) {
      place(it.placement, float: true, centered)
    } else {
      centered
    }
  }

  body
}

#let comment(body) = {
  h(1fr)
  text(size: .7em, fill: gray, sym.triangle.stroked.r + sym.space + body)
}

