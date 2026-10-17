// =============================================================================
// SQUELETTE — Modèle JUNIA
// =============================================================================
// 1. Remplir la section CONFIGURATION ci-dessous
// 2. Rédiger le contenu dans les fichiers du dossier fiches/
// =============================================================================

// Modèle starchy-junia, paquets et fonctions personnalisées
#import "ressources/commun.typ": *

// Entrées du lexique
#import "ressources/lexique.typ": *

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
  // langue:               "en",                             // Décommenter pour passer en anglais
  // date:                 [Juin 2025],                      // Décommenter pour fixer la date manuellement
  // ebauche:              true,                             // Mode brouillon : filigrane BROUILLON
  // bandeau-confidentiel: true,                             // Bandeau CONFIDENTIEL sur chaque page
  // numerotation:         (equations: true),                // Numéroter les équations, ou (profondeur: 2) pour les titres
  // police:               (taille: 11pt),                   // Police du texte, ou (titres: (1.4em, 1.3em, ...)) pour les titres
  // code:                 (mode: "figure"),                 // Blocs de code traités comme des figures (voir la documentation)
  // confidentialite:      [Confidentiel — 5 ans],           // Mention rouge sur la page de garde
  // page-de-garde:        image("images/garde.pdf"),     // Page de garde externe à la place de la page générée (none = aucune)
)

// =============================================================================
// PRÉ-SOMMAIRE
// =============================================================================

#include "fiches/pre-sommaire/01-resume.typ"
#include "fiches/pre-sommaire/02-remerciements.typ"
#include "fiches/pre-sommaire/03-preambule.typ"

#show: fbc-lexique        // Lexique              — affiché si ressources/lexique.typ contient des entrées
#show: fbc-sommaire       // Table des matières
#show: fbc-liste-figure   // Table des figures    — affichée si le document en contient
#show: fbc-liste-tableau  // Liste des tableaux   — affichée si le document en contient
#show: fbc-liste-programme // Liste des programmes — affichée si le document contient du code en figure

// =============================================================================
// CORPS DU DOCUMENT
// =============================================================================

#show: fmp-corps-document

#include "fiches/corps/01-introduction.typ"
#include "fiches/corps/02-cadre-etude.typ"
#include "fiches/corps/03-contexte-etat-art.typ"
#include "fiches/corps/04-methodologie-moyens.typ"
#include "fiches/corps/05-presentation-analyses.typ"
#include "fiches/corps/06-discussions-perspectives.typ"
#include "fiches/corps/07-conclusion.typ"

#show: fbc-bibliographie  // Bibliographie        — affichée si des citations @cle sont présentes
#bibliography(
  (
    "ressources/bibliographie.yml",   // Format Hayagriva, propre à Typst
    "ressources/bibliographie.bib"    // Format BibTeX, exporté par Zotero et la plupart des outils
  ),
)

// =============================================================================
// ANNEXES
// =============================================================================

#show: fmp-annexes // Sommaire des annexes        - affichés si des annexes (titre, `=` ) sont présent
#include "fiches/annexes/01-annexes.typ"
