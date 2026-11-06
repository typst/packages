// interne.typ (farfadet-exo) — noms du MOTEUR, seul point d'entrée pour les autres paquets.
// Fichier généré : ne pas modifier à la main.
// Noms STABLES : jamais renommés ni retirés (les autres paquets en dépendent) ; on peut en ajouter.
// Emploi depuis un autre paquet :
//   #import "lib.typ": interne as _x
//   #import _x: nom-1, nom-2

#import "src/moteur/exo.typ": (
  bf-exo, bf-exo-reel, bf-rdifficulty-p, bf-rdifficulty, rdifficulty, bf-exo-courant, bf-rdexo-filtre-p,
  bf-rdexo-filtre, bf-correction-styles-p, bf-correction-styles, bf-exobac-etat-p, bf-exobac-etat,
  bf-exo-options-fichier-p, bf-exo-options-fichier, bf-filtre-accepte, bf-rdexofilter, bf-rdexoresetfilter,
  bf-skin, bf-rdexoSkin, bf-lower-parametres, bf-exercice, bf-types-setrdexo, bf-setrdexo, bf-thenumexo,
  bf-thescore, bf-theScore, bf-rdexoscore, bf-theexotitle, bf-theExotitle, bf-thetags-courant, bf-thelabel,
  bf-rdexotags, bf-thelevel, bf-rdexonumexo, bf-rdexoMod, bf-rdexotitlefont, bf-TFNumexo, bf-TFScore,
  bf-TFLevel, bf-TFTitle, bf-TFTags, bf-habiller-boite, bf-rdexocorrection, bf-rdexoEnonceLabel,
  bf-rdexoSolutionLabel, bf-grille-exoeval, bf-tcblower, bf-exocorrection, bf-couper-exo, bf-EXO, bf-EXOEVAL,
  bf-competences-document, printcompindex, bf-rdexoinclude,
)
#import "src/moteur/evaluation.typ": (
  bf-overlaychrono, bf-chrono, bf-tableauEval, bf-tableauProjetEval, bf-tableauPresenteEvalSixieme, mi, mf,
  ms, tbm, bf-couleurs-grille, competence, tableaucompetence, tableaucompetenceeval,
)
#import "src/moteur/reglages.typ": (
  bf-exo-sans, bf-exo-couleurs, bf-exo-couleur, bf-exo-taille-sans, bf-exo-police, bf-lower-defauts,
  bf-lower-cles, bf-correction-defauts, bf-cles-boite, bf-exo-defauts, bf-exo-controles, bf-exo-registre,
  bf-types-exercice, bf-exo-fusion, bf-skins-defauts, bf-skins-communs, bf-skins-registre, bf-cles-skin,
  bf-skins-perso-p, bf-skins-perso, bf-skin-couleurs, bf-etoiles-defauts, bf-etoiles-registre,
  bf-points-gris, bf-divers-types, bf-divers-registre, bf-exolombards-registre,
)
#import "src/moteur/etoiles.typ": (
  bf-rdexostars,
)
#import "src/moteur/listes.typ": (
  bf-exo-liste, bf-rdexocountlist, bf-rdexohlist, bf-rdexotikzlist,
)
#import "src/moteur/points.typ": (
  bf-points-info, bf-afficher-bareme-p, bf-afficher-bareme, bf-icone-portable, bf-libelle-point,
  bf-boite-point, bf-itempoint, bf-infotcbitempoint, bf-displaybaremepoints, bf-baremepoint,
  bf-points-exercice, bf-getinfoexopoint, bf-getsavedinfototalpoints,
)
#import "src/moteur/skins.typ": (
  bf-largeur-entete, bf-ding110, bf-ding113, bf-the-score, bf-exo-etiquette, bf-thetags, bf-bfexobacUline,
  bf-exolombards-etiquette-defaut, bf-exolombards-titre-defaut, bf-exolombards-bareme-defaut,
  bf-skins-integres,
)
#import "src/moteur/exobac.typ": (
  bf-styleExoBac, bf-styleExoBrevet, bf-numeroterBac, bf-styleQuestionsBac, bf-styleExercicesBac,
  bf-partieBac, bf-consigneBac, bf-encadreBac, bf-encadreBacEtroit, bf-corrigeBac, bf-chapitreBac,
  bf-chapitreBrevet,
)
#import "src/moteur/exolombards.typ": (
  bf-styleExoLombards, bf-correctionsLombards, bf-exolombardsEtiquette, bf-exolombardsTitre,
  bf-exolombardsBareme, bf-exolombardsMotCorrection, bf-corrigeLombards, bf-pied-exolombards, bf-exolombards,
)
