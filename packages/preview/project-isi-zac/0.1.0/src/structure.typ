/// Returns whether the current page is one where a chapter begins. This is
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

/// Marks all pagebreaks for empty page detection via. This is called as a show
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

/// Returns whether the current page is empty. This is determined by checking
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

/// This is intended to be called in a section show rule. It returns whether
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

/// Applies show rules that allow referencing non-numbered headings by name.
///
/// -> function
#let plain-heading-refs() = body => {
  show ref: it => {
    if type(it.element) != content { return it }
    if it.element.func() != heading { return it }
    if it.element.numbering != none { return it }

    link(it.target, it.element.body)
  }
  body
}

/// Applies show rules that set chapter and heading supplements, start each chapter on an odd page,
/// and start the first section in a chapter on a new page.
///
/// -> function
#let chapters-and-sections(
  /// The chapter heading supplement
  /// -> content
  chapter: none,
  /// The section heading supplement
  /// -> content
  section: none,
) = body => {
  assert.ne(chapter, none, message: "Chapter supplement not set")
  assert.ne(section, none, message: "Section supplement not set")

  // Heading supplements are section or chapter, depending on level
  show heading: set heading(supplement: section)
  show heading.where(level: 1): set heading(supplement: chapter)

  // chapters start on a right page and have very big, fancy headings
  show heading.where(level: 1): it => {
    set text(1.3em)
    pagebreak()
    v(12%)
    if it.numbering != none [
      #it.supplement #counter(heading).display()
      #parbreak()
    ]
    set text(1.3em)
    it.body
    v(1cm)
  }

  // Keep other sections also inside Chapter pages since commented
  // the first section of a chapter starts on the next page
  /*
  show heading.where(level: 2): it => {
    if is-first-section() {
      pagebreak()
    }
    it
  }
  */
  
  body
}

/// Applies show rules for the front matter. It's intended that this wraps the _whole_ document;
/// starting the main matter will override the rules applied here.
///
/// -> function
#let front-matter() = body => {
  // front matter headings are not outlined
  set heading(outlined: false)

  body
}
