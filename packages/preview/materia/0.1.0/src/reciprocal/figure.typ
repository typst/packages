// User-facing reciprocal-space figure layer: the textbook Brillouin-zone drawing
// (translucent BZ polyhedron + labelled high-symmetry points + the k-path traced
// on it) and an optional flat band-path panel, both assembled from `scenery`
// primitives and rendered through the shared scene core.
//
// Pipeline (bz-figure): lattice -> primitive reciprocal basis (b1,b2,b3) ->
// `bz-cell` (Wigner-Seitz cell of the reciprocal lattice) -> a translucent
// `scenery.mesh` with visible edge strokes, overlaid with the SC-2010 k-points
// (small spheres), the recommended path (thick `seg`s) and pretty Greek labels.
//
// IMPORTANT — primitive vs conventional cell. The first Brillouin zone is the
// Wigner-Seitz cell of the reciprocal of the PRIMITIVE lattice, and SC-2010's
// k-points are fractional in the PRIMITIVE reciprocal basis. So for centered
// lattices (fcc, bcc, ...) the conventional cell's reciprocal is the WRONG basis
// (it would draw a cube, not a truncated octahedron). `_primitive-vectors`
// applies the standard centering transform to turn conventional parameters into
// primitive lattice vectors, so `bz-figure(lattice: (a: 3.6), bravais: "cF")`
// yields the truncated octahedron with its k-points landing exactly on the zone
// boundary. Passing three direct vectors instead treats them AS the primitive
// cell (no transform); a materia structure carries only its conventional
// `vectors` and no Bravais symbol, so its k-path cannot be drawn (see below).

#import "@preview/scenery:0.1.0" as scenery
#import "reciprocal.typ": reciprocal-vectors, params-to-vectors
#import "kpath.typ": kpath-data

// --- k-point label pretty-printing ------------------------------------------

// HPKOT/seekpath spells Greek points out in ASCII ("GAMMA", "SIGMA_0"); the
// tables in kpath.typ already use "Γ" for Gamma but keep "SIGMA", "DELTA", ...
// spelled out. Map those to their letters, and render a trailing `_<digits>`
// tag as Unicode subscripts: GAMMA -> Γ, DELTA_0 -> Δ₀, X_1 -> X₁, W_2 -> W₂.
#let _greek = (
  "GAMMA": "Γ", "DELTA": "Δ", "SIGMA": "Σ", "LAMBDA": "Λ", "THETA": "Θ",
  "PI": "Π", "PHI": "Φ", "PSI": "Ψ", "OMEGA": "Ω",
)
#let _subs = (
  "0": "₀", "1": "₁", "2": "₂", "3": "₃", "4": "₄",
  "5": "₅", "6": "₆", "7": "₇", "8": "₈", "9": "₉",
)

/// Pretty-print an HPKOT-style k-point name to a display string.
///
/// The base token is mapped through the Greek table (already-Unicode "Γ" passes
/// through unchanged), and any `_<tail>` suffix is rendered as Unicode
/// subscripts. Pure and total: unknown bases and non-digit tails pass through.
///
/// - name (string): an HPKOT/seekpath point name, e.g. `"GAMMA"`, `"X_1"`.
/// -> string
#let pretty-klabel(name) = {
  let parts = str(name).split("_")
  let base = parts.at(0)
  let mapped = _greek.at(base, default: base)
  let sub = ""
  for t in parts.slice(1) {
    for c in t.clusters() { sub += _subs.at(c, default: c) }
  }
  mapped + sub
}

// --- primitive lattice vectors from conventional parameters -----------------

// Centering transform: conventional (a,b,c,angles) -> primitive lattice vectors
// matching SC-2010's primitive-cell choice per Bravais type, so k-points land on
// the zone boundary. Verified (tests/test-figure.typ) by asserting every path
// point sits on the Brillouin-zone surface for each supported Bravais symbol.
#let _primitive-vectors(bravais, params) = {
  let (a1, a2, a3) = params-to-vectors(params)
  let comb(x, y, z) = scenery.vadd(
    scenery.vadd(scenery.vscale(a1, x), scenery.vscale(a2, y)),
    scenery.vscale(a3, z),
  )
  if bravais in ("cP", "tP", "oP", "mP", "hP", "aP") {
    (a1, a2, a3) // primitive == conventional
  } else if bravais in ("cF", "oF") {
    (comb(0, 0.5, 0.5), comb(0.5, 0, 0.5), comb(0.5, 0.5, 0)) // face-centered
  } else if bravais in ("cI", "tI", "oI") {
    (comb(-0.5, 0.5, 0.5), comb(0.5, -0.5, 0.5), comb(0.5, 0.5, -0.5)) // body-centered
  } else if bravais == "oC" {
    (comb(0.5, -0.5, 0), comb(0.5, 0.5, 0), a3) // C-centered
  } else if bravais == "hR" {
    (comb(1 / 3, -1 / 3, 1 / 3), comb(1 / 3, 2 / 3, 1 / 3), comb(-2 / 3, -1 / 3, 1 / 3)) // rhombohedral
  } else if bravais == "mC" {
    panic("materia: mC (base-centered monoclinic) has no closed-form primitive"
      + " cell here; pass the primitive lattice vectors directly as `lattice`")
  } else {
    panic("materia: unknown Bravais symbol '" + bravais + "'")
  }
}

