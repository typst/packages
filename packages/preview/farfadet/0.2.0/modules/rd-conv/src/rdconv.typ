// rdconv.typ (façade) — rdconv, rdplace, rdconvert, rdconvemptyline, rdconvtext, setrdconv, rdtheme,
// rdconvdingnum et rdconvbadge.

#import "../../socle/lib.typ": interne as _socle
#import _socle: reglages-resoudre
#import "moteur/rdconv.typ" as _m
#import "moteur/commun.typ": rd-local

/// `rdconv` : tableau de conversion d'unités (longueur, masse, capacité, aire ou volume), dont les lignes sont
/// décrites par `rdplace`, `rdconvert` et `rdconvemptyline`.
///
/// Les STYLES (clés `digit-style`, `added-style`, `comma-style`, `cross-style`, `cell-base-style`) sont des
/// dictionnaires `(text: red, font: (weight: "bold"), fill: yellow, inset: 2pt, min-width: 1em…)` ; les FORMATS
/// (clés `unit-format`, `sec-unit-format`, `data-format`, `title-format`, `mult-format`) sont des dictionnaires
/// `(bg: couleur, fg: couleur, font: (…), align: right, border: false)`. Les traits de grille (clés `grid-…-style`)
/// sont des traits Typst (`1.5pt + black`, `(paint: blue, dash: "dashed")`) ou `none` pour une ligne invisible.
///
/// ```example
/// #rdconv(
///   rdplace(12, "m"),
///   rdplace("3,45", "dam"),
///   rdplace("45.6", "cm"),
/// )
/// ```
///
/// - ..lignes (any): les lignes du tableau, dans l'ordre : `rdplace(…)`, `rdconvert(…)`, `rdconvemptyline(…)`.
/// - type (auto, str): grandeur : `"length"`, `"mass"`, `"capacity"`, `"area"` ou `"volume"`. Défaut : `"length"`.
/// - title (auto, none, str, content): titre fusionné sur toute la largeur ; `none` : aucun titre. Défaut : `none`.
/// - title-pos (auto, str): place du titre : `"top"` (au-dessus), `"bottom"` (sous le tableau) ou `"below-mult"` (sous la ligne des multiples). Défaut : `"top"`.
/// - title-format (auto, none, dictionary): format de la cellule du titre ; sa clé `border` règle le cadre. Défaut : `none`.
/// - title-border (auto, bool): cadre autour du titre. Défaut : `true`.
/// - show-mult (auto, bool): affiche la ligne « Multiples » et « Sous-multiples ». Défaut : `false`.
/// - mult-format (auto, none, dictionary): format de la ligne des multiples ; sa clé `border` règle le cadre. Défaut : `none`.
/// - mult-border (auto, bool): cadre autour des cases « Multiples » et « Sous-multiples ». Défaut : `true`.
/// - mult-text (auto, content): texte de la case des multiples (ajout). Défaut : `[Multiples]`.
/// - submult-text (auto, content): texte de la case des sous-multiples (ajout). Défaut : `[Sous-multiples]`.
/// - decimal-sep (auto, bool): `rdplace` dessine la virgule d'un nombre décimal. Défaut : `false`.
/// - correction (auto, bool): les éléments de `rdconvert` (chiffres, zéros, virgule, ratures) n'apparaissent qu'en version professeur, dans la couleur et la police des corrections ; en version élève les cases restent vides. Défaut : `false`.
/// - mass-tons (auto, bool): tableau de masses avec les colonnes des tonnes, des quintaux et des dizaines de kilogrammes. Défaut : `false`.
/// - show-ca (auto, bool): tableau d'aires : affiche le centiare sous les mètres carrés. Défaut : `false`.
/// - sec-units (auto, bool): aires et volumes : affiche la ligne des unités secondaires (ha, a ; capacités). Défaut : `true`.
/// - width (auto, length, ratio): largeur totale du tableau. Défaut : `100%`.
/// - liter (auto, content): lettre du litre dans les en-têtes de capacité. Défaut : `$ell$`.
/// - number-info (auto, bool): colonne de numéros tout à gauche. Défaut : `false`.
/// - number-table (auto, bool): colonne de numéros juste avant la grille. Défaut : `false`.
/// - nb-info-col-type (auto, str, dictionary): alignement et largeur de la colonne `number-info` (`"l"`, `"c"`, `"r"` ou `(align: left, width: 2cm)`). Défaut : `"c"`.
/// - nb-table-col-type (auto, str, dictionary): alignement et largeur de la colonne `number-table`. Défaut : `"c"`.
/// - nb-info-macro (auto, none, function, str): met en forme le numéro de `number-info` : fonction `numéro => contenu` ou `"rdconvbadge"`. Défaut : `none`.
/// - nb-table-macro (auto, none, function, str): met en forme le numéro de `number-table`. Défaut : `none`.
/// - info-col (auto, none, content, function): colonne de texte libre à gauche ; une fonction reçoit le dictionnaire `(rdValInit, rdUnitInit, rdValTarget, rdUnitTarget)` de la ligne. Défaut : `none`.
/// - info-col-type (auto, str, dictionary): alignement et largeur de la colonne `info-col` (`"l"`, `(align: left, width: 6fr)`…). Défaut : `"l"`.
/// - tblr-options (auto, none, dictionary): `(colsep: longueur, rowsep: longueur, cells: format)` : marges des cellules et format commun. Défaut : `none`.
/// - grid-style (auto, none, length, color, stroke, dictionary): même trait pour les cinq lignes de grille suivantes (celles qui sont données l'emportent). Défaut : `auto`.
/// - grid-v-style (auto, none, length, color, stroke, dictionary): lignes verticales qui séparent les unités. Défaut : `1.5pt + black`.
/// - grid-vminor-style (auto, none, length, color, stroke, dictionary): lignes verticales secondaires entre les colonnes d'une même unité (aires, volumes). Défaut : `0.6pt + black`, en pointillés.
/// - grid-outer-style (auto, none, length, color, stroke, dictionary): cadre extérieur de la grille. Défaut : `1.5pt + black`.
/// - grid-h-style (auto, none, length, color, stroke, dictionary): lignes horizontales. Défaut : `1.5pt + black`.
/// - grid-hminor-style (auto, none, length, color, stroke, dictionary): ligne entre les unités principales et secondaires. Défaut : `auto` (comme `grid-h-style`).
/// - unit-format (auto, none, dictionary): format de la ligne des unités. Défaut : `none`.
/// - sec-unit-format (auto, none, dictionary): format de la ligne des unités secondaires. Défaut : `none`.
/// - data-format (auto, none, dictionary): format du bloc des cellules de données. Défaut : `none`.
/// - cell-base-style (auto, none, dictionary, function, array): style de base de chaque case ; remplace le style d'origine. Défaut : `(inset: 2pt, min-width: 1em)`.
/// - digit-style (auto, none, dictionary, function, array): style des chiffres saisis. Défaut : `none`.
/// - added-style (auto, none, dictionary, function, array): style des zéros ajoutés par une conversion. Défaut : `(text: red, font: (weight: "bold"))`.
/// - comma-style (auto, none, dictionary, function, array): style de la virgule. Défaut : `(text: red, font: (weight: "bold", size: 1.6em), inset: 0pt)` (virgule agrandie, lisible sur le filet de colonne).
/// - cross-style (auto, none, dictionary, function, array): style des ratures. Défaut : `(draw: red, line-width: 0.8pt)`.
/// - cross-path (auto, none, function): fonction qui dessine la rature : elle reçoit `(w, h, asc, stroke)` (largeur, hauteur, hauteur de la ligne de base, trait) et rend un contenu posé avec `place`. Défaut : la diagonale de la case.
/// - rdtheme-main-color (auto, color): couleur des pastilles `"rdconvbadge"`. Défaut : `rgb("#5F8090")`.
/// - style (auto, str, array): style(s) nommé(s) : `"rdfiche"`, `"rdtheme"`, `"rdtheme-blue"`, `"rdtheme-dark"`, `"rdtheme-lightblue"`, `"rdtheme-teal"`, `"rdtheme-red"`, ou définis par `setrdconv(definir: …)`. Défaut : `auto`.
/// -> content
#let rdconv(
  type: auto,
  title: auto,
  title-pos: auto,
  title-format: auto,
  title-border: auto,
  show-mult: auto,
  mult-format: auto,
  mult-border: auto,
  mult-text: auto,
  submult-text: auto,
  decimal-sep: auto,
  correction: auto,
  mass-tons: auto,
  show-ca: auto,
  sec-units: auto,
  width: auto,
  liter: auto,
  number-info: auto,
  number-table: auto,
  nb-info-col-type: auto,
  nb-table-col-type: auto,
  nb-info-macro: auto,
  nb-table-macro: auto,
  info-col: auto,
  info-col-type: auto,
  tblr-options: auto,
  grid-style: auto,
  grid-v-style: auto,
  grid-vminor-style: auto,
  grid-outer-style: auto,
  grid-h-style: auto,
  grid-hminor-style: auto,
  unit-format: auto,
  sec-unit-format: auto,
  data-format: auto,
  cell-base-style: auto,
  digit-style: auto,
  added-style: auto,
  comma-style: auto,
  cross-style: auto,
  cross-path: auto,
  rdtheme-main-color: auto,
  style: auto,
  ..lignes,
) = {
  let local = (
    type: type, title: title, title-pos: title-pos, title-format: title-format, title-border: title-border,
    show-mult: show-mult, mult-format: mult-format, mult-border: mult-border, mult-text: mult-text,
    submult-text: submult-text, decimal-sep: decimal-sep, correction: correction, mass-tons: mass-tons,
    show-ca: show-ca, sec-units: sec-units, width: width, liter: liter, number-info: number-info,
    number-table: number-table, nb-info-col-type: nb-info-col-type, nb-table-col-type: nb-table-col-type,
    nb-info-macro: nb-info-macro, nb-table-macro: nb-table-macro, info-col: info-col,
    info-col-type: info-col-type, tblr-options: tblr-options, grid-style: grid-style,
    grid-v-style: grid-v-style, grid-vminor-style: grid-vminor-style, grid-outer-style: grid-outer-style,
    grid-h-style: grid-h-style, grid-hminor-style: grid-hminor-style, unit-format: unit-format,
    sec-unit-format: sec-unit-format, data-format: data-format, cell-base-style: cell-base-style,
    digit-style: digit-style, added-style: added-style, comma-style: comma-style, cross-style: cross-style,
    cross-path: cross-path, rdtheme-main-color: rdtheme-main-color, style: style,
  )
  if lignes.named().len() > 0 {
    panic(
      "rdconv : clé inconnue « " + lignes.named().keys().first() + " ». Clés possibles : "
        + local.keys().map(k => "« " + k + " »").join(", ") + ".",
    )
  }
  let corps = lignes.pos()
  context {
    let r = reglages-resoudre(_m.rdconv-reglages, local: rd-local(local), commande: "rdconv")
    _m.rdconv-rendu(r, corps)
  }
}

