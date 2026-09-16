// A compact, Typst-native introduction to cubic SrTiO3. The crystallographic
// and reciprocal-space geometry is computed by materia; the band energies are
// deliberately simple analytic illustration data, not a first-principles result.
#import "@preview/materia:0.1.0": prototypes, crystal, crystal-scene
#import "@preview/materia:0.1.0": bz-figure, band-axis, band-panel
#import "@preview/scenery:0.1.0": default-theme, render-scene

// --- document language -----------------------------------------------------

#let ink = rgb("#182536")
#let muted = rgb("#5d6875")
#let navy = rgb("#244765")
#let blue = rgb("#6485a6")
#let blue-pale = rgb("#edf3f8")
#let copper = rgb("#b96d45")
#let copper-pale = rgb("#fbf1eb")
#let green = rgb("#477a70")
#let rule = rgb("#ccd5dc")
#let panel = rgb("#f7f9fa")

#set page(
  paper: "a4",
  margin: (x: 1.55cm, top: 1.35cm, bottom: 1.45cm),
  numbering: "1",
  number-align: right,
)
#set text(font: "New Computer Modern", size: 9.2pt, fill: ink)
#set par(justify: true, leading: 0.62em)
#set heading(numbering: none)
#show heading: set block(above: 0.8em, below: 0.4em)
#show link: set text(fill: navy)
#show raw.where(block: true): set text(size: 7.6pt)
#show raw.where(block: false): it => box(
  fill: rgb("#edf0f2"),
  inset: (x: 2.5pt, y: 0.5pt),
  radius: 2pt,
  it,
)

#let card(body, fill: panel, stroke: rule, inset: 9pt) = block(
  width: 100%,
  breakable: false,
  fill: fill,
  stroke: 0.55pt + stroke,
  radius: 4pt,
  inset: inset,
  body,
)

#let tag(body, fill: navy) = box(
  fill: fill,
  radius: 2pt,
  inset: (x: 5pt, y: 2pt),
  text(size: 6.8pt, weight: "bold", fill: white, tracking: 0.06em, body),
)

#let page-title(kicker, title, deck) = block[
  #tag(kicker)
  #v(5pt)
  #text(size: 22pt, weight: "bold", tracking: -0.02em)[#title]
  #v(3pt)
  #text(size: 10.2pt, fill: muted)[#deck]
  #v(8pt)
  #line(length: 100%, stroke: 0.8pt + rule)
  #v(7pt)
]

#let key-value(key, value) = grid(
  columns: (1fr, auto),
  column-gutter: 6pt,
  text(size: 7.7pt, weight: "bold", fill: muted, key),
  text(size: 7.7pt, value),
)

#let source-link(n, url) = link(url)[#super[#n]]

// --- shared scientific data ------------------------------------------------

#let a = 3.905
#let lattice = (a: a)
#let path = ("Γ", "X", "M", "Γ", "R", "X")
#let samples = 24
#let atom-colors = (
  Sr: blue,
  Ti: rgb("#9199a2"),
  O: rgb("#cec857"),
)
#let ti-o-bonds = ((elements: ("Ti", "O"), max: 2.2),)
#let srtio3 = prototypes.perovskite("Sr", "Ti", "O", a: a)

// A scene is plain data and can be rendered directly with scenery.
#let unit-scene = crystal-scene(
  srtio3,
  bonds: ti-o-bonds,
  polyhedra: ("Ti",),
  colors: atom-colors,
  view: (azimuth: 45deg, elevation: 45deg),
)

// Sample the conventional primitive-cubic path. materia computes the Cartesian
// reciprocal coordinates and cumulative distances used by the band panel.
#let axis = band-axis("cP", lattice, path, samples: samples)

// Analytic illustration data. These functions encode VBM(R)=0 eV,
// CBM(Gamma)=3.25 eV, and a direct Gamma gap of 3.75 eV along this path.
#let structure-factor(k) = (
  calc.cos(k.at(0) * a)
    + calc.cos(k.at(1) * a)
    + calc.cos(k.at(2) * a)
)
#let valence-top(k) = -(3 + structure-factor(k)) / 12
#let conduction-bottom(k) = 3.25 + (3 - structure-factor(k)) / 20

