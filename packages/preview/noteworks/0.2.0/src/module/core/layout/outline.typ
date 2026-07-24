// Table of contents built from document queries: every chapter cover
// emits a <chapter-cover> anchor and every page a <nw-page> anchor
// (see core/book.typ), so rows and page numbers resolve natively in a
// single compile - no external structure file or page map needed.

#import "../../../core/setup.typ": format-chapter-id, format-page-id, nw-config, nw-theme

#let outline() = {
  page(
    paper: "a4",
    margin: (x: 2.5cm, y: 2.5cm),
  )[
    #std.metadata("outline") <outline>
    #context {
      let theme = nw-theme()
      let c = nw-config()
      let chapters = query(<chapter-cover>)
      let total-chapters = chapters.len()

      [
        #line(length: 100%, stroke: 1pt + theme.text-muted)
        #v(0.5cm)

        #text(
          size: 24pt,
          weight: "bold",
          tracking: 1pt,
          font: c.font,
          fill: theme.text-heading,
        )[Table of Contents]

        #v(0.5cm)
        #line(length: 100%, stroke: 1pt + theme.text-muted)
        #v(1.5cm)
      ]

      for (i, ch) in chapters.enumerate() {
        // Pages of this chapter: <nw-page> anchors between this chapter
        // cover and the next one (or the end of the document)
        let pages = if i + 1 < chapters.len() {
          query(selector(<nw-page>).after(ch.location()).before(chapters.at(i + 1).location()))
        } else {
          query(selector(<nw-page>).after(ch.location()))
        }
        let chap-id = format-chapter-id(i + 1, total-chapters)

        block(breakable: false)[
          #text(
            size: 16pt,
            weight: "bold",
            font: c.font,
            fill: theme.text-accent,
          )[
            #c.chapter-name #chap-id
          ]
          #h(1fr)
          #text(
            size: 16pt,
            weight: "regular",
            style: "italic",
            font: c.font,
            fill: theme.text-main,
          )[
            #ch.value.title
          ]
          #v(0.5em)
          #line(length: 100%, stroke: 0.5pt + theme.text-muted.transparentize(50%))
        ]

        v(0.5em)

        grid(
          columns: (auto, 1fr, auto),
          row-gutter: 0.8em,
          column-gutter: 1.5em,

          ..for (j, pg) in pages.enumerate() {
            let full-id = str(i + 1) + "." + str(j + 1)
            let page-display-id = format-page-id(full-id, pages.len(), total-chapters)
            let page-num = str(counter(page).at(pg.location()).first())

            (
              text(fill: theme.text-muted, font: c.font, weight: "medium")[#c.chapter-name #page-display-id],
              box(width: 100%)[
                #text(font: c.font, fill: theme.text-main)[#pg.value.title]
                #box(width: 1fr, repeat[#text(fill: theme.text-muted.transparentize(70%))[. ]])
              ],
              text(fill: theme.text-muted, font: c.font, weight: "medium")[#page-num],
            )
          }
        )

        v(1.5cm)
      }
    }
  ]
}
