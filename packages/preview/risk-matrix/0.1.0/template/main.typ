#import "@preview/risk-matrix:0.1.0": *
#import "data.typ": study

#validate-study(study)

#show: risk-report.with(
  title: "Analyse de risque cyber",
  organization: "Atelier Boréal",
  author: "summoningshells",
  date: "5 octobre 2026",
  version: "0.1.0",
  classification: "Exemple fictif · Données et preuves de démonstration",
)

#risk-matrix(study.risks, policy: example-policy, title: "Cartographie initiale", cell-height: 12mm)

== Synthèse

L'étude porte sur le portail de commandes et le CRM. Deux risques sont retenus :
l'interruption des commandes par extorsion (R1) et le vol des dossiers clients (R2).

Le traitement de R1 reste à réaliser : renforcer les accès tiers et tester la
restauration du portail. Pour R2, les exports ont été limités et les alertes
vérifiées dans la simulation. L'acceptation doit encore être examinée en comité.

L'altération ponctuelle d'une commande (ER3) reste à instruire.

Les couleurs suivent la politique de cet exemple, à adapter aux critères de l'étude.

#pagebreak()
#workshop(1, "Cadrage et socle de sécurité")[
  #scope-card(
    objective: [Préparer les décisions de sécurisation du service de commandes.],
    scope: [Portail de commandes, CRM, identités et accès de maintenance.],
    participants: [Direction, métiers, RSSI, exploitation et représentant du prestataire.],
    decision-maker: [Direction générale ; acceptation à consigner après revue.],
    strategic-cycle: [Revue de l'étude à 24 mois ou changement majeur.],
    operational-cycle: [Revue à 6 mois, après incident ou évolution significative.],
    assumptions: [Mode dégradé limité à deux jours ; accès de maintenance sans second facteur.],
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

  ER3 n'a pas de scénario associé. Vérifier sa prise en charge par le socle
  de sécurité ou compléter l'étude.
]

#pagebreak()
#workshop(5, "Traitement du risque")[
  #risk-register(study.risks, policy: example-policy)

  == Plan de traitement
  #treatment-table(study.measures)

  == Décision et suivi
  Le RSSI suit M1 et M2 avec les responsables infrastructure et exploitation.
  R1 sera réévalué après leur vérification. La direction doit se prononcer sur
  l'acceptation de R2 à partir du compte rendu PV-DEMO-03.
]

#pagebreak()
= Après traitement : cibles et résiduels

#risk-matrix(study.risks, stage: "residual", policy: example-policy)

== Référence méthodologique

#link("https://messervices.cyber.gouv.fr/guides/la-methode-ebios-risk-manager-le-guide")[
  ANSSI · Guide EBIOS Risk Manager et fiches méthodes
]

Guide version 1.5, septembre 2024, ANSSI-PA-048, diffusé sous Licence Ouverte
Etalab V1. Consulté le 5 octobre 2026. Ce modèle est indépendant, sans affiliation
ni labellisation ANSSI. EBIOS est une marque du SGDSN.

== Utiliser ce modèle

Remplacer les données de `data.typ`, définir les échelles avec les participants,
puis remplacer `example-policy` par la politique retenue. La gravité et la
vraisemblance restent deux cotations distinctes ; le modèle ne calcule pas leur produit.

`validate-study` vérifie les références et la cohérence des cotations. La qualité
des hypothèses, des preuves et des décisions relève de la revue de l'étude.
