// Crystal-figure builder on top of the scenery core (issue #8).
//
// Replaces the former package-private engine (`linalg.typ`, `project.typ`,
// `scene.typ`, `render.typ`): geometry is turned into scenery *primitives*
// (`sphere`/`seg`/`face`/`edge`/`label`) carrying per-atom colours and strokes
// as style hooks, and drawn through scenery's `scene-group`. Two material-figure
// specifics are reproduced here rather than in the core:
//   * the coverage-suppression heuristic (`occlude`), re-implemented as a pure
//     screen-space pre-filter with the SAME slacks (`2*r`, `0.45*w`) the old
//     `render.typ` used (controller ruling, issue #8);
//   * legend/axes furniture, drawn via scenery's `legend`/`axes-triad` with
//     origins derived from the crystal scene's screen-space bbox.

#import "@preview/scenery:0.1.0" as scenery
#import "@preview/cetz:0.5.2"
#import "../core/data.typ": element-info
#import "geometry.typ": display-atoms, cell-edges, find-bonds, find-polyhedra
#import "../io.typ": _io

// The verbatim `occlude` slacks (see below), forwarded to the engine's cull
// mirror as NUMBERS on the `engine: "wasm"` path so the wasm output matches the
// pure path's coverage suppression exactly (issue #32). Kept in sync with the
// `2 * sp.r` / `sp.depth + sp.r` / `0.45 * b.w` / `b.depth + 1.0` constants in
// `occlude`.
#let _materia-cull = (seg-r-slack: 2.0, point-r-slack: 1.0, seg-w-frac: 0.45, seg-d-slack: 1.0)

