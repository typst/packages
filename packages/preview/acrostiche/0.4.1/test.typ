#import "@preview/acrostiche:0.4.1": *

#init-acronyms((
  "PFT": ("Package For Typst","Packages For Typst"),
  "AJT": ("Amicale des Joyeux Typistes"),
  "ada": (short:[#text(fill:aqua)[ADA]], short-pl:"ADAs", long:"Advanced Definition Acronym", long-pl:"Advanced Definions Acronyms"),
  "TEA": ("The Extra Acronym",),
  "TUA": ("The Unused Acronym",),
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

== Acronym with Advanced Definitions

First use of #acr("ada") and second use of #acr("ada").\
#ref("First use of Advanced Definition Acronym (ADA) and second use of (ADA).")

//First use of iplural #acrpl("ada") and second use of plural #acrpl("ada").\
//#ref("First use of Advanced Definitions Acronyms (ADAs) and second use of (ADAs).")


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

