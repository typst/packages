#import "../../tools/miscellaneous.typ": content-to-string
#let numbered(content) = {
  set text(10pt)

  set heading(numbering: "I)1)a)i)")

  show heading: it => {
    if content-to-string(it) == "audhzifoduiygzbcjlxmwmwpadpozieuhgb" {
      return none
    }
    set par(spacing: 15pt)
    if it.numbering != none {
      let n = it.level - 1
      set text(size: 15pt - 1pt * n)

      block(
        sticky: true,
        h(1cm * n)
          + ([
            #counter(heading).display(it.numbering).split(")").at(-2) -- #it.body

          ]),
      )
    }
  }

  content
}


#let get-small-title(title) = context {

    return {
      
      v(0.5cm)
      
      align(
      center,
      box(
        width: 100%,
        inset: 0.75cm,

        radius: 0.2cm,
        stroke: 1pt,
        [



          #place(
            dy: -1.2cm,
            [
              #rect(fill: white)[
                #text(size: 16pt, [*#title.at(0)*])
              ]
            ],
          )




          #{
            if title.at(1).len() > 0 {
              place(
                dy: 0.3cm,
                dx: 99% - measure(text(size: 18pt, [*#title.at(1)*])).width,
                [
                  #rect(fill: white)[
                    #text(size: 18pt, [*#title.at(1)*])
                  ]
                ],
              )
            }
          }

        ],
      ),
    )
    v(1.2cm)
  }

  
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






