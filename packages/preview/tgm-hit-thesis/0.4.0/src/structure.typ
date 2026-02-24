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

/// Applies pagebreak rules that suppress headers and footers on empty pages;
/// see https://forum.typst.app/t/how-can-i-suppress-headers-and-footers-on-blank-verso-trailing-pages/4384/9
///
/// -> function
#let skip-empty-page-headers-footers() = body => {
  show selector.or(
    pagebreak.where(to: "odd"),
    pagebreak.where(to: "even"),
  ): set page(header: none, footer: none)
  body
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
    pagebreak(to: "odd")
    v(12%)
    if it.numbering != none [
      #it.supplement #counter(heading).display()
      #parbreak()
    ]
    set text(1.3em)
    it.body
    v(1cm)
  }

  // the first section of a chapter starts on the next page
  show heading.where(level: 2): it => {
    if is-first-section() {
      pagebreak()
    }
    it
  }

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

/// Shows the outline and applies show rules for the main matter, overriding the front matter rules.
///
/// -> function
#let main-matter(
  /// The outline title
  /// -> content
  contents: none,
) = body => {
  import "outline.typ": align-fill

  assert.ne(contents, none, message: "Outline title not set")

  {
    show outline.entry: it => {
      if it.level == 1 { return it }
      show: align-fill()
      it
    }
    set outline.entry(fill: repeat(gap: 6pt, justify: false)[.])
    show outline.entry.where(level: 1): set outline.entry(fill: none)
    show outline.entry.where(level: 1): set block(above: 12pt)
    show outline.entry.where(level: 1): set text(weight: "bold")

    [= #contents <contents>]
    outline(title: none)
  }

  set heading(outlined: true, numbering: "1.1")

  body
}

/// Applies show rules for the references part of the back matter: the glossary, literature, and
/// prompts. These are still outlined.
///
/// -> function
#let back-matter-references() = body => {
  set heading(outlined: true)

  body
}

/// Applies show rules for the list part of the back matter: the lists of figures, tables, and
/// listings. These are not outlined.
///
/// -> function
#let back-matter-lists() = body => {
  body
}
