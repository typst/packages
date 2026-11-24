// MakeCode blocks: the micro:bit editor's look, and the Calliope mini colours.
//
// The same notation as scratch(). Block texts are the editors' own, in
// German (default) or English; `ende` closes a C-block, `ansonsten` opens
// the else branch. Unknown labels are drawn as written with the category
// from a `::kategorie` suffix.
#import "@preview/blockst:0.4.0": makecode, raw-makecode

#set page(width: auto, height: auto, margin: 4mm, fill: none)
#show: raw-makecode(language: "en")

#let programm = "
beim Start
  zeige Symbol [Herz v]
  setze [zähler v] auf (0)
ende
wenn Knopf [A v] geklickt
  zeige LEDs [#...#|.#.#.|..#..|.#.#.|#...#]
  spiele (Melodie [C D E F - - - -] mit Tempo (120) (bpm)) [bis zum Ende v]
  ändere [zähler v] um (1)
  zeige Zahl (zähler)
  wenn <(zähler) > (9)> dann
    zeige Text [Fertig!]
    setze [zähler v] auf (0)
  ansonsten
    pausiere (ms) (100)
  ende
ende
"

#grid(
  columns: 3,
  column-gutter: 7mm,
  row-gutter: 2mm,
  align: top + left,
  text(size: 8pt, fill: gray)[makecode (micro:bit)], text(size: 8pt, fill: gray)[makecode-calliope], text(size: 8pt, fill: gray)[makecode · en],

  makecode(programm),
  makecode(programm, profile: "makecode-calliope"),
  [
    ```microbit
    forever
      show number (((1) + (2)) * (3))
      if <not <button [A v] is pressed>> then
        show icon [Heart v]
      end
    end
    ```
  ],
)
