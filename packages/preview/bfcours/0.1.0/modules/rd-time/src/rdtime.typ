// rdtime.typ (façade) — `rdtime` (durées posées) et `setrdtime`.

#import "../../socle/lib.typ": interne as _socle
#import _socle: reglages-resoudre
#import "moteur/rdtime.typ" as _m

/// `\rdtime[options]{durée 1}{durée 2}` : pose et effectue une addition (ou une soustraction) de durées
/// en colonnes, avec les retenues et les cellules barrées.
///
/// Les durées s'écrivent `"HH h MM min SS s"` : nombres entiers avec ou sans zéros inutiles, les unités
/// dans cet ordre, espaces facultatifs (`"2h37min"`, `"29 min 17 s"`). En soustraction, la première durée
/// doit être la plus grande.
///
/// Les STYLES (clés `result`, `sign`, `rule`, `matrix`, `nodes`…) remplacent les styles TikZ : un
/// dictionnaire `(text: red, font: (weight: "bold"), fill: "red!5", draw: blue, line-width: 1pt…)`, une
/// fonction `c => …` ou un tableau de styles.
///
/// ```example
/// #rdtime("2h37min", "3h49min") #h(1cm)
/// #rdtime(sub: true, "5h27min38s", "2h19min46s")
/// ```
///
/// - duree-1 (str): première durée (premier terme).
/// - duree-2 (str): seconde durée (second terme).
/// - operation (auto, str): `"add"` (addition) ou `"sub"` (soustraction). Défaut : `"add"`.
/// - add (auto, bool): raccourci de `operation: "add"` (style LaTeX `add`). Défaut : `false`.
/// - sub (auto, bool): raccourci de `operation: "sub"` (style LaTeX `sub`). Défaut : `false`.
/// - digit-width (auto, length): largeur occupée par chaque chiffre. Défaut : `0.65em` (1.5ex).
/// - column-sep (auto, length): espace entre les colonnes. Défaut : `0.5em`.
/// - hour-label (auto, content): libellé des heures. Défaut : `[h]`.
/// - min-label (auto, content): libellé des minutes. Défaut : `[min]`.
/// - sec-label (auto, content): libellé des secondes. Défaut : `[s]`.
/// - minus-sign (auto, content): signe de la soustraction. Défaut : `$-$`.
/// - plus-sign (auto, content): signe de l'addition. Défaut : `$+$`.
/// - name (auto, str, none): label Typst posé sur l'opération (nom de la matrice TikZ). Défaut : `"timematrix"`.
/// - baseline (auto, str, int): ligne de base : `"t"`, `"c"`, `"b"`, `"sign"` (second terme), `"result"` ou numéro de ligne (0 ou 1 : premier terme). Défaut : `0`.
/// - display-intermediary (auto, bool): affiche les calculs intermédiaires. Défaut : `true`.
/// - visible (auto, bool): `false` n'affiche que l'opération (résultats et retenues masqués, place gardée). Défaut : `true`.
/// - mode-correctif (auto, bool): `visible` suit la version du document (professeur : visible). Défaut : `false`.
/// - correction (auto, bool): style LaTeX `correction` : mode correctif, résultat et retenues dans la couleur des corrections. Défaut : `false`.
/// - matrix (auto, dictionary, function, array, none): style du cadre de l'opération (fill, draw, line-width, inset, radius). Défaut : `none`.
/// - nodes (auto, dictionary, function, array, none): style de toutes les cellules (text-height, text-depth, min-width…). Défaut : `none`.
/// - sign (auto, dictionary, function, array, none): style de la cellule du signe. Défaut : `none`.
/// - rule (auto, dictionary, function, array, none): style du trait horizontal (draw, line-width, dash). Défaut : `none`.
/// - special-cell (auto, dictionary, function, array, none): style des cellules barrées. Défaut : `(stroke-out: (line-width: 0.8pt, color: "red", shadowed: "black"))`.
/// - result (auto, dictionary, function, array, none): style de la ligne du résultat. Défaut : `none`.
/// - result-h (auto, dictionary, function, array, none): style des heures du résultat. Défaut : `none`.
/// - result-min (auto, dictionary, function, array, none): style des minutes du résultat. Défaut : `none`.
/// - result-sec (auto, dictionary, function, array, none): style des secondes du résultat. Défaut : `none`.
/// - first-number (auto, dictionary, function, array, none): style de la ligne du premier terme. Défaut : `none`.
/// - first-number-h (auto, dictionary, function, array, none): style des heures du premier terme. Défaut : `none`.
/// - first-number-min (auto, dictionary, function, array, none): style des minutes du premier terme. Défaut : `none`.
/// - first-number-sec (auto, dictionary, function, array, none): style des secondes du premier terme. Défaut : `none`.
/// - second-number (auto, dictionary, function, array, none): style de la ligne du second terme. Défaut : `none`.
/// - second-number-h (auto, dictionary, function, array, none): style des heures du second terme. Défaut : `none`.
/// - second-number-min (auto, dictionary, function, array, none): style des minutes du second terme. Défaut : `none`.
/// - second-number-sec (auto, dictionary, function, array, none): style des secondes du second terme. Défaut : `none`.
/// - intermediary (auto, dictionary, function, array, none): style des calculs intermédiaires. Défaut : `none`.
/// - labels (auto, dictionary, function, array, none): style des trois libellés d'unités. Défaut : `none`.
/// - hours-label (auto, dictionary, function, array, none): style du libellé des heures. Défaut : `none`.
/// - minutes-label (auto, dictionary, function, array, none): style du libellé des minutes. Défaut : `none`.
/// - seconds-label (auto, dictionary, function, array, none): style du libellé des secondes. Défaut : `none`.
/// - text-height (auto, length): hauteur des cellules au-dessus de la ligne de base (ajout ; `text height` du style de matrice). Défaut : `6mm`.
/// - text-depth (auto, length): profondeur des cellules (ajout ; `text depth`). Défaut : `2mm`.
/// - rule-width (auto, length): épaisseur du trait horizontal (ajout). Défaut : `0.8pt`.
/// - matrix-inset (auto, length, dictionary): marge intérieure du cadre (ajout ; `inner sep` de `\matrix`). Défaut : `0.3333em`.
/// - style (auto, str, array): style(s) nommé(s) défini(s) par `setrdtime(definir: …)`. Défaut : `auto`.
/// -> content
#let rdtime(
  operation: auto,
  add: auto,
  sub: auto,
  digit-width: auto,
  column-sep: auto,
  hour-label: auto,
  min-label: auto,
  sec-label: auto,
  minus-sign: auto,
  plus-sign: auto,
  name: auto,
  baseline: auto,
  display-intermediary: auto,
  visible: auto,
  mode-correctif: auto,
  correction: auto,
  matrix: auto,
  nodes: auto,
  sign: auto,
  rule: auto,
  special-cell: auto,
  result: auto,
  result-h: auto,
  result-min: auto,
  result-sec: auto,
  first-number: auto,
  first-number-h: auto,
  first-number-min: auto,
  first-number-sec: auto,
  second-number: auto,
  second-number-h: auto,
  second-number-min: auto,
  second-number-sec: auto,
  intermediary: auto,
  labels: auto,
  hours-label: auto,
  minutes-label: auto,
  seconds-label: auto,
  text-height: auto,
  text-depth: auto,
  rule-width: auto,
  matrix-inset: auto,
  style: auto,
  duree-1,
  duree-2,
) = {
  let local = (
    operation: operation, add: add, sub: sub, digit-width: digit-width, column-sep: column-sep,
    hour-label: hour-label, min-label: min-label, sec-label: sec-label, minus-sign: minus-sign,
    plus-sign: plus-sign, name: name, baseline: baseline, display-intermediary: display-intermediary,
    visible: visible, mode-correctif: mode-correctif, correction: correction, matrix: matrix, nodes: nodes,
    sign: sign, rule: rule, special-cell: special-cell, result: result, result-h: result-h,
    result-min: result-min, result-sec: result-sec, first-number: first-number,
    first-number-h: first-number-h, first-number-min: first-number-min, first-number-sec: first-number-sec,
    second-number: second-number, second-number-h: second-number-h, second-number-min: second-number-min,
    second-number-sec: second-number-sec, intermediary: intermediary, labels: labels,
    hours-label: hours-label, minutes-label: minutes-label, seconds-label: seconds-label,
    text-height: text-height, text-depth: text-depth, rule-width: rule-width, matrix-inset: matrix-inset,
    style: style,
  )
  let a = _m.rdtime-lire(duree-1)
  let b = _m.rdtime-lire(duree-2)
  context {
    let r = reglages-resoudre(_m.rdtime-reglages, local: _m.rd-local(local), commande: "rdtime")
    _m.rdtime-rendu(r, a, b)
  }
}

