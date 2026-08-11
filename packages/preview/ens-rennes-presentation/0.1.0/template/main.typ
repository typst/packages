#import "@preview/ens-rennes-presentation:0.1.0" : *

#show: ens-rennes-theme.with(
  aspect-ratio: "16-9",
  config-info(
    title: [ENS Rennes presentation theme],
    subtitle: [You can also add a subtitle],
    mini-title: [ENS Rennes presentation],
    authors: [Janet Doe],
    mini-authors: [Doe],
    date: datetime.today(),
  ),
  section-style: "named subsection",
  department: "info",
  display-dpt: false,
  named-index: true
)

#title-slide(
  additional-content: [Any additional content you wish here]
)

= Section 1

== Subsection 1.1

#slide(title:[First slide])[
  Content
]
