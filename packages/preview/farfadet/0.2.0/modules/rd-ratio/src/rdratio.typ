// rdratio.typ (façade) — `rdratio` (barre de proportion), `dratio`, `sumlist` et `setrdratio`.

#import "../../socle/lib.typ": interne as _socle
#import _socle: reglages-resoudre, reglages-courants
#import "moteur/rdratio.typ" as _m
#import "moteur/commun.typ": rd-local

/// `\ratio[options]{n1,n2,…}` : barre de proportion. Une case par unité, une couleur par part (dégradé
/// de `leftcol` à `rightcol`, ou liste `colors`), une accolade au-dessus (`label-above`) et une accolade
/// sous chaque part (« 2 parts », ou la liste `label-below`).
///
/// Nommée `rdratio` et non `ratio` : `ratio` est un type natif de Typst (repli R18).
///
/// ```example
/// Le ratio #dratio("1:3") : #rdratio((1, 3))
///
/// #rdratio(width: 5cm, label-above: [150 €], label-below-auto-colors: true, "1,2,3")
/// ```
///
/// - parts (array, str, int): parts du ratio : `(2, 3)` ou `"2,3"`.
/// - width (auto, length): largeur totale. Défaut : `6cm`.
/// - height (auto, length): hauteur totale. Défaut : `0.8cm`.
/// - auto-width (auto, bool): cases carrées, largeur calculée d'après `height`. Défaut : `false`.
/// - auto-height (auto, bool): cases carrées, hauteur calculée d'après `width`. Défaut : `false`.
/// - line-width (auto, length): épaisseur du contour (et des séparations). Défaut : `1pt`.
/// - rounded-corners (auto, length): arrondi des coins (`0pt` : coins vifs). Défaut : `3pt`.
/// - brace-amplitude (auto, length): amplitude des accolades. Défaut : `2.5pt`.
/// - colframe (auto, color, str): couleur du contour. Défaut : `"black"`.
/// - leftcol (auto, color, str): couleur de la première part. Défaut : `"red"`.
/// - rightcol (auto, color, str): couleur de la dernière part. Défaut : `"blue"`.
/// - colors (auto, none, array, str): couleurs des parts, en boucle ; remplace le dégradé. Défaut : `none`.
/// - align (auto, str): `"top"`, `"center"` ou `"bottom"` : point du cadre posé sur la ligne de base. Défaut : `"center"`.
/// - raise (auto, length): décalage vertical (positif : vers le haut). Défaut : `0pt`.
/// - labels (auto, str): `"all"`, `"above"`, `"below"` ou `"none"`. Défaut : `"all"`.
/// - label-above (auto, none, content): légende de l'accolade supérieure. Défaut : `none`.
/// - label-above-font (auto, str, length, dictionary, function): police de la légende : taille LaTeX, longueur, dictionnaire de police ou fonction. Défaut : `"footnotesize"`.
/// - label-above-color (auto, color, str): couleur de la légende. Défaut : `"black"`.
/// - label-above-sep (auto, length): distance cadre–accolade. Défaut : `2mm`.
/// - label-above-node-sep (auto, length): distance accolade–légende. Défaut : `2pt`.
/// - label-above-line-width (auto, length): épaisseur de l'accolade. Défaut : `0.7pt`.
/// - label-above-decoration (auto, none, dictionary): style de l'accolade : `draw`, `line-width`, `amplitude`, `dash`. Défaut : `none`.
/// - label-below (auto, none, array, str): légendes des parts, une par part ; remplace `label-below-auto`. Défaut : `none`.
/// - label-below-auto (auto, array, str): singulier et pluriel des légendes automatiques. Défaut : `("part", "parts")`.
/// - label-below-font (auto, str, length, dictionary, function): police des légendes inférieures. Défaut : `"footnotesize"`.
/// - label-below-color (auto, color, str): couleur des légendes inférieures. Défaut : `"black"`.
/// - label-below-auto-colors (auto, bool): accolades et légendes de la couleur de leur part. Défaut : `false`.
/// - label-below-sep (auto, length): distance cadre–accolades. Défaut : `2mm`.
/// - label-below-node-sep (auto, length): distance accolades–légendes. Défaut : `2pt`.
/// - label-below-line-width (auto, length): épaisseur des accolades inférieures. Défaut : `0.7pt`.
/// - label-below-decoration (auto, none, dictionary): style des accolades inférieures. Défaut : `none`.
/// - label-below-n (auto, none, dictionary): style de l'accolade n° n (`label below <n>`) : `("2": (draw: green, line-width: 2pt))`. Défaut : `none`.
/// - label-below-node-n (auto, none, dictionary): style de la légende n° n (`label below node <n>`) : `("2": (text: orange))`. Défaut : `none`.
/// - ratiobox (auto, none, dictionary): style de la case n° n (`ratiobox <n>`) : `fill`, `pattern` (tiling), `draw`, `content`… Défaut : `none`.
/// - code-after (auto, none, function): `points => contenu`, posé dans le repère du cadre ; `points` contient `rdframe`, `rdbox<n>` (ancres `center`, `north-west`…), `rdmid<n>`, et l'aide `node(point, contenu)`. Défaut : `none`.
/// - remember (auto, bool): pose les points dans un `metadata` étiqueté `<rdratio-remember>` (équivalent de `remember picture`). Défaut : `false`.
/// - label-inner-sep (auto, length): marge des légendes (ajout ; `inner sep` TikZ). Défaut : `0.3333em`.
/// - label-phantom (auto, none, content): fantôme qui égalise la hauteur des légendes (ajout ; `\vphantom{ÀÊÉpgjy}`). Défaut : `[ÀÊÉpgjy]`.
/// - style (auto, str, array): style(s) nommé(s) (`setrdratio(definir: …)`). Défaut : `auto`.
/// -> content
#let rdratio(
  width: auto,
  height: auto,
  auto-width: auto,
  auto-height: auto,
  line-width: auto,
  rounded-corners: auto,
  brace-amplitude: auto,
  colframe: auto,
  leftcol: auto,
  rightcol: auto,
  colors: auto,
  align: auto,
  raise: auto,
  labels: auto,
  label-above: auto,
  label-above-font: auto,
  label-above-color: auto,
  label-above-sep: auto,
  label-above-node-sep: auto,
  label-above-line-width: auto,
  label-above-decoration: auto,
  label-below: auto,
  label-below-auto: auto,
  label-below-font: auto,
  label-below-color: auto,
  label-below-auto-colors: auto,
  label-below-sep: auto,
  label-below-node-sep: auto,
  label-below-line-width: auto,
  label-below-decoration: auto,
  label-below-n: auto,
  label-below-node-n: auto,
  ratiobox: auto,
  code-after: auto,
  remember: auto,
  label-inner-sep: auto,
  label-phantom: auto,
  style: auto,
  parts,
) = {
  let local = (
    width: width, height: height, auto-width: auto-width, auto-height: auto-height, line-width: line-width,
    rounded-corners: rounded-corners, brace-amplitude: brace-amplitude, colframe: colframe, leftcol: leftcol,
    rightcol: rightcol, colors: colors, align: align, raise: raise, labels: labels, label-above: label-above,
    label-above-font: label-above-font, label-above-color: label-above-color, label-above-sep: label-above-sep,
    label-above-node-sep: label-above-node-sep, label-above-line-width: label-above-line-width,
    label-above-decoration: label-above-decoration, label-below: label-below, label-below-auto: label-below-auto,
    label-below-font: label-below-font, label-below-color: label-below-color,
    label-below-auto-colors: label-below-auto-colors, label-below-sep: label-below-sep,
    label-below-node-sep: label-below-node-sep, label-below-line-width: label-below-line-width,
    label-below-decoration: label-below-decoration, label-below-n: label-below-n,
    label-below-node-n: label-below-node-n, ratiobox: ratiobox, code-after: code-after, remember: remember,
    label-inner-sep: label-inner-sep, label-phantom: label-phantom, style: style,
  )
  let p = _m.rdratio-lire(parts)
  context {
    let r = reglages-resoudre(_m.rdratio-reglages, local: rd-local(local), commande: "rdratio")
    _m.rdratio-rendu(r, p)
  }
}

