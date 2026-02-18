// Imports
#import "@preview/brilliant-cv:2.0.5": cvSection, cvEntry, hBar
#let metadata = toml("../metadata.toml")
#let cvSection = cvSection.with(metadata: metadata)
#let cvEntry = cvEntry.with(metadata: metadata)


#cvSection("Formation")

#cvEntry(
  title: [Master en Science des Données],
  society: [Université de Californie à Los Angeles],
  date: [2018 - 2020],
  location: [USA],
  logo: image("../src/logos/ucla.png"),
  description: list(
    [Thèse : Prédiction du taux de désabonnement des clients dans l'industrie des télécommunications en utilisant des algorithmes d'apprentissage automatique et l'analyse de réseau],
    [Cours : Systèmes et technologies Big Data #hBar() Exploration et exploitation de données #hBar() Traitement du langage naturel],
  ),
)

#cvEntry(
  title: [Bachelors en Informatique],
  society: [Université de Californie à Los Angeles],
  date: [2014 - 2018],
  location: [USA],
  logo: image("../src/logos/ucla.png"),
  description: list(
    [Thèse : Exploration de l'utilisation des algorithmes d'apprentissage automatique pour la prédiction des prix des actions : une étude comparative des modèles de régression et de séries chronologiques],
    [Cours : Systèmes de base de données #hBar() Réseaux informatiques #hBar() Génie logiciel #hBar() Intelligence artificielle],
  ),
)
