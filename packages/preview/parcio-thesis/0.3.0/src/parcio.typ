#import "titlepage.typ": *
#import "util.typ": *

#let parcio(
  /// The title of your thesis.
  /// -> content
  title: [Title],
  /// The author data (your name and student mail).
  /// -> dictionary
  author: (name: "Author", mail: "author@ovgu.de"), 
  /// The optional abstract of your thesis.
  /// -> content | none
  abstract: [],
  /// The thesis type (bachelor, master, PhD, etc...).
  /// -> string
  thesis-type: "Bachelor or Master",
  /// The reviewers and supervisors of your thesis.
  /// -> array 
  reviewers: (),
  /// The submission date.
  /// -> datetime
  date: datetime.today(),
  /// The way your headings should be numbered.
  /// -> numbering | string
  heading-numbering: "1.1.",
  /// Whether to start a new chapter at an even or odd page (can be `"even"`, `"odd"` or `none`).
  /// -> str | none
  chapter-start-at: none,
  /// The language of your thesis for automatic hyphenation and spellcheck.
  /// -> string
  lang: "en",
  /// The logo(s) of your faculty or institution.
  /// -> content
  header-logo: image("logos/OVGU-INF.pdf", width: 66%),
  /// Custom translations for certain keywords in TOML format.
  /// -> dictionary
  translations: toml("translations.toml"),
  body
) = {
  // Basic document & page rules.
  set document(title: title, author: author.name)
  set page(
    "a4", 
    margin: (x: 2.5cm), 
    number-align: right, 
    numbering: "i", 
    footer: none
  )

  // Handle translations in separate toml file for basic terms.
  let trans = translations.at(lang, default: translations.at(translations.default-lang))

  set text(font: "Libertinus Serif", 12pt, lang: lang)
  set heading(numbering: heading-numbering, supplement: trans.section)
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
  show heading.where(level: 1): set heading(supplement: trans.chapter)
  show heading.where(level: 1): h => {
    set text(_huge, font: "Libertinus Sans")

    // Non-numbered headings still get some extra vertical spacing.
    if h.numbering != none {
      assert(
        chapter-start-at in (none, "even", "odd"),
        message: "invalid option for chapter starting page"
      )

      {
        // Ensure truly empty pages when skipping pages to next chapter.
        set page(footer: none) if chapter-start-at != none
        pagebreak(weak: true, to: chapter-start-at)
      }

      v(2.3cm)

      // Reset figure counters.
      counter(figure.where(kind: image)).update(0)
      counter(figure.where(kind: table)).update(0)
      counter(figure.where(kind: raw)).update(0)

      block[
        #let heading-prefix = if h.supplement == [Appendix] [
          Appendix #counter(heading).display(h.numbering)
        ] else [
          #trans.chapter #counter(heading).display()
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

  set outline(title: trans.contents)
  show outline: it => { show heading: pad.with(bottom: 0.75em); it }

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

  show heading.where(level: 1): it => it + v(0.6em)
  show heading.where(level: 2).or(heading.where(level: 3)): set text(font: "Libertinus Sans", _Large)
  show heading.where(level: 2).or(heading.where(level: 3)): set block(spacing: 1.25em)
  
  set footnote.entry(separator: line(length: 40%, stroke: 0.5pt))
  set list(marker: (sym.bullet, "◦"))

  /* --- Title Page --- */

  title-page(
    author,
    thesis-type,
    header-logo,
    reviewers,
    trans,
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
