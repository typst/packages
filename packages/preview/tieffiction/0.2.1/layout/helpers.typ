#import "../core/footers.typ": no-footer, page-number-footer
#import "../core/headers.typ": (
  book-author-title-header, book-author-title-pagenum-header, book-title-subtitle-header,
  book-title-subtitle-pagenum-header, chapter-number-center-header, chapter-number-outside-header,
  chapter-number-outside-pagenum-header, no-header,
)
#import "../core/state.typ": main-header-footer-state

#let header-footer-formats = (
  chapter-number-center: (header: chapter-number-center-header, footer: page-number-footer),
  chapter-number-outside: (header: chapter-number-outside-header, footer: page-number-footer),
  chapter-number-outside-pagenum-header: (header: chapter-number-outside-pagenum-header, footer: no-footer),
  author-title-header-pagenum-footer: (header: book-author-title-header, footer: page-number-footer),
  title-subtitle-header-pagenum-footer: (header: book-title-subtitle-header, footer: page-number-footer),
  author-title-pagenum-header: (header: book-author-title-pagenum-header, footer: no-footer),
  title-subtitle-pagenum-header: (header: book-title-subtitle-pagenum-header, footer: no-footer),
)

#let set-header-footer = format => {
  if type(format) == str {
    assert(
      format != none and header-footer-formats.keys().contains(format),
      message: "Format name must be of the following: " + header-footer-formats.keys().join("\n"),
    )

    main-header-footer-state.update(header-footer-formats.at(format))
  } else {
    assert(type(format) == dictionary, message: "Format must be either string or dictionary.")
    assert(format.at("header", default: none) != none, message: "Format must contain a `header` field.")
    assert(format.at("footer", default: none) != none, message: "Format must contain a `footer` field.")

    main-header-footer-state.update(format)
  }
}

#let start-preamble = body => {
  pagebreak(weak: true)
  set heading(numbering: none)
  set page(numbering: none)
  counter(heading).update(0)
  counter(page).update(1)
  set page(header: no-header, footer: no-footer)

  body
}

#let start-before-main = body => {
  pagebreak(weak: true)
  counter(heading).update(0)
  set heading(numbering: "A")
  set page(numbering: "I")
  counter(page).update(1)
  set page(footer: page-number-footer)

  body
}

#let start-main = body => {
  pagebreak(weak: true)
  set heading(numbering: "1")
  set page(numbering: "1")
  counter(heading).update(0)
  counter(page).update(1)


  set page(
    header: context main-header-footer-state.get().header,
    footer: context main-header-footer-state.get().footer,
  )
  body
}

#let start-after-main = body => {
  pagebreak(weak: true)
  set heading(numbering: none)
  set page(numbering: none)
  counter(heading).update(0)
  counter(page).update(1)
  set page(header: no-header, footer: no-footer)

  body
}
