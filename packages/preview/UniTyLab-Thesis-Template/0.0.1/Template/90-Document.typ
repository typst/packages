// General Configuration Template
#import "config.typ": *
#show: config.with()


// =================================================================
// Initialice Typst Universe Packages
// =================================================================

// Codly
#show: codly-init.with()
#codly(  
  fill: luma(251),
  zebra-fill: luma(241),
  stroke: 1pt + luma(0),
  inset: 0.35em,
  languages: codly-languages
)


// Glossary
#show: make-glossary
#include "../Studi/50-Bibliography/52-Glossary.typ"



// =================================================================
// Display settings
// =================================================================

// Figure Caption Text
//#show figure.where(kind: table): set figure.caption(position: top)
#show figure.caption: set text(size:11pt, style: "italic")


// Highlight different Typs of Links
#show link: this => {
  if type(this.dest) == label {
    if this.body.has("children") and this.body.children.len() == 6 {
      if this.body.children.at(2) == [(] { 
        underline(text(weight: "medium", this)) 
      }
    } 
    else { text(weight: "medium", this) }
  } 
  else if type(this.dest) == str {
    context {
      if here().page() > 2 { underline(text(fill: blue.darken(60%), this)) }
      else { this }
    }
  } 
  else { underline(stroke: green, this) } 
}


// Numbering of Equations
#set math.equation(numbering: "(1)")

// Styling Heading
#show heading.where(level: 1): item => {
  set text(17pt)
  v(1.4em)
  item
  //underline[#item.body]
  //underline()[#counter(heading).display() #item.body]
  v(0.4em)
}

// =================================================================
// Document
// =================================================================

// Title
#include "00-Title/00-Title.typ"

// Pre-Document
#include "10-Pre-Doc.typ"

// Main-Document
#counter(page).update(1)      // Reset Counter Pages
#counter(heading).update(0)   // Reset Counter Headings
#include "20-Main-Doc-Intro.typ"
#include "../Studi/30-Chapters/30-Main-Doc-Personal.typ"
#include "40-Main-Doc-Outro.typ"

// Post-Document
#include "50-Bibliography.typ"
#include "../Studi/60-Post-Doc/60-Post-Doc.typ"

// Appendix
#include "../Studi/70-Appendix/70-Appendix.typ"
