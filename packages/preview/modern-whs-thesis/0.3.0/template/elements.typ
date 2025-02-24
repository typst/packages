#import "settings.typ" as settings

// finds the first level one header on this or some previous page
#let heading_near_to_here = context {
  let here = here()
  let page = here.page()

  // get all headings of level 1 after this one
  let next_headings = query(heading.where(level: 1).after(here))

  // check if there is at least one heading ahead
  if (next_headings.len() != 0) {
    let n = next_headings.first()
    let np = n.location().position().page
    // check if the heading is on the same page as we are
    let number = if n.numbering != none {
      numbering(n.numbering, ..counter(heading).at(n.location()))
    }

    if np == page {
      // return if so
      return [#number #upper(n.body)]
    }
  }

  // if we haven't found any header on this page, we take the
  // nearest previous one
  let nearest_prev = query(heading.where(level: 1).before(here)).last()
  let number = if nearest_prev.numbering != none {
    numbering(
      nearest_prev.numbering,
      ..counter(heading).at(nearest_prev.location()),
    )
  }
  return [#number #upper(nearest_prev.body)]
}

// the common header that is used on all pages except the first ones
#let common_header(title) = context {
  let pageNum = if here().page-numbering() == "I" {
    counter(page).display("I")
  } else {
    counter(page).display()
  }

  v(settings.HEADER_INNER_MARGIN)
  set text(10pt)
  set align(top)
  block(
    grid(
      columns: (1fr, auto),
      inset: (
        x: 0pt,
        y: 7pt,
      ),
      align(left)[_ #heading_near_to_here _],
      pageNum,
      grid.hline()
    ),
  )
}
