// interne.typ (farfadet-tabvar) — noms du MOTEUR, seul point d'entrée pour les autres paquets.
// Écrit à la main.
// Noms STABLES : jamais renommés ni retirés ; on peut en ajouter. Emploi depuis un autre paquet :
//   #import "lib.typ": interne as _x
//   #import _x: tabvar-construire

#import "src/reglages.typ": reglages-tabvar
#import "src/lignes.typ": _contenu as tabvar-contenu, _ac-resolu as tabvar-ac-resolu, _cache as tabvar-cache
#import "src/moteur.typ": _construire as tabvar-construire
