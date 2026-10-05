#import "@preview/risk-matrix:0.1.0": *
#import "data.typ": study

#validate-study(study)

#show: risk-report.with(
  title: "Analyse de risque cyber",
  organization: "Atelier Boréal · Cas fictif",
  author: "summoningshells",
  date: "5 octobre 2026",
  version: "0.1.0",
  classification: "DÉMONSTRATION · Données et preuves fictives",
)

Cas fictif. Les cotations et les éléments de preuve illustrent l'utilisation du modèle.

#v(8pt)
#risk-matrix(study.risks, policy: example-policy, title: "Cartographie initiale", cell-height: 12mm)

== Synthèse

Deux risques documentés, trois mesures de traitement. L'événement ER3 reste à instruire.

La couleur représente une politique d'exemple propre à ce projet. Elle ne constitue
pas un seuil imposé par l'ANSSI ni une décision d'acceptation. La matrice exprime
deux échelles ordinales ; aucun produit gravité × vraisemblance n'est calculé.

*Fondement méthodologique :* guide EBIOS Risk Manager, ANSSI, version 1.5,
septembre 2024. Implémentation indépendante, sans affiliation ni labellisation ANSSI.

#pagebreak()
#workshop(1, "Cadrage et socle de sécurité")[
  #scope-card(
    objective: [Préparer les décisions de sécurisation du service de commandes.],
    scope: [Portail de commandes, CRM, identités et accès de maintenance.],
    participants: [Direction, métiers, RSSI, exploitation et représentant du prestataire.],
    decision-maker: [Direction générale ; acceptation à consigner après revue.],
    strategic-cycle: [Revue de l'étude à 24 mois ou changement majeur.],
    operational-cycle: [Revue à 6 mois, après incident ou évolution significative.],
    assumptions: [Entreprise fictive. Mesures et cotations à remplacer par les constats du terrain.],
  )

  == Valeurs métier et supports
  #assets-table(study.assets)

  == Événements redoutés
  #events-table(study.events)

  == Socle de sécurité
  #baseline-table(study.baseline)
]

#pagebreak()
#workshop(2, "Sources de risque")[
  #sources-table(study.sources)
]

#workshop(3, "Scénarios stratégiques")[
  == Écosystème
  #stakeholders-table(study.stakeholders)

  == Chemins d'attaque
  #strategic-table(study.strategic)
]

#pagebreak()
#workshop(4, "Scénarios opérationnels")[
  #operational-table(study.operational)

  == Conventions de cotation
  La gravité reprend les conséquences métier du scénario stratégique.
  La vraisemblance est appréciée pour chaque scénario opérationnel, avec une
  justification. Elle n'est pas convertie en probabilité annuelle.

  #data-table((
    (code: [G1 / V1], gravity: [Mineure], likelihood: [Peu vraisemblable]),
    (code: [G2 / V2], gravity: [Significative], likelihood: [Vraisemblable]),
    (code: [G3 / V3], gravity: [Grave], likelihood: [Très vraisemblable]),
    (code: [G4 / V4], gravity: [Critique], likelihood: [Quasi certain]),
  ), (
    (key: "code", label: [Niveau]),
    (key: "gravity", label: [Gravité]),
    (key: "likelihood", label: [Vraisemblance]),
  ))

  == Couverture des événements
  #coverage-table(study.events, study.risks)

  ER3 reste visible même s'il n'est associé à aucun scénario dans cet exemple.
  L'équipe doit justifier sa prise en charge par le socle ou compléter l'étude.
]

#pagebreak()
#workshop(5, "Traitement du risque")[
  #risk-register(study.risks, policy: example-policy)

  == Plan de traitement
  #treatment-table(study.measures)

  == Décision et suivi
  La direction statue sur l'acceptation ; le RSSI suit les mesures avec leurs
  propriétaires. Le niveau visé de R1 demeure une cible jusqu'à vérification des
  mesures et réévaluation. R2 illustre une réévaluation appuyée sur une preuve fictive.
  La décision d'acceptation reste distincte de cette évaluation.
]

#pagebreak()
= Après traitement : cibles et résiduels

#risk-matrix(study.risks, stage: "residual", policy: example-policy)

== Traçabilité des sources

#link("https://messervices.cyber.gouv.fr/guides/la-methode-ebios-risk-manager-le-guide")[
  ANSSI · Guide EBIOS Risk Manager et fiches méthodes
]

Guide version 1.5, septembre 2024, ANSSI-PA-048, diffusé sous Licence Ouverte
Etalab V1. Référence consultée le 5 octobre 2026. Les exemples, la présentation
et la politique de classement sont propres à ce package. Aucun logo ANSSI n'est utilisé.

Les fiches méthodes complètent notamment la justification des cotations, la
caractérisation de l'écosystème et le suivi des mesures. Les seuils doivent être
définis et approuvés pour chaque étude. EBIOS est une marque du SGDSN.

== Utiliser ce modèle

Modifier les données de `data.typ`, définir les critères de gravité et de
vraisemblance avec les participants, puis remplacer `example-policy` par la
politique retenue. La fonction `validate-study` signale les références rompues
et les incohérences de cotation ; elle ne certifie pas la qualité de l'analyse.
