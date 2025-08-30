#import "@preview/acrostiche:0.0.0": *

#init-acronyms((
  "STA": "String Type Acronym",
  "PFT": ("Package For Typst","Packages For Typst"),
  "AJT": ("Amicale des Joyeux Typistes"),
  "ada": (short:[#text(fill:aqua)[ADA]], short-pl:"ADAs", long:"Advanced Definition Acronym", long-pl:"Advanced Definitions Acronyms"),
  "TEA": ("The Extra Acronym",),
  "TUA": ("The Unused Acronym",),
  "NCA": ("non-capitalized acronym")
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

== Plural with string only definition
First use of #acrpl("STA") and second use of #acrpl("STA").\
#ref("First use of String Type Acronyms (STAs) and second use of STAs.")

== Acronym with Advanced Definitions

First use of #acr("ada") and second use of #acr("ada").\
#ref("First use of Advanced Definition Acronym (ADA) and second use of ADA.")



Reset acronyms. #racr("AJT")

Full definition of #acrfull("AJT").\
Full definition of #acrf("AJT").\
#ref("Full definition of Amicale des Joyeux Typistes (AJT)")

== Capitalized Definitions
#reset-all-acronyms()
#acr("NCA")

#reset-all-acronyms()
#acrcap("NCA")


== Reset All Acronyms

Use #acr("PFT") and #acr("AJT").\
Reset.#reset-all-acronyms()\
Use again #acr("PFT") and #acr("AJT").

#ref("
Use Package For Typst (PFT) and Amicale des Joyeux Typistes (AJT).
Reset.
Use again Package For Typst (PFT) and Amicale des Joyeux Typistes (AJT).
")

== Shortcuts and Functions Names from LaTeX
#reset-all-acronyms()

First use of #ac("PFT") and second use of #ac("PFT").\
#ref("First use of Package For Typst (PFT) and second use of PFT.")

Full definition singular #acf("PFT") and plural #acfp("ada")\
#ref("Full definition singular Package For Typst (PFT) and plural Advanced Definitions Acronyms (ADAs)")

Display short singular #acs("ada") and short plural #acsp("ada")\
#ref("Display short singular ADA and short plural ADAs")

Display plural with shortcut: #acp("ada") and #acp("ada").\
#ref("Display plural with shortcut: Advanced Definitions Acronyms (ADAs) and ADAs.")

Display long shortcut: #acl("ada").\
#ref("Display long shortcut: Advanced Definition Acronym.")

Display long plural shortcut: #aclp("ada").\
#ref("Display long plural shortcut: Advanced Definitions Acronyms.")

== Print Index Variations
Acronyms can be clicked and link to the first index table that has the default flag `clickable: true`.

#print-index(title: "Default index (clickeable deactivated)", clickable: false)
#print-index(title:"Clickable acronyms", clickable: true)

#print-index(title:"Sorted Empty",sorted:"")
#print-index(title:"Sorted up",   sorted:"up")
#print-index(title:"Sorted down", sorted:"down")

#print-index(title:"Used only up", sorted: "up", used-only:true)
#print-index(title:"Used only down", sorted: "down", used-only:true)

#print-index(title:"Column ratio 0.5",sorted:"", column-ratio:0.5)
#print-index(title:"Column ratio 0.75",sorted:"", column-ratio:0.75)
#print-index(title:"Column ratio 1",sorted:"", column-ratio:1)
#print-index(title:"Column ratio 2",sorted:"", column-ratio:2)
