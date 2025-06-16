#import "../../glossarium.typ": make-glossary, print-glossary, gls, glspl
// Replace the local import with a import to the preview namespace. 
// If you don't know what that mean, please go read typst documentation on how to import packages at https://typst.app/docs/packages/.

#show: make-glossary

#set page(numbering: "1", paper: "a5")

//I recommend setting a show rule for the links to that your reader understand that they can click on the references to go to the term in the glossary.
#show link: set text(fill: blue.darken(60%))

= Groups example

Reference to @ntc \
Reference to @bor

#pagebreak()
= Glossary with group enabled
#print-glossary(
  (
    (
      key: "ntc",
      short: "NTC",
      long: "Linear Transform Coding",
      desc: [This is the opposite of @ltc.],
      group: "Nonlinear",
    ),
    (
      key: "ltc",
      short: "LTC",
      long: "This is the opposite of @ltc.",
      desc: [    Transform Coding constraint to linear transforms.],
      group: "Linear",
    ),
    (
      key: "bor",
      short: "DEF",
      long: "Default",
      desc: lorem(25),
    ),
    (
      key: "bor2",
      short: "DEF2",
      long: "Default2",
      desc: lorem(25),
      group: "", // Please note that an empty group has the same effect as no group
    ),
    
  ),
  show-all: true,
  enable-group-pagebreak: true, // break page for each group
)
