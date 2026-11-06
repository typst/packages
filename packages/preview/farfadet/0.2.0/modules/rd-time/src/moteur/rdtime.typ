// rdtime.typ (rdtime, moteur) — addition ou soustraction de durées posée en colonnes, avec retenues
// et cellules barrées.
//
// Le calcul produit les lignes SI, SS, A, B, RR, R et la matrice des cellules à barrer.
// La ligne RI (retenue en cascade des secondes vers les heures) est calculée mais jamais affichée.

#import "../../../socle/lib.typ": interne as _socle
#import _socle: (
  reglages-paquet, reglages-controles, reglages-choix, reglages-ou, reglages-resoudre, reglages-courants,
  bf-reglages-socle, est-correction, bf-xcolor, xmix,
)
#import "commun.typ": *

// =====================================================================
// Réglages (`setrdtime`)
// =====================================================================

#let _style = rd-controle-style

#let rdtime-reglages = reglages-paquet(
  "rdtime",
  (
    operation: "add",
    add: false,
    sub: false,
    digit-width: 0.65em, // 1.5ex
    column-sep: 0.5em,
    hour-label: [h],
    min-label: [min],
    sec-label: [s],
    minus-sign: $-$,
    plus-sign: $+$,
    name: "timematrix",
    baseline: 0,
    display-intermediary: true,
    visible: true,
    mode-correctif: false,
    correction: false,
    matrix: none,
    nodes: none,
    sign: none,
    rule: none,
    special-cell: (stroke-out: (line-width: 0.8pt, color: "red", shadowed: "black")),
    result: none,
    result-h: none,
    result-min: none,
    result-sec: none,
    first-number: none,
    first-number-h: none,
    first-number-min: none,
    first-number-sec: none,
    second-number: none,
    second-number-h: none,
    second-number-min: none,
    second-number-sec: none,
    intermediary: none,
    labels: none,
    hours-label: none,
    minutes-label: none,
    seconds-label: none,
    // mesures réglables (ajouts)
    text-height: 6mm,
    text-depth: 2mm,
    rule-width: 0.8pt,
    matrix-inset: 0.3333em,
  ),
  controles: (
    operation: reglages-choix("add", "sub"),
    add: reglages-controles.booleen,
    sub: reglages-controles.booleen,
    hour-label: reglages-controles.contenu,
    min-label: reglages-controles.contenu,
    sec-label: reglages-controles.contenu,
    minus-sign: reglages-controles.contenu,
    plus-sign: reglages-controles.contenu,
    name: (v => v == none or type(v) == str, "none ou une chaîne (nom du label Typst posé sur l'opération)"),
    baseline: (
      v => v in ("c", "t", "b", "sign", "result") or type(v) == int,
      "\"c\", \"t\", \"b\", \"sign\", \"result\" ou un entier (numéro de ligne)",
    ),
    matrix: _style,
    nodes: _style,
    sign: _style,
    rule: _style,
    special-cell: _style,
    result: _style,
    result-h: _style,
    result-min: _style,
    result-sec: _style,
    first-number: _style,
    first-number-h: _style,
    first-number-min: _style,
    first-number-sec: _style,
    second-number: _style,
    second-number-h: _style,
    second-number-min: _style,
    second-number-sec: _style,
    intermediary: _style,
    labels: _style,
    hours-label: _style,
    minutes-label: _style,
    seconds-label: _style,
    matrix-inset: (v => type(v) in (length, dictionary), "une longueur ou un dictionnaire (left, right, top, bottom, x, y)"),
  ),
  commande: "setrdtime",
)

// =====================================================================
// Calcul
// =====================================================================

