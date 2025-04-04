/*
  Glossarium is the default glossary package of this template (you can use another if you want). If you have any doubts related to Glossarium after reading the quick guide, you can check its documentation at:
  https://github.com/typst-community/glossarium
*/

#import "@preview/glossarium:0.5.4": make-glossary, register-glossary, print-glossary

#show: make-glossary

#let main-glossary = (
  (
    key: "potato",
    short: "potato",
    plural: "potatoes",
    description: "An edible tuber"
  ),
)

#let abbreviations-glossary = (
  (
    key: "IST",
    short: "IST",
    long: "Instituto Superior Técnico"
  ),

  (
    key: "DM",
    short: "DM",
    long: "Diagonal Matrix",
    longplural: "Diagonal Matrices"
  ),
)

#let symbols-glossary = (
  (
    key: "mu_0",
    short: $mu_0$,
    description: "Vacuum magnetic permeability"
  ),
)

= Glossary
#register-glossary(main-glossary)
#print-glossary(main-glossary)

== Abbreviations
#register-glossary(abbreviations-glossary)
#print-glossary(abbreviations-glossary)

== Symbols
#register-glossary(symbols-glossary)
#print-glossary(symbols-glossary)
