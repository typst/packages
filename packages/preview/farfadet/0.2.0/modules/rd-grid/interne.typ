// interne.typ (rdgrid) — noms du MOTEUR, seul point d'entrée pour les autres paquets.
// Fichier généré : ne pas modifier à la main.
// Noms STABLES : jamais renommés ni retirés (les autres paquets en dépendent) ; on peut en ajouter.
// Emploi depuis un autre paquet :
//   #import "lib.typ": interne as _x
//   #import _x: nom-1, nom-2

#import "src/moteur/commun.typ": (
  rd-regler, rd-style-cles, rd-controle-style, rd-style, rd-style-fusion, rd-couleur, rd-police,
  rd-appliquer-police, rd-texte, rd-trait, rd-fond, rd-hauteur, rd-profondeur, rd-boite, rd-haut-cadre,
  rd-abs, rd-marges, rd-noeud, rd-noeud-en-ligne, rd-local, rd-node-at,
)
#import "src/moteur/rdgrid.typ": (
  rdgrid-types, rdgrid-reglages, rdgrid-polygones, rdgrid-options-tikz, rdgrid-rendu,
)
