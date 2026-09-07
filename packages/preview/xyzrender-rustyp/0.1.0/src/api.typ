// Mirrors upstream src/xyzrender/api.py.
//
// Upstream `api.py` (~3000 lines) exposes `load(...)`, `render(...)`,
// `render_gif(...)`, the `Molecule` class, `EnsembleFrames`, plus a
// large supporting cast of private helpers for hull / pore / cmap /
// cell / overlay / vector / ensemble / measurement / orient. Almost
// all of those depend on features explicitly out of scope for v1
// (PLAN.md:23-29).
//
// The v1 surface is two functions:
//   - `xyzrender(source, ...)` — load + render in one call. Combines
//     upstream's `load()` (file → Molecule) and `render(molecule, ...)`
//     (Molecule → SVG). Returns Typst content (an `image(...)`).
//     Maps to upstream `render(molecule, config="default", **kwargs)`.
//
// Document-wide kwarg defaults (no upstream parallel — Python has no
// show rules) are a call-site concern, not a library one: rebind the
// import with `.with()`, e.g.
//   #let xyzrender = xyzrender.with(config: "tube", width: 8cm)
// Every later call merges its own kwargs on top of those bound
// defaults, same precedence as any other override.
//
// Style kwargs are not enumerated — `..overrides` accepts anything
// and merges into the resolved config. Upstream lists every
// RenderConfig field explicitly on `render()`; Typst can't (no
// dataclass) and doesn't need to (no static type checking).
//
// `source` accepts bytes (from `read(path, encoding: none)`), an inline
// XYZ/PDB string, or — once a `reader` is bound — a bare path string.
// Format (XYZ vs PDB) is auto-detected; see `readers.typ`. `reader:`
// has no upstream parallel (Python just calls `open()`); it exists
// because a package's own `read()` calls resolve relative to the
// package, not the caller's document. Bind it once to unlock bare
// paths everywhere after:
//   #let xyzrender = xyzrender.with(reader: p => read(p, encoding: none))
//   #xyzrender("Structures/caffeine.pdb")

#import "bond_rules.typ": apply-bond-rules
#import "config.typ": load-preset, merge-overrides, build-region-config
#import "readers.typ": load-molecule
#import "renderer.typ": render-svg
#import "selectors.typ": resolve-atom-indices
#import "types.typ": defaults

// Upstream `apply_hydrogen_flags` (config.py:246-263). Verbatim port:
//
//   no_hy=true           -> hide every H (hide_h=true, show_h_indices=())
//   hy=none (default)    -> hide C-H if `auto_hide_h` is true; else show all
//   hy=true              -> show every H (hide_h=false)
//   hy=(1, 3) / "1,3-5"  -> hide_h=true, show only those H atoms
//                           (atom-spec input is subject to `index_base`,
//                           matching the upstream CLI's 1-indexed convention)
//
// Resolves to `(hide_h, show_h_indices)` — both 0-indexed — which the
// renderer consumes from the config dict.
#let _apply-hydrogen-flags(cfg, hy, no-hy, elements, bonds) = {
  // upstream config.py:251-253
  if no-hy {
    return cfg + (hide_h: true, show_h_indices: ())
  }
  let auto-hide-h = cfg.at("auto_hide_h", default: defaults.auto_hide_h)
  // upstream config.py:254-258
  if hy == none {
    if auto-hide-h {
      return cfg + (hide_h: true, show_h_indices: ())
    }
    return cfg
  }
  // upstream config.py:259-260
  if hy == true {
    return cfg + (hide_h: false, show_h_indices: ())
  }
  // upstream config.py:261-263 — `isinstance(hy, list)` path. Typst
  // strings are accepted alongside arrays as a Typst-side convenience,
  // routed through the same `resolve-atom-indices` grammar used by
  // selectors / vdw_indices.
  //
  // Upstream's type annotation is `bool | list[int] | None`, but only
  // `True` matches a branch — `False` falls through unchanged. We
  // mirror that no-op fall-through so the API stays 1:1. Users who
  // want "hide all H" should pass `no_hy: true` (matches upstream's
  // separate `--no-hy` flag).
  if type(hy) != str and type(hy) != array {
    return cfg
  }
  let index-base = int(cfg.at("index_base", default: defaults.index_base))
  let resolved = if type(hy) == str {
    resolve-atom-indices(hy, elements, bonds: bonds, index-base: index-base)
  } else {
    hy.map(i => int(i) - index-base)
  }
  cfg + (hide_h: true, show_h_indices: resolved)
}

