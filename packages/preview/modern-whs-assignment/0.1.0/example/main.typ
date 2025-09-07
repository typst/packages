#import "meta.typ" as meta
#import "@preview/modern-whs-assignment:0.1.0": *

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
