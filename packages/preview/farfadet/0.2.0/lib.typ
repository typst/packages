// farfadet — méta-paquet : réexporte la façade publique des paquets farfadet-* et rd*.
//
//   #import "@preview/farfadet:0.2.0": *
//   #show: modele("cours", niveau: "2nde", theme: [Les vecteurs], correction: false)
//   #definition[Vecteur][…]
//
// Ce fichier n'exporte QUE des noms publics, par imports nominatifs (ni `interne` ni moteur). Chaque nom
// vient d'une seule façade : aucune collision entre paquets.

// Socle : version prof/élève, couleurs nommées, réglages communs (farfadet-socle)
#import "modules/socle/lib.typ": (
  ifcorrection, begin, end, environnements, alias, oe, oe-maj, euro, definir-style, setbfcolors, setbfsocle, couleur-texte-accent, couleurs-secondary-tabular,
  couleurs-tabular, reset-couleur-texte-accent, reset-couleurs-secondary-tabular, reset-couleurs-tabular, colorlet,
  couleur-item, definecolor, reset-item-base-color, textcolor, xcolor, current-accent-color, current-table-col-title-color,
  current-table-colback-title-color, item-base-color,
)

// Environnements didactiques, sections, sommaire, vocabulaire (farfadet-didactique)
#import "modules/didactique/lib.typ": (
  activite, aide, contre-exemple, definition, demonstration, exemple, histoire, methode, neutre, notation,
  propriete, remarque, solution, theoreme, vocabulaire, bf-env, bfbox, boite, boite-figure, cracked,
  new-bfd-palette, bfd-activate-palette, bfd-activate-variant, bfset, setbfenvironments, setbfskins, bfskin, coloredsquare,
  dimcoloredsquare, liencontent, setbfsections, tableofcontents, printvocindex, tableau-vocabulaire-sommaire, voc,
  vocref,
)

// Modèle de document, en-têtes, pied de page (farfadet-modele)
#import "modules/modeles/lib.typ": (
  farfadet, sequence-item, chap-eval, chapitre, pied-de-page, modele, choice-fonts-dys, setbfmodele,
)

// Maths, texte, connecteurs, nombres et unités (farfadet-maths)
#import "modules/maths/lib.typ": (
  setbfmaths, sisetup, crochetd, crochetg, coordonnees, dd, rep, vect, intervalle, affiche, acc, encadrer,
  frquote, lien, needspace, outilcours, pascalc, surligner, alors, car, donc, et, mais, puisque, ssi, si, np,
  num, qty, unit,
)

// Énumérations et colonnage (farfadet-enum)
#import "modules/enumerations/lib.typ": (
  setbfenum, multi-colonnes, tcbitem, tcbraster, enumerate, itemize, tcbenumerate, bfd-enum-label, bfd-enum-level,
  bfd-enum-num,
)

// Tableaux (farfadet-tableaux)
#import "modules/tableaux/lib.typ": (
  tcbtab, hline, cline, multicolumn, multirow, cellcolor, tableaurecapsequence, entete-contenu, recap-heures,
  setbftableaux,
)

// Zones de réponse, cases à cocher (farfadet-crep)
#import "modules/zones-reponse/lib.typ": (
  setrdcrep, crep, tccrep, tcfillcrep, repsim, tcfraccrep, seyesrep, assosbox, seyesfig, dembox, crepbox,
  correction-box, crepcorrectionfont, seyestab, seyesarray, checkbox, tcbcheckbox, tccheckbox, tccheckboxlist, cb,
  ccb, mysquare,
)

// Exercices, corrections, points, évaluation (farfadet-exo)
#import "modules/exercices/lib.typ": (
  exo, exo-eval, setrdexo, rdexo-skin, rdexostars, rdexocorrection, exocorrection, tcblower, rdexofilter, rdexoresetfilter, rdexohlist,
  rdexotikzlist, rdexocountlist, thenumexo, rdexonumexo, thescore, thescore-libelle, rdexoscore, thelevel, theexotitle,
  theexotitle-style, rdexotitlefont, thetags, thelabel, rdexotags, tf-numexo, tf-score, tf-level, tf-title, tf-tags,
  rdexo-enonce-label, rdexo-solution-label, rdifficulty, rdexo-mod, rdexoinclude, itempoint,
  infotcbitempoint, displayitempoints, baremepoint, displaybaremepoints, getinfoexopoint, getsavedtotalpoints,
  getsavedinfototalpoints, competence, tableaucompetence, tableaucompetence-eval, printcompindex, tableau-eval,
  tableau-projet-eval, tableau-presente-eval-sixieme, chrono, overlaychrono, mi, mf, ms, tbm, chapitre-bac,
  chapitre-brevet, style-exo-bac, style-exo-brevet, style-questions-bac, style-exercices-bac, numeroter-bac, partie-bac,
  consigne-bac, encadre-bac, encadre-bac-etroit, corrige-bac, bfexobac-uline, exolombards, style-exo-lombards,
  corrections-lombards, corrige-lombards, exolombards-etiquette, exolombards-titre, exolombards-bareme,
  exolombards-mot-correction,
)

