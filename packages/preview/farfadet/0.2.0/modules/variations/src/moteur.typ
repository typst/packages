// moteur.typ (farfadet-tabvar) — mise en page et dessin d'un tableau de signes et de variations.
//
// Tout est dessiné à coordonnées absolues dans une seule `box` (place, line, polygon) : pas de cetz.
// Raison : un tableau de variations n'est que du texte, des traits et des pointes de flèche ; les
// positions se déduisent des mesures des nombres (`measure`), et un dessin cetz ne saurait pas
// mesurer le texte posé pour tenir à distance les flèches. Les longueurs sont calculées en points
// (nombres décimaux) puis converties au moment de poser l'élément.

#import "../../socle/lib.typ": interne as _socle
#import _socle: reglages-resoudre, bf-xcolor, est-correction
#import "reglages.typ": reglages-tabvar
#import "lignes.typ": _contenu, _ac-resolu, _cache

#let _inf = 1e9
#let _pt(l) = l / 1pt
#let _L(f) = f * 1pt

/// Construit le tableau à l'échelle de texte `echelle` dans la largeur disponible `A` ;
/// renvoie `(contenu:, ratio:)` où `ratio` < 1 signale des valeurs trop serrées.
#let _construire(xs, lignes, nom-x, r, prof, tab-ac, A, echelle) = {
  let N = xs.len()
  let base = if r.taille == auto { text.size } else { r.taille }
  let sz = base * echelle
  let S = _pt(sz)
  let txt(c) = {
    show math.frac: it => if r.fractions { math.display(it) } else { it }
    text(size: sz, top-edge: "bounds", bottom-edge: "bounds", c)
  }
  let mes(c) = {
    let m = measure(box(txt(c)))
    (w: _pt(m.width), h: _pt(m.height))
  }
  let pad = 0.42 * S
  let lw = _pt(r.lw)
  let bar = 1.5 // demi-écart des deux traits d'une double barre
  let off = bar + 0.3 * S + lw // distance entre l'axe de la barre et le bord d'un nombre voisin

  let c-cadre = bf-xcolor(r.couleur-cadre, commande: "tabvar")
  let c-fl = bf-xcolor(r.couleur-fleches, commande: "tabvar")
  let c-hach = bf-xcolor(r.couleur-hachures, commande: "tabvar")
  let c-corr = bf-xcolor(r.correction-color, commande: "tabvar")
  let fond = if r.fond == none { none } else { bf-xcolor(r.fond, commande: "tabvar") }

  // ---- Passe 1 : mesures --------------------------------------------------------------------
  let lignes-x = ((genre: "x", nom: nom-x, h: r.h-x, items: xs.map(_contenu)),) + lignes

  let mesurer(l, num) = {
    let eg = (0.0,) * N
    let ed = (0.0,) * N
    let ei = (0.0,) * (N - 1)
    let hmax = 0.0
    let items = ()
    let nom-txt = if num == 0 { "tabvar (ligne des x)" } else { "ligne n° " + str(num) }
    if l.genre == "x" {
      for (k, c) in l.items.enumerate() {
        let m = if c == none { (w: 0.0, h: 0.0) } else { mes(c) }
        eg.at(k) = m.w / 2
        ed.at(k) = m.w / 2
        hmax = calc.max(hmax, m.h)
        items.push((c: c, w: m.w, h: m.h))
      }
    } else if l.genre == "signes" {
      if l.items.len() != 2 * N - 1 {
        panic(
          "tkzTabLine (" + nom-txt + ") : " + str(N) + " valeurs de x demandent " + str(2 * N - 1)
            + " éléments (valeurs de x aux rangs impairs, intervalles aux rangs pairs) ; reçu : "
            + str(l.items.len()) + ".",
        )
      }
      for (i0, it) in l.items.enumerate() {
        let i = i0 + 1
        let impair = calc.odd(i)
        let k = calc.quo(i - 1, 2)
        if impair and it.genre == "h" {
          panic("tkz-tab-line (" + nom-txt + ") : les hachures « h » se placent dans un intervalle (rang pair), pas au rang " + str(i) + ".")
        }
        if not impair and it.genre in ("z", "t", "d", "barre") {
          panic(
            "tkzTabLine (" + nom-txt + ") : « " + (z: "z", t: "t", d: "d", barre: "|").at(it.genre)
              + " » se place sur une valeur de x (rang impair), pas au rang " + str(i) + ".",
          )
        }
        let c = if it.genre == "z" { $0$ } else if it.genre in ("signe", "texte") { it.c } else { none }
        let m = if c == none { (w: 0.0, h: 0.0) } else { mes(c) }
        hmax = calc.max(hmax, m.h)
        if impair {
          eg.at(k) = calc.max(eg.at(k), m.w / 2)
          ed.at(k) = calc.max(ed.at(k), m.w / 2)
          if it.genre in ("d", "barre") {
            eg.at(k) = calc.max(eg.at(k), bar)
            ed.at(k) = calc.max(ed.at(k), bar)
          }
        } else {
          ei.at(k) = calc.max(ei.at(k), m.w + 2 * pad)
        }
        items.push((..it, c: c, w: m.w, h: m.h))
      }
    } else {
      if l.items.len() != N {
        panic(
          "tkzTabVar (" + nom-txt + ") : " + str(N) + " valeurs de x demandent " + str(N)
            + " éléments, un par valeur de x (« R » pour une colonne vide) ; reçu : " + str(l.items.len()) + ".",
        )
      }
      for (k, it) in l.items.enumerate() {
        let pts = it.pts.map(p => {
          let m = if p.val == none { (w: 0.0, h: 0.0) } else { mes(p.val) }
          (..p, w: m.w, h: m.h)
        })
        let im = if it.im == none { none } else {
          let m = mes(it.im)
          (c: it.im, w: m.w, h: m.h)
        }
        if im != none {
          eg.at(k) = calc.max(eg.at(k), im.w / 2)
          ed.at(k) = calc.max(ed.at(k), im.w / 2)
          hmax = calc.max(hmax, im.h)
        }
        if it.barre {
          eg.at(k) = calc.max(eg.at(k), bar)
          ed.at(k) = calc.max(ed.at(k), bar)
        }
        for p in pts {
          hmax = calc.max(hmax, p.h)
          if p.cote == "c" {
            eg.at(k) = calc.max(eg.at(k), p.w / 2)
            ed.at(k) = calc.max(ed.at(k), p.w / 2)
          } else if p.cote == "g" {
            eg.at(k) = calc.max(eg.at(k), off + p.w)
          } else {
            ed.at(k) = calc.max(ed.at(k), off + p.w)
          }
        }
        items.push((..it, pts: pts, im: im))
      }
    }
    (..l, items: items, eg: eg, ed: ed, ei: ei, hmax: calc.max(hmax, 0.8 * S))
  }
  let infos = lignes-x.enumerate().map(((j, l)) => mesurer(l, j))

  // ---- Géométrie générale ------------------------------------------------------------------
  let fini = A < 1e5 * 1pt
  let larg = r.largeur
  let W-cible = if larg == auto { none } else if type(larg) == ratio {
    if fini { _pt(A * larg) } else { none }
  } else { _pt(larg) }
  let W-max = if fini { _pt(A) } else { _inf }

  let w-noms = infos.map(l => mes(l.nom).w).fold(0.0, (a, b) => calc.max(a, b))
  let lgt = if r.lgt != auto { _pt(r.lgt) } else {
    calc.min(w-noms + 3 * pad, 0.34 * (if W-cible != none { W-cible } else { W-max }))
  }
  let nom-h(n) = _pt(measure(box(width: _L(lgt - 2 * pad), align(center, txt(n)))).height)

  let ml = if r.deltacl != auto { _pt(r.deltacl) } else {
    infos.map(l => l.eg.first()).fold(0.9 * S, (a, b) => calc.max(a, b)) + pad
  }
  let mr = if r.deltacl != auto { _pt(r.deltacl) } else {
    infos.map(l => l.ed.last()).fold(0.9 * S, (a, b) => calc.max(a, b)) + pad
  }

  let besoin = 0.0
  for l in infos {
    let gmin = if l.genre == "variations" { 1.4 * S } else { 0.8 * S }
    for k in range(N - 1) {
      besoin = calc.max(besoin, l.ed.at(k) + l.eg.at(k + 1) + gmin, l.ei.at(k))
    }
  }
  let sp-nat = calc.max(_pt(r.espcl), besoin)
  let W-nat = lgt + ml + mr + (N - 1) * sp-nat
  let W = if W-cible != none { W-cible } else { calc.min(W-nat, W-max) }
  let sp = calc.max((W - lgt - ml - mr) / (N - 1), 1.0)
  let ratio = if besoin > 0 { sp / besoin } else { 10.0 }

  // hauteurs de lignes
  let u = _pt(r.unite)
  let hauteurs = infos.map(l => {
    let hn = nom-h(l.nom) + 2 * pad
    let need = if l.genre == "variations" { calc.max(hn, 2 * l.hmax + 2 * pad + 0.9 * S) } else {
      calc.max(hn, l.hmax + 2 * pad)
    }
    calc.max(l.h * u, need)
  })
  let ys = (0.0,)
  for h in hauteurs { ys.push(ys.last() + h) }
  let H = ys.last()

  let px(k) = lgt + ml + k * sp

  // ---- Primitives de dessin -----------------------------------------------------------------
  let st-trait = _L(lw) + c-cadre
  let st-fin = (paint: c-cadre, thickness: _L(lw * 0.85), dash: r.pointilles)
  let ligne(x1, y1, x2, y2, st) = place(
    top + left,
    line(start: (_L(x1), _L(y1)), end: (_L(x2), _L(y2)), stroke: st),
  )
  let centrer(x, y, c, fill: none, inset: 0pt) = {
    let m = measure(box(inset: inset, txt(c)))
    place(
      top + left,
      dx: _L(x) - m.width / 2,
      dy: _L(y) - m.height / 2,
      box(fill: fill, inset: inset, txt(c)),
    )
  }
  let colorer(c, corr) = if corr { text(fill: c-corr, c) } else { c }
  let hachures = tiling(
    size: (5pt, 5pt),
    {
      place(line(start: (0pt, 5pt), end: (5pt, 0pt), stroke: 0.55pt + c-hach))
      place(line(start: (-1pt, 1pt), end: (1pt, -1pt), stroke: 0.55pt + c-hach))
      place(line(start: (4pt, 6pt), end: (6pt, 4pt), stroke: 0.55pt + c-hach))
    },
  )
  let double-barre(x, y0, y1) = (
    ligne(x - bar, y0, x - bar, y1, st-trait),
    ligne(x + bar, y0, x + bar, y1, st-trait),
  )

  // Flèche de `a` à `b` (points : x, y, w, h en pt) ; `images` : valeurs posées dessus.
  let fleche(a, b, couleur, dessiner, images) = {
    let dx = b.x - a.x
    let dy = b.y - a.y
    let long = calc.sqrt(dx * dx + dy * dy)
    let g = _pt(r.marge-fleches)
    let tc(hw, hh) = calc.min(
      if dx == 0 { _inf } else { hw / calc.abs(dx) },
      if dy == 0 { _inf } else { hh / calc.abs(dy) },
    )
    if long == 0 { return () }
    let t0 = tc(a.w / 2 + g, a.h / 2 + g)
    let t1 = tc(b.w / 2 + g, b.h / 2 + g)
    if t0 + t1 >= 1 - 3.5 / long { return () }
    let sx = a.x + t0 * dx
    let sy = a.y + t0 * dy
    let ex = b.x - t1 * dx
    let ey = b.y - t1 * dy
    let ux = dx / long
    let uy = dy / long
    let hl = _pt(r.pointe)
    let hw = 0.34 * hl
    let bx = ex - ux * hl
    let by = ey - uy * hl
    let ep = if r.ep-fleches == auto { lw } else { _pt(r.ep-fleches) }
    let out = ()
    if dessiner {
      out.push(ligne(sx, sy, bx + ux * 0.5 * hl, by + uy * 0.5 * hl, (paint: couleur, thickness: _L(ep), cap: "round")))
      out.push(place(
        top + left,
        polygon(
          fill: couleur,
          stroke: none,
          (_L(ex), _L(ey)),
          (_L(bx - uy * hw), _L(by + ux * hw)),
          (_L(bx + uy * hw), _L(by - ux * hw)),
        ),
      ))
    }
    for im in images {
      if im.montrer and dx != 0 {
        let y = a.y + (im.x - a.x) * dy / dx
        out.push(centrer(im.x, y, colorer(im.c, im.corr), fill: fond, inset: (x: 1.6pt, y: 0.8pt)))
      }
    }
    out
  }

  // ---- Contenu d'une ligne de signes -------------------------------------------------------
  let dessiner-signes(l, y0, y1, hid) = {
    let fonds = ()
    let traits = ()
    let textes = ()
    let ym = (y0 + y1) / 2
    for (i0, it) in l.items.enumerate() {
      let i = i0 + 1
      let k = calc.quo(i - 1, 2)
      let impair = calc.odd(i)
      let cache = _cache(hid, i)
      let montrer = not cache or prof
      if it.genre == "h" {
        let xa = if k == 0 { lgt } else { px(k) }
        let xb = if k == N - 2 { W } else { px(k + 1) }
        fonds.push(place(
          top + left,
          dx: _L(xa),
          dy: _L(y0),
          rect(width: _L(xb - xa), height: _L(y1 - y0), fill: hachures, stroke: none),
        ))
      } else if it.genre in ("z", "t") {
        traits.push(ligne(px(k), y0, px(k), y1, st-fin))
        if it.genre == "z" and montrer {
          textes.push(centrer(px(k), ym, colorer(it.c, cache), fill: fond, inset: (x: 1.6pt, y: 0.8pt)))
        }
      } else if it.genre == "d" {
        traits += double-barre(px(k), y0, y1)
      } else if it.genre == "barre" {
        traits.push(ligne(px(k), y0, px(k), y1, st-trait))
      } else if it.genre in ("signe", "texte") and montrer {
        let x = if impair { px(k) } else { (px(k) + px(k + 1)) / 2 }
        textes.push(centrer(x, ym, colorer(it.c, cache)))
      }
    }
    fonds + traits + textes
  }

  // ---- Contenu d'une ligne de variations ---------------------------------------------------
  let dessiner-var(l, y0, y1, hid) = {
    let out = ()
    let valeurs = ()
    let hv = l.hmax
    let yh = y0 + pad + hv / 2
    let yb = y1 - pad - hv / 2
    let prev = none
    let attente = ()
    let nfl = 0
    for (k, it) in l.items.enumerate() {
      let kk = k + 1
      if it.barre { out += double-barre(px(k), y0, y1) }
      let abs = it.pts.map(p => {
        let xc = if p.cote == "c" { px(k) } else if p.cote == "g" { px(k) - off - p.w / 2 } else {
          px(k) + off + p.w / 2
        }
        (x: xc, y: if p.niveau == "h" { yh } else { yb }, w: p.w, h: p.h, val: p.val)
      })
      let ent = if it.ent == none { none } else { abs.at(it.ent) }
      let sor = if it.sor == none { none } else { abs.at(it.sor) }
      let cache-val = _cache(hid.val, kk)
      if it.im != none {
        attente.push((
          x: px(k),
          c: it.im.c,
          montrer: not cache-val or prof,
          corr: cache-val,
        ))
      }
      if ent != none {
        if prev != none {
          nfl += 1
          let cache-f = _cache(hid.fl, nfl)
          out += fleche(prev, ent, if cache-f { c-corr } else { c-fl }, not cache-f or prof, attente)
        }
        attente = ()
      } else if not it.passe {
        attente = ()
      }
      if not it.passe { prev = sor }
      if not cache-val or prof {
        for p in abs {
          if p.val != none { valeurs.push(centrer(p.x, p.y, colorer(p.val, cache-val))) }
        }
      }
    }
    out + valeurs
  }

  // ---- Assemblage ---------------------------------------------------------------------------
  let el = ()
  // hachures d'abord (sous les traits), puis cadre et lignes de séparation
  let corps = ()
  for (j, l) in infos.enumerate() {
    let y0 = ys.at(j)
    let y1 = ys.at(j + 1)
    let ym = (y0 + y1) / 2
    corps.push(place(
      top + left,
      dy: _L(y0),
      box(width: _L(lgt), height: _L(y1 - y0), inset: (x: _L(pad)), align(center + horizon, txt(l.nom))),
    ))
    if l.genre == "x" {
      for (k, it) in l.items.enumerate() {
        if it.c != none { corps.push(centrer(px(k), ym, it.c)) }
      }
    } else {
      let hid = _ac-resolu(l.a-completer, tab-ac, j)
      if l.genre == "signes" { corps += dessiner-signes(l, y0, y1, hid.val) } else {
        corps += dessiner-var(l, y0, y1, hid)
      }
    }
  }
  if not r.nocadre {
    el.push(place(top + left, rect(width: _L(W), height: _L(H), stroke: st-trait, fill: none)))
  }
  for j in range(1, infos.len()) { el.push(ligne(0, ys.at(j), W, ys.at(j), st-trait)) }
  el.push(ligne(lgt, 0, lgt, H, st-trait))
  el += corps
  (contenu: box(width: _L(W), height: _L(H), el.join()), ratio: ratio)
}