#let vb-1 = axis.carts.map(valence-top)
#let vb-2 = axis.carts.map(k => valence-top(k) - 0.32 - 0.05 * calc.cos(k.at(2) * a))
#let vb-3 = axis.carts.map(k => valence-top(k) - 0.67 + 0.04 * calc.cos(k.at(0) * a))
#let cb-1 = axis.carts.map(conduction-bottom)
#let cb-2 = axis.carts.map(k => conduction-bottom(k) + 0.28 + 0.04 * calc.cos(k.at(1) * a))
#let cb-3 = axis.carts.map(k => conduction-bottom(k) + 0.58 - 0.05 * calc.cos(k.at(2) * a))
#let bands = (vb-1, vb-2, vb-3, cb-1, cb-2, cb-3)

#let band-theme = default-theme + (palette: (
  rgb("#b9633f"), rgb("#d08763"), rgb("#8d4b35"),
  rgb("#315f82"), rgb("#5d8cab"), rgb("#223f59"),
),)

// --- page 1: real space ----------------------------------------------------

#page-title(
  [01 · REAL SPACE],
  [SrTiO#sub[3], from formula to framework],
  [A three-page introduction built entirely in Typst with #raw("materia") and #raw("scenery").],
)

#grid(
  columns: (1.16fr, 0.84fr),
  column-gutter: 0.7cm,
  align: top,
  [
    #align(center, crystal(
      srtio3,
      bonds: ti-o-bonds,
      polyhedra: ("Ti",),
      colors: atom-colors,
      labels: true,
      width: 8.8cm,
    ))
    #v(2pt)
    #align(center)[
      #text(size: 7.7pt, fill: muted)[
        Cubic reference cell: Ti--O bonds, TiO#sub[6] coordination,
        crystallographic axes, and element legend.
      ]
    ]
  ],
  [
    #card(fill: blue-pale)[
      #text(size: 11pt, weight: "bold")[The room-temperature reference]
      #v(4pt)
      Cubic SrTiO#sub[3] is the archetypal #emph[ABO#sub[3]] perovskite. In the
      conventional description, Sr occupies the cube corners, Ti the body
      centre, and O the face centres. The TiO#sub[6] octahedra meet at their
      corners to form a three-dimensional framework.
      #v(7pt)
      #key-value([Space group], [$P m overline(3) m$ (No. 221)])
      #key-value([Lattice], [primitive cubic])
      #key-value([Parameter], [#a Å])
      #key-value([Formula units], [1 per cell])
    ]
    #v(7pt)
    #card(fill: white)[
      #text(size: 9.5pt, weight: "bold")[Wyckoff construction]
      #v(4pt)
      #table(
        columns: (0.65fr, 0.52fr, 1.45fr),
        inset: (x: 3pt, y: 2.6pt),
        stroke: (x: none, y: 0.35pt + rule),
        align: (left, center, left),
        table.header(
          text(size: 7pt, weight: "bold", fill: muted)[Atom],
          text(size: 7pt, weight: "bold", fill: muted)[Site],
          text(size: 7pt, weight: "bold", fill: muted)[Representative],
        ),
        [Sr], [1a], [#text(size: 7pt)[$(0,0,0)$]],
        [Ti], [1b], [#text(size: 7pt)[$(1/2,1/2,1/2)$]],
        [O], [3c], [#text(size: 7pt)[$(1/2,1/2,0)$]],
      )
      #v(4pt)
      #text(size: 7.5pt, fill: muted)[
        #raw("prototypes.perovskite") expands these three sites into the five
        atoms of the conventional cubic cell.
      ]
    ]
  ],
)

