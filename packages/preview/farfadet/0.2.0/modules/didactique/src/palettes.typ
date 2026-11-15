// palettes.typ — personnalisation globale des environnements : palettes et variantes de
// new-bfcours-environments.sty (\bfset, \NewBfdPalette, \bfdActivatePalette, \bfdActivateVariant)
// et le setter `setbfenvironments` (réglages, styles nommés : équivalent des `/.style` de tcolorbox).
//
// Une palette redéfinit les neuf couleurs sémantiques `thm`, `defi`, `prop`, `demo`, `meth`, `act`,
// `rem`, `nota`, `ex`, exactement comme \colorlet en LaTeX : elle passe par les couleurs définies par
// l'utilisateur du socle (`bf-couleurs-perso`), que lisent les environnements (couleur `auto`), les
// noms xcolor (`"thm!50"`) et les accroches de couleurs (`bfdSetColors`).

#import "../../socle/lib.typ": interne as _socle
#import _socle: couleurs, definecolor as _definecolor, reglages-definir-style, reglages-liste, reglages-regler, reglages-reinitialiser, bf-etat, bf-maj, bf-lire
#import "reglages.typ": _R, _RA

#let _semantiques = ("thm", "defi", "prop", "demo", "meth", "act", "rem", "nota", "ex")
#let _variantes = ("lignes", "minimal", "sidebar")

/// Palettes livrées par bfcours (`default` = couleurs d'origine de bfcours-colors).
#let _palettes-livrees = (
  default: _semantiques.map(n => (n, couleurs.at(n))).to-dict(),
  ocean: (thm: "blue", defi: "teal", prop: "cyan", demo: "purple", meth: "blue", act: "teal", rem: "blue", nota: "purple", ex: "blue"),
  vintage: (thm: "red", defi: "olive", prop: "orange", demo: "brown", meth: "brown", act: "orange", rem: "brown", nota: "purple", ex: "brown"),
)

#let _palettes-p = bf-etat("bfd-palettes", _palettes-livrees)
#let _palettes = _palettes-p.etat

/// Déclare une palette (`\NewBfdPalette{nom}{thm=…, defi=…}`). Les couleurs absentes gardent leur
/// valeur au moment de l'activation. Valeurs : couleur Typst ou expression xcolor (`"blue!70!cyan"`).
///
/// ```example
/// #new-bfd-palette("foret", thm: "olive", defi: "teal", prop: rgb("#2e7d32"))
/// #bfd-activate-palette("foret")
/// #propriete[Verte][Texte.]
/// ```
///
/// - nom (str): nom de la palette.
/// - couleurs (color, str): `thm`, `defi`, `prop`, `demo`, `meth`, `act`, `rem`, `nota`, `ex`.
/// -> content
#let new-bfd-palette(nom, ..couleurs) = {
  if type(nom) != str { panic("new-bfd-palette : le nom d'une palette est une chaîne ; reçu : " + repr(nom) + ".") }
  if couleurs.pos().len() > 0 { panic("new-bfd-palette : les couleurs s'écrivent en arguments nommés (thm: …, defi: …).") }
  for (k, v) in couleurs.named() {
    if k not in _semantiques {
      panic("new-bfd-palette : couleur inconnue « " + k + " ». Couleurs possibles : " + reglages-liste(_semantiques) + ".")
    }
    if type(v) not in (color, str) {
      panic("new-bfd-palette : valeur invalide pour « " + k + " » : " + repr(v) + ". Valeurs possibles : une couleur Typst ou un nom xcolor.")
    }
  }
  bf-maj(_palettes-p, p => p + ((nom): couleurs.named()))
}

/// Active une palette (`\bfdActivatePalette{nom}`) : `default`, `ocean`, `vintage` ou une palette
/// déclarée par `new-bfd-palette`. Les environnements suivants prennent ses couleurs.
///
/// ```example
/// #bfd-activate-palette("ocean")
/// #theoreme[Bleu][Texte.]
/// #bfd-activate-palette("default")
/// ```
///
/// - nom (str): nom de la palette.
/// -> content
#let bfd-activate-palette(nom) = context {
  let p = bf-lire(_palettes-p)
  if nom not in p {
    panic("bfd-activate-palette : palette inconnue « " + str(nom) + " ». Palettes possibles : " + reglages-liste(p.keys()) + ".")
  }
  for (k, v) in p.at(nom) { _definecolor(k, v) }
}

/// Choisit l'habillage des environnements à banderole (`\bfdActivateVariant{…}`) :
/// `"lignes"` (défaut : filets gauche et bas, sous-titre centré), `"minimal"` (fin filet gauche,
/// sans sous-titre) ou `"sidebar"` (bande pleine à gauche, sous-titre à droite). Équivaut à
/// `setbfenvironments(variant: …)`.
///
/// ```example
/// #bfd-activate-variant("sidebar")
/// #definition[Barre latérale][Texte.]
/// #bfd-activate-variant("lignes")
/// ```
///
/// - variante (str): `"lignes"`, `"minimal"` ou `"sidebar"`.
/// -> content
#let bfd-activate-variant(variante) = {
  if variante not in _variantes {
    panic("bfd-activate-variant : variante inconnue « " + str(variante) + " ». Variantes possibles : " + reglages-liste(_variantes) + ".")
  }
  reglages-regler(_R, commande: "bfdActivateVariant", variant: variante)
}

