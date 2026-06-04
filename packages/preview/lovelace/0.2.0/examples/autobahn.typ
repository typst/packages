#import "../lib.typ": *
#set page(width: 40em, height: auto, margin: 1em)

#show: setup-lovelace.with(line-number-supplement: "Zeile")
#let pseudocode = pseudocode.with(indentation-guide-stroke: .5pt)
#let algorithm = algorithm.with(supplement: "Algorithmus")

#algorithm(
  caption: [Spurwechsel nach links auf der Autobahn],
  pseudocode(
    <line:blinken>,
    [Links blinken],
    [In den linken Außenspiegel schauen],
    [Schulterblick],
    [*wenn* niemand nähert sich auf der linken Spur, *dann*], ind,
      [Spur wechseln], ded,
    [Blinker aus],
  )
)

Der Schritt in @line:blinken stellt offenbar für viele Verkehrsteilnehmer eine
Herausforderung dar.
