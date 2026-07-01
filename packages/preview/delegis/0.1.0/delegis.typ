// sentence marker
#let s = "XXXXXX"

#let unnumbered = (it, ..rest) => heading(level: 6, numbering: none, ..rest, it)

// template
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
) => [
  /// General Formatting
  #set document(title: title + " (" + abbreviation + ")", keywords: (title, abbreviation, resolution, in-effect))
  
  #let bg = if draft {
    rotate(45deg, text(100pt, fill: luma(85%), font: font, strDraft))
  } else {}
  
  #set page(paper: paper, numbering: "1 / 1", background: bg)
  #set text(hyphenate: true, lang: lang, size: size, font: font)

  /// Clause Detection
  #show regex("§ ([0-9a-zA-Z]+) (.+)$"): it => {
    
    let (_, number, ..rest) = it.text.split()
  
  
    align(center, heading(level: 6, numbering: none, {
      "§ " + number + "\n" + rest.join(" ")
    }))
  }

  /// Heading Formatting
  #set heading(numbering: "I.1.A.i.a.")
  #show heading: it => {
    set align(center)
  
    text(size: size, it, weight: "regular")
  }
  
  #show heading.where(level: 1): it => emph(it)
  #show heading.where(level: 2): it => emph(it)
  #show heading.where(level: 3): it => emph(it)
  #show heading.where(level: 4): it => emph(it)
  #show heading.where(level: 5): it => emph(it)
  
  #show heading.where(level: 6): it => strong(it)

  /// Outlines
  #show outline.entry: it => {
    show linebreak: it => {}
    show "\n": " "
    it
  }
  
  #set outline(indent: 1cm)
  #show outline: it => {
    it
    pagebreak(weak: true)
  }

  /// Sentence Numbering
  #show regex("XXXXXX"): it => {
    counter("sentence").step()
    super(strong(counter("sentence").display()))
  }
  
  #show parbreak: it => {
    counter("sentence").update(0)
    it
  }
  
  /// Title Page
  #page(numbering: none,{
    place(top + right, block(width: 2cm, logo))
    v(1fr)
  
    show par: set block(spacing: .6em)
  
    if draft { text[#str-draft:] } else { par(text(str-intro(resolution, in-effect))) }
    par(text(2em, strong[#title~(#abbreviation)]), leading: 0.6em)
    v(3cm)
  })

  /// Content
  #body
]
