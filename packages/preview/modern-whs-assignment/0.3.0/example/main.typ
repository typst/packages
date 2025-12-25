#import "meta.typ" as meta
#import "acronyms.typ" as acronyms
#import "@preview/modern-whs-assignment:0.2.1": *

#show: whs-assignment.with(
  meta.title,
  meta.author,
  meta.submission-date,
  meta.keywords,
  meta.course,
  meta.lecturer,
  meta.bibliography, // none to disable
  acronyms.acronyms, // none to disable
)

#include "chapters/01_introduction.typ"
