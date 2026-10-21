// rdratio.typ (rdratio, moteur) — barre de proportion (une case par unité, dégradé de couleurs),
// accolades et légendes au-dessus et en dessous ; `dratio` (écriture « 2 : 3 ») et `sumlist`.
//
// Géométrie : repère de Typst (origine en haut à gauche du cadre, y vers le bas). Les points nommés
// (rdframe, rdbox<n>, rdmid<n>) forment un dictionnaire passé à la fonction `code-after`.

#import "../../../socle/lib.typ": interne as _socle
#import _socle: reglages-paquet, reglages-controles, reglages-choix, reglages-ou, xmix, taille-latex
#import "commun.typ": *

// =====================================================================
// Réglages (`setrdratio`)
// =====================================================================

#let _style = rd-controle-style
#let _liste = (
  v => v == none or type(v) in (array, str),
  "none, un tableau ou une chaîne LaTeX « a, b, c »",
)

#let rdratio-reglages = reglages-paquet(
  "rdratio",
  (
    width: 6cm,
    height: 0.8cm,
    brace-amplitude: 2.5pt,
    auto-width: false,
    auto-height: false,
    line-width: 1pt,
    rounded-corners: 3pt,
    colframe: "black",
    leftcol: "red",
    rightcol: "blue",
    colors: none,
    align: "center",
    raise: 0pt,
    labels: "all",
    label-above: none,
    label-above-font: "footnotesize",
    label-above-color: "black",
    label-above-sep: 2mm,
    label-above-node-sep: 2pt,
    label-above-line-width: 0.7pt,
    label-above-decoration: none,
    label-below: none,
    label-below-auto: ("part", "parts"),
    label-below-font: "footnotesize",
    label-below-color: "black",
    label-below-auto-colors: false,
    label-below-sep: 2mm,
    label-below-node-sep: 2pt,
    label-below-line-width: 0.7pt,
    label-below-decoration: none,
    label-below-n: none,
    label-below-node-n: none,
    ratiobox: none,
    code-after: none,
    remember: false,
    // mesures réglables (ajouts)
    label-inner-sep: 0.3333em, // inner sep par défaut des nœuds TikZ
    label-phantom: [ÀÊÉpgjy], // \vphantom{ÀÊÉpgjy} : légendes de même hauteur
    dratio-sep: [#h(1em / 6):#h(1em / 6)], // \,:\, de \dratio
  ),
  controles: (
    width: reglages-controles.longueur,
    height: reglages-controles.longueur,
    brace-amplitude: reglages-controles.longueur,
    line-width: reglages-controles.longueur,
    rounded-corners: reglages-controles.longueur,
    raise: reglages-controles.longueur,
    colframe: reglages-controles.couleur-ou-nom,
    leftcol: reglages-controles.couleur-ou-nom,
    rightcol: reglages-controles.couleur-ou-nom,
    label-above-color: reglages-controles.couleur-ou-nom,
    label-below-color: reglages-controles.couleur-ou-nom,
    colors: _liste,
    align: reglages-choix("top", "center", "bottom"),
    labels: reglages-choix("above", "below", "all", "none"),
    label-above: reglages-controles.contenu-ou-none,
    label-above-font: rd-controle-police,
    label-below-font: rd-controle-police,
    label-above-decoration: _style,
    label-below-decoration: _style,
    label-below: _liste,
    label-below-auto: (
      v => (type(v) == array and v.len() == 2) or type(v) == str,
      "un tableau (singulier, pluriel) ou une chaîne LaTeX « part, parts »",
    ),
    label-below-n: rd-controle-styles-numerotes,
    label-below-node-n: rd-controle-styles-numerotes,
    ratiobox: rd-controle-styles-numerotes,
    code-after: (v => v == none or type(v) == function, "none ou une fonction (points) => contenu"),
    label-inner-sep: reglages-controles.longueur,
    label-phantom: reglages-controles.contenu-ou-none,
    dratio-sep: reglages-controles.contenu,
  ),
  commande: "setrdratio",
)

