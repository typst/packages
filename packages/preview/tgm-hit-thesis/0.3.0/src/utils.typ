/// *Internal function.* Returns whether the current page is one where a chapter begins. This is
/// used for styling headers and footers.
///
/// This function is contextual.
///
/// -> bool
#let is-chapter-page() = {
  // all chapter headings
  let chapters = query(heading.where(level: 1))
  // return whether one of the chapter headings is on the current page
  chapters.any(c => c.location().page() == here().page())
}

// this is an imperfect workaround, see
// - https://github.com/typst/typst/issues/2722
// - https://github.com/typst/typst/issues/4438

#let _empty_page_start = <thesis-empty-page-start>
#let _empty_page_end = <thesis-empty-page-end>

/// *Internal function.* Marks all pagebreaks for empty page detection via. This is called as a show
/// rule (```typ #show: mark-empty-pages()```) by the main template.
///
/// -> function
#let mark-empty-pages() = doc => {
  show pagebreak: it => {
    [#metadata(none)#_empty_page_start]
    it
    [#metadata(none)#_empty_page_end]
  }
  doc
}

/// *Internal function.* Returns whether the current page is empty. This is determined by checking
/// whether the current page is between the start and end of a pagebreak, which may span a whole
/// page when `pagebreak(to: ..)` is used.
/// This is used for styling headers and footers.
///
/// This function is contextual.
///
/// -> bool
#let is-empty-page() = {
  let page-num = here().page()
  query(selector.or(_empty_page_start, _empty_page_end)).chunks(2).any(((start, end)) => {
    start.location().page() < page-num and page-num < end.location().page()
  })
}

/// *Internal function.* This is intended to be called in a section show rule. It returns whether
/// that section is the first in the current chapter
///
/// This function is contextual.
///
/// -> bool
#let is-first-section() = {
  // all previous headings
  let prev = query(selector(heading).before(here(), inclusive: false))
  // returns whether the previous heading is a chapter heading
  prev.len() != 0 and prev.last().level == 1
}
