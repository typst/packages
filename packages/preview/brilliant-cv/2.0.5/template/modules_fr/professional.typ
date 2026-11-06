// Imports
#import "@preview/brilliant-cv:2.0.5": cvSection, cvEntry
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
    [Diriger une équipe de scientifiques et d'analystes de données pour développer et mettre en œuvre des stratégies axées sur les données, développer des modèles prédictifs et des algorithmes pour soutenir la prise de décisions dans toute l'organisation],
    [Collaborer avec la direction pour identifier les opportunités d'affaires et stimuler la croissance, mettre en œuvre les meilleures pratiques en matière de gouvernance, de qualité et de sécurité des données],
  ),
  tags: ("Exemple de tags ici", "Dataiku", "Snowflake", "SparkSQL"),
)

#cvEntry(
  title: [Analyste de Données],
  society: [ABC Company],
  date: [2017 - 2020],
  location: [New York, NY],
  logo: image("../src/logos/abc_company.png"),
  description: list(
    [Analyser de grands ensembles de données avec SQL et Python, collaborer avec les équipes pour découvrir des insights commerciaux],
    [Créer des visualisations de données et des tableaux de bord dans Tableau, développer et maintenir des pipelines de données avec AWS],
  ),
)

#cvEntry(
  title: [Stagiaire en Analyse de Données],
  society: [PQR Corporation],
  date: list(
    [été 2017],
    [été 2016],
  ),
  location: [Chicago, IL],
  logo: image("../src/logos/pqr_corp.png"),
  description: list([Aider à la préparation, au traitement et à l'analyse de données à l'aide de Python et Excel, participer aux réunions d'équipe et contribuer à la planification et à l'exécution de projets]),
)
