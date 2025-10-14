#import "apply-style.typ": get-small-title
#import "outline.typ" : get-local-outline

#let front-pages(style, small-caps, title, title-page, authors, outline, local-outline, custom-outline) = {
  let sc(c) = {
    if small-caps == true {
      return smallcaps(c)
    } else {
      return c
    }
  }

  if title-page {
    align(
      center + horizon,
      [

        #{
          if type(title) == str {
            par(leading: 2em, spacing: 3em, text(size: 5em, hyphenate: false, (strong(title))))
          } else {
            par(leading: 1.7em, text(size: 5em, hyphenate: false, (strong(title.at(1)))))
            par(leading: 1em, spacing: 3em, text(size: 3.25em, hyphenate: false, (title.at(0))))
          }
        }
        #v(1em)

        #{
          if type(authors) == array {
            if authors.len() > 0 {
              [
                #text(size: 1.55em, sc(authors.at(0)))
                \
              ]
            }
            if authors.len() > 1 {
              [
                #text(size: 1.55em, authors.slice(1).map(sc).join(" - "))
              ]
            }
          } else {
            [
              #text(size: 1.55em, sc(authors))
            ]
          }
        }

      ],
    )

    pagebreak()
    if outline {
      custom-outline
      pagebreak()
    }

    if local-outline { 
      get-local-outline()
    }
    get-small-title(style, title, authors)
  } else {
    if outline {
      custom-outline
      pagebreak()
    }

    get-small-title(style, title, authors)
    if local-outline { 
      get-local-outline()
    }
    v(20pt)
  }
}
