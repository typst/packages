// Mirrors upstream src/xyzrender/config.py.
//
// Preset registry and the merge function used to layer:
//   defaults < preset JSON < call-site kwargs
//
// `defaults` (the RenderConfig field defaults) lives in types.typ,
// matching upstream's split where `RenderConfig` is in types.py and
// `load_config` / `_merge_onto_default` are in config.py.

#import "types.typ": defaults

// Built-in preset name -> path. User-supplied JSON paths are passed
// straight through `load-preset`.
#let _built-in = (
  "default": "presets/default.json",
  "flat":    "presets/flat.json",
  "paton":   "presets/paton.json",
  "vdw":     "presets/vdw.json",
  "tube":    "presets/tube.json",
  "btube":   "presets/btube.json",
  "mtube":   "presets/mtube.json",
  "bubble":  "presets/bubble.json",
  "graph":   "presets/graph.json",
  "pmol":    "presets/pmol.json",
  "wire":    "presets/wire.json",
)

// One-level deep merge, mirroring upstream `_merge_onto_default`
// (config.py:63-71): `for k, v in over: base[k].update(v)` when both
// sides hold a dict at `k`, else `base[k] = v`. Typst's `+` on dicts is
// the shallow inner `.update`. A plain `base + over` would REPLACE a
// nested dict wholesale — dropping keys a partial override means to
// inherit (e.g. `wire`/`tube` declare only `colors.H` and must keep
// `colors.C` from default.json).
#let _deep-merge(base, over) = {
  let out = base
  for (k, v) in over {
    out.insert(
      k,
      if type(v) == dictionary and type(base.at(k, default: none)) == dictionary {
        base.at(k) + v
      } else {
        v
      },
    )
  }
  out
}

// Upstream `load_config` (config.py:74-99) + `_merge_onto_default`
// (config.py:63-71): every preset — built-in or user-supplied — is
// layered on top of `default.json` so unspecified keys inherit the
// standard look. The bare `defaults` dict (in types.typ, mirroring
// the RenderConfig dataclass field defaults) sits beneath default.json
// as the ultimate fallback for keys default.json doesn't set.
//
//   load-preset("default") = defaults + default.json
//   load-preset("flat")    = defaults + default.json + flat.json
//   load-preset(path.json) = defaults + default.json + user.json
#let load-preset(name-or-path) = {
  let default-layer = _deep-merge(defaults, json(_built-in.at("default")))
  if name-or-path == "default" {
    default-layer
  } else {
    let path = _built-in.at(name-or-path, default: name-or-path)
    _deep-merge(default-layer, json(path))
  }
}

// Merge `overrides` on top of `base`, but drop entries whose value is
// the sentinel `auto` so users passing the default kwargs don't blow
// away preset values.
#let merge-overrides(base, overrides) = {
  let effective = (:)
  for (k, v) in overrides {
    if v != auto {
      effective.insert(k, v)
    }
  }
  base + effective
}

// Upstream `build_region_config` (config.py:431-438) — a region's
// config is just a full RenderConfig built from a preset name (string)
// or an inline overrides dict. Only per-atom/bond fields are
// meaningful; global fields (canvas, fog, surfaces) are ignored by
// the renderer for region configs.
//
// Accepts either:
//   - a string: a preset name → load-preset(name)
//   - a dict: kwarg overrides → load default preset, merge overrides
#let build-region-config(spec) = {
  if type(spec) == str {
    load-preset(spec)
  } else if type(spec) == dictionary {
    merge-overrides(load-preset("default"), spec)
  } else {
    load-preset("default")
  }
}
