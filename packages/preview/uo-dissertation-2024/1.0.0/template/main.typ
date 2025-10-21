// main.typ - Main dissertation file
// University of Oregon Dissertation Template

// Import configuration and styling
#import "config.typ": *
#import "metadata.typ": *

// Document setup
#set document(
  title: dissertation-title,
  author: author-name,
)

// Apply UO formatting rules to entire document
#show: doc => apply-uo-style(doc)

// Style hyperlinks to be blue and underlined
#show link: it => text(fill: blue, underline(it))

// ===== TITLE PAGE (Page 1, no number) =====
#set page(numbering: none)
#align(center)[
  #v(0.25in)
  #set par(leading: 2em)
  #text(size: 12pt, upper(dissertation-title))
  #v(0.25in)
  by
  #v(0.25in)
  #upper(author-name)
  #v(0.5in)
  A dissertation accepted and approved in partial fulfillment of the \
  requirements for the degree of
  #degree-name
  in
  #major-name
  #v(0.5in)
  Dissertation Committee: \
  #committee-chair, Chair \
  #if committee-cochair != none [#committee-cochair, Co-Chair \ ]
  #if committee-advisor != none [#committee-advisor, Advisor \ ]
  #committee-member-1, Core Member \
  #committee-member-2, Core Member \
  #institutional-rep, Institutional Representative
  #v(0.5in)
  University of Oregon
  #v(0.25in)
  #term #year
]

// ===== COPYRIGHT PAGE (Page 2) =====
#pagebreak()
#set page(numbering: "1", number-align: center + bottom)
#counter(page).update(2)
#v(4in)
#align(center)[
  #if copyright-option == "standard" [
    #sym.copyright #year #author-name
  ] else if copyright-option == "cc-by" [
    #sym.copyright #year #author-name
    #v(0.5em)
    This work is openly licensed via 
    #link("https://creativecommons.org/licenses/by/4.0/")[CC BY 4.0].
    #v(0.5em)
    #image("prefatory/cc-badges/cc-by.png", width: 88pt)
  ] else if copyright-option == "cc-by-sa" [
    #sym.copyright #year #author-name
    #v(0.5em)
    This work is openly licensed via 
    #link("https://creativecommons.org/licenses/by-sa/4.0/")[CC BY-SA 4.0].
    #v(0.5em)
    #image("prefatory/cc-badges/cc-by-sa.png", width: 88pt)
  ] else if copyright-option == "cc-by-nc" [
    #sym.copyright #year #author-name
    #v(0.5em)
    This work is openly licensed via 
    #link("https://creativecommons.org/licenses/by-nc/4.0/")[CC BY-NC 4.0].
    #v(0.5em)
    #image("prefatory/cc-badges/cc-by-nc.png", width: 88pt)
  ] else if copyright-option == "cc-by-nc-sa" [
    #sym.copyright #year #author-name
    #v(0.5em)
    This work is openly licensed via 
    #link("https://creativecommons.org/licenses/by-nc-sa/4.0/")[CC BY-NC-SA 4.0].
    #v(0.5em)
    #image("prefatory/cc-badges/cc-by-nc-sa.png", width: 88pt)
  ] else if copyright-option == "cc-by-nd" [
    #sym.copyright #year #author-name
    #v(0.5em)
    This work is openly licensed via 
    #link("https://creativecommons.org/licenses/by-nd/4.0/")[CC BY-ND 4.0].
    #v(0.5em)
    #image("prefatory/cc-badges/cc-by-nd.png", width: 88pt)
  ] else if copyright-option == "cc-by-nc-nd" [
    #sym.copyright #year #author-name
    #v(0.5em)
    This work is openly licensed via 
    #link("https://creativecommons.org/licenses/by-nc-nd/4.0/")[CC BY-NC-ND 4.0].
    #v(0.5em)
    #image("prefatory/cc-badges/cc-by-nc-nd.png", width: 88pt)
  ]
]

// ===== PREFATORY PAGES =====
#include "prefatory/abstract.typ"
#include "prefatory/cv.typ"  // Optional - comment out if not needed
#include "prefatory/acknowledgments.typ"  // Optional - comment out if not needed
#include "prefatory/dedication.typ"  // Optional - comment out if not needed

// ===== TABLE OF CONTENTS =====
#pagebreak()
#align(center)[
  #text(size: 12pt)[TABLE OF CONTENTS]
]
#v(14pt)
// Automatic table of contents showing chapters and sections (levels 1 and 2)
#show outline.entry.where(level: 1): it => {
  v(0.5em)
  text(weight: "bold")[#it]
}
#outline(
  title: none,
  indent: auto,
  depth: 2, // Shows chapters (level 1) and sections (level 2)
)
#v(0.25in)
// Manually add appendices and references if needed - update page numbers
// APPENDICES#box(width: 1fr, repeat[.#h(2pt)])85
// #pad(left: 0.5in)[
//   A. APPENDIX TITLE IN ALL CAPS#box(width: 1fr, repeat[.#h(2pt)])86 \
//   B. APPENDIX TITLE IN ALL CAPS#box(width: 1fr, repeat[.#h(2pt)])90
// ]
// REFERENCES CITED#box(width: 1fr, repeat[.#h(2pt)])95

// ===== LISTS OF FIGURES, TABLES, SCHEMES =====
#include "prefatory/list-of-figures.typ"  // Comment out if no figures
#include "prefatory/list-of-tables.typ"  // Comment out if no tables
#include "prefatory/list-of-schemes.typ"  // Comment out if no schemes

// ===== MAIN BODY =====
#pagebreak()
// Include chapters
#include "chapters/chapter-1.typ"
#include "chapters/chapter-2.typ"
#include "chapters/chapter-3.typ"
#include "chapters/chapter-4.typ"
// Add more chapters as needed:
// #include "chapters/chapter-5.typ"
// #include "chapters/chapter-6.typ"

// ===== APPENDICES =====
// Comment out if no appendices
// #include "appendices/appendix-a.typ"
// #include "appendices/appendix-b.typ"

// ===== REFERENCES =====
// #include "references.typ"