// farfadet-extras — pellicule de film, code Python mis en forme, habillage de figures, icônes.
//
//   #import "lib.typ": *
//
// Ce fichier n'exporte QUE les noms publics (façade) et le module `interne` (noms du moteur, seul point
// d'entrée des autres paquets). 

// Noms du moteur (pour les autres paquets farfadet-*)
#import "interne.typ"

// Réglages : l'unique setter `setbfextras`
#import "src/regler.typ": setbfextras

// Pellicule de film
#import "src/film.typ": clip-image, colored-small-box, filmbox, filmt, whitebox

// Code Python mis en forme
#import "src/python.typ": bf-code-python

// Habillage de figure (wrap-it), icônes (ficons)
#import "src/habillage.typ": habiller
#import "src/icones.typ": icone
