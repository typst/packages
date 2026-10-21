// farfadet-tableaux — Tableaux de bfcours : tcbtab (le tableau encadré), ses aides de filets et de cellules, setbftableaux.
//
//   #import "lib.typ": *
//
// Ce fichier n'exporte QUE les noms publics (façade) et le module `interne` (noms du moteur, seul point
// d'entrée des autres paquets). Les variantes du tableau (centré, secondaire, compact) sont des clés de
// `tcbtab` ; un tableau nu s'écrit avec la `table` native de Typst (voir le guide).
// 

// Noms du moteur (pour les autres paquets farfadet-*)
#import "interne.typ"

// Tableau, aides de cellules, récapitulatif de séquence, setter
#import "src/tableaux.typ": (
  tcbtab, hline, cline, multicolumn, multirow, cellcolor,
  tableaurecapsequence, entete-contenu, recap-heures,
  setbftableaux,
)
