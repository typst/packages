// interne.typ (farfadet-qcm) — noms du MOTEUR, seul point d'entrée pour les autres paquets.
// Fichier généré : ne pas modifier à la main.
// Noms STABLES : jamais renommés ni retirés (les autres paquets en dépendent) ; on peut en ajouter.
// Emploi depuis un autre paquet :
//   #import "lib.typ": interne as _x
//   #import _x: nom-1, nom-2

#import "src/moteur/boite.typ": (
  mcq-sans, mcq-tailles, mcq-tcb-controles, mcq-tcb-defauts, mcq-verifier-style, mcq-fusionner, mcq-evaluer,
  mcq-regles, mcq-marges, mcq-boite,
)
#import "src/moteur/cases.typ": (
  bf-mcq-br, registre-rdmcqcb, registre-rdmcqrb, mcq-dessin-cb, mcq-dessin-rb, mcq-cb, mcq-rb,
)
#import "src/moteur/formats.typ": (
  rdmcqCounterFormat, mcq-formats-predefinis, bf-mcq-formats, mcq-formats-globaux,
)
#import "src/moteur/mcq.typ": (
  bf-mcq-question, bf-mcq-reponse, bf-mcq-courant, mcq-defauts, registre-mcq, mcq-raccourcis, mcq-geometrie,
  mcq-grille, mcq-rangee, mcq-environnement, mcq-question,
)
