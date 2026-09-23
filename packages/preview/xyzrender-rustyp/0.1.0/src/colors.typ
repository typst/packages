// Mirrors upstream src/xyzrender/colors.py.
//
// Element-keyed lookups (CPK colour, vdW radius), colour-space maths
// (hex<->RGB<->HSL, HSL-space lighten/darken), and the gradient
// triplet helper `get-gradient-colors`. All formulas, constants, and
// stop offsets are ported verbatim from upstream.

#import "types.typ": defaults

#let _named-colors = json("presets/named_colors.json")

// CPK colours (Jmol palette). Ported verbatim from upstream
// colors.py:_CPK (atomic-number indexed). Keyed by element symbol
// here because the WASM plugin emits symbols, not atomic numbers.
// Atoms not in this table fall back to `_DEFAULT_COLOR`.
#let _cpk = (
  "H":  "#ffffff", "He": "#d9ffff",
  "Li": "#cc80ff", "Be": "#c2ff00", "B":  "#ffb5b5", "C":  "#909090",
  "N":  "#3050f8", "O":  "#ff0d0d", "F":  "#90e050", "Ne": "#b3e3f5",
  "Na": "#ab5cf2", "Mg": "#8aff00", "Al": "#bfa6a6", "Si": "#f0c8a0",
  "P":  "#ff8000", "S":  "#ffff30", "Cl": "#1ff01f", "Ar": "#80d1e3",
  "K":  "#8f40d4", "Ca": "#3dff00",
  "Sc": "#e6e6e6", "Ti": "#bfc2c7", "V":  "#a6a6ab", "Cr": "#8a99c7",
  "Mn": "#9c7ac7", "Fe": "#e06633", "Co": "#f090a0", "Ni": "#50d050",
  "Cu": "#c88033", "Zn": "#7d80b0",
  "Ga": "#c28f8f", "Ge": "#668f8f", "As": "#bd80e3", "Se": "#ffa100",
  "Br": "#a62929", "Kr": "#5cb8d1",
  "Rb": "#702eb0", "Sr": "#00ff00",
  "Y":  "#94ffff", "Zr": "#94e0e0", "Nb": "#73c2c9", "Mo": "#54b5b5",
  "Tc": "#3b9e9e", "Ru": "#248f8f", "Rh": "#0a7d8c", "Pd": "#006985",
  "Ag": "#c0c0c0", "Cd": "#ffd98f",
  "In": "#a67573", "Sn": "#668080", "Sb": "#9e63b5", "Te": "#d47a00",
  "I":  "#940094", "Xe": "#429eb0",
  "Cs": "#57178f", "Ba": "#00c900",
  "La": "#70d4ff",
  "Ce": "#ffffc7", "Pr": "#d9ffc7", "Nd": "#c7ffc7", "Pm": "#a3ffc7",
  "Sm": "#8fffc7", "Eu": "#61ffc7", "Gd": "#45ffc7", "Tb": "#30ffc7",
  "Dy": "#1fffc7", "Ho": "#00ff9c", "Er": "#00e675", "Tm": "#00d452",
  "Yb": "#00bf38",
  "Lu": "#00ab24", "Hf": "#4dc2ff", "Ta": "#4da6ff", "W":  "#2194d6",
  "Re": "#267dab", "Os": "#266696", "Ir": "#175487", "Pt": "#d0d0e0",
  "Au": "#ffd123", "Hg": "#b8b8d0",
  "Tl": "#a6544d", "Pb": "#575961", "Bi": "#9e4fb5", "Po": "#ab5c00",
  "At": "#754f45", "Rn": "#428296",
  "Fr": "#420066", "Ra": "#007d00",
  "Ac": "#70abfa",
  "Th": "#00baff", "Pa": "#00a1ff", "U":  "#008fff", "Np": "#0080ff",
  "Pu": "#006bff", "Am": "#545cf2", "Cm": "#785ce3", "Bk": "#8a4fe3",
  "Cf": "#a136d4", "Es": "#b31fd4", "Fm": "#b31fba", "Md": "#b30da6",
  "No": "#bd0d87", "Lr": "#c70066",
  // Superheavies (Z 104-118). Upstream `_CPK` only gives Rf a distinct
  // colour; Db-Og all resolve to the #a0a0a0 default there, mirrored
  // verbatim so the table is a complete 1:1 copy through Og (colors.py:192).
  "Rf": "#cc0059",
  "Db": "#a0a0a0", "Sg": "#a0a0a0", "Bh": "#a0a0a0", "Hs": "#a0a0a0",
  "Mt": "#a0a0a0", "Ds": "#a0a0a0", "Rg": "#a0a0a0", "Cn": "#a0a0a0",
  "Nh": "#a0a0a0", "Fl": "#a0a0a0", "Mc": "#a0a0a0", "Lv": "#a0a0a0",
  "Ts": "#a0a0a0", "Og": "#a0a0a0",
)

