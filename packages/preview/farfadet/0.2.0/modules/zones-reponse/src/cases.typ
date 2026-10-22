// cases.typ (farfadet-crep) — façade publique des cases à cocher (\checkbox, tcbcheckbox, \tccheckbox,
// \tccheckboxlist) et des cases \cb, \ccb, \mysquare.
// Réglages : `setrdcrep(pour: "checkbox" | "tcbcheckbox" | "tccheckbox" | "tccheckboxlist", …)`.

#import "moteur/checkbox.typ" as m
#import "moteur/bfcours.typ" as mb

#let _n(..a) = a.named().pairs().filter(((k, v)) => v != auto).to-dict()

/// Une case à cocher ou un bouton radio vectoriel (`\checkbox[options]`), posé sur la ligne de base.
/// Défauts réglables : `setrdcrep(pour: "checkbox", …)`, styles nommés :
/// `setrdcrep(definir: "nom", pour: "checkbox", …)`.
///
/// ```example
/// Une case #checkbox() cochée #checkbox(checked: true) ronde #checkbox(skin: "circle", check-mark: "disc", checked: true).
/// #setrdcrep(pour: "checkbox", color: blue, skin: "squarerounded")
/// #setrdcrep(definir: "sbr", pour: "checkbox", width: 1.3em, skin: "circleshadowA", color: blue)
/// Réglée : #checkbox() #checkbox(checked: true) bouton radio : #checkbox(style: "sbr")
/// ```
///
/// - style (str, array): style(s) nommé(s) (`setrdcrep(definir: …)`).
/// - width (length): largeur. Défaut : `0.9em`.
/// - color (color, str, none): couleur de la case. Défaut : `black`.
/// - opacity (float): opacité de la case. Défaut : `1`.
/// - background-color (color, str, none): fond. Défaut : `none`.
/// - background-opacity (float): opacité du fond. Défaut : `1`.
/// - background-style (color, gradient, dictionary, none): peinture du fond (remplace `background-color`). Défaut : `none`.
/// - checked (bool): case cochée. Défaut : `false`.
/// - checked-corr (bool): cochée en version professeur seulement. Défaut : `false`.
/// - skin (str): `"square"`, `"squareshadow"`, `"squarerounded"`, `"squareshadowrounded"`, `"circle"`, `"circleshadowA"`, `"circleshadowB"`. Défaut : `"squareshadow"`.
/// - fill-style (color, gradient, dictionary, none): peinture de la case (remplace `color`). Défaut : `none`.
/// - check-mark (str, content): `"mark1"` … `"mark14"`, `"square"`, `"hollowsquare"`, `"squarerounded"`, `"hollowsquarerounded"`, `"disc"`, `"smalldisc"`, `"hollowdisc"`, ou un contenu. Défaut : `"mark1"`.
/// - mark-color (color, str, none): couleur de la marque. Défaut : `red`.
/// - mark-overlay (bool): la marque déborde sans prendre de place. Défaut : `true`.
/// - mark-scale (int, float): échelle de la marque. Défaut : `1`.
/// - mark-opacity (float): opacité de la marque. Défaut : `1`.
/// - mark-style (color, gradient, dictionary, none): peinture de la marque. Défaut : `none`.
/// - mark-preaction (stroke, none): trait dessiné sous la marque (`3pt + white`). Défaut : `none`.
/// - raise (length): décalage vertical. Défaut : `0pt`.
/// -> content
#let checkbox(
  style: auto,
  width: auto,
  color: auto,
  opacity: auto,
  background-color: auto,
  background-opacity: auto,
  background-style: auto,
  checked: auto,
  checked-corr: auto,
  skin: auto,
  fill-style: auto,
  check-mark: auto,
  mark-color: auto,
  mark-overlay: auto,
  mark-scale: auto,
  mark-opacity: auto,
  mark-style: auto,
  mark-preaction: auto,
  raise: auto,
) = m.checkbox(.._n(
  style: style,
  width: width,
  color: color,
  opacity: opacity,
  background-color: background-color,
  background-opacity: background-opacity,
  background-style: background-style,
  checked: checked,
  checked-corr: checked-corr,
  skin: skin,
  fill-style: fill-style,
  check-mark: check-mark,
  mark-color: mark-color,
  mark-overlay: mark-overlay,
  mark-scale: mark-scale,
  mark-opacity: mark-opacity,
  mark-style: mark-style,
  mark-preaction: mark-preaction,
  raise: raise,
))

