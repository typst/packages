// farfadet-geom — figures de géométrie plane aux couleurs de bfcours : une COUCHE LÉGÈRE sur cetz.
//
//   #import "lib.typ": *
//
//   #geo({
//     repere(x: (-1, 5), y: (-1, 4))
//     triangle((0, 0), (4, 0), (4, 3), noms: ("A", "B", "C"), angles-droits: (1,))
//   })
//
// Style : couleurs nommées de bfcours (lues au rendu), réglable par `setbfgeom(…)`. Pas de 3D (voir plotsy-3d).
// Ce fichier n'exporte QUE les noms publics et le module `interne`. 

// Noms du moteur
#import "interne.typ"

// Canevas et réglages
#import "src/cadre.typ": figure-geo, geo
#import "src/reglages.typ": setbfgeom

// Repère et courbe
#import "src/repere.typ": courbe, repere

// Objets
#import "src/objets.typ": arc, cercle, demi-droite, droite, point, polygone, segment, triangle, fleche, fleche-de

// Tracés libres (étiquette, ligne brisée, quadrillage, axes)
#import "src/traces.typ": axe, axes, etiquette, ligne-brisee, quadrillage

// Codages
#import "src/codages.typ": angle-droit, angle-marque, codage-parallele, codage-segment

// Constructions (tracés) et calculs (fonctions pures sur des points)
#import "src/constructions.typ": bissectrice, hauteur, mediatrice
#import "src/outils.typ": distance, intersection, milieu, projete
