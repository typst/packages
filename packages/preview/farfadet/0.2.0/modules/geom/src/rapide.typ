// rapide.typ (farfadet-geom) — éléments cetz « courts » pour les tracés les plus fréquents.
//
// Pourquoi : chaque `d.line` / `d.content` de cetz résout un système de coordonnées général, fusionne
// tout le dictionnaire de styles (`styles.resolve`), calcule seize ancres et une matrice de décalage,
// puis transforme ses tracés. Pour un segment entre deux points (x, y) ou une étiquette posée par une
// ancre de boussole, presque tout ce travail est inutile. Les éléments ci-dessous produisent DIRECTEMENT
// les mêmes tracés (« drawables ») que cetz : le canevas les place exactement de la même façon.
//
// Garde-fou : la voie courte n'est prise que si le contexte est celui que `geo` a posé (style non modifié
// par un `set-style` de l'utilisateur, pas de résolveur de coordonnées, pas de mode debug) et si les
// points sont des couples de nombres. Sinon on appelle l'élément cetz d'origine : même résultat, coût
// d'origine.

#import "@preview/cetz:0.5.3": draw as d

#let _ident4 = ((1.0, 0.0, 0.0, 0.0), (0.0, 1.0, 0.0, 0.0), (0.0, 0.0, 1.0, 0.0), (0.0, 0.0, 0.0, 1.0))

/// Contexte « standard » : celui que `geo` a posé, sans style ni résolveur ajoutés par l'utilisateur.
#let _contexte-ok(ctx) = (
  not ctx.debug and ctx.resolve-coordinate == () and ctx.at("bfgeom-style", default: none) == ctx.style
)

/// Point (x, y) ou (x, y, z) de nombres → vecteur de flottants, ou `none` si autre forme (ancre, polaire…).
#let _vec(p) = {
  if type(p) != array or p.len() < 2 or p.len() > 3 { return none }
  for c in p { if type(c) != int and type(c) != float { return none } }
  (float(p.at(0)), float(p.at(1)), float(p.at(2, default: 0)))
}

/// Même calcul que `matrix.mul4x4-vec3` de cetz.
#let _transformer(m, v) = {
  if m == _ident4 { return v }
  let (x, y, z) = v
  let ((a1, a2, a3, a4), (b1, b2, b3, b4), (c1, c2, c3, c4), _) = m
  (a1 * x + a2 * y + a3 * z + a4, b1 * x + b2 * y + b3 * z + b4, c1 * x + c2 * y + c3 * z + c4)
}

/// Trait résolu comme le ferait `styles.resolve` pour un trait donné en dictionnaire.
#let _trait(ctx, stroke) = {
  if stroke == auto { ctx.style.stroke } else if stroke == none { none } else if type(stroke) == dictionary and type(ctx.style.stroke) == dictionary { ctx.style.stroke + stroke } else { auto }
}

/// Segments d'un chemin ouvert ou fermé, normalisés comme `path-util.normalize` (fermeture explicite,
/// segments de longueur nulle retirés).
#let _segments(vs, close) = {
  let origine = vs.first()
  let segs = ()
  let prec = origine
  for v in vs.slice(1) {
    if v != prec { segs.push(("l", v)) }
    prec = v
  }
  if close and prec != origine { segs.push(("l", origine)) }
  ((origine, close, segs),)
}

/// Ligne brisée (comme `d.line(..pts, stroke:, fill:, close:)`, sans flèche ni nom).
#let ligne(..pts, stroke: auto, fill: auto, close: false) = {
  let pts = pts.pos()
  (ctx => {
    let vs = pts.map(_vec)
    let st = _trait(ctx, stroke)
    if not _contexte-ok(ctx) or vs.any(v => v == none) or st == auto or (fill != auto and fill != none and type(fill) != color) {
      let style = (:)
      if stroke != auto { style.stroke = stroke }
      if fill != auto { style.fill = fill }
      return (d.line(..pts, close: close, ..style).first())(ctx)
    }
    ctx.prev.pt = vs.last()
    let m = ctx.transform
    let tv = if m == _ident4 { vs } else { vs.map(v => _transformer(m, v)) }
    (
      ctx: ctx,
      drawables: ((
        type: "path",
        segments: _segments(tv, close),
        fill: if fill == auto { none } else { fill },
        fill-rule: "non-zero",
        stroke: st,
        tags: (),
      ),),
    )
  },)
}

