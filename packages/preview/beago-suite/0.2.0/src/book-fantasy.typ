#import "dependencies.typ": dropcap, typearea

/// Drop cap for chapter openings: `#dropped[First words,][ rest of paragraph.]`
#let dropped(first, rest) = {
  dropcap(height: 3, gap: 0.5em)[#smallcaps(first)#rest]
}

/// Framed full-page illustration with italic caption.
#let framed-image(img-path, cap, height: 95%) = {
  figure(
    rect(
      stroke: 1pt + black,
      inset: 1pt,
      image(img-path, height: height, scaling: "smooth"),
    ),
    caption: text(size: 10pt, style: "italic", cap),
    kind: "beago-image",
    supplement: [],
    numbering: none,
  )
}

/// Part title page: `#book-part[The Pastoral Years]` → "Part I", "Part II", … (outline too)
#let book-part(title) = {
  counter("beago-part").step()
  heading(
    level: 1,
    supplement: [Part],
    outlined: true,
    bookmarked: true,
    title,
  )
}

/// Switch into end matter (appendix, notes): `#show: book-backmatter`
#let book-backmatter(body) = {
  set heading(numbering: none, outlined: true)
  set page(footer: none)
  body
}

#let _titlepage-auto(
  title,
  title-prefix,
  subtitle,
  author,
  author-note,
  font-size,
) = {
  align(center)[
    #v(2fr)
    #if title-prefix != none {
      text(
        size: font-size * 1.5,
        weight: "semibold",
        tracking: 0.05em,
        upper(title-prefix),
      )
      v(0.5em)
    }
    #text(
      size: font-size * 2,
      weight: "semibold",
      tracking: 0.1em,
      upper(title),
    )
    #v(0.35em)
    #text(size: font-size * 1.4, tracking: 0.025em, smallcaps(author))
    #v(2fr)
  ]
}

#let _centered-page(body, style: none, size: none) = {
  pagebreak()
  set text(style: style) if style != none
  set text(size: size) if size != none
  set par(justify: false, first-line-indent: 0em)
  align(center)[
    #v(1fr)
    #body
    #v(1fr)
  ]
}