/// Build a pure-data scene of scenery primitives (3D, unprojected) plus the
/// screen-space bbox and element list the crystal renderer needs. Primitives are
/// UNFILTERED here (coverage suppression happens at render time via `occlude`),
/// matching the old `scene.typ` contract that `tests/test-scene.typ` pins.
#let crystal-scene(
  structure,
  view: (azimuth: 25deg, elevation: 15deg),
  supercell: (1, 1, 1),
  mode: "ball-and-stick",  // | "space-filling"/"cpk" | "licorice"
  bonds: auto,          // auto | none | rules array
  bond-color: auto,     // auto = two-tone split halves | a color = one seg per bond
  polyhedra: (),        // element list
  radius: auto,         // per-mode default: 0.45 (b&s), 1.0 (cpk), 0.55 (licorice)
  bond-width: auto,     // per-mode default: 0.25 (licorice), 0.16 otherwise
  labels: false,
  colors: (:),
  engine: "typst",
) = {
  assert(mode in ("ball-and-stick", "space-filling", "cpk", "licorice"),
    message: "materia: mode must be \"ball-and-stick\", \"space-filling\" (alias \"cpk\") or \"licorice\", got " + repr(mode))
  let mode = if mode == "cpk" { "space-filling" } else { mode }
  assert(mode != "space-filling" or polyhedra.len() == 0,
    message: "materia: space-filling mode draws no polyhedra; drop the polyhedra: option")
  assert(bond-color == auto or type(bond-color) == color,
    message: "materia: bond-color must be auto or a color, got " + repr(bond-color))
  let bond-width = if bond-width == auto {
    if mode == "licorice" { 0.25 } else { 0.16 }
  } else { bond-width }
  let radius = if radius == auto {
    if mode == "space-filling" { 1.0 } else if mode == "licorice" { 0.55 } else { 0.45 }
  } else { radius }

  let az = view.at("azimuth", default: 25deg)
  let elev = view.at("elevation", default: 15deg)
  let cam = scenery.camera(
    azimuth: az, elevation: elev,
    mode: view.at("mode", default: "orthographic"),
    distance: view.at("distance", default: 25.0),
  )

  // Depth-only offset: the old renderer pushed polyhedra faces back by 0.01 in
  // depth (`cdepth - 0.01`). The camera-forward direction changes ONLY depth
  // (screen x/y are invariant), so offsetting face vertices along it by -0.01
  // reproduces the old depth key exactly while leaving projected geometry — and
  // hence the screen bbox and every drawn pixel — untouched.
  // (Exact for orthographic; under perspective the 0.01 depth push shifts
  // screen x/y by ~0.01/distance — visually negligible.)
  let gdepth = (-calc.sin(az) * calc.cos(elev), calc.cos(az) * calc.cos(elev), calc.sin(elev))
  let face-offset = scenery.vscale(gdepth, -0.01)

  let shown = display-atoms(structure, supercell: supercell)
  let prims = ()
  // Displayed sphere radius per mode. Ball-and-stick is today's exact formula;
  // space-filling uses the full van der Waals radius (CPK); licorice caps are
  // element-independent, slightly wider (0.55) than the stick's half-width
  // (0.50 x bond-width) so the round cap joint is seamlessly covered.
  let rdisp(el) = if mode == "space-filling" { radius * element-info(el).r-vdw }
    else if mode == "licorice" { radius * bond-width }
    else { radius * element-info(el).r-atom }
  let color-of(el) = colors.at(el, default: element-info(el).color)

  // Spheres, then labels, then bond segs, then polyhedra faces, then cell edges:
  // this push order is the stable-sort tie-break the old renderer relied on.
  // Each atom sphere is NAMED (by display index) so bond segs can reference it
  // through scenery's connection abstraction (surface auto-attach, see below).
  for (idx, a) in shown.enumerate() {
    prims.push(scenery.sphere(a.cart, rdisp(a.element),
      color: color-of(a.element), element: a.element, name: "atom-" + str(idx)))
  }
  if labels {
    for a in shown {
      prims.push(scenery.label(a.cart, a.element))
    }
  }

  // Space-filling shows the raw packing: skip the bond search entirely.
  // In auto mode, a molecule may carry parser-precomputed bonds (same rule as
  // find-bonds, but O(N) in Rust): use them verbatim. `display-atoms` emits a
  // molecule's atoms in order with no supercell images, so the indices line up.
  // A user-supplied `bonds:` rules array still overrides via find-bonds.
  // The engine="wasm" path detects auto bonds through the materia-io accelerator
  // (`detect_bonds`, O(N) in Rust) instead of Typst `find-bonds`; the two use the
  // SAME rule and radii, so the resulting bond set — and hence the whole scene —
  // is identical (pinned by tests/test-bonds.typ). Precomputed bonds and a
  // user-supplied rules array still take their existing branches.
  let pre = structure.at("bonds", default: none)
  let blist = if mode == "space-filling" or bonds == none { () }
    else if bonds == auto and pre != none { pre.map(b => (i: b.at(0), j: b.at(1))) }
    else if bonds == auto and engine == "wasm" {
      json(_io.detect_bonds(bytes(json.encode(
        shown.map(a => (element: a.element, cart: a.cart))))))
        .map(b => (i: b.at(0), j: b.at(1)))
    }
    else { find-bonds(shown, bonds) }
  for b in blist {
    let (pa, pb) = (shown.at(b.i), shown.at(b.j))
    // Bond endpoints go through scenery's connection abstraction: an endpoint
    // that references a NAMED sphere is auto-attached to the sphere SURFACE
    // (`center + r * normalize(other - center)`) by `resolve-scene` below, so
    // bonds emerge exactly at the atom surface — no hand-rolled trim.
    // Licorice is the intentional exception: its sticks run atom-center to
    // atom-center (concrete endpoints) because the caps have the same radius
    // as the stick, so the round cap hides the joint.
    let (ea, eb) = if mode == "licorice" { (pa.cart, pb.cart) }
      else { ("atom-" + str(b.i), "atom-" + str(b.j)) }
    if bond-color == auto {
      // Two-tone bond: mark the full-length seg with its two atom colours; it
      // is split into per-atom halves AFTER resolution, at the midpoint of the
      // attached (surface) endpoints.
      prims.push(scenery.seg(ea, eb, w: bond-width, materia-two-tone: (
        color-of(pa.element).darken(10%), color-of(pb.element).darken(10%))))
    } else {
      // Single-color opt-out: one seg per bond, verbatim color.
      prims.push(scenery.seg(ea, eb, color: bond-color, w: bond-width))
    }
  }

  if polyhedra.len() > 0 {
    for poly in find-polyhedra(shown, blist, polyhedra) {
      let col = color-of(shown.at(poly.center).element)
      for f in poly.faces {
        // shade: false — the old renderer never lit faces (flat translucent fill).
        // depth-key: "back" anchors the face at its farthest vertex. Combined
        // with face-offset above, each corresponding ligand sphere is strictly
        // nearer and paints after the face instead of being cut by a
        // centroid-sorted triangular wedge.
        prims.push(scenery.face(f.map(p => scenery.vadd(p, face-offset)),
          color: col, shade: false, depth-key: "back"))
      }
    }
  }

  if structure.at("kind", default: "") != "molecule" {
    for (ea, eb) in cell-edges(structure, supercell: supercell) {
      for t in range(8) {
        let p = scenery.lerp(ea, eb, t / 8)
        let q = scenery.lerp(ea, eb, (t + 1) / 8)
        prims.push(scenery.edge(p, q, color: luma(120), width: 0.7pt))
      }
    }
  }

  // Resolve named references NOW: `resolve-scene` attaches every anchor-ref
  // bond endpoint to its atom sphere's surface, yielding concrete coordinates
  // for the bbox below and the `occlude` pre-filter (both need real points;
  // `scene-group` re-resolves later, a no-op on concrete prims). Then split
  // each marked two-tone bond into per-atom halves at the midpoint of the
  // ATTACHED endpoints.
  let resolved = scenery.resolve-scene(scenery.build-scene(..prims), cam).prims
  prims = ()
  for p in resolved {
    if p.kind == "seg" and "materia-two-tone" in p {
      let mid = scenery.lerp(p.a, p.b, 0.5)
      let (ca, cb) = p.materia-two-tone
      prims.push(scenery.seg(p.a, mid, color: ca, w: p.w))
      prims.push(scenery.seg(mid, p.b, color: cb, w: p.w))
    } else {
      prims.push(p)
    }
  }

  // Screen-space bbox: projected extents, including each
  // sphere's radius added in screen space (NOT scenery's 3D-AABB projection).
  let xs = ()
  let ys = ()
  for p in prims {
    if p.kind == "sphere" {
      let s = scenery.project(cam, p.center)
      // Screen radius: world radius times the camera's depth magnification
      // (exactly 1.0 for orthographic).
      let rs = p.r * scenery.project-scale(cam, s.depth)
      xs += (s.sx - rs, s.sx + rs)
      ys += (s.sy - rs, s.sy + rs)
    } else if p.kind == "face" {
      for q in p.pts {
        let s = scenery.project(cam, q)
        xs.push(s.sx); ys.push(s.sy)
      }
    } else if p.kind == "label" {
      // sits on a sphere center: already inside that sphere's bbox
    } else {
      let sa = scenery.project(cam, p.a)
      let sb = scenery.project(cam, p.b)
      xs += (sa.sx, sb.sx); ys += (sa.sy, sb.sy)
    }
  }

  let elements = ()
  for a in shown {
    if a.element not in elements { elements.push(a.element) }
  }
  let base = scenery.build-scene(..prims)
  (
    ..base,
    screen-bbox: (calc.min(..xs), calc.min(..ys), calc.max(..xs), calc.max(..ys)),
    elements: elements,
    element-colors: elements.map(color-of),
    camera: cam,
  )
}

