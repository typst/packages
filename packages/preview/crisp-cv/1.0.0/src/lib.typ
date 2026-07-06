#let default-config = (
  paper: "a4",
  page-margin: 0.6in,
  font: "Source Sans Pro",
  font-size: 11pt,
  file-title: none,
  show-footer: true,
)

#let cv(
  name: "",
  contact: (),
  links: (),
  config: (:),
  doc,
) = {
  // Merge default config and, if supplied, config overrides.
  let config = default-config + config
  let file-title = if config.file-title == none {
    "CV " + name
  } else {
    config.file-title
  }

  // Set PDF metadata.
  set document(author: name, title: file-title)

  // Configure page layout.
  let page-args = (
    paper: config.paper,
    margin: config.page-margin,
  )
  if config.show-footer {
    page-args.insert(
      "footer",
      context [
        #set text(fill: gray)
        #grid(
          columns: (1fr, 1fr),
          file-title, align(right, counter(page).display("1 / 1", both: true)),
        )
      ],
    )
  }
  set page(..page-args)

  // Set default font size (-> 1em) and font family.
  set text(font: config.font, size: config.font-size)

  // Underline links.
  show link: underline

  // L1 headings with divider line below them.
  show heading.where(level: 1): it => pad(bottom: 0.3em, stack(
    spacing: 0.3em,
    text(weight: "medium", size: config.font-size, smallcaps(it.body)),
    line(length: 100%),
  ))

  // Render the header.
  grid(
    columns: (1fr, auto),
    gutter: 2em,
    align(bottom, stack(
      spacing: 1em,
      text(size: 2.2em, weight: "bold")[#name],
      links.join("  |  "),
    )),
    align(right, contact.join([\ ])),
  )

  set par(justify: true)

  doc
}

// A table-like block that lists categories (in bold font) and associated values.
#let skills(..items) = pad(left: 1em, bottom: 0.5em, grid(
  columns: (auto, 1fr),
  row-gutter: 1em,
  column-gutter: 1em,
  ..items.pos().map(item => (strong(item.at(0)), item.at(1))).flatten(),
))

// A block for describing a single employment or education entry.
#let record(
  primary: "",
  secondary: "",
  timespan: "",
  location: "",
  body,
) = pad(left: 1em, bottom: 0.5em, stack(
  spacing: 1.2em,
  grid(
    columns: (1fr, auto),
    row-gutter: 0.7em,
    strong(primary), align(right, timespan),
    text(size: .87em, emph(secondary)), align(right, text(size: .87em, emph(location))),
  ),
  // Only show body (and its padding) if one is provided.
  ..if body != [] { (pad(left: .5em, text(size: .87em, body)),) } else { () },
))

// A badge for displaying arbitrary text content like a note, reference, or a skill or keyword.
#let badge(body) = box(
  fill: rgb("#f8f8f8"),
  stroke: rgb("#e8e8e8"),
  radius: 2pt,
  inset: 4pt,
  text(fill: rgb("#6e6e6e"), size: .8em, body),
)
