#import "fonts.typ": TJFONT_TABLE, TJFONT_CAPTION
#import "tables.typ": toprule, midrule, bottomrule

#let table-notes-state = state("table-notes", ())
#let table-note(text) = {
  table-notes-state.update(s => {
    s.push(text)
    s
  })
  context super[#table-notes-state.get().len()]
}

#let continued-table(
  header: (),
  columns: auto,
  caption: none,
  lbl-name: none,
  breakable: true,
  ..body-rows,
) = context {
  let ncols = if type(columns) == int { columns } else { columns.len() }
  counter("ctbl-id").step()
  let tid = counter("ctbl-id").get().first()
  let nxt = state("ctbl-" + str(tid), false)
  let lbl = if lbl-name != none { label(lbl-name) } else { none }

  table-notes-state.update(())

  show figure: set block(breakable: breakable)
  show figure.caption: set align(center)
  set figure.caption(position: top)
  show table: set text(size: TJFONT_TABLE)

  figure(
    kind: "table",
    supplement: [表],
    caption: caption,
    [
      #table(
        columns: columns,
        inset: 5pt,
        stroke: none,
        table.header(
          table.cell(
            colspan: ncols,
            context if nxt.get() {
              set align(right)
              set text(size: TJFONT_CAPTION)
              v(0pt)
              let h1 = query(heading.where(level: 1).before(here())).last()
              if h1 != none and h1.body == [附录] {
                let sec = counter(heading).get().at(1, default: 1)
                let fg = counter(figure.where(kind: "table")).get().first()
                [续表 #numbering("A", sec).#fg#h(2em)]
              } else {
                let ch = counter(heading).get().first()
                let fg = counter(figure.where(kind: "table")).get().first()
                [续表 #ch.#fg#h(2em)]
              }
              v(-0.3em)
            } else {
              nxt.update(true)
              v(-0.5em)
              []
            },
          ),
          toprule(),
          ..header,
          midrule(),
        ),
        ..body-rows,
        bottomrule(),
      )
      #context {
        let notes = table-notes-state.get()
        if notes.len() > 0 {
          v(-0.5em)
          for (i, n) in notes.enumerate() {
            set text(size: TJFONT_TABLE)
            set par(first-line-indent: 0pt, leading: 0.5em)
            set align(left)
            super[#(i + 1)] + [ #n]
            v(0.3em)
          }
        }
      }
      #if lbl != none { lbl }
    ],
  )
}
