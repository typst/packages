// bfcours-didactique — environnements didactiques de bfcours (Definition, Theoreme, Propriete…),
// style « rd » (boîtes du paquet `rdboites`), palettes et variantes, sectionnement (jeux de titres) et
// sommaire, vocabulaire, Anki.
//
//   #import "lib.typ": *
//
//   #setbfenvironments(style: "rd")                   // rendu par les boîtes de `rdboites` (défaut : "bf")
//   #setbfskins(bristol: mon-skin)                    // skin : fonction d => contenu (skins/CONTRAT.md)
//   #setbfenvironments(pour: "Definition", rendu: "bristol")
//   #setbfenvironments(pour: "Theoreme", rendu: "filet")   // skins intégrés : cahier, outil, pastille, manchette, filet, suspendu
//   #setbfenvironments(pour: "Propriete", rendu: bfskin("outil", icone: "cle"))   // variante à options figées
//   #setbfenvironments(pour: "Definition", numero: true)
//   #setbfsections(jeu: "sobre", couleur: "defi")     // jeux de titres : bfcours, sobre, classique, documentation
//
// Ce fichier n'exporte QUE les noms publics (noms LaTeX exacts) et le module `interne` (noms du moteur,
// seul point d'entrée des autres paquets). Les COULEURS (`setbfcolors`, `definecolor`, `colorlet`,
// `CouleursTabular`, `CouleurTexteAccent`, `couleurItem`…) sont dans bfcours-socle.

// Noms du moteur (pour les autres paquets bfcours-*)
#import "interne.typ"

// Environnements didactiques et boîtes (src/didactique.typ est Fichier généré)
#import "src/didactique.typ": (
  Activite, Aide, ContreExemple, Definition, Demonstration, Exemple, Histoire, Methode, None, Notation, Propriete,
  Remarque, Solution, Theoreme, Vocabulaire, bfEnv, bfbox, boite, boiteFigure, cracked,
)

// Réglages des environnements (styles nommés, style « rd », Anki), palettes et variantes
#import "src/palettes.typ": NewBfdPalette, bfdActivatePalette, bfdActivateVariant, bfset, setbfenvironments

// Skins : rendus des environnements fournis par des fonctions d => contenu (contrat : skins/CONTRAT.md)
#import "src/skins.typ": bfskin, setbfskins

// Carrés de couleur
#import "src/couleurs.typ": coloredsquare, dimcoloredsquare

// Sommaire, titres (jeux de titres) et entrée de sommaire
#import "src/sommaire.typ": liencontent, setbfsections, tableofcontents

// Vocabulaire
#import "src/vocabulaire.typ": printvocindex, tableauVocabulaireSommaire, voc, vocref
