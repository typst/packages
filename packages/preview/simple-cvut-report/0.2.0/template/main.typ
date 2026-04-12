#import "../lib.typ": report

#set text(
  lang: "cs",
  region: "cz",
  size: 12pt,
)

#show: report.with(
  title: "Semestrální práce",
  subtitle: "Dokumentace",
  author: "Jan Novák",
  username: "novakja2",
  toc-title: "Obsah",
  branch: "Obor Softwarové inženýrství a technologie",
  date: "Květen 2026",
  logo: image("assets/cvut-logo.svg"),
  bib: none, // e.g. bibliography("bib.yaml", style: "the-lancet")
)

// Overwrites here...

= Úvod
#lorem(67)

// TODO some actual text
