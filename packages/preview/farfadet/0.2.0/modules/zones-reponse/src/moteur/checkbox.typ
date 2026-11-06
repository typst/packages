// checkbox.typ (farfadet-crep) — cases à cocher et boîtes à cocher (checkbox, tcbcheckbox, tccheckbox,
// tccheckboxlist).
//
//   checkbox      : \checkbox[options] — case à cocher vectorielle (7 habillages, 21 marques) ;
//   tcbcheckbox   : environnement tcbcheckbox — boîte avec une case dans son coin supérieur gauche ;
//   tccheckbox    : \tccheckbox[options]{contenu} — boîte à cocher sensible au mode correctif ;
//   tccheckboxlist: \tccheckboxlist[options]{liste} — liste de boîtes à cocher en colonnes.
// Les formes viennent de formes.typ, GÉNÉRÉ par generer_formes.py (outil de développement, non publié).

#import "../../../socle/lib.typ": interne as _socle
#import _socle: *
#import "reglages.typ": *
#import "formes.typ": checkbox-skins, checkbox-marks

#let _K = 0.5522847498

// =====================================================================
// Chemins TikZ → curve
// =====================================================================

/// Points (y vers le haut) d'un chemin, points de contrôle compris (boîte englobante de TikZ).
#let _points(chemin) = {
  let pts = ()
  for e in chemin {
    if e.at(0) in ("m", "l") { pts.push((e.at(1), e.at(2))) }
    if e.at(0) == "c" { pts += ((e.at(1), e.at(2)), (e.at(3), e.at(4)), (e.at(5), e.at(6))) }
  }
  pts
}

/// Éléments `curve` d'un chemin : f((x, y)) → (x, y) Typst.
#let _elements(chemin, f) = chemin.map(e => {
  let k = e.at(0)
  if k == "m" { curve.move(f((e.at(1), e.at(2)))) } else if k == "l" { curve.line(f((e.at(1), e.at(2)))) } else if (
    k == "c"
  ) {
    curve.cubic(f((e.at(1), e.at(2))), f((e.at(3), e.at(4))), f((e.at(5), e.at(6))))
  } else { curve.close(mode: "straight") }
})

/// Peinture d'un style : couleur (opacité appliquée), dégradé, motif ; dictionnaire (fill:, stroke:).
#let _peinture(couleur, opacite, style) = {
  let fill = if couleur == none { none } else {
    let c = bf-resoudre-couleur(couleur)
    if opacite < 1 { c.transparentize((1 - opacite) * 100%) } else { c }
  }
  let stroke = none
  if style != none and style != auto {
    if type(style) == dictionary {
      if "fill" in style { fill = style.fill }
      if "stroke" in style { stroke = style.stroke }
    } else { fill = if type(style) == str { xcouleur(style) } else { style } }
  }
  (fill: fill, stroke: stroke)
}

/// Une forme (chemin TikZ) remplie, en coordonnées Typst par f.
#let _forme(chemin, f, peinture) = curve(
  fill: peinture.fill,
  fill-rule: "even-odd",
  stroke: peinture.stroke,
  .._elements(chemin, f),
)

// =====================================================================
// \checkbox
// =====================================================================

/// Rendu d'une case à partir de réglages résolus `r` (à appeler dans un `context`).
#let checkbox-rendu(r) = {
  let w = r.width.to-absolute()
  let sk = checkbox-skins.at(r.skin)
  let pts = _points(sk.chemin) + _points(sk.fond)
  let coches = r.checked == true or (r.checked-corr == true and est-correction())
  let marque = r.check-mark
  let s = w * r.mark-scale
  let (cx, cy) = sk.centre
  if coches and not r.mark-overlay and type(marque) == str {
    pts += _points(checkbox-marks.at(marque)).map(((x, y)) => (cx + x * r.mark-scale, cy + y * r.mark-scale))
  }
  let xmin = calc.min(..pts.map(p => p.at(0))) * w
  let xmax = calc.max(..pts.map(p => p.at(0))) * w
  let base = sk.base * w - r.raise
  let ymin = calc.min(calc.min(..pts.map(p => p.at(1))) * w, base)
  let ymax = calc.max(calc.max(..pts.map(p => p.at(1))) * w, base)
  let f((x, y)) = (x * w - xmin, ymax - y * w)
  let fm((x, y)) = ((cx + x * r.mark-scale) * w - xmin, ymax - (cy + y * r.mark-scale) * w)
  box(width: xmax - xmin, height: ymax - ymin, baseline: base - ymin, {
    // fond, forme, marque
    let pf = _peinture(r.background-color, r.background-opacity, r.background-style)
    if pf.fill != none or pf.stroke != none { place(top + left, _forme(sk.fond, f, pf)) }
    let pc = _peinture(r.color, r.opacity, r.fill-style)
    if pc.fill != none or pc.stroke != none { place(top + left, _forme(sk.chemin, f, pc)) }
    if coches {
      if type(marque) == str {
        let chemin = checkbox-marks.at(marque)
        if r.mark-preaction != none {
          let t = r.mark-preaction
          let trait = if type(t) == dictionary { t.at("stroke", default: t) } else { t }
          place(top + left, curve(stroke: trait, fill: none, .._elements(chemin, fm)))
        }
        place(top + left, _forme(chemin, fm, _peinture(r.mark-color, r.mark-opacity, r.mark-style)))
      } else {
        // marque donnée comme contenu : centrée sur le centre de la case
        let (mx, my) = f((cx, cy))
        place(top + left, dx: mx, dy: my, place(center + horizon, text(fill: bf-resoudre-couleur(r.mark-color), marque)))
      }
    }
  })
}