/// A5 two-sided fantasy/historical book layout (Schola, drop caps, mirrored margins).
///
/// Order: cover → titlepage → publishing-info → dedication →
/// acknowledgements → epigraph → frontmatter → TOC → body → colophon
#let book-fantasy(
  title: [Title],
  title-prefix: none,
  subtitle: none,
  author: [Author],
  author-note: none,
  publisher: none,
  place: none,
  year: none,
  cover-image: none,
  titlepage: auto,
  publishing-info: none,
  dedication: none,
  acknowledgements: none,
  epigraph: none,
  frontmatter: none,
  colophon: false,
  font: "TeX Gyre Schola",
  font-size: 11pt,
  paper: "a5",
  two-sided: true,
  binding-correction: 8mm,
  show-outline: true,
  show-figures-outline: false,
  body,
) = {
  set document(title: title)

  show: typearea.with(
    two-sided: two-sided,
    paper: paper,
    div: 12,
    binding-correction: binding-correction,
    footer-include: false,
    header-include: false,
    footer-height: 0em,
    header-height: 0em,
  )

  set text(font: font, size: font-size, lang: "en")

  set par(
    justify: true,
    justification-limits: (
      spacing: (
        min: 47%, // default: 66.67%
        max: 150%,
      ),
    ),
    first-line-indent: (amount: 1em, all: true),
    spacing: 0.8em,
    leading: 0.8em,
  )

  // Parts = level 1 (with supplement Part); chapters = level 2.
  // Unnumbered level-1 (Preface, Appendix) keeps chapter styling.
  show heading.where(level: 1): it => {
    if it.supplement == [Part] {
      let n = counter("beago-part").at(it.location()).first()
      pagebreak()
      align(center)[
        #v(1fr)
        #text(size: 12pt, tracking: 0.15em, smallcaps[Part #numbering("I", n)])
        #v(1.25em)
        #text(size: 18pt, weight: "regular", style: "italic", it.body)
        #v(1fr)
      ]
      pagebreak()
    } else {
      set align(center)
      set text(size: 18pt, weight: "regular", style: "italic")
      pagebreak() + v(4em) + it.body + v(3em)
    }
  }

  show heading.where(level: 2): it => {
    counter("beago-chapter").step()
    pagebreak()
    v(4em)
    context {
      let n = counter("beago-chapter").at(it.location()).first()
      align(center)[
        #text(size: 14pt, weight: "regular", tracking: 0.1em, numbering("I", n))
        #v(0.85em)
        #text(size: 18pt, weight: "regular", style: "italic", it.body)
        #v(4em)
      ]
    }
  }

  set footnote(numbering: "*")
  set footnote.entry(indent: 0em)
  set page(header: counter(footnote).update(0))

  set figure(
    numbering: none,
    placement: auto,
    kind: "beago-image",
    supplement: [],
  )

  // Cover
  set page(footer: none)
  align(center)[
    #v(1fr)
    #if title-prefix != none {
      text(
        size: 18pt,
        weight: "semibold",
        tracking: 0.05em,
        upper(title-prefix),
      )
      v(0.5em)
    }
    #text(size: 22pt, weight: "semibold", tracking: 0.1em, upper(title))
    #v(1fr)
    #if subtitle != none {
      text(size: 12pt, style: "italic", subtitle)
      v(1fr)
    }
    #text(size: 11pt, smallcaps[by])
    #v(0.35em)
    #text(size: 16pt, tracking: 0.025em, smallcaps(author))
    #if author-note != none {
      linebreak()
      text(size: 9pt, style: "italic", author-note)
    }
    #v(2fr)
    #if cover-image != none {
      cover-image
      v(2fr)
    }
    #if place != none {
      text(size: 12pt, tracking: 0.1em, smallcaps(place))
    }
    #v(1fr)
    #if publisher != none {
      text(size: 12pt, smallcaps(publisher))
    }
    #if year != none {
      linebreak()
      text(size: 12pt, smallcaps(year))
    }
  ]

  // Title page
  if titlepage == auto {
    pagebreak()
    _titlepage-auto(
      title,
      title-prefix,
      subtitle,
      author,
      author-note,
      font-size,
    )
  } else if titlepage != none {
    pagebreak()
    titlepage
  }

  // Publishing info (copyright)
  if publishing-info != none {
    _centered-page(publishing-info, size: font-size * 0.9)
  }

  // Dedication
  if dedication != none {
    _centered-page(dedication, style: "italic")
  }

  // Acknowledgements
  if acknowledgements != none {
    pagebreak()
    v(1fr)
    linebreak()
    set par(first-line-indent: 0em)
    align(center, acknowledgements)
    v(2fr)
  }

  // Epigraph
  if epigraph != none {
    pagebreak()
    set text(size: font-size * 0.9, style: "italic")
    set par(justify: false, first-line-indent: 0em)
    v(1fr)
    align(center, epigraph)
    v(2fr)
  }

  set heading(numbering: none)
  set outline.entry(fill: none)
  show outline.entry.where(level: 1): it => {
    v(1.5em, weak: true)
    if it.element.supplement == [Part] {
      let n = counter("beago-part").at(it.element.location()).first()
      it.indented([Part #numbering("I", n)#h(0.35em)], it.inner())
    } else {
      it
    }
  }
  show outline.entry.where(level: 2): it => {
    let n = counter("beago-chapter").at(it.element.location()).first()
    it.indented(
      box(width: 1.75em, align(right, numbering("I", n))) + h(0.5em),
      it.inner(),
    )
  }

  if show-outline or show-figures-outline {
    // `set page` already starts a new page; a prior pagebreak would leave a blank "i".
    set page(
      footer: context {
        let n = counter(page).get().first()
        align(if calc.odd(n) { right } else { left }, numbering("i", n))
      },
    )
    counter(page).update(1)
    if show-outline {
      outline(title: "Table of Contents", indent: auto)
    }
    if show-figures-outline {
      outline(
        title: "List of Figures",
        target: figure.where(kind: "beago-image"),
      )
    }
  }

  // Body
  set page(
    footer: context {
      let n = counter(page).get().first()
      align(if calc.odd(n) { right } else { left }, numbering("1", n))
    },
  )
  counter(page).update(1)

  body

  // Colophon
  if colophon {
    pagebreak()
    set page(footer: none)
    set text(size: font-size * 0.85)
    set par(justify: false, first-line-indent: 0em)
    align(left)[
      #v(3fr)
      Set in #font, #font-size.\
      Paper #upper(paper)#if two-sided [, two-sided].\
      Typeset with Typst and #link(
        "https://typst.app/universe/package/beago-suite/",
        "beago-suite",
      )'s `book-fantasy` layout.
      #v(1fr)
    ]
  }
}
