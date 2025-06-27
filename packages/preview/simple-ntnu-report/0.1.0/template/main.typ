#import "@preview/simple-ntnu-report:0.1.0": ntnu-report
#import "@preview/zero:0.3.3": num

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

  front-image: image("figures/NTNU.svg"),
  date: datetime.today(),

  abstract: include "content/sammendrag.typ",
  bibfile: bibliography("ref.bib"),
  bibstyle: "institute-of-electrical-and-electronics-engineers",

  language: "bokmål",
  column_number: 2,
  
  show_toc: true,
  show_figure_index: false,
  show_table_index: false,
)


= Innhold
Innholdet kan skrives enten direkte her eller i egne filer, husk å formatere tall med `num`, slik som $pi = e = num(3.0) approx 1$ for å få desimaltegn riktig.
