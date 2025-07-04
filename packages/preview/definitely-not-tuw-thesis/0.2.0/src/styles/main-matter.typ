#let main-matter-styles = rest => {
  set page(numbering: "1")
  set heading(numbering: "1.")
  counter(page).update(1)
  counter(heading).update(0)

  let calc-margin(margin, shape) = if margin == auto {
    2.5 / 21 * calc.min(..shape)
  } else {
    margin
  }

  show heading.where(level: 1): it => {
    if it.numbering == "1." {
      pagebreak(weak: true)
      set align(right)
      set text(
        size: 1.3em,
        weight: "regular",
      )
      block(
        above: 20pt,
        below: 50pt,
        context {
          let title-content = {
            smallcaps(
              [
                Chapter
                #text(size: 4em)[#counter(heading).display("1")]
              ]
            )
          }
          box[
            #title-content
            #place(
              dx: calc-margin(page.margin, (page.width, page.height)),
              horizon + right,
              rect(
                fill: gradient.linear(black.lighten(50%), black),
                height: measure(title-content).height,
              ),
            )
          ]
          v(10pt)
          text(size: 1.3em)[*#it.body*]
        }
      )
    } else {
      it
    }
  }

  rest
}
