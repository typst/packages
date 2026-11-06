#import "template.typ": *
#show: mantys

// ----------------------------
// Manual for DECKZ package
= How to use DECKZ
<sec:guide>
#include "01.manual.typ"


// ----------------------------
// Complete documentation for DECKZ functions and features
= Documentation
<sec:documentation>
#include "02.documentation.typ"

// ----------------------------
// Examples
= Examples
<sec:examples>
#include "03.examples.typ"

// ----------------------------
// Additional information
#heading(numbering: none)[Credits]

This package is created by #link("https://github.com/micheledusi")[*Michele Dusi*] and is licensed under the #link("https://www.gnu.org/licenses/gpl-3.0.en.html")[GNU General Public License v3.0].

The *name* is inspired by Typst's drawing package #universe("cetz"): it mirrors its sound while hinting at its own purpose: rendering card decks.

All *fonts* used in this package are licensed under the #link("https://openfontlicense.org")[SIL Open Font License, Version 1.1] 
(#link("https://fonts.google.com/specimen/Oldenburg")[_Oldenburg_], #link("https://fonts.google.com/specimen/Arvo")[_Arvo_])
or the #link("http://www.apache.org/licenses/")[Apache License, Version 2.0]
(#link("https://fonts.google.com/specimen/Roboto+Slab")[_Roboto Slab_]).

The *card designs* are inspired by the standard playing cards, with suit symbols taken from the #link("https://typst.app/docs/img/reference/symbols/emoji/")[emoji library of Typst].

This project owes a lot to the creators of these *Typst packages*, whose work made DECKZ possible:
- #universe("cetz"), for handling graphics and for the name inspiration.
- #universe("suiji"), for random number generation.
- #universe("linguify"), for localization.
- #universe("mantys"), #universe("tidy"), and #universe("codly"), for documentation.
- #universe("octique") and #universe("showybox"), for documentation styling.

Special thanks to everyone involved in the development of the #link("https://typst.app/about/")[Typst] language and engine, whose efforts made the entire ecosystem possible.

#heading(numbering: none, level: 2)[Contributing]
Found a bug, have an idea, or want to contribute?
Feel free to open an *issue* or *pull request* on the _GitHub_ repository (#github("micheledusi/Deckz")).

Made something cool with Deckz? Let me know — I'd love to feature your work!