// Top-level configuration
// -----------------------

// DO NOT change keys, just values
// This is for general document tuning
// For fine tuning, see "ELEMENTS.typ"
#let CONFIG = (
  // document main language
  lang: "en",
  // document paper
  paper: "us-trade",
  // body of text (main size)
  size: 11pt,
  // document font scheme: 3 serif vars + 1 sans + 1 mono
  font: (
    // body of text (main font), use a serif family
    body: "EB Garamond",
    // variant serif font for other elements
    serif: "Libertinus Serif",
    // small element font: footnote mark/entry, captions, etc.
    details: "Libertinus Serif",
    // sans font
    sans: "Fira Sans",
    // mono font
    mono: "Inconsolata",
  ),
  color: (
    // theme - reserved for seldom use in key opaque elements
    theme: color.hsv(240deg,  75%,  33%, 100%), // dark indigo,
    // page - page backgroung, usually opaque sepia or white
    pages: color.hsv( 50deg,  18%, 100%, 100%), // sepia
    // cover - text foreground, adjust according to cover art
    cover: color.hsv(240deg,  75%,  33%, 100%), // dark indigo,
  ),
  num-sep: (
    eqn: ".", // for equation (1.1)
    fig: ".", // for figure 1.1, table 1.1
    exh: "\u{2013}", // for exhibit 1–1
    pro: "\u{2013}", // for problem 1–1
  ),
)

#let scaled(
  // How many notches larger (+) or smaller (-)
  // every ±4 notches doubles/halvens the size
  notches,
) = {
  // base = ∜2 ~ 1.189 ()
  let b = calc.pow(2, 0.25) 
  calc.round(
    calc.pow(b, notches),
    digits: 4,
  ) * 100%
}

#let resized(
  // See @scaled
  notches,
) = {
  CONFIG.size * scaled(notches)
}

