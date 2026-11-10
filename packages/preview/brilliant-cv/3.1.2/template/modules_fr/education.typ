// Imports
#import "@preview/brilliant-cv:3.1.2": cv-section, cv-entry, h-bar


#cv-section("Formation")

#cv-entry(
  title: [Master en Science des Données],
  society: [Université de Californie à Los Angeles],
  date: [2018 - 2020],
  location: [USA],
  logo: image("../assets/logos/ucla.png"),
  description: list(
    [Thèse : Prédiction du taux de désabonnement des clients dans l'industrie des télécommunications en utilisant des algorithmes d'apprentissage automatique et l'analyse de réseau],
    [Cours : Systèmes et technologies Big Data #h-bar() Exploration et exploitation de données #h-bar() Traitement du langage naturel],
  ),
)

#cv-entry(
  title: [Bachelors en Informatique],
  society: [Université de Californie à Los Angeles],
  date: [2014 - 2018],
  location: [USA],
  logo: image("../assets/logos/ucla.png"),
  description: list(
    [Thèse : Exploration de l'utilisation des algorithmes d'apprentissage automatique pour la prédiction des prix des actions : une étude comparative des modèles de régression et de séries chronologiques],
    [Cours : Systèmes de base de données #h-bar() Réseaux informatiques #h-bar() Génie logiciel #h-bar() Intelligence artificielle],
  ),
)
