// =============================================================================
// SQUELETTE — Modèle JUNIA
// =============================================================================
// 1. Remplir la section CONFIGURATION ci-dessous
// 2. Rédiger le contenu dans les fichiers du dossier 02-fiches/
// =============================================================================

#import "00-configuration/005-centralisation.typ": *

// =============================================================================
// CONFIGURATION — à remplir avant de commencer à rédiger
// =============================================================================

#show: modele-junia.with(

  glossaire:     v-liste-glossaire,  // Ne pas modifier

  // ── À remplir ──────────────────────────────────────────────────────────────
  type-rapport:    [Rapport de stage],
  titre-rapport:   [Titre du rapport],
  type-diplome:    [Ingénieur généraliste JUNIA-HEI],
  professeur:      [Enseignant référent : NOM Prénom],
  encadrant:       [Encadrant : NOM Prénom],
  auteurs:         ("NOM Prénom",),  // Ajouter une ligne par auteur supplémentaire
  formation:       [Ingénieur en Apprentissage],
  promotion:       [BTP/ESE HEI],
  niveau-classe:   [48],

  // ── Options ────────────────────────────────────────────────────────────────
  // lang-doc:        "en",                       // Décommenter pour passer en anglais
  // mois-annee:      [Juin 2025],                // Décommenter pour fixer la date manuellement
  // ebauche:         true,                       // Mode brouillon : filigrane + notes de relecture
  // filigrane:       true,                       // Filigrane CONFIDENTIEL sur chaque page
  // num-equations:   true,                       // Numéroter les équations mathématiques
  // confidentialite: [Confidentiel — 5 ans],     // Mention rouge sur la page de garde
)

// =============================================================================
// PRÉ-SOMMAIRE
// =============================================================================

#include "02-fiches/021-pre-sommaire/B-resume.typ"
#include "02-fiches/021-pre-sommaire/C-remerciements.typ"
#include "02-fiches/021-pre-sommaire/D-preambule.typ"

#show: fbc-lexique        // Lexique              — affiché si E-lexique.typ contient des entrées
#show: fbc-sommaire       // Table des matières
#show: fbc-liste-figure   // Table des figures    — affichée si le document en contient
#show: fbc-liste-tableau  // Liste des tableaux   — affichée si le document en contient

// =============================================================================
// CORPS DU DOCUMENT
// =============================================================================

#show: fmp-corps-document

#include "02-fiches/022-post-sommaire/G-introduction.typ"
#include "02-fiches/022-post-sommaire/H-cadre-de-etude.typ"
#include "02-fiches/022-post-sommaire/I-contexte-etat-art.typ"
#include "02-fiches/022-post-sommaire/J-methodologie-moyens.typ"
#include "02-fiches/022-post-sommaire/K-presentation-analyses.typ"
#include "02-fiches/022-post-sommaire/L-discussions-perspectives.typ"
#include "02-fiches/022-post-sommaire/M-conclusion.typ"

#show: fbc-bibliographie  // Bibliographie        — affichée si des citations @cle sont présentes

// =============================================================================
// ANNEXES
// =============================================================================

#show: fmp-annexes // Sommaire des annexes        - affichés si des annexes (titre, `=` ) sont présent
#include "02-fiches/023-annexes/P-annexes.typ"
