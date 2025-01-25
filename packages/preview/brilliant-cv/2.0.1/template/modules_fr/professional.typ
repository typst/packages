// Imports
#import "@preview/brilliant-cv:2.0.1": cvSection, cvEntry
#let metadata = toml("../metadata.toml")
#let cvSection = cvSection.with(metadata: metadata)
#let cvEntry = cvEntry.with(metadata: metadata)

#cvSection("Expérience Professionnelle")

#cvEntry(
  title: [Directeur de la Science des Données],
  society: [XYZ Corporation],
  date: [2020 - Présent],
  logo: image("../src/logos/xyz_corp.png"),
  location: [San Francisco, CA],
  description: list(
    [Diriger une équipe de scientifiques et d'analystes de données pour développer et
      mettre en œuvre des stratégies axées sur les données, développer des modèles
      prédictifs et des algorithmes pour soutenir la prise de décisions dans toute
      l'organisation],
    [Collaborer avec la direction pour identifier les opportunités d'affaires et
      stimuler la croissance, mettre en œuvre les meilleures pratiques en matière de
      gouvernance, de qualité et de sécurité des données],
  ),
)

#cvEntry(
  title: [Analyste de Données],
  society: [ABC Company],
  date: [2017 - 2020],
  location: [New York, NY],
  logo: image("../src/logos/abc_company.png"),
  description: list(
    [Analyser de grands ensembles de données à l'aide de SQL et Python, collaborer
      avec des équipes interfonctionnelles pour identifier des insights métier],
    [Créer des visualisations de données et des tableaux de bord à l'aide de Tableau,
      développer et maintenir des pipelines de données à l'aide d'AWS],
  ),
)

#cvEntry(
  title: [Stagiaire en Analyse de Données],
  society: [PQR Corporation],
  date: [été 2017],
  location: [Chicago, IL],
  logo: image("../src/logos/pqr_corp.png"),
  description: list([Aider à la préparation, au traitement et à l'analyse de données à l'aide de
    Python et Excel, participer aux réunions d'équipe et contribuer à la
    planification et à l'exécution de projets]),
)
