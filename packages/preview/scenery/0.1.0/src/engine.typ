// WASM accelerator bridge (issue #32): serializes prepared primitives + camera
// to CBOR, calls scenery-engine's sort_scene, and reassembles the returned
// draw-ordered records onto the original styled primitives by index.
// The engine is bytes-in/bytes-out and host-agnostic: all styling stays here.
#import "style.typ": default-theme, resolve-style

#let _engine = plugin("../plugin/scenery_engine.wasm")

/// Plugin version string (smoke check that the binary loads).
#let engine-version() = str(_engine.version())

#let _ser-pt(p) = p.map(float)

// The camera crosses the boundary as PRECOMPUTED trig coefficients so the
// engine performs only exactly-rounded arithmetic (+ - * / sqrt): sin/cos are
// libm-dependent and would break bit-identical depth keys across platforms.
#let _ser-camera(cam) = if cam.mode == "2d" { (mode: "2d") } else {
  (
    mode: cam.mode,
    cos-az: calc.cos(cam.azimuth), sin-az: calc.sin(cam.azimuth),
    cos-el: calc.cos(cam.elevation), sin-el: calc.sin(cam.elevation),
    ..if cam.mode == "perspective" { (distance: float(cam.distance)) } else { (:) },
  )
}

#let _ser-prim(p, theme) = {
  let k = p.kind
  if k == "sphere" { (k: k, c: _ser-pt(p.center), r: float(p.r)) }
  else if k == "seg" {
    (k: k, a: _ser-pt(p.a), b: _ser-pt(p.b), w: float(resolve-style(theme, p).w))
  } else if k == "edge" { (k: k, a: _ser-pt(p.a), b: _ser-pt(p.b)) }
  else if k == "arrow" { (k: k, a: _ser-pt(p.from), b: _ser-pt(p.to)) }
  else if k == "face" {
    (k: k, pts: p.pts.map(_ser-pt),
     opaque: resolve-style(theme, p).at("fill-opacity", default: 0%) == 0%)
  } else if k == "label" { (k: k, p: _ser-pt(p.at)) }
  else { panic("scenery engine: unsupported primitive kind: " + k) }
}

/// Depth-orders `prepared` primitives through the scenery-engine WASM plugin.
/// `prepared` MUST be `_prepare-faces` output (meshes exploded, face culling
/// applied, rear-face tags in place). Returns the same primitives — possibly
/// split into fragments — each with a `depth` key, in back-to-front draw order.
#let engine-sort(prepared, camera, theme: default-theme, bsp: true, cull: none) = {
  let req = cbor.encode((
    camera: _ser-camera(camera),
    bsp: bsp,
    cull: cull,
    prims: prepared.map(p => _ser-prim(p, theme)),
    depth-keys: prepared.map(p => p.at("depth-key", default: "center")),
  ))
  let out = cbor(_engine.sort_scene(req))
  out.map(rec => {
    let p = prepared.at(rec.i)
    if "pts" in rec { p.insert("pts", rec.pts) }
    if "a" in rec {
      if p.kind == "arrow" { p.insert("from", rec.a); p.insert("to", rec.b) }
      else { p.insert("a", rec.a); p.insert("b", rec.b) }
    }
    if "head" in rec { p.insert("draw-head", rec.head) }
    (..p, depth: rec.d)
  })
}
