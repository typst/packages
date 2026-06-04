//
// Description: Main document to stitch everything together
//
#import "/metadata.typ": *
#import "/tail/bibliography.typ": *
#import "/tail/glossary.typ": *
#show:make-glossary
#register-glossary(entry-list)

//-------------------------------------
// Template config
//
#show: thesis.with(
  option: option,
  doc: doc,
  data-page: data-page,
  summary-page: summary-page,
  professor: professor,
  expert: expert,
  school: school,
  date: date,
  tableof: tableof,
  logos: logos,
)

//-------------------------------------
// Content
//
#include("/main/00-acknowledgements.typ")
#include "/main/01-abstract.typ"
#include "/main/02-introduction.typ"
#include "/main/03-analysis.typ"
#include "/main/04-design.typ"
#include "/main/05-implementation.typ"
#include "/main/06-validation.typ"
#include "/main/07-conclusion.typ"

//-------------------------------------
// Glossary
//
#make_glossary(gloss:gloss, title:i18n("gloss-title", lang: option.lang))

//-------------------------------------
// Bibliography
//
#make_bibliography(bib:bib, title:i18n("bib-title", lang: option.lang))

//-------------------------------------
// Appendix
//
#if appendix == true {[
  #counter(heading).update(0)
  #set heading(numbering:"A")
  #include "/tail/a-appendix.typ"
]}
