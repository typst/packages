#import "@preview/glossarium:0.5.0": make-glossary, register-glossary, print-glossary

#show: make-glossary

/*
Add your glossary terms below!

  - They will always be shown alphabetically;

  - If you don't specify a plural/longplural form, #gspl() will just add an s in case you call it;

  - Terms with a long form will be shown just as their short form from the second time on.

For any doubts, check the page of the imported package:
https://github.com/typst-community/glossarium
*/

#let main-glossary = (

  // Terms you add in glossaries need to be referenced to show up, unless you uncomment this line:
  // show-all: true,

  (
    (
      key: "potato",
      short: "potato",
      plural: "potatoes",
      description: "An edible tuber"
    ),
  )
)

#let acronyms-glossary = (
  (
    (
      key: "ist",
      short: "IST",
      long: "Instituto Superior Técnico"
    ),

    (
      key: "dm",
      short: "DM",
      long: "Diagonal Matrix",
      longplural: "diagonal matrices"
    ),
  )
)

#let symbols-glossary = (
  (
    (
      key: "mu_0",
      short: $mu_0$,
      description: "Standard magnetic permeability"
    ),
  )
)

= Glossary
#register-glossary(main-glossary)
#print-glossary(main-glossary)

== Acronyms
#register-glossary(acronyms-glossary)
#print-glossary(acronyms-glossary)

== Symbols
#register-glossary(symbols-glossary)
#print-glossary(symbols-glossary)
