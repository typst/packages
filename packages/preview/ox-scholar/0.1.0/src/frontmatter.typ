#import "utils.typ": page-has-heading

#let frontmatter-page(title: none, body) = {
  // Validate inputs
  assert(title != none, message: "Frontmatter page title must be provided")

  set page(
    header: none,
    footer: context {
      if page-has-heading(here()) { none } else {
        set align(center)
        set text(style: "italic")
        counter(page).display()
      }
    },
  )

  heading(
    level: 1,
    numbering: none,
    outlined: false,
    title,
  )

  body

  pagebreak(weak: true, to: "odd")
}
