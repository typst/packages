#import "@preview/fibber:0.1.0"

#let materials = (
  Conductor: yellow,
  Dielectric: blue,
  Substrate: luma(120),
)

#let electrode-pattern = ((left, middle, right)) => (
  (left + 0.5, middle - 1.25),
  (middle - 0.75, middle + 0.75),
  (middle + 1.25, right - 0.5),
)

#let device-steps = device-steps(
  materials: materials,
  steps: (
    deposit(
      material: "Substrate",
      height: 2
    ),
    deposit(
      material: "Dielectric",
    ),
    deposit(
      material: "Conductor",
      pattern: electrode-pattern,
      height: 0.5
    ),
  ),
)
// Used this to visualize the device I was building as I was building it
// #device-steps.last()

#step-diagram(
  columns: 2,
  device-steps: device-steps,
  step-desc: ("1. Transfer Substrate", "2. Add Dielectric", "3. Conductor Deposition",),
  legend: format-legend(columns: 2, materials: materials,),
)