/// \checkbox[options] : une case à cocher (ou un bouton radio). Réglages : setrdcrep(pour: "checkbox", …).
#let checkbox(commande: "checkbox", ..options) = context {
  let r = reglages-resoudre(registre-crep, pour: "checkbox", local: options.named(), commande: commande)
  checkbox-rendu(r)
}

// =====================================================================
// Polygones à coins arrondis (cadres de tcbcheckbox)
// =====================================================================

/// Éléments `curve` d'un polygone fermé `pts` (coordonnées Typst), coin i arrondi au rayon `rayons.at(i)`.
#let _polygone(pts, rayons) = {
  let n = pts.len()
  let unit((ax, ay), (bx, by)) = {
    let (dx, dy) = (bx - ax, by - ay)
    let l = calc.sqrt(calc.pow(dx.to-absolute() / 1pt, 2) + calc.pow(dy.to-absolute() / 1pt, 2))
    if l == 0 { (0, 0) } else { (dx.to-absolute() / 1pt / l, dy.to-absolute() / 1pt / l) }
  }
  let coins = range(n).map(i => {
    let p = pts.at(i)
    let pr = pts.at(calc.rem(i - 1 + n, n))
    let ps = pts.at(calc.rem(i + 1, n))
    let r = rayons.at(i)
    let (ux, uy) = unit(p, pr)
    let (vx, vy) = unit(p, ps)
    let a = (p.at(0) + r * ux, p.at(1) + r * uy)
    let b = (p.at(0) + r * vx, p.at(1) + r * vy)
    (p: p, a: a, b: b)
  })
  let el = (curve.move(coins.at(0).b),)
  for i in range(1, n) + (0,) {
    let c = coins.at(i)
    el.push(curve.line(c.a))
    let c1 = (c.a.at(0) + _K * (c.p.at(0) - c.a.at(0)), c.a.at(1) + _K * (c.p.at(1) - c.a.at(1)))
    let c2 = (c.b.at(0) + _K * (c.p.at(0) - c.b.at(0)), c.b.at(1) + _K * (c.p.at(1) - c.b.at(1)))
    el.push(curve.cubic(c1, c2, c.b))
  }
  el.push(curve.close(mode: "straight"))
  el
}

#let _aligner(h) = if h == "left" or h == "flush left" { left } else if h in ("right", "flush right") { right } else if (
  h in ("center", "flush center")
) { center } else { left }
#let _valigner(v) = if v == "top" { top } else if v == "bottom" { bottom } else { horizon }
#let _largeur(w, total) = if type(w) == ratio { w * total } else if type(w) == relative { w.length + w.ratio * total } else { w }

// =====================================================================
// tcbcheckbox
// =====================================================================

