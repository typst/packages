// ETH Zürich corporate design colour palette.
// https://ethz.ch/staffnet/en/service/communication/corporate-design/colours.html
//
// Each corporate-design colour is a dictionary of its published shades. The key
// is the shade percentage (`s10` … `s120`); `s100` is the base colour, also
// exposed as `base`. Access e.g. `eth.blue.base` or `eth.red.s40`.

// Build a shade palette from the seven published hex values.
#let palette(s10, s20, s40, s60, s80, base, s120) = (
  s10: rgb(s10),
  s20: rgb(s20),
  s40: rgb(s40),
  s60: rgb(s60),
  s80: rgb(s80),
  s100: rgb(base),
  base: rgb(base),
  s120: rgb(s120),
)

// ETH Zürich corporate-design colours, with the published shades.
#let eth = (
  blue: palette("#e9eff7", "#d3deef", "#a6bedf", "#7a9dcf", "#4d7dbf", "#215caf", "#08407e"),
  petrol: palette("#e7f4f7", "#cce4ea", "#99cad5", "#66afc0", "#3395ab", "#007894", "#00596d"),
  green: palette("#eef1e7", "#e0e3d0", "#c0c7a1", "#a1ab71", "#818f42", "#627313", "#365213"),
  bronze: palette("#f4f0e7", "#e8e1d0", "#d2c2a1", "#bba471", "#a58542", "#8e6713", "#704f12"),
  red: palette("#f8ebea", "#f1d7d5", "#e2aeab", "#d48681", "#c55d57", "#b7352d", "#96272d"),
  purple: palette("#f8e8f3", "#efd0e3", "#dc9ec9", "#ca6cae", "#b73b92", "#a7117a", "#8c0a59"),
  grey: palette("#f1f1f1", "#e2e2e2", "#c5c5c5", "#a9a9a9", "#8c8c8c", "#6f6f6f", "#575757"),
  black: rgb("#000000"),
  white: rgb("#ffffff"),
)
