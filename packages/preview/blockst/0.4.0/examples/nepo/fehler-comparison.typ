// Visual regression sheet for the six “Fehler” examples from the lesson.
//
// It deliberately reproduces the source logic as shown, including its
// intentional logical mistakes.  Each Blockst rendering is placed next to
// the corresponding Open Roberta screenshot for direct visual comparison.
//
// Compile on the teaching-machine (the references live in iCloud there):
//   typst compile examples/nepo/fehler-comparison.typ fehler-comparison.pdf --root /

#import "@preview/blockst:0.4.0": nepo, set-blockst

#set page(width: 420mm, height: auto, margin: 12mm, fill: white)
#set text(font: "Helvetica Neue", fallback: true)
#set-blockst(font: "Helvetica Neue")

#let assets = "/Users/lkoehl/Library/Mobile Documents/com~apple~CloudDocs/Unterrichtsmaterial/IF 09/01 Einstieg in das Algorithmische Problemlösen/08 Fehler/assets/"

#let comparison(number, source) = {
  heading(level: 2)[Fehler #number]
  grid(
    columns: (1fr, 1fr),
    column-gutter: 12mm,
    row-gutter: 5mm,
    [*Open-Roberta-Referenz* \
      #image(assets + "fehler" + str(number) + ".png", width: 100%)],
    [*Blockst* \
      #nepo(source)],
  )
}

#comparison(1, "
Start
  wenn Taste A gedrückt?
    Zeige Bild (..#../.###./#####/.###./..#..)
  sonst
    Zeige Bild (#...#/.#.#./..#../.#.#./#...#)
")

#pagebreak()
#comparison(2, "
Start
  Schalte RGB LED an (#ff0000)
  Schalte RGB LED an (#ffff00)
  Schalte RGB LED an (#00cc00)
")

#pagebreak()
#comparison(3, "
Start
  Wiederhole solange Taste A gedrückt?
    Schalte RGB LED an (#ff0000)
  Schalte RGB LED aus
")

#pagebreak()
#comparison(4, "
Start
  Wiederhole unendlich oft
    wenn 50 > gib Wert % Lichtsensor
      Schalte RGB LED aus
    sonst
      Schalte RGB LED an (#ff0000)
")

#pagebreak()
#comparison(5, "
Start
  Wiederhole unendlich oft
    wenn gib Wert ° Temperatursensor ≥ 15
      Zeige Text \"Stufe 1\"
    wenn gib Wert ° Temperatursensor ≥ 10
      Zeige Text \"Stufe 2\"
    wenn gib Wert ° Temperatursensor ≥ 5
      Zeige Text \"Stufe 3\"
")

#pagebreak()
#comparison(6, "
Start
  Wiederhole unendlich oft
    wenn gib Geräusch % Mikrofon ≥ 80 oder gib Geräusch % Mikrofon ≤ 100
      Schalte RGB LED an (#ff0000)
    sonst
      wenn gib Geräusch % Mikrofon ≥ 50 oder gib Geräusch % Mikrofon ≤ 80
        Schalte RGB LED an (#ffff00)
      sonst
        wenn gib Geräusch % Mikrofon ≥ 20 oder gib Geräusch % Mikrofon ≤ 50
          Schalte RGB LED an (#00cc00)
        sonst
          Schalte RGB LED aus
")
