// Imports
#import "@preview/brilliant-cv:3.1.2": cv-section, cv-entry, cv-entry-start, cv-entry-continued


#cv-section("Expérience Professionnelle")

#cv-entry-start(
  society: [XYZ Corporation],
  logo: image("../assets/logos/xyz_corp.png"),
  location: [San Francisco, CA],
)

#cv-entry-continued(
  title: [Directeur de la Science des Données],
  date: [2020 - Présent],
  description: list(
    [Diriger une équipe de scientifiques et d'analystes de données pour développer et mettre en œuvre des stratégies axées sur les données, développer des modèles prédictifs et des algorithmes pour soutenir la prise de décisions dans toute l'organisation],
    [Collaborer avec la direction pour identifier les opportunités d'affaires et stimuler la croissance, mettre en œuvre les meilleures pratiques en matière de gouvernance, de qualité et de sécurité des données],
  ),
  tags: ("Dataiku", "Snowflake", "SparkSQL"),
)

#cv-entry(
  title: [Analyste de Données],
  society: [ABC Company],
  date: [2017 - 2020],
  location: [New York, NY],
  logo: image("../assets/logos/abc_company.png"),
  description: list(
    [Analyser de grands ensembles de données avec SQL et Python, collaborer avec les équipes pour découvrir des insights commerciaux],
    [Créer des visualisations de données et des tableaux de bord dans Tableau, développer et maintenir des pipelines de données avec AWS],
  ),
)

#cv-entry(
  title: [Stagiaire en Analyse de Données],
  society: [PQR Corporation],
  date: list(
    [été 2017],
    [été 2016],
  ),
  location: [Chicago, IL],
  logo: image("../assets/logos/pqr_corp.png"),
  description: list([Aider à la préparation, au traitement et à l'analyse de données à l'aide de Python et Excel, participer aux réunions d'équipe et contribuer à la planification et à l'exécution de projets]),
)
