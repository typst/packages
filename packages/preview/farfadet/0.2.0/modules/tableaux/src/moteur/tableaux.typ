// tableaux.typ — moteur de tableaux : `tabular` (grille à spécification de colonnes), `tcbtab`,
// `tcbtabcomp`, boîte de tableau. Les noms de ce fichier sont exportés par `interne.typ` pour les autres
// paquets (farfadet-exo) ; la façade publique est `../tableaux.typ`.
//
// Géométrie : les filets (| et hline) ont une épaisseur qui compte dans la largeur et la hauteur du
// tableau ; chaque cellule porte un étai (arraystretch × 0,7 et 0,3 de l'interligne) ; l'espace
// horizontal de part et d'autre de chaque colonne vaut 6 pt.
//
// Couleurs courantes : farfadet-socle ; évaluation et compétences : farfadet-exo.

#import "../../../socle/lib.typ": interne as _socle
#import _socle: *
#import "../../../enumerations/lib.typ": interne as _enum
#import _enum: bf-couleur-tcb, bf-resoudre-tcb, bf-raster, bf-tcb-defaut, tcbitem

/// Résout une couleur stockée (chaîne xcolor ou couleur) : `bf-resoudre-couleur` du socle.
#let _resoudre = bf-resoudre-couleur

// =====================================================================
// tabular : spécification de colonnes LaTeX → grille Typst
// =====================================================================

/// \hline, \cline{a-b} : marqueurs à glisser entre les cellules.
#let hline() = (bf-filet: true, de: none, a: none)
#let cline(plage) = {
  let (a, b) = str(plage).split("-").map(x => int(x.trim()))
  (bf-filet: true, de: a, a: b)
}

/// Cellule avec options : \multicolumn{n}{spec}{x} → cellule(colspan: n, align: center)[x] ;
/// \cellcolor{c} x → cellule(fill: "c")[x]. `align` : left, center, right (défaut : celui de la colonne).
#let cellule(colspan: 1, rowspan: 1, fill: none, align: auto, corps) = (
  bf-cellule: true, colspan: colspan, rowspan: rowspan, fill: fill, align: align, corps: corps,
)
/// \multicolumn{n}{spec}{contenu}
#let multicolumn(n, spec, corps) = {
  let s = spec.replace("|", "").trim()
  let a = if s.starts-with("l") or s.starts-with("p") { left } else if s.starts-with("r") { right } else { center }
  cellule(colspan: n, align: a, corps)
}

/// Contenu d'un groupe {…} à partir de l'indice i (qui pointe sur « { ») : (contenu, indice après « } »).
#let _groupe(car, i) = {
  let prof = 0
  let j = i
  let s = ""
  while j < car.len() {
    let c = car.at(j)
    if c == "{" { prof += 1; if prof == 1 { j += 1; continue } }
    if c == "}" { prof -= 1; if prof == 0 { return (s, j + 1) } }
    s += c
    j += 1
  }
  (s, j)
}

/// Développe *{n}{motif}.
#let _developper(spec) = {
  let car = spec.clusters()
  let r = ""
  let i = 0
  while i < car.len() {
    if car.at(i) == "*" and i + 1 < car.len() and car.at(i + 1) == "{" {
      let (n, j) = _groupe(car, i + 1)
      let (motif, k) = _groupe(car, j)
      r += _developper(motif) * int(n.trim())
      i = k
    } else {
      r += car.at(i)
      i += 1
    }
  }
  r
}

