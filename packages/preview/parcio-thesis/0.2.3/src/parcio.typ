#import "titlepage.typ": *
#import "util.typ": *

#let parcio(
  title: [Title], 
  author: (name: "Author", mail: "author@ovgu.de"), 
  abstract: [], 
  thesis-type: "Bachelor/Master", 
  reviewers: (), 
  date: datetime.today(),
  heading-numbering: "1.1.",
  lang: "en",
  header-logo: none,
  translations: none,
  body
) = {
  // Basic document rules.
  set document(title: title, author: author.name)
  set page(
    "a4", 
    margin: (left: 2.5cm, right: 2.5cm), 
    number-align: right, 
    numbering: "i", 
    footer: none
  )

  // Handle translations in separate toml file for basic terms.
  let _translation-file = toml(if-none("translations.toml", translations))
  let translations = _translation-file.at(
    lang, 
    default: _translation-file.at(_translation-file.default-lang)
  )

  set text(font: "Libertinus Serif", 12pt, lang: lang)
  set heading(numbering: heading-numbering, supplement: translations.section)
  set par(justify: true)
  set math.equation(numbering: "(1)")

  /* ---- General design choices. --- */

  // Make URLs use monospaced font.
  show link: it => { set text(..mono-args) if type(it.dest) == str; it }

  // Enable heading specific figure numbering and increase spacing.
  show figure: set block(spacing: 1.5em)
  set figure(numbering: n => numbering("1.1", counter(heading).get().first(), n), gap: 1em)

  // Add final period after fig-numbering (1.1 -> 1.1.).
  // Additionally, left align caption if it spans multiple lines.
  show figure.caption: c => {
    grid(
      columns: 2,
      align: top + left,
      [#c.supplement #context c.counter.display(c.numbering).#c.separator],
      c.body,
    )
  }

  /* ---- Stylization of headings / chapters. ---- */

  // Create "Chapter X." heading for every numbered level 1 heading.
  show heading.where(level: 1): set heading(supplement: translations.chapter)
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

        #heading-prefix#v(0.2em)#h.body
      ]
    } else {
      v(2.3cm) + h
    }
  }

  // Add some additonal spacing between numbering and level 2 heading.
  show heading.where(level: 2): it => block({
    if it.numbering != none {
      counter(heading).display()
      h(0.5em)
    }
    it.body
  })

  /* ---- Customization of ToC ---- */

  set outline(title: translations.contents)
  show outline: it => { show heading: pad.with(bottom: 1.25em); it }

  // Level 1 outline entries are bold and there is no fill.
  show outline.entry.where(level: 1): set outline.entry(fill: none)
  show outline.entry.where(level: 1): set block(above: 1.35em)
  show outline.entry.where(level: 1): set text(font: "Libertinus Sans", weight: "bold")

  // Level 2 and 3 outline entries have a bigger gap and a dot fill.
  show outline.entry.where(level: 2)
    .or(outline.entry.where(level: 3)): set outline.entry(fill: repeat(justify: true, gap: 0.5em)[.])

  show outline.entry.where(level: 2).or(outline.entry.where(level: 3)): it => link(
    it.element.location(),
    it.indented(gap: 1em, it.prefix(),
      it.body()
        + box(width: 1fr, inset: (left: 5pt), it.fill)
        + box(width: 1.5em, align(right, it.page())),
    )
  )

  /* ----------------------------- */

  show raw: set text(..mono-args)
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
    block(width: 100%, stroke: gray + 0.5pt, inset: 0.75em, r)
  }

  /* ----------------------------- */

  show heading: set block(spacing: 1.25 * _Large)
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
  
  pagebreak(to: "odd")
  set-page-properties(margin-left: 2.5cm, margin-right: 2.5cm)

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
