// farfadet-qcm — QCM de bfcours : rdmcq et format BFCours, plus l'exercice vrai/faux.
//
//   #import "lib.typ": *
//
// Ce fichier n'exporte QUE les noms publics (façade) et le module `interne` (noms du moteur, seul point
// d'entrée des autres paquets). Façade épurée le 07/10/2026 : 5 noms.
//   Mcq, McqQuest  : questionnaire à choix multiples (rdmcq), formats choisis par la clé `style:`
//   setrdmcq       : setter unique (Mcq, cases `rdmcqcb`/`rdmcqrb`, `vrai-faux`, styles nommés)
//   vrai-faux, affirmation : exercice « vrai ou faux »
// Guide : docs/guide.pdf.

// Noms du moteur (pour les autres paquets farfadet-*)
#import "interne.typ"

#import "src/rdmcq.typ": mcq, mcq-quest, setrdmcq
#import "src/vrai-faux.typ": affirmation, vrai-faux
