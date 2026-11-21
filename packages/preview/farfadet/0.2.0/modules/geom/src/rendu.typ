// rendu.typ (farfadet-geom) — canevas de farfadet-geom : même traitement des éléments que `cetz.canvas`
// (process.many), mais un RENDU propre, qui évite la recomposition des figures au tour 2.
//
// Pourquoi : `measure` met ses éléments repérables (formules) en « mode mesure » : chacun cherche, par
// introspection, son jumeau dans le document réel (`Locator`, `MeasureIntrospection`). Au tour 1 il n'y a
// pas de jumeau, au tour 2 il y en a un (l'étiquette dessinée) : la réponse change, et toute la figure,
// avec chaque conteneur qui l'englobe, est recalculée. Deux différences avec le rendu de cetz :
//   1. une étiquette posée par une ancre (rotation nulle) n'est plus mesurée : sa taille est celle du bloc
//      qui l'enveloppe, lue dans ses champs (même valeur que `measure`) ;
//   2. les formules des étiquettes dessinées reçoivent l'étiquette Typst <bf-geo-rendu> : leur clé de
//      repérage diffère de celle des formules mesurées par les éléments (d.content, rapide.contenu), qui
//      n'ont donc plus de jumeau, ni au tour 1 ni au tour 2.
// Tout le reste (ordre, boîte englobante, tracés `curve`) reproduit `cetz.canvas` (cetz 0.5.3,
// src/canvas.typ) ; seuls les arguments employés par `geo` sont pris en charge (length, body).

#import "@preview/cetz:0.5.3": process, drawable, path-util, styles, version as _cetz-version

#let _ident = ((1.0, 0.0, 0.0, 0.0), (0.0, 1.0, 0.0, 0.0), (0.0, 0.0, 1.0, 0.0), (0.0, 0.0, 0.0, 1.0))

/// Pose l'étiquette <bf-geo-rendu> sur chaque formule du contenu (parcours des emballages usuels).
#let _sans-jumeau(c) = {
  if type(c) != content { return c }
  let f = c.func()
  if f == math.equation { return [#c<bf-geo-rendu>] }
  if f == [].func() { return c.children.map(_sans-jumeau).sum(default: []) }
  if c.has("child") and c.has("styles") { return f(_sans-jumeau(c.child), c.styles) }
  if f == rotate {
    let fs = c.fields()
    let b = fs.remove("body")
    let a = fs.remove("angle", default: 0deg)
    return rotate(a, ..fs, _sans-jumeau(b))
  }
  if f in (block, box, align, pad, move) and c.has("body") {
    let fs = c.fields()
    let b = fs.remove("body")
    if f == align {
      let al = fs.remove("alignment")
      return align(al, ..fs, _sans-jumeau(b))
    }
    return f(..fs, _sans-jumeau(b))
  }
  c
}

/// Taille d'un corps d'étiquette sans `measure` quand c'est `rotate(0deg, reflow: true, block(width:, height:))`
/// aux dimensions absolues ; sinon `none`.
#let _taille-connue(b) = {
  if b.func() != rotate or b.at("angle", default: 0deg) != 0deg { return none }
  let i = b.body
  if i.func() != block { return none }
  let (w, h) = (i.at("width", default: auto), i.at("height", default: auto))
  if type(w) != length or type(h) != length { return none }
  if w.em != 0 or h.em != 0 { return none }
  (w, h)
}

/// Boîte englobante de points (x, y, z) : même résultat que `aabb.aabb` de cetz (min et max par axe,
/// calculés par son greffon WASM), sans l'aller-retour vers le greffon (sérialisation CBOR à chaque élément).
#let _englobante(pts) = {
  let xs = pts.map(p => p.at(0))
  let ys = pts.map(p => p.at(1))
  let zs = pts.map(p => p.at(2, default: 0.0))
  (
    low: (float(calc.min(..xs)), float(calc.min(..ys)), float(calc.min(..zs))),
    high: (float(calc.max(..xs)), float(calc.max(..ys)), float(calc.max(..zs))),
  )
}

/// `aabb.merge` de cetz 0.5.3 (non exporté par cetz).
#let _fusion(a, b) = {
  if a == none { return b }
  if b == none { return a }
  let (alx, aly, alz) = a.low
  let (ahx, ahy, ahz) = a.high
  let (blx, bly, blz) = b.low
  let (bhx, bhy, bhz) = b.high
  (
    low: (calc.min(alx, blx), calc.min(aly, bly), calc.min(alz, blz)),
    high: (calc.max(ahx, bhx), calc.max(ahy, bhy), calc.max(ahz, bhz)),
  )
}

