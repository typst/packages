// interne.typ (rdconv) — noms du MOTEUR, seul point d'entrée pour les autres paquets.
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
#import "src/moteur/rdconv.typ": (
  rdconv-unites, rdconv-nom-unite, rdconv-rang-unite, rdconv-unite-affichee, rdconv-lire-nombre,
  rdconv-decaler, rdconv-valeur-affichee, rdconv-placer, rdconv-convertir, rdconv-defauts,
  rdconv-base-defaut, rdconv-ajoute-defaut, rdconv-virgule-defaut, rdconv-rature-defaut, rdconv-controles,
  rdconv-sans, rdconv-magenta, rdconv-bleu-fonce, rdconv-bleu-moyen, rdconv-bleu-clair, rdconv-bleu,
  rdconv-sarcelle, rdconv-rouge, rdconvdingnum, rdconvbadge, rdconv-theme, rdconv-styles, rdconv-reglages,
  rdconv-rendu,
)