/// Plusieurs segments indépendants `((a, b), (c, e), …)` d'un même trait, en UN élément cetz
/// (chaque segment reste un tracé distinct : rendu identique à autant de `d.line`).
#let segments(paires, stroke: auto) = (ctx => {
  let st = _trait(ctx, stroke)
  let vs = paires.map(((a, b)) => (_vec(a), _vec(b)))
  if not _contexte-ok(ctx) or st == auto or vs.any(((a, b)) => a == none or b == none) {
    let c = ctx
    let tr = ()
    let style-trait = if stroke != auto { (stroke: stroke) } else { (:) }
    for (a, b) in paires {
      let r = (d.line(a, b, ..style-trait).first())(c)
      c = r.ctx
      tr += r.drawables
    }
    return (ctx: c, drawables: tr)
  }
  if vs.len() > 0 { ctx.prev.pt = vs.last().last() }
  let m = ctx.transform
  (
    ctx: ctx,
    drawables: vs.map(((a, b)) => {
      let (ta, tb) = if m == _ident4 { (a, b) } else { (_transformer(m, a), _transformer(m, b)) }
      (
        type: "path",
        segments: ((ta, false, if ta != tb { (("l", tb),) } else { () }),),
        fill: none,
        fill-rule: "non-zero",
        stroke: st,
        tags: (),
      )
    }),
  )
},)

// ---------- Étiquettes ----------

#let _decalages = (
  center: (0, 0), north: (0, 1), south: (0, -1), east: (1, 0), west: (-1, 0),
  north-east: (1, 1), north-west: (-1, 1), south-east: (1, -1), south-west: (-1, -1),
)

#let _mesure(ctx, c) = {
  let s = measure(c)
  (calc.abs(s.width / ctx.length), calc.abs(s.height / ctx.length))
}

#let _arrondi(v) = calc.ceil(v * calc.pow(10, 8)) / calc.pow(10, 8)