// Upstream colors.py:208 — fallback for elements outside the CPK table.
#let _DEFAULT_COLOR = "#a0a0a0"

// vdW radii in Angstroms — used for display sizing. These are NOT Bondi
// radii: upstream xyzrender reads `raw_vdw = DATA.vdw.get(s, 1.5)` where
// `DATA` is `from xyzgraph import DATA`, i.e. xyzgraph's data/vdw_radii.json
// (values in Bohr) × BOHR_TO_ANGSTROM (0.5291772105). Bondi radii are ~0.89×
// these (C: 1.70 vs 1.910) — using them shrank every atom and dropped metals
// to the 1.5 default. Generated verbatim from the pinned xyzgraph via
// `~/Lavoro/bin/python -c "from xyzgraph import DATA; print(DATA.vdw)"`; the
// Rust plugin generates the same table from plugin/src/data/vdw_radii.json in
// build.rs. Quirk carried verbatim: xyzgraph has a lowercase "ho" (Holmium
// "Ho" therefore falls to the 1.5 default upstream too). Regenerate this
// table on any xyzgraph pin bump (see SYNC.md) — Typst has no build.rs.
#let _vdw = (
  "H": 1.6746855305377184,
  "He": 1.4144901544892894,
  "Li": 2.7991331267747475,
  "Be": 2.26884729001875,
  "B": 2.0797722727071,
  "C": 1.9101180590208,
  "N": 1.7981441612790001,
  "O": 1.71453416202,
  "F": 1.6310299982030998,
  "Ne": 1.553511886991376,
  "Na": 2.7967015574925003,
  "Mg": 2.4845928387395997,
  "Al": 2.4116722191327002,
  "Si": 2.2654076381504997,
  "P": 2.1394634620515,
  "S": 2.06342069690265,
  "Cl": 1.98129239383305,
  "Ar": 1.9052374576083584,
  "K": 3.0366305047332003,
  "Ca": 2.791938962598,
  "Sc": 2.5966725719235,
  "Ti": 2.6083144705545003,
  "V": 2.5569842811359997,
  "Cr": 2.5395214331895,
  "Mn": 2.4680825097719996,
  "Fe": 2.4358026999314997,
  "Co": 2.3945268775125004,
  "Ni": 2.3553677639355,
  "Cu": 2.3416091564625,
  "Zn": 2.2773670431078004,
  "Ga": 2.362247067672,
  "Ge": 2.288162258202,
  "As": 2.196085423575,
  "Se": 2.185501879365,
  "Br": 2.087074918212,
  "Kr": 2.0214426563253167,
  "Rb": 3.0795996942258,
  "Sr": 2.873432253015,
  "Y": 2.79405567144,
  "Zr": 2.6506486473945,
  "Nb": 2.6003768123969997,
  "Mo": 2.5569842811359997,
  "Tc": 2.5215294080325,
  "Ru": 2.4887204209815,
  "Rh": 2.4553822567199997,
  "Pd": 2.15274581003505,
  "Ag": 2.3945268775125004,
  "Cd": 2.3342006755154996,
  "In": 2.4527363706675,
  "Sn": 2.3818266244605,
  "Sb": 2.3119752326745,
  "Te": 2.271228587466,
  "I": 2.22513725243145,
  "Xe": 2.1666102529501496,
  "Cs": 3.18051378826815,
  "Ba": 3.008901618903,
  "La": 2.909416303329,
  "Ce": 2.8898367465405,
  "Pr": 2.9115330121709997,
  "Nd": 2.8956576958560003,
  "Pm": 2.879782379541,
  "Sm": 2.862848708805,
  "Eu": 2.8453858608585,
  "Gf": 2.7845304816509997,
  "Tb": 2.8136352282285,
  "Dy": 2.8014641523869996,
  "ho": 2.779238709546,
  "Er": 2.7638925704415,
  "Tm": 2.747488076916,
  "Yb": 2.7337294694430003,
  "Lu": 2.7279085201275,
  "Hf": 2.619427191975,
  "Ta": 2.49771643356,
  "W": 2.46596580093,
  "Re": 2.4358026999314997,
  "Os": 2.406697953354,
  "Ir": 2.3881767509864997,
  "Pt": 2.348488460199,
  "Au": 2.2537657395195003,
  "Hg": 2.2347153599414997,
  "Tl": 2.362247067672,
  "Pb": 2.3416091564625,
  "Bi": 2.348488460199,
  "Po": 2.3193837136215,
  "At": 2.304037574517,
  "Rn": 2.244769726941,
  "Fr": 3.0768479727312,
  "Ra": 2.9660382648525,
  "Ac": 2.8856033288565,
  "Th": 2.9157664298549997,
  "Pa": 2.773946937441,
  "U": 2.7046247228655,
  "Np": 2.7665384564939997,
  "Pu": 2.7146790898649997,
  "Am": 2.70938731776,
  "Cm": 2.7464297224950003,
  "Bk": 2.693512001445,
  "Cf": 2.682928457235,
  "Es": 2.672344913025,
  "Fm": 2.6564695967099996,
  "Md": 2.640594280395,
  "No": 2.643769343658,
  "Lr": 3.0798113651100003,
  "Rf": 2.6506486473945,
  "Db": 2.304037574517,
  "Sg": 2.288162258202,
  "Bh": 2.271228587466,
  "Hs": 2.2537657395195003,
  "Mt": 2.2357737143625,
  "Ds": 2.216194157574,
  "Rg": 2.2172525119950004,
  "Cn": 2.1743891579445,
  "Nh": 2.185501879365,
  "Fl": 2.2061397905745,
  "Mc": 2.481841117245,
  "Ts": 2.50829997777,
  "Og": 2.41304807988,
)

