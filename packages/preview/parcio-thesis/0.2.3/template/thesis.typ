#import "@preview/parcio-thesis:0.2.3": *

/* 
  Your ParCIO thesis template has these possible options (you may not need all of them):
  
  - title: your thesis title.
  - author: your full name and e-mail address as (name: "", mail: "").
  - abstract: your thesis abstract.
  - thesis-type: your thesis type, such as "Bachelor", "Master" or "PhD".
  - reviewers: your thesis reviewers, specify in order "first-reviewer", "second-reviewer" and (if needed) "supervisor".
  - date: your thesis deadline (default: datetime.today()).
  - heading-numbering: how to number your headings (default: "1.1.")
  - lang: the text language for smartquotes & hyphenation (specify as ISO 639-1/2/3 code, default: "en").
  - header-logo: your faculty and/or organization banner (default: none).
  - translations: a file path to a possible translation scheme.
*/
#show: parcio.with(
  title: "Title", 
  author: (
    name: "Author",
    mail: "author@ovgu.de"
  ),
  abstract: include "chapters/abstract.typ",
  reviewers: ("Prof. Dr. Musterfrau", "Prof. Dr. Mustermann", "Dr. Evil"),
  header-logo: image("images/ovgu-fin.svg", width: 66%),
)

#show: roman-numbering.with(reset: false)
#outline(depth: 3)

/* ---- Main matter of your thesis ---- */

#empty-page

// Set arabic numbering and alternate page number position.
#show: arabic-numbering

#include "chapters/introduction/intro.typ"

#include "chapters/background/background.typ"

#include "chapters/eval/eval.typ"

#include "chapters/conclusion/conc.typ"

/* ---- Back matter of your thesis ---- */

#empty-page

#bibliography("bibliography/refs.bib", style: "bibliography/apalike.csl")

#empty-page

#include "appendix.typ"

#empty-page

#include "legal.typ"
