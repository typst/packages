// Curated palette collection, exported on every facade as the `palettes`
// namespace. Each palette is the same flat eight-color dictionary that
// `setup(colors: ..)` and theme definitions accept, so any of these composes
// with any theme in either polarity:
//
//   #show: m.setup.with(colors: m.palettes.espresso)
//
// Six keys are the deck's own chrome (`canvas`, `surface`, `accent`, `text`,
// `muted`, `line`); the remaining two name the status colors components paint
// with. A component derives its panel fill by mixing its color into `canvas`,
// so a palette states each color once and the tint follows the palette in
// both polarities. Every entry here is an ordinary dictionary, so extending
// one is addition: `m.palettes.light + (accent: rgb("#b91c1c"))`.
//
// The built-in polarity pair leads the collection under its plain names;
// `palettes.light` and `palettes.dark` are the only names for the pair. The six
// curated schemes share one Japandi voice: wood-tone and dried-plant accents,
// muted sage, one indigo for depth, and status colors that whisper rather
// than shout. Accents are drawn from Japandi interior swatches and then tuned
// to the contrast contract below.
//
// A ground carries only a trace of its hue. Light canvases sit within a few
// steps of white and dark inks within a few steps of it too, so the tint
// reads as the temperature of the paper rather than as a color in its own
// right; the scheme's voice comes from its accent, not from a saturated
// ground. A projector exaggerates any tint it is given, which is the other
// reason these stay faint.
//
// Every palette shipped here satisfies the contrast contract enforced by
// tests/test_palettes.py: readable text and muted ink on the canvas, an accent
// and status colors legible on both the canvas and on `text` (the ground of an
// inverted slide), a line color that is visible but quiet, and a surface that
// stays close to the canvas. User palettes passed to `setup(colors: ..)` are
// deliberately never validated against that contract; it binds only what we
// ship.

// The default light palette: the colors a deck gets when it names none. It is
// deliberately the quietest thing here, so it stays near-neutral and lets the
// content carry the color. The grays are untinted, the accent is a desaturated
// slate blue rather than a saturated primary, and the status pair is muted
// toward amber and brick instead of full-strength signal orange. A deck that
// wants a voice picks one of the schemes below or passes its own dictionary.
#let light = (
  canvas: rgb("#f8f8f7"),
  surface: white,
  accent: rgb("#4a6274"),
  text: rgb("#18181b"),
  muted: rgb("#737373"),
  line: rgb("#e3e3e0"),
  warning: rgb("#96793d"),
  error: rgb("#8a4a3a"),
)

// The light palette's polarity twin. Dark is not a theme: any theme repaints
// itself with this through `setup(colors: ..)`, and polarity-sensitive rules
// derive their branch from the canvas it supplies.
#let dark = (
  canvas: rgb("#16181b"),
  surface: rgb("#1e2125"),
  accent: rgb("#7e97ad"),
  text: rgb("#f2f2f0"),
  muted: rgb("#9a9a96"),
  line: rgb("#33363a"),
  warning: rgb("#b39a5f"),
  error: rgb("#c08476"),
)

// Barely-oat paper with espresso ink and a walnut accent.
#let parchment = (
  canvas: rgb("#faf8f2"),
  surface: rgb("#fdfcf9"),
  accent: rgb("#96603e"),
  text: rgb("#2a2420"),
  muted: rgb("#79695c"),
  line: rgb("#e6e2da"),
  warning: rgb("#9a7d3f"),
  error: rgb("#83493b"),
)

// Cool daylight with the faintest green cast and a dried-sage accent.
#let sage = (
  canvas: rgb("#f7f8f4"),
  surface: rgb("#fbfcfa"),
  accent: rgb("#5c6b54"),
  text: rgb("#252a23"),
  muted: rgb("#6e7466"),
  line: rgb("#dfe2d9"),
  warning: rgb("#9a7d3f"),
  error: rgb("#83493b"),
)

// Faintly warm greige with a muted indigo accent.
#let stone = (
  canvas: rgb("#f8f6f2"),
  surface: rgb("#fcfbf9"),
  accent: rgb("#4a5866"),
  text: rgb("#232529"),
  muted: rgb("#6f6c66"),
  line: rgb("#e2ded6"),
  warning: rgb("#9a7d3f"),
  error: rgb("#83493b"),
)

// Roasted brown-black with a pale wood accent.
#let espresso = (
  canvas: rgb("#1c1714"),
  surface: rgb("#272019"),
  accent: rgb("#b08f76"),
  text: rgb("#f4f0ea"),
  muted: rgb("#9c9082"),
  line: rgb("#3b342c"),
  warning: rgb("#ae9464"),
  error: rgb("#bb8574"),
)

// Moss night with a dried-sage accent.
#let forest = (
  canvas: rgb("#161b16"),
  surface: rgb("#202822"),
  accent: rgb("#93a086"),
  text: rgb("#f1f4ee"),
  muted: rgb("#96a094"),
  line: rgb("#303a31"),
  warning: rgb("#ae9464"),
  error: rgb("#bb8574"),
)

// Blue-gray charcoal warmed by a wood accent.
#let slate = (
  canvas: rgb("#1f2428"),
  surface: rgb("#2a3036"),
  accent: rgb("#b39177"),
  text: rgb("#f1f3f4"),
  muted: rgb("#9ca4a8"),
  line: rgb("#3c444a"),
  warning: rgb("#ae9464"),
  error: rgb("#bb8574"),
)
