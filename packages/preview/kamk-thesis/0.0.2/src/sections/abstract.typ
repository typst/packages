#import "../core/utils.typ": format-authors

#let render-abstract(
  lang-dict,
  authors: (),
  language: "fi",
  title: "",
  degree: "",
  keywords: (),
  body
) = {
  // The abstract page body text size is 10pt
  set text(size: 10pt)
  
  // Heading is 11pt, bold
  show heading: set text(size: 11pt, weight: "bold")
  show heading: set block(below: 1.5em)

  // Not outlined (not in Table of Contents)
  heading(level: 1, outlined: false, strong(lang-dict.abstract))

  // Metadata block: Author, Title, Degree, Keywords
    block[
      *#lang-dict.author*: #format-authors(authors, language: language) \
      *#lang-dict.title*: #title \
      *#lang-dict.degree*: #degree \
      *#lang-dict.keywords*: #keywords.join(", ")
    ]
  
  // A gap between the metadata and the actual abstract text
  v(1.5em)
  
  // Abstract text block.
  body
}