// --- lattice -> primitive reciprocal basis ----------------------------------

// Is `x` an array of three 3-vectors (direct lattice vectors)?
#let _is-vectors(x) = {
  type(x) == array and x.len() == 3 and x.all(v => type(v) == array and v.len() == 3)
}

// The primitive reciprocal basis (b1,b2,b3) for a lattice argument. `lattice` is
// a materia structure (has a `vectors` field; conventional cell, no centering
// applied), three primitive direct vectors, or a conventional-parameter dict —
// the last needs `bravais` to know the centering.
#let _recip(lattice, bravais) = {
  if type(lattice) == dictionary and "vectors" in lattice {
    reciprocal-vectors(lattice)
  } else if _is-vectors(lattice) {
    reciprocal-vectors(lattice)
  } else if type(lattice) == dictionary {
    if bravais == auto {
      // conventional == primitive only for P lattices; without a Bravais symbol
      // we cannot center, so use the parameters as a primitive cell as-is.
      reciprocal-vectors(lattice)
    } else {
      reciprocal-vectors(_primitive-vectors(bravais, lattice))
    }
  } else {
    panic("materia: `lattice` must be a parameter dict, three direct vectors, "
      + "or a materia structure; got " + repr(type(lattice)))
  }
}

// Parameters for kpath-data: a params dict is used directly; anything else needs
// an explicit `params:` (direct vectors / materia structures carry no a,b,c,..).
#let _params-for-kpath(lattice, params) = {
  if params != auto { params }
  else if type(lattice) == dictionary and "vectors" not in lattice { lattice }
  else {
    panic("materia: drawing a k-path needs cell parameters — pass a parameter "
      + "dict as `lattice`, or give `params: (a: .., ..)` explicitly (direct "
      + "vectors and materia structures carry no a,b,c,angles)")
  }
}

// Cartesian k of a fractional point `f` in the reciprocal basis `b`.
#let _kcart(b, f) = scenery.vadd(
  scenery.vadd(scenery.vscale(b.at(0), f.at(0)), scenery.vscale(b.at(1), f.at(1))),
  scenery.vscale(b.at(2), f.at(2)),
)

// --- scene assembly ---------------------------------------------------------

// Default BZ styling: steel-blue translucent faces with dark navy edges.
#let _bz-fill = rgb("#7aa7d6")
#let _bz-edge = rgb("#1f3b57")
#let _kp-color = rgb("#b5323b") // k-point markers + path (dark red)
#let _hl-color = rgb("#e0a72e") // highlighted points (gold)

// The connected sequence of point NAMES to draw as the path. `path == auto` uses
// the recommended (possibly disjoint) segment list from kpath-data; an explicit
// array of names is read as a connected chain of segments.
#let _path-segments(data, path) = {
  if path == auto { data.path } else {
    range(path.len() - 1).map(i => (path.at(i), path.at(i + 1)))
  }
}

