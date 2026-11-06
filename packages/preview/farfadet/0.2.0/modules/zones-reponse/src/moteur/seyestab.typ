// seyestab.typ (farfadet-crep) — tableaux alignés sur la grille Seyès (seyestab, seyesarray).
//
// Chaque rangée mesure exactement une ligne Seyès : strut de 5 mm au-dessus de la ligne de base et 3 mm
// au-dessous (\strutbox de \crep@seyes@initspacing). Les filets ne décalent pas les cellules (en LaTeX, il
// fallait \sline, filet TikZ de nicematrix ; en Typst, les filets de `table` ne prennent jamais de place).
// Le tableau est aligné « [t] » : sa première rangée est sur la ligne de base du texte. Dans une zone
// Seyès (crep seyes), il ne compte pas dans l'interligne (comme en LaTeX, \lineskiplimit = −∞) : ajouter
// des lignes avec la clé `skip`.

#import "../../../socle/lib.typ": interne as _socle
#import _socle: *
#import "reglages.typ": *
#import "crep.typ": seyesskip

/// Spécification de colonnes LaTeX (« lcc », « |l|c|r| », « XX[c]X[c] », « p{3cm}c ») →
/// (colonnes, alignements, positions des filets verticaux « | »).
#let seyestab-colonnes(spec) = {
  let cols = ()
  let aligns = ()
  let barres = ()
  let i = 0
  let s = spec.clusters()
  while i < s.len() {
    let c = s.at(i)
    if c == "|" { barres.push(cols.len()) } else if c in ("l", "c", "r") {
      cols.push(auto)
      aligns.push(if c == "l" { left } else if c == "c" { center } else { right })
    } else if c == "X" {
      let a = left
      if i + 2 < s.len() and s.at(i + 1) == "[" {
        let f = s.at(i + 2)
        a = if f == "c" { center } else if f == "r" { right } else { left }
        i += 3
      }
      cols.push(1fr)
      aligns.push(a)
    } else if c in ("p", "m", "b") and i + 1 < s.len() and s.at(i + 1) == "{" {
      let fin = s.slice(i + 2).position(x => x == "}")
      let l = longueur-latex(s.slice(i + 2, i + 2 + fin).join(), defaut: auto)
      cols.push(l)
      aligns.push(left)
      i += 2 + fin
    } else if c != " " {
      panic("seyestab : spécification de colonnes non reconnue « " + c + " » dans « " + spec + " ». Possibles : l, c, r, X, X[c], p{…}, |.")
    }
    i += 1
  }
  (colonnes: cols, aligns: aligns, barres: barres)
}