/// \begin{tcbcheckbox}[options] … \end{tcbcheckbox} : boîte avec une case dans son coin supérieur gauche.
#let tcbcheckbox(..options, corps) = context {
  let r = reglages-resoudre(registre-crep, pour: "tcbcheckbox", local: options.named(), commande: "tcbcheckbox")
  let (xs, ys) = if r.sep != auto { (r.sep, r.sep) } else { (r.xsep, r.ysep) }
  // case : réglages du type « checkbox » + clé `checkbox` + checked corr + couleur automatique
  let oc = r.checkbox
  if r.checked-corr { oc.insert("checked-corr", true) }
  if r.checkbox-auto-color { oc.insert("color", bf-resoudre-couleur(r.colback)) }
  let case = checkbox-rendu(reglages-resoudre(registre-crep, pour: "checkbox", local: oc, commande: "tcbcheckbox"))
  let mc = measure(case)
  let (bw, bh) = (mc.width, mc.height)
  let br = r.boxrule
  block(width: 100%, breakable: false, layout(taille => {
    let W = _largeur(r.width, taille.width)
    let li = W - 2 * br - 2 * r.boxsep - r.left - r.right
    let contenu = block(width: li, align(_aligner(r.halign), corps))
    let hc = measure(contenu).height
    let H = hc + 2 * r.boxsep + r.top + r.bottom + 2 * br
    if r.height != auto { H = calc.max(H, r.height) }
    let arc = r.arc
    // Boîte d'une ligne avec un cadre épais : le bas de l'encoche (sous la case) passait sous le bord
    // intérieur du cadre, le contour intérieur se croisait et le filet gauche disparaissait. La boîte
    // est au moins assez haute pour loger l'encoche, le filet du bas et deux arrondis.
    H = calc.max(H, bh + ys + 2 * br + calc.max(2 * arc, ys))
    let arc-ext = if arc > 0pt { arc + br } else { 0pt }
    let ext = ((0pt, H), (W, H), (W, 0pt), (bw + xs, 0pt), (bw + xs, bh + ys), (0pt, bh + ys))
    let int = (
      (br, H - br),
      (br, bh + ys + br),
      (br + bw + xs, bh + ys + br),
      (br + bw + xs, br),
      (W - br, br),
      (W - br, H - br),
    )
    let cadre = _peinture(r.colframe, r.opacityframe, none).fill
    let fond = _peinture(r.colback, r.opacityback, none).fill
    let el-int = _polygone(int, int.map(_ => arc))
    let el-ext = _polygone(ext, (arc-ext, arc-ext, arc-ext, arc-ext, arc, arc-ext))
    box(width: W, height: H, {
      if fond != none { place(top + left, curve(fill: fond, ..el-int)) }
      if cadre != none { place(top + left, curve(fill: cadre, fill-rule: "even-odd", ..el-ext, ..el-int)) }
      place(top + left, dx: br + r.boxsep + r.left, dy: br + r.boxsep + r.top, box(
        width: li,
        height: H - 2 * br - 2 * r.boxsep - r.top - r.bottom,
        align(_valigner(r.valign), contenu),
      ))
      place(top + left, case)
    })
  }))
}

// =====================================================================
// \tccheckbox, \tccheckboxlist
// =====================================================================

/// Marque vectorielle `nom` (marques de rdcheckbox) de largeur ≈ `taille`, couleur `couleur`.
#let _marque(nom, taille, couleur) = {
  let chemin = checkbox-marks.at(nom, default: none)
  if chemin == none {
    panic("check-mark : marque inconnue « " + str(nom) + " ». Marques possibles : " + reglages-liste(checkbox-marks-noms) + ".")
  }
  let pts = _points(chemin)
  let xmin = calc.min(..pts.map(p => p.at(0)))
  let xmax = calc.max(..pts.map(p => p.at(0)))
  let ymin = calc.min(..pts.map(p => p.at(1)))
  let ymax = calc.max(..pts.map(p => p.at(1)))
  let f((x, y)) = ((x - xmin) * taille, (ymax - y) * taille)
  box(width: (xmax - xmin) * taille, height: (ymax - ymin) * taille, _forme(chemin, f, (fill: couleur, stroke: none)))
}

/// Couleur des lignes épaisses Seyès (seyescolA) des réglages `rc`.
#let _couleurs-a(rc) = {
  let c = rc.seyes-colors
  let a = if type(c) == array { c.at(0) } else { c }
  bf-resoudre-couleur(a)
}

/// Dessin d'une tccheckbox de largeur W (à appeler dans un `context`).
#let _tccheckbox-dessin(r, corps, W, hauteur) = {
  let rc = reglages-courants(registre-crep)
  let coches = r.checked == true or (r.checked-corr == true and est-correction())
  let br = r.boxrule
  let lw = r.left-width
  let li = W - 2 * br - lw - 2 * r.boxsep - r.left - r.right
  let contenu = block(width: li, align(_aligner(r.halign), corps))
  let hc = measure(contenu).height
  let H = hc + 2 * r.boxsep + r.top + r.bottom + 2 * br
  if r.height != auto { H = calc.max(H, r.height) }
  if hauteur != auto { H = calc.max(H, hauteur) }
  let fond = _peinture(r.colback, r.opacityback, none).fill
  let gauche = _peinture(if r.background == auto { xmix(_couleurs-a(rc), 20) } else { r.background }, 1, none).fill
  let col-coche = bf-resoudre-couleur(if r.check-color == auto { crep-correction(rc).couleur } else { r.check-color })
  let marque = if not coches { none } else if type(r.check-mark) == str {
    _marque(r.check-mark, 1em * r.mark-scale, col-coche)
  } else { text(fill: col-coche, r.check-mark) }
  let ry = H - 2 * br - 2 * r.boxsep - r.top - r.bottom
  let dessin = {
    if fond != none { place(top + left, rect(width: W, height: H, fill: fond, radius: r.arc)) }
    place(top + left, box(width: W, height: H, clip: true, radius: r.arc, rect(width: br + lw, height: H, fill: gauche)))
    if br > 0pt {
      place(top + left, dx: br / 2, dy: br / 2, rect(
        width: W - br,
        height: H - br,
        stroke: br + bf-resoudre-couleur(r.colframe),
        radius: calc.max(0pt, r.arc - br / 2),
      ))
    }
    if marque != none { place(top + left, dx: br, box(width: lw, height: H, align(center + horizon, marque))) }
    place(top + left, dx: br + lw + r.boxsep + r.left, dy: br + r.boxsep + r.top, box(
      width: li,
      height: ry,
      align(_valigner(r.valign), contenu),
    ))
  }
  if r.on-line {
    // ligne de base : celle de la première ligne du contenu (centré verticalement)
    let haut = measure(box({
      set par(leading: 0pt)
      set text(bottom-edge: "baseline")
      [x]
    })).height
    let y-base = br + r.boxsep + r.top + (ry - hc) / 2 + haut
    box(width: W, height: H, baseline: H - y-base, dessin)
  } else { block(width: W, height: H, breakable: false, dessin) }
}

