#import "config.typ"
#import "core.typ"
#import "utils.typ"

#let title-page(
  config: (:),
  title: [],
  subtitle: [],
  authors: (:),
  date: [],
) = core.fn-wrapper(self => context {
  // FRONT PAGE
  
  v(50mm, weak: false)
  align(center, text(18pt, title))
  v(-4mm, weak: false)
  align(center, text(12pt, subtitle))
  v(25pt, weak: false)
  for i in range(calc.ceil(authors.len() / 3)) {
    let end = calc.min((i + 1) * 3, authors.len())
    let is-last = authors.len() == end
    let slice = authors.slice(i * 3, end)
    grid(columns: slice.len() * (1fr,), gutter: 12pt, ..slice.map(author => align(center, {
        text(12pt, author.name)
        if "organization" in author [
          \ #emph(author.organization)
        ]
        if "location" in author [
          \ #author.location
        ]
        if "email" in author [
          \ #link("mailto:" + author.email)
        ]
      })))

    if not is-last {
      v(16pt, weak: true)
    }
  }
  v(40pt, weak: true)

  align(center + bottom, text(13pt, text(date, font: self.font.headers.level-1.font, size: 10pt)))
})
