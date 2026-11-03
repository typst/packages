// farfadet-socle — Fondations des paquets farfadet-* : version prof/élève, couleurs (port de
// bfcours-colors.sty), mesures, police, français, points, mécanisme générique de réglages.
//
//   #import "lib.typ": *
//
// Ce fichier n'exporte QUE les noms publics (façade, noms LaTeX exacts) et le module `interne` (noms du moteur, STABLES, seul point d'entrée des autres paquets).

// Noms du moteur (pour les autres paquets farfadet-*)
#import "interne.typ"

// Version professeur / élève (bfcours-use_rdexo_rdcrep)
#import "src/publique.typ": ifcorrection

// Double syntaxe commande / environnement : #begin(f, …) … #end(f), passe `environnements`
#import "src/environnements.typ": begin, end, environnements

// Alias de commandes : #let mc = alias(MultiColonnes, cles: (columns: "nb"))
#import "src/alias.typ": alias

// Caractères : œ, Œ, €
#import "src/publique.typ": oe, oe-maj, euro

// Réglages du socle, couleurs nommées, styles nommés communs
#import "src/publique.typ": definir-style, setbfcolors, setbfsocle

// Couleurs (bfcours-colors.sty) et commandes xcolor
#import "src/publique.typ": (
  couleur-texte-accent, couleurs-secondary-tabular, couleurs-tabular, reset-couleur-texte-accent,
  reset-couleurs-secondary-tabular, reset-couleurs-tabular, colorlet, couleur-item, definecolor, reset-item-base-color,
  textcolor, xcolor,
)

// Macros d'état de couleur lues dans les cours (lecture, dans un `context`) ; les autres : xcolor("<macro>")
#import "src/publique.typ": current-accent-color, current-table-col-title-color, current-table-colback-title-color, item-base-color
