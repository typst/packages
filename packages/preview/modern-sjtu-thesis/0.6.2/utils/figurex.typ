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
#import "style.typ": zihao

#let preset(
  body,
) = {
  show ref: it => {
    if it.element != none and it.element.func() == figure and it.element.kind == "subimage_" {
      "(" + it + ")"
    } else { it }
  }
  body
}

#let show-subimages(
  body,
  english-gap: false,
) = {
  show figure.where(kind: "subimage"): it => {
    let parent = query(figure.where(outlined: true).before(it.location())).last()
    let generated-label = if parent != none {
      str(parent.label) + ":" + str(it.label)
    } else {
      str(it.label)
    }
    [
      #figure(
        it.body,
        caption: it.counter.display("(a)") + " " + it.caption.body,
        kind: it.kind + "_",
        supplement: it.supplement,
        outlined: it.outlined,
        numbering: "(a)",
        gap: 1em,
      )#label(generated-label)
    ]
  }

  show figure.where(kind: "subimage-en"): it => {
    let result = [
      #figure(
        it.body,
        caption: if it.caption != none {
          it.counter.display("(a)") + " " + it.caption.body
        } else {
          none
        },
        kind: it.kind + "_",
        supplement: it.supplement,
        outlined: it.outlined,
        numbering: "(a)",
        gap: 1em,
      )
    ]
    if english-gap { result + v(0.5em) } else { result }
  }

  body
}

#let notes = state("notes", ())
#let table-note(text) = {
  notes.update(s => {
    s.push(text)
    s
  })
  context super(numbering("a", notes.get().len()))
}

#let tablex(
  ..body,
  header: (),
  alignment: auto,
  column-gutter: auto,
  columns: auto,
  fill: none,
  inset: 0% + 5pt,
  row-gutter: auto,
  rows: auto,
  stroke: none,
  caption: auto,
  caption-en: none,
  placement: none,
  breakable: true,
  size: zihao.wuhao,
  label-name: "",
) = context {
  set figure.caption(position: top)
  show table: set text(size: size)
  show table: set par(leading: 1em)
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
        [
          #table(
            columns: columns,
            align: alignment,
            inset: inset,
            stroke: stroke,
            row-gutter: row-gutter,
            column-gutter: column-gutter,
            fill: fill,
            table.header(
              table.cell(
                colspan: if type(columns) == int { columns } else { columns.len() },
                {
                  context if nxt.get() {
                    set align(left)
                    text(weight: "bold")[续#ref(head-label)]
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
            table.hline(),
          )
          #context for (i, e) in notes.get().enumerate() {
            set par(leading: 7pt, spacing: 7pt, first-line-indent: 0em)
            set align(left)
            if i == 0 {
              v(-1em)
            }
            text(zihao.xiaowu, weight: "regular")[#super(numbering("a", i + 1)) #h(.3em) #e]
          }
          #notes.update(())
        ],
        gap: 1em,
        caption: caption-en,
        kind: "table-en",
        supplement: [Table],
      ),
      gap: 1em,
      caption: caption,
      kind: "table",
      placement: placement,
      supplement: [表],
    )#new-label
  ]
}

#let algox(
  content,
  caption: none,
  caption-en: none,
  label-name: "",
  breakable: true,
) = context {
  let prefix = "algox-none-label"
  let number = query(figure.where(kind: "algorithm").before(here()))
  let label-name = if label-name == "" { str("~" + prefix + "-" + str(number.len())) } else { label-name }
  let nxt = state("algox" + label-name, false)
  let new-label = label(label-name)
  let head-label = label("algo:" + label-name)
  set par(leading: 23pt - 1em, spacing: 23pt - 1em)
  show figure: set block(width: 100%)
  show figure.caption: set align(left)

  set table(stroke: none)
  show figure: set block(breakable: breakable)

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
            } else {
              set align(left)
              set text(weight: "bold")
              v(-0.5em)
              line(start: (-5pt, 0pt), length: 100% + 11pt)
              v(-0.3em)
              [
                #figure(
                  figure(
                    { if caption-en != none { v(.5em) } else { v(-0.5em) } },
                    kind: "algorithm-en",
                    caption: caption-en,
                    supplement: [Algorithm],
                    gap: 1em,
                  ),
                  kind: "algorithm",
                  caption: caption,
                  supplement: [算法],
                  gap: 1em,
                )#new-label
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
  alignx: center + bottom,
) = context {
  let prefix = "subimagex-none-label"
  let number = query(figure.where(kind: "subimage").before(here()))
  let label-name = if label-name == "" { str("~" + prefix + "-" + str(number.len())) } else { label-name }
  let new-label = label(label-name)
  align(
    alignx,
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
  placement: none,
  breakable: false,
  label-name: "",
) = context {
  let prefix = "imagex-none-label"
  let number = query(figure.where(kind: "image").before(here()))
  let label-name = if label-name == "" { str("~" + prefix + "-" + str(number.len())) } else { label-name }
  let new-label = label(label-name)
  [
    #figure(
      [
        #figure(
          table(..body, columns: columns, row-gutter: 1em, column-gutter: 1em, stroke: none),
          caption: caption,
          kind: "image",
          supplement: [图],
          gap: 0.5em,
        )#new-label
      ],
      gap: 1em,
      placement: placement,
      caption: caption-en,
      kind: "image-en",
      supplement: [Figure],
    )
  ]
  counter(figure.where(kind: "subimage")).update(0)
  counter(figure.where(kind: "subimage-en")).update(0)
  counter(figure.where(kind: "subimage_")).update(0)
}