/// Contenu posé en `p` par une ancre de boussole (comme `d.content(p, corps, anchor:, padding:)`).
/// Mêmes mesures et même boîte que cetz ; ni cadre, ni rotation, ni nom.
#let contenu(p, corps, anchor: "center", padding: 0pt) = (ctx => {
  let v = _vec(p)
  if (
    not _contexte-ok(ctx) or v == none or anchor not in _decalages or type(padding) not in (length, int, float)
      or ctx.style.content.frame != none or ctx.style.content.wrap != none or ctx.style.content.auto-scale
  ) {
    return (d.content(p, corps, anchor: anchor, padding: padding).first())(ctx)
  }
  let pad = if type(padding) == length { float(padding.to-absolute() / ctx.length) } else { float(padding) }
  // les trois mesures de cetz (hauteur de ligne, profondeur, taille)
  let (_, h-ligne) = _mesure(ctx, text(top-edge: "cap-height", bottom-edge: "baseline", [ #show linebreak: [ ]; #corps]))
  let (_, h-bornes) = _mesure(ctx, text(top-edge: "cap-height", bottom-edge: "bounds", [ #show linebreak: [ ]; #corps]))
  let (cw, ch) = _mesure(ctx, text(top-edge: "cap-height", bottom-edge: "baseline", corps))
  let width = calc.max(0, calc.abs(cw) + pad + pad)
  let height = calc.max(0, calc.abs(ch + h-bornes - h-ligne) + pad + pad)
  let w = width / 2
  let h = height / 2
  let c = _transformer(ctx.transform, v)
  let (dx, dy) = _decalages.at(anchor)
  ctx.prev.pt = v
  (
    ctx: ctx,
    drawables: ((
      type: "content",
      pos: (c.at(0) - dx * w, c.at(1) - dy * h, c.at(2)),
      width: 2 * w,
      height: 2 * h,
      segments: (),
      body: std.rotate(
        -0deg,
        reflow: true,
        origin: center + horizon,
        block(
          width: _arrondi(width) * ctx.length,
          height: _arrondi(height) * ctx.length,
          inset: (top: pad * ctx.length, left: pad * ctx.length, bottom: pad * ctx.length, right: pad * ctx.length),
          text(top-edge: "cap-height", bottom-edge: "baseline", corps),
        ),
      ),
      tags: (),
    ),),
  )
},)

// ---------- Flèches ----------

#let _L0 = 100.0
#let _U0 = 1cm
#let _temoin = rgb(1, 2, 3)

/// Flèche canonique de (0, 0) à (L0, 0), calculée par cetz une fois pour un style donné (appel mémoïsé
/// par Typst : mêmes arguments, même résultat) : renvoie (raccourci du trait, points de la pointe
/// relatifs au bout, tracé de la pointe).
#let _fleche-canon(version, style, longueur, marques, stroke, mark) = {
  let ctx = (
    version: version,
    length: longueur,
    debug: false,
    background: none,
    prev: (pt: (0.0, 0.0, 0.0)),
    style: style,
    transform: _ident4,
    nodes: (:),
    groups: (),
    marks: marques,
    resolve-coordinate: (),
    shared-state: (:),
  )
  let r = (d.line((0, 0), (_L0, 0), stroke: stroke, mark: mark).first())(ctx)
  let (trait, ..pointes) = r.drawables
  let fin = trait.segments.first().at(2).last().last()
  // étendue de la pointe le long du trait, depuis le bout : une flèche plus courte que la pointe (ou
  // que le raccourci du trait) est confiée à cetz, qui la traite à sa façon
  let etendue = _L0 - fin.at(0)
  for p in pointes {
    for (o, _c, s) in p.segments {
      for q in (o,) + s.map(x => x.last()) {
        etendue = calc.max(etendue, calc.abs(q.at(0) - _L0))
      }
    }
  }
  (raccourci: _L0 - fin.at(0), trait: trait, pointes: pointes, etendue: etendue)
}

/// Flèche de `a` vers `b` (comme `d.line(a, b, stroke:, mark:)` avec une pointe au bout).
#let fleche(a, b, stroke: auto, mark: (:)) = (ctx => {
  let va = _vec(a)
  let vb = _vec(b)
  let st = _trait(ctx, stroke)
  let style-trait = if stroke != auto { (stroke: stroke) } else { (:) }
  let repli = () => (d.line(a, b, mark: mark, ..style-trait).first())(ctx)
  if not _contexte-ok(ctx) or va == none or vb == none or st == auto or ctx.transform != _ident4 or va.at(2) != 0 or vb.at(2) != 0 {
    return repli()
  }
  let (dx, dy) = (vb.at(0) - va.at(0), vb.at(1) - va.at(1))
  let l = calc.sqrt(dx * dx + dy * dy)
  // La géométrie de la pointe ne dépend ni de la couleur ni de l'unité de la figure : toutes ses tailles
  // (style `mark` de cetz, épaisseur du trait) sont des longueurs absolues, donc proportionnelles à
  // 1 / unité en coordonnées du canevas. La flèche canonique est calculée une fois, à l'unité `_U0` et
  // dans une couleur témoin, puis mise à l'échelle et repeinte : une entrée de cache par épaisseur et
  // style de trait, au lieu d'une par couleur et par unité de figure.
  let p = if type(stroke) == dictionary { stroke.at("paint", default: none) } else { none }
  let neutre = p != none and p != _temoin
  let (st-c, mk-c) = (stroke, mark)
  if neutre {
    st-c.insert("paint", _temoin)
    if mk-c.at("fill", default: none) == p { mk-c.insert("fill", _temoin) }
  }
  let can = _fleche-canon(ctx.version, ctx.style, _U0, ctx.marks, st-c, mk-c)
  let e = _U0 / ctx.length
  if l <= 1.5 * can.etendue * e { return repli() }
  let (ux, uy) = (dx / l, dy / l)
  let tourner(q) = {
    let (x, y) = ((q.at(0) - _L0) * e, q.at(1) * e)
    (vb.at(0) + x * ux - y * uy, vb.at(1) + x * uy + y * ux, 0.0)
  }
  let peindre(dr) = {
    if not neutre { return dr }
    let s = dr.at("stroke", default: none)
    if type(s) == dictionary and s.at("paint", default: none) == _temoin { s.insert("paint", p); dr.stroke = s }
    else if s == _temoin { dr.stroke = p }
    if dr.at("fill", default: none) == _temoin { dr.fill = p }
    dr
  }
  let r = can.raccourci * e
  let fin = (vb.at(0) - r * ux, vb.at(1) - r * uy, 0.0)
  let trait = peindre(can.trait)
  trait.segments = ((va, false, (("l", fin),)),)
  ctx.prev.pt = vb
  (
    ctx: ctx,
    drawables: (trait,) + can.pointes.map(q => {
      q = peindre(q)
      q.segments = q.segments.map(((o, c, s)) => (tourner(o), c, s.map(((k, ..t)) => (k, ..t.map(tourner)))))
      q
    }),
  )
},)
