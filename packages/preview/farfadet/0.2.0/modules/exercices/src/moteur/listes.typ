// listes.typ (farfadet-exo) — listes de rdexo.sty (l. 356-609) : \rdexohlist, \rdexotikzlist, \rdexocountlist.
// Les étiquettes d'un exercice (\thetags) sont une \rdexotikzlist de petites boîtes.

#import "../../../socle/lib.typ": interne as _socle
#import _socle: *

/// Découpe une liste : chaîne « a, b, c » (séparateur `sep`), tableau, ou contenu seul.
/// Les éléments vides sont retirés, les espaces de bord aussi (comme \seq_set_split de expl3).
#let bf-exo-liste(liste, sep: ",") = {
  if liste == none or liste == "" or liste == () { return () }
  if type(liste) == str { return liste.split(sep).map(t => t.trim()).filter(t => t != "") }
  if type(liste) == array { return liste.filter(t => t != none and t != "") }
  (liste,)
}

/// \rdexocountlist{a,b,c} : nombre d'éléments de la liste.
#let bf-rdexocountlist(liste, sep: ",") = bf-exo-liste(liste, sep: sep).len()

/// \rdexohlist[options]{liste} : éléments séparés par `sep`, entre `before` et `after`,
/// chacun passé à `macro` (fonction élément → contenu, ou none). `avec-rang: true` (ajout, pour les
/// macros \hlistindex et \hlistcount de rdexo) : `macro` reçoit aussi le rang de l'élément (à partir de 1)
/// et le nombre d'éléments : `macro(élément, rang, total)`.
#let bf-rdexohlist(liste, list-sep: ",", sep: auto, before: none, after: none, macro: none, avec-rang: false) = {
  let elements = bf-exo-liste(liste, sep: list-sep)
  if elements.len() == 0 { return none }
  // sep={\hspace*{0.5em};\hspace*{0.5em}}
  let sep = if sep == auto { [#h(0.5em);#h(0.5em)] } else { sep }
  let f = if macro == none { x => x } else { macro }
  let n = elements.len()
  let rendus = elements.enumerate().map(((i, x)) => if avec-rang { f(x, i + 1, n) } else { f(x) })
  [#before#rendus.join(sep)#after]
}

/// \rdexotikzlist[options]{liste} : matrice dont le nombre de colonnes est le plus grand (≤ max cols,
/// 0 = sans limite) qui tienne dans la largeur de ligne. Colonnes à la largeur de leur plus grand
/// élément, éléments centrés, écarts `col-sep` et `row-sep` entre les bords.
#let bf-rdexotikzlist(liste, col-sep: 2em, row-sep: 0.5em, macro: none, max-cols: 0, list-sep: ",") = {
  let elements = bf-exo-liste(liste, sep: list-sep)
  if elements.len() == 0 { return none }
  let f = if macro == none { x => x } else { macro }
  let cellules = elements.map(x => f(x))
  let n = elements.len()
  layout(taille => {
    let max = if max-cols <= 0 { n } else { calc.min(max-cols, n) }
    let colonnes = max
    let grille(k) = grid(columns: k, column-gutter: col-sep, row-gutter: row-sep, align: center + horizon, ..cellules)
    // on retire une colonne tant que la matrice dépasse la ligne (et qu'il en reste plus d'une)
    while colonnes > 1 and measure(grille(colonnes)).width >= taille.width { colonnes -= 1 }
    grille(colonnes)
  })
}