/// `rdplace` : place une grandeur (valeur et unité) dans le tableau, sans conversion. À écrire dans `rdconv`.
///
/// ```example
/// #rdconv(decimal-sep: true, rdplace("3,52", "m"), rdplace(45, "cm"))
/// ```
///
/// - valeur (int, float, str): entier ou décimal ; la virgule et le point sont acceptés (`"3,45"`, `"45.6"`).
/// - unite (str): unité du tableau : `"km"`, `"m^2"`, `"ha"`, `"dL"`, `"kg"`… (l'exposant s'écrit `^2`, ou `²`).
/// -> dictionary
#let rdplace(valeur, unite) = {
  let _ = _m.rdconv-lire-nombre(valeur, commande: "rdplace")
  let _ = _m.rdconv-rang-unite(unite, commande: "rdplace")
  (rdconv-ligne: "place", valeur: valeur, unite: unite)
}

/// `rdconvert` : écrit la conversion d'une grandeur : chiffres, zéros ajoutés, virgule déplacée et zéros inutiles
/// barrés. À écrire dans `rdconv`.
///
/// ```example
/// #rdconv(type: "mass", rdconvert(12, "g", "cg"), rdconvert("3,45", "hg", "g"), rdconvert(4500, "mg", "g"))
/// ```
///
/// - valeur (int, float, str): entier ou décimal.
/// - de (str): unité de départ.
/// - vers (str): unité d'arrivée.
/// - comma-style (auto, none, dictionary, function, array): style de la virgule pour cette seule ligne, ajouté au style global (`(yshift: -2pt)` la descend). Défaut : `auto`.
/// -> dictionary
#let rdconvert(valeur, de, vers, comma-style: auto) = {
  let _ = _m.rdconv-lire-nombre(valeur, commande: "rdconvert")
  let _ = _m.rdconv-rang-unite(de, commande: "rdconvert")
  let _ = _m.rdconv-rang-unite(vers, commande: "rdconvert")
  (rdconv-ligne: "convertir", valeur: valeur, de: de, vers: vers, comma-style: if comma-style == auto { none } else { comma-style })
}