#v(9pt)
#grid(
  columns: (1fr, 1.08fr),
  column-gutter: 0.7cm,
  align: top,
  [
    #card(fill: copper-pale)[
      #tag(fill: copper)[CRYSTAL FIGURE]
      #v(5pt)
      ```typ
      #crystal(
        srtio3,
        bonds: ti-o-bonds,
        polyhedra: ("Ti",),
        colors: atom-colors,
        labels: true,
        width: 8.8cm,
      )
      ```
      #v(3pt)
      #text(size: 7.3pt, fill: muted)[
        The structure, bond rule, and colours are ordinary Typst values reused
        by the unit-cell and supercell views.
      ]
    ]
  ],
  [
    #align(center, crystal(
      srtio3,
      supercell: (2, 2, 1),
      view: (azimuth: 34deg, elevation: 25deg),
      bonds: ti-o-bonds,
      polyhedra: ("Ti",),
      colors: atom-colors,
      legend: false,
      axes: false,
      width: 6.3cm,
    ))
    #align(center)[#text(size: 7.5pt, fill: muted)[
      A $2 times 2 times 1$ supercell exposes the corner-sharing octahedral network.
    ]]
  ],
)

#v(8pt)
#card(fill: white, stroke: copper)[
  #text(weight: "bold", fill: copper)[Reference structure, not the zero-temperature phase.]
  Below about 105--110 K, SrTiO#sub[3] undergoes an antiferrodistortive transition
  to a tetragonal structure driven by rotations of the TiO#sub[6] octahedra.
  The cubic cell above is the high-symmetry reference used throughout this
  introduction.#source-link(1, "https://doi.org/10.1103/PhysRev.177.858")
]

// --- page 2: reciprocal and electronic space ------------------------------

#pagebreak(weak: false)
#page-title(
  [02 · RECIPROCAL + ELECTRONIC SPACE],
  [One periodicity, two complementary views],
  [The lattice determines the Brillouin zone. Energies require a model or calculation.],
)

#grid(
  columns: (0.78fr, 1.22fr),
  column-gutter: 0.65cm,
  align: top,
  [
    #card(fill: blue-pale)[
      #tag[COMPUTED GEOMETRY]
      #v(6pt)
      #align(center, bz-figure(
        lattice,
        bravais: "cP",
        path: path,
        highlight: ("Γ", "R"),
        view: (azimuth: 32deg, elevation: 20deg),
        width: 6.0cm,
      ))
      #align(center)[#text(size: 7.4pt, fill: muted)[
        First Brillouin zone of the primitive-cubic lattice.
        Gold markers identify Γ and R.
      ]]
    ]
  ],
  [
    #card(fill: copper-pale, stroke: rgb("#e0c5b7"))[
      #grid(
        columns: (1fr, auto),
        [#tag(fill: copper)[SUPPLIED BANDS]],
        text(size: 7pt, weight: "bold", fill: copper)[SCHEMATIC · eV],
      )
      #v(7pt)
      #align(center, band-panel(
        bands,
        axis,
        width: 9.1cm,
        height: 5.7cm,
        theme: band-theme,
      ))
      #v(3pt)
      #grid(
        columns: (1fr, 1fr),
        column-gutter: 8pt,
        [
          #text(size: 7.6pt, weight: "bold", fill: copper)[O 2p valence edge]
          #line(length: 18pt, stroke: 1.5pt + rgb("#b9633f"))
          #text(size: 7pt, fill: muted)[maximum at R: 0 eV]
        ],
        [
          #text(size: 7.6pt, weight: "bold", fill: navy)[Ti 3d $t_(2g)$ conduction edge]
          #line(length: 18pt, stroke: 1.5pt + rgb("#315f82"))
          #text(size: 7pt, fill: muted)[minimum at Γ: 3.25 eV]
        ],
      )
    ]
  ],
)