/// Vérifie les arguments publics de `tabvar` puis dessine le tableau.
#let tabvar(x, ..args, nom-x: auto, a-completer: false, version: auto) = {
  if type(x) != array or x.len() < 2 {
    panic("tabvar : les valeurs de x forment un tableau d'au moins deux éléments, par exemple (\"-oo\", \"0\", \"+oo\") ; reçu : " + repr(x) + ".")
  }
  let lignes = args.pos()
  if lignes.len() == 0 {
    panic("tabvar : au moins une ligne est attendue (tkz-tab-line ou tkz-tab-var).")
  }
  for (j, l) in lignes.enumerate() {
    if type(l) != dictionary or "bf-tabvar-ligne" not in l {
      panic(
        "tabvar : l'argument n° " + str(j + 2) + " n'est pas une ligne ; utiliser tkz-tab-line(…) ou tkz-tab-var(…). Reçu : "
          + repr(l) + ".",
      )
    }
  }
  if not (a-completer in (true, false) or (type(a-completer) == array and a-completer.all(i => type(i) == int))) {
    panic(
      "tabvar : la clé « a-completer » attend true, false ou une liste de numéros de lignes (1 = première ligne après les x) ; reçu : "
        + repr(a-completer) + ".",
    )
  }
  if version not in (auto, "prof", "eleve") {
    panic("tabvar : la clé « version » attend auto, \"prof\" ou \"eleve\" ; reçu : " + repr(version) + ".")
  }
  context {
    let prof = if version == "prof" { true } else if version == "eleve" { false } else { est-correction() }
    let r = reglages-resoudre(reglages-tabvar, local: args.named(), commande: "tabvar")
    let nx = if nom-x == auto { $x$ } else { _contenu(nom-x) }
    layout(size => {
      let res = _construire(x, lignes, nx, r, prof, a-completer, size.width, 1.0)
      if r.reduire and res.ratio < 1 {
        res = _construire(x, lignes, nx, r, prof, a-completer, size.width, calc.max(0.6, res.ratio))
      }
      align(r.alignement, res.contenu)
    })
  }
}
