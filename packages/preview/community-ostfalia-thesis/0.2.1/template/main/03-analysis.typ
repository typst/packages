#import "/metadata.typ": *
#pagebreak()
= #i18n("analysis-title", lang:option.lang) <sec:analysis>

#option-style(type:option.type)[
  In the analysis part a so called ”State of the Art” research is done. It describes the knowledge about the studied matter through the analysis of similar or related published work. It provides a comprehensive overview of what was done, what has been done in the field and what should be further investigated.

  A State of the Art is done in multiple phases:

  + Problem formulation (Research questions)
  + Literature search
  + Literature evaluation
  + Analysis and interpretation
  + Presentation

  Good sources for a literature search depend on your subject matter. For engineering hereafter a incomplete list:
  - #link("https://ieeexplore.ieee.org/")[IEEE Xplore]
  - #link("https://www.sciencedirect.com")[Science Direct]
  - #link("https://scholar.google.com")[Google Scholar]
  - #link("https://link.springer.com")[Springer Link]
  - #link("https://www.proquest.com")[ProQuest]
  - #link("https://www.jstor.org")[JSTOR]
  - #link("https://books.google.com")[Google Books]
]

#lorem(50)

#add-chapter(
  after: <sec:analysis>,
  before: <sec:design>,
  minitoc-title: i18n("toc-title", lang: option.lang)
)[
  #pagebreak()
  == Section 1

  #lorem(50)

  == Section 2

  #lorem(50)

  == Conclusion

  #lorem(50)
]
