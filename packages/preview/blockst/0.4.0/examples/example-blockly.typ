// Blockly blocks: the jwinf profile next to the default look.
//
// The same notation as scratch(). On jwinf a block's label changes from task
// to task, so unknown labels are drawn as written and take their category
// from a `::kategorie` suffix; loops, conditions, variables and the world
// commands are recognised without one.
#import "@preview/blockst:0.4.0": blockly, raw-blockly

#set page(width: auto, height: auto, margin: 4mm, fill: none)
#set text(font: ("Helvetica Neue", "Helvetica", "Arial"))
#show: raw-blockly()

#let programm = "
Roboter-Programm
wiederhole (4) mal:
  gehe nach rechts
  falls <auf Kiste>
    hebe Murmel auf ::aktionen
  sonst
    drehe nach links
  ende
ende
setze [Punkte v] auf (0)
"

#grid(
  columns: 3,
  column-gutter: 7mm,
  row-gutter: 2mm,
  align: top + left,
  text(size: 8pt, fill: gray)[jwinf], text(size: 8pt, fill: gray)[jwinf · grayscale], text(size: 8pt, fill: gray)[blockly (default)],

  blockly(programm, profile: "jwinf"),
  blockly(programm, profile: "jwinf", theme: "grayscale"),
  [
    ```blockly
    falls <(1) = (2)>
      setze [x v] auf (7)
    ende
    ```
    ```jwinf
    gehe (3) Schritte
    drehe um (90) nach [links v]
    ```
  ],

  text(size: 8pt, fill: gray)[jwinf-turtle], text(size: 8pt, fill: gray)[jwinf · `colors: (aktionen: …)`], [],

  // The turtle sandbox colours loops, logic and maths differently.
  blockly(programm, profile: "jwinf-turtle"),
  // A task with its own colours: lay them over the profile's palette.
  blockly(programm, profile: "jwinf", colors: (aktionen: "#cc7347", schleifen: rgb("#5ba55b"))),
  [],
)
