#import "@preview/hydra:0.5.2": hydra 


/// A Template recreating the look of the classic Article Class.
/// -> content
#let article(
  /// Set the language of the document.
  /// -> str
  lang:"de",
  /// Set the equation numbering style.
  /// -> str | none
  eq-numbering:none,
  /// Set the text size.
  /// Headings are adjusted automatically.
  /// -> length
  text-size:10pt,
  /// Set the page numbering style.
  /// -> none | str | function
  page-numbering: "1",
  /// Set the page numbering alignment.
  /// -> alignment
  page-numbering-align: center,
  /// Set the heading numbering style.
  /// -> none | str | function
  heading-numbering: "1.1  ",
  /// Set the margins of the document.
  /// -> auto | relative | dictionary
  margins: (left: 25mm, right: 25mm, top: 30mm, bottom: 30mm),
  /// Set the Enum indentation.
  /// -> length
  enum-indent: 1.5em,
  /// Set the List indentation.
  /// -> length
  list-indent: 1.5em,
  /// Set if the default header should be used.
  /// -> bool
  show-header: false,
  /// Set if the default header should be alternating.
  /// -> bool
  alternating-header: true,
  /// Set the first page of the header.
  /// -> int | float
  first-page-header: 1,
  /// Set the Header Titel
  /// -> str | content
  header-titel: none,
  ///-> content
  content) = {
  // Set the document's basic properties.
  set page(
    margin: margins,
    numbering: page-numbering,
    number-align: page-numbering-align,
  )
  set text(font: "New Computer Modern", lang:lang, size: text-size)
  show math.equation: set text(weight: 400)
  set math.equation(numbering: eq-numbering)
  set heading(numbering: heading-numbering)
  set enum(indent: enum-indent)
  set list(indent: list-indent)
  show link: it => text(fill:blue.darken(20%), it)
  set outline(indent: auto)
  show outline.entry.where(
    level: 1,
  ): it => {
    v(15pt, weak: true)
    text(size:11pt ,[
      #strong(it.body)
      #box(width: 1fr, repeat[])
      #strong(it.page)
      ])}
      
  // Referencing Figures
  show figure.where(kind: table): set figure(supplement:[Tab.], numbering: "1") if lang == "de" 
  show figure.where(kind: image): set figure(supplement:[Abb.], numbering: "1",) if lang == "de"

  // Set Table style
  set table(
    stroke: none,
    gutter: auto,
    fill: none,
    inset: (right: 1.5em),
  )

  // Configure figures (tables)
  show figure.where(kind: table): it => {
    show: pad.with(x: 23pt)
    set align(center)
    v(12.5pt, weak: true)
    // Display the figure's caption.
    if it.has("caption") {
      v(if it.has("gap") { it.gap } else { 17pt }, weak: true)
      strong(it.supplement)
      if it.numbering != none {
        [ ]
        strong(it.counter.display(it.numbering))
      }
      [*: *]
      it.caption.body
    
    // Display the figure's body.
    it.body
    }
    v(15pt, weak: true)
  }

  // Configure figures (images)
  show figure.where(kind: image): it => {
    show: pad.with(x: 23pt)
    set align(center)
    v(12.5pt, weak: true)
    // Display the figure's body.
    it.body
    // Display the figure's caption.
    if it.has("caption") {
      v(if it.has("gap") { it.gap } else { 17pt }, weak: true)
      strong(it.supplement)
      if it.numbering != none {
        [ ]
        strong(it.counter.display(it.numbering))
      }
      [*: *]
      it.caption.body
    }
    v(15pt, weak: true)
  }

  // Configure the header.
  let header-oddPage = context {
    set text(10pt)
    set grid.hline(stroke: 0.9pt)
    grid(
      columns: (1fr, 1fr),
      align: (left, right),
      inset:4pt,
      smallcaps(header-titel),
      hydra(1),
      grid.hline(),
    )    
  }

  let header-evenPage = context {
    set text(10pt)
    set grid.hline(stroke: 0.9pt)
    grid(
      columns: (1fr, 1fr),
      align: (left, right),
      inset:4pt,
      hydra(1),
      smallcaps(header-titel),
      grid.hline(),
    )
  }

  let header-content = context {
    let current = counter(page).get().first()

    if current > first-page-header and calc.rem(current,2) == 0{
      return header-oddPage
    } else if current > first-page-header {
      if alternating-header {
        return header-evenPage
      } else {
        return header-oddPage
      }
    }
  }

  set page(header: header-content) if show-header

  // Main body.
  set par(justify: true)

  content
}

/// Make the title of the document.
/// -> content
#let maketitle(
  /// The title of the document.
  /// -> string | content
  title: "",
  /// The authors of the document.
  /// -> array
  authors: (),
  /// The date of the document.
  /// -> string | content | datetime
  date: none,
  /// Use titel and author information for
  /// the document metadata.
  /// -> bool
  metadata: true,
) = {
  if metadata {
    set document(author: authors, title: title)
  }
  // Author information.
  let authors-text = {
    set text(size: 1.1em)
    pad(
      top: 0.5em,
      bottom: 0.5em,
      x: 2em,
      grid(
        columns: (1fr,) * calc.min(3, authors.len()),
        gutter: 1em,
        ..authors.map(author => align(center, author)),
      ),
  )}
  
  // Frontmatter
  align(center)[
    #v(60pt)
    #block(text(weight: 400, 18pt, title))
    #v(1em, weak: true)
    #authors-text
    #v(1em, weak: true)
    #block(text(weight: 400, 1.1em, date))
    #v(20pt)
  ]
}