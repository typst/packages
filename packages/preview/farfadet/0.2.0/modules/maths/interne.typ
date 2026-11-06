// interne.typ (farfadet-maths) — noms du MOTEUR, seul point d'entrée pour les autres paquets.
// Fichier généré : ne pas modifier à la main.
// Noms STABLES : jamais renommés ni retirés (les autres paquets en dépendent) ; on peut en ajouter.
// Emploi depuis un autre paquet :
//   #import "lib.typ": interne as _x
//   #import _x: nom-1, nom-2

#import "src/moteur/maths.typ": (
  R, N, Z, Q, C, D, vecteur, vect, crochets, crochet-seul, crochet-adapte, pastille-avec, intervalle, rep,
)
#import "src/moteur/texte.typ": (
  bf-texte-brut, acc, frquote, pascalc, vspace, hspace, needspace, coloredsquare, dimcoloredsquare,
  boite-en-ligne, encadrer, surligner, si, alors, donc, et, mais, car, puisque, ssi,
)