/// Boîte avec une case dans son coin supérieur gauche (environnement `tcbcheckbox`). Défauts réglables :
/// `setrdcrep(pour: "tcbcheckbox", …)` ; la case suit `setrdcrep(pour: "checkbox", …)`.
///
/// ```example
/// #tcbcheckbox(width: 6cm)[Une boîte \ avec une case à cocher]
/// #setrdcrep(pour: "tcbcheckbox", boxrule: 2pt, checkbox: (color: blue, check-mark: "mark8"))
/// #tcbcheckbox(checked-corr: true, width: 5cm)[Choix n° 2]
/// ```
///
/// - style (str, array): style(s) nommé(s) (`setrdcrep(definir: …)`).
/// - xsep (length): écart horizontal entre la case et le cadre. Défaut : `3pt` TeX.
/// - ysep (length): écart vertical. Défaut : `3pt` TeX.
/// - sep (length): les deux à la fois.
/// - checked-corr (bool): case cochée en version professeur. Défaut : `false`.
/// - checkbox-auto-color (bool): la case prend la couleur du fond. Défaut : `false`.
/// - checkbox (dictionary): clés de `checkbox` pour la case. Défaut : `(:)`.
/// - colframe (color, str): cadre. Défaut : `black`.
/// - colback (color, str): fond. Défaut : `white`.
/// - opacityback (float): opacité du fond. Défaut : `0`.
/// - opacityframe (float): opacité du cadre. Défaut : `1`.
/// - halign (str): alignement du contenu. Défaut : `"center"`.
/// - valign (str): alignement vertical. Défaut : `"center"`.
/// - boxsep (length): marge. Défaut : `3pt` TeX.
/// - boxrule (length): épaisseur du cadre. Défaut : `0.7pt` TeX.
/// - arc (length): coins. Défaut : `0pt`.
/// - top (length): marge haute. Défaut : `0pt`.
/// - bottom (length): marge basse. Défaut : `0pt`.
/// - left (length): marge gauche. Défaut : `0pt`.
/// - right (length): marge droite. Défaut : `0pt`.
/// - width (length, ratio): largeur. Défaut : `100%`.
/// - height (length, auto): hauteur minimale. Défaut : `auto`.
/// - corps (content): contenu.
/// -> content
#let tcbcheckbox(
  style: auto,
  xsep: auto,
  ysep: auto,
  sep: auto,
  checked-corr: auto,
  checkbox-auto-color: auto,
  checkbox: auto,
  colframe: auto,
  colback: auto,
  opacityback: auto,
  opacityframe: auto,
  halign: auto,
  valign: auto,
  boxsep: auto,
  boxrule: auto,
  arc: auto,
  top: auto,
  bottom: auto,
  left: auto,
  right: auto,
  width: auto,
  height: auto,
  corps,
) = m.tcbcheckbox(
  .._n(
    style: style,
    xsep: xsep,
    ysep: ysep,
    sep: sep,
    checked-corr: checked-corr,
    checkbox-auto-color: checkbox-auto-color,
    checkbox: checkbox,
    colframe: colframe,
    colback: colback,
    opacityback: opacityback,
    opacityframe: opacityframe,
    halign: halign,
    valign: valign,
    boxsep: boxsep,
    boxrule: boxrule,
    arc: arc,
    top: top,
    bottom: bottom,
    left: left,
    right: right,
    width: width,
    height: height,
  ),
  corps,
)

