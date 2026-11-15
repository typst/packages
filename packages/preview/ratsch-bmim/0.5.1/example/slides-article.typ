#import "./preamble.typ": *

// The same slides as in slides-longTitle.typ, rendered as an article in the
// layout of the report variant. Alternatively, choose the mode when
// compiling: typst compile slides-longTitle.typ --input export-mode=article
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
  bib-as-footnote: false,
  handout: false,
  article-mode: true,
  // variant of the document: "report" (default), "article", "lecture" or a
  // function, e.g. info => bmim.workbook(course: info.title, authors: info.authors);
  // an own title block is given with titleblock: args => [..]
  article-variant: "report",
  notes: none,
  logo: (
    left: pad(
      top: -8.0pt,
      left: 21pt,
      image("./../assets/logo_lfui_color_invert.png", height: 30pt)
    ),
    title-left: pad(
      top: -1.0pt,
      image("./../assets/logo_lfui_color_invert.png", height: 48pt)
    ),
  ),
)

#include "content/slides.typ"
