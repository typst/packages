// theme.typ — Default color palette + BW helpers for trigo-scenes

#let scene-theme = (
  sky: rgb("#d4eafc"),
  ground: rgb("#8BC34A"),
  ground-stroke: rgb("#228B22"),
  water-light: rgb("#64B5F6"),
  water-mid: rgb("#42A5F5"),
  water-deep: rgb("#1E88E5"),
  mountain: rgb("#607D8B"),
  mountain-stroke: rgb("#455A64"),
  snow: white,
  rock: rgb("#78909C"),
  tree-trunk: rgb("#5D4037"),
  tree-foliage: rgb("#2E7D32"),
  wood: rgb("#8B6914"),
  brick: rgb("#B55A30"),
  sand: rgb("#F5DEB3"),
  metal: rgb("#9E9E9E"),
  balloon-envelope: rgb("#FF6F00"),
  balloon-envelope-stroke: rgb("#E65100"),
  balloon-basket: rgb("#795548"),
  balloon-basket-stroke: rgb("#5D4037"),
  boat-hull: rgb("#795548"),
  boat-hull-stroke: rgb("#5D4037"),
  submarine-hull: rgb("#37474F"),
  submarine-hull-stroke: rgb("#263238"),
  person: rgb("#333333"),
  fish-default: rgb("#FF9800"),
  rope: rgb("#555555"),
  wall-fill: rgb("#D7CCC8"),
  wall-stroke: rgb("#8D6E63"),
  roof: rgb("#B71C1C"),
  window: rgb("#BBDEFB"),
  door: rgb("#5D4037"),
  concrete: rgb("#BDBDBD"),
  concrete-stroke: rgb("#757575"),
  night-sky: rgb("#0d1b2a"),
  star: rgb("#FFFDE7"),
  underground: rgb("#4E342E"),
  underground-stroke: rgb("#3E2723"),
  cliff: rgb("#6D4C41"),
  cliff-stroke: rgb("#4E342E"),
  road: rgb("#616161"),
  road-stroke: rgb("#424242"),
  road-marking: rgb("#FFEB3B"),
  path: rgb("#A1887F"),
  bush: rgb("#1B5E20"),
  flower-stem: rgb("#388E3C"),
  lightning: rgb("#FFD600"),
  moon: rgb("#FFF9C4"),
  fence: rgb("#8D6E63"),
  antenna: rgb("#757575"),
  kite-string: rgb("#555555"),
  car-body: rgb("#1565C0"),
  car-stroke: rgb("#0D47A1"),
  helicopter-body: rgb("#455A64"),
  airplane-body: rgb("#ECEFF1"),
  airplane-stroke: rgb("#607D8B"),
  parachute-canopy: rgb("#FF7043"),
  rocket-body: rgb("#ECEFF1"),
  rocket-nose: rgb("#F44336"),
  rocket-flame: rgb("#FF9800"),
  drone-body: rgb("#37474F"),
)

// --- BW mode helpers ---
// When `bw` is true:
//   _f(color, bw) → none  (no fill)
//   _s(color, bw) → black (black stroke)
// When `bw` is false:
//   _f(color, bw) → color
//   _s(color, bw) → color

/// Resolve a fill color — returns `none` in BW mode
#let _f(color, bw) = if bw { none } else { color }

/// Resolve a stroke color — returns `black` in BW mode
#let _s(color, bw) = if bw { black } else { color }