/// `\setrdtime{clés}` : le réglage de `rdtime`, sous ses quatre formes (mêmes clés que `rdtime`).
///
/// - `setrdtime(cle: v, …)` : réglage global, pour la suite du document ; les appels s'ajoutent clé par clé.
/// - `setrdtime(definir: "nom", cle: v, …)` : définit le style nommé « nom » (`\setrdtime{nom/.style={…}}`),
///   appelé ensuite par `style: "nom"` sur `rdtime` ou `setrdtime`. Un style peut en appeler un autre (`style:`).
/// - `setrdtime(reinitialiser: true)` : oublie les réglages (styles gardés) ; avec des clés, repart des
///   défauts puis les applique. `reinitialiser: "tout"` oublie aussi les styles.
///
/// ```example
/// #setrdtime(matrix: (fill: "blue!8"), result: (text: red))
/// #rdtime("3min4s", "5min6s")
/// #setrdtime(definir: "bleu", result: (text: blue))
/// #rdtime(style: "bleu", "3min4s", "5min6s")
/// #setrdtime(reinitialiser: "tout")
/// #rdtime("3min4s", "5min6s")
/// ```
///
/// - pour (none, str): sans effet ici (`rdtime` n'a pas de types) ; gardé pour la signature commune des setters. Défaut : `none`.
/// - reinitialiser (bool, str): `true` : oublie les réglages ; `"tout"` : oublie aussi les styles. Défaut : `false`.
/// - definir (none, str): nom du style à définir avec les clés données. Défaut : `none`.
/// - ..cles (any): clés de `rdtime` (et `style:`).
/// -> content
#let setrdtime(pour: none, reinitialiser: false, definir: none, ..cles) = _m.rd-regler(
  _m.rdtime-reglages, "setrdtime", pour, reinitialiser, definir, cles,
)
