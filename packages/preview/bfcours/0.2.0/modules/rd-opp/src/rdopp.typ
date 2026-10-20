// rdopp.typ (façade) — `rdopp` et `setrdopp`.

#import "../../socle/lib.typ": interne as _socle
#import _socle: reglages-resoudre
#import "moteur/rdopp.typ" as _m
#import "moteur/commun.typ": rd-local, rd-regler

/// `rdopp[options]{nombres}` : pose et effectue une opération « à la française » : addition (à plusieurs
/// termes), soustraction, multiplication ou division, avec retenues, zéros ajoutés, grille, mise en page
/// Séyès, et masquage de la solution en version élève.
///
/// Les nombres s'écrivent comme une seule chaîne `"12.5, 3.45"` (la virgule sépare les nombres), comme un
/// tableau `(12.5, 3.45)` ou comme plusieurs arguments `12.5, 3.45` (chaînes, entiers, décimaux ; la chaîne
/// `"12,5"` seule est lue comme deux nombres). Pour les décimaux, le point est recommandé ; une chaîne
/// garde les zéros finals (`"2.50"`). La soustraction attend le plus grand nombre en premier ; la
/// division, un diviseur entier. Les clés `add`, `sub`, `mul`, `div` et `divint` sont des raccourcis de
/// `operation` ; si plusieurs sont vraies, `divint` l'emporte sur `div`, puis `mul`, `sub`, `add`.
///
/// Les STYLES (clés `carry-style`, `zero-style`, `bar-style`, `matrix`, `cell`…) sont un dictionnaire
/// `(text: red, fill: "yellow!50", draw: blue, line-width: 1pt, font: (weight: "bold")…)`, une fonction
/// `c => …` ou un tableau de styles.
///
/// ```example
/// #rdopp("12.5, 3.45", operation: "sub") #h(1cm)
/// #rdopp("234, 56", mul: true, carry: true) #h(1cm)
/// #rdopp("125, 5", div: true)
/// ```
///
/// - operation (auto, str): `"add"`, `"sub"`, `"mul"`, `"div"` (ou `"addition"`, `"soustraction"`, `"multiplication"`). Défaut : `"add"`.
/// - add (auto, bool): raccourci de `operation: "add"` (style LaTeX `add`). Défaut : `false`.
/// - sub (auto, bool): raccourci de `operation: "sub"` (style LaTeX `sub`). Défaut : `false`.
/// - mul (auto, bool): raccourci de `operation: "mul"` (style LaTeX `mul`). Défaut : `false`.
/// - div (auto, bool): raccourci de `operation: "div"` (style LaTeX `div`). Défaut : `false`.
/// - divint (auto, bool): division euclidienne : `operation: "div"` et `precision: 0` (style LaTeX `divint`). Défaut : `false`.
/// - precision (auto, int): nombre maximal de décimales du quotient (la division s'arrête avant si le reste est nul). Défaut : `2`.
/// - add-symbol (auto, content): signe de l'addition (et des lignes ajoutées de la multiplication). Défaut : `$+$`.
/// - sub-symbol (auto, content): signe de la soustraction. Défaut : `$-$`.
/// - mul-symbol (auto, content): signe de la multiplication. Défaut : `$times$`.
/// - decimal-sep (auto, content): séparateur décimal affiché. Défaut : `[,]`.
/// - carry (auto, bool): affiche les retenues (addition, soustraction, multiplication). Défaut : `false`.
/// - carry-font (auto, dictionary, str, length, function, none): police des retenues : taille LaTeX (`"scriptsize"`), dictionnaire `(size: …, weight: …)`, longueur ou fonction. Défaut : `"tiny"`.
/// - carry-style (auto, dictionary, function, array, none): style de toutes les retenues. Défaut : `none`.
/// - top-carry-style (auto, dictionary, function, array, none): style des retenues du haut (emprunts de la soustraction), en plus de `carry-style`. Défaut : `none`.
/// - bot-carry-style (auto, dictionary, function, array, none): style des retenues du bas (remboursements de la soustraction), en plus de `carry-style`. Défaut : `none`.
/// - zero (auto, bool): écrit les zéros ajoutés pour aligner les décimales (addition, soustraction). Défaut : `false`.
/// - zero-style (auto, dictionary, function, array, none): style des zéros ajoutés. Défaut : `none`.
/// - intermediary (auto, bool): affiche les calculs intermédiaires (multiplication : produits partiels ; division : soustractions). Défaut : `true`.
/// - mul-zero-lines (auto, bool): garde les lignes de zéros quand un chiffre du multiplicateur est nul. Défaut : `false`.
/// - offset-char (auto, content, none): caractère écrit dans le décalage vers la gauche des produits partiels. Défaut : `none`.
/// - bridge (auto, bool): dessine un pont (arc) au-dessus du premier dividende partiel de la division. Défaut : `false`.
/// - bridge-style (auto, dictionary, function, array, none): style du pont (`bend` : courbure en degrés, 30 par défaut). Défaut : `none`.
/// - hbar (auto, int, str): longueur du trait de la division, en chiffres (`"auto"` : le diviseur ou le quotient, le plus long) ; pour les autres opérations, décalage du début du trait (`"auto"` : 0). Défaut : `"auto"`.
/// - vbar (auto, int, str): hauteur de la potence de la division, en lignes (`"auto"` : 4 lignes au plus ; `"max"` : toutes). Défaut : `"auto"`.
/// - vbar-leftsep (auto, length, none): espace entre le dernier chiffre du dividende et la potence. Défaut : `none` (1ex ou `vbar-sep`).
/// - vbar-rightsep (auto, length, none): espace entre la potence et le diviseur. Défaut : `none` (1ex ou `vbar-sep`).
/// - vbar-sep (auto, length, none): fixe en une fois `vbar-leftsep` et `vbar-rightsep` ; ces deux clés l'emportent si elles sont données. Défaut : `none`.
/// - correction (auto, bool): n'affiche que l'énoncé en version élève, et la résolution complète, colorée, en version professeur. Défaut : `false`.
/// - seyes (auto, bool): dimensions des cellules pour une zone de réponse Séyès (2,4ex × 6mm + 2mm) ; les clés `cell-width`, `cell-height` et `cell-depth` écrites sur l'appel l'emportent. Défaut : `false`.
/// - cell-width (auto, length): largeur minimale d'une cellule (2ex). Défaut : `0.8667em`.
/// - cell-height (auto, length): hauteur d'une cellule au-dessus de la ligne de base (2ex). Défaut : `0.8667em`.
/// - cell-depth (auto, length): profondeur d'une cellule sous la ligne de base (0,5ex). Défaut : `0.2167em`.
/// - lw (auto, length): épaisseur par défaut des traits principaux (barres, potence, pont). Défaut : `0.8pt`.
/// - bar-style (auto, dictionary, function, array, none): style des traits principaux (résultat, potence de la division). Défaut : `none`.
/// - subbar-style (auto, dictionary, function, array, none): style des petits traits des soustractions intermédiaires de la division. Défaut : `none`.
/// - grid (auto, bool): trace une grille autour de chaque cellule. Défaut : `false`.
/// - grid-width (auto, length): épaisseur des traits de la grille. Défaut : `0.4pt`.
/// - grid-color (auto, color, str): couleur de la grille. Défaut : `"gray"`.
/// - cell (auto, array, dictionary, none): styles de cellules : un tableau de triplets `(lignes, colonnes, style)` ou de dictionnaires `(rows: …, cols: …, style: …)` ; les lignes et colonnes sont un entier, une plage `"2-4"`, une liste `"1,3"` ou un tableau de ces formes (numérotation de la grille : colonne 1 = signes). Défaut : `none`.
/// - baseline (auto, int, str): ligne de base de l'opération : `"t"` (haut), `"c"` (centre), `"b"` (bas) ou le numéro de la ligne qui s'aligne avec le texte. Défaut : `1`.
/// - matrix (auto, dictionary, function, array, none): style du cadre de l'opération (fill, draw, inset, radius) ; la sous-clé `nodes` règle toutes les cellules, `row-sep` et `column-sep` les espaces. Défaut : `none`.
/// - tikz (auto, dictionary, function, array, none): style de l'arrière-plan de l'image (fill, draw, radius, inset), sans effet sur sa taille. Défaut : `none`.
/// - matrix-name (auto, str, none): label Typst posé sur l'opération. Défaut : `none`.
/// - row-sep (auto, length, none): espace entre les lignes (ajout ; `none` : cellules jointives, traits de grille confondus). Défaut : `none`.
/// - column-sep (auto, length, none): espace entre les colonnes (ajout). Défaut : `none`.
/// - matrix-inset (auto, length, dictionary): marge intérieure du cadre (ajout ; `inner sep` de la matrice). Défaut : `0.3333em`.
/// - overlay (auto, function, none): fonction `cellules => contenu` qui dessine par-dessus l'opération (ajout) ; `cellules.at("cell 5-4")` donne les ancres (`north`, `south-west`, `base-east`…) de la cellule ligne 5, colonne 4 (aussi `"M-5-4"` si `matrix-name: "M"`), et `(cellules.node)(point, contenu)` pose un contenu. Défaut : `none`.
/// - style (auto, str, array): style(s) nommé(s) défini(s) par `setrdopp(definir: …)`. Défaut : `auto`.
/// - ..nombres (any): les nombres à poser (voir ci-dessus).
/// -> content
#let rdopp(
  operation: auto,
  add: auto,
  sub: auto,
  mul: auto,
  div: auto,
  divint: auto,
  precision: auto,
  add-symbol: auto,
  sub-symbol: auto,
  mul-symbol: auto,
  decimal-sep: auto,
  carry: auto,
  carry-font: auto,
  carry-style: auto,
  top-carry-style: auto,
  bot-carry-style: auto,
  zero: auto,
  zero-style: auto,
  intermediary: auto,
  mul-zero-lines: auto,
  offset-char: auto,
  bridge: auto,
  bridge-style: auto,
  hbar: auto,
  vbar: auto,
  vbar-leftsep: auto,
  vbar-rightsep: auto,
  vbar-sep: auto,
  correction: auto,
  seyes: auto,
  cell-width: auto,
  cell-height: auto,
  cell-depth: auto,
  lw: auto,
  bar-style: auto,
  subbar-style: auto,
  grid: auto,
  grid-width: auto,
  grid-color: auto,
  cell: auto,
  baseline: auto,
  matrix: auto,
  tikz: auto,
  matrix-name: auto,
  row-sep: auto,
  column-sep: auto,
  matrix-inset: auto,
  overlay: auto,
  style: auto,
  ..nombres,
) = {
  if nombres.named().len() > 0 {
    let k = nombres.named().keys().first()
    panic(
      "rdopp : clé inconnue « " + k + " ». Clés possibles : "
        + _m.rdopp-reglages.defauts.keys().map(x => "« " + x + " »").join(", ") + ", « style ».",
    )
  }
  let local = rd-local((
    operation: operation, add: add, sub: sub, mul: mul, div: div, divint: divint, precision: precision,
    add-symbol: add-symbol, sub-symbol: sub-symbol, mul-symbol: mul-symbol, decimal-sep: decimal-sep,
    carry: carry, carry-font: carry-font, carry-style: carry-style, top-carry-style: top-carry-style,
    bot-carry-style: bot-carry-style, zero: zero, zero-style: zero-style, intermediary: intermediary,
    mul-zero-lines: mul-zero-lines, offset-char: offset-char, bridge: bridge, bridge-style: bridge-style,
    hbar: hbar, vbar: vbar, vbar-leftsep: vbar-leftsep, vbar-rightsep: vbar-rightsep, vbar-sep: vbar-sep,
    correction: correction, seyes: seyes, cell-width: cell-width, cell-height: cell-height,
    cell-depth: cell-depth, lw: lw, bar-style: bar-style, subbar-style: subbar-style, grid: grid,
    grid-width: grid-width, grid-color: grid-color, cell: cell, baseline: baseline, matrix: matrix,
    tikz: tikz, matrix-name: matrix-name, row-sep: row-sep, column-sep: column-sep,
    matrix-inset: matrix-inset, overlay: overlay, style: style,
  ))
  let liste = _m.rdopp-lire-liste(nombres.pos())
  context {
    let r = reglages-resoudre(_m.rdopp-reglages, local: local, commande: "rdopp")
    _m.rdopp-rendu(r, local, liste)
  }
}

