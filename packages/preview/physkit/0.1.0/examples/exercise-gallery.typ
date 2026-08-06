#import "@preview/physkit:0.1.0": mechanics

#set page(
  width: 297mm,
  height: 210mm,
  margin: (x: 10mm, y: 8mm),
  fill: rgb("f7f9fb"),
)
#set text(font: "Libertinus Serif", size: 8.5pt, fill: rgb("253047"))
#set par(leading: 0.55em)

#let panel(title, diagram) = block(
  width: 100%,
  height: 78mm,
  inset: 5mm,
  radius: 3mm,
  fill: white,
  stroke: rgb("d8e0e8") + 0.55pt,
  [
    #text(size: 10pt, weight: "semibold")[#title]
    #v(2mm)
    #align(center, diagram)
  ],
)

// 1. Bloco em plano inclinado.
#let ramp-1 = mechanics.inclined-plane(
  "ramp-1", length: 4.6, angle: 30deg,
)
#let box-1 = mechanics.box("box-1", width: 1.05, height: 0.72,
  label: [$m$], label-offset: (0.12, 0.12))
#let diagram-1 = mechanics.diagram(
  objects: (ramp-1, box-1),
  constraints: (mechanics.on-surface(box-1, ramp-1, distance: 2.6),),
  forces: (
    mechanics.force("p-1", box-1, (0, -1), magnitude: 1.35,
      anchor: "bottom", label: [$P$], label-offset: (0.28, 0)),
    mechanics.force("n-1", box-1, (-0.5, 0.866), magnitude: 1.1,
      label: [$N$], label-offset: (-0.18, 0.12)),
    mechanics.force("f-1", box-1, (-0.866, -0.5), magnitude: 1.0,
      anchor: "bottom", label: [$f$], label-offset: (-0.05, 0.2)),
  ),
)

// 2. Bloco puxado por uma força oblíqua.
#let floor-2 = mechanics.floor("floor-2", from: 0, to: 5.5)
#let box-2 = mechanics.box("box-2", width: 1.15, height: 0.78,
  label: [$m$])
#let diagram-2 = mechanics.diagram(
  objects: (floor-2, box-2),
  constraints: (mechanics.on-surface(box-2, floor-2, distance: 2.2),),
  forces: (
    mechanics.force("p-2", box-2, (0, -1), magnitude: 1.25,
      anchor: "bottom", label: [$P$], label-offset: (0.23, 0)),
    mechanics.force("n-2", box-2, (0, 1), magnitude: 1.15,
      anchor: "top", label: [$N$], label-offset: (0.22, 0)),
    mechanics.force("f-2", box-2, (-1, 0), magnitude: 1.0,
      anchor: "left", label: [$f$], label-offset: (0, 0.22)),
    mechanics.force("pull-2", box-2, (0.866, 0.5), magnitude: 1.55,
      anchor: "right", label: [$F$], label-offset: (0.05, 0.24)),
  ),
)

// 3. Máquina de Atwood.
#let ceiling-3 = mechanics.ceiling("ceiling-3", y: 4.8, from: 0.2, to: 5.2)
#let pulley-3 = mechanics.pulley("pulley-3", radius: 0.48)
#let left-3 = mechanics.box("left-3", width: 0.72, height: 0.72,
  label: [$m_1$])
#let right-3 = mechanics.box("right-3", width: 0.82, height: 0.82,
  label: [$m_2$])
#let diagram-3 = mechanics.diagram(
  objects: (ceiling-3, pulley-3, left-3, right-3),
  constraints: (
    mechanics.fixed-to(pulley-3, ceiling-3, position: 50%, distance: 0.65),
    mechanics.suspended-from(left-3, pulley-3, side: "left", length: 1.25),
    mechanics.suspended-from(right-3, pulley-3, side: "right", length: 1.7),
  ),
  connections: (
    mechanics.rope("rope-3", (
      mechanics.connect(left-3, "top"),
      mechanics.wrap(pulley-3, side: "upper"),
      mechanics.connect(right-3, "top"),
    ), label: [$T$], label-offset: (0.22, 0)),
  ),
  forces: (
    mechanics.weight("p1-3", left-3, magnitude: 0.9,
      label: [$P_1$], label-offset: (0.25, 0)),
    mechanics.weight("p2-3", right-3, magnitude: 1.1,
      label: [$P_2$], label-offset: (0.25, 0)),
  ),
)

