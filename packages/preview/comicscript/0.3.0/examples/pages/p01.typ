#import "@preview/comicscript:0.3.0" as hq

// Synthetic scene written solely to demonstrate the package.
#let p1 = hq.page(
  1,
  title: [A paper kite],
  objective: [Introduce a kite-flying activity in a park.],
  status: "draft",
  notes: (
    hq.note("decision", status: "resolved")[Keep the action within the park.],
  ),
  hq.row(
    hq.panel(
      texts: (hq.speech("Alex")[Ready for the first flight?],),
    )[Alex holds a paper kite while Sam checks the reel.],
  ),
  hq.row(
    weight: 3,
    id: "launch-row",
    notes: (hq.note("composition")[The launch uses three times the height of the opening row.],),
    hq.panel(
      id: "kite-launch",
      shot: "wide shot",
      composition: [The sky fills the upper area. Both figures remain near the bottom.],
      notes: (
        hq.note("composition")[Leave a clear silhouette around the kite.],
        hq.note("alternative", status: "discarded")[Start with a close-up of the reel.],
      ),
    )[The kite rises above an open meadow. Alex releases the frame and Sam holds the line.],
  ),
)
