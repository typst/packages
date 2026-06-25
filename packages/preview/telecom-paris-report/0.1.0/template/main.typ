#import "@preview/telecom-paris-report:0.1.0": *

#let abstract = [
  This is a test of the Télécom Paris report template. It features some simple
  options and basic page layout. It currenly support `lang` "fr" and "en" for
  text attributes translations (like `abstract` or `keywords`). See
  documentation to know about all the available options.
]

#show: telecom-paris-report.with(
  title: "Unofficial Télécom Paris Report Template",
  subtitle: "Styled according to Télécom Paris' graphic chart",
  short-title: "Report Template",
  authors: (
    (name: "Jonh Doe", mail: "jonh.doe@test.com"),
    (name: "Jane Doe", mail: "jane.doe@test.fr"),
  ),
  supervisors: (
    (name: "Bob Doe", mail: "bob.doe@bob.org"),
  ),
  keywords: ("Report", "Template", "Télécom Paris"),
  abstract: abstract,
  date: "2024-01-01",
  sidebar-text: "Sidebar text",
  show-mail: true,
  lang: "en",
)

= A Section

#lorem(50)

== A Subsection

#lorem(200)

=== A Subsubsection

#lorem(100)
