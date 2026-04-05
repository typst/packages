#import "metadata.typ": author, lang, document-type, supervisor, second-supervisor, advisors, city, date, is-doublesided, title, international-title, organisation, organisation-logo, header-logo
#import "@preview/optimal-ovgu-thesis:0.1.0": optimal-ovgu-thesis, oot-titlepage, oot-disclaimer, oot-acknowledgement, oot-abstract

#show: optimal-ovgu-thesis.with(
  title: title,
  author: author,
  lang: lang,
  is-doublesided: is-doublesided,
)

#set page(numbering: "I")

#oot-titlepage(
  title: title,
  document-type: document-type,
  supervisor: supervisor,
  second-supervisor: second-supervisor,
  advisors: advisors,
  author: author,
  city: city,
  date: date,
  organisation: organisation,
  organisation-logo: organisation-logo,
  header-logo: header-logo,
  is-doublesided: is-doublesided,
  lang: lang,
)

#counter(page).update(2)

#oot-disclaimer(
  title: title,
  international-title: international-title,
  author: author,
  city: city,
  is-doublesided: is-doublesided,
  lang: lang,
)

#oot-acknowledgement(heading: "Acknowledgements", is-doublesided: is-doublesided, [
  Standing on the shoulders of giants
])

#oot-abstract(
  is-doublesided: is-doublesided,
)[
  This Master's thesis investigates the impact of different architectures of
  neural networks on the performance of real-time image recognition on low-power
  devices. Optimization strategies are developed and evaluated to enhance the
  efficiency and accuracy of these systems. The results demonstrate that targeted
  adaptations of network structures are crucial for enabling fast and precise
  image recognition on resource-constrained devices.
]

#oot-abstract(
  is-doublesided: is-doublesided,
  lang: "de",
)[
  Die vorliegende Masterarbeit untersucht die Auswirkungen verschiedener
  Architekturen von neuronalen Netzwerken auf die Leistungsfähigkeit der
  Bilderkennung in Echtzeit auf energiesparenden Geräten. Es werden
  Optimierungsstrategien entwickelt und evaluiert, um die Effizienz und
  Genauigkeit dieser Systeme zu verbessern. Die Ergebnisse zeigen, dass die
  gezielte Anpassung der Netzwerkstrukturen entscheidend ist, um eine schnelle und
  präzise Bilderkennung auf ressourcenbeschränkten Geräten zu ermöglichen.
]

#outline()

#set page(numbering: "1")
#counter(page).update(1)

#include "chapter/01-Einleitung.typ"
// #include "chapter/02-Grundlagen.typ"
// #include "chapter/03-StandDerTechnik.typ"
// ...

#bibliography("./thesis.bib")

#include "chapter/99-Appendix.typ"