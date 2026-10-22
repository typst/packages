// interne.typ (rdsheet) — noms du MOTEUR, seul point d'entrée pour les autres paquets.
// Fichier généré : ne pas modifier à la main.
// Noms STABLES : jamais renommés ni retirés (les autres paquets en dépendent) ; on peut en ajouter.
// Emploi depuis un autre paquet :
//   #import "lib.typ": interne as _x
//   #import _x: nom-1, nom-2

#import "src/moteur/commun.typ": (
  rd-regler, rd-local, rd-couleur,
)
#import "src/moteur/rdsheet.typ": (
  rd-palette, rd-cles-style, rdsheet-reglages, rdsheet-cles, rd-lettres, rd-colonne-entier, rd-indices,
  rdsheet-rendu,
)
