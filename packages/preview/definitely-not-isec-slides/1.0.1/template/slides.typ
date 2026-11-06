#import "@preview/definitely-not-isec-slides:1.0.1": *

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
    extra: [SomeConf 2025],
    footer: [First Author, Second Author, Third Author],
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
// #blank-slide()
// #slide(title)
//
// === Available macros ===
//
// #quote-block(body)
// #color-block(title, body)
// #icon-block(title, icon, body)
//
// === Presenting with pdfpc ===
//
// Use #note("...") to add pdfpc presenter annotations on a specific slide
// Before presenting, export all notes to a pdfpc file:
// $ typst query slides.typ --field value --one "<pdfpc-file>" > slides.pdfpc
// $ pdfpc slides.pdf
//
// -------------------------------[[ CUT HERE ]]--------------------------------
 
#title-slide()

#slide(title: [First Slide])[
  #quote-block[
    Good luck with your presentation! @emg25template
  ]

  #note("This will show on pdfpc speaker notes ;)")
]

#slide(title: [Bibliography])[
  #bibliography("bibliography.bib")
]