// =====================================================================
// Outils
// =====================================================================

/// \sumlist{a,b,…} : somme d'une liste (tableau ou chaîne « a,b,c »).
#let rd-sumlist(v) = rd-liste(if type(v) == int { (v,) } else { v }).map(x => if type(x) == str { int(x) } else { x }).sum(default: 0)

/// Lit la liste des parts d'un ratio : tableau d'entiers ou chaîne « 2,3 ».
#let rdratio-lire(v, commande: "rdratio") = {
  let l = if type(v) == int { (v,) } else { rd-liste(v) }
  let res = ()
  for x in l {
    let n = if type(x) == str and x.match(regex("^[0-9]+$")) != none { int(x) } else { x }
    if type(n) != int or n < 1 {
      panic(commande + " : ratio illisible " + repr(v) + ". Forme attendue : un tableau d'entiers positifs (2, 3) ou une chaîne \"2,3\".")
    }
    res.push(n)
  }
  if res.len() == 0 { panic(commande + " : ratio vide.") }
  res
}

// Taille de police (pour résoudre les em d'une marge) : dans un `context`.
#let _taille-police(f) = {
  if type(f) == str { taille-latex(f) } else if type(f) == length { f.to-absolute() } else if type(f) == dictionary and "size" in f {
    let s = f.size
    if type(s) == str { taille-latex(s) } else { s.to-absolute() }
  } else { text.size }
}

#let _em(l, taille) = if type(l) == length { l.abs + l.em * taille } else { l }

// Légende (nœud TikZ : inner sep, \vphantom) ; renvoie (corps, w, ht, dp, i, hc).
#let _legende(c, couleur, police, style, phantom, inner, commande) = {
  let st = rd-style(style, commande: commande)
  // Le fantôme tient dans une boîte de largeur nulle : sans `hyphenate: false` ni `justify: false`, un
  // document justifié le coupait lettre à lettre en autant de lignes (légendes rejetées très bas).
  let corps = text(fill: couleur, [#c#if phantom != none {
    box(width: 0pt, hide({ set par(justify: false); set text(hyphenate: false); phantom }))
  }])
  corps = rd-appliquer-police(corps, police, commande: commande)
  corps = rd-texte(corps, st, commande: commande)
  let taille = _taille-police(police)
  let i = _em(inner, taille)
  let b = rd-boite(corps)
  (corps: corps, w: b.w, ht: b.ht, dp: b.dp, i: i, hc: rd-haut-cadre(corps))
}

#let _point(x, y) = (x, y)

#let _ancres(x, y, w, h) = (
  x: x,
  y: y,
  width: w,
  height: h,
  center: (x + w / 2, y + h / 2),
  north: (x + w / 2, y),
  south: (x + w / 2, y + h),
  east: (x + w, y + h / 2),
  west: (x, y + h / 2),
  north-west: (x, y),
  north-east: (x + w, y),
  south-west: (x, y + h),
  south-east: (x + w, y + h),
)

// =====================================================================
// Rendu (dans un `context`)
// =====================================================================