// --- coverage suppression (screen-space pre-filter) -------------------------

/// Screen `(sx, sy)` of a 3D point under `cam`.
#let _proj2(cam, p) = { let q = scenery.project(cam, p); (q.sx, q.sy) }

/// Camera depth of a 3D point under `cam`.
#let _pdepth(cam, p) = scenery.project(cam, p).depth

/// Midpoint of two points.
#let _mid(a, b) = scenery.lerp(a, b, 0.5)

/// Squared distance from screen point `q` to segment `a`-`b` (all 2D).
#let _dist2-point-seg(q, a, b) = {
  let (qx, qy) = (q.at(0), q.at(1))
  let (ax, ay) = (a.at(0), a.at(1))
  let (bx, by) = (b.at(0), b.at(1))
  let (ux, uy) = (bx - ax, by - ay)
  let len2 = ux * ux + uy * uy
  let t = if len2 == 0 { 0.0 } else {
    calc.min(1.0, calc.max(0.0, ((qx - ax) * ux + (qy - ay) * uy) / len2))
  }
  let (dx, dy) = (qx - (ax + t * ux), qy - (ay + t * uy))
  dx * dx + dy * dy
}

/// Whether screen point `q` lies inside the disk of center `c`, radius `r`.
#let _in-disk(q, c, r) = {
  let (dx, dy) = (q.at(0) - c.at(0), q.at(1) - c.at(1))
  dx * dx + dy * dy < r * r
}

