// interne.typ (farfadet-tableaux) — noms du MOTEUR, seul point d'entrée pour les autres paquets.
// Fichier généré : ne pas modifier à la main.
// Noms STABLES : jamais renommés ni retirés (les autres paquets en dépendent) ; on peut en ajouter.
// Emploi depuis un autre paquet :
//   #import "lib.typ": interne as _x
//   #import _x: nom-1, nom-2

#import "src/moteur/tableaux.typ": (
  hline, cline, cellule, multicolumn, bf-analyser-spec, bf-tabular, tabular, tcbtab, tcbtabc, tcbtabx,
  tcbtabcomp, tableau, _boite-tableau as bf-boite-tableau,
)
#import "src/moteur/natif.typ": (
  bf-reglages-tableaux, bf-styles-tableaux, bf-rangees, bf-couleur-rangee, bf-tableau,
)
