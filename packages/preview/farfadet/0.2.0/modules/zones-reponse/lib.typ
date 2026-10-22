// farfadet-crep — Zones de réponse : crep, tccrep, tcfillcrep, tableaux Seyès, dembox, crepbox, cases à cocher
// (checkbox, tcbcheckbox, tccheckbox) et cases cb, ccb, mysquare.
//
//   #import "lib.typ": *
//
// Ce fichier n'exporte QUE les noms publics et le module
// `interne` (noms du moteur, STABLES, seul point d'entrée des autres paquets farfadet-*).
// Le seul réglage du paquet est `setrdcrep` (types « checkbox », « tcbcheckbox » compris).
// La version prof/élève (`ifcorrection`) est publiée par farfadet-socle.
// Guide : docs/guide.pdf.

// Noms du moteur (pour les autres paquets farfadet-*)
#import "interne.typ"

// rdcrep : réglage, zones de réponse, boîtes dérivées, texte de correction
#import "src/reponses.typ": (
  setrdcrep, crep, tccrep, tcfillcrep, repsim, tcfraccrep, seyesrep, assosbox, seyesfig, dembox, crepbox,
  correction-box, crepcorrectionfont,
)
// rdcrep : tableaux Seyès
#import "src/tableaux-seyes.typ": seyestab, seyesarray
// rdcheckbox, boîtes à cocher de rdcrep ; cases de bfcours
#import "src/cases.typ": checkbox, tcbcheckbox, tccheckbox, tccheckboxlist, cb, ccb, mysquare
