// farfadet-exo — Exercices de bfcours (EXO, EXOEVAL) et de rdexo (thèmes, corrections différées, filtre
// d'étiquettes, accesseurs), points et barème, compétences, évaluation, sujets d'examen (exobac, exolombards).
//
//   #import "lib.typ": *
//
// Ce fichier n'exporte que les noms publics et le module `interne` (noms du moteur, seul point d'entrée
// des autres paquets). Un seul réglage : `setrdexo` (exercices, thèmes `skin:`, étoiles, boîtes de
// points, tableaux, sujets d'examen). Guide : docs/guide.pdf.

// Noms du moteur (pour les autres paquets farfadet-*)
#import "interne.typ"

// Exercices : EXO, EXOEVAL, réglage unique, thèmes, étoiles, corrections, filtre, listes, accesseurs rdexo
#import "src/exercices.typ": (
  exo, exo-eval, setrdexo, rdexo-skin, rdexostars, rdexocorrection, exocorrection, tcblower, rdexofilter, rdexoresetfilter,
  rdexohlist, rdexotikzlist, rdexocountlist, thenumexo, rdexonumexo, thescore, thescore-libelle, rdexoscore,
  thelevel, theexotitle, theexotitle-style, rdexotitlefont, thetags, thelabel, rdexotags, tf-numexo, tf-score,
  tf-level, tf-title, tf-tags, rdexo-enonce-label, rdexo-solution-label, rdifficulty, rdexo-mod, rdexoinclude,
)

// Points et barème
#import "src/points.typ": (
  itempoint, infotcbitempoint, displayitempoints, baremepoint, displaybaremepoints,
  getinfoexopoint, getsavedtotalpoints, getsavedinfototalpoints,
)

// Compétences et évaluation
#import "src/evaluation.typ": (
  competence, tableaucompetence, tableaucompetence-eval, printcompindex, tableau-eval, tableau-projet-eval,
  tableau-presente-eval-sixieme, chrono, overlaychrono, mi, mf, ms, tbm,
)

// Sujets d'examen (bfcours-exobac) et habillage exolombards
#import "src/sujets.typ": (
  chapitre-bac, chapitre-brevet, style-exo-bac, style-exo-brevet, style-questions-bac, style-exercices-bac,
  numeroter-bac, partie-bac, consigne-bac, encadre-bac, encadre-bac-etroit, corrige-bac, bfexobac-uline,
  exolombards, style-exo-lombards, corrections-lombards, corrige-lombards, exolombards-etiquette,
  exolombards-titre, exolombards-bareme, exolombards-mot-correction,
)
