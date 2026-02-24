#import "@preview/hei-synd-thesis:0.1.0": *
#import "/metadata.typ": *
#pagebreak()
#heading(numbering:none)[#i18n("abstract-title", lang:option.lang)] <sec:abstract>

#option-style(type:option.type)[
  The abstract serves as a concise summary of your entire thesis, encapsulating key elements on a single page such as:
  - General background information
  - Objective(s)
  - Approach and method
  - Conclusions
]

#lorem(50)

#lorem(50)

#lorem(50)

#v(2em)
#if doc.at("keywords", default:none) != none {[

  _*#i18n("keywords", lang: option.lang)*_:

  #enumerating-items(
    items: doc.keywords,
    italic: true
  )
]}
