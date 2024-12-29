#import "@preview/modern-report-umfds:0.1.1": umfds

#show: umfds.with(
  title: [#lorem(12)],
  authors: (
    "Author 1",
    "Author 2",
    "Author 3",
    "Author 4"
  ),
  date: datetime.today().display("[day] [month repr:long] [year]"),
  img: rect(width: 15em, height: 15em, fill: luma(240))[
    #align(center + horizon)[
      #text(size: 2em, weight: "black")[Image]
    ]
  ],
  abstract: [
    #lorem(100)
  ],
  bibliography: bibliography("refs.bib", full: true),
  lang: "en",
)

= Section titled
#lorem(50)

#lorem(20)

#lorem(40)

== Sub-section
#lorem(100)

=== Sub-subsection
#lorem(50)

= Section title
#lorem(200)
