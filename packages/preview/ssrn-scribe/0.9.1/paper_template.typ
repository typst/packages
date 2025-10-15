///////////////////////////////
// This Typst template is for working paper draft.
// It is based on the general SSRN paper.
// Copyright (c) 2025
// Author:  Jiaxin Peng
// License: MIT
// Version: 0.9.1
// Date:    2025-10-14
// Email:   jiaxin.peng@outlook.com
///////////////////////////////

#let author-column-count(count, override) = if override != none {
  calc.max(1, override)
} else if count <= 1 {
  1
} else if count == 2 {
  2
} else if count == 4 {
  2
} else {
  calc.min(count, 3)
}

#let author-block(author, name-size: 14pt) = box(width: auto)[
  #text(name-size, [
    #strong(author.name)
    #if "note" in author { footnote(author.note) }
  ])
  #if "department" in author [
    \ #emph(author.department)
  ]
  #if "affiliation" in author [
    \ #emph(author.affiliation)
  ]
  #if "email" in author [
    \ #link("mailto:" + author.email)
  ]
]

#let render-author-grid(
  authors,
  columns: none,
  alignment: center,
  name-size: 14pt,
  gutter: 24pt,
  row-gap: 16pt,
) = {
  if authors.len() == 0 {
    none
  } else {
    let total = authors.len()
    let column-count = author-column-count(total, columns)
    let rows = calc.ceil(total / column-count)
    {
      for row in range(rows) {
        let start = row * column-count
        let end = calc.min((row + 1) * column-count, total)
        let slice = authors.slice(start, end)
        grid(
          columns: slice.len() * (1fr,),
          gutter: gutter,
          ..slice.map(author => align(alignment, author-block(author, name-size: name-size)))
        )
        if row < rows - 1 {
          v(row-gap, weak: true)
        }
      }
    }
  }
}

#let render-frontmatter(
  abstract,
  keywords,
  JEL,
  text-width: 80%,
  section-gap: 10pt,
  leading: 1.32em,
  paragraph-spacing: 0.7em,
) = {
  if abstract == none and keywords == none and JEL == none {
    none
  } else {
    box(width: text-width)[
      #set par(
        leading: leading,
        spacing: paragraph-spacing,
        first-line-indent: 0em,
        justify: true,
      )
      #set align(left)
      #if abstract != none {
        par(justify: true)[
          #align(center, [*Abstract*])
          #abstract
        ]
      }
      #if abstract != none and (keywords != none or JEL != none) {
        v(section-gap, weak: true)
      }
      #if keywords != none {
        par(justify: true)[
          #emph([*Keywords:*]) #keywords
        ]
      }
      #if keywords != none and JEL != none {
        v(section-gap, weak: true)
      }
      #if JEL != none {
        par(justify: true)[
          #emph([*JEL Classification:*]) #JEL
        ]
      }
    ]
  }
}