// ---- colour resolution ----

#let resolve-color(c) = {
  // Accept native Typst `color` values (`rgb("#…")`, `blue`, `luma(…)`,
  // etc.) — the idiomatic way a Typst user writes a colour — by folding
  // them to a hex string. `to-hex()` yields "#rrggbb" for opaque colours
  // (or "#rrggbbaa" when the colour carries alpha; downstream hex math
  // reads only the rgb bytes). Without this, any colour object fell to
  // the `#ff1493` fallback below and rendered fuchsia.
  if type(c) == color {
    c.to-hex()
  } else if type(c) != str {
    "#ff1493"
  } else if c.starts-with("#") {
    c
  } else {
    _named-colors.at(lower(c), default: "#ff1493")
  }
}

#let element-color(element, config) = {
  let overrides = config.at("colors", default: (:))
  let raw = overrides.at(element, default: _cpk.at(element, default: _DEFAULT_COLOR))
  resolve-color(raw)
}

// Upstream xyzrender atom-radius formula (renderer.py):
//   raw_vdw[i] = vdw[s] * (h_scale if s=="H" else 1.0)
//   radii[i]   = raw_vdw[i] * atom_scale * 0.075  (Angstroms)
// Renderer multiplies by px/Å scale at render time.
// NOTE: `vdw_scale` is intentionally NOT used here — upstream uses it
// only for the vdW-surface rendering preset, not for atom sizing.
#let display-radius(element, config) = {
  let atom-scale = float(config.at("atom_scale", default: defaults.atom_scale))
  if atom-scale == 0.0 { return 0.0 }
  let h-scale = float(config.at("h_scale", default: defaults.h_scale))
  let h-factor = if element == "H" { h-scale } else { 1.0 }
  let raw-vdw = _vdw.at(element, default: 1.5) * h-factor
  raw-vdw * atom-scale * 0.075
}

