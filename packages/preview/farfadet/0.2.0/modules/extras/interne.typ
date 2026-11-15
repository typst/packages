// interne.typ (farfadet-extras) — noms du MOTEUR, seul point d'entrée pour les autres paquets.
// Fichier généré : ne pas modifier à la main.
// Noms STABLES : jamais renommés ni retirés (les autres paquets en dépendent) ; on peut en ajouter.
// Emploi depuis un autre paquet :
//   #import "lib.typ": interne as _x
//   #import _x: nom-1, nom-2

#import "src/moteur/complements.typ": (
  habiller, icone,
)
#import "src/moteur/film.typ": (
  bf-film-perforations, bf-film-couleurs-haut, bf-film-cadre, bf-film-image-largeur, bf-film-clip,
  bf-film-boite-bicolore,
)
#import "src/moteur/python.typ": (
  bf-python-theme, bf-python-coins, bf-python-boite,
)
