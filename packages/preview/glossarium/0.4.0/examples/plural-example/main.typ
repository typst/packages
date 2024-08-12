#import "../../glossarium.typ": make-glossary, print-glossary, gls, glspl
// Replace the local import with a import to the preview namespace. 
// If you don't know what that mean, please go read typst documentation on how to import packages at https://typst.app/docs/packages/.

#show: make-glossary

#set page(paper: "a5")

#show link: set text(fill: blue.darken(60%))

I like to eat #glspl("potato"). Yes I still like to eat #glspl("potato").

But I don't like to eat #glspl("dm").

...

I thought about it and now I like to eat #glspl("dm").

I love #glspl("cpu"). I ate a #gls("cpu") once. 

Would you eat a #gls("buffer") ? I heard #glspl("buffer") are tasty.

= Glossary
#print-glossary(
  ((
    key: "potato",
    short: "potato",
    // "plural" will be used when "short" should be pluralized
    plural: "potatoes",
    desc: [#lorem(10)],
  ), (
    key: "dm",
    short: "DM",
    long: "diagonal matrix",
    // "longplural" will be used when "long" should be pluralized
    longplural: "diagonal matrices",
    desc: "Probably some math stuff idk",
  ), (
    key: "cpu",
    short: "CPU",
    long: "Central Processing Unit",
    desc: [#lorem(10)],
  ), (key: "buffer", short: "buffer", desc: "A place to store stuff"),),
  // show all term even if they are not referenced, default to true
  show-all: true,
  // disable the back ref at the end of the descriptions
  disable-back-references: true,
)