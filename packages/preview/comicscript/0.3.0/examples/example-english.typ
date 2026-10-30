#import "@preview/comicscript:0.3.0" as hq

#set document(title: "comicscript — English authoring API")
#set page(paper: "a4", margin: 20mm, numbering: "1")
#set text(font: "Libertinus Serif", size: 11pt, lang: "en")

// Synthetic demonstration of English commands; PDF labels remain Portuguese.
#let pages = (
  hq.page(
    1,
    title: [A sensor test],
    objective: [Demonstrate a short equipment check at a test bench.],
    status: "draft",
    notes: (hq.note("decision", status: "resolved")[Use only one test bench.],),
    hq.row(
      hq.panel(
        id: "sensor-check",
        weight: 2,
        shot: "wide shot",
        composition: [Place the indicator above the control panel.],
        texts: (
          hq.caption[The first equipment test...],
          hq.speech("Alex", mode: "thought")[That light is blinking.],
          hq.sound[BEEP!],
        ),
        notes: (
          hq.note("continuity")[Keep the power cable on the left.],
          hq.note("alternative", status: "discarded")[Start with a close-up.],
        ),
        references: ([Control panel diagram.],),
      )[Alex checks a small sensor above the test bench.],
      hq.panel(
        texts: (hq.speech("Sam")[The reading is stable.],),
      )[Sam compares the display with a handwritten checklist.],
    ),
    hq.row(
      weight: 2,
      hq.panel[Both indicators glow steadily while the checklist receives a check mark.],
    ),
  ),
)

#hq.render(pages, mode: sys.inputs.at("mode", default: "editorial"))