/// Builds a composable scenery scene for a Brillouin zone and optional k-path.
///
/// Takes the same scientific options as `bz-figure`, without output sizing or
/// theme options.
/// -> dictionary
#let bz-scene(
  lattice,
  bravais: auto,
  view: (azimuth: 30deg, elevation: 20deg),
  kpath: true,
  klabels: true,
  highlight: (),
  path: auto,
  params: auto,
) = {
  let b = _recip(lattice, bravais)
  let bz = {
    import "wigner-seitz.typ": bz-cell
    bz-cell(b)
  }
  if bz == none {
    panic("materia: degenerate lattice — the reciprocal vectors are coplanar, "
      + "so no bounded Brillouin zone exists")
  }

  let maxr = calc.max(..bz.vertices.map(v => scenery.vlen(v)))
  let kp-r = 0.045 * maxr
  let hl-r = 0.075 * maxr
  let path-w = 0.02 * maxr
  let lab-off = 0.17 * maxr

  let prims = ()
  prims.push(scenery.mesh(
    bz.vertices, bz.faces,
    color: _bz-fill,
    fill-opacity: 60%,
    stroke: (paint: _bz-edge, thickness: 0.9pt),
  ))

  let has-symbol = bravais != auto
  if highlight.len() > 0 and not has-symbol {
    panic("materia: `highlight:` names high-symmetry points, which are only "
      + "known once `bravais:` is given (so the k-point set is defined)")
  }

  if (kpath or highlight.len() > 0) and has-symbol {
    let ps = _params-for-kpath(lattice, params)
    let data = kpath-data(bravais, ps)
    let norm(h) = if h == "GAMMA" { "Γ" } else { h }
    for h in highlight {
      if norm(h) not in data.points {
        panic("materia: highlight point '" + h + "' is not in the " + bravais
          + " k-point set " + repr(data.points.keys()))
      }
    }
    let hl-set = highlight.map(norm)
    let segs = _path-segments(data, path)
    let names = ()
    for (na, nb) in segs {
      if na not in names { names.push(na) }
      if nb not in names { names.push(nb) }
    }
    if kpath {
      for (na, nb) in segs {
        prims.push(scenery.seg(
          _kcart(b, data.points.at(na)), _kcart(b, data.points.at(nb)),
          color: _kp-color, w: path-w,
        ))
      }
    }
    for nm in names {
      let hot = nm in hl-set
      prims.push(scenery.sphere(
        _kcart(b, data.points.at(nm)),
        if hot { hl-r } else { kp-r },
        color: if hot { _hl-color } else { _kp-color },
      ))
    }
    if klabels {
      // Γ sits at the zone centre; nudge its label AWAY from the cluster of the
      // other points (into empty space) rather than into a neighbour.
      let others = names.filter(nm => scenery.vlen(_kcart(b, data.points.at(nm))) > 1e-9)
      let ctr = if others.len() > 0 {
        scenery.vscale(others.fold((0.0, 0.0, 0.0), (acc, nm) => scenery.vadd(acc, _kcart(b, data.points.at(nm)))), 1 / others.len())
      } else { (0, 0, 1) }
      let cn = scenery.vlen(ctr)
      let gamma-dir = if cn < 1e-9 { (0, 0, 1) } else { scenery.vscale(ctr, -1 / cn) }
      for nm in names {
        let p = _kcart(b, data.points.at(nm))
        let n = scenery.vlen(p)
        let off = if n < 1e-9 { scenery.vscale(gamma-dir, lab-off) } else { scenery.vscale(p, lab-off / n) }
        prims.push(scenery.label(scenery.vadd(p, off), pretty-klabel(nm)))
      }
    }
  }

  scenery.build-scene(..prims)
}

/// The classic Brillouin-zone figure: a translucent BZ polyhedron with visible
/// edges, the recommended high-symmetry k-path drawn on it, and pretty-labelled
/// k-points.
///
/// - lattice (dictionary, array): one of — a conventional-parameter dict (keys
///   `a`, `b`, `c`, `alpha`, `beta`, `gamma`; pair with `bravais` so the correct
///   PRIMITIVE cell and k-points are used), three PRIMITIVE direct lattice
///   vectors, or a materia structure value (its conventional `vectors` are read;
///   no k-path — a structure carries no Bravais symbol).
/// - bravais (auto, string): extended Bravais base symbol (cP, cF, cI, tP, tI,
///   oP, oF, oI, oC, hP, hR, mP, aP). Required to draw a k-path. `mC` is not
///   supported from parameters — pass primitive vectors for it.
/// - view (dictionary): camera orientation `(azimuth:, elevation:)`.
/// - kpath (bool): draw the recommended path and its k-points.
/// - klabels (bool): draw pretty Greek labels at each k-point.
/// - highlight (array): point names to emphasize (larger gold markers); an
///   unknown name is a clear error.
/// - path (auto, array): override the drawn path with a connected sequence of
///   point names, e.g. `("Γ", "X", "W", "K", "Γ", "L")`.
/// - params (auto, dictionary): explicit k-path parameters when `lattice` is not
///   a parameter dict.
/// - width (length): rendered width.
/// - theme (dictionary): a `scenery` theme.
/// -> content
#let bz-figure(
  lattice,
  bravais: auto,
  view: (azimuth: 30deg, elevation: 20deg),
  kpath: true,
  klabels: true,
  highlight: (),
  path: auto,
  params: auto,
  width: 6cm,
  theme: scenery.default-theme,
) = {
  let scene = bz-scene(
    lattice,
    bravais: bravais,
    view: view,
    kpath: kpath,
    klabels: klabels,
    highlight: highlight,
    path: path,
    params: params,
  )
  scenery.render-scene(
    scene,
    scenery.camera(
      azimuth: view.at("azimuth", default: 30deg),
      elevation: view.at("elevation", default: 20deg),
    ),
    width: width,
    theme: theme,
  )
}

// --- band-path axis + panel -------------------------------------------------

