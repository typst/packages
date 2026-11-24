// sprig 0.8.0 — mindgrid : un vrai tableau 3 × 3, avec le moyeu au centre.
#import "@preview/sprig:0.8.0": *

#set page(width: 24cm, height: 17cm, margin: 0.8cm)
#set text(size: 9pt)

#align(center)[*Gestes pour une école durable*]
#v(0.35cm)

#align(center, mindgrid(
  [*Notre école*],
  cols: 3,
  rows: 3,
  hub-at: (1, 1),
  cell: 4.4,
  gap-x: 0.55,
  gap-y: 0.72,
  route: true,
  clearance: 0.28,
  stalk: 0.16,
  stalk-tip: 0.06,
  wave: 0.012,
  palette: "cool",
  theme: "poster",
  node(title: [*Énergie*], shape: "leaf")[Veilles éteintes, jour lumineux.],
  node(title: [*Eau*], shape: "cloud")[Fuites réparées.],
  node(title: [*Déchets*], shape: "ticket")[Trier et réemployer.],
  node(title: [*Mobilité*], shape: "bookmark")[Marche, vélo, bus.],
  node(title: [*Alimentation*], shape: "round")[Local, de saison.],
  node(title: [*Nature*], shape: "bubble")[Planter et observer.],
  node(title: [*Achats*], shape: "parallelogram")[Réparer avant d’acheter.],
  node(title: [*Participation*], shape: "round")[Proposer, puis tester.],
))
