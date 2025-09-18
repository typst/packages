#import "@local/gallus-hsg:1.0.0": *
#import "./metadata.typ": *

#set document(title: title, author: author)

#show: thesis.with(
  language: language,
  title: title,
  subtitle: subtitle,
  type: type,
  professor: professor,
  author: author,
  matriculation-number: matriculation-number,
  submission-date: submission-date,
  abstract: include "./content/abstract.typ",
  acknowledgement: include "./content/acknowledgement.typ",
  writing-aids-directory: include "./content/writing-aids-directory.typ",
  appendix: include "./content/appendix.typ",
  bibliography-as-bytes: read("./bibliography.bib", encoding: none)
)

#include "./content/01-content.typ"
#include "./content/02-content.typ"