#let paper(
  font: "PT Serif",
  fontsize: 11pt,
  title: none,
  subtitle: none,
  maketitle: true,
  authors: (),
  date: none,
  abstract: none,
  keywords: none,
  JEL: none,
  acknowledgments: none,
  bibliography: none,
  author-columns: none,
  author-alignment: center,
  cover-title-size: 20pt,
  cover-subtitle-size: 13pt,
  cover-author-name-size: 14pt,
  cover-spacing: 24pt,
  cover-author-gutter: 24pt,
  cover-author-row-gap: 16pt,
  cover-text-width: 90%,
  cover-line-leading: 1.32em,
  cover-paragraph-spacing: 0.7em,
  frontmatter-gap: 12pt,
  inline-title-size: 18pt,
  inline-subtitle-size: 12pt,
  inline-author-name-size: 12pt,
  inline-author-gutter: 18pt,
  inline-author-row-gap: 12pt,
  body-line-leading: 1.32em,
  body-paragraph-spacing: 0.7em,
  body-text-spacing: 106%,
  doc,
) = {
  set math.equation(numbering: "(1)", supplement: auto)

  set text(
    font: font,
    size: fontsize,
    spacing: body-text-spacing,
  )

  set page(numbering: "1")

  set document(
    title: title,
    author: authors.map(author => author.name),
  )

  set footnote.entry(separator: line(length: 100%, stroke: 0.5pt))
  set footnote.entry(indent: 0em, gap: 0.6em)
  show footnote.entry: set align(left)

  if maketitle == true {
    set footnote(numbering: "*")
    set par(
      leading: cover-line-leading,
      spacing: cover-paragraph-spacing,
      first-line-indent: 0em,
      justify: false,
    )
    set align(center)

    if title != none {
      text(cover-title-size, [
        #strong(title)
        #if acknowledgments != none { footnote(acknowledgments) }
      ])
    }

    if subtitle != none {
      v(cover-spacing, weak: true)
      text(cover-subtitle-size, subtitle)
    }

    if authors.len() > 0 {
      v(cover-spacing, weak: true)
      render-author-grid(
        authors,
        columns: author-columns,
        alignment: author-alignment,
        name-size: cover-author-name-size,
        gutter: cover-author-gutter,
        row-gap: cover-author-row-gap,
      )
    }

    if date != none {
      v(cover-spacing, weak: true)
      text(12pt, [This Version: #date])
    }

    let frontmatter = render-frontmatter(
      abstract,
      keywords,
      JEL,
      text-width: cover-text-width,
      section-gap: frontmatter-gap,
      leading: cover-line-leading,
      paragraph-spacing: cover-paragraph-spacing,
    )
    if frontmatter != none {
      v(cover-spacing, weak: true)
      frontmatter
    }

    set align(left)
    pagebreak()
  } else {
    set footnote(numbering: "*")
    set par(
      leading: cover-line-leading,
      spacing: cover-paragraph-spacing,
      first-line-indent: 0em,
      justify: false,
    )
    set align(left)

    if title != none {
      text(inline-title-size, align(center, [
        #strong(title)
        #if acknowledgments != none { footnote(acknowledgments) }
      ]))
    }

    if subtitle != none {
      v(6pt, weak: true)
      text(inline-subtitle-size, align(center, { subtitle }))
    }

    if authors.len() > 0 {
      v(cover-spacing, weak: true)
      set align(center)
      render-author-grid(
        authors,
        columns: author-columns,
        alignment: author-alignment,
        name-size: inline-author-name-size,
        gutter: inline-author-gutter,
        row-gap: inline-author-row-gap,
      )
      set align(left)
    }

    if date != none {
      v(cover-spacing, weak: true)
      align(center, [This Version: #date])
    }

    let frontmatter = render-frontmatter(
      abstract,
      keywords,
      JEL,
      text-width: cover-text-width,
      section-gap: frontmatter-gap,
      leading: cover-line-leading,
      paragraph-spacing: cover-paragraph-spacing,
    )
    if frontmatter != none {
      v(cover-spacing, weak: true)
      frontmatter
    }
  }

  set footnote(numbering: "1")
  set footnote.entry(separator: line(length: 100%, stroke: 0.5pt))
  set footnote.entry(indent: 0em, gap: 0.6em)

  set align(left)

  v(10pt)

  set heading(numbering: "1.")
  set math.equation(numbering: "(1)", supplement: auto)
  show heading.where(): it => [
    #context it
    #v(10pt)
  ]
  set text(spacing: body-text-spacing)
  set par(
    leading: body-line-leading,
    spacing: body-paragraph-spacing,
    first-line-indent: 0em,
    justify: true,
  )

  columns(1, doc)

  set par(
    leading: body-line-leading,
    spacing: body-paragraph-spacing,
    first-line-indent: 0em,
    justify: true,
  )

  if bibliography != none {
    colbreak()
    show heading: it => [
      #set align(left)
      #it.body
      #v(10pt)
    ]
    bibliography
  }
}