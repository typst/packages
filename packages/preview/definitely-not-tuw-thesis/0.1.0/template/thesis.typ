#import "@preview/definitely-not-tuw-thesis:0.1.0": *

#show: general-styles

#show: thesis.with(
  lang: "en",
  title: (en: "An ode for Lord Ipsum", de: "Eine Ode an Lord Ipsum"),
  subtitle: (:),
  thesis-type: (en: "Diploma Thesis", de: "Diplomarbeit"),
  academic-title: (de: "Diplom-Ingenieur", en: "Diplom-Ingenieur"),
  curriculum: (en: "Software Engineering & Internet Computing", de: "Software Engineering & Internet Computing "),
  author: (name: "Lord Ipsus", student-number: 11223344),
  advisor: (name: "Darth Ipsus", pre-title: "Univ.Prof.Dr."),
  assistants: ((name: "Ipsinator", pre-title: "Sir"),),
  reviewers: (),
  keywords: ("Lorem Ipsum"),
  font: "DejaVu Sans",
  date: datetime.today(),
)

#show: flex-caption-styles
#show: toc-styles
#show: front-matter-styles

// If you have non-image/table figures, you need to pass a "supplement", that is shown when referencing it (@my-alg). You can globally set this, e.g. for algorithms:
#show figure.where(kind: "algorithm"): set figure(supplement: "Algorithm")

#include "content/front-matter.typ"
#outline()

#show: main-matter-styles
#show: page-header-styles

#include "content/main.typ"

#show: back-matter-styles
#set page(header: none)

#outline(title: "List of Figures", target: figure.where(kind: image))
#outline(title: "List of Tables", target: figure.where(kind: table))
#outline(title: "List of Algorithms", target: figure.where(kind: "algorithm"))

#bibliography("refs.bib")

#show: appendix-styles

#include "content/appendix.typ"