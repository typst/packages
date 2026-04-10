#import "@preview/beautiful-abs:0.1.0": *

= General Usage

This is an example usage of #ie or #eg. It places half a space in between the parts of the abbreviation.

#text(
  "It also works with italic styles: " + ie + " ... ",
  style: "italic"
)
#text(
  "or bold texts: " + eg,
  weight: "bold"
)

= Existing Abbreviations

#table(
  columns: (1fr, 2fr, 1fr, 1fr),
  table.header([*Abbreviation*], [*Long Form*], [*Function*], [*Language*]),
  [#eg], [exempli gratia], [\#eg], [Latin],
  [#etal], [et alia], [\#etal], [Latin],
  [#ie], [id est], [\#ie], [Latin],
  [#perse], [per se], [\#perse], [Latin],
  [#qed], [quod erat demonstrandum], [\#qed], [Latin],
  [#aka], [also known as], [\#aka], [English],
  [#st], [such that], [\#st], [English],
  [#dh], [das heißt], [\#dh], [German],
  [#ua], [unter anderem], [\#ua], [German],
  [#zb], [zum Beispiel], [\#zb], [German],
  [#pex], [per exemple], [\#pex], [French]
)

= Custom Abbreviations

In case there is more, you can use:
#customab(("a.", "b.", "c."))
