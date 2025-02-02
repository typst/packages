#import "../../tools/miscellaneous.typ": content-to-string
#let colored(content) = {
  set text(12pt, fill: blue.darken(50%))


  show heading: it => {
    if content-to-string(it) == "audhzifoduiygzbcjlxmwmwpadpozieuhgb" {
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

#let get-small-title(title) = context {
  return {
    line(length: 100%, stroke: 2pt + text.fill)
    text(
      size: 2em,
      font: "Noto Sans Georgian",
      align(
        center,
        if type(title) == "array" [
          *#title.at(0) - #title.at(1)*
        ] else [
          *#title*
        ],
      ),
    )


    line(length: 100%, stroke: 2pt + text.fill)
    v(15pt)
  }
}