/// Analyse une spécification tabular (« |p{5cm}|c|c| », « >{\centering\arraybackslash}p{2cm} », « X »).
/// Renvoie (colonnes: ((type, largeur, align, justifie)…), filets: nombre de | à chaque frontière,
/// sans-sep: frontières sous @{…}).
#let bf-analyser-spec(spec, largeur-texte: none) = {
  let car = _developper(spec).clusters()
  let colonnes = ()
  let filets = (0,)
  let sans-sep = (false,)
  let avant = ""
  let i = 0
  let largeur(v) = {
    let l = longueur-latex(v.replace("\\textwidth", "\\linewidth").replace("\\columnwidth", "\\linewidth"), defaut: auto)
    if type(l) == ratio and largeur-texte != none { l * largeur-texte } else { l }
  }
  while i < car.len() {
    let c = car.at(i)
    if c == "|" { filets.at(-1) += 1; i += 1 }
    else if c == ">" { let (g, j) = _groupe(car, i + 1); avant += g; i = j }
    else if c == "<" { let (g, j) = _groupe(car, i + 1); i = j }
    else if c == "@" or c == "!" { let (g, j) = _groupe(car, i + 1); sans-sep.at(-1) = c == "@"; i = j }
    else if c in ("l", "c", "r", "S", "X") {
      let a = if c == "l" { left } else if c == "r" { right } else if c == "X" { auto } else { center }
      if avant.contains("\\centering") { a = center } else if avant.contains("\\raggedleft") { a = right } else if avant.contains("\\raggedright") { a = left }
      colonnes.push((type: c, largeur: if c == "X" { 1fr } else { auto }, align: a, avant: avant))
      filets.push(0)
      sans-sep.push(false)
      avant = ""
      i += 1
    } else if c in ("p", "m", "b") {
      let (g, j) = _groupe(car, i + 1)
      let a = auto
      if avant.contains("\\centering") { a = center } else if avant.contains("\\raggedleft") { a = right } else if avant.contains("\\raggedright") { a = left }
      colonnes.push((type: c, largeur: largeur(g), align: a, avant: avant))
      filets.push(0)
      sans-sep.push(false)
      avant = ""
      i = j
    } else { i += 1 }
  }
  (colonnes: colonnes, filets: filets, sans-sep: sans-sep)
}

/// Contenu d'une cellule : étai de début et de fin (\@arstrut), alignement, justification.
#let _contenu-cellule(corps, col, align-force, haut, prof) = {
  let a = if align-force != auto { align-force } else { col.align }
  let justifie = a == auto
  let debut = box(width: 0pt, height: haut)
  let fin = box(width: 0pt, height: prof, baseline: prof)
  let c = [#debut#bf-sans-espace-initial(corps)#fin]
  set par(justify: justifie)
  if a == auto or a == left { c } else { align(a, c) }
}

