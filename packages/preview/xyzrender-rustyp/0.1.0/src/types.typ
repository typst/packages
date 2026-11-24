// Mirrors upstream src/xyzrender/types.py.
//
// Upstream `types.py` defines `RenderConfig` (a dataclass with every
// render knob and its default value), plus auxiliary types for
// features that are out of scope for v1 (OverlayConfig, StyleRegion,
// VectorArrow, CellData, MO/Dens/ESP/NCI Params, HighlightGroup,
// BondStyle enum, SVGResult, GIFResult).
//
// In Typst there is no static type system, so `RenderConfig` is
// represented as the `defaults` dict below. The field names and
// values are ported verbatim from upstream's RenderConfig dataclass.
//
// IMPORTANT: every default here comes from upstream xyzrender's
// RenderConfig. Don't tune these locally; if upstream changes,
// update here and bump SYNC.md.

#let defaults = (
  // canvas
  canvas_size: 800,
  // Port divergence (user preference): upstream RenderConfig default is
  // 20.0; halved here for a tighter default crop alongside `tight_fit`.
  padding: 10.0,
  background: "#ffffff",
  // Upstream RenderConfig.auto_orient (types.py:303). The dataclass
  // default is `False`, but upstream's CLI build path explicitly sets
  // it to `True` (config.py:400), so every CLI render is PCA-oriented
  // unless the user passes `--no-orient`. We mirror the CLI default
  // here so `#xyzrender(...)` matches what `xyzrender file.xyz`
  // produces from the same input. PCA picks the molecule's longest
  // axis as horizontal x, next as y, smallest as z (depth) —
  // different input frames render at the same on-page geometry.
  auto_orient: true,
  // Upstream RenderConfig.fixed_span (types.py:310). When set, locks
  // `_fit_canvas` to a constant per-Å scale and a square canvas of
  // `canvas_size × canvas_size`. Different molecules render at the same
  // physical atom size — pick a value bigger than every molecule's
  // bounding span. `none` (default) lets each render auto-fit.
  fixed_span: none,
  // Port-only (no upstream equivalent — upstream renders one molecule
  // per CLI call, so cross-molecule scale never comes up). Controls
  // whether a render uses a *fixed* per-Å scale (so atoms/bonds are the
  // same physical size across different molecules) or auto-fits its own
  // bounding box to fill the canvas (the historic behaviour, where every
  // molecule's long axis fills `canvas_size` → small molecules render
  // with oversized atoms next to large ones).
  //   auto  (default) — use the fixed scale ONLY when the caller left
  //                     both `width` and `height` unspecified; if a size
  //                     is given, auto-fit to fill it as before.
  //   true            — always use the fixed scale.
  //   false           — always auto-fit (original behaviour).
  // The fixed scale is `(canvas_size - 2*padding) / _REF_SPAN` — i.e. a
  // molecule ≈ `_REF_SPAN` Å wide fills `canvas_size` on its long axis
  // (same as auto-fit for that size), and every other molecule shares
  // that scale. `canvas_size` therefore stays the zoom control: bigger
  // `canvas_size` → bigger atoms/canvas. It must anchor to `canvas_size`
  // (NOT the constant `_REF_CANVAS` via `ref-scale`), otherwise
  // `canvas_size` silently stops affecting width-auto renders.
  // `fixed_span` still wins when set (square GIF-mode canvas).
  consistent_scale: auto,
  // Port-only (no upstream equivalent). Upstream `_fit_canvas` pads the
  // bounding box of atom *centers* by the single largest fitted radius
  // on all four sides, so any side whose outermost atoms are small
  // carries blank slack (with vdW overlays this can waste ~40% of the
  // canvas area). `true` (default) fits per-atom extents instead —
  // `min/max(center ± fit_radius)` per axis — so the canvas is tight to
  // the ink and only the `padding` config remains around the molecule.
  // `false` restores the upstream-verbatim fit (use for fixture
  // comparisons against upstream renders).
  tight_fit: true,
  // atoms
  atom_scale: 1.0,
  vdw_scale: 1.0,
  h_scale: 0.6,
  atom_stroke_width: 1.5,
  atom_stroke_color: "#000000",
  atom_wash: 0.0,  // blend atom fill toward white (0=none, 0.78=graph-style)
  // Interlocked silhouettes for primary atom spheres (used by the
  // `vdw` preset). When false, atom discs always emit as <circle>.
  // `vdw_interlock_samples` is the perimeter samples per sphere
  // (upstream RenderConfig defaults).
  atom_interlocking: false,
  vdw_interlock_samples: 64,
  // bonds
  bond_width: 5.0,
  bond_color: "#333333",
  bond_orders: true,
  // Manual bond add/remove. Both accept arrays of pair-spec strings
  // like ("1-3", "4-5"), or a bare string for one pair ("1-3"). `unbond`
  // drops covalent bonds; `bond` adds them. Mirrors upstream
  // RenderConfig.bond / .unbond (types.py:281-282), generalized with
  // this project's `index_base` knob (default 1, matching upstream's
  // bond_rules.py `_parse_index_pair` regex; set `index_base: 0` for
  // raw 0-indexed specs) — every index-accepting keyword in this port
  // (vdw_indices, hy, bond, unbond, ts_bonds, nci_bonds,
  // style_regions.indices, region_specs) shares this one knob. Selector-
  // grammar specs (M, L, hal, pi, …) are not in scope for v1; only index
  // pairs are accepted.
  bond: (),
  unbond: (),
  // TS / NCI bond overlays. Each entry is either a 2-element int pair
  // (e.g. (1, 3)) or a "1-4" string spec (including the bare-string
  // one-pair convenience) — both subject to `index_base`, same as
  // `bond`/`unbond` above. Mirrors upstream RenderConfig.ts_bonds /
  // .nci_bonds (types.py:288-289). The renderer styles ts_bonds with the
  // DASHED stroke (ts_dash / ts_width / ts_color) and nci_bonds with the
  // DOTTED stroke (nci_dash / nci_width / nci_color). Pairs that already
  // exist in the structural bond list are restyled in place; pairs that
  // don't are added as new edges (matches renderer.py:430-433).
  ts_bonds: (),
  nci_bonds: (),
  // TS / NCI bond styling (upstream RenderConfig — types.py:259-266).
  //   *_color    — flat stroke; `none` falls back to base bond_color.
  //   *_element  — split each dash/dot into atom-coloured halves; only
  //                takes effect when bond_color_by_element is on AND
  //                *_color is none (matches renderer.py:1247-1248).
  //   *_dash     — (length, gap) pair; both are bond_width multipliers
  //                applied as stroke-dasharray.
  //   *_width    — bond_width multiplier for the dashed/dotted stroke.
  // Upstream ts_dash default is (1.2, 2.2); the tube / btube / mtube
  // presets override it to (0.5, 3) (presets/*.json).
  ts_color: none,
  ts_element: false,
  ts_dash: (1.2, 2.2),
  ts_width: 1.2,
  nci_color: none,
  nci_element: false,
  nci_dash: (0.08, 2.0),
  nci_width: 1.0,
  // When false (default), aromatic bonds render as the upstream
  // solid-outer / dashed-inner pair (renderer.py:1345-1376). When true,
  // the plugin keeps alternating 1/2 Kekulé orders in aromatic rings
  // and the renderer draws them like ordinary single/double bonds.
  kekule: false,
  bond_color_by_element: false,
  bond_outline_color: "#000000",
  bond_outline_width: 0.0,
  bond_gradient: false,
  bond_gradient_strength: 1.0,
  bond_gap: 0.6,  // multi-bond spacing as fraction of bond_width
  // gradient / shading
  // NOTE: upstream RenderConfig.gradient = False; the canonical xyzrender
  // renders typically pass --gradient on the CLI. We deviate per project
  // preference — atoms get sphere shading by default unless a preset or
  // call site explicitly sets gradient: false.
  gradient: true,
  atom_gradient_strength: 1.0,
  hue_shift_factor: 0.2,
  light_shift_factor: 0.2,
  saturation_shift_factor: 0.2,
  // fog
  // NOTE: deviations from upstream RenderConfig (fog=False,
  // fog_strength=0.8). Per project preference:
  //   - fog defaults true (upstream only sets it in default.json).
  //   - fog_strength defaults 1.2 (matches default.json's explicit
  //     value, which the user has confirmed is the canonical look).
  // Per-preset fog_strength still wins (paton uses 1, etc.).
  fog: true,
  fog_strength: 1.2,
  // Fog target colour (upstream RenderConfig.fog_color, v0.3.3). `none`
  // = derive from background (which defaults transparent → white).
  fog_color: none,
  // labels / atom indices (upstream RenderConfig.show_indices, idx_format,
  // label_font_size, label_color, label_offset — types.py:324-328).
  show_indices: false,
  idx_format: "sn",  // "sn" (C1) | "s" (C) | "n" (1) — 1-indexed numbers
  label_font_size: 11.0,
  label_color: "#222222",
  label_offset: 0.5,
  // Index base for every user-supplied atom index or pair spec in this
  // port: vdw_indices, hy, bond, unbond, ts_bonds, nci_bonds,
  // style_regions.indices, and region_specs' numeric-range keys. Default
  // 1 mirrors upstream's user-facing CLI (selectors.py
  // `resolve_atom_indices` treats spec strings as 1-indexed). Upstream's
  // *internal* index lists (e.g. `cfg.vdw_indices: list[int]`) are
  // 0-indexed; the port unifies all of these under one user-visible,
  // document-wide knob — bind `xyzrender.with(index_base: 0)` once to
  // switch every index in a document to raw 0-indexed integers /
  // unshifted ranges instead.
  index_base: 1,
  // VDW overlay (upstream RenderConfig.vdw_* — types.py:290-302).
  // `vdw_indices = ()` is the "render every atom" sentinel; `none` means
  // "no overlay". Accepts either an integer array (subject to
  // `index_base`) or a selector string like `"31-38"` / `"1,4-7,M"`
  // (routed through `resolve-atom-indices`, also subject to
  // `index_base`).
  vdw_indices: none,
  vdw_opacity: 0.5,
  vdw_gradient_strength: 1.6,
  vdw_outline_width: none,  // None = inherit atom_stroke_width; 0 = no outline
  vdw_outline_color: none,  // None = inherit atom_stroke_color
  vdw_h_scale: 0.7,
  vdw_interlocking: false,
  // Hydrogen visibility (upstream RenderConfig.hide_h, show_h_indices,
  // auto_hide_h — types.py:284-286). Driven by the `hy` API kwarg via
  // `apply-hydrogen-flags` in api.typ (mirrors upstream
  // config.py:246-263).
  //   hide_h=false              -> render every H
  //   hide_h=true               -> hide every H except show_h_indices
  //   show_h_indices=(0, 2, 5)  -> 0-indexed atoms to keep visible
  //   auto_hide_h=true          -> when the user doesn't pass `hy`,
  //                                hide C-H hydrogens automatically
  //                                (matches upstream's CLI default)
  hide_h: false,
  show_h_indices: (),
  auto_hide_h: true,
  // Bond visibility (upstream RenderConfig.hide_bonds — types.py). When
  // true, upstream skips the entire bond dict incl. TS/NCI overrides and
  // aromatic-ring computation (renderer.py:413,487), drawing atoms only.
  // Used by the `bubble` and `vdw` presets.
  hide_bonds: false,
  // Draw-order flag (upstream RenderConfig.atoms_above_bonds — types.py:253).
  // When true, each atom's disc+label is deferred and drawn AFTER all bonds
  // (still in z-order among themselves), so atoms sit cleanly on top for a
  // diagram look instead of depth-interleaving with bonds (renderer.py:1671).
  // Used by the `graph` preset.
  atoms_above_bonds: false,
  // Style regions (upstream RenderConfig.style_regions / region_specs —
  // types.py:425-427). `style_regions` is the resolved form: a list of
  // (indices: (...), config: (...)) tuples — `indices` accepts either
  // an int array (`(1, 2, 3)`) or a selector string (`"1-3"`, `"het"`,
  // …), same string-or-array convention as `vdw_indices`; both forms
  // are subject to `index_base` (api.typ shifts/resolves these to raw
  // 0-based before the renderer sees them). `region_specs` is the
  // selector-keyed form: ("M": "flat", "L": (atom_scale: 4.0)), whose
  // numeric-range keys are equally subject to `index_base` — api.typ
  // resolves it into `style_regions` after bond perception.
  style_regions: (),
  region_specs: none,
  // colours (user overrides keyed by element symbol)
  colors: (:),
)
