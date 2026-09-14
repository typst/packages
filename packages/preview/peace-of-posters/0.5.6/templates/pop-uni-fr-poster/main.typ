#import "@preview/peace-of-posters:0.5.6" as pop

#set page("a0", margin: 1cm)
#pop.set-poster-layout(pop.layout-a0)
#pop.set-theme(pop.uni-fr)
#set text(size: pop.layout-a0.at("body-size"))
#let box-spacing = 1.2em
#set columns(gutter: box-spacing)
#set block(spacing: box-spacing)
#pop.update-poster-layout(spacing: box-spacing)

#pop.title-box(
  "Peace of Posters Template",
  authors: "Jonas Pleyer¹",
  institutes: "¹Freiburg Center for Data-Analysis and Modelling",
  keywords: "Peace, Dove, Poster, Science",
  logo: circle(image("peace-dove.png"), fill: white, inset: -10pt),
)

#columns(2,[
  #pop.column-box(heading: "Columbidae")[
    'Columbidae is a bird family consisting of doves and pigeons.
    It is the only family in the order Columbiformes.'
    #cite(<wiki:Columbidae>)

    #figure(caption: [
      Pink-necked green pigeon #cite(<wiki:File:Treron_vernans_male_-_Kent_Ridge_Park.jpg>).
    ])[
      #image("Treron_vernans_male_-_Kent_Ridge_Park.jpg", width: 40%)
    ]
  ]

  // These properties will be given to the function which is responsible for creating the heading
  #let hba = pop.uni-fr.heading-box-args
  #hba.insert("stroke", (paint: gradient.linear(green, red, blue), thickness: 10pt))

  // and these are for the body.
  #let bba = pop.uni-fr.body-box-args
  #bba.insert("inset", 30pt)
  #bba.insert("stroke", (paint: gradient.linear(green, red, blue), thickness: 10pt))

  #pop.column-box(
    heading: "Biological Information",
    heading-box-args: hba,
    body-box-args: bba,
  )[
    #table(
      columns: (auto, 1fr),
      inset: 0.5cm,
      stroke: (x, y) => if y >= 0 {(bottom: 0.2pt + black)},
      [Domain],[Eukaryota],
      [Kingdom],[Animalia],
      [Phylum],[Chordata],
      [Class],[Aves],
      [Clade],[Columbimorphae],
      [Order],[Columbiformes],
      [Family],[Columbidae],
      [Type genus],[Columba],
    )

    This box is styled differently compared to the others.
    To make such changes persistent across the whole poster, we can use these functions:
    ```typst
    #pop.update-poster-layout(...)
    #pop.update-theme()
    ```
  ]

  #pop.column-box(heading: "Peace of Posters Documentation")[
    You can find more information on the documentation site under
    #text(fill: red)[
      #link("https://jonaspleyer.github.io/peace-of-posters/")[
        jonaspleyer.github.io/peace-of-posters/
      ]
    ].

    #figure(caption: [
      The poster from the thumbnail can be viewed at the documentation website as well.
    ])[
      #link("https://jonaspleyer.github.io/peace-of-posters/")[
        #image("thumbnail.png", width: 50%)
      ]
    ]
  ]

  #colbreak()

  #pop.column-box(heading: "General Relativity")[
    Einstein's brilliant theory of general relativity
    starts with the field equations #cite(<Einstein1916>).
    $ G_(mu nu) + Lambda g_(mu nu) = kappa T_(mu nu) $
    However, they have nothing to do with doves.
  ]

  #pop.column-box(heading: "Peace be with you")[
    #figure(caption: [
      'Doves [...] are used in many settings as symbols of peace, freedom or love.
      Doves appear in the symbolism of Judaism, Christianity, Islam and paganism, and of both
      military and pacifist groups.'
      #cite(<wiki:Doves_as_symbols>).
    ])[
      #image("peace-dove.png")
    ]
  ]

  #pop.column-box(heading: "Etymology")[
    Pigeon is a French word that derives from the Latin pīpiō, for a 'peeping' chick,
    while dove is an ultimately Germanic word, possibly referring to the bird's diving flight.
    The English dialectal word culver appears to derive from Latin columba
    #cite(<wiki:Online_Etymology_Dictionary>).
    A group of doves is called a "dule", taken from the French word deuil ('mourning')
    @Lipton1991-qa.
  ]

  #pop.column-box()[
    #bibliography("bibliography.bib")
  ]

  #pop.column-box(heading: "Fill space with a box", stretch-to-next: true)[
    Notice that this box would not fill the entire space up to the bottom of the page but we
    can stretch it such that it does so anyway.
  ]
])

#pop.bottom-box()[
  Bottom Boxes are displayed at the bottom of a page.
  #linebreak()
  Download more RAM: #link("https://www.youtube.com/watch?v=dQw4w9WgXcQ")
]