#v(10pt)
#grid(
  columns: (1fr, 1fr, 1fr),
  column-gutter: 7pt,
  [#card(fill: white)[
    #text(size: 7pt, weight: "bold", fill: muted)[PATH]
    #v(2pt)
    #text(size: 12pt, weight: "bold")[$Γ dash X dash M dash Γ dash R dash X$]
    #v(3pt)
    #text(size: 7.5pt, fill: muted)[Five connected segments; 24 sub-intervals each.]
  ]],
  [#card(fill: white)[
    #text(size: 7pt, weight: "bold", fill: muted)[INDIRECT GAP]
    #v(2pt)
    #text(size: 12pt, weight: "bold", fill: green)[$R arrow Γ quad approx 3.25 upright("eV")$]
    #v(3pt)
    #text(size: 7.5pt, fill: muted)[VBM and CBM occur at different k-points.]
  ]],
  [#card(fill: white)[
    #text(size: 7pt, weight: "bold", fill: muted)[DIRECT Γ GAP]
    #v(2pt)
    #text(size: 12pt, weight: "bold")[$approx 3.75 upright("eV")$]
    #v(3pt)
    #text(size: 7.5pt, fill: muted)[Shown here to distinguish direct and indirect transitions.]
  ]],
)

#v(10pt)
#grid(
  columns: (1fr, 1fr),
  column-gutter: 0.7cm,
  align: top,
  [
    == What #raw("materia") determines

    From $a$, the package constructs direct vectors, reciprocal vectors using
    the $2 pi$ convention, and their Wigner--Seitz cell. The tabulated cP
    high-symmetry points are converted to Cartesian reciprocal coordinates;
    #raw("band-axis") then samples the same connected path drawn on the zone.
  ],
  [
    == What the document supplies

    The six coloured curves are analytic functions evaluated at those sampled
    k-points. They encode literature-guided landmarks---an R-point valence
    maximum dominated by O 2p states and a Γ-point Ti 3d $t_(2g)$ conduction
    minimum---but are not density-functional or experimental bands.
    The gap values follow the comparison summarized by Janotti _et al._#source-link(2, "https://doi.org/10.1103/PhysRevB.84.201304")
  ],
)

#v(8pt)
#card(fill: blue-pale)[
  #text(weight: "bold", fill: navy)[The distinction is the point.]
  Geometry and visualization can be reproducible without pretending that a
  drawing package is an electronic-structure solver. Replace #raw("bands") with
  arrays from your own calculation; the zone, path distances, ticks, and scene
  composition remain unchanged.
]

// --- page 3: provenance and reproducibility -------------------------------

#pagebreak(weak: false)
#page-title(
  [03 · REPRODUCIBILITY],
  [Know which layer owns each claim],
  [Plain dictionaries keep the path from crystallographic input to final vector figure inspectable.],
)

#grid(
  columns: (1fr, auto, 1fr, auto, 1fr),
  column-gutter: 6pt,
  align: horizon,
  card(fill: blue-pale, inset: 7pt)[
    #text(size: 7pt, weight: "bold", fill: muted)[INPUT]
    #v(2pt)
    space group + Wyckoff sites
  ],
  text(size: 15pt, fill: muted)[$arrow$],
  card(fill: white, inset: 7pt)[
    #text(size: 7pt, weight: "bold", fill: muted)[MATERIA]
    #v(2pt)
    expanded atoms + bonds + polyhedra
  ],
  text(size: 15pt, fill: muted)[$arrow$],
  card(fill: copper-pale, inset: 7pt)[
    #text(size: 7pt, weight: "bold", fill: muted)[SCENERY]
    #v(2pt)
    primitives + camera + vector render
  ],
)

#v(7pt)
#grid(
  columns: (1fr, auto, 1fr, auto, 1fr),
  column-gutter: 6pt,
  align: horizon,
  card(fill: blue-pale, inset: 7pt)[
    #text(size: 7pt, weight: "bold", fill: muted)[INPUT]
    #v(2pt)
    lattice parameter + Bravais type
  ],
  text(size: 15pt, fill: muted)[$arrow$],
  card(fill: white, inset: 7pt)[
    #text(size: 7pt, weight: "bold", fill: muted)[MATERIA]
    #v(2pt)
    reciprocal basis + Wigner--Seitz cell
  ],
  text(size: 15pt, fill: muted)[$arrow$],
  card(fill: copper-pale, inset: 7pt)[
    #text(size: 7pt, weight: "bold", fill: muted)[USER DATA]
    #v(2pt)
    sampled energies on #raw("band-axis")
  ],
)