/// Drops the bond segs / cell edges the old renderer would have hidden under
/// sphere coverage, then returns the surviving primitives in their original
/// order (so the stable depth-sort tie-break is preserved).
///
/// Ports `render.typ`'s `seg-hidden`/`edge-hidden` verbatim into screen space,
/// with the SAME slacks (`2*r`, `0.45*w`). All spheres and all (unfiltered) segs
/// participate in the coverage test, exactly as the old draw loop did.
#let occlude(prims, cam) = {
  let spheres = prims.filter(p => p.kind == "sphere").map(p => {
    let q = scenery.project(cam, p.center)
    // Disk radius in screen units (depth-scaled; x1.0 under orthographic).
    (c: (q.sx, q.sy), r: p.r * scenery.project-scale(cam, q.depth), depth: q.depth)
  })
  let segs = prims.filter(p => p.kind == "seg").map(p => {
    let d = _pdepth(cam, _mid(p.a, p.b))
    (a: _proj2(cam, p.a), b: _proj2(cam, p.b),
     w: p.w * scenery.project-scale(cam, d), depth: d)
  })
  // A bond stub is hidden when it projects fully inside a sphere's disk and is
  // not clearly in front of that sphere (2r slack).
  let seg-hidden(sa, sb, sd) = spheres.any(sp =>
    _in-disk(sa, sp.c, sp.r) and _in-disk(sb, sp.c, sp.r) and sd < sp.depth + 2 * sp.r)
  // A point is covered when a sphere disk or a bond stroke sits over it and is
  // not clearly behind it.
  let covered(q, ed) = spheres.any(sp =>
    _in-disk(q, sp.c, sp.r) and ed < sp.depth + sp.r
  ) or segs.any(b =>
    _dist2-point-seg(q, b.a, b.b) < calc.pow(0.45 * b.w, 2) and ed < b.depth + 1.0)

  prims.filter(p => {
    if p.kind == "seg" {
      let sd = _pdepth(cam, _mid(p.a, p.b))
      not seg-hidden(_proj2(cam, p.a), _proj2(cam, p.b), sd)
    } else if p.kind == "edge" {
      let ed = _pdepth(cam, _mid(p.a, p.b))
      not (covered(_proj2(cam, p.a), ed) and covered(_proj2(cam, p.b), ed))
    } else { true }
  })
}

// --- rendering --------------------------------------------------------------

/// Raw cetz draw commands for `scene` at canvas scale `scale` (for composition
/// inside a user `cetz.canvas`). Suppression is applied first; drawing goes
/// through scenery's `scene-group`.
#let draw-scene(scene, scale: 1.0, engine: "typst") = {
  // engine="wasm": hand ALL prims to the accelerator, which mirrors `occlude` via
  // its cull stage (policy passed as `_materia-cull` numbers); engine="typst": run the
  // pure-Typst `occlude` pre-filter here. Both drive scenery's `scene-group`.
  let prims = if engine == "wasm" { scene.prims } else { occlude(scene.prims, scene.camera) }
  scenery.scene-group(scenery.build-scene(..prims), scene.camera, unit: scale,
    engine: engine, engine-cull: if engine == "wasm" { _materia-cull } else { none })
}

/// Render a scene to content: a cetz canvas scaled so the scene's (screen-space)
/// bbox width equals `width`. `legend: true` adds element swatch rows to the
/// right; `axes-info: (vectors, view, n-axes?)` adds an a/b/c triad bottom-left.
/// Placement uses the crystal scene's screen bbox, not scenery's
/// 3D-AABB projection), so output is pixel-identical.
#let render(scene, width: 8cm, legend: true, axes-info: none, engine: "typst") = {
  let (x0, y0, x1, y1) = scene.screen-bbox
  let s = (width / 1cm) / (x1 - x0)
  let cam = scene.camera
  // See draw-scene: wasm mirrors `occlude` in the engine cull stage; typst runs
  // the pure pre-filter. The engine args equal scene-group's defaults on the
  // typst path, so the default output is byte-identical.
  let prims = if engine == "wasm" { scene.prims } else { occlude(scene.prims, cam) }
  let sub = scenery.build-scene(..prims)
  cetz.canvas(length: 1cm, {
    scenery.scene-group(sub, cam, unit: s,
      engine: engine, engine-cull: if engine == "wasm" { _materia-cull } else { none })
    if legend {
      let legend-colors = scene.at(
        "element-colors",
        default: scene.elements.map(el => element-info(el).color),
      )
      scenery.legend(
        scene.elements.zip(legend-colors),
        origin: (x1 * s + 0.7, y1 * s),
        gap: 0.14,
      )
    }
    if axes-info != none {
      let acam = scenery.camera(
        azimuth: axes-info.view.at("azimuth", default: 25deg),
        elevation: axes-info.view.at("elevation", default: 15deg),
      )
      let naxes = axes-info.at("n-axes", default: 3)
      scenery.axes-triad(
        acam,
        axes-info.vectors.slice(0, naxes),
        names: ("a", "b", "c").slice(0, naxes),
        origin: (x0 * s - 0.5, y0 * s - 0.5),
      )
    }
  })
}
