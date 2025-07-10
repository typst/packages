#let page-header-styles = rest => {
  // Add current chapter to page header
  set page(header: context {
    let current-page = counter(page).get()

    let all-headings = query(heading.where(level: 1, numbering: "1."))
    let is-new-chapter = all-headings.any(m => counter(page).at(m.location()) == current-page)
    if is-new-chapter {
      return
    }


    let previous-headings = query(selector(heading.where(level: 1)).before(here())).filter(h => h.numbering != none)

    if previous-headings.len() == 0 {
      return
    }
    let heading-title = previous-headings.last().body

    [#str(previous-headings.len()). #h(1em) #smallcaps(heading-title)]
    line(length: 100%)
  })

  rest
}