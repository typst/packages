// interne.typ (farfadet-enum) — noms du MOTEUR, seul point d'entrée pour les autres paquets.
// Fichier généré : ne pas modifier à la main.
// Noms STABLES : jamais renommés ni retirés (les autres paquets en dépendent) ; on peut en ajouter.
// Emploi depuis un autre paquet :
//   #import "lib.typ": interne as _x
//   #import _x: nom-1, nom-2

#import "src/moteur/listes.typ": (
  bf-registre-enum, tcbitem, bf-lire-item, bf-largeurs-colonnes, bf-grille-egale, bf-enum-niveau,
  bf-enum-compteurs, bf-enum-numero, bfd-enum-level, bfd-enum-num, bfd-enum-label, bf-badge-enum,
  tcbenumerate-cles, bf-liste-niveau, bf-etiquette-enum, itemize, enumerate, puces, regles-listes,
)
#import "src/moteur/colonnes.typ": (
  bf-tcb-defaut, bf-couleur-tcb, bf-police-tcb, bf-resoudre-tcb, bf-appliquer-police, bf-halign, bf-boite,
  bf-raster, tcolorbox, tcbox, tcbraster,
)
