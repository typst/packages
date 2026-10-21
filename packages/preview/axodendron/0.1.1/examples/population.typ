#import "@preview/axodendron:0.1.1" as swc

#set page(width: auto, height: auto, margin: 3mm)
#set text(size: 8pt)

#let load-file(name) = swc.load(read("data/" + name, encoding: none), profile: "incf-strict")
#let cells = swc.population((
  swc.population-entry("AA0109", cell: load-file("AA0109.CNG.swc")),
  swc.population-entry("Nr5a1", cell: load-file("Nr5a1-Cre_Ai14-187777-05-02-01_491392821_m.kp1.swc")),
  swc.population-entry("Sst", cell: load-file("Sst-IRES-Cre_Ai14-188740-03-02-01_491119369_m.kp12.swc")),
))
#let features = swc.feature-table(
  cells,
  columns: (
    swc.feature-column("fractional-anisotropy", name: "FA"),
    swc.feature-column(
      "local-bifurcation-angle",
      name: "mean local angle",
      aggregate: "mean",
      missing-policy: "omit",
    ),
    swc.feature-column("centroid", name: "centroid x", component: "x"),
  ),
)
#let show-cell(cell) = if cell.status == "value" { calc.round(cell.value, digits: 3) } else { [missing: #cell.reason] }

#table(
  columns: (auto, auto, auto, auto),
  inset: 5pt,
  table.header([*Morphology*], [*FA*], [*Mean local angle (degrees)*], [*Centroid x (µm)*]),
  ..features.rows.map(row => (
    [#row.id],
    [#show-cell(row.values.at(0))],
    [#show-cell(row.values.at(1))],
    [#show-cell(row.values.at(2))],
  )).flatten(),
)

#block(inset: (top: 2mm, bottom: 0.8mm))[
  #set text(size: 7.5pt, fill: luma(38%))
  *Data:* NeuroMorpho.Org records 85226 (MouseLight), 62390 and 62495 (Allen Cell Types); doi:10.1002/jnr.23978, doi:10.25378/janelia.5526706, and doi:10.1016/j.neuron.2015.02.022; CC BY 4.0. Cite NeuroMorpho.Org, RRID:SCR_002145.
]
