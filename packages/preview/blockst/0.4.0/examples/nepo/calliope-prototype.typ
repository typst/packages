// NEPO prototype — the six blocks the evaluation is built on.
//
// Imported relatively rather than as `@preview/blockst:0.4.0`, because NEPO is
// not part of a released version yet.
#import "@preview/blockst:0.4.0": nepo, set-blockst

#set page(width: auto, height: auto, margin: 12pt, fill: white)
#set text(font: "Helvetica Neue", fallback: true)

#set-blockst(font: "Helvetica Neue")

#let caption(body) = text(size: 8pt, fill: rgb("#555"), body)

#grid(
  columns: 1,
  row-gutter: 14pt,

  caption[Vollständiges Programm — Start, Aktion, Kontrolle, Spezialfeld],
  nepo("
Start
  Zeige Text \"Hallo\"
  Schalte RGB LED an (#ff0000)
  Wiederhole unendlich oft
    Zeige Bild (.#.#.|.#.#.|.....|#...#|.###.)
  Ende
"),

  caption[Einzelblöcke],
  nepo("Start"),
  nepo("Zeige Text \"Hallo\""),
  nepo("Schalte RGB LED an (#ff0000)"),
  nepo("Taste A gedrückt?"),
  nepo("Warte ms 1 + 2"),
  nepo("Warte bis Taste A gedrückt? und wahr"),
  nepo("gib geschüttelt Lage"),
  nepo("Spiele Viertelnote C4"),
  nepo("Zeige Bild Herz"),
  nepo("Kommentar \"Notiz\""),
  nepo("
Wiederhole unendlich oft
  Zeige Text \"Hallo\"
Ende
"),
  nepo("Zeige Bild (.#.#.|.#.#.|.....|#...#|.###.)"),

  caption[Leere, typisierte Anschlüsse — die Farbe nennt den erwarteten Datentyp],
  nepo("Zeige Text"),
  nepo("Schalte RGB LED an"),
  nepo("Zeige Bild"),
)
