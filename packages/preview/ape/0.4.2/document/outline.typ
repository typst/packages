#import "../tools/miscellaneous.typ": content-to-string

#let get-local-outline() = context {
  let depthsMap = (1,) * 20

  set par(justify: true, spacing: 5pt)
  set text(size: 10pt)

  let start = false
  let here-page = here().position().page

  let titles-positions = query(<title>).map(t => t.location().position())


  block(
    width: 100%,
    inset: 20pt,
    grid(
      columns: (auto, 20fr, 1fr),
      column-gutter: (12pt, 5pt),
      row-gutter: 7pt,
      align: (left, left, bottom),

      ..for e in query(heading) {
        if content-to-string(e) != "" {
          let dotFill(c, correctif) = context {
            layout(size => {
              let w = size.width + correctif

              let filled = box(width: w, c + box(width: 1fr, repeat[.]))

              [#filled]
            })
          }
          if (e.location().page() >= here-page) {
            if (e.location().position() in titles-positions) {
              if start == true {
                break
              }
              start = true
            } else if start == true and e.depth == 1 {
              (
                [*#numbering("I", depthsMap.at(0))*],
                link(e.location(), dotFill([*#e.body*], 0pt)),
                [#link(e.location(), str(e.location().page()))],
              )


              depthsMap.at(0) += 1
              depthsMap = (depthsMap.at(0),) + (1,) * 20
            }
          }
        }
      }
    ),
  )
}


#let get-outline(lang, small-caps, outline-max-depth) =   {
  let sc(c) = {
    if small-caps == true {
      return smallcaps(c)
    } else {
      return c
    }
  }
  let first-real-pages = array(bytes(""))

  let titles-positions = query(<title>).map(t => t.location().position())
  let sections-positions = query(<section>).map(t => t.location().position())

  let custom-outline = {
    set text(hyphenate: true)

    align(center, [

      #{
        if lang == "fr" {
          text(size: 2.5em, sc[
            *Table des matières*
          ])
        } else {
          text(size: 2.5em, sc[
            *Table of content*
          ])
        }
      }
    ])


    let depthsMap = (1,) * 20

    set par(justify: true, spacing: 5pt)

    grid(
      columns: (auto, 20fr, 1fr),
      column-gutter: (12pt, 5pt),
      row-gutter: 7pt,
      align: (left, left, bottom),

      ..for e in query(heading) {
        if content-to-string(e) != "" {
          let dotFill(c, correctif) = context {
            layout(size => {
              let w = size.width + correctif

              let filled = box(width: w, c + box(width: 1fr, repeat[.]))

              [#filled]
            })
          }
          let pos = e.location().position()
          if  (pos in sections-positions){
            ([], [], [])
            ([], [], [])
            ([], [], [])
            ([], [], [])
            ([], [], [])
            ([], link(e.location(), text(size: 17pt, [*#e.body*])), [])
          } else if (pos in titles-positions) {
            if titles-positions.len() >= 2 {
              depthsMap = (1,) * 20
              ([], [], [])
              ([], [], [])
              ([], link(e.location(), text(size: 12pt, e.body)), [])
            }

            first-real-pages.push(e.location().page())
          } else if e.depth == 1 {
            if outline-max-depth <= 1 {
              (
                numbering("I", depthsMap.at(0)),
                link(e.location(), dotFill(e.body, 0pt)),
                [#link(e.location(), str(e.location().page()))],
              )
            } else {
              (
                [*#numbering("I", depthsMap.at(0))*],
                link(e.location(), dotFill([*#e.body*], 0pt)),
                [#link(e.location(), str(e.location().page()))],
              )
            }


            depthsMap.at(0) += 1
            depthsMap = (depthsMap.at(0),) + (1,) * 20
          } else if (e.depth <= outline-max-depth) {
            let style = "1."
            if e.depth == 3 { style = "a." }
            if e.depth == 4 { style = "i." }

            (
              [],
              link(e.location(), grid(
                columns: ((e.depth - 1) * 2em, 100% - ((e.depth - 1) * 2em)),
                align: (right, left),
                column-gutter: 10pt,
                [#numbering(style, depthsMap.at(e.depth - 1))], box(clip: false)[#dotFill(e.body, -10pt)],
              )),
              [#link(e.location(), str(e.location().page()))],
            )

            depthsMap.at(e.depth - 1) += 1
            depthsMap = depthsMap.slice(0, e.depth) + (1,) * 15
          }
        }
      }
    )
  }

  return (first-real-pages, custom-outline)
}