// Upstream `raw_vdw_sphere` (renderer.py:182-184) — the VDW overlay
// uses its OWN h_scale (`vdw_h_scale`) so the --vdw look stays
// consistent regardless of which primary preset is active. Returns
// the unscaled xyzgraph VDW radius in Angstroms (see _vdw above).
#let raw-vdw-sphere(element, vdw-h-scale) = {
  let h-factor = if element == "H" { vdw-h-scale } else { 1.0 }
  _vdw.at(element, default: 1.5) * h-factor
}

// ---- hex <-> RGB ----

#let _hex-table = (
  "0": 0, "1": 1, "2": 2, "3": 3, "4": 4,
  "5": 5, "6": 6, "7": 7, "8": 8, "9": 9,
  "a": 10, "b": 11, "c": 12, "d": 13, "e": 14, "f": 15,
)

#let _hex-pair(hex, i) = {
  let hi = _hex-table.at(lower(hex.at(i)), default: 0)
  let lo = _hex-table.at(lower(hex.at(i + 1)), default: 0)
  hi * 16 + lo
}

// Returns (r, g, b) in 0..1.
#let parse-hex(hex) = (
  _hex-pair(hex, 1) / 255.0,
  _hex-pair(hex, 3) / 255.0,
  _hex-pair(hex, 5) / 255.0,
)

#let _byte-to-hex(n) = {
  let n = int(calc.clamp(n, 0, 255))
  let h = "0123456789abcdef"
  h.at(int(n / 16)) + h.at(int(calc.rem(n, 16)))
}

// rgb-floats (0..1) -> "#rrggbb"
// Only the HSL darken/lighten path (get-gradient-colors) reaches here now —
// rgb-blend does its own integer-space quantization. Upstream `from_hls`
// truncates with `int(v*255)` (colors.py:48), NOT round; `_byte-to-hex`
// already does `int(clamp(...))`, so pass the raw scaled channel through.
// Verified: matches upstream on 344/345 gradient stops across a colour/shift
// sweep (the 1 miss is a sub-ULP `hls_to_rgb` vs CPython `colorsys` drift);
// `calc.round` here was off-by-one on essentially every saturated colour.
#let format-hex(rgb) = (
  "#"
    + _byte-to-hex(rgb.at(0) * 255)
    + _byte-to-hex(rgb.at(1) * 255)
    + _byte-to-hex(rgb.at(2) * 255)
)

// Python's `%` is sign-of-divisor; Typst's `calc.rem` is
// sign-of-dividend. Upstream uses `%`, so we need a Python-style
// modulo helper here, otherwise hues > ~300° (most metals, halogens,
// magentas) get shifted in the wrong direction.
#let _pymod(a, b) = {
  let r = calc.rem(a, b)
  if r < 0.0 { r + b } else { r }
}

// ---- RGB <-> HSL (matches Python's colorsys.rgb_to_hls / hls_to_rgb) ----
//
// Note: Python's stdlib colorsys uses HLS (hue, lightness, saturation)
// ordering; upstream's `to_hls()` and `from_hls()` mirror that. We
// preserve the (h, l, s) tuple ordering used by upstream.

#let rgb-to-hls(r, g, b) = {
  let mx = calc.max(r, g, b)
  let mn = calc.min(r, g, b)
  let l = (mx + mn) / 2.0
  if mx == mn {
    return (0.0, l, 0.0)
  }
  let d = mx - mn
  let s = if l > 0.5 { d / (2.0 - mx - mn) } else { d / (mx + mn) }
  let h = if mx == r {
    (g - b) / d + (if g < b { 6.0 } else { 0.0 })
  } else if mx == g {
    (b - r) / d + 2.0
  } else {
    (r - g) / d + 4.0
  }
  (h * 60.0, l, s)
}

#let _hue-to-rgb(p, q, t) = {
  let t = if t < 0.0 { t + 1.0 } else if t > 1.0 { t - 1.0 } else { t }
  if t < 1.0 / 6.0 {
    p + (q - p) * 6.0 * t
  } else if t < 0.5 {
    q
  } else if t < 2.0 / 3.0 {
    p + (q - p) * (2.0 / 3.0 - t) * 6.0
  } else {
    p
  }
}

