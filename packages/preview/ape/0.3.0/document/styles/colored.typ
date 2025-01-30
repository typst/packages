#import "../../tools/miscellaneous.typ" : content-to-string
#let colored(content) = {
  set text(12pt)


  show heading: it => {
    if content-to-string(it) == "audhzifoduiygzbcjlxmwmwpadpozieuhgb" {
      return none
    }

  let cl = blue.darken(20% - 20% * (it.level - 1))

    block(breakable: false)[
      #h(20pt * (it.depth - 1))
      #{text(fill: cl)[*▸*]}
       #text(fill: cl, it.body)
      #place(
        dy: -6pt + measure(it.body).height,
        line(
          length: 100%,
          stroke: (
            thickness: calc.max(1pt, calc.min(4pt, 4pt - 1pt * it.level)),
            paint : cl,
            cap: "round",
          )
        ),
      )
    ]
  }

  content
}