// 4. Dois blocos conectados sobre uma mesa.
#let floor-4 = mechanics.floor("floor-4", from: 0, to: 6.2)
#let box-a4 = mechanics.box("box-a4", width: 1.1, height: 0.72,
  label: [$m_1$])
#let box-b4 = mechanics.box("box-b4", width: 1.25, height: 0.82,
  label: [$m_2$])
#let diagram-4 = mechanics.diagram(
  objects: (floor-4, box-a4, box-b4),
  constraints: (
    mechanics.on-surface(box-a4, floor-4, distance: 1.5),
    mechanics.on-surface(box-b4, floor-4, distance: 4.3),
  ),
  connections: (
    mechanics.rope("rope-4", (
      mechanics.connect(box-a4, "right"),
      mechanics.connect(box-b4, "left"),
    ), label: [$T$], label-offset: (0, 0.22)),
  ),
  forces: (
    mechanics.force("pull-4", box-b4, (1, 0), magnitude: 1.25,
      anchor: "right", label: [$F$], label-offset: (0, 0.22)),
  ),
)

// 5. Corpo sustentado por dois cabos.
#let ceiling-5 = mechanics.ceiling("ceiling-5", y: 4.5, from: 0.3, to: 5.7)
#let sign-5 = mechanics.box("sign-5", at: (3, 1.25), width: 1.65, height: 0.8,
  label: [$m$])
#let diagram-5 = mechanics.diagram(
  objects: (ceiling-5, sign-5),
  connections: (
    mechanics.rope("left-cable-5", (
      mechanics.connect(ceiling-5, "start"),
      mechanics.connect(sign-5, "top-left"),
    ), label: [$T_1$], label-offset: (-0.18, 0.18)),
    mechanics.rope("right-cable-5", (
      mechanics.connect(sign-5, "top-right"),
      mechanics.connect(ceiling-5, "end"),
    ), label: [$T_2$], label-offset: (0.18, 0.18)),
  ),
  forces: (
    mechanics.weight("p-5", sign-5, magnitude: 1.25,
      label: [$P$], label-offset: (0.25, 0)),
  ),
)

// 6. Queda com resistência do ar.
#let body-6 = mechanics.box("body-6", at: (2.6, 2.4), width: 0.85, height: 0.85,
  label: [$m$])
#let diagram-6 = mechanics.diagram(
  objects: (body-6,),
  forces: (
    mechanics.force("p-6", body-6, (0, -1), magnitude: 1.55,
      anchor: "bottom", label: [$P$], label-offset: (0.25, 0)),
    mechanics.force("drag-6", body-6, (0, 1), magnitude: 0.9,
      anchor: "top", label: [$F_r$], label-offset: (0.28, 0)),
    mechanics.force("velocity-6", body-6, (0, -1), magnitude: 1.0,
      anchor: "right", label: [$v$], color: rgb("d1495b"),
      label-offset: (0.25, 0)),
  ),
)

#align(center)[
  #text(size: 17pt, weight: "bold")[PhysKit — situações típicas de Mecânica]
  #v(1mm)
  #text(size: 8pt, fill: rgb("65758b"))[
    Diagramas declarados por objetos, vínculos, conexões e forças
  ]
]
#v(4mm)

#table(
  columns: (1fr, 1fr, 1fr),
  rows: (78mm, 78mm),
  gutter: 4mm,
  stroke: none,
  inset: 0pt,
  panel([1. Plano inclinado com atrito], diagram-1),
  panel([2. Tração oblíqua sobre piso], diagram-2),
  panel([3. Máquina de Atwood], diagram-3),
  panel([4. Blocos conectados], diagram-4),
  panel([5. Corpo suspenso por cabos], diagram-5),
  panel([6. Queda com resistência do ar], diagram-6),
)
