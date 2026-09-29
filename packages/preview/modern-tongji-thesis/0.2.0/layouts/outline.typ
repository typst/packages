// Table of contents — matches LaTeX \tableofcontents
#let make-outline(title: "目 录", depth: 3, indent: true) = {
  heading(title, numbering: none, outlined: false)
  set par(first-line-indent: 0pt, leading: 1.2em)
  context {
    let elements = query(heading.where(outlined: true))

    for el in elements {
      if depth != none and el.level > depth { continue }

      let el_number = if el.numbering != none {
        numbering(el.numbering, ..counter(heading).at(el.location()))
        h(0.5em)
      }

      let line = {
        if indent {
          let indent-width = if el.level == 1 {
            0pt
          } else if el.level == 2 {
            2em
          } else if el.level == 3 {
            4em
          } else {
            0pt
          }
          h(indent-width)
        }

        link(el.location(), el_number)
        link(el.location(), el.body)
        box(width: 1fr, repeat[.])
        link(el.location(), str(counter(page).at(el.location()).first()))
        linebreak()
      }

      line
    }
  }
}