/// `rdconvemptyline` : insère des lignes vides, numérotées si la numérotation est active. À écrire dans `rdconv`.
///
/// ```example
/// #rdconv(number-info: true, rdplace(12, "m"), rdconvemptyline(2), rdplace("3,45", "dam"))
/// ```
///
/// - nombre (int): nombre de lignes vides.
/// -> dictionary
#let rdconvemptyline(nombre) = {
  if type(nombre) != int or nombre < 0 {
    panic("rdconvemptyline : un entier positif est attendu ; reçu : " + repr(nombre) + ".")
  }
  (rdconv-ligne: "vide", nombre: nombre)
}

/// `rdconvtext` : valeur convertie d'une grandeur, écrite avec une virgule décimale, sans zéros inutiles
/// (`"12500"`, `"0,721"`). Sert dans une phrase ou comme argument d'une autre fonction (`num`).
///
/// ```example
/// 12,5 km $=$ #rdconvtext("12.5", "km", "m") m $=$ #rdconvtext("12.5", "km", "cm") cm.
///
/// Une aire de 0,35 m#super[2] vaut #rdconvtext("0.35", "m^2", "cm^2") cm#super[2].
/// ```
///
/// - valeur (int, float, str): entier ou décimal.
/// - de (str): unité de départ.
/// - vers (str): unité d'arrivée.
/// -> str
#let rdconvtext(valeur, de, vers) = {
  let k = _m.rdconv-rang-unite(vers, commande: "rdconvtext") - _m.rdconv-rang-unite(de, commande: "rdconvtext")
  _m.rdconv-decaler(valeur, k, commande: "rdconvtext")
}

