// Mirrors upstream src/xyzrender/interlock.py.
//
// VDW interlocking-spheres silhouette using the cinemol approach
// (David Meijer, github.com/moltools/cinemol). The actual math
// (perimeter sampling, pairwise sphere intersection, visibility
// clipping, 2D convex hull) lives in the WASM plugin under
// `plugin/src/interlock.rs` — Typst's interpreter is slow on the
// numerical hot loop, and the upstream relies on NumPy for the same
// reason. This module is the Typst-side wrapper that packs inputs
// as CBOR, calls the plugin, and unpacks the result back into the
// (x, y) tuple shape that `renderer.typ` consumes.
//
// The Rust port (plugin/src/interlock.rs) is the byte-for-byte
// translation of upstream `interlock.py` — line numbers there refer
// back to the Python source. Visual output is identical to the
// previous pure-Typst implementation; only performance changes.

// Upstream interlock.py:66 signature:
//
//   compute_interlock_polygons(
//       centers_3d: np.ndarray,
//       radii_3d:   np.ndarray,
//       *,
//       samples: int = 64,
//       min_clip_fraction: float = 0.03,
//   ) -> list[np.ndarray | None]
//
// Inputs:
//   centers-3d: list of (x, y, z) tuples (post-rotation Angstroms).
//               The z component is preserved through the plugin and
//               used by the 3D visibility test exactly as in
//               interlock.py:131-134.
//   radii-3d:   list of floats (Angstroms).
//   samples:    perimeter samples per sphere (default 64).
//   min-clip-fraction: skip atoms whose clipped perimeter fraction
//                      is below this — they round-trip to a plain
//                      circle anyway. Default 0.03, matching
//                      interlock.py:71.
//
// Returns a list of length n; each entry is either `none` (atom
// emits as a plain circle) or a list of (x, y) tuples forming the
// silhouette polygon in counter-clockwise order.
#let compute-interlock-polygons(
  centers-3d,
  radii-3d,
  samples: 64,
  min-clip-fraction: 0.03,
) = {
  let n = centers-3d.len()
  if n == 0 { return () }

  // Coerce inputs to CBOR-friendly numeric types. Centers may arrive
  // as 3-tuples or 3-element arrays — both index the same in Typst.
  let centers-arr = centers-3d.map(c => (
    float(c.at(0)),
    float(c.at(1)),
    float(c.at(2)),
  ))
  let radii-arr = radii-3d.map(r => float(r))

  let input = (
    centers: centers-arr,
    radii: radii-arr,
    samples: int(samples),
    min_clip_fraction: float(min-clip-fraction),
  )
  let p = plugin("assets/xyzrender.wasm")
  let raw = p.compute_interlock(cbor.encode(input))
  let polys = cbor(raw)

  // Plugin returns CBOR `null` for atoms with no polygon; Typst
  // surfaces these as `none`. Polygons come back as arrays of
  // 2-element arrays; pass them through unchanged (`renderer.typ`
  // accepts `.at(0)` / `.at(1)` access either way).
  polys.map(p => if p == none { none } else { p })
}
