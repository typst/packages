// sentence number substitution marker
#let s = "XXXXXXSENTENCEXXXNUMBERXXXXXX"

/// Create an unmarkes section, such as a preamble.
/// Usage: `#unnumbered[Preamble]`
#let unnumbered = (it, ..rest) => heading(level: 6, numbering: none, ..rest, it)

/// Manually create a section. Useful when unsupported characters are used in the heading.
/// Usage: `#section[§ 3][Administrator*innen]`
#let section = (number, it, ..rest) => unnumbered({number + "\n" + it}, ..rest)

/// Initialize a delegis document.
#let delegis = (
  // Metadata
  title : "Vereinsordnung zur IT-Infrastruktur",
  abbreviation : "ITVO",
  resolution : "3. Beschluss des Vorstands vom 24.01.2024",
  in-effect : "24.01.2024",
  draft : false,
  // Template
  logo : none,
  // Overrides
  size : 11pt,
  font : "Atkinson Hyperlegible",
  lang : "de",
  paper: "a5",
  str-draft : "Entwurf",
  str-intro : (resolution, in-effect) => [Mit Beschluss (#resolution) tritt zum #in-effect in Kraft:],
  // Content
  body
) => {
  /// Metadata
  set document(title: title + " (" + abbreviation + ")", keywords: (title, abbreviation, resolution, in-effect))
  
  /// General Formatting
  let bg = if draft {
    rotate(45deg, text(100pt, fill: luma(85%), font: font, str-draft))
  } else {}
  
  set page(paper: paper, numbering: "1 / 1", background: bg)
  set text(hyphenate: true, lang: lang, size: size, font: font)

  /// Clause Detection
  show regex("§ ([0-9a-zA-Z]+) (.+)$"): it => {
    let (_, number, ..rest) = it.text.split()
  
    heading(level: 6, numbering: none, {
      "§ " + number + "\n" + rest.join(" ")
    })
  }

  /// Heading Formatting
  set heading(numbering: "I.1.A.i.a.")
  show heading: set align(center)
  show heading: set text(size: size, weight: "regular")
  
  show heading.where(level: 1): set text(style: "italic")
  show heading.where(level: 2): set text(style: "italic")
  show heading.where(level: 3): set text(style: "italic")
  show heading.where(level: 4): set text(style: "italic")
  show heading.where(level: 5): set text(style: "italic")

  show heading.where(level: 6): set text(weight: "bold")
  
  /// Outlines
  show outline.entry: it => {
    show linebreak: it => {} // disable manual line breaks
    show "\n": " " // disable section number line breaks
    it
  }
  
  set outline(indent: 1cm)
  show outline: it => {
    it
    pagebreak(weak: true)
  }

  /// Sentence Numbering
  show regex(s): it => {
    counter("sentence").step()
    super(strong(counter("sentence").display()))
  }
  
  show parbreak: it => {
    counter("sentence").update(0)
    it
  }
  
  /// Title Page
  page(numbering: none, {
    place(top + right, block(width: 2cm, logo))
    v(1fr)
  
    show par: set block(spacing: .6em)
  
    if draft {
      text[#str-draft:] 
    } else {
      par(text(str-intro(resolution, in-effect))) 
    }
    
    par(text(2em, strong[#title (#abbreviation)]), leading: 0.6em)
    
    v(3cm)
  })

  // Metadata once again. Needs to be down here to have the page size set.
  // Can be used with `typst query`, e.g.:
  //
  // `typst query example.typ "<title>" --field value --one` returns `"[title]"`
  [
    #metadata(title)<title>
    #metadata(abbreviation)<abbreviation>
    #metadata(resolution)<resolution>
    #metadata(in-effect)<in-effect>
  ]

  // allow footnotes that don't conflict with sentence numbers
  set footnote(numbering: "[1]")

  /// Content
  body
}