/// `setrdopp{clés}` : le réglage de `rdopp`, sous ses quatre formes (mêmes clés que `rdopp`).
///
/// - `setrdopp(cle: v, …)` : réglage global, pour la suite du document ; les appels s'ajoutent clé par clé.
/// - `setrdopp(definir: "nom", cle: v, …)` : définit le style nommé « nom », appelé ensuite par `style: "nom"` sur `rdopp` ou `setrdopp`. Un style peut en appeler un autre (`style:`).
/// - `setrdopp(reinitialiser: true)` : oublie les réglages (styles gardés) ; avec des clés, repart des défauts puis les applique. `reinitialiser: "tout"` oublie aussi les styles.
///
/// ```example
/// #setrdopp(carry: true, seyes: true)
/// #rdopp("37, 8", mul: true)
/// #setrdopp(definir: "gris", zero: true, zero-style: (text: gray))
/// #rdopp(style: "gris", "12, 3.4", sub: true)
/// #setrdopp(reinitialiser: "tout")
/// ```
///
/// - pour (none, str): sans effet ici (`rdopp` n'a pas de types) ; gardé pour la signature commune des setters. Défaut : `none`.
/// - reinitialiser (bool, str): `true` : oublie les réglages ; `"tout"` : oublie aussi les styles. Défaut : `false`.
/// - definir (none, str): nom du style à définir avec les clés données. Défaut : `none`.
/// - ..cles (any): clés de `rdopp` (et `style:`).
/// -> content
#let setrdopp(pour: none, reinitialiser: false, definir: none, ..cles) = rd-regler(
  _m.rdopp-reglages, "setrdopp", pour, reinitialiser, definir, cles,
)