/// Tableau Seyès générique (à appeler dans un `context`) : `cellules` = contenus et filets (table.hline…).
#let seyestab-rendu(spec, cellules, local: (:), maths: false, commande: "seyestab") = {
  let r = reglages-resoudre(registre-crep, pour: "seyestab", local: local, commande: commande)
  // largeur et delims (tableaux mathématiques seulement) : clés du registre
  let largeur = r.largeur
  let delims = if maths { r.delims } else { none }
  let (colonnes, aligns, barres) = seyestab-colonnes(spec)
  let n = colonnes.len()
  let trait = r.rules-width + bf-resoudre-couleur(r.rules-color)
  let sep = if maths { r.arraycolsep } else { r.tabcolsep }
  let filets = ()
  // filets verticaux : « | » de la spécification, clé vlines (true : tous ; tableau : positions)
  let vl = if r.vlines == true { range(n + 1) } else if type(r.vlines) == array { r.vlines } else { () }
  for x in barres + vl { filets.push(table.vline(x: x, stroke: trait)) }
  let corps = cellules.map(c => {
    if type(c) == content and c.func() in (table.hline, table.vline) {
      // \sline : filet sans épaisseur de rangée, au trait des réglages s'il n'en a pas
      let f = c.fields()
      if "stroke" not in f or f.stroke == auto { f.stroke = trait }
      if c.func() == table.hline { table.hline(..f) } else { table.vline(..f) }
    } else if type(c) == content and c.func() == table.cell {
      c
    } else if maths and not (type(c) == content and c.func() == math.equation) {
      math.equation(block: false, math.display(c))
    } else if maths and type(c) == content and c.func() == math.equation {
      math.equation(block: false, math.display(c.body))
    } else { c }
  })
  // filets horizontaux : clé hlines
  let nrangees = calc.ceil(cellules.filter(c => not (type(c) == content and c.func() in (table.hline, table.vline))).len() / n)
  let hl = if r.hlines == true { range(nrangees + 1) } else if type(r.hlines) == array { r.hlines } else { () }
  for y in hl { filets.push(table.hline(y: y, stroke: trait)) }
  let tab = {
    set text(top-edge: r.strut-height, bottom-edge: -r.strut-depth)
    set par(leading: 0pt, spacing: 0pt)
    table(
      columns: if largeur == none { colonnes } else { colonnes },
      align: (x, _) => aligns.at(calc.min(x, aligns.len() - 1)) + top,
      inset: (x: sep, y: 0pt),
      stroke: none,
      ..filets,
      ..corps,
    )
  }
  if largeur != none { tab = block(width: largeur, tab) }
  if delims != none {
    let (g, d) = delims
    let code(x) = if x == "{" { "\\{" } else if x == "}" { "\\}" } else if x == "." { "" } else { x }
    // lr centre ses délimiteurs sur l'axe mathématique (≈ 0,25 em) : le tableau y est centré, sinon
    // l'accolade, symétrique, descendait d'autant sous la dernière rangée
    tab = eval("$lr(" + code(g) + " #t " + code(d) + ")$", scope: (t: box(tab, baseline: 50% - 0.25em)))
  }
  let m = measure(tab)
  let haut = r.strut-height
  let normal = box(width: m.width, height: m.height, baseline: m.height - haut, tab)
  // version « grille » : aucun encombrement vertical, première rangée sur la ligne de base.
  // Le tableau garde une boîte à sa taille : placé nu dans une région de hauteur nulle, ses rangées
  // s'écraseraient les unes sur les autres.
  let grille = box(width: m.width, height: 0pt, place(top + left, dy: -haut, box(width: m.width, height: m.height, tab)))
  [#box([#metadata(grille)#normal])<bf-seyes-tab>]
}

/// Lignes Seyès sautées après un tableau (clé `skip`) : le marqueur doit être au même niveau
/// que le tableau dans le contenu de la crep (hors de son `context`), sinon la mesure de la zone double.
#let _saut-apres(skip, tableau) = {
  if type(skip) not in (int, float) or skip < 0 {
    panic("seyestab : la clé « skip » attend un nombre de lignes positif ou nul ; reçu : " + repr(skip) + ".")
  }
  if skip > 0 { tableau + seyesskip(n: skip) } else { tableau }
}

/// \begin{seyestab}{colonnes} … \end{seyestab} : tableau sur la grille Seyès (NiceTabular [t]) ;
/// avec la clé `largeur`, colonnes `X` de largeur donnée ; `skip` : lignes sautées après.
#let seyestab(spec, ..args) = {
  let local = args.named()
  let skip = local.remove("skip", default: 0)
  _saut-apres(skip, context seyestab-rendu(spec, args.pos(), local: local))
}

/// \begin{seyesarray}{colonnes} … \end{seyesarray} : tableau mathématique (NiceArray) ; avec la clé
/// `delims`, entre délimiteurs ; `skip` : lignes sautées après.
#let seyesarray(spec, ..args) = {
  let local = args.named()
  let skip = local.remove("skip", default: 0)
  _saut-apres(skip, context seyestab-rendu(spec, args.pos(), local: local, maths: true, commande: "seyesarray"))
}
