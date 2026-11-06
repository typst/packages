#import "icons.typ": *

// ============================================
// Column layout settings
// ============================================
#let default-c1-len = 15%
#let default-c2-len = 1fr
#let default-c3-len = auto
#let default-col-gutter = 1em
#let default-col-align = (left, left, right)

// ============================================
// Icon registry functions
// ============================================
#let configured-icons = configure-icon-registry(
  color: luma(20%),
  height: 0.95em,
  baseline: 20%,
)
#let google-scholar-icon = configured-icons.at("google-scholar-icon")
#let link-icon = configured-icons.at("link-icon")
#let linkedin-icon = configured-icons.at("linkedin-icon")
#let github-icon = configured-icons.at("github-icon")
#let orcid-icon = configured-icons.at("orcid-icon")
#let x-icon = configured-icons.at("x-icon")

// ============================================
// RESUME FUNCTION
// ============================================
#let resume(
  paper: "a4", // or "us-letter"
  margin: (left: 0.95in, right: 0.95in, top: 0.9in, bottom: 0.9in),
  text-args: (
    font-family: "Alegreya",
    font-size: 10pt,
  ),
  heading-args: (
    font-family: "Arial",
    level1-font-size: 20pt,
    level3-align: right,
  ),
  par-args: (
    leading: 0.55em,
    spacing: 1em,
  ),
  link-line-args: (
    stroke: 0.5pt + luma(200),
    offset: 2pt,
  ),
  col-args: (
    c1-len: default-c1-len,
    c2-len: default-c2-len,
    col-gutter: default-col-gutter,
  ),
  // icon-args: (
  //   color: luma(20%),
  //   height: 0.95em,
  //   baseline: 20%,
  // ),
  author-args: (
    web-font-family: "Courier New",
    web-font-size: 0.95em,
  ),
  author-info: (
    name: "John Doe",
    primary-info: [
      Assistant Professor \
      Department of Your Department \
      Building Name \
      Your University \
      City, Countryg
    ],
    secondary-info: [
      #link("mailto:your.email@university.edu")[your.email\@university.edu] \
      #link("https://www.yourwebsite.com")[https://www.yourwebsite.com] \ 
      #link("https://linkedin.com/in/your-linkedin-username")[#linkedin-icon()] #link("https://x.com/your-x-username")[#x-icon()] #link("https://scholar.google.com/citations?user=your-scholar-id")[#google-scholar-icon()] #link("https://github.com/your-github-username")[#github-icon()] #link("https://orcid.org/0000-0000-0000-0000")[#orcid-icon()]
    ],
  ),
  body,
) = {
  // ============================================
  // BASE SETTINGS
  // ============================================
  set document(author: author-info.name, title: author-info.name)

  set text(
    font: text-args.font-family,
    size: text-args.font-size,
    ligatures: false,
  )

  set page(
    paper: paper,
    margin: margin,
    footer: context { align(center)[#text(size: 0.9em)[#counter(page).display("1")]] },
  )

  set par(
    justify: true,
    first-line-indent: 0pt,
    leading: par-args.leading,
    spacing: par-args.spacing,
  )

  // Default par settings for two-column layout.
  show par: it => {
    grid(
      columns: (col-args.c1-len, col-args.c2-len),
      column-gutter: col-args.col-gutter,
      [], it,
    )
  }

  // ============================================
  // HEADING SETTINGS
  // ============================================
  show heading.where(level: 1): it => {
    set block(breakable: false, above: 1.2em, below: 0.8em)
    set text(font: heading-args.font-family, size: heading-args.level1-font-size, weight: "bold")
    it
  }

  show heading.where(level: 2): it => {
    set block(breakable: false, above: 1.2em, below: 1em)
    set text(font: heading-args.font-family)
    it
  }

  show heading.where(level: 3): it => {
    set block(breakable: false, above: 1em, below: 1em)
    set text(style: "italic")
    set align(heading-args.level3-align)
    grid(
      columns: (col-args.c1-len, col-args.c2-len),
      column-gutter: col-args.col-gutter,
      [#it],
      [],
    )
  }

  // ============================================
  // LINK SETTINGS
  // ============================================
  show link: it => {underline(stroke: link-line-args.stroke, offset: link-line-args.offset, it)}

  // ============================================
  // AUTHOR HEADER
  // ============================================
  block(below: 0.8em)[
    #heading(level: 1)[#author-info.name]
    #pad(left: 2em, right: 2em)[
      #grid(
        columns: (1fr, 1fr),
        column-gutter: 2em,
        row-gutter: 0.15em,
        align: (left, right),
        author-info.primary-info,
        text(font: author-args.web-font-family, size: author-args.web-font-size)[#author-info.secondary-info],
      )
    ]
  ]

  // ============================================
  // BODY
  // ============================================
  body
}

#let cols3(
  c1-len: default-c1-len,
  c2-len: default-c2-len,
  c3-len: default-c3-len,
  align: default-col-align,
  col-gutter: default-col-gutter,
  c1-text-args: (:),
  c2-text-args: (:),
  c3-text-args: (:),
  c1,
  c2,
  c3,
) = {
  let has-c3 = c3 != [] and c3 != none
  if has-c3 {
    grid(
      columns: (c1-len, c2-len, c3-len),
      align: align,
      column-gutter: col-gutter,
      text(..c1-text-args)[#c1],
      text(..c2-text-args)[#c2],
      text(..c3-text-args)[#c3],
    )
  } else {
    grid(
      columns: (c1-len, c2-len),
      align: (align.at(0), align.at(1)),
      column-gutter: col-gutter,
      text(..c1-text-args)[#c1],
      text(..c2-text-args)[#c2],
    )
  }
}

// ============================================
// EMPLOYMENT FUNCTIONS
// ============================================
// TODO: Add block environment for item and head. (more precise vertical spacing control)

#let employment-head(
  c2, c3,
  c1-len: default-c1-len,
  c2-len: default-c2-len,
  c3-len: default-c3-len,
  col-gutter: default-col-gutter,
  c2-text-args: (weight: "bold"),
  c3-text-args: (style: "italic"),
) = {
  cols3(
    [], smallcaps(c2), c3,
    c1-len: c1-len,
    c2-len: c2-len,
    c3-len: c3-len,
    col-gutter: col-gutter,
    c2-text-args: c2-text-args,
    c3-text-args: c3-text-args,
  )
}

#let employment-head-item(
  c2, c3,
  c1-len: default-c1-len,
  c2-len: default-c2-len,
  c3-len: auto,
  col-gutter: default-col-gutter,
  c2-text-args: (weight: "bold"),
  c3-text-args: (style: "italic"),
  body-pad-left: 2em,
  body
) = {
  employment-head(
    c2, c3,
    c1-len: c1-len,
    c2-len: c2-len,
    c3-len: c3-len,
    col-gutter: col-gutter,
    c2-text-args: c2-text-args,
    c3-text-args: c3-text-args,
  )
  pad(left: body-pad-left)[
    // Keep parbreak so single body blocks still render as paragraph content.
    #body #parbreak()
  ]
}

// ============================================
// META ENTRY FUNCTIONS
// ============================================
#let meta-entry(
  c1, c2, c3,
  c1-len: default-c1-len,
  c2-len: default-c2-len,
  c3-len: default-c3-len,
  col-gutter: default-col-gutter,
  align: default-col-align,
  c1-text-args: (:),
  c2-text-args: (weight: "bold"),
  c3-text-args: (style: "italic"),
) = {
  cols3(
    c1, c2, c3,
    c1-len: c1-len,
    c2-len: c2-len,
    c3-len: c3-len,
    col-gutter: col-gutter,
    c1-text-args: c1-text-args,
    c2-text-args: c2-text-args,
    c3-text-args: c3-text-args,
  )
}

#let meta-entry-item(
  c1, c2, c3,
  c1-len: default-c1-len,
  c2-len: default-c2-len,
  c3-len: default-c3-len,
  col-gutter: default-col-gutter,
  align: default-col-align,
  c1-text-args: (:),
  c2-text-args: (weight: "bold"),
  c3-text-args: (style: "italic"),
  body,
) = {
  meta-entry(
    c1, c2, c3,
    c1-len: c1-len,
    c2-len: c2-len,
    c3-len: c3-len,
    col-gutter: col-gutter,
    align: align,
    c1-text-args: c1-text-args,
    c2-text-args: c2-text-args,
    c3-text-args: c3-text-args,
  )
  [#body #parbreak()]
}

// TODO: automatically read publications from bib
// TODO: automatically generate sorted label from bib
// TODO: automatically classify publications into conferences, journals, workshops, etc.
#let pubs-reset() = context { counter("pub").update(1) }
#let pub-item(
  c1-len: default-c1-len,
  c2-len: default-c2-len,
  c3-len: default-c3-len,
  col-gutter: 1em,
  body,
) = context {
  let c = counter("pub")
  let label = [
    \[#c.display("1")\]
    #c.step()
  ]
  cols3(
    label, body, [],
    c1-len: c1-len,
    c2-len: c2-len,
    c3-len: c3-len,
    col-gutter: col-gutter,
    align: (right, left, right),
  )
}

// ============================================
// LIST WRAPPER FUNCTIONS
// ============================================

#let employment-head-item-list(
  c1-len: default-c1-len,
  c2-len: default-c2-len,
  c3-len: default-c3-len,
  col-gutter: default-col-gutter,
  c2-text-args: (weight: "bold"),
  c3-text-args: (style: "italic"),
  body-pad-left: 2em,
  item-spacing: 1em,
  ..items,
) = {
  set par(spacing: item-spacing)
  for item in items.pos() {
    employment-head-item(
      item.at("c2", default: []),
      item.at("c3", default: []),
      c1-len: c1-len,
      c2-len: c2-len,
      c3-len: c3-len,
      col-gutter: col-gutter,
      c2-text-args: c2-text-args,
      c3-text-args: c3-text-args,
      body-pad-left: body-pad-left,
      item.at("body", default: []),
    )
  }
}

#let meta-entry-item-list(
  c1-len: default-c1-len,
  c2-len: default-c2-len,
  c3-len: default-c3-len,
  col-gutter: default-col-gutter,
  align: default-col-align,
  c1-text-args: (:),
  c2-text-args: (weight: "bold"),
  c3-text-args: (style: "italic"),
  item-spacing: 1em,
  ..items,
) = {
  set par(spacing: item-spacing)
  for item in items.pos() {
    meta-entry-item(
      item.at("c1", default: []),
      item.at("c2", default: []),
      item.at("c3", default: []),
      c1-len: c1-len,
      c2-len: c2-len,
      c3-len: c3-len,
      col-gutter: col-gutter,
      align: align,
      c1-text-args: c1-text-args,
      c2-text-args: c2-text-args,
      c3-text-args: c3-text-args,
      item.at("body", default: []),
    )
  }
}

#let pub-item-list(
  c1-len: default-c1-len,
  c2-len: default-c2-len,
  c3-len: default-c3-len,
  col-gutter: 1em,
  item-spacing: 1em,
  ..items,
) = {
  set par(spacing: item-spacing)
  for item in items.pos() {
    pub-item(
      item,
      c1-len: c1-len,
      c2-len: c2-len,
      c3-len: c3-len,
      col-gutter: col-gutter,
    )
  }
}
