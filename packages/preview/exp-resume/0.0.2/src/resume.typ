#import "helpers.typ": linked-text

#let resume(
  author: "",
  author-position: left,
  personal-info-position: left,
  pronouns: "",
  location: "",
  email: "",
  email-text: "",
  github: "",
  github-text: "",
  linkedin: "",
  linkedin-text: "",
  phone: "",
  personal-site: "",
  personal-site-text: "",
  accent-color: "#000000",
  font: "New Computer Modern",
  paper: "us-letter",
  author-font-size: 20pt,
  font-size: 10pt,
  // How far section body content is indented relative to the section title
  section-content-inset: 4pt,
  lang: "en",
  body,
) = {

  // Sets document metadata
  set document(author: author, title: author)

  // Document-wide formatting, including font and margins
  set text(
    // LaTeX style font
    font: font,
    size: font-size,
    lang: lang,
    // Disable ligatures so ATS systems do not get confused when parsing fonts.
    ligatures: false
  )

  // Recommended to have 0.5in margin on all sides
  set page(
    margin: (0.5in),
    paper: paper,
  )

  // Link styles: underline with a small gap under the glyphs (Jake-style).
  // `offset` is layout, not font-dependent; applies to every link site-wide.
  show link: it => {
    if type(it.dest) == str and it.dest.starts-with("tel:") {
      it
    } else {
      underline(offset: 4pt, stroke: 0.8pt + luma(35%), it)
    }
  }

  // Accent Color Styling
  show heading: set text(
    fill: rgb(accent-color),
  )

  show link: set text(
    fill: rgb(accent-color),
  )

  // Name will be aligned left, bold and big
  show heading.where(level: 1): it => [
    #set align(author-position)
    #set text(
      weight: 600,
      size: author-font-size,
    )
    #pad(it.body)
  ]

  // Level 1 Heading
  [= #(author)]

  // Personal Info
  pad(
    top: 0em,
    bottom: 0.25em,
    align(personal-info-position)[
      #{
        let items = (
          linked-text(pronouns),
          linked-text(phone, link-prefix: "tel:"),
          linked-text(location),
          linked-text(email, link-prefix: "mailto:", text: email-text),
          linked-text(linkedin, link-prefix: "https://", text: linkedin-text),
          linked-text(github, link-prefix: "https://", text: github-text),
          linked-text(personal-site, link-prefix: "https://", text: personal-site-text),
        )
        items.filter(x => x != none).join(" | ")
      }
    ],
  )

  // Main body: content indented under section titles; titles + rules stay full width
  set par(justify: true)

  pad(left: section-content-inset, {
    show heading.where(level: 2): it => {
      pad(left: -section-content-inset)[
        #set text(weight: 400)
        #pad(top: 0pt, bottom: -10pt, [#smallcaps(it.body)])
        #line(length: 100% + section-content-inset, stroke: 0.8pt + luma(35%))
      ]
    }
    body
  })
}