/// `\dratio{2:3}` : écrit un rapport « 2 : 3 » avec des espaces fines autour des deux-points.
///
/// ```example
/// Ces quantités sont dans le ratio #dratio("2:3") ; celles-ci dans le ratio *#dratio("4:5:7")*.
/// ```
///
/// - ratio (str, array): `"2:3"` ou `(2, 3)`.
/// - dratio-sep (auto, content): séparateur (ajout ; `\,:\,` en LaTeX). Défaut : espace fine, deux-points, espace fine.
/// -> content
#let dratio(dratio-sep: auto, ratio) = context {
  let sep = if dratio-sep == auto { reglages-courants(_m.rdratio-reglages).dratio-sep } else { dratio-sep }
  _m.rdratio-dratio(ratio, sep)
}

/// `\sumlist{a,b,…}` : somme des entiers d'une liste (nombre Typst).
///
/// ```example
/// Il y a #sumlist("2,3,4") parts en tout.
/// ```
///
/// - liste (str, array): `"2,3,4"` ou `(2, 3, 4)`.
/// -> int
#let sumlist(liste) = _m.rd-sumlist(liste)

/// `\setrdratio{clés}` : le réglage de `rdratio`, sous ses quatre formes (mêmes clés que `rdratio`, plus
/// `dratio-sep`).
///
/// - `setrdratio(cle: v, …)` : réglage global, pour la suite du document ; les appels s'ajoutent clé par clé.
/// - `setrdratio(definir: "nom", cle: v, …)` : définit le style nommé « nom » (`\setrdratio{nom/.style={…}}`),
///   appelé ensuite par `style: "nom"`. Un style peut en appeler un autre ; la clé locale l'emporte.
/// - `setrdratio(reinitialiser: true)` : oublie les réglages (styles gardés) ; avec des clés, repart des
///   défauts puis les applique. `reinitialiser: "tout"` oublie aussi les styles.
///
/// ```example
/// #setrdratio(leftcol: "yellow", rightcol: "brown", width: 4cm)
/// #rdratio((2, 3))
/// #setrdratio(definir: "sarcelle", colframe: "teal", leftcol: "white", rightcol: "teal")
/// #rdratio(style: "sarcelle", (1, 2, 3))
/// #setrdratio(reinitialiser: "tout")
/// ```
///
/// - pour (none, str): sans effet ici (`rdratio` n'a pas de types) ; gardé pour la signature commune des setters. Défaut : `none`.
/// - reinitialiser (bool, str): `true` : oublie les réglages ; `"tout"` : oublie aussi les styles. Défaut : `false`.
/// - definir (none, str): nom du style à définir avec les clés données. Défaut : `none`.
/// - ..cles (any): clés de `rdratio` (et `style:`).
/// -> content
#let setrdratio(pour: none, reinitialiser: false, definir: none, ..cles) = _m.rd-regler(
  _m.rdratio-reglages, "setrdratio", pour, reinitialiser, definir, cles,
)
