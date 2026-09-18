#import "../lib.typ": *

#show: gibz-script.with(
  moduleNumber: "000",
  moduleTitle: "Modultitel",
  documentTitle: "Skript",
  language: "de",
)

= Intro

Hello world!

= IPA-Kriterium Vorschau

#gibz-ipa-criterion(
  "Doc01",
  "Gliederung",
  "Wie ist die Dokumentation gegliedert? Gibt es eine klar unterscheidbare Trennung von Inhalt und Struktur?",
  [
    + Es ist klar, dass es keine Unterschiede gibt. Es soll auch deutlich unterscheidbar vom Standard-Inhalt sein.
    + ebenso...
    + schliesslich solle alles einfach gut sein :-)
  ],
  [
    Die Dokumentation ist mehrheitlich klar und gut gegliedert, mit kleinen Lücken.
  ],
  [
    Die Gliederung ist teilweise vorhanden, aber wichtige Inhalte fehlen oder sind unklar.
  ],
  [
    Keine erkennbare Struktur oder Dokumentation.
  ],
  active-level: 3,
  feedback: [
    Gute Grundstruktur. Der Abschnitt zu Quellen und Reflexion sollte noch präziser gegliedert werden.
  ],
)

== Listen und Aufzählungen
#lorem(40)

+ #lorem(4)
+ #lorem(4) #lorem(21)
+ #lorem(6)
+ #lorem(26)
+ #lorem(8)

#lorem(40)

- #lorem(4)
- #lorem(21)

- #lorem(6)
- #lorem(26) 
- #lorem(8)

== Tabellen Vorschau

#table(
  columns: (2fr, 1fr, 1fr),

  table.header(
    [Kriterium],
    [Wert],
    [Status],
  ),

  [Layout], [0.2.0], [OK],
  [Listen/Enum], [kein Blocksatz], [OK],
  [IPA-Kriterium], [aktiv], [OK],
)

#table(
  columns: (1fr, 1fr, 1fr, 1fr),
  align: (left + horizon, right + horizon, right + horizon, center + horizon),

  table.header(
    [Position],
    [Plan],
    [Ist],
    [Δ],
  ),

  [Entwicklung], [24 h], [22 h], [−2 h],
  [Testing], [12 h], [13 h], [+1 h],
  [Dokumentation], [8 h], [9 h], [+1 h],
)

= Inline Code

A variable always has three parts: a *data type* (for example `bool`,
`int`), a *name*, and, optionally, a *starting value*. The data type decides
which values are even allowed — more on that in the next chapter.