/// Interface unique de configuration de new-bfcours-environments (`\bfset{palette=…, variant=…}`).
///
/// ```example
/// #bfset(palette: "vintage", variant: "minimal")
/// #methode[Ton chaud][Texte.]
/// #bfset(palette: "default", variant: "lignes")
/// ```
///
/// - palette (str, none): palette à activer (voir `bfd-activate-palette`). Défaut : `none` (inchangée).
/// - variant (str, none): variante à activer (voir `bfd-activate-variant`). Défaut : `none` (inchangée).
/// -> content
#let bfset(palette: none, variant: none) = {
  if palette != none { bfd-activate-palette(palette) }
  if variant != none { bfd-activate-variant(variant) }
}

/// Règle les environnements didactiques pour la suite du document : le setter de farfadet-didactique
/// pour les environnements (signature commune de tous les setters de bfcours).
///
/// | Appel | Effet |
/// |---|---|
/// | `setbfenvironments(cle: v)` | réglage global (toutes les clés que le type connaît) |
/// | `setbfenvironments(pour: "Definition", cle: v)` | réglage d'un type, d'un groupe ou d'un tableau de types |
/// | `setbfenvironments(definir: "nom", cle: v)` | définit le style nommé « nom » (appel : `style: "nom"`) |
/// | `setbfenvironments(style: "rd")` | rendu par les boîtes de `rdboites` (`"bf"`, le défaut, rend le style de bfcours) |
/// | `setbfenvironments(pour: "anki", paquet: …)` | export Anki (clés `paquet`, `etiquettes`, `format`) |
/// | `setbfenvironments(reinitialiser: true)` | oublie réglages global et par type (styles gardés) ; avec des clés, repart des défauts puis les applique |
/// | `setbfenvironments(reinitialiser: "tout")` | idem, et ramène les styles aux styles prédéfinis |
///
/// Priorité : clé écrite sur l'environnement > style nommé > réglage du type > réglage global > défaut.
/// Un type, une clé, une valeur ou un style inconnus arrêtent la compilation avec la liste des
/// possibilités. Styles prédéfinis (styles LaTeX de bfcours) : `bf`, `rd` (rendus), `bfd theoreme`,
/// `bfd definition`, `bfd propriete`, `bfd demonstration`, `bfd methode`, `bfd activite`,
/// `bfd vocabulaire`, `bfd solution`, `bfd histoire`, `exempleboxstyle`,
/// `contreexempleboxstyle`, `bfd edge overlay lignes`, `bfd edge overlay minimal`,
/// `bfd edge overlay sidebar`.
///
/// Anki : l'export se fait hors de Typst, par l'outil `ankify` (Node ou Deno) qui lit les métadonnées
/// du PDF ; les cartes sont déposées par la clé `anki` des environnements. `paquet` : nom du paquet de
/// cartes (`none` : celui d'ankify), `etiquettes` : étiquettes ajoutées à toutes les cartes, `format` :
/// `"png"`, `"svg"` ou `"plain"`.
///
/// ```example
/// #setbfenvironments(sommaire: false)
/// #setbfenvironments(pour: "Definition", numero: true, couleur: "teal")
/// #setbfenvironments(definir: "sobre", drop-shadow: false, variant: "minimal")
/// #propriete(style: "sobre")[Sobre][Texte.]
/// #setbfenvironments(pour: "anki", paquet: "Maths - 2nde", etiquettes: ("vecteurs",))
/// ```
///
/// - pour (str, array, none): type d'environnement (nom LaTeX exact : `definition`, `exemple`, `bf-env`,
///   `boite`…), tableau de types, ou `"anki"` ; `none` : réglage global.
/// - reinitialiser (bool, str): `true`, `false` ou `"tout"`.
/// - definir (str, none): nom d'un style à définir ; les clés qui suivent en forment le contenu.
/// - cles (any): les clés à régler (voir la fiche de chaque environnement).
/// -> content
#let setbfenvironments(pour: none, reinitialiser: false, definir: none, ..cles) = {
  if reinitialiser not in (true, false, "tout") {
    panic("setbfenvironments : la clé « reinitialiser » attend true, false ou \"tout\" ; reçu : " + repr(reinitialiser) + ".")
  }
  if pour == "anki" {
    if definir != none { panic("setbfenvironments : `definir` ne s'applique pas à « anki » (clés : paquet, etiquettes, format).") }
    return reglages-regler(_RA, reinitialiser: reinitialiser != false, ..cles)
  }
  if definir != none { return reglages-definir-style(_R, definir, pour: pour, ..cles) }
  if reinitialiser == "tout" { reglages-reinitialiser(_R, styles: true) }
  reglages-regler(_R, pour: pour, reinitialiser: reinitialiser != false, ..cles)
}

