// farfadet-didactique — environnements didactiques de bfcours (Definition, Theoreme, Propriete…),
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
//   #setbfsections(jeu: "sobre", couleur: "defi")     // jeux de titres : bfcours, sobre, classique, documentation, rd
//
// Ce fichier n'exporte QUE les noms publics (noms LaTeX exacts) et le module `interne` (noms du moteur,
// seul point d'entrée des autres paquets). Les COULEURS (`setbfcolors`, `definecolor`, `colorlet`,
// `couleurs-tabular`, `couleur-texte-accent`, `couleur-item`…) sont dans farfadet-socle.

// Noms du moteur (pour les autres paquets farfadet-*)
#import "interne.typ"

// Environnements didactiques et boîtes (src/didactique.typ est Fichier généré)
#import "src/didactique.typ": (
  activite, aide, contre-exemple, definition, demonstration, exemple, histoire, methode, neutre, notation, propriete,
  remarque, solution, theoreme, vocabulaire, bf-env, bfbox, boite, boite-figure, cracked,
)

// Réglages des environnements (styles nommés, style « rd », Anki), palettes et variantes
#import "src/palettes.typ": new-bfd-palette, bfd-activate-palette, bfd-activate-variant, bfset, setbfenvironments

// Skins : rendus des environnements fournis par des fonctions d => contenu (contrat : skins/CONTRAT.md)
#import "src/skins.typ": bfskin, setbfskins

// Carrés de couleur
#import "src/couleurs.typ": coloredsquare, dimcoloredsquare

// Sommaire, titres (jeux de titres) et entrée de sommaire
#import "src/sommaire.typ": liencontent, setbfsections, tableofcontents

// Vocabulaire
#import "src/vocabulaire.typ": printvocindex, tableau-vocabulaire-sommaire, voc, vocref
