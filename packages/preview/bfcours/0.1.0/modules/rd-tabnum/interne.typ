// interne.typ (rdtabnum) — noms du MOTEUR, seul point d'entrée pour les autres paquets.
// Fichier généré : ne pas modifier à la main.
// Noms STABLES : jamais renommés ni retirés (les autres paquets en dépendent) ; on peut en ajouter.
// Emploi depuis un autre paquet :
//   #import "lib.typ": interne as _x
//   #import _x: nom-1, nom-2

#import "src/moteur/commun.typ": (
  rd-regler, rd-style-cles, rd-controle-style, rd-style, rd-style-fusion, rd-couleur, rd-police,
  rd-appliquer-police, rd-texte, rd-trait, rd-fond, rd-hauteur, rd-profondeur, rd-boite, rd-haut-cadre,
  rd-abs, rd-marges, rd-noeud, rd-local,
)
#import "src/moteur/rdtabnum.typ": (
  rdtabnumarrowcol, rdtnpurple, rdtabnum-reglages, rdtnarrow-reglages, rdtabnum-developper,
  rdtabnum-developper-fleche, rdtabnum-borne-depart, rdtabnum-borne-fin, rdtabnum-lire-nombre,
  rdtabnum-rendu, rdtabnum-construire, rdtabnum-aplatir,
)