#let hls-to-rgb(h, l, s) = {
  if s == 0.0 {
    return (l, l, l)
  }
  let q = if l < 0.5 { l * (1.0 + s) } else { l + s - l * s }
  let p = 2.0 * l - q
  // Matches Python `(h % 360) / 360` from upstream Color.from_hls.
  let hn = _pymod(h, 360.0) / 360.0
  (
    _hue-to-rgb(p, q, hn + 1.0 / 3.0),
    _hue-to-rgb(p, q, hn),
    _hue-to-rgb(p, q, hn - 1.0 / 3.0),
  )
}

// ---- lighten / darken (upstream HSL-space formulas) ----
//
// From colors.py:
//   lighten:
//     new_l = l + light_shift * strength * (1 - l)
//     d     = ((60 - h + 180) mod 360) - 180
//     new_h = (h + d * hue_shift * strength) mod 360       (toward yellow)
//     new_s = s * (1 - sat_shift * strength)
//   darken:
//     new_l = l * (1 - light_shift * strength * 3)
//     d     = ((240 - h + 180) mod 360) - 180
//     new_h = (h + d * hue_shift * strength) mod 360       (toward blue)
//     new_s = s + (1 - s) * sat_shift * strength

#let _shift-hue(h, target, hue-shift, strength) = {
  let d = _pymod(target - h + 180.0, 360.0) - 180.0
  _pymod(h + d * hue-shift * strength, 360.0)
}

#let lighten-hex(
  hex,
  strength: 1.0,
  hue-shift: 0.2,
  light-shift: 0.2,
  sat-shift: 0.2,
) = {
  let (r, g, b) = parse-hex(hex)
  let (h, l, s) = rgb-to-hls(r, g, b)
  let new-l = l + light-shift * strength * (1.0 - l)
  let new-h = _shift-hue(h, 60.0, hue-shift, strength)
  let new-s = s * (1.0 - sat-shift * strength)
  format-hex(hls-to-rgb(new-h, calc.clamp(new-l, 0.0, 1.0), calc.clamp(new-s, 0.0, 1.0)))
}

#let darken-hex(
  hex,
  strength: 1.0,
  hue-shift: 0.2,
  light-shift: 0.2,
  sat-shift: 0.2,
) = {
  let (r, g, b) = parse-hex(hex)
  let (h, l, s) = rgb-to-hls(r, g, b)
  let new-l = l * (1.0 - light-shift * strength * 3.0)
  let new-h = _shift-hue(h, 240.0, hue-shift, strength)
  let new-s = s + (1.0 - s) * sat-shift * strength
  format-hex(hls-to-rgb(new-h, calc.clamp(new-l, 0.0, 1.0), calc.clamp(new-s, 0.0, 1.0)))
}

// Upstream's get_gradient_colors() — returns (hi, base, lo).
#let get-gradient-colors(hex, config, strength: 1.0) = (
  lighten-hex(
    hex,
    strength: strength,
    hue-shift: float(config.at("hue_shift_factor", default: defaults.hue_shift_factor)),
    light-shift: float(config.at("light_shift_factor", default: defaults.light_shift_factor)),
    sat-shift: float(config.at("saturation_shift_factor", default: defaults.saturation_shift_factor)),
  ),
  resolve-color(hex),
  darken-hex(
    hex,
    strength: strength,
    hue-shift: float(config.at("hue_shift_factor", default: defaults.hue_shift_factor)),
    light-shift: float(config.at("light_shift_factor", default: defaults.light_shift_factor)),
    sat-shift: float(config.at("saturation_shift_factor", default: defaults.saturation_shift_factor)),
  ),
)

// ---- fog (upstream colors.py / renderer.py) ----

// Upstream colors.py (v0.3.3 "Fog update"):
//   _FOG_NEAR       = 1.0   # Å of depth before fog kicks in
//   _MAX_FOG        = 0.70  # deepest primitives keep >=30% of their colour
//   _FOG_MIN_DELTA_E = 10.0 # ...and never come within this ΔE of the fog
//   WHITE           = #ffffff (fog target when the background isn't a colour)
#let WHITE = "#ffffff"
#let MAX_FOG = 0.70
#let FOG_NEAR = 1.0
#let FOG_MIN_DELTA_E = 10.0

