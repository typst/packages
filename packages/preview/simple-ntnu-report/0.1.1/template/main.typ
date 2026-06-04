#import "@preview/simple-ntnu-report:0.1.1": ntnu-report, un
#import "@preview/zero:0.5.0": num

#show: ntnu-report.with(
  length: "short",
  watermark: "Typstmal",

  title: "Typst mal",
  subtitle: "En mal tiltenkt bruk ved NTNU",
  authors: (
    (
      name: "Per Askeladden",
      department: [ITK],
      organization: [NTNU],
      location: [Skævven]
    ),
    (
      name: "Pål Askeladden",
    ),
    (
      name: "Espen Askeladden",
      location: [Slottet til Kongen],
      email: "espen@askeladden.no"
    ),
  ),
  group: "1",

  front-image: image("figures/NTNU.svg", width: 6cm),
  date: datetime.today(),

  abstract: include "content/sammendrag.typ",
  appendices: include "content/appendix.typ",
  bibfile: bibliography("ref.bib"),
  bibstyle: "institute-of-electrical-and-electronics-engineers",

  language: "bokmål",
  column-number: 2,

  number-headings: true,
  
  show-toc: true,
  show-figure-index: false,
  show-table-index: false,
  show-listings-index: false,
)


= Innhold <sec:innhold>
Innholdet kan skrives enten direkte her eller i egne filer, husk å formatere tall med `num`, slik som $pi = e = num(3.0) approx 1$ for å få desimaltegn riktig.
Husk og at enheter, slik som $5 un(V m/s)$, 

Kryssreferanser til @sec:innhold og @ap:likninger kan gjøres enkelt og greit.
