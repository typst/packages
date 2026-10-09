// Default palette: color name → color.
//
// Sticker colors follow the common "official" shades, chosen so that white,
// yellow and orange stay clearly distinct from each other and from red. The
// second group is used by the megaminx; `black` is for Square-1 schemes with
// a black top. `hidden` is not a sticker color: it is what masked stickers
// are drawn with.
#let colors = (
  white: rgb("#ffffff"),
  yellow: rgb("#ffd500"),
  orange: rgb("#ff5800"),
  red: rgb("#b71234"),
  green: rgb("#009b48"),
  blue: rgb("#0046ad"),
  grey: rgb("#595959"),
  purple: rgb("#7b1fa2"),
  pink: rgb("#ff69b4"),
  lime: rgb("#9acd32"),
  lightblue: rgb("#6ec6ff"),
  beige: rgb("#f0dcb4"),
  black: luma(25),
  hidden: luma(170),
)
