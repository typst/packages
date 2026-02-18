#import "../core/i18n.typ": setup-i18n
#import "../components/blurb.typ": blurb-block
#import "../components/copyright_block.typ": copyright-block
#import "../components/toc.typ": table-of-content
#import "helpers.typ": start-after-main, start-main, start-preamble
#import "setup.typ": setup
#import "../components/title_page.typ": title-page

#let book = (
  title: none,
  author: none,
  publisher: none,
  date: none,
  isbn: none,
  edition: none,
  blurb: none,
  dedication: none,
  license: none,
  paper: auto,
  margin: none,
  width: none,
  height: none,
  language: none,
  show-title-page: true,
  toc-settings: (:),
  copyright-block-settings: (:),
  body,
) => {
  show: setup.with(
    title: title,
    author: author,
    publisher: publisher,
    date: date,
    isbn: isbn,
    edition: edition,
    blurb: blurb,
    dedication: dedication,
    license: license,
    paper: paper,
    margin: margin,
    width: width,
    height: height,
    language: language,
  )

  show: start-preamble

  if show-title-page {
    title-page()
  }

  if copyright-block != none {
    pagebreak(to: "even", weak: true)
    copyright-block(..copyright-block-settings)
    pagebreak(to: "even", weak: true)
  }

  if toc-settings != none {
    pagebreak(to: "even", weak: true)
    table-of-content(..toc-settings)
    pagebreak(to: "odd", weak: false)
  }

  show: start-main

  body

  show: start-after-main

  if blurb != none {
    blurb-block()
  }
}