/// \begin{tabular}{spec} … \end{tabular} (arraystretch, filets épais comme en LaTeX).
///   #tabular("|c|c|", [$x$], [1], hline(), [$f(x)$], [3])
/// Cellules : contenus, cellule(…)[…], multicolumn(…) ; filets : hline(), cline("2-3").
/// Options : etirement (\arraystretch, 1,5 dans bfcours), epaisseur (\arrayrulewidth),
/// couleur-filets (\arrayrulecolor), fond (couleur des cellules), tabcolsep, largeur (tabularx).
/// À appeler dans un `context`.
#let bf-tabular(
  spec,
  cellules,
  etirement: 1.5,
  epaisseur: ptl(0.4),
  couleur-filets: black,
  fond: none,
  tabcolsep: ptl(6),
  largeur-texte: none,
  rangees: none,
) = {
  // rangées alternées (\rowcolors) : fonction (indice de rangée de contenu, 0 = première) → couleur ou auto
  let fond-rangee(k) = {
    let v = if rangees == none { auto } else { rangees(k) }
    if v == auto { fond } else { v }
  }
  let lt = if largeur-texte == none { bf-largeur-courante() } else { largeur-texte }
  let sp = bf-analyser-spec(spec, largeur-texte: lt)
  let n = sp.colonnes.len()
  let bs = bf-lire(bf-interligne-p).baselineskip
  let haut = etirement * 0.7 * bs
  let prof = etirement * 0.3 * bs
  // colonnes de la grille : [filet?] col [filet?] col … [filet?]
  let colonnes-grille = ()
  let indice-col = () // position de chaque colonne de contenu dans la grille
  for b in range(n + 1) {
    let k = sp.filets.at(b)
    if k > 0 { colonnes-grille.push(k * epaisseur) }
    if b < n {
      let col = sp.colonnes.at(b)
      indice-col.push(colonnes-grille.len())
      let sep-g = if sp.sans-sep.at(b) { 0pt } else { tabcolsep }
      let sep-d = if sp.sans-sep.at(b + 1) { 0pt } else { tabcolsep }
      colonnes-grille.push(if type(col.largeur) == length { col.largeur + sep-g + sep-d } else { col.largeur })
    }
  }
  let total = colonnes-grille.len()
  let filet-col(b) = sp.filets.at(b) > 0
  // découpe en rangs
  let rangs = ()
  let rang = ()
  let pleins = 0
  for it in cellules {
    if type(it) == dictionary and it.at("bf-filet", default: false) {
      if rang.len() > 0 { rangs.push((sorte: "cellules", items: rang)); rang = (); pleins = 0 }
      rangs.push((sorte: "filet", de: it.de, a: it.a))
      continue
    }
    let cel = if type(it) == dictionary and it.at("bf-cellule", default: false) { it } else {
      (colspan: 1, rowspan: 1, fill: none, align: auto, corps: it)
    }
    rang.push(cel)
    pleins += cel.colspan
    if pleins >= n { rangs.push((sorte: "cellules", items: rang)); rang = (); pleins = 0 }
  }
  if rang.len() > 0 { rangs.push((sorte: "cellules", items: rang)) }
  // construction, positions explicites (x, y) : les \multirow (rowspan) couvrent aussi les rangs de
  // filets qu'ils traversent, et la cellule vide que LaTeX attend sous eux est écartée
  let lignes = rangs.map(r => if r.sorte == "filet" { epaisseur } else { auto })
  let y-contenu = rangs.enumerate().filter(((i, r)) => r.sorte == "cellules").map(((i, r)) => i)
  let occupe = (:) // "x,y" couverts par un rowspan venu d'un rang supérieur
  let libre(occ, x, y) = (str(x) + "," + str(y)) not in occ
  let x-filet(b) = if b < n { indice-col.at(b) - 1 } else { total - 1 }
  // Les filets sont de VRAIS traits (grid.hline / grid.vline), posés sur les pistes réservées : un filet
  // dessiné comme une cellule pleine de 0,4 pt disparaît du rendu à l'écran (anticrénelage).
  let trait-h(y, de, a) = grid.hline(y: y, start: de, end: a, stroke: epaisseur + couleur-filets)
  let trait-v(x, y, b) = grid.vline(x: x, start: y, end: y + 1, stroke: sp.filets.at(b) * epaisseur + couleur-filets)
  let sortie = ()
  let k = 0 // rang de contenu courant
  for (y, r) in rangs.enumerate() {
    if r.sorte == "filet" {
      if r.de != none and r.a > n {
        panic("cline : la plage « " + str(r.de) + "-" + str(r.a) + " » dépasse les " + str(n) + " colonnes du tableau.")
      }
      let (x0, x1) = if r.de == none { (0, total - 1) } else { (indice-col.at(r.de - 1), indice-col.at(r.a - 1)) }
      // segments libres de la plage
      let debut = none
      for x in range(x0, x1 + 2) {
        let ok = x <= x1 and libre(occupe, x, y)
        if ok and debut == none { debut = x }
        if not ok and debut != none {
          sortie.push(trait-h(y, debut, x))
          debut = none
        }
      }
      // hors de la plage d'un \cline, les filets verticaux continuent (en LaTeX, \cline ne les coupe pas)
      for b in range(n + 1) {
        let x = x-filet(b)
        if filet-col(b) and (x < x0 or x > x1) and libre(occupe, x, y) {
          sortie.push(trait-v(x, y, b))
        }
      }
    } else {
      let pris = ()
      let c = 0
      for cel in r.items {
        if c >= n { break }
        let fin = calc.min(c + cel.colspan, n) - 1
        let g0 = indice-col.at(c)
        let g1 = indice-col.at(fin)
        if not libre(occupe, g0, y) {
          // cellule vide sous un \multirow
          c = fin + 1
          continue
        }
        let dernier = calc.min(k + calc.max(cel.rowspan, 1) - 1, y-contenu.len() - 1)
        let y1 = y-contenu.at(dernier)
        for yy in range(y + 1, y1 + 1) {
          for xx in range(g0, g1 + 1) { occupe.insert(str(xx) + "," + str(yy), true) }
        }
        for xx in range(g0, g1 + 1) { pris.push(xx) }
        let sep-g = if sp.sans-sep.at(c) { 0pt } else { tabcolsep }
        let sep-d = if sp.sans-sep.at(fin + 1) { 0pt } else { tabcolsep }
        let col = sp.colonnes.at(c)
        let largeur-p = if col.type in ("p", "m", "b") and cel.colspan == 1 { col.largeur } else { auto }
        let contenu = _contenu-cellule(cel.corps, col, cel.align, haut, prof)
        let f = if cel.fill != none { _resoudre(cel.fill) } else { fond-rangee(k) }
        sortie.push(grid.cell(
          x: g0,
          y: y,
          colspan: g1 - g0 + 1,
          rowspan: y1 - y + 1,
          fill: f,
          inset: (left: sep-g, right: sep-d, y: 0pt),
          align: if y1 > y or col.type == "m" { horizon } else if col.type == "b" { bottom } else { top },
          if largeur-p == auto { contenu } else { block(width: largeur-p, contenu) },
        ))
        c = fin + 1
      }
      // cellules manquantes (rang incomplet)
      while c < n {
        let g = indice-col.at(c)
        if libre(occupe, g, y) {
          pris.push(g)
          sortie.push(grid.cell(x: g, y: y, fill: fond-rangee(k), []))
        }
        c += 1
      }
      // filets verticaux (sauf ceux qu'un \multicolumn ou un \multirow recouvre)
      for b in range(n + 1) {
        let x = x-filet(b)
        if filet-col(b) and x not in pris and libre(occupe, x, y) {
          sortie.push(trait-v(x, y, b))
        }
      }
      k += 1
    }
  }
  grid(columns: colonnes-grille, rows: lignes, ..sortie)
}

