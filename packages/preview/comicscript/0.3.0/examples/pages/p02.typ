#import "@preview/comicscript:0.3.0" as hq

// Synthetic continuation; it is not an excerpt from a working comic.
#let p2 = hq.page(
  2,
  title: [A careful landing],
  objective: [Bring the kite down safely through a small coordinated action.],
  status: "draft",
  hq.row(
    hq.panel(
      id: "kite-drifting",
      shot: "wide shot",
      notes: (
        hq.note("continuity")[Keep the red ribbon attached to the kite.],
      ),
    )[The wind weakens. The kite drifts toward the grass while the two friends prepare to retrieve it.],
  ),
  hq.row(
    hq.panel(
      id: "reel-turning",
      texts: (
        hq.speech("Sam")[I can turn the reel slowly while you prepare a place for landing.],
      ),
    )[Sam turns the reel with both hands.],
    hq.panel(
      texts: (hq.speech("Alex")[Then I will keep the blanket open.],),
      notes: (
        hq.note("alternative")[Try a closer view of the blanket unfolding.],
      ),
    )[Alex opens a blanket on a clear patch of grass.],
  ),
  hq.row(
    hq.panel(
      texts: (hq.speech("Sam")[There it is. Safe and sound.],),
      notes: (
        hq.note("subtext")[The relaxed posture signals that the task is complete.],
        hq.note("custom-review", author: "Example editor")[A custom category needs no registration.],
      ),
    )[The kite settles on the blanket. Alex and Sam crouch beside it.],
  ),
)
