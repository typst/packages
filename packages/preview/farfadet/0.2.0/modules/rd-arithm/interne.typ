// interne.typ (rdarithm) — noms du MOTEUR, seul point d'entrée pour les autres paquets.
// Fichier généré : ne pas modifier à la main.
// Noms STABLES : jamais renommés ni retirés (les autres paquets en dépendent) ; on peut en ajouter.
// Emploi depuis un autre paquet :
//   #import "lib.typ": interne as _x
//   #import _x: nom-1, nom-2

#import "src/moteur/commun.typ": (
  rd-regler, rd-style-cles, rd-controle-style, rd-controle-styles-numerotes, rd-style, rd-style-fusion,
  rd-couleur, rd-police, rd-appliquer-police, rd-texte, rd-trait, rd-fond, rd-hauteur, rd-profondeur,
  rd-boite, rd-haut-cadre, rd-abs, rd-marges, rd-noeud, rd-noeud-en-ligne, rd-bord, rd-cycle, rd-liste,
  rd-local, rd-node-at,
)
#import "src/moteur/rdarithm.typ": (
  rdarithm-couleurs, ra-couleur, rdarithm-reglages, ra-facteurs, ra-diviseurs, ra-pgcd, ra-ppcm, ra-colonnes,
  ra-puissances, ra-avec-puissances, ra-produit, ra-contenu, ra-ancres, ra-aligne, ra-matrice,
  ra-tableau-deux, ra-listefp, ra-decompfp, xmix-light, ra-decompfpa, ra-decompfpb, ra-decompfpc,
  ra-tabdiviseurs, ra-listediviseurs, ra-tabpgcd, ra-lignes-communes, ra-rowpgcd, ra-decompfrac, ra-ecrire,
)