/// \begin{tabular}{spec} … : version document (couleur des filets : primaire courante).
#let tabular(spec, etirement: 1.5, ..cellules) = context bf-tabular(
  spec,
  cellules.pos(),
  etirement: etirement,
  couleur-filets: _resoudre(bf-lire(bf-couleurs-tableaux-p).primaire.filets),
)

// =====================================================================
// Boîtes de tableaux (TableauBox, CompTab, tabularx*)
// =====================================================================

/// Ombre « drop fuzzy shadow » : 10 calques gris décalés de 1 mm (relevés sur tcolorbox).
#let _ombre-floue(l, h, rayon) = {
  let opacites = (1, 2, 4, 7, 11, 11, 7, 4, 2, 1)
  for (k, o) in opacites.enumerate() {
    let d = 1.36pt - k * 0.34pt
    place(top + left, dx: 1mm - d, dy: 1mm - d, rect(
      width: l + 2 * d,
      height: h + 2 * d,
      radius: calc.max(rayon + d, 0pt),
      fill: rgb(50%, 50%, 50%, o * 1%),
      stroke: none,
    ))
  }
}

/// Boîte tcolorbox d'un tableau, ajustée au contenu (hbox) ou de largeur imposée.
/// c : (cadre, fond-titre, texte-titre, fond, texte) résolus. À appeler dans un `context`.
#let _boite-tableau(
  titre,
  corps,
  c,
  largeur: auto,
  mesure-corps: none,
  regle: 0.5mm,
  arc: 1mm,
  marge-titre: 0.5mm,
  police-titre: (weight: "bold"),
  texte-noir: false,
  ombre: true,
  marge-titre-bas: auto,
  titre-centre: true,
) = {
  let m = bf-metriques()
  let corps-colore = if c.texte == none { corps } else { text(fill: c.texte, corps) }
  // largeur naturelle : celle du contenu, élargie si le titre (sur une ligne) est plus large
  let l-titre = if titre != none and largeur == auto {
    measure(text(..police-titre, titre)).width + 2 * marge-titre
  } else { 0pt }
  // Largeur automatique : la grille est mesurée UNE seule fois (largeur et hauteur naturelles) ; la taille
  // du cadre s'en déduit sans remettre la grille en page, ce qui divisait par deux le coût d'un tableau
  // (chaque niveau d'imbrication multiplie le travail).
  let mesure-corps = if largeur != auto { none } else if mesure-corps != none { mesure-corps } else { measure(corps-colore) }
  let l-int = if largeur == auto { calc.max(mesure-corps.width, l-titre) } else { largeur - 2 * regle }
  let partie-titre = if titre != none {
    block(
      width: l-int,
      fill: c.fond-titre,
      radius: (top: arc),
      inset: (
        x: 0pt,
        top: marge-titre + m.asc - m.haut,
        bottom: (if marge-titre-bas == auto { marge-titre } else { marge-titre-bas }) + m.prof - m.desc,
      ),
      above: 0pt,
      below: 0pt,
      align(if titre-centre { center } else { left }, text(fill: c.texte-titre, ..police-titre, titre)),
    )
  }
  let interieur = block(
    width: l-int,
    fill: c.fond,
    radius: if titre != none { (bottom: arc) } else { arc },
    above: 0pt,
    below: 0pt,
    clip: false,
    if l-titre > 0pt { align(center, corps-colore) } else { corps-colore },
  )
  let cadre = block(
    width: l-int + 2 * regle,
    fill: c.cadre,
    radius: arc + regle,
    inset: regle,
    above: 0pt,
    below: 0pt,
    {
      if partie-titre != none {
        partie-titre
        v(regle, weak: false)
      }
      interieur
    },
  )
  let t = if largeur == auto {
    // cadre = filet (regle) + [titre + filet] + intérieur + filet ; l'intérieur a la hauteur de la grille
    let h-titre = if partie-titre != none { measure(partie-titre).height + regle } else { 0pt }
    (width: l-int + 2 * regle, height: 2 * regle + h-titre + mesure-corps.height)
  } else { measure(cadre) }
  box(width: t.width, height: t.height, {
    if ombre { _ombre-floue(t.width, t.height, arc + regle) }
    place(top + left, cadre)
  })
}

