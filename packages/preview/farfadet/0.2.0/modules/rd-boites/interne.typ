// interne.typ (rdboites) — noms du MOTEUR, seul point d'entrée pour les autres paquets.
// Fichier généré : ne pas modifier à la main.
// Noms STABLES : jamais renommés ni retirés (les autres paquets en dépendent) ; on peut en ajouter.
// Emploi depuis un autre paquet :
//   #import "lib.typ": interne as _x
//   #import _x: nom-1, nom-2

#import "src/rd-outils.typ": (
  sans, police-titre, police-manuscrite, gris, palette, pale, espace, t-notes, t-script, t-minuscule,
  t-grand, resoudre, chiffres, titre-corps, deux-parties, colorer, ombre-floue, icone-alerte, compteur,
  reinitialiser-compteur, reinitialiser-scratch, courbe-ronde, rectangle-dechire, calque, calque-ligne,
  vertical, prof, case,
)