// Linear RGB interpolation between two hex colours (upstream
// Color.blend uses RGB-space mix).
// Lerp toward `hex-b` by `t`, matching upstream `Color.blend`
// (colors.py:57-61) *exactly*: it works in 0..255 **integer** space and
// truncates with `int(a + t*(b-a))`. Blending in 0..1 space instead would
// let float error (e.g. 33.0 → 32.9999) truncate a channel down by one, so
// the arithmetic stays on the raw bytes here. `_byte-to-hex` does the
// `int(clamp(...))`.
#let rgb-blend(hex-a, hex-b, t) = {
  let mix(a, b) = a + t * (b - a)
  "#" + _byte-to-hex(mix(_hex-pair(hex-a, 1), _hex-pair(hex-b, 1))) + _byte-to-hex(mix(_hex-pair(hex-a, 3), _hex-pair(hex-b, 3))) + _byte-to-hex(mix(_hex-pair(hex-a, 5), _hex-pair(hex-b, 5)))
}

// CIELAB (L*, a*, b*) under D65 — upstream colors.py `_lab`.
#let _lab(hex) = {
  // parse-hex already returns channels in 0..1 (upstream's `lin` divides the
  // 0..255 byte by 255 first — that normalisation is already done here, so
  // `s` is the channel value directly, NOT `channel / 255`).
  let (r1, g1, b1) = parse-hex(hex)
  let lin(s) = { if s <= 0.04045 { s / 12.92 } else { calc.pow((s + 0.055) / 1.055, 2.4) } }
  let f(t) = if t > 216.0 / 24389.0 { calc.pow(t, 1.0 / 3.0) } else { t * (841.0 / 108.0) + 4.0 / 29.0 }
  let r = lin(r1)
  let g = lin(g1)
  let b = lin(b1)
  let fx = f((0.4124564 * r + 0.3575761 * g + 0.1804375 * b) / 0.95047)
  let fy = f(0.2126729 * r + 0.7151522 * g + 0.0721750 * b)
  let fz = f((0.0193339 * r + 0.1191920 * g + 0.9503041 * b) / 1.08883)
  (116.0 * fy - 16.0, 500.0 * (fx - fy), 200.0 * (fy - fz))
}

// CIE76 perceptual colour difference — upstream colors.py `delta_e`.
#let delta-e(hex-a, hex-b) = {
  let (l1, a1, b1) = _lab(hex-a)
  let (l2, a2, b2) = _lab(hex-b)
  calc.sqrt((l1 - l2) * (l1 - l2) + (a1 - a2) * (a1 - a2) + (b1 - b2) * (b1 - b2))
}

// Largest blend fraction leaving `base` FOG_MIN_DELTA_E clear of `fog`
// (upstream colors.py `_legible_fog`; Typst memoizes it like the lru_cache).
#let _legible-fog(base-hex, fog-hex) = {
  if delta-e(base-hex, fog-hex) <= FOG_MIN_DELTA_E {
    0.0
  } else {
    let lo = 0.0
    let hi = 1.0
    for _ in range(24) {
      let mid = (lo + hi) / 2.0
      if delta-e(rgb-blend(base-hex, fog-hex, mid), fog-hex) >= FOG_MIN_DELTA_E { lo = mid } else { hi = mid }
    }
    lo
  }
}

// Colour depth fog converges on: the background, unless `fog-color`
// overrides it; "none"/"transparent"/unparseable → white (upstream
// colors.py `fog_target`, whose `Color.from_str` raises → WHITE).
#let fog-target(background, fog-color: none) = {
  let raw = if fog-color != none { fog-color } else { background }
  if type(raw) != str { return WHITE }
  let low = lower(raw)
  if low == "none" or low == "transparent" { return WHITE }
  if raw.starts-with("#") { return raw }
  _named-colors.at(low, default: WHITE)
}

// Fog blend fraction at a normalized depth (upstream colors.py `fog_alpha`):
//   min(strength * depth_norm**2, _MAX_FOG)
#let fog-alpha(depth-norm, strength) = calc.min(strength * depth-norm * depth-norm, MAX_FOG)

