// interne.typ (farfadet-geom) — noms du MOTEUR, seul point d'entrée pour les autres paquets.
// Écrit à la main.
// Noms STABLES : jamais renommés ni retirés ; on peut en ajouter. Emploi depuis un autre paquet :
//   #import "lib.typ": interne as _g
//   #import _g: elem, couleur-de, trait

#import "src/reglages.typ": _R as registre-geom, noms-couleurs as geom-noms-couleurs, reglages-geom
#import "src/base.typ": couleur-de, elem, etiquette, fenetre-de, nom-math, nom-vecteur, trait, u as geom-unites
#import "src/rapide.typ": (
  contenu as geom-contenu, fleche as geom-fleche, ligne as geom-ligne, segments as geom-segments,
)
#import "src/outils.typ": (
  ajouter as geom-ajouter, couper as geom-couper, multiplier as geom-multiplier, norme as geom-norme,
  retrancher as geom-retrancher, unitaire as geom-unitaire, verifier-point as geom-verifier-point,
)