/// `process.many` de cetz 0.5.3 (src/process.typ), boîtes englobantes calculées en Typst (`_englobante`).
/// Repli sur cetz en mode debug (cadres de débogage).
#let _many(ctx, body) = {
  if ctx.debug { return process.many(ctx, body) }
  let drawables = ()
  let bounds = none
  for el in body {
    let (ctx: c, ..element) = el(ctx)
    ctx = c
    let b = none
    if "drawables" in element {
      if type(element.drawables) == dictionary { element.drawables = (element.drawables,) }
      let points = ()
      for dr in element.drawables {
        if drawable.TAG.no-bounds in dr.tags { continue }
        points += if dr.type == "path" {
          path-util.bounds(dr.segments)
        } else if dr.type == "content" {
          let (x, y, _, w, h) = dr.pos + (dr.width, dr.height)
          ((x - w / 2, y - h / 2, 0.0), (x + w / 2, y + h / 2, 0.0))
        }
      }
      if points.len() > 0 { b = _englobante(points) }
    }
    let name = element.at("name", default: none)
    if name != none {
      assert.eq(type(name), str, message: "Element name must be a string")
      assert(not name.contains("."), message: "Invalid name for element '" + name + "'; name must not contain '.'")
      if "anchors" in element {
        element.name = name
        ctx.nodes.insert(name, element)
        if ctx.groups.len() > 0 { ctx.groups.last().push(name) }
      }
    } else if element.at("leak-nodes", default: false) {
      if ctx.groups.len() > 0 { ctx.groups.last() += ctx.nodes.keys() }
    }
    bounds = _fusion(bounds, b)
    drawables += element.at("drawables", default: ())
  }
  (ctx: ctx, bounds: bounds, drawables: drawables)
}

#let canevas(length: 1cm, body) = context {
  if body == none { return [] }
  let length = length.to-absolute()
  let ctx = (
    version: _cetz-version,
    length: length,
    debug: false,
    background: none,
    prev: (pt: (0.0, 0.0, 0.0)),
    style: styles.default,
    transform: _ident,
    nodes: (:),
    groups: (),
    marks: (mnemonics: (:), marks: (:)),
    resolve-coordinate: (),
    shared-state: (:),
  )
  let (ctx, bounds, drawables) = _many(ctx, body)
  if bounds == none { return [] }
  drawables = drawable.filter-tagged(drawables, drawable.TAG.hidden)
  drawables = drawables.sorted(key: cmd => cmd.at("z-index", default: 0))

  let (width, height) = ((bounds.high.at(0) - bounds.low.at(0)) * length, (bounds.high.at(1) - bounds.low.at(1)) * length)
  let width = calc.abs(width)
  let height = calc.abs(height)
  let (offset-x, offset-y, ..) = bounds.low
  offset-y = -offset-y - height / length

  block(breakable: false, width: width, height: height, stroke: none, fill: none, align(top, {
    for dr in drawables {
      let (segment-x, segment-y) = if dr.type == "path" {
        let pts = path-util.bounds(dr.segments)
        let lx = calc.min(..pts.map(p => p.at(0)))
        let hy = calc.max(..pts.map(p => p.at(1)))
        (lx - bounds.low.at(0), bounds.high.at(1) - hy)
      } else { (0, 0) }

      place(top + left, float: false, if dr.type == "path" {
        let vertices = ()
        let transform-point((x, y, ..)) = ((x - offset-x - segment-x) * length, (-y - offset-y - segment-y) * length)
        for ((origin, closed, segments)) in dr.segments {
          vertices.push(curve.move(transform-point(origin)))
          for ((kind, ..args)) in segments {
            if kind == "l" {
              for pt in args { vertices.push(curve.line(transform-point(pt))) }
            } else if kind == "c" {
              vertices.push(curve.cubic(..args.map(transform-point)))
            } else { panic(kind, args) }
          }
          if closed { vertices.push(curve.close(mode: "straight")) }
        }
        if type(dr.stroke) == dictionary and "thickness" in dr.stroke and type(dr.stroke.thickness) != std.length {
          dr.stroke.thickness *= length
        }
        std.curve(stroke: dr.stroke, fill: dr.fill, fill-rule: dr.at("fill-rule", default: "non-zero"), ..vertices)
      } else if dr.type == "content" {
        let t = _taille-connue(dr.body)
        let (w, h) = if t != none { t } else { let m = std.measure(dr.body); (m.width, m.height) }
        move(
          dx: (dr.pos.at(0) - offset-x) * length - w / 2,
          dy: (-dr.pos.at(1) - offset-y) * length - h / 2,
          _sans-jumeau(dr.body),
        )
      }, dx: segment-x * length, dy: segment-y * length)
    }
  }))
}
