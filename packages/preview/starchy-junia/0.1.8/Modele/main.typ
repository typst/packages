// --- Imports ---
// setup.typ contient le modèle du document et les fonctions de mise en page
#import "Configuration/setup.typ": *

// --- Configuration globale du modèle ---
#show: modele-junia.with(
  // Page de garde : true : génère la page de garde | false : utilise une page de garde PDF
  generate-cover: true,
  // Chemin vers la page de garde PDF
  cover-pdf-path: "../Images/Garde/page_de_garde.pdf",

  // Paramètres de la page de garde, remplir au minimum le titre et les auteurs
  // Si pas besoin d'un "champ", on le commente avec // devant
  type-rapport: [Type de rapport ou type de mémoire],
  titre-rapport: [Titre],
  confidentialite: [Confidentiel - X années],
  type-diplome: [En vue de l'obtention du diplôme : Ingénieur généraliste JUNIA-HEI],
  professeur: [Enseignant référent : NOM Prénom],
  encadrant: [Encadrant organisme d'accueil : NOM Prénom],
  auteurs: (
    "NOM Prénom",
    "NOM Prénom",
    "NOM Prénom",
    "NOM Prénom",
    "NOM Prénom",
    "NOM Prénom",
    "NOM Prénom",
    "NOM Prénom",
    "NOM Prénom",
    "NOM Prénom",
  ),
  formation: [Ingénieur en Apprentissage],
  promotion: [BTP/ESE HEI],
  niveau-classe: [48],
  // Si on laisse `auto`, la date se met à jour automatiquement sinon on peut mettre "Mois Années" ou [Mois Années]
  mois-annee: auto,

  // Gestion du mode ébauche avec les notes de pages
  ebauche: false,
  // Filigrane pour la confidentialité du rapport
  filigrane: false,

  // Numérotation des équations mathématiques
  math-num: false,
  // Langue du document : "fr" ou "en" (traduit automatiquement les titres des sections)
  lang-doc: "fr",
)

// --- Pré-Sommaire du document ---
#include "Fiches/B_Resume.typ"
#include "Fiches/C_Remerciements.typ"
#include "Fiches/D_Preambule.typ"

// - Lexique -
#show: f-lexique

// - Sommaire -
#show: f-sommaire

// - Table des figures -
#show: f-liste-figure

// - Liste des tableaux -
#show: f-liste-tableau

// --- Post-Sommaire du document ---
// Bascule l'affichage des pages et leurs numérotation
#show: f-corps-document

// - Chapitres du document -
#include "Fiches/G_Introduction.typ"
#include "Fiches/H_Cadre_de_etude.typ"
#include "Fiches/I_Contexte_Etat_art.typ"
#include "Fiches/J_Methodologie_Moyens.typ"
#include "Fiches/K_Presentation_Analyses.typ"
#include "Fiches/L_Discussions_Perspectives.typ"
#include "Fiches/M_Conclusion.typ"

// - Bibliographie -
#show: f-bibliographie

// - Annexes -
// Bascule vers le mode annexe: numérotation différente, figures renumérotées, sommaire des annexes généré
#show: f-annexes
// Contenu des annexes
#include "Fiches/P_Annexes.typ"
