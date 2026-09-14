#import "@preview/cuti:0.3.0": show-cn-fakebold

#let mainmatter(
  margin: (
    top: 3cm,
    bottom: 2cm,
    outside: 2cm,
    inside: 4cm,
  ),
  type: "A卷",
  seed: 1,
  font: ("Times New Roman", "KaiTi"),
  font-size: 13pt,
  show-answer: false,
  mono-font: 13pt,
  mono-font-size: 13pt,
  frame: true,
  double-page: true,
  frame-stroke: (0.4pt + black),
  student-info: ("班级", "姓名", "学号"),
  ..args,
  it,
) = {
  set text(font: font, size: font-size)
  show raw: it => text(font: mono-font, size: mono-font-size, it)
  show: show-cn-fakebold
  set page(
    margin: if double-page { margin } else {
      (top: margin.top, bottom: margin.bottom, left: margin.inside, right: margin.outside)
    },
  )
  set underline(offset: 1.5pt, stroke: 1pt)
  set par(justify: true)

  set page(
    header: context {
      if calc.odd(counter(page).get().last()) or not double-page {
        place(
          dy: page.height,
          dx: -margin.inside + 0.5em,
          rotate(
            -90deg,
            place(
              box(stroke: none, height: margin.inside, width: page.height)[
                #align(center)[
                  #let column-width = (100 / (student-info.len() + 1)) * 1%
                  #grid(
                    columns: (column-width,) * student-info.len(),
                    ..student-info.map(field => field + ": " + box(stroke: (bottom: 0.5pt), width: 50%))
                  )

                  #text(size: 8pt)[（密封线外不要写姓名、学号、班级、密封线内不准答题，违者按零分计）]

                  #box(stroke: none, width: 100%)[
                    #set text(size: 10pt)
                    #place(dy: -0.3em, line(start: (5%, 0%), end: (95%, 0%), stroke: (dash: "dash-dotted")))
                    #place(dx: 4cm, dy: -0.6em, grid(
                      columns: (1fr,) * 3,
                      [#box(fill: white)[密]], [#box(fill: white)[封]], [#box(fill: white)[线]]
                    ))
                  ]
                ]],
            ),
          ),
        )
      }
    },

    numbering: (..nums) => {
      let numArr = nums.pos().map(str)
      let pg = [#type 第 #numArr.at(0) 页，共 #numArr.at(1) 页]
      let m = measure(pg)
      place(dx: 50% - m.width / 2, dy: -margin.bottom / 2 + m.height + 1em, text(size: 11pt, pg))
    },

    background: context if frame {
      let p = counter(page).get().first()
      place(
        dx: if calc.odd(p) or not double-page { margin.inside - 1em } else { margin.outside / 2 },
        dy: 2.5cm,
        rect(width: 100% - margin.inside - margin.outside + 4em, height: 100% - margin.bottom - margin.top + 1em, stroke: frame-stroke),
      )
    },
  )


  it
}
