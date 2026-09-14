#import "@preview/tieflang:0.1.0": tr

#let chapter-number-header = () => align(center, context {
  let headings = query(heading.where(level: 1))
  let current-page = here().page()
  let previous-headings = headings.filter(h => h.location().page() <= current-page)
  if previous-headings.len() == 0 {
    return
  }
  let nearest-previous-heading = previous-headings.last()
  let heading-on-current-page = nearest-previous-heading.location().page() == current-page
  let heading-number = counter(heading).at(nearest-previous-heading.location())
  let heading-display = numbering(heading.numbering, ..heading-number)
  if heading-on-current-page {
    let res-heading = headings.first()
    text(font: "Cormorant SC", weight: "bold")[ #(tr().chapter)(heading-display)]
  } else {
    text(font: "Cormorant SC", weight: "bold")[ #(tr().chapter)(heading-display) -- #nearest-previous-heading.body]
  }
})

#let no-header = () => none