/// Placement d'une boîte de tableau :
///   none   : en ligne (tcolorbox nobeforeafter), comme en LaTeX ;
///   left, right : seule sur sa ligne (paragraphe à elle) : \lineskip au-dessus, \baselineskip au-dessous ;
///   center : motif \begin{center}\begin{tcbtab}…\end{tcbtab}\end{center}, relevé sur LaTeX :
///            28,40 pt de la ligne de base précédente au haut du cadre, 27,40 pt du bas du cadre
///            à la ligne de base suivante.
#let _placer(boite, position, m) = {
  if position == none { boite } else if position == center {
    block(width: 100%, above: 28.40pt - m.desc, below: 27.40pt - m.haut, align(center, boite))
  } else {
    block(
      width: 100%,
      above: ptl(1) + m.prof - m.desc,
      below: m.bs - m.haut,
      align(position, boite),
    )
  }
}

/// Le contenu est-il (ou contient-il) un `table(…)` Typst ?
#let _contient-table(c) = {
  if type(c) != content { return false }
  if c.func() == table { return true }
  if c.func() == [*a* *b*].func() { return c.children.any(_contient-table) }
  false
}

/// Tableau Typst déjà construit (forme du convertisseur) : on lui donne la géométrie LaTeX qui ne
/// dépend pas de sa construction — étais `\arraystretch` en tête et en fin de cellule, `\tabcolsep`,
/// couleur et épaisseur des filets. Les filets n'y prennent pas de place (0,4 pt par filet d'écart).
#let _table-fournie(t, etirement, epaisseur, couleur-filets) = {
  let bs = bf-lire(bf-interligne-p).baselineskip
  let haut = etirement * 0.7 * bs
  let prof = etirement * 0.3 * bs
  set table(stroke: epaisseur + couleur-filets)
  set table.hline(stroke: epaisseur + couleur-filets)
  set table.vline(stroke: epaisseur + couleur-filets)
  // la règle remplace le rendu par défaut de la cellule : marge et alignement sont réappliqués
  show table.cell: it => {
    let a = if it.align == auto { left } else { it.align }
    let debut = box(width: 0pt, height: haut)
    let fin = box(width: 0pt, height: prof, baseline: prof)
    pad(x: ptl(6), align(a, [#debut#bf-sans-espace-initial(it.body)#fin]))
  }
  t
}

/// Corps d'un tableau : « spécification + cellules » (forme fidèle), ou `table(…)` Typst déjà construit
/// (seul, ou après la spécification, qui est alors ignorée).
#let _corps-tableau(args, etirement, epaisseur, couleur-filets, fond, largeur-texte: none) = {
  let pos = args.pos()
  let fournie = pos.filter(_contient-table)
  if fournie.len() > 0 {
    _table-fournie(fournie.join(), etirement, epaisseur, couleur-filets)
  } else if pos.len() > 0 and type(pos.at(0)) == str {
    bf-tabular(
      pos.at(0),
      pos.slice(1),
      etirement: etirement,
      epaisseur: epaisseur,
      couleur-filets: couleur-filets,
      fond: fond,
      largeur-texte: largeur-texte,
    )
  } else {
    _table-fournie(pos.join(), etirement, epaisseur, couleur-filets)
  }
}

/// Couleurs d'un tableau, surchargées par des options tcolorbox brutes (`tcb`).
#let _couleurs-tableau(t, tcb) = {
  let c = (
    cadre: _resoudre(t.cadre),
    fond-titre: _resoudre(t.fond-titre),
    texte-titre: _resoudre(t.texte-titre),
    fond: _resoudre(t.fond),
    texte: if t.texte == none { none } else { _resoudre(t.texte) },
  )
  let o = lire-options(tcb)
  let cles = (colframe: "cadre", colbacktitle: "fond-titre", coltitle: "texte-titre", colback: "fond", colupper: "texte", coltext: "texte")
  for (k, v) in o {
    if k in cles { c.insert(cles.at(k), bf-couleur-tcb(v)) }
  }
  c
}