/// Sample a connected sequence of high-symmetry k-points into a band-path axis.
///
/// Returns the cumulative distance array along the path (in Å⁻¹), the Cartesian
/// k-points at each sample (so band energies can be evaluated), and the tick
/// positions/labels at each named vertex — the exact shape `band-panel` consumes
/// as its `path-points` argument (the extra `carts` key is ignored there).
///
/// - bravais (string): Bravais base symbol (see `bz-figure`).
/// - params (dictionary): conventional-cell parameters.
/// - points (array): a connected chain of point names, e.g.
///   `("Γ", "X", "W", "K", "Γ", "L")`.
/// - samples (int): sub-intervals per segment.
/// -> dictionary
#let band-axis(bravais, params, points, samples: 24) = {
  let data = kpath-data(bravais, params)
  let b = _recip(params, bravais)
  let norm(h) = if h == "GAMMA" { "Γ" } else { h }
  let seq = points.map(norm)
  for nm in seq {
    if nm not in data.points {
      panic("materia: band-axis point '" + nm + "' is not in the " + bravais
        + " k-point set " + repr(data.points.keys()))
    }
  }
  let cart(nm) = _kcart(b, data.points.at(nm))

  let dists = (0.0,)
  let carts = (cart(seq.first()),)
  let tick-pos = (0.0,)
  let tick-lab = (pretty-klabel(seq.first()),)
  let d = 0.0
  for i in range(seq.len() - 1) {
    let ca = cart(seq.at(i))
    let cb = cart(seq.at(i + 1))
    let seglen = scenery.vlen(scenery.vsub(cb, ca))
    for s in range(1, samples + 1) {
      let t = s / samples
      carts.push(scenery.lerp(ca, cb, t))
      dists.push(d + seglen * t)
    }
    d += seglen
    tick-pos.push(d)
    tick-lab.push(pretty-klabel(seq.at(i + 1)))
  }
  (
    k-dists: dists,
    carts: carts,
    ticks: (positions: tick-pos, labels: tick-lab),
  )
}

/// A flat band-structure panel: dispersion curves against distance along a
/// k-path, with high-symmetry ticks. A modest companion to `bz-figure`, drawn
/// through `scenery`'s 2D mode — for serious plotting use lilaq.
///
/// - bands (array): one array of energies per band, each sampled over the shared
///   `path-points.k-dists`.
/// - path-points (dictionary): `(k-dists: array, ticks: (positions:, labels:))`,
///   e.g. from `band-axis`.
/// - labels (auto, array): tick labels; `auto` uses `path-points.ticks.labels`.
/// - width (length): panel width.
/// - height (length): panel height.
/// - theme (dictionary): a `scenery` theme (band colours use its palette).
/// -> content
#let band-panel(
  bands,
  path-points,
  labels: auto,
  width: 8cm,
  height: 5cm,
  theme: scenery.default-theme,
) = {
  let kd = path-points.k-dists
  let ticks = path-points.ticks
  let tick-labels = if labels == auto { ticks.labels } else { labels }
  assert(bands.len() > 0, message: "materia: band-panel `bands` is empty")
  assert(kd.len() > 1, message: "materia: band-panel needs at least two k-distance samples")

  let kmin = kd.first()
  let kmax = kd.last()
  let all-e = bands.flatten()
  let emin = calc.min(..all-e)
  let emax = calc.max(..all-e)
  let pad = 0.08 * calc.max(emax - emin, 1e-9)
  emin = emin - pad
  emax = emax + pad

  let W = width / 1cm
  let H = height / 1cm
  let xof(k) = (k - kmin) / calc.max(kmax - kmin, 1e-12) * W
  let yof(e) = (e - emin) / calc.max(emax - emin, 1e-12) * H

  let prims = ()
  // Vertical high-symmetry grid lines.
  for p in ticks.positions {
    prims.push(scenery.edge((xof(p), 0), (xof(p), H), color: luma(205), width: 0.6pt))
  }
  // Axis frame (left + bottom, drawn a touch darker).
  prims.push(scenery.edge((0, 0), (W, 0), color: luma(70), width: 1pt))
  prims.push(scenery.edge((0, 0), (0, H), color: luma(70), width: 1pt))
  // Band curves as polyline seg chains.
  for (bi, band) in bands.enumerate() {
    let col = scenery.palette-color(theme, bi)
    for i in range(band.len() - 1) {
      prims.push(scenery.seg(
        (xof(kd.at(i)), yof(band.at(i))),
        (xof(kd.at(i + 1)), yof(band.at(i + 1))),
        color: col, w: 0.03,
      ))
    }
  }
  // Tick labels below the axis.
  for (p, lab) in ticks.positions.zip(tick-labels) {
    prims.push(scenery.label((xof(p), -0.42), lab))
  }
  // Energy-axis caption.
  prims.push(scenery.label((-0.75, H / 2), rotate(-90deg, reflow: true)[Energy]))

  scenery.render-scene(
    scenery.build-scene(..prims),
    scenery.camera-2d(),
    width: width,
    theme: theme,
  )
}
