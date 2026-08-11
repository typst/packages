#import "../core/state.typ": metadata-state
#import "@preview/tieflang:0.1.0": tr
#import "@preview/ccicons:1.0.1": cc-is-valid

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
  let meta = metadata-state.final()
  let holder-value = format-list(if holder == none { meta.at("author", default: none) } else { holder })
  let publisher-value = format-list(if publisher == none { meta.at("publisher", default: none) } else { publisher })
  let date-value = if date == none { meta.at("date", default: none) } else { date }
  let year-value = resolve-year(year, date-value)
  let isbn-value = if isbn == none { meta.at("isbn", default: none) } else { isbn }
  let edition-value = if edition == none { meta.at("edition", default: none) } else { edition }
  let dedication-value = if dedication == none { meta.at("dedication", default: none) } else { dedication }
  let license-value = if license == none { meta.at("license", default: none) } else { license }
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
