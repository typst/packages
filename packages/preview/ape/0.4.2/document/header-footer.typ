#import "../tools/miscellaneous.typ": to-array
#let header-footer(style, small-caps, first-real-pages, title, authors, content) = {
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

  let sections-pages = query(<section>).map(t => t.location().position().page)

  if (style == "numbered-book") {
    set page(
      header: context {
        let current-page = counter(page).get().at(0)
        let alignType = if (calc.even(current-page)) { left } else { right }


        let header-text = if (calc.odd(current-page) and to-array(authors).len() >= 1) {
          [ #to-array(authors).join([ --- ]) ]
        } else if (type(title) != array) {
          [ #title ]
        } else { [#title.at(0) --- #sc(title.at(1))] }


        if (
          (current-page > first-real-pages.at(0)) and (first-real-pages.all(e => e != current-page)) and (counter-page not in sections-pages)
        ) {
          [
            #set text(size: 9pt)
            #set align(alignType)
            #header-text
            #place(dy: 3.5pt, line(length: 100%, stroke: 0.5pt + text.fill))
          ]
        }
      },

      footer: context {
        let current-page = counter(page).get().at(0)
        if (current-page >= first-real-pages.at(0)) {
          [
            #place(dy: -0.25cm, line(length: 100%, stroke: 0.5pt + text.fill))

            #let alignType = if (calc.even(current-page)) { left } else { right }

            #set align(alignType)
            #counter(page).display() / #counter(page).final().at(0)

          ]
        }
      },
    )
    content
  } else {
    set page(
      header: context {
        let current-page = counter(page).get().at(0)


        if (
          (current-page > first-real-pages.at(0))
            and (first-real-pages.all(e => e != current-page))
            and to-array(authors).len() > 0
        ) {
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
        let current-page = counter(page).get().at(0)
        if (
          (current-page > first-real-pages.at(0)) and to-array(authors).len() > 0
        ) {
          [
            #place(dy: -0.25cm, line(length: 100%, stroke: 0.5pt + text.fill))


            #set align(center)
            #counter(page).display() / #counter(page).final().at(0)

          ]
        }
      },
    )
    content
  }
}