/// \begin{tcbtab}[titre]{spec} … \end{tcbtab}
///   #tcbtab(titre: [Titre], "|p{5cm}|c|c|", [a], [b], [c], hline(), [d], [e], [f])
///   #tcbtab(titre: [Titre], "|p{5cm}|c|c|")[#table(…)]   (tableau déjà construit par le convertisseur)
/// position : none (boîte en ligne, comme LaTeX), left, center, right (bloc seul).
/// tcb : options tcolorbox brutes (colframe, colback, colbacktitle, coltitle, colupper).
#let tcbtab(titre: none, position: none, etirement: 1.5, tcb: none, ..args) = context {
  let t = bf-lire(bf-couleurs-tableaux-p).primaire
  let c = _couleurs-tableau(t, tcb)
  let corps = _corps-tableau(args, etirement, ptl(0.4), _resoudre(t.filets), none, largeur-texte: bf-largeur-courante())
  _placer(_boite-tableau(titre, corps, c), position, bf-metriques())
}

/// \begin{tcbtabc}[titre]{spec}[options] : tcbtab centré (environnement cassé dans la production LaTeX).
#let tcbtabc(titre: none, etirement: 1.5, ..args) = tcbtab(titre: titre, position: center, etirement: etirement, ..args)

/// \begin{tcbtabx}[titre]{spec}{largeur} … \end{tcbtabx} : tableau secondaire en tabularx
/// (colonnes X, filets de 0,5 mm couleur du cadre, \arraystretch = 1,4, titre \bfseries\large).
///   #tcbtabx(titre: [Titre], "|X|X|X|", 80%, [a], [b], [c], hline(), …)
#let tcbtabx(titre: none, position: none, tcb: none, spec, largeur, ..cellules) = context {
  let t = bf-lire(bf-couleurs-tableaux-p).secondaire
  let c = _couleurs-tableau(t + (texte: none), tcb)
  let lt = bf-largeur-courante()
  let l = longueur-latex(largeur, defaut: largeur)
  let l = if type(l) == ratio { l * lt } else if type(l) == relative { l.ratio * lt + l.length } else { l }
  // tabularx : la grille remplit la largeur intérieure (colonnes X en 1fr)
  let args = arguments(spec, ..cellules.pos())
  let corps = block(width: l - 1mm, _corps-tableau(args, 1.4, 0.5mm, c.cadre, none, largeur-texte: lt))
  _placer(
    _boite-tableau(titre, corps, c, largeur: l, marge-titre: 1mm, police-titre: (weight: "bold", size: taille-latex("large"))),
    position,
    bf-metriques(),
  )
}

/// \begin{tcbtabcomp}[titre]{spec} (CompTab : filets blue!50!black, \arraystretch = 0,2).
#let tcbtabcomp(titre: none, position: none, etirement: 0.2, tcb: none, ..args) = context {
  let c = _couleurs-tableau(bf-lire(bf-couleurs-tableaux-p).primaire, tcb)
  let corps = _corps-tableau(args, etirement, ptl(0.4), xcolor("blue!50!black"), none, largeur-texte: bf-largeur-courante())
  _placer(_boite-tableau(titre, corps, c), position, bf-metriques())
}

// alias de compatibilité
#let tableau = tcbtab
