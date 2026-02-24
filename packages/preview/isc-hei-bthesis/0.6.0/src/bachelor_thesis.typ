#import "@preview/isc-hei-bthesis:0.6.0" : *

#let doc_language = "en" // Valid values are en, fr

#show: project.with( 
  title: "Life, the Universe, and Everything", // Your thesis title
  subtitle: "An exploration of the intersection between computer science and engineering, focusing on their impact on modern technological advancements.", // Optional, use none if not needed
  authors: "James Gosling", 
  language: doc_language, // must be defined globally, see above
  
  thesis-supervisor: "Prof. Dr John von Neumann", 
  thesis-co-supervisor: "Lady Ada Lovelace", // Optional, use none if not needed
  thesis-expert: "Dr Grace Hopper", // Optional, use none if not needed
  thesis-id: "ISC-ID-25-1", // Your thesis ID (from the official project description)
  project-repos: "https://isc.hevs.ch", // Your project git repository.

  school: "Haute École d'Ingénierie de Sion", 
  programme: "Informatique et Systèmes de communication (ISC)",

  // Some keywords related to your thesis
  keywords: ("engineering", "data", "machine learning", "meteorology"),
  major : "Data engineering", // "Software engineering", "Embedded systems", "Security", "something else"

  date: datetime(year: 2025, month: 6, day: 30), // or datetime.today() 

  is-thesis: true,
  split-chapters: true,
  revision: "1.0", // Or for instance "1.0", for the version of your thesis  
  code-theme: "bluloco-light", // See directory themes/ for available themes
) 

// // If using acronyms 
#import "@preview/acrostiche:0.6.0": *     
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

Writing a report is an exercise that involves both *content* and *form*. In this document, we aim to simplify the formatting aspect without making any assumptions about the content, specifically in the context of the ISC degree programme#footnote[Here is how to add a footnote https://isc.hevs.ch].

== The content of a thesis

The general structure of a bachelor thesis typically includes the following sections:

1. *Abstract*: A concise summary of the thesis, including the research question, methodology, results, and conclusions.
2. *Résumé*: A summary of the thesis in French.
3. *Acknowledgements*: [Optional] A section to thank those who supported your work.
4. *Table of Contents*: An organized list of chapters and sections.
5. *Introduction*: Presents the background/context, motivation, objectives, and scope and plan of the thesis.
6. *State of the Art / Literature Review*: Reviews existing research and situates the thesis within the academic context, if relevant to your work.
7. *Development and Methodology*: Describes the methods, materials, and procedures used in the research/thesis.
8. *Results*: Presents the findings of the research, often with tables, figures, and analysis.
9. *Discussion*: Interprets the results, discusses implications, and relates findings to the research question.
10. *Conclusion*: Summarizes the main findings and contributions, and suggests future work.
11. *References / Bibliography*: Lists all sources cited in the thesis.
12. *Appendices*: (Optional) Contains supplementary material such as raw data, code, or additional explanations.

This structure may vary depending on the field of study, but these elements are commonly found in most bachelor theses. They are recommended for the _ISC Bachelor thesis_ and should be adapted to the specific requirements of your thesis (e.g., if you have a state of the art section or not).

You can also change the order or the names of the sections, for instance, if you want to put the state of the art before the introduction, or if you want to add a section on methodology before the results.

== Academic titles
Please note that the academic titles of your supervisors and experts are important.

They should be included on the cover page, and you should use the correct title when addressing them in the acknowledgements section. For instance, a professor should be addressed as "Prof. [Name]", while a doctor should be addressed as "Dr [Name]" (*without a colon!*). A professor who is also a doctor should be addressed as "Prof. Dr [Name]".

If you are unsure about the title of your supervisor, co-supervisor, or expert, you can ask them directly or check their profile on the university website.

== Compiling the thesis

If you compile your thesis using the `typst` command line tool, or by using the `typst` extension in Visual Studio Code, please not that you must install the fonts used in this template. You can do so by running the following command in your terminal:

```bash
./fonts/install_fonts.sh
```

= Introduction
Have fun #todo[writing your thesis!] and good luck with it !

#figure(
  image("figs/pixelize.png", height: 4cm),
  caption: [Grace Hopper]
) <fig_engineer>

#lorem-pars(600)

= Development and Methodology
#lorem-pars(1500)

= Results and Discussion
#lorem-pars(950)

#lorem-pars(950)

#lorem-pars(950)

= Conclusion
#lorem-pars(1200)

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