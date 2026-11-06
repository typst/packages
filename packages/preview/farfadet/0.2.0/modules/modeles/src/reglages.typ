// reglages.typ — réglages du document : un setter `setbfmodele`, et la police dys.
//
//   #setbfmodele(cycle: [Lycée], etablissement: [Lycée du Parc])         // tout le document
//   #setbfmodele(pour: "chapitre", hauteur: 2cm)                            // les bandeaux de chapitre
//   #setbfmodele(definir: "sobre", couleur-debut: white, couleur-fin: white)
//   #chapitre(theme: [Les vecteurs], style: "sobre")
//   #setbfmodele(reinitialiser: true)                                       // retour aux défauts
//
// Mécanisme générique du socle (farfadet-socle/REGLAGES.md) : priorité clé locale > style nommé >
// réglage du type > réglage global > défaut. Les types sont « bfcours », « chapitre », « chapEval »,
// « pied-de-page » et « SequenceItem » ; les groupes « entete » (chapitre, chapEval) et « identite »
// (chapitre, chapEval, pied-de-page).

#import "../../socle/lib.typ": interne as _socle
#import _socle: reglages-regler, reglages-definir-style, reglages-reinitialiser
#import "moteur/reglages.typ": modele-reglages as _R

/// Règle le modèle de document et ses en-têtes à partir de cet endroit : un seul setter pour tout
/// le paquet (réglage global, réglage d'un type, style nommé, remise à zéro).
///
/// En LaTeX, bfcours se règle une fois pour toutes au `\usepackage` : les clés du modèle sont le
/// réglage global. Ici, `setbfmodele` s'écrit n'importe où avant ce qu'il règle. Les arguments de
/// page de `farfadet` (`papier`, `marges`, `decalage`, `avec-page`, `pied`) font exception : Typst
/// interdit de régler la page depuis un état, ils se passent à `farfadet` lui-même.
///
/// ```typ
/// #setbfmodele(cycle: [Lycée], etablissement: [Lycée du Parc])
/// #setbfmodele(pour: "chapitre", hauteur: 2cm, couleur-debut: luma(230))
/// #setbfmodele(definir: "sobre", couleur-debut: luma(240), couleur-fin: luma(240))
/// #setbfmodele(titres: "sobre")
/// #setbfmodele(pour: "identite", etablissement: [Lycée du Parc], professeur: [M. Durand], annee: [2026-2027])
/// #setbfmodele(pour: "entete", rendu: "sobre", couleur-filet: rgb("#1d4e89"))
/// #setbfmodele(pour: "pied-de-page", droite: ("professeur", "annee"))
/// #setbfmodele(reinitialiser: true)
/// ```
///
/// Identité et en-tête : les champs d'identité (`etablissement`, `cycle`, `professeur`, `academie`,
/// `annee`, `classe`, `matiere`, `logo`, `mentions`) se règlent par `pour: "identite"` (bandeaux et pied
/// de page à la fois) ; le dessin des bandeaux par `pour: "entete"` (`chapitre` et `chap-eval`) : clé
/// `rendu` (`"bf"`, `"rd"`, `"sobre"`, `"encadre"` ou une fonction), `champs`, couleurs, polices, filets,
/// logo ; le pied par `pour: "pied-de-page"`. Un document reprend la main pour lui seul en passant les
/// mêmes clés à `modele("cours", …)` ou à `chapitre`, ou en rappelant `setbfmodele`.
///
/// - pour (str, array, none): type à régler : `"bfcours"`, `"chapitre"`, `"chapEval"`, `"pied-de-page"`, `"SequenceItem"`, ou un groupe : `"entete"` (les deux bandeaux), `"identite"` (les deux bandeaux et le pied de page) ; ou un tableau de types et de groupes. `none` : réglage global, valable pour tous les types qui ont la clé.
/// - reinitialiser (bool, str): `true` : oublie les réglages global et par type (les styles nommés restent) ; avec des clés, repart des défauts puis les applique. `"tout"` : oublie aussi les styles nommés.
/// - definir (str, none): nom d'un style à définir ; les clés deviennent le contenu du style, appelé ensuite par `style: "nom"`. `pour:` contrôle les clés contre un type.
/// - cles (arguments): les clés à régler, nommées ; la clé `style` appelle un ou plusieurs styles nommés ; la clé `titres` choisit le jeu de titres (`"bfcours"`, `"sobre"`, `"classique"`, `"documentation"`, `"rd"`) et la clé `numeros` le style de numérotation des titres (`"arabe"`, `"romain"`, `"lettres"` ou un tableau de motifs).
/// -> content
#let setbfmodele(pour: none, reinitialiser: false, definir: none, ..cles) = {
  if reinitialiser not in (true, false, "tout") {
    panic("setbfmodele : la clé « reinitialiser » attend true, false ou \"tout\" ; reçu : " + repr(reinitialiser) + ".")
  }
  if cles.pos().len() > 0 {
    panic("setbfmodele : seules des clés nommées sont acceptées ; reçu : " + repr(cles.pos().first()) + ".")
  }
  if definir != none { return reglages-definir-style(_R, definir, pour: pour, ..cles) }
  if reinitialiser == "tout" { reglages-reinitialiser(_R, styles: true) }
  reglages-regler(_R, pour: pour, reinitialiser: reinitialiser != false, ..cles)
}

/// \choiceFontsDys{nom} (bfcours-fonts) : choisit la famille de la variante dys ; elle s'applique
/// quand `dys: true` (clé de `farfadet`). Écrire avant `#show: farfadet`.
///
/// ```typ
/// #choice-fonts-dys("lmodern")
/// #show: farfadet.with(dys: true)
/// ```
///
/// - nom (str): `"Fira"` (Fira Sans et Fira Math), `"lmodern"` (Latin Modern Sans) ou `"tgheros"` (TeX Gyre Heros).
/// -> content
#let choice-fonts-dys(nom) = reglages-regler(_R, pour: "bfcours", commande: "choiceFontsDys", police-dys: nom)
