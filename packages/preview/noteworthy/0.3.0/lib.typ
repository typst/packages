
// All imports
#import "@preview/theoretic:0.3.0" as theoretic: proof, qed, theorem
#import theoretic.presets.basic: *
#show ref: theoretic.show-ref
#import "@preview/showybox:2.0.4": showybox

// Main noteworthy function
#let noteworthy(
  paper-size: "a4",
  font: "New Computer Modern",
  language: "EN",
  title: none,
  header-title: none,
  date: none,
  author: none,
  contact-details: none,
  toc-title: "Table of Contents",
  watermark: none,
  content,
) = {
  // Document metadata
  set document(
    title: [#title - #author],
    author: author,
    date: auto,
  )

  // Page settings
  set page(
    paper: paper-size,
    background: if watermark != none {
      rotate(-40deg, text(30pt, fill: rgb("FFCBC4"))[*#watermark*])
    },
    header: context {
      if (counter(page).get().at(0) > 1) [
        #grid(
          columns: (1fr, 1fr),
          align: (left, right),
          smallcaps(if header-title != none {
            header-title
          } else {
            title
          }),
          if date != none {
            date
          } else {
            datetime.today().display("[day]/[month]/[year]")
          },
        )
        #line(length: 100%)
      ]
    },
    footer: context [
      #line(length: 100%)
      #grid(
        columns: (1fr, 1fr, 1fr),
        align: (left, center, right),
        author,
        if contact-details != none {
          [#sym.diamond.filled #link(contact-details) #sym.diamond.filled]
        },
        counter(page).display(
          "(1/1)",
          both: true,
        ),
      )
    ],
  )

  // Text settings
  set text(
    font: font,
    size: 12pt,
    lang: language,
  )

  // TOC settings
  show outline.entry.where(level: 1): it => {
    v(12pt, weak: true)
    strong(it)
  }

  // Heading settings
  set heading(numbering: "1.")

  // Paragraph settings
  set par(justify: true)

  // Title
  showybox(
    frame: (
      border-color: blue.darken(50%),
      body-color: blue.lighten(80%),
    ),
    shadow: (
      offset: 3pt,
    ),
    body-style: (
      align: center,
    ),
    text(weight: "black", size: 15pt, title),
  )

  // Table of contents
  showybox(
    breakable: true,
    outline(
      indent: auto,
      title: toc-title,
      depth: 2,
    ),
  )

  // Main content
  content
}

// Custom environment using Theoretic package

// Solution environment
#let solution = theoretic.theorem.with(
  supplement: "Solution",
  kind: "solution",
  variant: "remark",
  number: none,
)
