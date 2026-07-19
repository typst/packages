#import "@preview/definitely-not-isec-slides:1.1.0": *

#show: definitely-not-isec-theme.with(
  aspect-ratio: "16-9",
  slide-alignment: top,
  progress-bar: true,
  institute: [isec.tugraz.at],
  logo: [#tugraz-logo],
  config-info(
    title: [Long Paper Title \ with One to Three Lines],
    subtitle: [An optional short subtitle],
    authors: ([*First Author*], [Second Author], [Third Author]),
    extra: [SomeConf 2026],
    footer: [First Author, Second Author, Third Author #h(1fr) `firstname.lastname@tugraz.at`],
    download-qr: "",
  ),
  config-common(
    handout: false,
  ),
  config-colors(
    primary: rgb("e4154b"),
  ),
)

// -------------------------------[[ CUT HERE ]]--------------------------------
//
// === Available slides ===
//
// #title-slide()
// #standout-slide(title)
// #section-slide(title,subtitle)
// #section-slide-icon(title,icon)
// #blank-slide() 
// #slide(title)
//
// === Available macros ===
//
// #quote-block(body)
// #cblock(title: [Title], icon: "check", body)
// #split[Column 1][Column 2][...][Column N]
// #ticon("user-circle") // When preceding text "text-icon"
// #icon("user-square")  // For figures or similar 
//
// === Presenting with pdfpc ===
//
// Use #note("...") to add pdfpc presenter annotations on a specific slide
// Before presenting, export all notes to a pdfpc file:
// $ typst eval --in slides.typ "query(<pdfpc-file>).first().value" > slides.pdfpc 
// $ pdfpc slides.pdf
//
// -------------------------------[[ CUT HERE ]]--------------------------------

#title-slide()

#slide(title: [First Slide])[
  #quote-block[
    Use this block for a clear statement about the core concept of the slide
  ]

  Then, you can decompose the idea or present graphics @emg26template:

  #split[
    #cblock(title: [Advantages])[
      - A
      - B
      - C
    ]
  ][
    #cblock(title: [Disadvantages])[
      - A
      - B
      - C
    ]
  ]

  // #align(center)[
  //   // Install https://github.com/tabler/tabler-icons (MIT Licensed) and reference https://tabler.io/icons
  //   #ticon("flame") You can also use icons #ticon("flame")
  // ]

  Furthermore, you can add inline _`pdfpc`_ notes.#note("Here I am!")
]

#slide(title: [Bibliography])[
  #bibliography("bibliography.bib")
]
