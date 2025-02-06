#let code-display(content) = {
	 // Code

  show raw: it => context {
    if ("py", "python", "ocaml").contains(it.lang) {
      let breakableVar = false
      let lines = (..it.lines,).rev()
      while lines.at(0).text == "" {
        lines = lines.slice(1)
      }
      lines = lines.rev()

      if (it.lines.len() >= 20) {
        breakableVar = true
      }
      if (it.lines.len() >= 5) {
        block(
          clip: true,
          radius: 10pt,
          stroke: gray.darken(20%) + 1pt,
          align(
            center,
            block(
              breakable: breakableVar,
              grid(
                columns: (measure([#it.lines.at(0).count]).width + 10pt, 20fr),
                column-gutter: 0pt,
                inset: ((left: 5pt, right: 5pt, rest: 3pt), (left: 10pt, rest: 3pt)),
                align: (horizon + left, left),
                fill: (gray.lighten(50%), gray.lighten(75%)),
                [],
                [],
                ..for l in lines {
                  (str(l.number), l.body)
                },
                [],
                [],
              ),
            ),
          ),
        )
      } else {
        align(
          center,
          block(
            fill: gray,
            inset: 2pt,
            breakable: false,
            radius: 3pt,
            block(fill: gray.lighten(70%), inset: 16pt, width: 100%, par(it)),
          ),
        )
      }
    }
  }
	content
}