// QCM et vrai/faux (farfadet-qcm)
// farfadet-qcm : chargé au premier appel (imports paresseux)
#let mcq(..a) = { import "modules/qcm/lib.typ": mcq as _f; _f(..a) }
#let mcq-quest(..a) = { import "modules/qcm/lib.typ": mcq-quest as _f; _f(..a) }
#let setrdmcq(..a) = { import "modules/qcm/lib.typ": setrdmcq as _f; _f(..a) }
#let affirmation(..a) = { import "modules/qcm/lib.typ": affirmation as _f; _f(..a) }
#let vrai-faux(..a) = { import "modules/qcm/lib.typ": vrai-faux as _f; _f(..a) }

// Film, code Python, habillage de figures, icônes (farfadet-extras)
// farfadet-extras : chargé au premier appel (imports paresseux)
#let setbfextras(..a) = { import "modules/extras/lib.typ": setbfextras as _f; _f(..a) }
#let clip-image(..a) = { import "modules/extras/lib.typ": clip-image as _f; _f(..a) }
#let colored-small-box(..a) = { import "modules/extras/lib.typ": colored-small-box as _f; _f(..a) }
#let filmbox(..a) = { import "modules/extras/lib.typ": filmbox as _f; _f(..a) }
#let filmt(..a) = { import "modules/extras/lib.typ": filmt as _f; _f(..a) }
#let whitebox(..a) = { import "modules/extras/lib.typ": whitebox as _f; _f(..a) }
#let bf-code-python(..a) = { import "modules/extras/lib.typ": bf-code-python as _f; _f(..a) }
#let habiller(..a) = { import "modules/extras/lib.typ": habiller as _f; _f(..a) }
#let icone(..a) = { import "modules/extras/lib.typ": icone as _f; _f(..a) }

// Extraits LaTeX (farfadet-latex)
// farfadet-latex : chargé au premier appel (imports paresseux)
#let latex(..a) = { import "modules/extraits-latex/lib.typ": latex as _f; _f(..a) }
#let latex-avec(..a) = { import "modules/extraits-latex/lib.typ": latex-avec as _f; _f(..a) }
#let setbflatex(..a) = { import "modules/extraits-latex/lib.typ": setbflatex as _f; _f(..a) }

// Tableaux de signes et de variations (farfadet-tabvar)
// farfadet-tabvar : chargé au premier appel (imports paresseux)
#let tabvar(..a) = { import "modules/variations/lib.typ": tabvar as _f; _f(..a) }
#let tkz-tab-line(..a) = { import "modules/variations/lib.typ": tkz-tab-line as _f; _f(..a) }
#let tkz-tab-var(..a) = { import "modules/variations/lib.typ": tkz-tab-var as _f; _f(..a) }
#let setbftabvar(..a) = { import "modules/variations/lib.typ": setbftabvar as _f; _f(..a) }

// Figures de géométrie plane sur cetz : repère, courbes, objets, codages, constructions (farfadet-geom)
#import "modules/geom/lib.typ": (
  geo, figure-geo, setbfgeom, repere, courbe, point, segment, droite, demi-droite, fleche, fleche-de, cercle,
  arc, polygone, triangle, codage-segment, angle-droit, angle-marque, codage-parallele, mediatrice, bissectrice,
  hauteur, milieu, projete, intersection, distance, etiquette, ligne-brisee, quadrillage, axe, axes,
)

// Boîtes rd (module `rd`) (rdboites)
#import "modules/rd-boites/lib.typ": rd, cles-rd, setrdboites

// Horloges et durées (rdtime)
// rdtime : chargé au premier appel (imports paresseux)
#let rdtime(..a) = { import "modules/rd-time/lib.typ": rdtime as _f; _f(..a) }
#let setrdtime(..a) = { import "modules/rd-time/lib.typ": setrdtime as _f; _f(..a) }

// Proportionnalité (rdratio)
// rdratio : chargé au premier appel (imports paresseux)
#let rdratio(..a) = { import "modules/rd-ratio/lib.typ": rdratio as _f; _f(..a) }
#let dratio(..a) = { import "modules/rd-ratio/lib.typ": dratio as _f; _f(..a) }
#let sumlist(..a) = { import "modules/rd-ratio/lib.typ": sumlist as _f; _f(..a) }
#let setrdratio(..a) = { import "modules/rd-ratio/lib.typ": setrdratio as _f; _f(..a) }

// Grilles (rdgrid)
// rdgrid : chargé au premier appel (imports paresseux)
#let rdgrid(..a) = { import "modules/rd-grid/lib.typ": rdgrid as _f; _f(..a) }
#let setrdgrid(..a) = { import "modules/rd-grid/lib.typ": setrdgrid as _f; _f(..a) }

