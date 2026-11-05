//! Auxiliar functions and definitions.

#import "arguments.typ": format-value


#let azuluc3m = rgb("#000e78")



/// Advances to the next clean page.
///
/// - double-sided (bool): Whether to use a double-sided page.
/// - weak (bool): If `true`, the page break is skipped if the current page is already empty.
/// -> content
#let newpage(double-sided, weak: true) = {
  pagebreak(weak: weak, to: if double-sided { "odd" } else { none })
}


/// Prints a flyleaf, an empty page.
///
/// - double-sided (bool): Whether to use a double-sided page.
///
/// -> content
#let make-flyleaf(double-sided) = {
  set page(header: none, footer: none)
  newpage(double-sided, weak: false)
}

/// Checks whether the current page is a chapter start page.
///
/// -> bool
#let is-chapter-start() = {
  // https://forum.typst.app/t/how-to-determine-if-the-current-page-has-a-heading-of-level-1/4185/2
  query(heading.where(level: 1)).any(it => (
    it.location().page() == here().page()
  ))
}


/// Checks whether the current page is the last page.
///
/// -> bool
#let is-last-page() = {
  counter(page).final().first() == counter(page).get().first()
}


/// Capitalizes a string.
///
/// - s (str): String to capitalize
/// -> str
#let capitalize(s) = {
  s.replace(regex("^\w"), m => upper(m.text))
}
