// Slides of slides-longTitle.typ as handout.
#import "./preamble.typ": *

#show: bmim.slides(
  title: (
    "Control design strategies for better results that take a quite a long title to explain what's really happening",
    "Control it better"
  ),
  subtitle: "Because reactions are bad",
  lang: "en",
  conference: "94th Conference of Applied Mathematics and Slide Care",
  institution: (
    [$zwj^(1)$Institut für Automatisierungs und Regelungstechnik, UMIT TIROL, Hall in Tirol, Österreich],
    [$zwj^(2)$Institut für Mechatronik, Universität Innsbruck, Innsbruck, Österreich],
  ),
  location: "Irgendwo",
  authors: (
    [#text(weight: "bold", size: 1.05em)[Jane Doe$zwj^(1)$]],
    [John Doel$zwj^(2)$],
    [John Doele$zwj^(2)$],
    [John Doeles$zwj^(2)$],
    [John Doel$zwj^(2)$],
    [John Doel$zwj^(2)$],
    [Max Mustermann$zwj^(1)$]
  ),
  authors-short: [Doel, Doele, Doeles, et al.],
  date: datetime(day: 31, month: 12, year: 2024),
  bib-as-footnote: true,
  // handout: animations (#pause, #uncover, ..) show only their final state, one
  // page per slide, e.g. for printing
  handout: true,
  notes: none,
  institute: none,
  progress-animation: (
    slides: true,
    section: true,
  ),
)

#include "content/slides.typ"
