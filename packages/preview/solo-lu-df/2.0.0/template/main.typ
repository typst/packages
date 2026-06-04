#import "@preview/solo-lu-df:2.0.0": *

#show: ludf.with(
  title: "Darba Nosaukums",
  authors: (
    (
      name: "Jānis Bērziņš",
      code: "jb12345",
      location: [Riga, Latvia],
      email: "jb12345@edu.lu.lv",
    ),
    (
      name: "Zane Kalniņa",
      code: "zk67890",
      location: [Riga, Latvia],
      email: "zk67890@edu.lu.lv",
    ),
  ),
  advisors: (
    (
      title: "Prof. Dr. Phys.",
      name: "Anna Liepa",
    ),
  ),
  submission-date: datetime(
    year: 2025,
    month: 1,
    day: 1,
  ), // defaults to datetime.today()
  defense-date: datetime(
    year: 2025,
    month: 1,
    day: 15,
  ),
  place: "Rīga",
  bibliography: bibliography("bibliography.yml"),
  abstract: (
    primary: (
      text: [
        #lorem(50)

        #lorem(30)

        #lorem(20)
      ],
      keywords: (
        "Foo",
        "Bar",
        "Baz",
      ),
    ),
    secondary: (
      text: [
        #lorem(20)

        #lorem(30)

        #lorem(50)
      ],
      keywords: (
        "foo",
        "bar",
        "baz",
      ),
    ),
  ),
  description: [Some random document description that will be wisible in the metadata],
)


#set heading(numbering: none)
= Apzīmējumu saraksts
/ Docs: Typst dokumentācija.#footnote[https://typst.com/docs/]
/ Universe: Typst kopienas paketes un šabloni.#footnote[https://typst.app/universe/]

= Ievads
#lorem(100)@typst

#set heading(numbering: "1.")

= Nodaļas nosaukums
== Apakšnodaļas nosaukums
== Apakšnodaļas nosaukums
== Apakšnodaļas nosaukums

= Nodaļas nosaukums
== Apakšnodaļas nosaukums
== Apakšnodaļas nosaukums

= Nodaļas nosaukums
== Apakšnodaļas nosaukums
== Apakšnodaļas nosaukums

#set heading(numbering: none)
= Rezultāti
= Secinājumi

#bibliography-here()

= Pielikumi
#appendix(
  caption: "Appendix table",
  label: <table-1>,
)[
  #table(
    columns: (1fr, 2fr),
    table.header([Foo], [Bar]),
    lorem(10), lorem(20),
  )
]


#figure(
  kind: "appendix",
  caption: "Another table",
  table(
    columns: (1fr, 2fr),
    table.header([Foo], [Bar]),
    lorem(10), lorem(20),
  ),
)
