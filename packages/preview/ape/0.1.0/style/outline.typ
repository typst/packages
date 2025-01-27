#let get-outline(lang) = {
  let first-real-page = 0
  let custom-outline = {
    set text(size: 10pt, hyphenate: true)

    align(
      center,

      [
        #set text(size: 22pt)
        #{
          if lang == "fr" [
            Table des matières
          ]else[
            Table of contents
          ]
        }
      ],
    )


    let depthsMap = (1,) * 20

    set par(justify: true, spacing: 5pt)

    v(1cm)
    grid(
      columns: (1.2fr, 20fr, 1fr),
      column-gutter: 8pt,
      row-gutter: 9pt,
      align: (left, left, bottom),

      ..for e in query(heading) {
        if first-real-page == 0 {
          first-real-page = e.location().page()
        }

        if e.body.text != "audhzifoduiygzbcjlxmwmwpadpozieuhgb" {
          let dotFill(c, correctif) = context {
            layout(size => {
              let w = size.width + correctif

              let filled = box(width: w, c + box(width: 1fr, repeat[.]))

              [#filled]
            })
          }


          if e.depth == 1 {
            (
              numbering("I", depthsMap.at(0)),
              link(e.location(), dotFill([*#e.body*], 0pt)),
              [#link(e.location(), str(e.location().page()))],
            )


            depthsMap.at(0) += 1
            depthsMap = (depthsMap.at(0),) + (1,) * 20
          } else {
            let style = "1."
            if (e.depth == 3) { style = "a." }
            if e.depth == 4 { style = "i." }

            (
              [],
              link(
                e.location(),
                grid(
                  columns: ((e.depth - 1) * 20pt, 100% - ((e.depth - 1) * 20pt)),
                  align: (right, left),
                  column-gutter: 10pt,
                  [#numbering(style, depthsMap.at(e.depth - 1))], [#dotFill(e.body, -10pt)],
                ),
              ),
              [#link(e.location(), str(e.location().page()))],
            )

            depthsMap.at(e.depth - 1) += 1
            depthsMap = depthsMap.slice(0, e.depth) + (1,) * 15
          }
        }
      }
    )
  }

  return (first-real-page, custom-outline)
}