// Upstream blend_fog (colors.py, v0.3.3): lerp `hex` toward `fog-hex` by
// `alpha`, floored to _legible-fog so the result stays legible. `alpha` is
// used directly (the depth-squaring now lives in `fog-alpha`).
#let blend-fog(hex, fog-hex, alpha) = {
  let base = resolve-color(hex)
  let fog = resolve-color(fog-hex)
  let a = calc.min(calc.max(alpha, 0.0), 1.0, _legible-fog(base, fog))
  rgb-blend(base, fog, a)
}

// ---- plugin-backed batched entries (verbatim port lives in
// plugin/src/colors.rs and plugin/src/renderer.rs) ----
//
// One WASM round-trip per render replaces an O(n) loop of per-atom
// Typst function calls (parse-hex / HSL / lighten / darken /
// blend-fog). Pure-Typst variants below stay as the 1:1 reference
// for colors.py — the renderer can swap branches by importing one
// vs the other.

// Batched per-atom gradient triples (renderer.py:578-590). Returns
// a list of (hi, me, lo) hex tuples — one per atom in `elements`,
// fog-blended toward `fog-col` by `fog-fs` (the result of
// `compute-fog-factors`), with the CIELAB legibility floor.
//
// `color-overrides` is `config.at("colors", default: (:))` flattened
// to a list of `(symbol, hex)` pairs (CBOR-friendly).
//
// Values must be resolved through `resolve-color` (not just `str(...)`)
// before crossing into Rust: the WASM side's `Color::from_hex` only
// understands `#rrggbb` and silently falls back to black on anything
// else, so a raw named colour like `"royalblue"` or a native Typst
// `color` value (whose `str()` repr isn't hex either) rendered every
// override atom pure black instead of the intended colour. The
// non-plugin path (`element-color` in this file) already resolves
// through `resolve-color`; this makes the plugin path do the same.
#let compute-atom-gradients-plugin(
  elements, fog-fs, fog-col, color-overrides,
  hue-shift, light-shift, sat-shift, strength,
) = {
  let p = plugin("assets/xyzrender.wasm")
  let overrides-pairs = color-overrides.pairs().map(((k, v)) => (k, resolve-color(v)))
  let input = (
    elements: elements,
    overrides: overrides-pairs,
    fog_factors: fog-fs.map(f => float(f)),
    fog_col: resolve-color(fog-col),
    hue_shift_factor: float(hue-shift),
    light_shift_factor: float(light-shift),
    saturation_shift_factor: float(sat-shift),
    strength: float(strength),
  )
  let raw = p.compute_atom_gradients(cbor.encode(input))
  cbor(raw)
}

// Batched fog factors (renderer.py:487-493). Equivalent to
// `compute-fog-factors` below — exposed for callers that want to
// route through the plugin instead of the Typst implementation.
#let compute-fog-factors-plugin(coords, config) = {
  let p = plugin("assets/xyzrender.wasm")
  let zs = coords.map(c => float(c.at(2)))
  let input = (
    z: zs,
    fog: config.at("fog", default: defaults.fog),
    fog_strength: float(config.at("fog_strength", default: defaults.fog_strength)),
  )
  let raw = p.compute_fog_factors(cbor.encode(input))
  cbor(raw)
}

// Upstream fog factor (renderer.py:489-493, v0.3.3):
//   zr    = max(z.max - z.min, 1e-6)
//   fog_d = clip((z.max - z - _FOG_NEAR) / zr, 0, 1)          # normalized depth
//   fog_f = fog_alpha(fog_d, fog_strength)                    # = min(s·d², _MAX_FOG)
//
// Returns per-atom fog *alpha* (already capped) aligned with `coords`.
// Pure 0s if `config.fog` is False.
#let compute-fog-factors(coords, config) = {
  let fog-on = config.at("fog", default: defaults.fog)
  if not fog-on {
    return coords.map(_ => 0.0)
  }
  let fog-strength = float(config.at("fog_strength", default: defaults.fog_strength))
  let zs = coords.map(p => float(p.at(2)))
  let zmax = calc.max(..zs)
  let zmin = calc.min(..zs)
  let zr = calc.max(zmax - zmin, 0.000001)
  zs.map(z => {
    let d = calc.clamp((zmax - z - FOG_NEAR) / zr, 0.0, 1.0)
    fog-alpha(d, fog-strength)
  })
}