/// `setrdconv` : le réglage de `rdconv`, sous ses quatre formes (mêmes clés que `rdconv`).
///
/// - `setrdconv(cle: v, …)` : réglage global, pour la suite du document ; les appels s'ajoutent clé par clé.
/// - `setrdconv(definir: "nom", cle: v, …)` : définit le style nommé « nom », appelé ensuite par `style: "nom"`
///   sur `rdconv` ou `setrdconv`. Un style peut en appeler un autre (`style:`).
/// - `setrdconv(reinitialiser: true)` : oublie les réglages (styles gardés) ; avec des clés, repart des
///   défauts puis les applique. `reinitialiser: "tout"` oublie aussi les styles définis.
///
/// ```example
/// #setrdconv(decimal-sep: true, grid-style: (paint: gray, thickness: 1pt))
/// #rdconv(rdplace("3,52", "m"))
/// #setrdconv(definir: "bleu", unit-format: (bg: "blue!15", fg: blue))
/// #rdconv(style: "bleu", rdplace(12, "m"))
/// #setrdconv(reinitialiser: "tout")
/// ```
///
/// - pour (none, str): sans effet ici (`rdconv` n'a pas de types) ; gardé pour la signature commune des setters. Défaut : `none`.
/// - reinitialiser (bool, str): `true` : oublie les réglages ; `"tout"` : oublie aussi les styles. Défaut : `false`.
/// - definir (none, str): nom du style à définir avec les clés données. Défaut : `none`.
/// - ..cles (any): clés de `rdconv` (et `style:`).
/// -> content
#let setrdconv(pour: none, reinitialiser: false, definir: none, ..cles) = _m.rd-regler(
  _m.rdconv-reglages, "setrdconv", pour, reinitialiser, definir, cles,
)

/// `rdtheme` : jeu de clés du style `rdtheme` pour trois couleurs (principale, multiples, fond des données),
/// à passer à `rdconv` ou à `setrdconv` avec `..`. Sans argument : les couleurs bleu-gris d'origine. Les cinq
/// variantes prêtes à l'emploi sont les styles nommés `"rdtheme-blue"`, `"rdtheme-dark"`, `"rdtheme-lightblue"`,
/// `"rdtheme-teal"` et `"rdtheme-red"`.
///
/// ```example
/// #rdconv(..rdtheme(purple, purple.lighten(50%), purple.lighten(88%)), rdconvert(12.3, "m", "mm"))
/// ```
///
/// - ..couleurs (color): jusqu'à trois couleurs, dans l'ordre : principale (unités, pastilles, zéros ajoutés ; défaut `rgb("#5F8090")`), multiples (fond de la ligne des multiples ; défaut `rgb("#AABAC2")`), fond (cellules de données ; défaut `rgb("#EEF3F5")`).
/// -> dictionary
#let rdtheme(..couleurs) = {
  let c = couleurs.pos()
  if c.len() > 3 or couleurs.named().len() > 0 {
    panic("rdtheme : au plus trois couleurs positionnelles (principale, multiples, fond) ; reçu : " + repr(couleurs) + ".")
  }
  let defauts = (_m.rdconv-bleu-fonce, _m.rdconv-bleu-moyen, _m.rdconv-bleu-clair)
  let (a, b, d) = c + defauts.slice(c.len())
  _m.rdconv-theme(a, b, d)
}

/// `rdconvdingnum` : numéro encerclé ➊ ➋ ➌… (de 1 à 10), à donner à `nb-info-macro` ou `nb-table-macro`.
///
/// ```example
/// #rdconvdingnum(1) #rdconvdingnum(2) #rdconvdingnum(3)
/// ```
///
/// - numero (int): entier de 1 à 10.
/// -> content
#let rdconvdingnum(numero) = _m.rdconvdingnum(numero)

/// `rdconvbadge` : pastille ronde numérotée, à donner à `nb-table-macro` (par `"rdconvbadge"`, la couleur suit
/// `rdtheme-main-color`).
///
/// ```example
/// #rdconvbadge(1) #rdconvbadge(2, couleur: red)
/// ```
///
/// - numero (int, content): numéro écrit dans la pastille.
/// - couleur (color, str): couleur du fond. Défaut : `rgb("#5F8090")`.
/// -> content
#let rdconvbadge(numero, couleur: _m.rdconv-bleu-fonce) = _m.rdconvbadge(numero, couleur: couleur)
