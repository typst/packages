// Deploy one product change across both existing stages. All strengths and
// weights are workshop hypotheses; unchanged IDs preserve the baseline history.
#import "@preview/qualitree:0.1.0": qfd-stage, qfd-deploy, qfd-diff
#import "coffee-data.typ": needs, functions, components, needs-functions, functions-components

#let milk-needs = needs.map(item => if item.id == "routine" {
  item + (label: [Set up and clean coffee and milk paths easily],)
} else { item }) + (
  (id: "milk-drink", label: [Enjoy warm milk drinks with suitable texture], weight: 8),
  (id: "milk-ready", label: [Keep milk ready between drink sessions], weight: 6),
)
#let milk-functions = functions.map(item => if item.id == "guide" {
  item + (label: [Guide coffee, milk, and cleaning sequences],)
} else if item.id == "protect" {
  item + (label: [Contain hot-water, steam, and electrical hazards],)
} else if item.id == "collect" {
  item + (label: [Collect doses, drips, and milk rinse waste],)
} else { item }) + (
  (id: "store-milk", label: [Store milk under controlled refrigeration], target: [Storage gate\ TBD]),
  (id: "meter-milk", label: [Channel and meter milk to the cup], target: [Dose\ TBD]),
  (id: "heat-milk", label: [Transfer controlled heat into milk], target: [Serving temp.\ TBD]),
  (id: "texture-milk", label: [Generate steam and texture milk], target: [Texture\ TBD]),
  (id: "clean-milk", label: [Flush and clean milk-contact paths], target: [Hygiene gate\ TBD]),
)

// Each existing need gets five new relationships in the function order above.
// A positive strength means relevance, not a beneficial impact: refrigeration
// can strongly affect footprint while making the footprint harder to satisfy.
#let extensions = (
  (1, 1, 3, 3, 9), // Taste: residues and milk preparation can affect the result.
  (0, 1, 9, 3, 0), // Temperature now depends on the combined drink.
  (3, 9, 9, 9, 3), // Consecutive drinks consume milk, heat, and rinse capacity.
  (3, 3, 1, 3, 9), // The original cleaning need extends to the milk circuit.
  (0, 0, 0, 0, 0), // Grounds preservation is unchanged by the added capability.
  (9, 3, 3, 3, 3), // Cold storage and plumbing consume the existing space budget.
  (3, 3, 9, 9, 9), // Steam, food-contact paths, and cooling add hazard interfaces.
)
#let milk-needs-functions = qfd-stage(
  rows: milk-needs, columns: milk-functions,
  matrix: needs-functions.matrix.enumerate().map(((i, row)) => row + extensions.at(i)) + (
    (1, 3, 3, 0, 1, 0, 1, 0, 3, 1, 3, 3, 3, 9, 9, 9, 3),
    (0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 3, 3, 9, 1, 0, 0, 9),
  ),
  correlations: needs-functions.correlations + ((2, 16, "-"), (13, 15, "-"), (14, 17, "+")),
  labels: (whats: [Existing and new household needs], hows: [Functions · milk extension]),
)

#let milk-components = components.map(item => if item.id == "heater" {
  item + (label: [Coffee heater and coordinated thermal sensing],)
} else if item.id == "collector" {
  item + (label: [Drip tray, dose container, and rinse capacity],)
} else if item.id == "controller" {
  item + (label: [Controller, milk sequence, and cleaning interface],)
} else if item.id == "housing" {
  item + (label: [Housing, steam protection, and shared power budget],)
} else { item }) + (
  (id: "cold-module", label: [Refrigerated milk reservoir and sensor]),
  (id: "milk-circuit", label: [Milk pump, valves, and removable tubing]),
  (id: "steam-module", label: [Steam generator and thermal protection]),
  (id: "frother", label: [Steam–milk mixer and outlet]),
)

// Explicitly revise shared interfaces as well as adding hardware. Cleaning
// participates in the inherited waste collector and controller; no standalone
// "cleaner" component is assumed. Cooling technology is deliberately undecided.
#let shared = functions-components.matrix.enumerate().map(((i, original)) => {
  let row = original
  if i == 1 { row.at(8) = 9; row.at(9) = 9 } // Coordinate heat demand and power.
  row + (
    (0, 0, 0, 0), (0, 0, 9, 0), (0, 0, 1, 0), (0, 0, 0, 0),
    (0, 0, 3, 0), (0, 0, 0, 0), (0, 0, 0, 0), (0, 0, 0, 0),
    (0, 0, 0, 3), (0, 1, 1, 3), (3, 3, 3, 3), (3, 3, 9, 9),
  ).at(i)
})
#let milk-functions-components = qfd-deploy(milk-needs-functions,
  columns: milk-components,
  matrix: shared + (
    (0, 0, 0, 0, 0, 0, 0, 0, 3, 3, 9, 1, 0, 0),
    (0, 0, 0, 0, 0, 0, 1, 1, 9, 1, 3, 9, 0, 3),
    (1, 1, 0, 3, 0, 0, 0, 0, 9, 3, 0, 3, 9, 9),
    (3, 1, 3, 3, 0, 0, 0, 1, 9, 3, 0, 3, 9, 9),
    (3, 0, 0, 1, 0, 0, 0, 9, 9, 1, 9, 9, 3, 9),
  ),
  show-roof: false,
  labels: (whats: [Functions · redeployed priorities], hows: [Existing and new components], importance: [Rel. %]),
)
#let revision-view = qfd-diff(needs-functions, milk-needs-functions)
#let component-revision-view = qfd-diff(functions-components, milk-functions-components)
