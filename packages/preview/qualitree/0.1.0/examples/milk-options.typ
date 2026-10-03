// A compact teaching model, independent of the detailed coffee deployment.
// Both options are compared against the same coffee-only baseline. Scores are
// illustrative relevance judgments, not measured option performance.
#import "@preview/qualitree:0.1.0": qfd-stage, qfd-deploy, qfd-diff

#let needs = (
  (id: "taste", label: [Enjoy good coffee], weight: 10),
  (id: "clean", label: [Clean up easily], weight: 7),
  (id: "space", label: [Use little counter space], weight: 4),
  (id: "safe", label: [Use safely at home], weight: 10),
)
#let functions = (
  (id: "coffee", label: [Prepare coffee]),
  (id: "clean", label: [Clean fluid paths]),
  (id: "protect", label: [Contain hazards]),
)
#let baseline = qfd-stage(rows: needs, columns: functions,
  matrix: ((9, 3, 0), (3, 9, 1), (3, 3, 1), (3, 3, 9)),
  show-roof: false,
  labels: (whats: [Needs], hows: [Functions]),
)
#let milk-need = (id: "milk", label: [Enjoy warm, textured milk], weight: 8)
#let milk-functions = (
  (id: "heat-milk", label: [Heat milk]),
  (id: "texture", label: [Texture milk]),
)
#let manual = qfd-stage(rows: needs + (milk-need,),
  columns: functions.slice(0, 1) + (
    functions.at(1) + (label: [Clean coffee and milk paths],),
    functions.at(2) + (label: [Contain coffee and steam hazards],),
  ) + milk-functions,
  matrix: (
    (9, 3, 0, 1, 1),
    (3, 9, 1, 3, 3),
    (3, 3, 1, 3, 3),
    (3, 3, 9, 9, 9),
    (1, 3, 3, 9, 9),
  ),
  show-roof: false,
  labels: (whats: [Existing needs + milk drinks], hows: [Functions]),
)
#let automatic = qfd-stage(
  rows: needs + (milk-need, (id: "ready", label: [Keep milk ready between sessions], weight: 6)),
  columns: manual.column-ids.enumerate().map(((i, id)) => (id: id, label: manual.hows.at(i))) + (
    (id: "cold", label: [Store refrigerated milk]),
    (id: "meter", label: [Meter milk automatically]),
  ),
  matrix: manual.matrix.enumerate().map(((i, row)) => row + (
    (1, 1), (9, 9), (9, 3), (3, 3), (3, 9),
  ).at(i)) + ((0, 9, 3, 0, 0, 9, 3),),
  show-roof: false,
  labels: (whats: [Existing needs + milk convenience], hows: [Functions]),
)
#let components = (
  (id: "coffee", label: [Coffee brewing module]),
  (id: "control", label: [Controller and interface]),
  (id: "housing", label: [Housing and protection]),
)
#let baseline-components = qfd-deploy(baseline, columns: components,
  matrix: ((9, 3, 3), (9, 3, 1), (3, 3, 9)),
  show-roof: false,
  labels: (whats: [Functions], hows: [Components], importance: [Rel. %]),
)
#let manual-components = qfd-deploy(manual,
  columns: (components.at(0),
    components.at(1) + (label: [Controller with steam mode],),
    components.at(2) + (label: [Housing and steam protection],),
    (id: "steam", label: [Steam generator]),
    (id: "wand", label: [Steam wand and removable jug]),
  ),
  matrix: (
    (9, 3, 3, 0, 0),
    (9, 3, 1, 1, 9),
    (3, 9, 9, 9, 9),
    (1, 9, 3, 9, 9),
    (0, 3, 3, 9, 9),
  ),
  show-roof: false,
  labels: (whats: [Functions · inherited priorities], hows: [Components], importance: [Rel. %]),
)
#let automatic-components = qfd-deploy(automatic,
  columns: (components.at(0),
    components.at(1) + (label: [Controller with automatic milk cycle],),
    components.at(2) + (label: [Housing and shared power protection],),
    (id: "steam", label: [Steam generator]),
    (id: "mixer", label: [Automatic steam–milk mixer]),
    (id: "cold", label: [Refrigerated reservoir]),
    (id: "circuit", label: [Milk pump, valves, and tubing]),
  ),
  matrix: (
    (9, 3, 3, 0, 0, 0, 0),
    (9, 9, 1, 1, 9, 9, 9),
    (3, 9, 9, 9, 9, 3, 3),
    (1, 9, 3, 9, 9, 0, 3),
    (0, 9, 3, 9, 9, 0, 3),
    (0, 3, 3, 0, 0, 9, 1),
    (0, 9, 1, 0, 3, 3, 9),
  ),
  show-roof: false,
  labels: (whats: [Functions · inherited priorities], hows: [Components], importance: [Rel. %]),
)
#let manual-diff = qfd-diff(baseline, manual)
#let manual-component-diff = qfd-diff(baseline-components, manual-components)
#let automatic-diff = qfd-diff(baseline, automatic)
#let automatic-component-diff = qfd-diff(baseline-components, automatic-components)