/// Lit une durée « XX h YY min ZZ s » (espaces facultatifs ; h, min, s dans cet ordre) : (h, m, s).
#let rdtime-lire(d, commande: "rdtime") = {
  if type(d) == int { return (h: 0, m: 0, s: d) }
  if type(d) != str {
    panic(commande + " : une durée s'écrit comme une chaîne \"2 h 37 min 12 s\" ; reçu : " + repr(d) + ".")
  }
  let t = d.replace(regex("\s+"), "")
  let lire(x) = {
    if x == "" { return 0 }
    if x.match(regex("^[0-9]+$")) == none {
      panic(commande + " : durée illisible " + repr(d) + ". Forme attendue : \"XX h YY min ZZ s\" (heures, puis minutes, puis secondes).")
    }
    int(x)
  }
  let (h, m, s) = (0, 0, 0)
  let reste = t
  if "h" in reste {
    let p = reste.split("h")
    h = lire(p.at(0))
    reste = p.slice(1).join("h")
  }
  if "min" in reste {
    let p = reste.split("min")
    m = lire(p.at(0))
    reste = p.slice(1).join("min")
  }
  if reste != "" {
    if not reste.ends-with("s") {
      panic(commande + " : durée illisible " + repr(d) + ". Forme attendue : \"XX h YY min ZZ s\" (heures, puis minutes, puis secondes).")
    }
    s = lire(reste.slice(0, -1))
  }
  (h: h, m: m, s: s)
}

/// Lignes de l'opération posée : dictionnaire ligne → (H, M, S) des valeurs, barrées → (H, M, S) booléens,
/// colonnes présentes (H, S), ordre des lignes. `addition` : true/false.
#let rdtime-calcul(a, b, addition) = {
  let da = 3600 * a.h + 60 * a.m + a.s
  let db = 3600 * b.h + 60 * b.m + b.s
  let r = if addition { da + db } else { da - db }
  let hr = calc.quo(r, 3600)
  let mr = calc.quo(r - 3600 * hr, 60)
  let sr = r - 3600 * hr - 60 * mr
  let zero = (H: 0, M: 0, S: 0)
  let non = (H: false, M: false, S: false)
  let v = (SI: zero, SS: zero, A: (H: a.h, M: a.m, S: a.s), B: (H: b.h, M: b.m, S: b.s), R: (H: hr, M: mr, S: sr), RR: zero, RI: zero)
  let x = (SI: non, SS: non, A: non, B: non, R: non, RR: non, RI: non)
  let (col-h, col-s) = (true, true)
  if addition {
    let (srr, mrr, hrr) = (a.s + b.s, a.m + b.m, a.h + b.h)
    col-s = srr != 0
    col-h = hr != 0
    if srr > 59 {
      v.RR = (H: hrr, M: mrr, S: srr)
      x.RR.S = true
      x.RR.M = true
      if mrr >= 59 {
        v.RI = (H: hrr, M: mrr + 1, S: srr - 60)
        x.RI.M = true
        x.RI.H = true
      }
    } else if mrr > 59 {
      v.RR = (H: hrr, M: mrr, S: srr)
      x.RR.M = true
      x.RR.H = true
    }
  } else {
    col-s = a.s + b.s + sr != 0
    col-h = a.h + b.h + hr != 0
    let mtmp = a.m
    if a.s < b.s {
      x.A.S = true
      x.A.M = true
      if a.m == 0 {
        x.A.H = true
        v.SS.H = a.h - 1
        v.SS.M = 60
        x.SS.M = true
        v.SI.M = 59
        mtmp = 59
        v.SI.S = a.s + 60
      } else {
        v.SS.S = a.s + 60
        v.SS.M = a.m - 1
        mtmp = a.m - 1
      }
    }
    if mtmp < b.m {
      x.A.H = true
      if x.A.M {
        x.SS.M = true
        v.SI.M = mtmp + 60
        v.SI.H = a.h - 1
      } else {
        x.A.M = true
        v.SS.M = mtmp + 60
        v.SS.H = a.h - 1
      }
    }
  }
  (valeurs: v, barrees: x, col-h: col-h, col-s: col-s, impossible: not addition and db > da)
}

// =====================================================================
// Rendu (dans un `context`)
// =====================================================================

#let _chiffres(n, largeur) = {
  let s = str(n)
  if n < 10 { s = "0" + s }
  s.clusters().map(c => box(width: largeur, align(center, c))).join()
}