#let xyzrender(
  source,
  config: auto,
  width: auto,
  height: auto,
  rotate: (:),
  frame: 0,
  background: auto,
  hy: none,
  no_hy: false,
  reader: none,
  ..overrides,
) = {
  let call-level = (
    config: config,
    width: width,
    height: height,
    rotate: rotate,
    frame: frame,
    background: background,
  ) + overrides.named()

  // `config:` and `background:` are sentinel-defaulted to `auto` rather
  // than a real value, so an unspecified call-site kwarg — including the
  // bound default left behind by `xyzrender.with(config: "tube")` — never
  // clobbers the preset underneath it. `merge-overrides` drops any `auto`
  // entry before merging (config.typ); only `config` also needs a
  // fallback here, since a preset must always be chosen to load.
  // `background: none` is a real value (transparent) so it can't double
  // as "unset" — `auto` is the only sentinel that lets the preset's own
  // `background` (default.json sets "white") take effect when unpassed.
  let preset-name = if config != auto { config } else { "default" }
  let cfg = load-preset(preset-name)
  let cfg = merge-overrides(cfg, call-level)

  let data = load-molecule(
    source,
    frame: cfg.at("frame", default: 0),
    kekule: cfg.at("kekule", default: false),
    reader: reader,
  )

  // Upstream renderer.py:407 calls `apply_bond_rules(graph, cfg)` on
  // the render-time graph copy — before fog / projection / styling.
  // Mirror that here on the data dict so `hy`'s C-only neighbour check
  // sees the post-rule bond list (an H whose only C neighbour was just
  // unbonded should now stay visible as a free H).
  let data = apply-bond-rules(data, cfg)

  // Upstream api.py invokes `apply_hydrogen_flags` after bond perception
  // because the selector-spec `hy` form needs the molecule's elements
  // (and L/het narrowing needs bonds). Do the same here.
  let cfg = _apply-hydrogen-flags(
    cfg, hy, no_hy, data.elements, data.at("bonds", default: ()),
  )

  // Upstream `_apply_style_regions` (api.py:2384-2474). Two passes:
  // user-supplied `style_regions` keep their resolved configs as-is
  // and mark their atoms in `seen`; preset `region_specs` then skip
  // any indices already claimed (api.py:2458 `free` filter).
  //
  // Per-region rcfg construction (mirroring api.py:2461-2470):
  //   rcfg = copy.copy(cfg)               # inherit base config
  //   rcfg.style_regions = []             # no nested regions
  //   rcfg.region_specs = None
  //   if isinstance(region_def, str):
  //       overrides = load_config(region_def)   # full preset → replaces every key
  //   else:
  //       overrides = region_def                 # dict → only listed keys override
  //   for k, v in overrides.items():
  //       setattr(rcfg, k, v)
  // `index_base` (default 1, Typst-port-only, see types.typ) governs
  // every user-facing index in this project — `style_regions.indices`
  // and `region_specs`' numeric-range keys included, so they read the
  // same numbering as `vdw_indices`/`hy`/`bond`/`unbond`/`ts_bonds`/
  // `nci_bonds`. Normalize `style_regions.indices` to raw 0-based here,
  // once, before it's used for `seen`-tracking or handed to the
  // renderer; `resolve-atom-indices` does the equivalent shift inline
  // for `region_specs`.
  //
  // `indices` accepts the same two forms as `vdw_indices`: an explicit
  // int array (`(1, 2, 3)`) or a selector string (`"1-3"`, `"1-3,8"`,
  // `"het"`, …) routed through the shared selector grammar — matching
  // this project's own string-or-array convention.
  let index-base = int(cfg.at("index_base", default: defaults.index_base))
  let _resolve-region-indices(indices) = if type(indices) == str {
    resolve-atom-indices(indices, data.elements, bonds: data.at("bonds", default: ()), index-base: index-base)
  } else {
    indices.map(i => int(i) - index-base)
  }
  let style-regions = cfg.at("style_regions", default: ()).map(region =>
    region + (indices: _resolve-region-indices(region.indices))
  )
  let region-specs = cfg.at("region_specs", default: none)
  let seen = (:)
  for region in style-regions {
    for ai in region.indices {
      seen.insert(str(int(ai)), true)
    }
  }
  let resolved-regions = style-regions
  if region-specs != none {
    for (sel, region-def) in region-specs {
      let indices = resolve-atom-indices(sel, data.elements, bonds: data.at("bonds", default: ()), index-base: index-base)
      let free = indices.filter(i => not seen.at(str(i), default: false))
      if free.len() == 0 { continue }
      let overrides = if type(region-def) == str {
        load-preset(region-def)
      } else {
        region-def
      }
      let rcfg = cfg + overrides + (style_regions: (), region_specs: none)
      resolved-regions.push((indices: free, config: rcfg))
      for i in free { seen.insert(str(i), true) }
    }
  }
  let cfg = cfg + (style_regions: resolved-regions, region_specs: none)

  // Resolve `consistent_scale` (port-only, see types.typ) into the
  // concrete flag `fit-canvas` reads. In `auto` mode the fixed per-Å
  // scale kicks in only when the caller pinned neither width nor height
  // — a specified size means "fill this box", so we keep auto-fit there.
  let eff-width = cfg.at("width", default: auto)
  let eff-height = cfg.at("height", default: auto)
  let consistent = cfg.at("consistent_scale", default: auto)
  let use-absolute = if consistent == auto {
    eff-width == auto and eff-height == auto
  } else {
    consistent == true
  }
  let cfg = cfg + (_use_absolute_scale: use-absolute)

  let svg = render-svg(data, cfg)

  let img = image(
    bytes(svg),
    format: "svg",
    width: eff-width,
    height: eff-height,
  )

  // Cap the rendered image at 100% of the available width. With
  // consistent scale (width-auto), a large molecule's intrinsic size can
  // exceed the container and overflow the page; clamp those to fit while
  // molecules that already fit keep their intrinsic (consistent) size.
  layout(container => {
    if measure(img).width > container.width {
      image(bytes(svg), format: "svg", width: 100%)
    } else {
      img
    }
  })
}
