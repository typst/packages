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

    if it.location().position() in titles-positions {
      it.body

 }else if it.location().position() in sections-positions {
  pagebreak()
      grid(
        columns: 1fr,
        rows: 1fr,
        align: center + horizon,
        text(size: 50pt, it.body)
      )
      pagebreak()
     
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

    align(
      center,
      box(
        width: 100%,
        inset: 0.75cm,

        radius: 0.2cm,
        stroke: 1pt,
        [



          #if title_array.at(0).len() > 0 {
            place(
              dy: -1.1cm,

              [
                #rect(fill: white)[
                  #text(size: 1.5em, [*#title_array.at(0)*])
                ]
              ],
            )
          }




          #{
            let title-content = text(size: 1.6em)[#heading(depth: 1)[*#title_array.at(1)*] <title>]

            if title_array.at(1).len() > 0 {
              place(
                dy: 0.3cm,
                dx: 50% - measure(title-content).width / 2,
                [
                  #rect(fill: white, title-content)
                ],
              )
            }
          }

        ],
      ),
    )


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