#v(10pt)
#card(fill: white)[
  #grid(
    columns: (1.2fr, 0.8fr),
    column-gutter: 10pt,
    align: horizon,
    [
      #tag[SCENE AS DATA]
      #v(5pt)
      ```typ
      #let scene = crystal-scene(
        srtio3,
        bonds: ti-o-bonds,
        polyhedra: ("Ti",),
        colors: atom-colors,
      )

      #render-scene(scene, scene.camera, width: 4.2cm)
      ```
    ],
    [
      #align(center, render-scene(unit-scene, unit-scene.camera, width: 4.2cm))
      #align(center)[#text(size: 7.2pt, fill: muted)[
        A scene dictionary rendered directly through #raw("scenery").
      ]]
    ],
  )
]

#v(10pt)
== Computed, tabulated, and supplied

#table(
  columns: (1fr, 1.15fr, 1.55fr),
  inset: (x: 5pt, y: 4pt),
  stroke: 0.4pt + rule,
  fill: (_, row) => if row == 0 { navy } else if calc.even(row) { panel } else { white },
  align: (left, left, left),
  table.header(
    text(size: 7.5pt, weight: "bold", fill: white)[Layer],
    text(size: 7.5pt, weight: "bold", fill: white)[Owned here],
    text(size: 7.5pt, weight: "bold", fill: white)[Not implied],
  ),
  [#raw("materia")], [symmetry expansion; bonds; coordination; reciprocal cell; sampled path], [no relaxation, phonons, orbitals, or eigenvalues],
  [path convention], [named cP points and recommended segments], [no claim that this is the only useful path],
  [this document], [colours; camera; six analytic energy curves; annotations], [no calculated SrTiO#sub[3] band structure],
  [literature], [phase transition, band-edge character, gap landmarks], [no reproduction of the cited calculations],
)

#v(10pt)
#grid(
  columns: (1.08fr, 0.92fr),
  column-gutter: 0.7cm,
  align: top,
  [
    #card(fill: copper-pale, stroke: rgb("#e0c5b7"))[
      #text(size: 10pt, weight: "bold", fill: copper)[Why SrTiO#sub[3] remains interesting]
      #v(4pt)
      The octahedral rotation is only one instability. SrTiO#sub[3] also lies
      close to a ferroelectric phase: its soft polar mode is stabilized by
      quantum fluctuations, making the material a canonical quantum
      paraelectric.#source-link(3, "https://doi.org/10.1103/PhysRevB.104.L060103")
      The present figures provide the structural stage on which those lattice
      dynamics act; a phonon calculation would supply the missing frequencies
      and eigenvectors.
    ]
  ],
  [
    #card(fill: blue-pale)[
      #text(size: 9pt, weight: "bold", fill: navy)[Regression contracts]
      #v(4pt)
      #text(size: 7.7pt)[
        ✓ five expanded atoms\
        ✓ Pm$overline(3)$m space group\
        ✓ 121 path samples\
        ✓ equal band-array lengths\
        ✓ VBM at R, CBM at Γ\
        ✓ indirect gap = 3.25 eV
      ]
      #v(3pt)
      #text(size: 6.9pt, fill: muted)[Checked by #raw("tests/test-srtio3-showcase.typ").]
    ]
  ],
)

#v(10pt)
#line(length: 100%, stroke: 0.6pt + rule)
#v(5pt)
#text(size: 7.2pt, fill: muted)[
  *Primary sources.*
  [1] G. Shirane and Y. Yamada, _Phys. Rev._ *177*, 858 (1969).
  [2] A. Janotti, D. Steiauf, and C. G. Van de Walle, _Phys. Rev. B_ *84*, 201304(R) (2011).
  [3] D. Shin _et al._, _Phys. Rev. B_ *104*, L060103 (2021).
]
