#import "../tools/miscellaneous.typ": content-to-string

#let code-display(content) = {
  // Code
  show raw: it => context {
    if ("py", "python", "ocaml", "ml").contains(it.lang) {
      let breakableVar = false
      let lines = (..it.lines,)



			// Remove empty lines at the beginning and end
      while lines.len() > 0 and content-to-string(lines.first()).trim() == "" {
        lines.remove(0)
      }
      while lines.len() > 0 and content-to-string(lines.last()).trim() == "" {
        lines.remove(-1)
      }

      if (it.lines.len() >= 15) {
        breakableVar = true
      }

		 
      block(
        clip: true,
        radius: calc.min(9pt, 4pt + 2pt * lines.len()),
        stroke: text.fill.lighten(50%) + 0.5pt,
        align(
          center,
          block(
            breakable: breakableVar,
            grid(
              columns: (measure([#lines.len()]).width + 10pt, 20fr),
              column-gutter: 0pt,
              inset: ((left: 5pt, right: 5pt, rest: 3pt), (left: 10pt, rest: 3pt)),
              align: (horizon + left, left),
              fill: (text.fill.lighten(75%), text.fill.lighten(88%)),
              [],
              [],
              ..for i in range(lines.len()) {
                let l = lines.at(i)
                (str(i + 1), l.body)
              },
              [],
              [],
            ),
          ),
        ),
      )
    } else {
      it
    }
  }
  content
}
