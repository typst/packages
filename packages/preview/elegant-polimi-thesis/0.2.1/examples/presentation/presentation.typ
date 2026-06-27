#import "@preview/elegant-polimi-thesis:0.2.1": *
#import "@preview/touying:0.7.4": *

#show: polimi-digital-presentation.with(
  divider-style: "dark", // try "light"
  config-info(
    title: "Title of the Presentation",
    author: "Name Surname",
    subtitle: "01.01.2024\n#STEMintheCity2024",
    theme: "Theme",
    date: datetime.today(),
  ),
)

#title-slide(style: "default")

#title-slide(style: "white")

#title-slide(
  style: "logos",
  logos: (
    image("img/logo.svg", height: 3.5cm),
    "Lettering" + h(1.5cm),
  )
    * 4,
)

#title-slide(
  style: "background",
  background: image("img/background-style-image.svg"),
)

#make-outline()

= Chapter

== Title of a page\ only text

#text(size: 35pt)[
  Il Politecnico è un'università pubblica scientifico-tecnologica che\
  forma ingegneri, architetti e designer. Da sempre punta sulla qualità e\
  sull'innovazione della didattica e della ricerca, sviluppando un\
  rapporto fecondo con la realtà economica e produttiva attraverso\
  la ricerca sperimentale e il trasferimento tecnologico.

  La ricerca è sempre più legata alla didattica e costituisce un impegno\
  prioritario che consente al Politecnico di Milano di raggiungere\
  risultati\
  di alto livello internazionale e di realizzare l'incontro tra università e\
  mondo delle imprese. L'attività di ricerca costituisce, inoltre, un\
  percorso parallelo a quello della cooperazione e delle alleanze con il\
  sistema industriale.\
]

== Title

#exact-split-slide(
  splits: (
    [
      #heading(level: 3, numbering: none, "Title A")
      #lorem(40)
    ],
    [
      #heading(level: 3, numbering: none, "Title B")
      #lorem(40)
    ],
  ),
)

== Title

#exact-split-slide(
  splits: (
    [
      #heading(level: 3, numbering: none, "Title A")
      #lorem(40)
    ],
    [
      #heading(level: 3, numbering: none, "Title B")
      #lorem(40)
    ],
    [
      #heading(level: 3, numbering: none, "Title C")
      #lorem(40)
    ],
    [
      #heading(level: 3, numbering: none, "Title D")
      #lorem(40)
    ],
  ),
)

#slide(
  config: utils.merge-dicts(
    config-common(subslide-preamble: none),
    config-page(background: {
      set align(horizon)
      block(
        width: 100%,
        stroke: (
          top: rgb("#cdd6de"),
          bottom: rgb("#cdd6de"),
        ),
        move(dx: -29cm, circle(radius: 12cm, stroke: rgb("#cdd6de"))),
      )
    }),
  ),
  self => [
    #set align(horizon)
    #set text(weight: "light", size: 85pt, fill: self.colors.primary)
    Il Politecnico è un'università pubblica\
    scientifico-tecnologica che forma\
    ingegneri, architetti e designer.
  ],
)

#slide(
  config: utils.merge-dicts(
    config-common(
      subslide-preamble: none,
    ),
    config-page(background: {
      image("img/lab.png")
      place(
        top + left,
        block(width: 100%, height: 100%, fill: rgb("#022d56").transparentize(15%)),
      )
      place(
        top + left,
        {
          show: pad.with(top: 4.1cm)
          block(
            width: 100%,
            stroke: (
              top: rgb("#c0cbd5") + 0.75pt,
              bottom: rgb("#c0cbd5") + 0.75pt,
            ),
            align(center, circle(radius: 16cm, stroke: rgb("#c0cbd5") + 0.1pt)),
          )
        },
      )
    }),
  ),
  align(center + horizon, [
    #set text(white)
    #set text(size: 85pt, weight: 250)
    Una vita senza ricerca non è degna\
    per l'uomo d'esser vissuta.

    #set text(size: 33pt)
    Platone, Apologia di Socrate
  ]),
)


== Table title

#align(center + horizon, table(
  columns: 5,
  table.header([], [Column A], [Column B], [Column C], [Column D]),
  [Row 1], [1], [2], [3], [4],
  [Row 2], [5], [6], [7], [8],
  [Row 3], [9], [10], [11], [12],
))

== Table title

#split-slide(
  left: [
    #lorem(30)

    #lorem(30)
  ],
  right: [
    #align(center + horizon, table(
      columns: 5,
      table.header([], [Column A], [Column B], [Column C], [Column D]),
      [Row 1], [1], [2], [3], [4],
      [Row 2], [5], [6], [7], [8],
      [Row 3], [9], [10], [11], [12],
    ))
  ],
)

== Plot title

#align(center + bottom, image("img/infografica_2.svg"))

== Diagram title

#split-slide(
  left: [
    #lorem(20)
  ],
  right: [
    #align(center + horizon, image("img/torta.svg", height: 23.4cm))
  ],
)

== Plot title

#align(center + bottom, image("img/infografica_2.svg"))

== Plot title

#align(center + bottom, image("img/infografica_2.svg"))

#split-slide(
  left: [
    #lorem(20)
  ],
  right: [
    #align(
      center + horizon,
      image("img/infografica_2.svg"),
    )
  ],
)

#plot-slide[
  #grid(
    columns: (auto, 1fr, auto),
    text(
      size: 40pt,
      fill: white,
      "Example\ninfographic",
    ),
    block(),
    image(
      "img/infografica.png",
    ),
  )
]

== Title\ on multiple rows

#poli-slide(
  config: config-page(background: {
    place(
      top + right,
      {
        image("img/image_right.png", height: 35.4cm, width: 35.4cm)
        align(left, text(gray, "Testo"))
      },
    )
  }),
)[
  Conoscere il mondo dove si andrà a operare è requisito \
  indispensabile per la formazione degli studenti. Rapportarsi \
  alle esigenze del mondo produ ivo, industriale e della \
  pubblica amministrazione, aiuta la ricerca a percorrere \
  terreni nuovi e a confrontarsi con la necessità \
  di una costante e rapida innovazione.

  L'alleanza con il mondo industriale, in molti casi favorita \
  dalla Fondazione Politecnico e da consorzi partecipati \
  dal Politecnico, consente all'Ateneo di assecondare \
  la vocazione dei territori in cui opera e di essere da stimolo \
  per il loro sviluppo.
]

== Title\ on multiple rows

#split-slide(
  left: place(
    top + left,
    {
      v(1cm)
      grid(
        columns: (27cm, 36cm),
        inset: (x, _) => if x > 0 { (rest: 2cm, bottom: -8pt) } else { 0pt },
        move(
          dx: 3cm,
          image("img/image_left-1.png", height: 32cm, width: 24cm),
        ),
        [
          #text(
            size: 42pt,
            weight: "light",
            fill: rgb("#093157"),
            utils.display-current-heading(level: 2),
          )

          // #set text(size: 24pt)

          #lorem(30)

          #lorem(30)

          #set align(bottom)
          #set text(size: 16pt, fill: rgb("5e5e5eff"))

          Image caption
        ],
      )
    },
  ),
  config: config-common(subslide-preamble: none),
)

#background-slide(image: image("img/image_background.png"))

= Title of the divider

= Title of the divider

#focus-slide(
  lettering: "Here would be written the optional lettering.",
)[
  Thanks for listening.
]
