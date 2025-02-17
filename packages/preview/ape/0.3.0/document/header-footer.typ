#import "../tools/miscellaneous.typ": to-array
#let header-footer(style, small-caps, first-real-page, authors, content) = {
  
 
 
  if style == "presentation" {
    return content
  }

  let sc(c) = {
    if small-caps == true {
      return smallcaps(c)
    } else {
      return c
    }
  }


  set page(
    header: context {
      if (counter(page).get().at(0) > first-real-page and to-array(authors).len() > 0) {
        [
          #set text(size: 9pt)
          #grid(
            columns: (1fr, 2fr),
            align(left, sc(to-array(authors).at(0))), align(right, to-array(authors).slice(1).map(sc).join(" - ")),
          )
          #place(dy: 3.5pt, line(length: 100%, stroke: 0.5pt + text.fill))
        ]
      }
    },

    footer: context {
      if (counter(page).get().at(0) >= first-real-page) {
        [
          #place(dy: -0.25cm, line(length: 100%, stroke: 0.5pt + text.fill))
          #set align(center)


          _Page #counter(page).display() / #counter(page).final().at(0)_

        ]
      }
    },
  )

  content
}
