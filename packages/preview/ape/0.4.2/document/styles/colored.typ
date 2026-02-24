#import "../../tools/miscellaneous.typ": content-to-string
#let colored(content) = {
  set text(12pt, fill: blue.darken(50%), weight: "extrabold")


  show heading: it => {
    if content-to-string(it) == "" {
      return none
    }

    let cl = blue.darken(20% - 20% * (it.level - 1))

    block(breakable: false)[
      #h(20pt * (it.depth - 1))
      #{ text(fill: cl)[*▸*] }
      #text(fill: cl, it.body)
      #place(
        dy: -6pt + measure(it.body).height,
        line(
          length: 100%,
          stroke: (
            thickness: calc.max(1pt, calc.min(4pt, 4pt - 1pt * it.level)),
            paint: gradient.linear(cl, cl.lighten(70%)),
            cap: "round",
          ),
        ),
      )
      #v(7pt)
    ]
  }

  content
}

#let get-small-title(title, authors) = context {
 

  return {
    line(length: 100%, stroke: 2pt + text.fill)
    text(
      font: "Noto Sans Georgian",
      align(
        left,
        if type(title) == array [
          ▸ *#emph(text(size: 1.5em, title.at(0)))* 
           #align(center, text(size: 2em)[ *#title.at(1)*  ])
        ] else [
          *#title*
        ],
      ),
    )


    line(length: 100%, stroke: 2pt + text.fill)
    v(15pt)
  }
}
