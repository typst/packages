// interne.typ (farfadet-modele) — noms du MOTEUR, seul point d'entrée pour les autres paquets.
// Fichier généré : ne pas modifier à la main.
// Noms STABLES : jamais renommés ni retirés (les autres paquets en dépendent) ; on peut en ajouter.
// Emploi depuis un autre paquet :
//   #import "lib.typ": interne as _x
//   #import _x: nom-1, nom-2

#import "src/moteur/modele.typ": (
  bfcours-valeurs, bfcours-page, bfcours-texte, farfadet,
)
#import "src/moteur/entetes.typ": (
  modele-reglages, chapitre, chapeval, pied-de-page, sequence-item,
)