/// Rendu d'une tccheckbox (réglages résolus `r`) ; `hauteur` imposée (rangée d'une liste) ou auto.
#let _tccheckbox-rendu(r, corps, hauteur: auto) = if r.on-line {
  // en ligne (on line) : largeur relative rapportée à la largeur courante (\linewidth)
  _tccheckbox-dessin(r, corps, _largeur(r.width, bf-largeur-courante()), hauteur)
} else { layout(taille => _tccheckbox-dessin(r, corps, _largeur(r.width, taille.width), hauteur)) }

/// \tccheckbox[options]{contenu} : boîte à cocher sensible au mode correctif.
#let tccheckbox(..options, corps) = context {
  let r = reglages-resoudre(registre-crep, pour: "tccheckbox", local: options.named(), commande: "tccheckbox")
  _tccheckbox-rendu(r, corps)
}

/// \tccheckboxlist[options]{liste} : liste de boîtes à cocher, en colonnes (une colonne par élément par défaut).
#let tccheckboxlist(..args) = context {
  let o = args.named()
  let elements = args.pos()
  if elements.len() == 1 and type(elements.first()) == array { elements = elements.first() }
  // clés propres à la liste ; les autres clés s'appliquent à toutes les boîtes
  let propres = crep-types.tccheckboxlist.keys()
  let liste = (:)
  let commun = (:)
  for (k, v) in o { if k in propres { liste.insert(k, v) } else { commun.insert(k, v) } }
  let r = reglages-resoudre(registre-crep, pour: "tccheckboxlist", local: liste, commande: "tccheckboxlist")
  let num(v) = if type(v) == int { (v,) } else if type(v) == array { v } else { () }
  let coches = num(r.checked)
  let coches-corr = num(r.checked-corr)
  let n = elements.len()
  let cols = if r.columns > 0 { r.columns } else { calc.max(1, n) }
  let boites = range(n).map(i => {
    let k = i + 1
    let opts = r.raster + r.checkbox-style + commun
    if k in coches { opts += (checked: true) + r.checked-style }
    if k in coches-corr {
      opts += (checked-corr: true)
      if est-correction() { opts += r.checked-style }
    }
    opts += r.checkbox.at(str(k), default: (:))
    reglages-resoudre(registre-crep, pour: "tccheckbox", local: opts, commande: "tccheckboxlist")
  })
  layout(taille => {
    let lc = (taille.width - (cols - 1) * r.col-skip) / cols
    // hauteur de chaque rangée : la plus grande boîte (raster equal height)
    let hauteurs = range(n).map(i => measure(block(width: lc, _tccheckbox-rendu(boites.at(i), elements.at(i)))).height)
    let rangees = range(calc.ceil(n / cols)).map(j => calc.max(..hauteurs.slice(j * cols, calc.min(n, (j + 1) * cols))))
    grid(
      columns: (lc,) * cols,
      column-gutter: r.col-skip,
      row-gutter: r.row-skip,
      ..range(n).map(i => _tccheckbox-rendu(boites.at(i), elements.at(i), hauteur: rangees.at(calc.floor(i / cols)))),
    )
  })
}

// =====================================================================
// Cases bfcours (bfcours-commands.sty)
// =====================================================================

/// \cb : case vide (\checkbox[check mark=mark14, skin=squareshadow]).
#let cb(..options) = checkbox(commande: "cb", check-mark: "mark14", skin: "squareshadow", ..options)

/// \ccb : case cochée en version professeur (… checked corr).
#let ccb(..options) = checkbox(commande: "ccb", check-mark: "mark14", skin: "squareshadow", checked-corr: true, ..options)
