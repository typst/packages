#import "@preview/hydra:0.6.2": hydra

/// Detects if the location contains a heading of the
/// specified level
#let page-has-heading = (loc, level: 1) => {
  query(heading.where(level: level)).any(h => (
    h.location().page() == loc.page()
  ))
}

/// Builds the header content. If the page has an h1 heading,
/// it suppresses the header. Otherwise, the content depends
/// on page parity. If the page is odd, it returns the latest
/// h1 title on the left and the page number on the right. If
/// the page is even, it returns the page number on the left
/// and the latest h2 on the right (or the latest h1 if the
/// no h2 exists yet).
#let make-header() = context {
  // If page has h1, suppress header
  if page-has-heading(here()) {
    return none
  }
  let latest-h1 = hydra(1)
  let latest-h2 = hydra(2)
  let page-display-num = counter(page).display()
  set text(style: "italic")
  if calc.odd(here().page()) {
    // Odd page: heading title --- page number
    latest-h1
    h(1fr)
    page-display-num
  } else {
    // Even page: page number --- heading title
    page-display-num
    h(1fr)
    if latest-h2 != none { latest-h2 } else { latest-h1 }
  }
}

/// Builds the footer content. If the page has an h1 heading
/// it returns a centre-aligned, italic page number.
/// Otherwise, it returns none.
#let make-footer() = context {
  set align(center)
  set text(style: "italic")
  if page-has-heading(here()) {
    counter(page).display()
  } else { none }
}
