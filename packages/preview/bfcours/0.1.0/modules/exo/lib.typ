// bfcours-exo — Exercices de bfcours (EXO, EXOEVAL) et de rdexo (thèmes, corrections différées, filtre
// d'étiquettes, accesseurs), points et barème, compétences, évaluation, sujets d'examen (exobac, exolombards).
//
//   #import "lib.typ": *
//
// Ce fichier n'exporte que les noms publics et le module `interne` (noms du moteur, seul point d'entrée
// des autres paquets). Un seul réglage : `setrdexo` (exercices, thèmes `skin:`, étoiles, boîtes de
// points, tableaux, sujets d'examen). Guide : docs/guide.pdf.

// Noms du moteur (pour les autres paquets bfcours-*)
#import "interne.typ"

// Exercices : EXO, EXOEVAL, réglage unique, thèmes, étoiles, corrections, filtre, listes, accesseurs rdexo
#import "src/exercices.typ": (
  EXO, EXOEVAL, setrdexo, rdexoSkin, rdexostars, rdexocorrection, exocorrection, tcblower, rdexofilter, rdexoresetfilter,
  rdexohlist, rdexotikzlist, rdexocountlist, thenumexo, rdexonumexo, thescore, theScore, rdexoscore,
  thelevel, theexotitle, theExotitle, rdexotitlefont, thetags, thelabel, rdexotags, TFNumexo, TFScore,
  TFLevel, TFTitle, TFTags, rdexoEnonceLabel, rdexoSolutionLabel, rdifficulty, rdexoMod, rdexoinclude,
)

// Points et barème
#import "src/points.typ": (
  itempoint, infotcbitempoint, displayitempoints, baremepoint, displaybaremepoints,
  getinfoexopoint, getsavedtotalpoints, getsavedinfototalpoints,
)

// Compétences et évaluation
#import "src/evaluation.typ": (
  competence, tableaucompetence, tableaucompetenceEval, printcompindex, tableauEval, tableauProjetEval,
  tableauPresenteEvalSixieme, chrono, overlaychrono, mi, mf, ms, tbm,
)

// Sujets d'examen (bfcours-exobac) et habillage exolombards
#import "src/sujets.typ": (
  chapitreBac, chapitreBrevet, styleExoBac, styleExoBrevet, styleQuestionsBac, styleExercicesBac,
  numeroterBac, partieBac, consigneBac, encadreBac, encadreBacEtroit, corrigeBac, bfexobacUline,
  exolombards, styleExoLombards, correctionsLombards, corrigeLombards, exolombardsEtiquette,
  exolombardsTitre, exolombardsBareme, exolombardsMotCorrection,
)
