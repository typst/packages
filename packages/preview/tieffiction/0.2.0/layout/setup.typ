#import "../core/state.typ": metadata-state
#import "../core/i18n.typ": languages, setup-i18n
#import "common.typ": default-margin
#import "helpers.typ": header-footer-formats, set-header-footer
#import "@preview/tieflang:0.1.0": pop-lang, push-lang, tr
#import "@preview/ccicons:1.0.1": cc-is-valid

#let setup = (
  title: none,
  subtitle: none,
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
  header-footer: none,
  body,
) => {
  if license != none {
    assert(cc-is-valid(license), message: "If license is provided, it must be a valid CC license.")
  }

  if language != none {
    assert(
      languages.values().contains(language),
      message: "If language is provided, it must be contained in the available languages.",
    )
  }

  if date != none {
    assert(type(date) == datetime, message: "If date is provided, it must be of type datetime.")
  }

  setup-i18n()
  if language != none {
    push-lang(language)
  }

  let pdf-authors = (
    if author == none { "" } else if type(author) == array { author.join(", ") } else { author }
      + ", published by "
      + if publisher == none { "" } else if type(publisher) == array { publisher.join(", ") } else { publisher }
  )
  let date-or-today = if date == none { datetime.today() } else { date }

  set document(
    title: title,
    author: pdf-authors,
    date: date-or-today,
  )

  metadata-state.update((
    title: title,
    subtitle: subtitle,
    author: author,
    publisher: publisher,
    date: date-or-today,
    isbn: isbn,
    edition: edition,
    blurb: blurb,
    dedication: dedication,
    license: license,
  ))

  let resulting-margin = if margin != none {
    margin
  } else {
    default-margin
  }

  set par(first-line-indent: 1.5em, justify: true)

  set text(font: "Cormorant", weight: "medium")

  show heading: set text(font: "Cormorant SC", weight: "bold")
  show heading.where(level: 1): it => {
    pagebreak(weak: true)

    align(center, it.body)
  }

  show quote: set text(font: "Liberation Mono", size: 8pt)
  show quote: set par(first-line-indent: 0pt)

  if header-footer == none {
    set-header-footer(header-footer-formats.chapter-number-center)
  } else {
    set-header-footer(header-footer)
  }

  if width == none and height == none {
    let resulting-paper = if paper == auto { "a5" } else { paper }
    set page(
      paper: resulting-paper,
      margin: resulting-margin,
    )

    body
  } else {
    set page(
      width: width,
      height: height,
      margin: resulting-margin,
    )

    body
  }

  if language != none {
    pop-lang()
  }
}
