#import "titlepage.typ": *
#import "util.typ": *

#let parcio(
  title: [Title], 
  author: (name: "Author", mail: "author@ovgu.de"), 
  abstract: [], 
  thesis-type: "Bachelor/Master", 
  reviewers: (), 
  date: datetime.today(),
  lang: "en",
  header-logo: none,
  translations: none,
  body
) = {
  /* Basic document rules. */
  set document(title: title, author: author.name)
  set page("a4", margin: 2.5cm, number-align: right, numbering: "i", footer: none)
  set text(font: "Libertinus Serif", 12pt, lang: lang)
  set heading(numbering: "1.1.")
  set par(justify: true)
  set math.equation(numbering: "(1)")

  /* Handle translations in separate toml file for basic terms. */
  let _translation-file = toml(if-none("translations.toml", translations))
  let translations = _translation-file.at(
    lang, 
    default: _translation-file.at(_translation-file.default-lang)
  )

  /* ---- General design choices. --- */

  // Make URLs use monospaced font.
  show link: it => {
    set text(font: "Inconsolata", 12pt * 0.95) if type(it.dest) == str
    it
  }

  // Enable heading specific figure numbering and increase spacing.
  show figure: set block(spacing: 1.5em)
  set figure(
    numbering: n => numbering("1.1", counter(heading).get().first(), n), 
    gap: 1em
  )

  // Add final period after fig-numbering (1.1 -> 1.1.).
  // Additionally, left align caption if it spans multiple lines.
  show figure.caption: c => {
    grid(
      columns: 2,
      align(top)[#c.supplement #context c.counter.display(c.numbering).#c.separator],
      align(left, c.body),
    )
  }

  /* ---- Stylization of headings / chapters. ---- */

  // Create "Chapter X." heading for every numbered level 1 heading.
  show heading.where(level: 1): h => {
    set text(_huge, font: "Libertinus Sans")

    if h.numbering != none {
      pagebreak(weak: true)
      v(2.3cm)

      // Reset figure counters.
      counter(figure.where(kind: image)).update(0)
      counter(figure.where(kind: table)).update(0)
      counter(figure.where(kind: raw)).update(0)

      block[
        #let heading-prefix = if h.supplement == [Appendix] [
          Appendix #counter(heading).display(h.numbering)
        ] else [
          #translations.chapter #counter(heading).display()
        ]

        #heading-prefix#v(0.25em)#h.body
      ]
    } else {
      v(2.3cm) + h
    }
  }

  show heading.where(level: 2): h => block({
    if h.numbering != none {
      [#counter(heading).display()~~#h.body]
    } else {
      h
    }
  })

  /* Adjust refs: "Chapter XYZ" instead of "Section XYZ". */
  set ref(supplement: it => {
    if it.func() == heading and it.supplement == auto {
      if it.level > 1 {
        translations.section
      } else {
        translations.chapter
      }
    } else {
      it.supplement
    }
  })

  /* ---- Customization of ToC ---- */

  set outline(fill: repeat(justify: true, gap: 0.5em)[.], title: translations.contents)
  show outline: o => {
    show heading: pad.with(bottom: 1.25em)
    o
  }

  // Level 1 chapters get bold and no dots.
  show outline.entry.where(level: 1): it => {
    set text(font: "Libertinus Sans", weight: "bold")
    let cc = if it.element.numbering != none {
      numbering(
        it.element.numbering, 
        ..counter(heading).at(it.element.location())
      )
    } else {
      h(-0.5em)
    }
    
    v(0.1em)
    box(grid(
      columns: (auto, 1fr, auto),
      link(it.element.location())[#cc #h(0.5em) #it.element.body],
      h(1fr),
      it.page,
    ))
  }

  // Level 2 and deeper.
  show outline.entry.where(level: 2)
    .or(outline.entry.where(level: 3)): it => {
    let cc = numbering("1.1.", ..counter(heading).at(it.element.location()))
    let indent = h(1.5em + ((it.level - 2) * 2.5em))
    
    box(
      grid(
        columns: (auto, 1fr, auto),
        indent + link(it.element.location())[#cc#h(1em)#it.element.body#h(5pt)],
        it.fill,
        box(width: 1.5em, align(right, it.page)),
      ),
    )
  }

  /* ----------------------------- */

  show raw: set text(font: "Inconsolata")
  show raw.where(block: true): r => {
    set par(justify: false)
    show raw.line: l => {
      box(table(
        columns: (-1.25em, 100%),
        stroke: 0pt,
        inset: 0em,
        column-gutter: 1em,
        align: (x, y) => if x == 0 { right } else { left },
        text(fill: ovgu-darkgray, str(l.number)),
        l.body,
      ))
    }
    
    set align(left)
    rect(width: 100%, stroke: gray + 0.5pt, inset: 0.75em, r)
  }

  /* ----------------------------- */

  show heading: set block(spacing: 1.25em)
  show heading.where(level: 2): set text(font: "Libertinus Sans", _Large)
  show heading.where(level: 3): set text(font: "Libertinus Sans", _Large)
  
  set footnote.entry(separator: line(length: 40%, stroke: 0.5pt))
  set list(marker: (sym.bullet, "◦"))

  /* --- Title Page --- */

  title-page(
    title,
    author,
    thesis-type,
    header-logo,
    reviewers,
    translations,
    date
  )
  
  show raw: set text(12pt * 0.95)
  pagebreak(to: "odd")
  set-page-properties()

  /* --- Abstract --- */

  v(-8.5em)
  align(center + horizon)[
    #text(font: "Libertinus Sans", [*Abstract*])\ \
    #align(left, abstract)
  ]
  
  /* --- Document Body --- */

  pagebreak(to: "odd")
  body
}