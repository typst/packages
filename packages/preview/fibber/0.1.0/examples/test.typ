#import "../src/exports.typ": *

#let materials = (
  Si: luma(120),
  LN: olive,
  Pt: gray,
  Au: yellow,
)

#let electrode-pattern = ((left, middle, right)) => (
  (left + 0.5, left + 1.25),
  (left + 1.75, middle - 0.75),
  (middle - 0.5, middle + 0.5),
  (middle + 0.75, right - 1.75),
  (right - 1.25, right - 0.5),
)

#let release-hole-etch-pattern = ((left, middle, right)) => (
  (left + 1.25, left + 1.75),
  (right - 1.75, right - 1.25),
)


#let device1 = device-steps(
  display-steps: (1, 2, 4, 5),
  materials: materials,
  steps: (
    deposit(material: "Si",),
    deposit(material: "LN",),
    etch(pattern: release-hole-etch-pattern,),
    deposit(
      material: "Pt",
      pattern: electrode-pattern,
      height: 0.5
    ),
    deposit(
      material: "Au",
      pattern: electrode-pattern,
      height: 0.5,
    ),
    etch(
      start-layer: 0,
      pattern: ((left,middle,right)) => ((left + 0.5, right - 0.5),)
    )
  ), 
)

#let step-desc = (
  [1. Sample Transfer],
  [2. Release Hole Etch],
  [3. Electrode Deposition],
  [4. XeF2 Release],
)

#step-diagram(
  columns: 2,
  device-steps: device1,
  step-desc: step-desc,
  legend: format-legend(columns: 2, materials: materials)
)
