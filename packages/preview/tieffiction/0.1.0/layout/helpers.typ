#import "../core/footers.typ": no-footer, page-number-footer
#import "../core/headers.typ": chapter-number-header, no-header

#let start-preamble = body => {
  pagebreak(weak: true)
  set heading(numbering: none)
  set page(numbering: none)
  counter(heading).update(0)
  counter(page).update(1)
  set page(header: no-header(), footer: no-footer())

  body
}

#let start-before-main = body => {
  pagebreak(weak: true)
  counter(heading).update(0)
  set heading(numbering: "A")
  set page(numbering: "I")
  counter(page).update(1)
  set page(footer: page-number-footer())

  body
}

#let start-main = body => {
  pagebreak(weak: true)
  set heading(numbering: "1")
  set page(numbering: "1")
  counter(heading).update(0)
  counter(page).update(1)
  set page(header: chapter-number-header(), footer: page-number-footer())

  body
}

#let start-after-main = body => {
  pagebreak(weak: true)
  set heading(numbering: none)
  set page(numbering: none)
  counter(heading).update(0)
  counter(page).update(1)
  set page(header: no-header(), footer: no-footer())

  body
}
