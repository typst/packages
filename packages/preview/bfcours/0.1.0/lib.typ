// bfcours-typst — méta-paquet : réexporte la façade publique des paquets bfcours-* et rd*.
//
//   #import "@preview/bfcours:0.1.0": *
//   #show: modele("cours", niveau: "2nde", theme: [Les vecteurs], correction: false)
//   #Definition[Vecteur][…]
//
// Ce fichier n'exporte QUE des noms publics, par imports nominatifs (ni `interne` ni moteur). Chaque nom
// vient d'une seule façade : aucune collision entre paquets.

// Socle : version prof/élève, couleurs nommées, réglages communs (bfcours-socle)
#import "modules/socle/lib.typ": (
  ifcorrection, begin, end, environnements, alias, oe, OE, euro, definir-style, setbfcolors, setbfsocle, CouleurTexteAccent, CouleursSecondaryTabular,
  CouleursTabular, ResetCouleurTexteAccent, ResetCouleursSecondaryTabular, ResetCouleursTabular, colorlet,
  couleurItem, definecolor, resetItemBaseColor, textcolor, xcolor, currentAccentColor, currentTableColTitleColor,
  currentTableColbackTitleColor, itemBaseColor,
)

// Environnements didactiques, sections, sommaire, vocabulaire (bfcours-didactique)
#import "modules/didactique/lib.typ": (
  Activite, Aide, ContreExemple, Definition, Demonstration, Exemple, Histoire, Methode, None, Notation,
  Propriete, Remarque, Solution, Theoreme, Vocabulaire, bfEnv, bfbox, boite, boiteFigure, cracked,
  NewBfdPalette, bfdActivatePalette, bfdActivateVariant, bfset, setbfenvironments, setbfskins, bfskin, coloredsquare,
  dimcoloredsquare, liencontent, setbfsections, tableofcontents, printvocindex, tableauVocabulaireSommaire, voc,
  vocref,
)

// Modèle de document, en-têtes, pied de page (bfcours-modele)
#import "modules/modeles/lib.typ": (
  bfcours, SequenceItem, chapEval, chapitre, pied-de-page, modele, choiceFontsDys, setbfmodele,
)

// Maths, texte, connecteurs, nombres et unités (bfcours-maths)
#import "modules/maths/lib.typ": (
  setbfmaths, sisetup, CrochetD, CrochetG, Coordonnees, DD, Rep, Vecteur, intervalle, affiche, acc, encadrer,
  frquote, lien, needspace, outilcours, pascalc, surligner, Alors, Car, Donc, Et, Mais, Puisque, SSI, Si, np,
  num, qty, unit,
)

// Énumérations et colonnage (bfcours-enum)
#import "modules/enumerations/lib.typ": (
  setbfenum, MultiColonnes, tcbitem, tcbraster, enumerate, itemize, tcbenumerate, bfdEnumLabel, bfdEnumLevel,
  bfdEnumNum,
)

// Tableaux (bfcours-tableaux)
#import "modules/tableaux/lib.typ": (
  tcbtab, hline, cline, multicolumn, multirow, cellcolor, tableaurecapsequence, enteteContenu, recapHeures,
  setbftableaux,
)

// Zones de réponse, cases à cocher (bfcours-crep)
#import "modules/zones-reponse/lib.typ": (
  setrdcrep, crep, tccrep, tcfillcrep, repsim, tcfraccrep, seyesrep, assosbox, seyesfig, dembox, crepbox,
  CorrectionBox, crepcorrectionfont, seyestab, seyesarray, checkbox, tcbcheckbox, tccheckbox, tccheckboxlist, cb,
  ccb, mysquare,
)

// Exercices, corrections, points, évaluation (bfcours-exo)
#import "modules/exo/lib.typ": (
  EXO, EXOEVAL, setrdexo, rdexoSkin, rdexostars, rdexocorrection, exocorrection, tcblower, rdexofilter, rdexoresetfilter, rdexohlist,
  rdexotikzlist, rdexocountlist, thenumexo, rdexonumexo, thescore, theScore, rdexoscore, thelevel, theexotitle,
  theExotitle, rdexotitlefont, thetags, thelabel, rdexotags, TFNumexo, TFScore, TFLevel, TFTitle, TFTags,
  rdexoEnonceLabel, rdexoSolutionLabel, rdifficulty, rdexoMod, rdexoinclude, itempoint,
  infotcbitempoint, displayitempoints, baremepoint, displaybaremepoints, getinfoexopoint, getsavedtotalpoints,
  getsavedinfototalpoints, competence, tableaucompetence, tableaucompetenceEval, printcompindex, tableauEval,
  tableauProjetEval, tableauPresenteEvalSixieme, chrono, overlaychrono, mi, mf, ms, tbm, chapitreBac,
  chapitreBrevet, styleExoBac, styleExoBrevet, styleQuestionsBac, styleExercicesBac, numeroterBac, partieBac,
  consigneBac, encadreBac, encadreBacEtroit, corrigeBac, bfexobacUline, exolombards, styleExoLombards,
  correctionsLombards, corrigeLombards, exolombardsEtiquette, exolombardsTitre, exolombardsBareme,
  exolombardsMotCorrection,
)

