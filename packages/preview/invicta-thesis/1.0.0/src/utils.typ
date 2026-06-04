// Additional utility functions for FEUP thesis

// Function to create a dedication page
#let dedication(content) = {
  set page(numbering: none)
  v(1fr)
  set align(center)
  text(size: 14pt, style: "italic")[#content]
  v(2fr)
  pagebreak()
}

// Function to create an epigraph (quote with attribution)
#let epigraph(quote, author, source: none) = {
  place(
    horizon + right,
    [
      #text(size: 14pt, style: "italic")[
        "#quote"
      ]
      #v(1cm)
      #text(size: 12pt)[
        #author
      ]
    ]
  )
}

// Function for glossary entries
#let glossary-entry(term, definition) = {
  grid(
    columns: (1fr, 3fr),
    column-gutter: 1em,
    [*#term*], [#definition]
  )
}

// Function to create code blocks with proper formatting
#let code-block(code, caption: none, lang: none) = {
  figure(
    block(
      fill: gray.lighten(95%),
      inset: 1em,
      radius: 3pt,
      width: 100%,
      stroke: 0.5pt + gray,
      code
    ),
    caption: caption,
    kind: "code",
    supplement: [Listing]
  )
}

// Function for creating algorithm pseudocode
#let algorithm(title, content) = {
  figure(
    block(
      fill: gray.lighten(97%),
      inset: 1em,
      radius: 3pt,
      width: 100%,
      stroke: 0.5pt + gray,
      [
        #align(center)[*#title*]
        #line(length: 100%)
        #content
      ]
    ),
    caption: title,
    kind: "algorithm",
    supplement: [Algorithm]
  )
}

// Function for creating a list of acronyms
#let acronym-list(acronyms) = {
  // Use text instead of heading to avoid showing in table of contents
  v(4em)
  text(size: 26pt, weight: "bold")[List of Acronyms]
  v(1em)
  
  table(
    columns: (1fr, 3fr),
    stroke: none,
    fill: none,
    ..acronyms.flatten()
  )
  
  pagebreak()
}

// Function for creating mathematical notation list
#let notation-list(symbols) = {
  heading(level: 1, numbering: none)[Mathematical Notation]
  
  table(
    columns: (1fr, 3fr),
    stroke: none,
    fill: none,
    ..symbols.pairs().map(((symbol, description)) => (symbol, description)).flatten()
  )
  
  pagebreak()
}
