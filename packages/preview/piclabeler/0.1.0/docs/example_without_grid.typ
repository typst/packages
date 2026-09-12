#import "@preview/piclabeler:0.1.0" as pl

#set page(margin: 2mm, width: auto, height: auto)

#pl.annotated-image(
  grid: none,
  width: 10cm,
  image-width: 80%,
  // https://images.nasa.gov/details/B1B_Cargo_Expanded_View
  image("B1B_Cargo_Expanded_View.jpg"),
  {
    let label = pl.label.with(
      frame: "rect",
      padding: 0.4em,
      mark: (
        end: ">>",
        fill: black,
        stroke: none
      ),
    )
    label([Cargo Fairing], (6, 0), to: (6, 4.3))
    label([Boosters], (2, -2), to: ((-4.6, 1), (-2, -4.7)))
  },
)
