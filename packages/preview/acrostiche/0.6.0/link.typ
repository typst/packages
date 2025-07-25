#import "@preview/acrostiche:0.0.0": *

#init-acronyms((
  "STA": "String Type Acronym",
  "PFT": ("Package For Typst","Packages For Typst"),
  "AJT": ("Amicale des Joyeux Typistes"),
  "ada": (short:[#text(fill:aqua)[ADA]], short-pl:"ADAs", long:"Advanced Definition Acronym", long-pl:"Advanced Definitions Acronyms"),
  "TEA": ("The Extra Acronym",),
  "TUA": ("The Unused Acronym",),
)) 

#let ref(str) = [#text(fill:green)[#str]]

== Acronym with Two Definitions.


First use of #acr("PFT") and second use of #acr("PFT").\
#ref("First use of Package For Typst (PFT) and second use of PFT.")


#pagebreak()

== Print Index Variations
Acronyms can be clicked and link to the first index table that has the default flag `clickable: true`.

#print-index(title:"Clickable acronyms", clickable: false)

