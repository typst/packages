#import "apply-style.typ" : get-small-title

#let front-pages(style, small-caps, title, title-page, authors, outline, custom-outline) = {
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
            if type(title) == text {
              text(size: 7em, [*#title*])
            } else {
              [
                #par(text(size: 6em, hyphenate: false, (strong(title.at(1)))))
                #v(3em)
                #par(text(size: 3em, hyphenate: false, (title.at(0))))
              ]
            }
          }


        #v(1em)
        #{
          if type(authors) == array {
            if authors.len() > 0 {
              [
                #text(size: 1.45em, sc(authors.at(0)))
                \
              ]
            }
            if authors.len() > 1 {
              [
                #text(size: 1.45em, authors.slice(1).map(sc).join(" - "))
              ]
            }
          } else {
            [
              #text(size: 1.45em, sc(authors))
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

    get-small-title(style, title)
  } else {
    if outline {
      custom-outline
      pagebreak()
    }

    get-small-title(style, title)

    v(15pt)
  }
}
