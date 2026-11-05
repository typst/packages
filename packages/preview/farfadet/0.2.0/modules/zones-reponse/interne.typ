// interne.typ (farfadet-crep) — noms du MOTEUR, seul point d'entrée pour les autres paquets.
// Fichier généré : ne pas modifier à la main.
// Noms STABLES : jamais renommés ni retirés (les autres paquets en dépendent) ; on peut en ajouter.
// Emploi depuis un autre paquet :
//   #import "lib.typ": interne as _x
//   #import _x: nom-1, nom-2

#import "src/moteur/crep.typ": (
  seyes-unite, crep-compteur, tccrep-compteur, lignes-seyes, tccrep, tcfillcrep, tcautocrep, repsim,
  tcfraccrep, correction-box, crep-correction-font, setrdcrep, crep, seyesrep, assosbox, dembox, crepbox,
  seyesskip, seyesfig,
)
#import "src/moteur/reglages.typ": (
  crep-defauts-communs, crepbox-defauts, checkbox-defauts, checkbox-skins-noms, checkbox-marks-noms,
  tcbcheckbox-defauts, crep-types, crep-controles, crep-styles-defaut, registre-crep, crep-preset-rd,
  crep-correction, crep-style, crep-resoudre,
)
#import "src/moteur/checkbox.typ": (
  checkbox-rendu, checkbox, tcbcheckbox, tccheckbox, tccheckboxlist, cb, ccb,
)
#import "src/moteur/seyestab.typ": (
  seyestab-colonnes, seyestab-rendu, seyestab, seyesarray,
)
#import "src/moteur/bfcours.typ": (
  mysquare,
)
#import "src/moteur/formes.typ": (
  checkbox-skins, checkbox-marks,
)
