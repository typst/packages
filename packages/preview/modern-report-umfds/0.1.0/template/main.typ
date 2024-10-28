#import "@preview/modern-report-umfds:0.1.0": umfds

#show: umfds.with(
  title: [#lorem(12)],
  abstract: [
    #lorem(100)
  ],
  authors: (
    "Author 1",
    "Author 2",
    "Author 3",
    "Author 4"
  ),
  date: datetime.today().display("[day] [month repr:long] [year]"),
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
