// bfcours-socle — Fondations des paquets bfcours-* : version prof/élève, couleurs (port de
// bfcours-colors.sty), mesures, police, français, points, mécanisme générique de réglages.
//
//   #import "lib.typ": *
//
// Ce fichier n'exporte QUE les noms publics (façade, noms LaTeX exacts) et le module `interne` (noms du moteur, STABLES, seul point d'entrée des autres paquets).

// Noms du moteur (pour les autres paquets bfcours-*)
#import "interne.typ"

// Version professeur / élève (bfcours-use_rdexo_rdcrep)
#import "src/publique.typ": ifcorrection

// Double syntaxe commande / environnement : #begin(f, …) … #end(f), passe `environnements`
#import "src/environnements.typ": begin, end, environnements

// Alias de commandes : #let mc = alias(MultiColonnes, cles: (columns: "nb"))
#import "src/alias.typ": alias

// Caractères : œ, Œ, €
#import "src/publique.typ": oe, OE, euro

// Réglages du socle, couleurs nommées, styles nommés communs
#import "src/publique.typ": definir-style, setbfcolors, setbfsocle

// Couleurs (bfcours-colors.sty) et commandes xcolor
#import "src/publique.typ": (
  CouleurTexteAccent, CouleursSecondaryTabular, CouleursTabular, ResetCouleurTexteAccent,
  ResetCouleursSecondaryTabular, ResetCouleursTabular, colorlet, couleurItem, definecolor, resetItemBaseColor,
  textcolor, xcolor,
)

// Macros d'état de couleur lues dans les cours (lecture, dans un `context`) ; les autres : xcolor("<macro>")
#import "src/publique.typ": currentAccentColor, currentTableColTitleColor, currentTableColbackTitleColor, itemBaseColor
