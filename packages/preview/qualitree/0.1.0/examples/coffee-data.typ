// A fictional design workshop, not a product benchmark. Need weights and every
// relationship are illustrative judgments. Thresholds are separate pass/fail
// gates; a high aggregate priority never establishes taste or safety acceptance.
#import "../lib.typ": qfd-stage, qfd-deploy, qfd-diff

#let needs = (
  (id: "taste", label: [Enjoy a café-worthy taste], weight: 10),
  (id: "temperature", label: [Drink coffee at an acceptable temperature], weight: 9),
  (id: "sequence", label: [Make 2–3 coffees consecutively], weight: 7),
  (id: "routine", label: [Set up and clean with little effort], weight: 7),
  (id: "freshness", label: [Use preground coffee six months after roasting], weight: 6),
  (id: "space", label: [Keep the kitchen footprint small], weight: 4),
  (id: "safety", label: [Use safely without training, with a child nearby], weight: 10),
)

// Functions describe transformations, storage, transport, and protection. The
// provisional system includes machine, sealed dose, and protective packaging.
#let functions = (
  (id: "store-water", label: [Store water for consecutive drinks], direction: "maximize", target: [3 cups \ + rinse]),
  (id: "make-heat", label: [Convert electrical energy into heat], direction: "minimize", target: [Warm-up \ TBD]),
  (id: "control-heat", label: [Deliver water at controlled temperature], direction: "target", target: [92 ± 2 \ °C\*]),
  (id: "pressurize", label: [Pressurize water for extraction], direction: "target", target: [Recipe \ TBD]),
  (id: "channel", label: [Channel and meter water to the dose], direction: "target", target: [Volume \ TBD]),
  (id: "open-dose", label: [Open the dose flow path], direction: "minimize", target: [1 dose \ insert]),
  (id: "extract", label: [Control water–grounds contact], direction: "target", target: [≈25 s\*]),
  (id: "preserve", label: [Preserve grounds before extraction], direction: "maximize", target: [6 mo.\*]),
  (id: "serve", label: [Deliver coffee into the cup], direction: "minimize", target: [Heat loss \ TBD]),
  (id: "collect", label: [Collect drips and spent doses], direction: "maximize", target: [3 spent \ doses]),
  (id: "guide", label: [Guide setup and the brewing sequence], direction: "minimize", target: [Steps \ TBD]),
  (id: "protect", label: [Contain heat, pressure, and electrical hazards], direction: "minimize", target: [Risk \ gates \ TBD]),
)

#let needs-functions = qfd-stage(
  rows: needs, columns: functions,
  matrix: (
    (0, 1, 9, 3, 9, 3, 9, 9, 3, 0, 1, 0),
    (0, 9, 9, 0, 1, 0, 3, 0, 9, 0, 1, 1),
    (9, 9, 3, 3, 3, 3, 3, 0, 1, 9, 3, 1),
    (3, 0, 0, 0, 1, 9, 1, 3, 3, 9, 9, 1),
    (0, 0, 0, 0, 0, 1, 1, 9, 0, 0, 0, 0),
    (9, 3, 0, 3, 1, 1, 0, 1, 1, 9, 0, 3),
    (1, 3, 3, 9, 3, 9, 1, 1, 3, 3, 9, 9),
  ),
  correlations: ((2, 3, "++"), (3, 9, "+"), (4, 12, "-"), (6, 12, "--"), (6, 11, "+")),
  labels: (whats: [Household needs], hows: [Functions], target: [Provisional target\*]),
)

// Components implement the functions above. Pump type, heater technology, and
// sensor principle remain candidate choices, not requirements disguised as HOWs.
#let components = (
  (id: "tank", label: [Water tank and refill interface]),
  (id: "heater", label: [Heater and thermal sensor]),
  (id: "pump", label: [Pump and pressure-limiting path]),
  (id: "meter", label: [Flowmeter and water circuit]),
  (id: "chamber", label: [Dose chamber, opener, and seals]),
  (id: "dose", label: [Sealed dose and barrier packaging]),
  (id: "outlet", label: [Coffee outlet and cup support]),
  (id: "collector", label: [Drip tray and spent-dose container]),
  (id: "controller", label: [Controller and user interface]),
  (id: "housing", label: [Housing, interlocks, and power protection]),
)

#let functions-components = qfd-deploy(needs-functions,
  columns: components,
  matrix: (
    (9, 0, 0, 1, 0, 0, 0, 0, 1, 1),
    (0, 9, 0, 0, 0, 0, 0, 0, 3, 3),
    (0, 9, 1, 3, 1, 0, 0, 0, 9, 1),
    (0, 0, 9, 3, 3, 0, 0, 0, 3, 3),
    (1, 0, 3, 9, 3, 1, 0, 0, 9, 0),
    (0, 0, 1, 0, 9, 9, 0, 0, 1, 3),
    (0, 3, 3, 9, 9, 9, 1, 0, 9, 0),
    (0, 0, 0, 0, 0, 9, 0, 0, 0, 0),
    (0, 0, 0, 1, 3, 0, 9, 0, 1, 1),
    (0, 0, 0, 0, 3, 1, 3, 9, 0, 1),
    (3, 0, 0, 0, 3, 1, 1, 3, 9, 3),
    (1, 3, 9, 3, 9, 1, 3, 3, 9, 9),
  ),
  show-roof: false,
  labels: (whats: [Functions · inherited priorities], hows: [Components], importance: [Rel. %]),
)

// A deliberately small editorial example isolates revision semantics from the
// café-substitution study. Relationship changes have no measured justification.
#let revision-before = qfd-stage(
  rows: (needs.at(0), needs.at(3), (id: "decor", label: [Offer a decorative light], weight: 2)),
  columns: (functions.at(2), functions.at(6), (id: "light", label: [Illuminate the worktop])),
  matrix: ((9, 9, 0), (1, 3, 1), (0, 0, 9)),
  correlations: ((1, 2, "+"), (2, 3, "-")),
)
#let revision-after = qfd-stage(
  rows: (needs.at(3) + (label: [Clean with fewer handling steps],), needs.at(0), needs.at(6)),
  columns: (functions.at(6), functions.at(2), functions.at(11)),
  matrix: ((9, 0, 1), (9, 9, 0), (1, 3, 9)),
  correlations: ((1, 2, "++"), (1, 3, "+")),
)
#let revision-view = qfd-diff(revision-before, revision-after)
