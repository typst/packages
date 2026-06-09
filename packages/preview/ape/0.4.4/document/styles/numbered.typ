#import "../../tools/miscellaneous.typ": content-to-string
#let numbered(content, style) = context {
  let get-page-style = {
    if style == "numbered-book" {
      (
        width: 16cm,
        height: 24cm,
      )
    } else {
      (
        paper: "a4",
      )
    }
  }

  set page(..get-page-style)


  set text(size: if style == "numbered-book" {
    8pt
  } else {
    10pt
  })

  set heading(numbering: "I)1)a)i)")


  show heading: it => context {
    let titles-positions = query(<title>).map(t => t.location().position())
    let sections-positions = query(<section>).map(t => t.location().position())
    let subsections-positions = query(<subsection>).map(t => t.location().position())

    if it.location().position() in titles-positions {
      it.body
    } else if it.location().position() in sections-positions {
      pagebreak()
      grid(
        columns: 1fr,
        rows: 1fr,
        align: center + horizon,
        text(size: 50pt, it.body)
      )
      pagebreak()
    } else if it.location().position() in subsections-positions {
      pagebreak()

      align(center, text(size: 22pt, it.body))

      v(0.75cm)
    } else {
      set par(spacing: 15pt)
      if it.numbering != none {
        let n = it.level - 1
        set text(size: 1.2em - 0.1em * n)

        block(
          sticky: true,
          h(0.8cm * n)
            + (
              [
                #counter(heading).display(it.numbering).split(")").at(-2) -- #it.body

              ]
            ),
        )
      }
    }
  }

  content
}


#let get-small-title(title, authors) = context {
  return {
    v(2cm)
    let title_array = ()
    if (type(title) == array) {
      title_array = title
    } else {
      title_array = ("", title)
    }

    layout(layout-size => {
      let title-content = align(center, text(size: 1.5em)[#heading(depth: 1)[*#title_array.at(1)*] <title>])

      let w = calc.min(measure(title-content).width, layout-size.width * 0.75) + 10pt

      let box-1 = [
        #rect(fill: white)[
          #text(size: 1.5em)[*#title_array.at(0)*]
        ]
      ]
      let box-2 = box(width: w, align(center, rect(fill: white, title-content)))

      let h = measure(box-2).height

      align(
        center,
        box(
          width: 100%,

          inset: 0.6cm,

          radius: 0.2cm,
          stroke: 1pt,
          [

            #v(h / 2)

            #if title_array.at(0).len() > 0 {
              place(
                dy: -0.95cm - h / 2,

                box-1,
              )
            }


            #{
              if title_array.at(1).len() > 0 {
                place(
                  dy: 0.55cm - h / 2,
                  dx: 50% - w / 2,
                  box-2,
                )
              }
            }

          ],
        ),
      )
    })


    v(1.35cm)
  }


  /*
  return {
    line(length: 100%)
    text(
      size: 2em,
      font: "Noto Sans Georgian",
      align(
        center,
        if type(title) == array [
          *#title.at(0) - #title.at(1)*
        ] else [
          *#title*
        ],
      ),
    )


    line(length: 100%)
    v(15pt)
  }
  */
}






