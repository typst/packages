#import "@preview/electrocentrale:0.1.0": *

// Configuration générale
#let langue = "fr" // "fr" ou "en"
#let style-police = "latex" // "arial" | "latex" | "typst-modern" | "modern-sans" | "editorial"

// Choix du modèle (décommentez le modèle souhaité pour votre document)

// --- Modèle 1 : Rapport de Travaux Pratiques (TP) ---
#show: tp.with(
  lang: langue,
  title: "Filtres Actifs et Traitement du Signal",
  tp-num: "1", // numéro de TP
  promo: "ING5",
  major: "Systèmes Embarqués", // ou none
  groupe: "Groupe 02",
  authors: (
    (name: "André-Marie AMPÈRE", email: "ampere@ece.fr", role: "Électronique analogique"),
    (name: "Alessandro VOLTA", email: "volta@ece.fr", role: "Mesures et banc de test"),
  ),
  supervisor: (name: "Dr. Jean DUPONT", email: "jean.dupont@ece.fr"), // ou string ou none
  show-roles: true,
  show-emails: true,
  date: auto,
  city: "Paris",
  draft: false,
  font: font-presets.at(style-police, default: "New Computer Modern"),
)

// --- Modèle 2 : Rapport de Projet ---
// #show: projet.with(
//   lang: langue,
//   title: "Système de Télémétrie et Surveillance Temps Réel",
//   promo: "ING5",
//   major: "Systèmes Embarqués",
//   groupe: "Groupe 02",
//   authors: (
//     (name: "André-Marie AMPÈRE", email: "ampere@ece.fr", role: "Chef de projet"),
//     (name: "Alessandro VOLTA", email: "volta@ece.fr", role: "Architecture logicielle"),
//   ),
//   supervisor: "Dr. Jean DUPONT",
//   abstract: [Contexte, problématique et objectifs techniques du projet.],
//   font: font-presets.at(style-police, default: "New Computer Modern"),
// )

// --- Modèle 3 : Document de Conception (Architecture technique / CDC) ---
// #show: conception.with(
//   lang: langue,
//   title: "Dossier de Conception Matérielle et Logicielle",
//   promo: "ING5",
//   major: "Systèmes Embarqués",
//   authors: (
//     (name: "André-Marie AMPÈRE", email: "ampere@ece.fr"),
//     (name: "Alessandro VOLTA", email: "volta@ece.fr"),
//   ),
//   abstract: [Avant-propos et spécifications fonctionnelles du système.],
//   font: font-presets.at(style-police, default: "New Computer Modern"),
// )

// --- Modèle 4 : Rapport de Stage (avec fiche d'évaluation officielle) ---
// #show: stage.with(
//   title: "Virtualisation et Sécurisation d'une Plateforme Embarquée",
//   student: (firstname: "Camille", lastname: "MARTIN", major: "Systèmes Embarqués"),
//   company: (name: "Innovatech Solutions SAS", address: "12 rue de l'Innovation, 75015 Paris"),
//   confidential: false,
//   return-to-supervisor: false,
//   mission-description: [Objectif principal et cadre de la mission de stage.],
//   missions: ([Qualifier l'environnement Linux], [Déployer la solution]),
//   maitre-de-stage: (name: "Dr. Thomas BERNARD", email: "thomas.bernard@innovatech.fr", phone: "01 40 00 00 00"),
//   city: "Paris",
// )

= Première partie : Étude théorique et expérimentale
== Analyse fréquentielle

#t(1)[Calculer la fonction de transfert théorique du filtre passe-bas actif.]

La fonction de transfert théorique s'exprime par :
$ H(j omega) = - (R_2 / R_1) 1 / (1 + j (omega / omega_0)) $ <eq:transfert>

Avec $R_1 = 10#kohm$, $R_2 = 100#kohm$, et $C_1 = 100#nf$. Le banc de test est présenté sur la @fig:logo.

#figure(
  logo-ece(width: 5cm),
  caption: [Logo vectoriel ECE],
) <fig:logo>

#callout(title: "Précaution expérimentale", type: "warning")[
  Vérifier l'alimentation symétrique (+15 V / -15 V) de l'amplificateur opérationnel avant la mise sous tension.
]

#e(1)[Mesure expérimentale du gain et traitement des données.]

Les signaux observés à l'oscilloscope sont illustrés sur la @fig:mesures.

#figure(
  logo-ece(width: 5cm),
  caption: [Résultats expérimentaux],
) <fig:mesures>

= Méthodologie et recommandations
== Guide de rédaction

#text(fill: gray)[
  Pour chaque question, expliciter :
  + Le problème
  + La solution technique
  + Les résultats obtenus
  + La validation critique
]

#show: annexes

= Annexes

Documents volumineux, relevés de mesures brutes ou code source (#attention[pas de code brut dans le corps du rapport]).
