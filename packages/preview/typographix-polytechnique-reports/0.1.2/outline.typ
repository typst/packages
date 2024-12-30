/***********************/
/* TEMPLATE DEFINITION */
/***********************/

#let apply(doc) = {

  show outline: o => {
    set par(first-line-indent: 0pt)
    o
  }
  
  // Level 1 headings
  show outline.entry.where(level : 1): i => {
    strong(i)
  }
  
  // Don't forget to return doc cause
  // we're in a template
  doc
}


/********************/
/* TESTING TEMPLATE */
/********************/

#show: apply

#set heading(numbering: "1.1")

#outline()

= My first section

== A sub-section 

#heading(level: 2, numbering: none)[Sub-section without numbering]

== Another sub-section

= Last one
