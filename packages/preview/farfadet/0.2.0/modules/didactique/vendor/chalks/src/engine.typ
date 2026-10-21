// WASM bridge: CBOR in/out to chalks-engine. Styling stays in Typst.
#import "style.typ": auto-seed, engine-fill-style, engine-stroke-style, resolve-style

#let _engine = plugin("../plugin/chalks_engine.wasm")

/// Returns the bundled Chalks WASM engine version string.
///
/// This is mainly useful for diagnostics and package smoke tests.
#let engine-version() = str(_engine.version())

// Round to 1e-6 pt: calc.sin/cos/exp go through the platform math library,
// whose last-ULP results vary across OSes; unrounded they would re-roll
// auto-seed and make committed example images irreproducible in CI.
#let _pt(p) = (
  calc.round(float(p.at(0)), digits: 6),
  calc.round(float(p.at(1)), digits: 6),
)

// Décimation (correctif local, voir PROVENANCE.md) : le moteur échantillonne les contours à
// résolution fixe (jusqu'à 1024 cubiques par passe, soit une cubique tous les 1,5 pt sur un cadre
// de page). C'est bien plus fin que ce qu'un rendu papier demande, et chaque cubique pèse dans le
// PDF. On fusionne les cubiques par paquets de `chalks-decimation` en doublant les tangentes des
// extrémités (fusion classique de Béziers) : le tracé reste le même à l'œil, le fichier maigrit.
// Défaut 2 pour bfcours (décision du 18/09/2026) : deux fois moins de segments, tracé
// indiscernable à taille d'impression. `#bf-craie-allegement(1)` rend le tracé complet.
#let chalks-decimation = state("chalks:decimation", 2)

#let _fusionner(depart, paquet) = {
  let n = paquet.len()
  let premiere = paquet.first()
  let derniere = paquet.last()
  let fin = derniere.at(2)
  if n == 1 { return premiere }
  let c1 = (
    depart.at(0) + n * (premiere.at(0).at(0) - depart.at(0)),
    depart.at(1) + n * (premiere.at(0).at(1) - depart.at(1)),
  )
  let c2 = (
    fin.at(0) + n * (derniere.at(1).at(0) - fin.at(0)),
    fin.at(1) + n * (derniere.at(1).at(1) - fin.at(1)),
  )
  (c1, c2, fin)
}

/// Éléments `curve` d'un chemin du moteur, cubiques fusionnées par paquets de `pas` (fonction pure :
/// mémoïsée par Typst). Même arithmétique que `_fusionner` (même tracé au bit près), mais en UNE boucle
/// `for` sur `chunks(pas)`, avec déstructuration : ni `while` + `slice`, ni appels `.at`, ni fermetures
/// `map` (un appel de fermeture coûte plus cher qu'un tour de boucle). Le départ d'un paquet est
/// l'extrémité du paquet précédent, que la fusion conserve.
/// Mesure (cadre de Démonstration, ~1 650 cubiques) : 15 ms → 8 ms par cadre.
#let _elements(p, pas) = {
  let elems = ()
  for sp in p.subpaths {
    let (d0, d1) = sp.start
    elems.push(curve.move((d0 * 1pt, d1 * 1pt)))
    for paquet in sp.cubics.chunks(calc.max(pas, 1)) {
      let n = paquet.len()
      if n == 1 {
        let ((a0, a1), (b0, b1), (e0, e1)) = paquet.first()
        elems.push(curve.cubic((a0 * 1pt, a1 * 1pt), (b0 * 1pt, b1 * 1pt), (e0 * 1pt, e1 * 1pt)))
        (d0, d1) = (e0, e1)
      } else {
        let ((p0, p1), _, _) = paquet.first()
        let (_, (q0, q1), (f0, f1)) = paquet.last()
        elems.push(curve.cubic(
          ((d0 + n * (p0 - d0)) * 1pt, (d1 + n * (p1 - d1)) * 1pt),
          ((f0 + n * (q0 - f0)) * 1pt, (f1 + n * (q1 - f1)) * 1pt),
          (f0 * 1pt, f1 * 1pt),
        ))
        (d0, d1) = (f0, f1)
      }
    }
    elems.push(curve.close())
  }
  elems
}

/// Version pure de `render-paths` (le pas de décimation est passé en argument) : sans `context`, ses
/// appels sont mémoïsés par Typst d'un emplacement à l'autre et d'un tour de mise en page à l'autre.
#let poser-chemins(paths, color, opacity, pas) = {
  for p in paths {
    let alpha = calc.max(0%, 100% - opacity * p.weight)
    place(top + left, curve(
      fill: color.transparentize(alpha),
      fill-rule: "even-odd",
      .._elements(p, pas),
    ))
  }
}

/// Engine paths -> filled curve elements, placed at (0,0) of the caller's
/// frame. weight scales opacity (shade layering).
#let render-paths(paths, color, opacity) = context poser-chemins(paths, color, opacity, chalks-decimation.get())

/// Draws a low-level hand-sketched stroke directly through explicit points.
///
/// Prefer `path` inside `sketch` for normal figures. This function bypasses
/// shape builders and returns placed content directly.
///
/// - points (array): Two or more `(x, y)` points as numbers in points, with
///   positive y downward.
/// - closed (bool): Join the last point to the first. Default: `false`.
/// - style (dictionary): Engine stroke keys: `smoothness`, `roughness`,
///   `width`, `taper`, and `passes`; rendering keys `color` and `opacity` are
///   also accepted. Default: `(:)`.
/// - seed (auto, int): Deterministic RNG seed; `auto` derives one from the
///   geometry. Default: `auto`.
#let raw-stroke(points, closed: false, style: (:), seed: auto) = context {
  let s = resolve-style(style)
  let pts = points.map(_pt)
  let seed = if seed == auto { auto-seed(("stroke", pts, closed)) } else { seed }
  let req = cbor.encode((
    points: pts,
    closed: closed,
    style: engine-stroke-style(s),
    seed: seed,
  ))
  render-paths(cbor(_engine.stroke(req)).paths, s.color, s.opacity)
}

/// Draws a low-level fill directly from explicit closed boundary rings.
///
/// Nested rings are holes under the even-odd rule. Prefer a filled shape or
/// `region` inside `sketch` for normal figures.
///
/// - boundaries (array): Array of rings, each containing at least three
///   `(x, y)` points as numbers in points, with positive y downward.
/// - style (dictionary): Fill keys: `pattern` (`"hachure"` or `"shade"`),
///   `smoothness`, `roughness`, `width`, `angle`, and `spacing`; `color` and
///   `opacity` are also accepted. Default: `(:)`.
/// - seed (auto, int): Deterministic RNG seed; `auto` derives one from the
///   boundaries. Default: `auto`.
#let raw-fill(boundaries, style: (:), seed: auto) = context {
  let s = resolve-style(style)
  let bs = boundaries.map(b => b.map(_pt))
  let seed = if seed == auto { auto-seed(("fill", bs)) } else { seed }
  let req = cbor.encode((
    boundaries: bs,
    style: engine-fill-style(s),
    seed: seed,
  ))
  render-paths(cbor(_engine.fill(req)).paths, s.color, s.opacity)
}
