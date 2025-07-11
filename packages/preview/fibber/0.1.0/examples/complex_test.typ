#import "../src/exports.typ": *
#import "@preview/typsium:0.2.0": ce


#let materials = (
  "aSi": gray,
  "Al2O3": rgb("b0bccc"),
  "Metal": yellow,
  "SiO2": rgb("#742ca8"),
  "LN": rgb("#08b4f4"),
)

#let device = device-steps(
  materials: materials,
  display-steps: (3,4,5,8,9,10),
  steps: (
    deposit(
      material: "Al2O3",
      height: 2.5,
    ),
    deposit(
      material: "aSi",
    ),
    deposit(
      material: "Metal",
    ),
    deposit(
      material: "LN",
      pattern: ((left, middle, right)) => ((left, right - 2),)
    ),
    etch(
      height: 2,
      pattern: ((left, middle, right)) => ((left, left + 2),),
    ),
    deposit(
      material: "SiO2",
      start-layer: 3.5,
      pattern: ((left, middle, right)) => ((left, left + 2),),
      height: 2,
    ),
    deposit(
      material: "Metal",
      pattern: ((left, middle, right)) => ((left, left + 1.5),),
      height: 2,
    ),
    deposit(
      material: "Metal",
      pattern: ((left, middle, right)) => (
        (middle - 1.75, middle - 1),
        (middle - 0.75, middle - 0.25),
        (middle + 0.25, middle + 0.75),
        (middle + 1, middle + 1.75),
      ),
      start-layer: (current-layer) => current-layer - 2,
    ), 
    deposit(
      material: "Metal",
      start-layer: (current-layer) => current-layer - 3,
      height: 3,
      pattern: ((left, middle, right)) => ((right - 2, right),),
    ),
    etch(
      start-layer: (current-layer) => current-layer - 3,
      height: 2,
      pattern: ((left, middle, right)) => ((middle - 0.25, middle + 0.25),),
    ),
    etch(
      start-layer: (current-layer) => current-layer - 5,
      pattern: ((left, middle, right)) => ((left + 1.5, right - 1.5,),
    )
  )
  )
)

#let step-desc = (
  [1. Electrode Exposure],
  [2. Active Area Etch],
  [3. SiO2 Backfill],
  [4. 3x Metal Deposition],
  [5. Release Window Etch],
  [6. XeF2 Release],
)
#step-diagram(
  device-steps: device,
  columns: 4,
  step-desc: step-desc,
  legend: format-legend(columns: 2, column-gutter: 15%, materials: materials, format-text: it => {
    if it == "Al2O3" or it == "SiO2" {
      place(dy: -2.25pt, ce(it))
    } else {
      text(it)
    }
  }),
)


