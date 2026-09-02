// araby-book v0.1.0
// Copyright (c) 2026 Abdelaziz Islam Galal
// Licensed under the BSD 3-Clause License. See LICENSE for details.

// --- Helper: Convert Western Arabic digits to Eastern Arabic digits ---
#let arabic-digits(n) = {
  let d = "٠١٢٣٤٥٦٧٨٩".clusters()
  str(n).clusters().map(c => d.at(int(c), default: c)).join()
}

// --- Helper: Traditional Arabic Poetry Pair (صدر وعجز) ---
#let poetry(first, second) = {
  v(0.4em)
  grid(
    columns: (1fr, 2em, 1fr),
    align: (right + horizon, center + horizon, left + horizon),
    first, text(fill: gray.darken(20%), size: 0.8em)[\*\*\*], second,
  )
  v(0.4em)
}

// --- Helper: Quranic / Decorative Verse Callout ---
#let verse(body, ref: none, color: rgb("#8b0000")) = {
  v(0.25em)
  align(center)[
    #block(
      width: 92%,
      inset: (x: 14pt, y: 10pt),
      radius: 4pt,
    )[
      #text(fill: color, weight: "medium", size: 1.05em)[« #body »]
      #if ref != none [
        #v(-0.2em)
        #align(left)[#text(size: 0.75em, fill: gray.darken(40%))[-- #ref]]
      ]
    ]
  ]
  v(0.25em)
}

#let inline_verse(body, ref: none, color: rgb("#8b0000")) = {
  text(fill: color, weight: "medium", size: 0.95em)[« #body »]
  if ref != none [
    #text(size: 0.7em, fill: gray.darken(40%))[-- #ref --]
  ]
}

#let inline_quotation(body, ref: none) = {
  text(style: "italic", weight: "medium", size: 0.95em)[« #body »]
  if ref != none [
    #text(size: 0.7em, fill: gray.darken(40%))[-- #ref --]
  ]
}

// --- Main Template Definition ---
#let book(
  title: "",
  subtitle: none,
  author: "",
  publisher: none,
  edition: none,
  date: none,
  paper: "a5",
  font: ("Amiri", "Noto Naskh Arabic"),
  font-size: 11pt,
  primary-color: rgb("#000000"),
  footnote-color: rgb("#8b0000"), // Custom color for footnote numbers (e.g., deep red)
  eastern-digits: true,
  dedication: none,
  show-toc: true,
  toc-title: "الفهرس",
  body,
) = {
  // 1. Metadata
  set document(title: title, author: author)

  // 2. Numbering format selector
  let num-fmt = if eastern-digits {
    (..nums) => arabic-digits(nums.pos().first())
  } else {
    (..nums) => str(nums.pos().first())
  }

  // 3. Page Setup
  set page(
    paper: paper,
    margin: (inside: 2.2cm, outside: 1.6cm, top: 2.4cm, bottom: 2.2cm),
    numbering: num-fmt,
    number-align: center,
    header: context {
      let page-num = counter(page).get().first()
      // Suppress header on page 1 (title page)
      if page-num == 1 { return }

      // Locate current chapter
      let headings = query(selector(heading.where(level: 1)))
      let current-heading = headings.filter(h => h.location().page() <= page-num).at(-1, default: none)

      // Suppress header on chapter start pages
      if current-heading != none and current-heading.location().page() == page-num {
        return
      }

      if current-heading != none {
        let h-text = current-heading.body
        if calc.even(page-num) {
          align(right)[#text(size: 8.5pt, fill: gray.darken(30%))[#h-text]]
        } else {
          align(left)[#text(size: 8.5pt, fill: gray.darken(30%))[#title]]
        }
        v(-0.4em)
        line(length: 100%, stroke: 0.3pt + gray.lighten(50%))
      }
    },
  )

  // 4. Global Typography Setup
  set text(
    font: font,
    lang: "ar",
    region: "SA",
    dir: rtl,
    size: font-size,
  )
  set par(justify: true, first-line-indent: 1.4em, leading: 1.25em)

  // Custom footnote styling and coloring
  show footnote: it => text(fill: footnote-color, size: 1.3em)[#it]

  set footnote.entry(
    separator: line(length: 70%, stroke: 0.4pt),
  )

  // 2. Color the footnote entry marker at the bottom
  show footnote.entry: it => {
    text(fill: footnote-color, size: 1em)[#it.note.numbering ]

    text(fill: gray.darken(30%), size: 1em)[#it.note.body]
  }

  // 5. Headings Setup
  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    v(1.5cm)
    align(center)[
      #text(size: 9pt, tracking: 2.5pt, fill: primary-color)[* فصل *]
      #v(0.2cm)
      #line(length: 25%, stroke: 0.5pt + primary-color)
      #v(0.4cm)
      #text(size: 20pt, weight: "bold", fill: primary-color)[#it.body]
    ]
    v(1.2cm)
  }

  show heading.where(level: 2): it => {
    v(1em)
    text(size: 13pt, weight: "bold", fill: primary-color)[#it.body]
    v(0.5em)
  }

  // 6. Cover / Title Page
  align(center + horizon)[
    #v(1cm)
    #text(size: 24pt, weight: "bold", fill: primary-color)[#title]
    #if subtitle != none [
      #v(0.4cm)
      #text(size: 13pt, style: "italic", fill: gray.darken(40%))[#subtitle]
    ]
    #v(0.8cm)
    #line(length: 20%, stroke: 0.6pt + primary-color)
    #v(2.5cm)
    #text(size: 12pt, weight: "medium")[#author]
    #if edition != none or date != none [
      #v(0.4cm)
      #text(size: 9.5pt, fill: gray.darken(30%))[
        #if edition != none [#edition]
        #if edition != none and date != none [ --- ]
        #if date != none [#date]
      ]
    ]
  ]

  pagebreak()

  // 7. Dedication Page
  if dedication != none {
    align(center + horizon)[
      #set par(leading: 1em)
      #text(size: 11pt, style: "italic")[#dedication]
    ]
    pagebreak()
  }

  // 8. Outline / Table of Contents
  if show-toc {
    show outline.entry.where(level: 1): it => {
      v(0.4em)
      text(weight: "bold")[#it]
    }
    outline(title: toc-title, indent: 1.2em)
    pagebreak()
  }

  // Render Document Body
  body
}
