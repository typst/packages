// small helper functions
#let empty(x) = x == none or x == "" or x == []
#let web-link(url) = link("https://" + url, url)
#let tel-link(number) = link("tel:" + number, number)
#let mail-link(address) = link("mailto:" + address, address)

#let resume(
  author: "",
  author-position: left,
  section-position: left,
  accent-color: rgb("#000000"),
  font: "New Computer Modern",
  paper: "us-letter",
  author-font-size: 20pt,
  font-size: 10pt,
  lang: "en",
  margin: 0.5in, // recommended to have 0.5in margin on all sides
  body,
) = {
  // Sets document metadata
  set document(author: author, title: author)

  // Document-wide formatting, including page and font setup
  set page(
    margin: margin,
    paper: paper,
  )

  set text(
    // LaTeX style font
    font: font,
    size: font-size,
    lang: lang,
    // Disable ligatures so ATS systems do not get confused when parsing fonts.
    ligatures: false,
  )

  set par(justify: true)

  // Link styles (links are often used in contact-section)
  show link: underline
  show link: set text(fill: accent-color)

  // Accent Color Styling
  show heading: set text(fill: accent-color)

  // Name (lv1 heading) will be aligned, bold and big
  show heading.where(level: 1): set align(author-position)
  show heading.where(level: 1): set text(
    weight: 700,
    size: author-font-size,
  )

  // section titles (lv2 headings) will use smallcaps
  show heading.where(level: 2): set align(section-position)
  show heading.where(level: 2): smallcaps
  show heading.where(level: 2): it => {
    pad(top: 0pt, bottom: -10pt, it)
    line(length: 100%, stroke: 1pt)
  }

  // Level 1 Heading
  [= #author]

  // Main body
  body
}

// Personal Info
#let contact-section(
  values: (),
  separator: sym.space.en + sym.dot + sym.space.en,
  position: left,
) = {
  assert(type(values) == array, message: "values must be an array")
  let values-are-rows = values.all(v => type(v) == array)
  let values-are-flat = values.all(v => type(v) != array)
  assert(
    values-are-rows or values-are-flat,
    message: "values must be a flat array or an array of rows",
  )
  if values-are-flat and values.len() > 0 {
    values = (values,)
  }

  // join them with separator
  let rows = values.map(row-values => {
    row-values = row-values.filter(x => x != none)

    if values.len() > 0 {
      row-values.join(separator)
    }
  })

  // actual content
  set align(position)
  set par(justify: false)

  v(.25em) // small top padding
  rows.join(linebreak())
}

// Generic two by two component for resume
#let generic-two-by-two(
  top-left: "",
  top-right: "",
  bottom-left: "",
  bottom-right: "",
) = [
  #top-left #h(1fr) #top-right \
  #bottom-left #h(1fr) #bottom-right
]

// Generic one by two component for resume
#let generic-one-by-two(
  left: "",
  right: "",
) = [
  #left #h(1fr) #right
]

#let dates-helper(
  ..args,
) = {
  let dates = args.pos().filter(x => not empty(x))
  assert(
    dates.len() in (1, 2),
    message: "dates-helper expects one or two dates",
  )
  if dates.len() == 1 {
    dates.at(0)
  } else {
    dates.at(0) + sym.space + sym.dash.en + sym.space + dates.at(1)
  }
}

// Section components below
#let edu(
  degree: "",
  dates: "",
  institution: "",
  location: "",
  institution-top: false,
  location-top: false,
) = {
  generic-two-by-two(
    top-left: strong(if institution-top { institution } else { degree }),
    top-right: if location-top { location } else { dates },
    bottom-left: emph(if institution-top { degree } else { institution }),
    bottom-right: emph(if location-top { dates } else { location }),
  )
}

#let work(
  title: "",
  dates: "",
  company: "",
  location: "",
) = {
  generic-two-by-two(
    top-left: strong(title),
    top-right: dates,
    bottom-left: company,
    bottom-right: emph(location),
  )
}

#let project(
  name: "",
  role: "",
  url: "",
  dates: "",
) = {
  assert(not empty(name), message: "name must not be empty")
  let a = if empty(role) [*#name*] else [*#role*, #name]
  // if url and dates are given, add the url to the left side
  let b = if not empty(url) and not empty(dates) [ (#web-link(url))]
  // right side is dates unless it's empty, then use url
  let c = if empty(dates) and not empty(url) { web-link(url) } else { dates }
  generic-one-by-two(left: a + b, right: c)
}

#let certificate(
  name: "",
  issuer: "",
  url: "",
  date: "",
) = {
  assert(not empty(name), message: "name must not be empty")
  assert(not empty(issuer), message: "issuer must not be empty")
  generic-one-by-two(
    left: [*#name*, #issuer] + if not empty(url) [ (#web-link(url))],
    right: date,
  )
}

#let extracurricular(
  activity: "",
  dates: "",
) = {
  generic-one-by-two(
    left: strong(activity),
    right: dates,
  )
}

#let extracurricular-list(
  data: (),
) = {
  assert(type(data) == array, message: "data must be an array")
  assert(data.len() > 0, message: "data must contain at least one item")
  assert(
    data.all(e => type(e) == array and e.len() == 2),
    message: "each item in data must be a two-element array",
  )

  list(..data.map(((desc, dates)) => generic-one-by-two(left: desc, right: dates)))
}

#let skills-table(
  data: (:),
  // key-decorator: text.with(size: 1.0em, weight: "bold")
  key-decorator: text.with(style: "italic", size: 1.05em),
) = {
  assert(type(data) == dictionary, message: "data must be a dictionary")
  assert(data.len() > 0, message: "data must contain at least one entry")
  assert(type(key-decorator) == function, message: "key-decorator must be a function")

  grid(
    columns: 2,
    align: (right, left),
    inset: .4em,
    ..data.pairs().map(((k, v)) => (key-decorator(k), v)).flatten(),
  )
}
