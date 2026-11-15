// tableaux-seyes.typ (farfadet-crep) — façade publique des tableaux alignés sur la grille Seyès
// (seyestab et seyesarray). Filets : `table.hline` ou la clé `hlines`.

#import "moteur/seyestab.typ" as m

#let _n(..a) = a.named().pairs().filter(((k, v)) => v != auto).to-dict()

/// Tableau dont chaque rangée occupe une ligne Seyès (`\begin{seyestab}{colonnes} … \end{seyestab}`) ;
/// sa première rangée est sur la ligne de base du texte. Avec `largeur:`, les colonnes `X` se partagent la largeur donnée. Dans une crep Seyès, le tableau ne prend pas de place
/// verticale : sauter les lignes qu'il occupe avec `skip:`. Filets : clés `vlines` et `hlines`, ou
/// `table.hline()` entre les rangées.
///
/// ```example
/// #crep[Un tableau : #seyestab("lcc", vlines: true, table.hline(), [Ligne 1], [a], [b], table.hline(), [Ligne 2], [c], [d], table.hline(), skip: 2)
/// Après.]
/// #seyestab("XX[c]X[c]", largeur: 10cm, hlines: true, [Ligne 1], [a], [b], [Ligne 2], [c], [d])
/// ```
///
/// - spec (str): colonnes à la LaTeX : `l`, `c`, `r`, `X`, `X[c]`, `p{3cm}`, `|` (filet vertical).
/// - largeur (length, ratio, none): largeur du tableau (colonnes `X`). Défaut : `none` (largeur naturelle).
/// - skip (int, float): lignes Seyès à sauter après le tableau, en zone Seyès. Défaut : `0`.
/// - vlines (bool, array): filets verticaux (tous, ou leurs positions). Défaut : `false`.
/// - hlines (bool, array): filets horizontaux (tous, ou leurs positions). Défaut : `false`.
/// - rules-width (length): épaisseur des filets (`rules/width`). Défaut : `0.4pt` TeX.
/// - rules-color (color, str): couleur des filets. Défaut : `black`.
/// - tabcolsep (length): demi-écart entre colonnes. Défaut : `6pt` TeX.
/// - strut-height (length): hauteur d'une rangée au-dessus de la ligne de base. Défaut : `5mm`.
/// - strut-depth (length): profondeur d'une rangée. Défaut : `3mm`.
/// - ..cellules (content): les cellules, rangée par rangée, et des filets `table.hline()`.
/// -> content
#let seyestab(
  largeur: auto,
  skip: auto,
  vlines: auto,
  hlines: auto,
  rules-width: auto,
  rules-color: auto,
  tabcolsep: auto,
  strut-height: auto,
  strut-depth: auto,
  spec,
  ..cellules,
) = m.seyestab(
  spec,
  .._n(
    largeur: largeur,
    skip: skip,
    vlines: vlines,
    hlines: hlines,
    rules-width: rules-width,
    rules-color: rules-color,
    tabcolsep: tabcolsep,
    strut-height: strut-height,
    strut-depth: strut-depth,
  ),
  ..cellules,
)

/// Tableau mathématique Seyès (`\begin{seyesarray}{colonnes}`, NiceArray) : cellules en mode maths. Avec
/// `delims:`, c'est le `seyesarraydelims` de rdcrep : le tableau est entouré de délimiteurs.
///
/// ```example
/// $ #seyesarray("rcl", $f(x)$, $=$, $2x - 1$, $g(x)$, $=$, $-3x + 5$) $
/// $ #seyesarray("l", delims: ("{", "."), $f(x) = 2x - 1$, $g(x) = -3x + 5$) $
/// ```
///
/// - spec (str): colonnes.
/// - delims (array, none): délimiteurs `(gauche, droite)` parmi `"("`, `")"`, `"["`, `"]"`, `"{"`, `"}"`, `"|"` ; `"."` : aucun. Défaut : `none`.
/// - skip (int, float): lignes Seyès à sauter après le tableau, en zone Seyès. Défaut : `0`.
/// - vlines (bool, array): filets verticaux.
/// - hlines (bool, array): filets horizontaux.
/// - rules-width (length): épaisseur des filets.
/// - rules-color (color, str): couleur des filets.
/// - arraycolsep (length): demi-écart entre colonnes. Défaut : `5pt` TeX.
/// - strut-height (length): hauteur d'une rangée.
/// - strut-depth (length): profondeur d'une rangée.
/// - ..cellules (content): les cellules.
/// -> content
#let seyesarray(
  delims: auto,
  skip: auto,
  vlines: auto,
  hlines: auto,
  rules-width: auto,
  rules-color: auto,
  arraycolsep: auto,
  strut-height: auto,
  strut-depth: auto,
  spec,
  ..cellules,
) = m.seyesarray(
  spec,
  .._n(
    delims: delims,
    skip: skip,
    vlines: vlines,
    hlines: hlines,
    rules-width: rules-width,
    rules-color: rules-color,
    arraycolsep: arraycolsep,
    strut-height: strut-height,
    strut-depth: strut-depth,
  ),
  ..cellules,
)
