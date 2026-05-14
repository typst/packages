#import "@local/ratsch-bmim:0.2.0" as bmim

#show: bmim.report(
  title: [Laborbericht],
  authors: ("John Doe", "Jane Doe"),
)

= Kurzzusammenfassung

- Beschreiben Sie in wenigen Sätzen das Ziel des Versuches, die Methode und das
	Ergebnis.
- Ihr Protokoll richtet sich an Fachpublikum. Die Sprache und das Niveau sollen
	diesem angepasst sein.

== Subsection

#lorem(20)

= Last Section

#lorem(30)

= Section

- element
- another

  Do try @tab:try.
  #figure(
    table(
      columns: 4,
      ..(context{counter("a").step(); str(counter("a").get().first())},)*8,
    ),
    caption: [Try me! #lorem(20)],
  ) <tab:try>

== Subsection

#lorem(30)

= Last Section

#lorem(50)
= Section

- element
- another

== Subsection

#lorem(20)

= Last Section

#lorem(30)

= Section

- element
- another

== Subsection

#lorem(20)

= Last Section

#lorem(30)
