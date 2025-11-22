#import "../tools/miscellaneous.typ": content-to-string
#let get-outline(lang, small-caps) = {
  let sc(c) = {
    if small-caps == true {
      return smallcaps(c)
    } else {
      return c
    }
  }

  let first-real-page = 0
  let custom-outline = {
    set text(hyphenate: true)

    align(
      center,
      [

        #{
          if lang == "fr" {
            text(
              size: 2.5em,
              sc[
                Table des matières
              ],
            )
          } else {
            text(
              size: 2.5em,
              sc[
                Table of content
              ],
            )
          }
        }
      ],
    )


    let depthsMap = (1,) * 20

    set par(justify: true, spacing: 5pt)


    grid(
      columns: (auto, 20fr, 1fr),
      column-gutter: (12pt, 5pt),
      row-gutter: 9pt,
      align: (left, left, bottom),

      ..for e in query(heading) {
        if first-real-page == 0 {
          first-real-page = e.location().page()
        }

        if content-to-string(e) != "audhzifoduiygzbcjlxmwmwpadpozieuhgb" {
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
                  columns: ((e.depth - 1) * 2em, 100% - ((e.depth - 1) * 2em)),
                  align: (right, left),
                  column-gutter: 10pt,
                  [#numbering(style, depthsMap.at(e.depth - 1))], box(clip: true)[#dotFill(e.body, -10pt)],
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
