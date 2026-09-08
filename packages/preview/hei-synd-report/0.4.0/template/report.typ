#import "/metadata.typ": *
#import "/tail/bibliography.typ": *
#import "/tail/glossary.typ": *
#show:make-glossary
#register-glossary(entry-list)

//-------------------------------------
// Template config
//
#show: report.with(
  option: option,
  doc: doc,
  date: date,
  display: display,
  tableof: tableof,
  fonts: fonts,
)

//-------------------------------------
// Content
//
#include "/main/01-intro.typ"
#include "/main/02-specification.typ"
#include "/main/03-design.typ"
#include "/main/04-implementation.typ"
#include "/main/05-validation.typ"
#include "/main/06-conclusion.typ"

//#heading(numbering:none, outlined: false)[] <sec:end>

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
