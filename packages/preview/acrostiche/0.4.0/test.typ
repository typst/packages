#import "@preview/acrostiche:0.4.0": *

#init-acronyms((
  "PFT": ("Package For Typst","Packages For Typst"),
  "AJT": ("Amicale des Joyeux Typistes"),
  "TEA": ("The Extra Acronym",),
)) 

#let ref(str) = [#text(fill:green)[#str]]

== Acronym with Two Definitions.

First use of #acr("PFT") and second use of #acr("PFT").\
#ref("First use of Package For Typst (PFT) and second use of PFT.")

Reset acronyms. #reset-acronym("PFT")

First use of plural #acrpl("PFT") and second use of plural #acrpl("PFT").\
#ref("First use of plural Packages For Typst (PFTs) and second use of plural PFTs.")

Reset acronyms. #racr("PFT")

Full definition of #acrfull("PFT") and full plural definition of #acrfullpl("PFT").
Full definition of #acrf("PFT") and full plural definition of #acrfpl("PFT").
#ref("Full definition of Package For Typst (PFT) and full plural definition of Packages For Typst (PFTs).")

== Acronym with a Single Definition.

First use of #acr("AJT") and second use of #acr("AJT").\
#ref("First use of Amicale des Joyeux Typistes (AJT) and second use of AJT.")


Reset acronyms. #racr("AJT")

Full definition of #acrfull("AJT").\
Full definition of #acrf("AJT").\
#ref("Full definition of Amicale des Joyeux Typistes (AJT)")

== Reset All Acronyms

Use #acr("PFT") and #acr("AJT").\
Reset.#reset-all-acronyms()\
Use again #acr("PFT") and #acr("AJT").

#ref("
Use Package For Typst (PFT) and Amicale des Joyeux Typistes (AJT).
Reset.
Use again Package For Typst (PFT) and Amicale des Joyeux Typistes (AJT).
")

== Print Index Variations

#print-index()

#print-index(title:"Sorted Empty",sorted:"")
#print-index(title:"Sorted up",   sorted:"up")
#print-index(title:"Sorted down", sorted:"down")

#print-index(title:"Used only up", sorted: "up", used-only:true)
#print-index(title:"Used only down", sorted: "down", used-only:true)

