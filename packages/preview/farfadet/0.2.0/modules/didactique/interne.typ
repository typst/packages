// interne.typ (farfadet-didactique) — noms du MOTEUR, seul point d'entrée pour les autres paquets.
// Fichier généré : ne pas modifier à la main.
// Noms STABLES : jamais renommés ni retirés (les autres paquets en dépendent) ; on peut en ajouter.
// Emploi depuis un autre paquet :
//   #import "lib.typ": interne as _x
//   #import _x: nom-1, nom-2

#import "src/moteur/didactique.typ": (
  bf-avec-couleurs, bf-entree-sommaire, bf-nom-banniere, bf-polygone, bf-craie, bf-craie-allegement,
  bf-craie-teinte, bf-environnement, theoreme, definition, propriete, demonstration, methode, activite,
  vocabulaire, solution, bf-exemple, exemple, contreexemple, contre-exemple, remarque, bf-graine-cracked,
  cracked, notation, aide, bfenv, bf-boitecouleur, bfbox, bf-boite, boitefigure, neutre, none-env,
  couleur-histoire, histoire, bfd-hook-theoreme, bfd-hook-definition,
)
#import "src/moteur/sectionnement.typ": (
  couleur-titres, bf-couleur-titres, bf-appliquer-jeu-titres, bf-reglages-titre, bf-bandeau-section,
  bf-bandeau-sous-section, bf-numero-section, tableofcontents, sommaire, _regles-titres as bf-regles-titres,
)
#import "src/moteur/vocabulaire.typ": (
  voc, printvocindex,
)
#import "src/reglages.typ": (
  _appliquer-environnements as bf-appliquer-environnements,
)