// QCM et vrai/faux (bfcours-qcm)
#import "modules/qcm/lib.typ": Mcq, McqQuest, setrdmcq, affirmation, vrai-faux

// Film, code Python, habillage de figures, icônes (bfcours-extras)
#import "modules/extras/lib.typ": (
  setbfextras, ClipImage, ColoredSmallBox, filmbox, filmt, whitebox, BFCodePython, habiller, icone,
)

// Extraits LaTeX (bfcours-latex)
#import "modules/extraits-latex/lib.typ": latex, latex-avec, setbflatex

// Tableaux de signes et de variations (bfcours-tabvar)
#import "modules/variations/lib.typ": tabvar, tkzTabLine, tkzTabVar, setbftabvar

// Figures de géométrie plane sur cetz : repère, courbes, objets, codages, constructions (bfcours-geom)
#import "modules/geom/lib.typ": (
  geo, figure-geo, setbfgeom, repere, courbe, point, segment, droite, demi-droite, vecteur, vecteur-de, cercle,
  arc, polygone, triangle, codage-segment, angle-droit, angle-marque, codage-parallele, mediatrice, bissectrice,
  hauteur, milieu, projete, intersection, distance,
)

// Boîtes rd (module `rd`) (rdboites)
#import "modules/rd-boites/lib.typ": rd, cles-rd, setrdboites

// Horloges et durées (rdtime)
#import "modules/rd-time/lib.typ": rdtime, setrdtime

// Proportionnalité (rdratio)
#import "modules/rd-ratio/lib.typ": rdratio, dratio, sumlist, setrdratio

// Grilles (rdgrid)
#import "modules/rd-grid/lib.typ": rdgrid, setrdgrid

// Arithmétique : décompositions, diviseurs, PGCD (rdarithm)
#import "modules/rd-arithm/lib.typ": (
  setrdarithm, ListeFP, DecompFP, ListeDiviseurs, TabDiviseurs, pgcd, ppcm, TabPGCD, RowPGCD, DecompFrac,
  fracirr, dfracirr,
)

// Tableaux de conversion (rdconv)
#import "modules/rd-conv/lib.typ": (
  rdconv, rdplace, rdconvert, rdconvemptyline, rdconvtext, setrdconv, rdtheme, rdconvdingnum, rdconvbadge,
)

// Opérations posées (rdopp)
#import "modules/rd-opp/lib.typ": rdopp, setrdopp

// Feuilles de calcul (rdsheet)
#import "modules/rd-sheet/lib.typ": rdsheet, setrdsheet, rdsheetsetup

// Tableaux de numération (rdtabnum)
#import "modules/rd-tabnum/lib.typ": (
  rdtabnum, rdtnplace, rdtnconvert, rdtnemptyline, rdtnArrow, rdtnsurcouche, setrdtabnum, rdtabnumarrowcol,
  rdtnpurple,
)

// Chaque partie de la suite est aussi un module, pour n'importer que ce dont on a besoin :
//   #import "@preview/bfcours:0.1.0": exo
//   #import exo: *
// Un module expose la façade de son paquet (et `interne`, réservé aux autres modules).
#import "modules/socle/lib.typ" as socle
#import "modules/didactique/lib.typ" as didactique
#import "modules/enumerations/lib.typ" as enumerations
#import "modules/tableaux/lib.typ" as tableaux
#import "modules/zones-reponse/lib.typ" as zones-reponse
#import "modules/exo/lib.typ" as exo
#import "modules/qcm/lib.typ" as qcm
#import "modules/maths/lib.typ" as maths
#import "modules/modeles/lib.typ" as modeles
#import "modules/extras/lib.typ" as extras
#import "modules/extraits-latex/lib.typ" as extraits-latex
#import "modules/variations/lib.typ" as variations
#import "modules/geom/lib.typ" as geom
#import "modules/rd-boites/lib.typ" as rd-boites
#import "modules/rd-time/lib.typ" as rd-time
#import "modules/rd-ratio/lib.typ" as rd-ratio
#import "modules/rd-grid/lib.typ" as rd-grid
#import "modules/rd-arithm/lib.typ" as rd-arithm
#import "modules/rd-conv/lib.typ" as rd-conv
#import "modules/rd-opp/lib.typ" as rd-opp
#import "modules/rd-sheet/lib.typ" as rd-sheet
#import "modules/rd-tabnum/lib.typ" as rd-tabnum
