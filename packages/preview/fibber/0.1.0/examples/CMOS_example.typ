#import "@preview/fibber:0.1.0": *

#let materials = (
  "p-type substrate": yellow,
  oxide: gray,
  n-well: aqua,
  polysilicon: green,
  "n+": blue,
  "p+": orange,
  nitride: luma(140),
  metal: luma(50),
)

#let patterns = (
  pmos-oxide-etch: ((left, middle, right)) => ((middle + 1, right - 1.5),),
  n-well: ((left, middle, right)) => ((middle + 0.5, right - 1),),
  nmos-oxide-etch: ((left, middle, right)) => ((left + 1.5, middle - 1),),
  gate-oxide-upper: ((left, middle, right)) => (
    (left, left + 1.5),
    (middle - 1, middle + 1),
    (right - 1.5, right),
  ),
  gate-oxide-lower: ((left, middle, right)) => (
    (left + 1.5, middle - 1),
    (middle + 1, right - 1.5),
  ),
  polysilicon-etch: ((left, middle, right)) => (
    (left + 1.5, left + 3),
    (left + 5.5, middle - 1),
    (middle + 1, right - 5.5),
    (right - 3, right - 1.5),
  ),
  n: ((left, middle, right)) => (
    (left + 1.45, left + 3.05),
    (left + 5.45, middle - 0.95),
  ),
  p: ((left, middle, right)) => (
    (middle + 0.95, right - 5.45),
    (right - 3.05, right - 1.45),
  ),
  nitride-etch-2: ((left, middle, right)) => (
    (left + 3.75, left + 4.75),
    (right - 4.75, right - 3.75),
  ),
  metal-etch: ((left, middle, right)) => (
    (left + 3, left + 3.75),
    (left + 4.75, left + 5.5),
    (right - 5.5, right - 4.75),
    (right - 3.75, right - 3),
  ),
)

#let cmos-steps = device-steps(
  materials: materials,
  width: 16,
  display-steps: (1,2,3,4,6,8,11,14,17,19,24,25),
  steps: (
    deposit(
      material: "p-type substrate",
      height: 2,
    ),
    deposit(
      material: "oxide",
    ),
    etch(
      pattern: patterns.pmos-oxide-etch
    ),
    deposit(
      material: "n-well",
      pattern: patterns.n-well,
      start-layer: current => current - 2.5,
      height: 1.5
    ),
    etch(
      pattern: patterns.nmos-oxide-etch,
    ),
    deposit(
      material: "oxide",
      pattern: patterns.gate-oxide-lower,
      start-layer: current => current - 1,
      height: 0.5,
    ),
    deposit(
      material: "oxide",
      pattern: patterns.gate-oxide-upper,
      height: 0.5,
    ),
    deposit(
      material: "polysilicon",
      pattern: patterns.gate-oxide-lower,
      start-layer: current => current - 1,
      height: 0.5,
    ),
    deposit(
      material: "polysilicon",
      pattern: patterns.gate-oxide-upper,
      height: 0.5,
    ),
    etch(
      pattern: patterns.gate-oxide-upper,
      height: 0.5,
    ),
    etch(
      pattern: patterns.polysilicon-etch,
      start-layer: current => current - 2
    ),
    set-active-layer(new-layer: 1),
    deposit(
      material: "n+",
      pattern: patterns.n,
    ),
    set-active-layer(new-layer: 1),
    deposit(
      material: "p+",
      pattern: patterns.p,
    ),
    deposit(
      material: "nitride",
      pattern: patterns.polysilicon-etch,
    ),
    deposit(
      material: "nitride",
      pattern: patterns.gate-oxide-lower,
      height: 0.5,
    ),
    deposit(
      material: "nitride",
      pattern: patterns.gate-oxide-upper,
      height: 0.5,
    ),
    etch(
      pattern: patterns.polysilicon-etch,
      height: 1.5,
      start-layer: current => current - 1.5,
    ),
    etch(
      pattern: patterns.nitride-etch-2,
      height: 1,
      start-layer: current => current - 1,
    ),
    set-active-layer(new-layer: current => current - 2),
    deposit(
      material: "metal",
      pattern: patterns.polysilicon-etch,
      height: 1.5,
    ),
    deposit(
      material: "metal",
      pattern: patterns.nitride-etch-2,
      height: 0.5,
      start-layer: current => current - 0.5
    ),
    deposit(
      material: "metal",
      pattern: patterns.gate-oxide-lower,
      height: 0.5,
    ),
    deposit(
      material: "metal",
      pattern: patterns.gate-oxide-upper,
      height: 0.5,
    ),
    etch(
      pattern: patterns.metal-etch,
      start-layer: current => current - 1.5,
      height: 0.5,
    ),
  )
)

#step-diagram(
  columns: 3,
  device-steps: cmos-steps,
  step-desc: (
    "1. Grow field oxide",
    "2. Etch oxide for pMOSFET",
    "3. Diffuse n-well",
    "4. Etch oxide for nMOSTFET",
    "5. Grow gate oxide",
    "6. Deposit polysilicon",
    "7. Etch polysilicon and oxide",
    "8. Implant sources and drains",
    "9. Grow nitride",
    "10. Etch nitride",
    "11. Deposit metal",
    "12. Etch metal",
  ),
  legend: [], 
)
#format-legend(materials: materials, columns: 4)
