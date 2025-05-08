
// Formating Config of the Main-Document
#let format-doc-main(body) = {

  // Set - Pages
  // --------------------------------------------------------
  set page(footer: context {
    set align(center)
    [\u{2015}]
    counter(page).display("  1  ")
    [\u{2015}]
  })

  
  // Set - Headings
  // --------------------------------------------------------
  set heading(numbering: "1.")

  
  // Styling - Level 1 Headings
  // --------------------------------------------------------
  show heading.where(level: 1): item => {
    set text(23pt)
    v(1.7em)
    //item
    underline()[#counter(heading).display() #item.body]
    //underline(evade: false,)[#item] // does not 
    v(0.7em)
  }

  
  // Styling - Level 2 Headings
  // --------------------------------------------------------
  show heading.where(level: 2): item => {
    set text(16pt)
    v(1.4em)
    item
    //underline[#counter(heading).display() #item.body]
    v(0.4em)
  }

  
  // Styling - Level 3 Headings
  // --------------------------------------------------------
  show heading.where(level: 3): item => {
    set text(14pt)
    v(1.2em)
    item
    v(0.2em)
  }

  
  // Styling - Level 4 Headings
  // --------------------------------------------------------
  show heading.where(level: 4): item => {
    v(1.1em)
    emph[#counter(heading).display() #item.body]
    v(0.1em)
  }

  
  // Body
  // --------------------------------------------------------
  body
}
