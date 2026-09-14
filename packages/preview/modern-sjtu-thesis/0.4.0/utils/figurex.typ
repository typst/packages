/*
 * figurex.typ
 *
 * @project: SHU-Bachelor-Thesis-Typst
 * @author: shuosc
 *
 * Copyright 2025 SHUOSC. All rights reserved.
 * Licensed under the Apache License, Version 2.0
 */

#import "@preview/i-figured:0.2.4"
#import "style.typ": ziti, zihao
#let preset(
  body,
) = {
  show ref: it => {
    if it.element != none and it.element.func() == figure and it.element.kind == "subimage_" {
      let q = query(figure.where(outlined: true).before(it.target)).last()
      ref(q.label)
    }
    if it.element != none and it.element.func() == figure and it.element.kind == "subimage_" {
      "(" + it + ")"
    } else { it }
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
  caption-en: none,
  breakable: true,
  label-name: "",
) = context {
  set figure.caption(position: top)
  show table: set text(size: zihao.wuhao, weight: "regular")
  set table(stroke: none)
  let prefix = "tablex-none-label"
  let number = query(figure.where(kind: "table").before(here()))
  let label-name = if label-name == "" { str("~" + prefix + "-" + str(number.len())) } else { label-name }
  let nxt = state("tablex" + label-name, false)
  let new-label = label(label-name)
  let head-label = label("tbl:" + label-name)
  [
    #show figure: set block(breakable: breakable)
    #figure(
      figure(
        table(
          columns: columns,
          align: alignment,
          inset: (y: 0.65em),
          table.header(
            table.cell(
              colspan: if type(columns) == type(int) { columns } else { columns.len() },
              {
                context if nxt.get() {
                  set align(left)
                  text(weight: "bold")[续#ref(head-label)]
                  nxt.update(false)
                } else {
                  v(-1em)
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
        caption: caption-en,
        kind: "table-en",
        supplement: [Table],
      ),
      gap: 1em,
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
  let number = query(figure.where(kind: "algorithm").before(here()))
  let label-name = if label-name == "" { str("~" + prefix + "-" + str(number.len())) } else { label-name }
  let new-label = label(label-name)
  let head-label = label("algo:" + label-name)
  let nxt = state("algox" + label-name, false)
  set par(leading: 23pt - 1em, spacing: 23pt - 1em)
  show figure: set block(width: 100%)
  show figure.caption: set align(left)

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
              set text(weight: "bold")
              [续#ref(head-label)]
              nxt.update(false)
            } else {
              set align(left)
              set text(weight: "bold")
              v(-0.5em)
              line(start: (-5pt, 0pt), length: 100% + 15pt)
              v(-0.3em)
              [
                #figure(
                  [],
                  kind: "algorithm",
                  caption: caption,
                  supplement: [算法],
                )#new-label
                #v(0.3em)
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
  caption-en: none,
  label-name: "",
) = context {
  let prefix = "subimagex-none-label"
  let none-label = state(prefix, 0)
  let number = query(figure.where(kind: "subimage").before(here()))
  let label-name = if label-name == "" { str("~" + prefix + "-" + str(number.len())) } else { label-name }
  let new-label = label(label-name)
  align(
    center + bottom,
    figure(
      [
        #figure(
          body,
          caption: caption,
          kind: "subimage",
          supplement: none,
          numbering: "(a)",
          outlined: false,
        )#new-label
      ],
      outlined: false,
      caption: caption-en,
      kind: "subimage-en",
      supplement: none,
      numbering: "(a)",
    ),
  )
}

#let imagex(
  ..body,
  caption: auto,
  caption-en: none,
  columns: auto,
  breakable: false,
  label-name: "",
) = context {
  let prefix = "imagex-none-label"
  let none-label = state(prefix, 0)
  let number = query(figure.where(kind: "image").before(here()))
  let label-name = if label-name == "" { str("~" + prefix + "-" + str(number.len())) } else { label-name }
  let new-label = label(label-name)
  [
    #figure(
      [
        #figure(
          grid(..body, columns: columns, row-gutter: 1em, column-gutter: 1em),
          caption: caption,
          kind: "image",
          supplement: [图],
          gap: 1em,
        )#new-label
      ],
      gap: 1em,
      caption: caption-en,
      kind: "image-en",
      supplement: [Figure],
    )
  ]
  counter(figure.where(kind: "subimage")).update(0)
  counter(figure.where(kind: "subimage-en")).update(0)
  counter(figure.where(kind: "subimage_")).update(0)
}