/// Rendu de \ratio : `r` = réglages résolus, `parts` = liste d'entiers.
#let rdratio-rendu(r, parts, commande: "rdratio") = {
  let cmd = commande
  let n = rd-sumlist(parts)
  let lw = rd-abs(r.line-width)
  let W = rd-abs(r.width)
  let H = rd-abs(r.height)
  let bh = H - 2 * lw
  let bw = (W - (n + 1) * lw) / n
  if r.auto-height {
    bh = bw
    H = bh + 2 * lw
  }
  if r.auto-width {
    bw = bh
    W = lw + n * (bw + lw)
  }
  let rc = rd-abs(r.rounded-corners)
  let rci = calc.max(0pt, rc - lw)
  // couleurs des parts
  let utilisateur = rd-liste(r.colors)
  let k = parts.len()
  let gauche = rd-couleur(r.leftcol, commande: cmd)
  let droite = rd-couleur(r.rightcol, commande: cmd)
  let cols = range(1, k + 1).map(i => {
    if utilisateur.len() > 0 { rd-couleur(rd-cycle(utilisateur, i), commande: cmd) } else if k == 1 { gauche } else {
      xmix(gauche, 100 - 100 * (i - 1) / (k - 1), autre: droite)
    }
  })
  let col-case = ()
  for (i, p) in parts.enumerate() { for _ in range(p) { col-case.push(cols.at(i)) } }
  let boxes = if r.ratiobox == none { (:) } else { r.ratiobox }

  // ancres (repère : origine en haut à gauche du cadre)
  let pas = (W - lw) / n
  let a = (rdframe: _ancres(0pt, 0pt, W, H))
  for j in range(n) {
    let x = lw + j * pas
    a.insert("rdbox" + str(j + 1), _ancres(x, lw, bw, bh))
    a.insert("rdmid" + str(j), (x - lw / 2, H / 2))
  }
  a.insert("rdmid" + str(n), (W - lw / 2, H / 2))
  a.insert("ratioBL", (0pt, H))
  a.insert("ratioBR", (W, H))
  a.insert("ratioTR", (W, 0pt))
  a.insert("ratioTL", (0pt, 0pt))
  a.insert("ratioML", (0pt, H / 2))
  // abscisses des accolades inférieures (ratioB<i>)
  let xb = (lw / 2,)
  for p in parts { xb.push(xb.last() + p * (bw + lw)) }
  for (i, x) in xb.enumerate() { a.insert("ratioB" + str(i + 1), (x, H)) }
  a.insert("ratioT1", (lw / 2, 0pt))
  a.insert("ratioT2", (W - lw / 2, 0pt))

  let haut = r.labels in ("above", "all")
  let bas = r.labels in ("below", "all")
  let elements = ()
  let (xmin, xmax, ymin, ymax) = (0pt, W, 0pt, H)

  // cadre et cases
  elements.push(place(top + left, rect(width: W, height: H, radius: rc, fill: rd-couleur(r.colframe, commande: cmd), stroke: none)))
  for j in range(n) {
    let b = a.at("rdbox" + str(j + 1))
    let st = rd-style(boxes.at(str(j + 1), default: none), commande: cmd, cle: "ratiobox")
    let kk = st.cles
    let fond = if "fill" in kk { rd-fond(st, commande: cmd) } else { col-case.at(j) }
    let op = kk.at("fill-opacity", default: kk.at("opacity", default: none))
    if "fill" not in kk and op != none and op < 1 { fond = fond.transparentize((1 - op) * 100%) }
    let trait = if "draw" in kk { rd-trait(st, commande: cmd) } else { none }
    elements.push(place(top + left, dx: b.x, dy: b.y, rect(width: bw, height: bh, radius: kk.at("radius", default: rci), fill: fond, stroke: trait)))
    if "pattern" in kk and kk.pattern != none {
      elements.push(place(top + left, dx: b.x, dy: b.y, rect(width: bw, height: bh, radius: kk.at("radius", default: rci), fill: kk.pattern, stroke: none)))
    }
    if "content" in kk and kk.content != none {
      elements.push(rd-node-at(b.center, rd-texte(kk.content, st, commande: cmd)))
    }
  }

  // accolade supérieure
  if haut {
    let st = rd-style(r.label-above-decoration, commande: cmd, cle: "label-above-decoration")
    let ampl = rd-abs(st.cles.at("amplitude", default: r.brace-amplitude))
    let trait = rd-trait(st, defaut: black, epaisseur: rd-abs(r.label-above-line-width), commande: cmd)
    let (x1, x2) = (lw / 2, W - lw / 2)
    let y = -rd-abs(r.label-above-sep)
    if trait != none { elements.push(place(top + left, dx: x1, dy: y, rd-accolade(x2 - x1, ampl, trait, haut: true))) }
    let lg = _legende(
      if r.label-above == none { [] } else { r.label-above },
      rd-couleur(r.label-above-color, commande: cmd), r.label-above-font, none, r.label-phantom, r.label-inner-sep, cmd,
    )
    let bas-noeud = y - ampl - rd-abs(r.label-above-node-sep)
    let base = bas-noeud - lg.i - lg.dp
    let xg = (x1 + x2) / 2 - lg.w / 2
    elements.push(place(top + left, dx: xg, dy: base - lg.hc, lg.corps))
    ymin = calc.min(ymin, base - lg.ht - lg.i)
    xmin = calc.min(xmin, xg - lg.i)
    xmax = calc.max(xmax, xg + lg.w + lg.i)
  }

  // accolades inférieures
  if bas {
    let auto-l = rd-liste(r.label-below-auto)
    let perso = if r.label-below == none { () } else { rd-liste(r.label-below) }
    let st-n = if r.label-below-n == none { (:) } else { r.label-below-n }
    let st-nn = if r.label-below-node-n == none { (:) } else { r.label-below-node-n }
    for (i, p) in parts.enumerate() {
      let num = str(i + 1)
      let prefixe = if r.label-below-auto-colors { (draw: cols.at(i)) } else { none }
      let st = rd-style-fusion(prefixe, r.label-below-decoration, st-n.at(num, default: none), commande: cmd)
      let ampl = rd-abs(st.cles.at("amplitude", default: r.brace-amplitude))
      let trait = rd-trait(st, defaut: black, epaisseur: rd-abs(r.label-below-line-width), commande: cmd)
      let (x1, x2) = (xb.at(i), xb.at(i + 1))
      let y = H + rd-abs(r.label-below-sep)
      if trait != none { elements.push(place(top + left, dx: x1, dy: y, rd-accolade(x2 - x1, ampl, trait, haut: false))) }
      let texte = if perso.len() > 0 { perso.at(i, default: []) } else {
        [#p #if p > 1 { auto-l.at(1) } else { auto-l.at(0) }]
      }
      let couleur = if r.label-below-auto-colors { cols.at(i) } else { rd-couleur(r.label-below-color, commande: cmd) }
      let lg = _legende(texte, couleur, r.label-below-font, st-nn.at(num, default: none), r.label-phantom, r.label-inner-sep, cmd)
      let haut-noeud = y + ampl + rd-abs(r.label-below-node-sep)
      let base = haut-noeud + lg.i + lg.ht
      let xg = (x1 + x2) / 2 - lg.w / 2
      elements.push(place(top + left, dx: xg, dy: base - lg.hc, lg.corps))
      ymax = calc.max(ymax, base + lg.dp + lg.i)
      xmin = calc.min(xmin, xg - lg.i)
      xmax = calc.max(xmax, xg + lg.w + lg.i)
    }
  }

  // code after : fonction des ancres ; `node` pose un contenu centré sur un point.
  let points = a + (node: rd-node-at)
  if r.code-after != none { elements.push((r.code-after)(points)) }
  if r.remember { elements.push(place(top + left, [#metadata(a)<rdratio-remember>])) }

  // ligne de base
  let ya = if r.align == "top" { 0pt } else if r.align == "bottom" { H } else { H / 2 }
  let yref = ya + rd-abs(r.raise)
  box(
    width: xmax - xmin,
    height: ymax - ymin,
    baseline: ymax - yref,
    place(top + left, dx: -xmin, dy: -ymin, box(width: W, height: H, elements.join())),
  )
}

/// \dratio{2:3} : écrit un rapport avec des espaces fines autour des deux-points.
#let rdratio-dratio(v, sep) = {
  let l = if type(v) == array { v } else { str(v).split(":").map(x => x.trim()) }
  l.map(x => if type(x) == str { [#x] } else { [#x] }).join(sep)
}
