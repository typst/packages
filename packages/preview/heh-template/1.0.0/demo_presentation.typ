#import "/lib.typ": (
  campus, config, heh-presentation, important, info, slide, slidegroup,
)

#import "@preview/polylux:0.4.0": item-by-item, one-by-one, uncover
#import "@preview/mmdr:0.2.2": mermaid
#import "@preview/cetz:0.5.2"
#import "@preview/cetz-plot:0.1.3"

#show: heh-presentation.with(
  document-config-fn: config.default-document-config.with(
    title: "Présentation du HEH-Template",
    description: "Présentation de démonstration de HEH-Template",
    formation: none,
    orientation: none,
    authors: (
      ("Contributeurs de HEH-Template", ""),
    ),
  ),
  print-config-fn: config.default-print-config.with(
    monochrome: "monochrome" in sys.inputs and sys.inputs.monochrome == "true",
  ),
  campus-config-fn: campus.dst-config,
)

#slidegroup("Introduction au template")[
  #slide[
    == Les tableaux

    #show: align.with(center)

    #table(
      columns: 3,
      table.header([*ID*], [*E-Mail*], [*Nom*]),
      [1], [john.doe\@heh.be], [John Doe],
      [2], [john.doe\@heh.be], [John Doe],
    )
  ]

  #slide[
    == Boites

    #info[
      Vous pouvez faire des informations sur vos slides!
    ]

    #important[
      N'oubliez pas d'utiliser le handout mode pour publier vos présentations en supprimant les animations
    ]
  ]
]

#slidegroup("Exemples")[
  #slide[
    == Mathématiques

    === Formules de Carnot

    #item-by-item[
      - $cos(a)^2 = frac(1 + cos(2a), 2)$
      - $sin(a)^2 = frac(1 - cos(2a), 2)$
      - $tan(a)^2 = frac(1 - cos(2a), 1 + cos(2a))$
    ]

    #one-by-one(start: 4)[
      === Formules de simpson

      #item-by-item(start: 5)[
        - $cos(a) + cos(b) = 2cos((a + b) / 2) cos((a - b) / 2)$
        - $cos(a) - cos(b) = -2sin((a + b) / 2) sin((a - b) / 2)$
        - $tan(a) + tan(b) = sin(a + b) / (cos(a) cos(b))$
      ]
    ]
  ]

  #slide[
    #show: align.with(horizon)

    == Diagrammes avec Mermaid

    #mermaid(
      "gitGraph
    commit id: \"Initial commit\"
    branch feat/add-presentations
    checkout feat/add-presentations
    commit id: \"feat: Ajout du support des présentations\"
    commit id: \"feat: Ajout du support du handout-mode\"
    checkout main
    merge feat/add-presentations
    commit
    commit
    ",
    )
  ]

  #slide[
    #show: align.with(center + horizon)
    == Graphiques avec CETZ

    #cetz.canvas({
      import cetz.draw: *
      import cetz-plot: *

      plot.plot(
        size: (10, 5),
        x-tick-step: calc.pi,
        y-tick-step: 1,
        plot.add(
          domain: (-2 * calc.pi, 2 * calc.pi),
          x => calc.sin(x),
        ),
      )
    })
  ]
]