/// Rendu de \rdtime : `r` = réglages résolus (dictionnaire), `a`, `b` = durées lues.
#let rdtime-rendu(r, a, b, commande: "rdtime") = {
  let cmd = commande
  let operation = if r.sub { "sub" } else if r.add { "add" } else { r.operation }
  let addition = operation == "add"
  let corr = reglages-courants(bf-reglages-socle).correction-color
  let corr = bf-xcolor(corr, commande: cmd)
  // style de la correction
  let mode-correctif = r.mode-correctif or r.correction
  let st-result = r.result
  let st-inter = r.intermediary
  let st-special = r.special-cell
  if r.correction {
    st-result = ((text: corr, font: (weight: "bold")), st-result)
    st-inter = ((text: xmix(corr, 75)), st-inter)
    if st-special == rdtime-reglages.defauts.special-cell {
      st-special = (stroke-out: (line-width: 0.8pt, color: corr, shadowed: "black"))
    }
  }
  let visible = if mode-correctif { est-correction() } else { r.visible }
  let c = rdtime-calcul(a, b, addition)
  if c.impossible {
    return box(text(fill: red, weight: "bold")[Soustraction impossible !])
  }
  let unites = ()
  if c.col-h { unites.push("H") }
  unites.push("M")
  if c.col-s { unites.push("S") }
  let libelle = (H: r.hour-label, M: r.min-label, S: r.sec-label)
  let st-libelle-unite = (H: r.hours-label, M: r.minutes-label, S: r.seconds-label)
  let suffixe = (H: "h", M: "min", S: "sec")
  let st-ligne = (A: r.first-number, B: r.second-number, R: st-result, RR: st-inter, RI: st-inter, SS: st-inter, SI: st-inter)
  let st-cellule(l, u) = if l == "A" { r.at("first-number-" + suffixe.at(u)) } else if l == "B" {
    r.at("second-number-" + suffixe.at(u))
  } else if l == "R" { r.at("result-" + suffixe.at(u)) } else { none }
  let nodes = rd-style(r.nodes, commande: cmd, cle: "nodes")
  let th = nodes.cles.at("text-height", default: r.text-height)
  let td = nodes.cles.at("text-depth", default: r.text-depth)
  let mw = nodes.cles.at("min-width", default: 0.65em)
  let base-noeud = rd-style-fusion((text-height: th, text-depth: td, min-width: mw), nodes, commande: cmd)
  // Lignes affichées (ordre : SI, SS, A, B, RR, R ; RI jamais affichée)
  let ordre = if r.display-intermediary { ("SI", "SS", "A", "B", "RR", "R") } else { ("A", "B", "R") }
  let lignes = ordre.filter(l => {
    let x = c.valeurs.at(l)
    x.H + x.M + x.S > 0
  })
  let ncol = 1 + 2 * unites.len()
  // cellules : (contenu, style, barree)
  let grille = ()
  for l in lignes {
    let rangee = ()
    let cache = not visible and l not in ("A", "B")
    if cache {
      for _ in range(ncol) { rangee.push((c: none, st: base-noeud, x: false)) }
      grille.push(rangee)
      continue
    }
    let speciale = l in ("SS", "SI")
    if l == "B" {
      rangee.push((c: if addition { r.plus-sign } else { r.minus-sign }, st: rd-style-fusion(base-noeud, r.sign, commande: cmd), x: false))
    } else { rangee.push((c: none, st: base-noeud, x: false)) }
    for u in unites {
      let val = c.valeurs.at(l).at(u)
      let barree = c.barrees.at(l).at(u) and visible
      let st-c = rd-style-fusion(base-noeud, st-ligne.at(l), st-cellule(l, u), if barree { st-special } else { none }, commande: cmd)
      let st-l = rd-style-fusion(
        base-noeud,
        st-ligne.at(l),
        if speciale { none } else { r.labels },
        if speciale { none } else { st-libelle-unite.at(u) },
        commande: cmd,
      )
      if val == 0 and speciale {
        rangee.push((c: none, st: st-c, x: false))
        rangee.push((c: none, st: st-l, x: false))
      } else {
        rangee.push((c: _chiffres(val, r.digit-width), st: st-c, x: barree))
        rangee.push((c: libelle.at(u), st: st-l, x: false))
      }
    }
    grille.push(rangee)
  }
  // Nœuds et largeurs de colonnes (nœuds alignés à droite : ancre `left` = east de TikZ)
  let noeuds = grille.map(rangee => rangee.map(x => (n: rd-noeud(x.c, x.st, commande: cmd), st: x.st, x: x.x)))
  let largeurs = range(ncol).map(j => calc.max(..noeuds.map(rg => rg.at(j).n.w)))
  let rowh = th + td
  let sep = r.column-sep
  let xs = ()
  let x0 = 0pt
  for j in range(ncol) {
    xs.push(x0)
    x0 += largeurs.at(j) + sep
  }
  let largeur = x0 - sep
  let hauteur = lignes.len() * rowh
  let em = 0.5em
  let corps = box(width: largeur, height: hauteur, {
    for (i, rg) in noeuds.enumerate() {
      for (j, cel) in rg.enumerate() {
        let x = xs.at(j) + largeurs.at(j) - cel.n.w
        let y = i * rowh + (rowh - cel.n.h) / 2
        place(top + left, dx: x, dy: y, cel.n.corps)
        // cellule barrée : stroke out (trait de (-0.5em, -2ex) à (0.5em, 1ex) autour du centre)
        if cel.x {
          let so = cel.st.cles.at("stroke-out", default: none)
          if so != none {
            let so = if so == true { (:) } else { so }
            let col = rd-couleur(so.at("color", default: "red"), commande: cmd)
            let ombre = so.at("shadowed", default: "black")
            let ombre = if ombre == none { none } else { rd-couleur(ombre, commande: cmd) }
            let trait = (paint: col, thickness: so.at("line-width", default: 0.8pt), cap: "butt")
            let cx = x + cel.n.w / 2
            let cy = y + cel.n.h / 2
            rd-trait-ombre(cx - em, cy + 0.86em, cx + em, cy - 0.43em, trait, ombre: ombre)
          }
        }
      }
    }
    // trait horizontal sous le second terme (de la colonne 2 à la dernière colonne)
    let ib = lignes.position(l => l == "B")
    if ib != none {
      let rg = noeuds.at(ib)
      let xg = xs.at(1) + largeurs.at(1) - rg.at(1).n.w
      let xd = xs.at(ncol - 1) + largeurs.at(ncol - 1)
      let y = ib * rowh + (rowh - rg.at(1).n.h) / 2 + rg.at(1).n.h
      let st = rd-style(r.rule, commande: cmd, cle: "rule")
      let trait = rd-trait(st, epaisseur: r.rule-width, commande: cmd)
      if trait != none { place(top + left, line(start: (xg, y), end: (xd, y), stroke: trait)) }
    }
  })
  // Cadre de la matrice (clé `matrix`) : fond, contour, marge intérieure (inner sep de \matrix)
  let mst = rd-style(r.matrix, commande: cmd, cle: "matrix")
  let m = rd-marges(mst.cles.at("inset", default: r.matrix-inset))
  let cadre-fond = rd-fond(mst, commande: cmd)
  let cadre-trait = if "draw" in mst.cles { rd-trait(mst, commande: cmd) } else { none }
  let cadre-rayon = mst.cles.at("radius", default: 0pt)
  let total = hauteur + m.top + m.bottom
  // Ligne de base
  let i-a = lignes.position(l => l == "A")
  let i-a = if i-a == none { 0 } else { i-a }
  let ligne-base(i) = m.top + i * rowh + th
  let bl = if r.baseline == "c" { total / 2 } else if r.baseline == "t" { total } else if r.baseline == "b" { 0pt } else {
    let i = if r.baseline == "sign" { lignes.position(l => l == "B") } else if r.baseline == "result" { lignes.len() - 1 } else if (
      type(r.baseline) == int and r.baseline > 0 and r.baseline <= lignes.len()
    ) { r.baseline - 1 } else { i-a }
    let i = if i == none { i-a } else { i }
    total - ligne-base(i)
  }
  // `bl` : distance de la ligne visée au bas du cadre (marge basse comprise). Typst compte la ligne de base
  // d'une boîte à `inset` depuis le bas du CONTENU : la marge basse est déjà sous la ligne de base, on la
  // retranche, sinon l'opération descend d'autant sous le texte qui l'entoure.
  let res = box(baseline: bl - m.bottom, inset: m, fill: cadre-fond, stroke: cadre-trait, radius: cadre-rayon, corps)
  if r.name != none { [#res#label(r.name)] } else { res }
}
