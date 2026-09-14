#import "@preview/isc-hei-bthesis:0.5.0" : *

#let doc_language = "en" // Valid values are en, fr

#show: project.with( 
  title: "Life, the Universe and Everything", 
  sub-title: "A Bachelor Thesis in Data Engineering", // Optional

  is-thesis: true,   
  split-chapters: true,

  thesis-supervisor: "Prof. Dr John Von Neumann", 
  thesis-co-supervisor: "Lady Ada Lovelace", // Optional, use none if not needed
  thesis-expert: "Dr Grace Hopper", // Optional, use none if not needed
  
  school: "Haute École d'Ingénierie de Sion", 
  programme: "Informatique et Systèmes de communication (ISC)",

  // Some keywords related to your thesis
  keywords: ("engineering", "data", "machine learning", "meteorology"),
  major : "Data engineering", // "Software engineering", "Embedded systems", "Security", "something else"

  authors: "James Gosling", 

  date: datetime(year: 2025, month: 6, day: 24), // or datetime.today() 
  language: doc_language, // en or fr
  version: none, // or for instance "1.0", for the version of your thesis],  
  code-theme: "bluloco-light",
) 

// // If using acronyms 
#import "@preview/acrostiche:0.5.2": *     
#include "acronyms.typ"

// Let's get started folks!

#cleardoublepage()
#include "pages/abstract.typ"

#cleardoublepage()
#include "pages/résumé.typ"

#cleardoublepage()
#include "pages/acknowledgements.typ"

#table-of-contents(depth:2)

= Writing a thesis 

// Enable headers and footers from this point on
#set-header-footer(true)

Writing a report is an exercise that involves both *content and form*. In this document, we aim to simplify the formatting aspect without making any assumptions about the content, specifically in the context of the ISC program#footnote[Here is how to add a footnote https://isc.hevs.ch].

== The content of a thesis

The general structure of a bachelor thesis typically includes the following sections:

1. *Abstract*: A concise summary of the thesis, including the research question, methodology, results, and conclusions.
2. *Résumé*: A summary of the thesis in French.
3. *Acknowledgements*: (Optional) A section to thank those who supported the work.
4. *Table of Contents*: An organized listing of chapters and sections.
5. *Introduction*: Presents the background, motivation, objectives, and scope and plan of the thesis.
6. *State of the Art / Literature Review*: Reviews existing research and situates the thesis within the academic context. If salient in your work.
7. *Methodology*: Describes the methods, materials, and procedures used in the research / thesis.
8. *Results*: Presents the findings of the research, often with tables, figures, and analysis.
9. *Discussion*: Interprets the results, discusses implications, and relates findings to the research question.
10. *Conclusion*: Summarizes the main findings, contributions, and suggests future work.
11. *References / Bibliography*: Lists all sources cited in the thesis.
12. *Appendices*: (Optional) Contains supplementary material such as raw data, code, or additional explanations.

This structure may vary depending on the field of study, but these elements are commonly found in most bachelor theses. They are compulsory for the _ISC Bachelor thesis_.

= Introduction
Have fun #todo[writing your thesis!] and good luck with it !

#figure(
  image("figs/pixelize.png", height: 4cm),
  caption: [Grace Hopper]
) <fig_engineer>

#lorem(1000)

= Methodology
#lorem(800)

#lorem(800)

= Results 
#lorem(950)

= Discussion
#lorem(1000)

= Conclusion
#lorem(1256)

//#bibliography("bibliography.bib", full: true, style: "ieee", title)
#pagebreak()
#the-bibliography(bib-file: "bibliography.bib", full: true, style: "ieee")

//////////////
// Appendices
////////////// 
#cleardoublepage()
#appendix-page()
#pagebreak()

// Table of acronyms, NOT COMPULSORY
#print-index(
  title: heavy-title(i18n(doc_language, "acronym-table-title"), mult:1, top:1em, bottom: 1em),
  sorted: "up",
  delimiter: " : ",
  row-gutter: 0.7em,
  outlined: false,  
)

#pagebreak()

// Table of listings 
#table-of-figures()

// Code inclusion
#pagebreak()
#code-samples()

#let code_sample = read("code/sample.scala")

#figure( 
    code()[
      #raw(code_sample, lang: "scala")
    ],
  caption: "Code included from the file example.scala"
)

#figure( 
    code()[
      #raw(read("code/sort.py"), lang: "python")
    ],
  caption: "Second code included from the file example.scala"
)

#figure( 
    code()[
      #raw(code_sample, lang: "scala")
    ],
  caption: "Second code included from the file example.scala"
)


// This is the end, folks!