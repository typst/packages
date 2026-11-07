#let pesha(
  name: "",
  address: "",
  contacts: (),
  profile-picture: none,
  paper-size: "a4",
  footer-text: none,
  page-numbering-format: "1 of 1",
  body,
) = {
  // Set document metadata.
  set document(
    title: name,
    author: name,
    keywords: (name, "curriculum vitae", "cv", "resume"),
  )

  // Configure text properties.
  set text(size: 10pt, hyphenate: false)

  // Text settings used across the template.
  let head-text = text.with(
    font: ("Cantarell", "Hanken Grotesk", "HK Grotesk"),
    weight: "medium",
  )

  // Set page properties.
  set page(
    paper: paper-size,
    margin: (
      x: 14%,
      top: if profile-picture == none { 13% } else { 8.6% },
      bottom: 10%,
    ),
    // Display page number in footer only if there is more than one page.
    footer: context {
      set align(center)
      show text: it => head-text(size: 0.85em, tracking: 1.2pt, it)
      if counter(page).final().first() > 1 {
        upper[#footer-text #counter(page).display(page-numbering-format, both: true)]
      } else {
        upper[#footer-text]
      }
    },
  )

  // Display title and contact info.
  block(width: 100%, below: 1.5em)[
    #let header-info = {
      show text: upper
      head-text(size: 1.8em, tracking: 3.2pt, name)
      v(1.4em, weak: true)
      show text: it => head-text(size: 0.86em, tracking: 1.4pt, it)
      address
      if contacts.len() > 0 {
        v(1em, weak: true)
        grid(columns: contacts.len(), align: horizon, gutter: 1em, ..contacts)
      }
    }
    #if profile-picture != none {
      grid(
        columns: (1fr, auto),
        box(
          clip: true,
          width: 3.3cm,
          height: 3.3cm,
          radius: 2.5cm,
          profile-picture,
        ),
        align(right + horizon, header-info),
      )
    } else {
      align(center, header-info)
    }
  ]

  // Configure heading properties.
  show heading: it => {
    line(length: 100%, stroke: 0.5pt)
    pad(
      top: -0.85em,
      left: 0.25em,
      bottom: 0.6em,
      upper(head-text(weight: "black", size: 0.7em, tracking: 0.6pt, it)),
    )
  }

  // Configure paragraph properties.
  set par(leading: 0.7em, justify: true, linebreaks: "optimized")

  body
}

// This function formats its `body` (content) into a block of experience section.
#let experience(
  place: none,
  title: none,
  location: none,
  time: none,
  body,
) = {
  set list(body-indent: 0.85em)

  block(
    width: 100%,
    below: 12pt,
    pad(left: 0.25em)[
      #grid(
        columns: (1fr, auto),
        align: (left, right),
        column-gutter: 1.5em,
        row-gutter: 10pt,
        ..if place != none or time != none {
          (
            text(size: 1.4em, place),
            if time != none { text(size: 1.3em, time) },
          )
        },
        ..if title != none or location != none {
          (
            emph(title),
            if location != none { text(size: 0.9em, location) },
          )
        },
        ..if body != [] and body != none {
          (grid.cell(colspan: 2)[#body],)
        },
      )
    ],
  )
}

// Overwrite the default `smallcaps` and `upper` functions with increased spacing between
// characters. We do this so that when someone uses these functions they will get spacing
// which fits in better with the rest of the template.
#let smallcaps(body, all: false) = std.smallcaps(all: all, text(tracking: 0.05em, body))
#let upper(body) = std.upper(text(tracking: 0.05em, body))
