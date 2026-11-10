// =====================================================
// NOTEWORTHY - Package entrypoint
// =====================================================
// A user project needs just two things, both importing this package:
//
//   main.typ    - #import "@preview/noteworks:0.2.0": *
//                 #show: noteworthy.with(title: ..., theme: ...)
//                 #cover() / #preface[..] / #toc()
//                 #chapter(..) / #page(..)[#include "content/..."]
//   content/    - one file per page, each starting with
//                 #import "@preview/noteworks:0.2.0": *

#import "src/templater.typ": *
