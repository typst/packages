#import "../core/state.typ": meta-value, val-or-meta
#import "@preview/tieflang:0.1.0": tr

#let copyright-block-settings = (
  text-size: 8.5pt,
  line-spacing: 2pt,
)

#let format-list = value => {
  if value == none {
    none
  } else if type(value) == array {
    value.join(", ")
  } else {
    value
  }
}

#let resolve-year = (year, date) => {
  if year != none {
    year
  } else if date == none {
    none
  } else if type(date) == datetime {
    date.display("[year]")
  } else {
    date
  }
}

#let ensure-array = value => {
  if value == none {
    ()
  } else if type(value) == array {
    value
  } else {
    (value,)
  }
}

#let copyright-block = (
  holder: none,
  publisher: none,
  year: none,
  date: none,
  isbn: none,
  edition: none,
  dedication: none,
  license: none,
  extra-lines: (),
  settings: (:),
) => context {
  let holder-value = format-list(val-or-meta(holder, "author"))
  let publisher-value = format-list(val-or-meta(publisher, "publisher"))
  let date-value = val-or-meta(date, "date")
  let year-value = resolve-year(year, date-value)
  let isbn-value = val-or-meta(isbn, "isbn")
  let edition-value = val-or-meta(edition, "edition")
  let dedication-value = val-or-meta(dedication, "dedication")
  let license-value = val-or-meta(license, "license")
  let extra = ensure-array(extra-lines)
  let merged-settings = (:..copyright-block-settings, ..settings)

  if dedication-value != none {
    place(top + left, dx: 20pt)[#dedication-value]
  }

  let lines = (tr().copyright-page)(
    holder-value,
    publisher-value,
    year-value,
    isbn-value,
    edition-value,
    license-value,
    extra,
  )

  let line-list = if type(lines) == array { lines } else { (lines,) }
  let filtered = line-list.filter(l => l != none)

  if filtered.len() == 0 {
    return
  }

  align(left + bottom)[
    #text(size: merged-settings.text-size, tracking: 1pt)[
      #stack(spacing: merged-settings.line-spacing, ..filtered)
    ]
  ]
}
