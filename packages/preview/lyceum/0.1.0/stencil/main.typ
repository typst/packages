// #import "@preview/lyceum:0.1.0": FRONT-MATTER
#import "@preview/lyceum:0.1.0": FRONT-MATTER, BODY-MATTER, APPENDIX, BACK-MATTER

#let TEXT-SIZE = 11pt

//----------------------------------------------------------------------------//
//                                FRONT-MATTER                                //
//----------------------------------------------------------------------------//

#show: FRONT-MATTER.with(
  // Document metadata
  title: (
    title: "Igneous Rocks",
    subtitle: "The Hard Science",
    sep: " - "
  ),
  authors: (
    (
      given-name: "Evelyn D.",
      name: "Crump",
      affiliation: "Rocks Hard Research Group",
      email: "crumped@rockshard.org.far",
      location: "Rich Mines, Faraway Country",
    ), (
      preffix: "Sir.",
      given-name: "Effie J.",
      name: "Hitchcock",
      suffix: "Jr.",
      affiliation: "Hard University",
      email: "hitchcockej@hard.edu.far",
      location: "Rockbridge, Faraway Country",
    ),
  ),
  editors: ("Cenhelm, Erwin", ),
  publisher: "Lyceum Publisher",
  location: "Lyceum City, Faraway Country",
  affiliated: (
    illustrator: ("Revaz Sopheap", ),
    organizer: "Darko Sergej",
  ),
  keywords: ("igneous", "rocks", "geology", ),
  date: datetime(year: 2024, month: 9, day: 13), // auto => datetime.today()
  // Document general format
  page-size: (width: 155mm, height: 230mm),
  page-margin: (inside: 30mm, rest: 25mm),
  page-binding: left,
  page-fill: color.hsl(45deg, 15%, 85%),  // ivory
  text-font: ("EB Garamond", "Libertinus Serif"),
  text-size: TEXT-SIZE,
  lang-name: "en",
)

// The lyceum auto-generates the title page

= Preface

Here goes the book preface. #lorem(50)

// Show rule for the outline
#show outline.entry.where(
  level: 1
): it => {
  v(12pt, weak: true)
  strong(it)
}


= Contents

#outline(
  title: none,
  target: heading.where(level: 1),
  indent: auto,
)


//----------------------------------------------------------------------------//
//                                BODY-MATTER                                 //
//----------------------------------------------------------------------------//

#show: BODY-MATTER.with(TEXT-SIZE, "Chapter", ship-part-page: false)

= Introduction

#lorem(520)

$ e = m c^2 $

== Sub-Section

#lorem(530)

== Sub-Section

#lorem(530)

= Methodology

#lorem(750)

== Sub-Section

#lorem(730)


//----------------------------------------------------------------------------//
//                                  APPENDIX                                  //
//----------------------------------------------------------------------------//

#show: APPENDIX.with(TEXT-SIZE, "Appendix", ship-part-page: true)

= Tables of Properties

#lorem(50)


//----------------------------------------------------------------------------//
//                                BACK-MATTER                                 //
//----------------------------------------------------------------------------//

#show: BACK-MATTER.with(TEXT-SIZE, ship-part-page: false)

= Citing This Book

The following is the _auto-generated_, self bibliography database entry for the *`hayagriva`*
manager:

#block(width: 100%)[
  #let self-bib = context query(<self-bib-entry>).first().value
  #set par(leading: 0.5em)
  #text(font: "Inconsolata", size: 9pt, weight: "bold")[
    #self-bib
  ]
]