/// Boîte à cocher sensible au mode correctif (`\tccheckbox[options]{contenu}`) : une bande colorée à
/// gauche reçoit la marque (en couleur de correction) quand la boîte est cochée.
///
/// ```example
/// #tccheckbox(checked-corr: true)[Oui]
/// Une boîte isolée : #tccheckbox(checked: true, on-line: true, width: 4cm, halign: "center")[Toute seule]
/// ```
///
/// - style (str, array): style(s) nommé(s) (`setrdcrep(definir: …)`).
/// - left-width (length): largeur de la bande de gauche. Défaut : `1.5em`.
/// - background (color, str): couleur de la bande. Défaut : `seyescolA!20`.
/// - check-color (color, str): couleur de la marque. Défaut : couleur de correction.
/// - check-mark (str, content): marque (nom de marque de checkbox, ou contenu). Défaut : `"mark2"` (✔).
/// - mark-scale (int, float): échelle de la marque (ajout). Défaut : `1`.
/// - checked (bool): cochée. Défaut : `false`.
/// - checked-corr (bool): cochée en version professeur. Défaut : `false`.
/// - on-line (bool): boîte en ligne (posée sur la ligne de base). Défaut : `false`.
/// - colback (color, str): fond. Défaut : `white`.
/// - opacityback (float): opacité du fond. Défaut : `0`.
/// - colframe (color, str): cadre. Défaut : `black`.
/// - boxrule (length): épaisseur du cadre. Défaut : `0.5pt` TeX.
/// - arc (length): coins. Défaut : `1mm`.
/// - boxsep (length): marge. Défaut : `3pt` TeX.
/// - top (length): marge haute. Défaut : `0pt`.
/// - bottom (length): marge basse. Défaut : `0pt`.
/// - left (length): marge gauche. Défaut : `0pt`.
/// - right (length): marge droite. Défaut : `0pt`.
/// - width (length, ratio): largeur. Défaut : `100%`.
/// - height (length, auto): hauteur minimale. Défaut : `auto`.
/// - halign (str): alignement du contenu. Défaut : `"left"`.
/// - valign (str): alignement vertical. Défaut : `"center"`.
/// - corps (content): contenu.
/// -> content
#let tccheckbox(
  style: auto,
  left-width: auto,
  background: auto,
  check-color: auto,
  check-mark: auto,
  mark-scale: auto,
  checked: auto,
  checked-corr: auto,
  on-line: auto,
  colback: auto,
  opacityback: auto,
  colframe: auto,
  boxrule: auto,
  arc: auto,
  boxsep: auto,
  top: auto,
  bottom: auto,
  left: auto,
  right: auto,
  width: auto,
  height: auto,
  halign: auto,
  valign: auto,
  corps,
) = m.tccheckbox(
  .._n(
    style: style,
    left-width: left-width,
    background: background,
    check-color: check-color,
    check-mark: check-mark,
    mark-scale: mark-scale,
    checked: checked,
    checked-corr: checked-corr,
    on-line: on-line,
    colback: colback,
    opacityback: opacityback,
    colframe: colframe,
    boxrule: boxrule,
    arc: arc,
    boxsep: boxsep,
    top: top,
    bottom: bottom,
    left: left,
    right: right,
    width: width,
    height: height,
    halign: halign,
    valign: valign,
  ),
  corps,
)

/// Liste de boîtes à cocher en colonnes (`\tccheckboxlist[options]{Bleu, Rouge, …}`) : un contenu par
/// élément (ou un tableau). Les clés de `tccheckbox` passées ici s'appliquent à toutes les boîtes.
///
/// ```example
/// #tccheckboxlist(columns: 2, checked-corr: 3)[Bleu][Rouge][Jaune][Vert]
/// ```
///
/// - columns (int): nombre de colonnes ; `0` : une par élément. Défaut : `0`.
/// - col-skip (length): écart entre colonnes. Défaut : `2mm`.
/// - row-skip (length): écart entre rangées. Défaut : `2mm`.
/// - checked (int, array): numéro(s) des boîtes cochées. Défaut : `()`.
/// - checked-corr (int, array): numéro(s) cochés en version professeur. Défaut : `()`.
/// - raster (dictionary): clés de `tccheckbox` pour toutes les boîtes (options du tcbraster). Défaut : `(:)`.
/// - checkbox-style (dictionary): style commun des boîtes. Défaut : `(:)`.
/// - checked-style (dictionary): style des boîtes cochées. Défaut : `(:)`.
/// - checkbox (dictionary): style par numéro : `("2": (colframe: blue))` (`checkbox n`). Défaut : `(:)`.
/// - ..elements (content): les éléments (et, en clés nommées, des clés de `tccheckbox`).
/// -> content
#let tccheckboxlist(
  columns: auto,
  col-skip: auto,
  row-skip: auto,
  checked: auto,
  checked-corr: auto,
  raster: auto,
  checkbox-style: auto,
  checked-style: auto,
  checkbox: auto,
  ..elements,
) = m.tccheckboxlist(
  .._n(
    columns: columns,
    col-skip: col-skip,
    row-skip: row-skip,
    checked: checked,
    checked-corr: checked-corr,
    raster: raster,
    checkbox-style: checkbox-style,
    checked-style: checked-style,
    checkbox: checkbox,
  ),
  ..elements,
)

/// Case vide de bfcours (`\cb` = `\checkbox[check mark=mark14, skin=squareshadow]`).
///
/// ```example
/// #cb() Option A #h(1em) #cb() Option B
/// ```
///
/// - ..options: clés de `checkbox`.
/// -> content
#let cb(..options) = m.cb(.._n(..options))

/// Case cochée en version professeur (`\ccb` = `\cb` + `checked corr`).
///
/// ```example
/// #cb() Faux #h(1em) #ccb() Vrai
/// ```
///
/// - ..options: clés de `checkbox`.
/// -> content
#let ccb(..options) = m.ccb(.._n(..options))

/// Case carrée blanche à cadre noir épais (`\mysquare`).
///
/// ```example
/// #mysquare() Vrai #h(1em) #mysquare() Faux
/// ```
/// -> content
#let mysquare() = mb.mysquare()
