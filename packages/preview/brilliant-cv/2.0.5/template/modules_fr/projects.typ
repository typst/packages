// Imports
#import "@preview/brilliant-cv:2.0.5": cvSection, cvEntry
#let metadata = toml("../metadata.toml")
#let cvSection = cvSection.with(metadata: metadata)
#let cvEntry = cvEntry.with(metadata: metadata)


#cvSection("Projets & Associations")

#cvEntry(
  title: [Analyste de Données Bénévole],
  society: [ABC Organisation à But Non Lucratif],
  date: [2019 - Présent],
  location: [New York, NY],
  description: list(
    [Analyser les données de donateurs et de collecte de fonds pour identifier les tendances et les opportunités de croissance],
    [Créer des visualisations de données et des tableaux de bord pour communiquer des insights au conseil d'administration],
  ),
)
