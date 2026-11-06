// One prototype block per page, so the comparison page can load each on its
// own. Compiled by build.sh into candidates/block-{n}.svg — the same path a
// real document takes, Typst font measurement included.
#import "../../../lib.typ": nepo, set-blockst

#set page(width: auto, height: auto, margin: 4pt, fill: none)
#set text(font: "Helvetica Neue", fallback: true)

#let blocks = (
  "Start",
  "Zeige Text \"Hallo\"",
  "Schalte RGB LED an (#ff0000)",
  "Taste A gedrückt?",
  "Wiederhole unendlich oft\n  Zeige Text \"Hallo\"\nEnde",
  "Zeige Bild (.#.#.|.#.#.|.....|#...#|.###.)",
  "Warte ms 1 + 2",
  "Warte bis Taste A gedrückt? und wahr",
  "gib geschüttelt Lage",
  "Spiele Viertelnote C4",
  "Zeige Bild Herz",
  "Start\n  Variable Punkte : Zahl ← 0",
  "Schreibe Punkte 0",
  "erhöhe Punkte um 1",
  "Liste : Zahl ← 1 2 3",
  "von der Liste Werte nimm #tes 2",
)

#for (index, source) in blocks.enumerate() {
  if index > 0 { pagebreak() }
  nepo(source)
}
