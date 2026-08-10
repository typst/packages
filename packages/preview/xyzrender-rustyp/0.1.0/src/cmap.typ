// Mirrors upstream src/xyzrender/cmap.py.
//
// Upstream's cmap.py implements:
//   - `build_palette_lut(palette, size)` — RGB LUT from a named palette
//   - `atom_colors(...)` — per-atom Color list for `--cmap` property
//     colouring
//   - `colorbar_extra_width` / `colorbar_svg` — vertical legend SVG
//
// All three drive the `--cmap` / `cbar` feature (RenderConfig.atom_cmap,
// cmap_range, cmap_palette, cbar). That feature is out of scope for v1
// (PLAN.md:23-29) — the named palettes themselves live in upstream
// colors.py:PALETTES and are likewise unported. The `cmap_unlabeled`
// key still appears in presets/default.json as a passthrough config
// value, but the renderer never reads it in v1.
//
// File kept for 1:1 parity with upstream src/xyzrender/.
