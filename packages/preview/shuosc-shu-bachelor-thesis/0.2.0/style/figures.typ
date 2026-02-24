#import "@preview/i-figured:0.2.4"
#import "font.typ": ziti, zihao
#let preset(
  body,
) = {
  show ref: it => {
    if it.element != none and it.element.func() == figure and it.element.kind == "subimage_" {
      let q = query(figure.where(outlined: true).before(it.target)).last()
      ref(q.label)
    }
    it
  }
  body
}

#let figures(
  appendix: false,
  math-level: 2,
  body,
) = {
  show figure: set align(center)
  show table: set align(center)

  show heading: i-figured.reset-counters.with(extra-kinds: ("image", "table", "algorithm"))
  show figure: i-figured.show-figure.with(
    extra-prefixes: (
      image: "img:",
      algorithm: "algo:",
    ),
    numbering: if not appendix { "1.1" } else { "A1" },
  )
  show math.equation: i-figured.show-equation.with(
    numbering: if not appendix { "(1.1)" } else { "(A1)" },
    level: if not appendix { math-level } else { 1 },
  )
  set math.equation(supplement: [公式])

  set figure.caption(separator: [#h(1em)])
  show figure.caption: set text(font: ziti.heiti, size: zihao.xiaosi, weight: "bold")

  show figure.where(kind: "subimage"): it => {
    if it.kind == "subimage" {
      let q = query(figure.where(outlined: true).before(it.location())).last()
      [
        #figure(
          it.body,
          caption: it.counter.display("(a)") + it.caption.body,
          kind: it.kind + "_",
          supplement: it.supplement,
          outlined: it.outlined,
          numbering: "(a)",
        )#label(str(q.label) + ":" + str(it.label))
      ]
    }
  }

  show figure.where(kind: "subimage_"): it => {
    let q = query(selector(figure).before(it.location())).last()
    if (q.kind == "image") {
      it.counter.update(0)
    }
    it
  }

  body
}

#let tablex(
  ..body,
  header: (),
  alignment: auto,
  column-gutter: auto,
  columns: auto,
  fill: none,
  gutter: auto,
  inset: 0% + 5pt,
  row-gutter: auto,
  rows: auto,
  stroke: 1pt + black,
  caption: auto,
  breakable: true,
  label-name: "",
) = context {
  set figure.caption(position: top)
  show table: set text(size: zihao.wuhao, weight: "regular")
  set table(stroke: none)
  let prefix = "tablex-none-label"
  let none-label = state(prefix, 0)
  let label-name = label-name
  if label-name == "" {
    let id = int(none-label.get())
    label-name = str("~" + prefix + "-" + str(id))
    none-label.update(id + 1)
  }
  let nxt = state("tablex" + label-name, false)
  let new-label = label(label-name)
  let head-label = label("tbl:" + label-name)
  [
    #show figure: set block(breakable: breakable)
    #figure(
      table(
        columns: columns,
        align: alignment,
        table.header(
          table.cell(
            colspan: if type(columns) == type(int) { columns } else { columns.len() },
            {
              context if nxt.get() {
                set align(left)
                set text(font: ziti.heiti, size: zihao.xiaosi, weight: "bold")
                [续#ref(head-label)]
                nxt.update(false)
              } else {
                v(-0.9em)
                nxt.update(true)
              }
            },
          ),
          table.hline(),
          ..header,
          table.hline(stroke: 0.5pt),
        ),
        ..body,
        table.hline()
      ),
      caption: caption,
      kind: "table",
      supplement: [表],
    )#new-label
  ]
}

#let algox(
  content,
  caption: none,
  label-name: "",
  breakable: true,
) = context {
  let prefix = "algox-none-label"
  let none-label = state(prefix, 0)
  let label-name = label-name
  if label-name == "" {
    let id = int(none-label.get())
    label-name = str("~" + prefix + "-" + str(id))
    none-label.update(id + 1)
  }
  let new-label = label(label-name)
  let head-label = label("algo:" + label-name)
  let nxt = state("algox" + label-name, false)
  set par(leading: 23pt - 1em, spacing: 23pt - 1em)
  [

    #figure(
      [],
      kind: "algorithm",
      supplement: [算法],
    )#new-label
    #v(-1.5em)
  ]
  set table(stroke: none)
  // show figure: set block(breakable: breakable)
  show figure: set block(breakable: true)

  figure(
    table(
      columns: 1fr,
      align: left,
      table.header(
        table.cell(
          colspan: 1,
          {
            context if nxt.get() {
              set align(left)
              set text(font: ziti.heiti, size: zihao.xiaosi, weight: "bold")
              [续#ref(head-label)]
              nxt.update(false)
            } else {
              set align(left)
              set text(font: ziti.heiti, size: zihao.xiaosi, weight: "bold")
              line(start: (-5pt, 0pt), length: 100% + 10pt)
              v(-0.5em)
              [
                #set par(first-line-indent: 0em)
                #ref(head-label)#h(1em)#caption
              ]
              nxt.update(true)
            }
          },
        ),
        table.hline(),
      ),
      content,
      table.hline()
    ),
  )
}

#let subimagex(
  body,
  caption: "",
  label-name: "",
) = context {
  let prefix = "subimagex-none-label"
  let none-label = state(prefix, 0)
  let label-name = label-name
  if label-name == "" {
    let id = int(none-label.get())
    label-name = str("~" + prefix + "-" + str(id))
    none-label.update(id + 1)
  }
  let new-label = label(label-name)
  [
    #figure(
      body,
      caption: caption,
      kind: "subimage",
      supplement: none,
      numbering: "(a)",
      outlined: false,
    )#new-label
  ]
}

#let imagex(
  ..body,
  caption: auto,
  columns: auto,
  breakable: false,
  label-name: "",
) = context {
  let prefix = "subimagex-none-label"
  let none-label = state(prefix, 0)
  let label-name = label-name
  if label-name == "" {
    let id = int(none-label.get())
    label-name = str("~" + prefix + "-" + str(id))
    none-label.update(id + 1)
  }
  let new-label = label(label-name)
  [
    #figure(
      grid(..body, columns: columns, row-gutter: 1em),
      caption: caption,
      kind: "image",
      supplement: [图],
    )#new-label
  ]
}
