#import "meta.typ" as meta
#import "@preview/modern-whs-assignment:0.2.1": *

#show: whs-assignment.with(
  meta.title,
  meta.author,
  meta.submission-date,
  meta.keywords,
  meta.course,
  meta.lecturer,
  meta.bibliography,
)

#include "chapters/01_introduction.typ"
