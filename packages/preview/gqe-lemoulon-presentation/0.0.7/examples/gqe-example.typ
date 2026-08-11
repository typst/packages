#import "@preview/gqe-lemoulon-presentation:0.0.7":*
#import themes.gqe: *



// Définir la page de titre et le pied de page des autres slides
#show: gqe-lemoulon-presentation-theme.with(
  aspect-ratio: "4-3",
  gqe-font: "PT Sans",
  gqe-config-info(
    title: [Présentation GQE],
    subtitle: [Presentation of the research unit],
    author: [Christine Dillmann],
    institution: none,
    equipe: "UMR GQE-Le Moulon",
    logo2: [],
  )
)

#title-slide()

== test

#alert()[choses là]
