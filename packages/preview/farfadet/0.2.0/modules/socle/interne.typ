// interne.typ (farfadet-socle) — noms du MOTEUR, seul point d'entrée pour les autres paquets.
// Fichier généré : ne pas modifier à la main.
// Noms STABLES : jamais renommés ni retirés (les autres paquets en dépendent) ; on peut en ajouter.
// Emploi depuis un autre paquet :
//   #import "lib.typ": interne as _x
//   #import _x: nom-1, nom-2

#import "src/couleurs.typ": (
  xmix, xc, couleurs, bf-couleurs-perso-p, bf-couleurs-perso, bf-nommee, bf-est-nommee, couleur, xcolor,
  definecolor, xcouleur, bf-couleur-p, bf-couleur, bf-couleur-item-p, bf-couleur-item, couleuritem,
  resetitembasecolor, tableaux-defauts, bf-couleurs-tableaux-p, bf-couleurs-tableaux, bf-teinte,
  bf-resoudre-couleur, couleurstabular, couleurssecondarytabular, resetcouleurstabular,
  resetcouleurssecondarytabular, couleurs-courantes-defauts, bf-couleurs-courantes-p, bf-couleurs-courantes,
  bf-boitecouleur-fixe-p, bf-boitecouleur-fixe, bf-couleur-courante, bf-regler-couleur-courante,
  couleurtexteaccent, resetcouleurtexteaccent, bfdsetcolors, bfdsetcolorstheoreme, bfdsetcolorsdefinition,
  bfdsetcolorsnoitem, bf-couleurs-reglage, bfdresetcolors, bfdresetcolorsnoitem, bf-couleur-connue,
  bf-xcolor, bf-modeles-couleur, bf-couleur-modele, bf-verifier-nom-couleur, bf-definecolor, bf-colorlet,
  bf-noms-couleurs-nommees, bf-couleur-nommee, bf-regler-couleurs,
)
#import "src/etat.typ": (
  tailles-latex, ptl, bf-taille-base-p, bf-taille-base, bf-police-p, bf-police, bf-interligne-p,
  bf-interligne, bf-pied-modele, bf-pied-surcharge, bf-fleqn-p, bf-fleqn, taille-latex, lire-options,
  longueur-latex, booleen-latex,
)
#import "src/version.typ": (
  correction-imposee, bf-version-p, bf-version, est-correction, set-correction, tf-correction,
  bf-reglages-socle, bf-police-correction, bf-si-correction, bf-ifcorrection,
)
#import "src/francais.typ": (
  pvfr, iff, ioo, ifo, iof, francais,
)
#import "src/mesures.typ": (
  bf-quad, bf-metriques, bf-espacement-tcb, bf-sans-espace-initial, bf-largeur-ligne, bf-marge-page,
  bf-largeur-texte, bf-gauche-ligne, bf-largeur-courante, bf-avec-largeur, bf-conteneur-ici,
)
#import "src/points.typ": (
  bf-points, bf-afficher-points-p, bf-afficher-points, displayitempointstrue, displayitempointsfalse,
  displayitempoints, bf-nombre, bf-libelle-points, tcbitempoint, bf-boite-points-en-ligne,
  getsavedtotalpoints,
)
#import "src/contenu.typ": (
  bf-vide, bf-brut,
)
#import "src/reglages.typ": (
  reglages-liste, reglages-controles, reglages-choix, reglages-ou, reglages-deduit, reglages-verifier,
  reglages-paquet, reglages-regler, reglages-regler-types, reglages-definir-style, bf-styles-communs,
  reglages-definir-style-commun, reglages-oublier-styles-communs, reglages-reinitialiser, reglages-resoudre,
  reglages-courants,
)
#import "src/precoce.typ": (
  bf-etat, bf-precoce-chaine, bf-maj, bf-lire, bf-porter, bf-porte, bf-precoce,
)
#import "src/environnements.typ": (
  garde-marqueur, begin, end, environnements, item-corps, item-options, decouper-items,
)