// Arithmétique : décompositions, diviseurs, PGCD (rdarithm)
// rdarithm : chargé au premier appel (imports paresseux)
#let setrdarithm(..a) = { import "modules/rd-arithm/lib.typ": setrdarithm as _f; _f(..a) }
#let liste-fp(..a) = { import "modules/rd-arithm/lib.typ": liste-fp as _f; _f(..a) }
#let decomp-fp(..a) = { import "modules/rd-arithm/lib.typ": decomp-fp as _f; _f(..a) }
#let liste-diviseurs(..a) = { import "modules/rd-arithm/lib.typ": liste-diviseurs as _f; _f(..a) }
#let tab-diviseurs(..a) = { import "modules/rd-arithm/lib.typ": tab-diviseurs as _f; _f(..a) }
#let pgcd(..a) = { import "modules/rd-arithm/lib.typ": pgcd as _f; _f(..a) }
#let ppcm(..a) = { import "modules/rd-arithm/lib.typ": ppcm as _f; _f(..a) }
#let tab-pgcd(..a) = { import "modules/rd-arithm/lib.typ": tab-pgcd as _f; _f(..a) }
#let row-pgcd(..a) = { import "modules/rd-arithm/lib.typ": row-pgcd as _f; _f(..a) }
#let decomp-frac(..a) = { import "modules/rd-arithm/lib.typ": decomp-frac as _f; _f(..a) }
#let fracirr(..a) = { import "modules/rd-arithm/lib.typ": fracirr as _f; _f(..a) }
#let dfracirr(..a) = { import "modules/rd-arithm/lib.typ": dfracirr as _f; _f(..a) }

// Tableaux de conversion (rdconv)
// rdconv : chargé au premier appel (imports paresseux)
#let rdconv(..a) = { import "modules/rd-conv/lib.typ": rdconv as _f; _f(..a) }
#let rdplace(..a) = { import "modules/rd-conv/lib.typ": rdplace as _f; _f(..a) }
#let rdconvert(..a) = { import "modules/rd-conv/lib.typ": rdconvert as _f; _f(..a) }
#let rdconvemptyline(..a) = { import "modules/rd-conv/lib.typ": rdconvemptyline as _f; _f(..a) }
#let rdconvtext(..a) = { import "modules/rd-conv/lib.typ": rdconvtext as _f; _f(..a) }
#let setrdconv(..a) = { import "modules/rd-conv/lib.typ": setrdconv as _f; _f(..a) }
#let rdtheme(..a) = { import "modules/rd-conv/lib.typ": rdtheme as _f; _f(..a) }
#let rdconvdingnum(..a) = { import "modules/rd-conv/lib.typ": rdconvdingnum as _f; _f(..a) }
#let rdconvbadge(..a) = { import "modules/rd-conv/lib.typ": rdconvbadge as _f; _f(..a) }

// Opérations posées (rdopp)
// rdopp : chargé au premier appel (imports paresseux)
#let rdopp(..a) = { import "modules/rd-opp/lib.typ": rdopp as _f; _f(..a) }
#let setrdopp(..a) = { import "modules/rd-opp/lib.typ": setrdopp as _f; _f(..a) }

// Feuilles de calcul (rdsheet)
// rdsheet : chargé au premier appel (imports paresseux)
#let rdsheet(..a) = { import "modules/rd-sheet/lib.typ": rdsheet as _f; _f(..a) }
#let setrdsheet(..a) = { import "modules/rd-sheet/lib.typ": setrdsheet as _f; _f(..a) }
#let rdsheetsetup(..a) = { import "modules/rd-sheet/lib.typ": rdsheetsetup as _f; _f(..a) }

// Tableaux de numération (rdtabnum)
// rdtabnum : chargé au premier appel (imports paresseux)
#let rdtabnum(..a) = { import "modules/rd-tabnum/lib.typ": rdtabnum as _f; _f(..a) }
#let rdtnplace(..a) = { import "modules/rd-tabnum/lib.typ": rdtnplace as _f; _f(..a) }
#let rdtnconvert(..a) = { import "modules/rd-tabnum/lib.typ": rdtnconvert as _f; _f(..a) }
#let rdtnemptyline(..a) = { import "modules/rd-tabnum/lib.typ": rdtnemptyline as _f; _f(..a) }
#let rdtn-arrow(..a) = { import "modules/rd-tabnum/lib.typ": rdtn-arrow as _f; _f(..a) }
#let rdtnsurcouche(..a) = { import "modules/rd-tabnum/lib.typ": rdtnsurcouche as _f; _f(..a) }
#let setrdtabnum(..a) = { import "modules/rd-tabnum/lib.typ": setrdtabnum as _f; _f(..a) }
#let rdtabnumarrowcol = rgb("#9C3063") // copie de rdtabnum (valeur, ne peut pas être paresseuse)
#let rdtnpurple = rdtabnumarrowcol

// Chaque partie de la suite est aussi un module, pour n'importer que ce dont on a besoin :
//   #import "@preview/farfadet:0.2.0": exercices
//   #import exercices: *
// Un module expose la façade de son paquet (et `interne`, réservé aux autres modules).
#import "modules/socle/lib.typ" as socle
#import "modules/didactique/lib.typ" as didactique
#import "modules/enumerations/lib.typ" as enumerations
#import "modules/tableaux/lib.typ" as tableaux
#import "modules/zones-reponse/lib.typ" as zones-reponse
#import "modules/exercices/lib.typ" as exercices
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
