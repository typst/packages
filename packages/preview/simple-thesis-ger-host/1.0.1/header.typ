// ===== Imports (package responsibility)
#import "@preview/glossarium:0.5.10":
  make-glossary,
  register-glossary,
  print-glossary,
  gls,
  glspl

// ===== Public entry function

#let thesis(entry-list, body) = {
  // Language & layout
  set text(lang: "de")
  set page(paper: "a4")
  set par(justify: true)
  set page(margin: (top: 2.5cm, bottom: 2.5cm, left: 3cm, right: 2.5cm))
  
  // Title page margin reset will be done by template
  body
}

// import "header" everything what is defined globally, except glossarium because its not working than (print-glossary funktion is missing)

