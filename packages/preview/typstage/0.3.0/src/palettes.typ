// Colour as a thing of its own: the palettes, the contrast contract they are
// held to, and the derivation an inverted slide uses.
//
// A theme says how a slide is *built*; a palette says what colour it is. The
// two vary separately: the classroom look is still the classroom look in a
// darkened room. That is why there is no second dark theme for every design
// here. Darkness is a palette, not a design.
//
// One rule shapes this file, and it is the reason the contract exists at all:
// no colour is ever guessed from the lightness of another. A muted sage such
// as rgb("#aebdb3") reads as "light" to a luminance rule, yet white on it
// measures 1.96 to 1 by the arithmetic below, far under the 4.5 to 1 that body
// text wants. What `invert-palette` derives, it derives from *two* given
// colours, the ground and the text, never from one alone.

/// One sRGB channel, linearised the way WCAG 2 defines it.
///
/// The value comes in as a ratio from 0 to 1, not as a byte.
#let kanal(c) = if c <= 0.03928 { c / 12.92 } else {
  calc.pow((c + 0.055) / 1.055, 2.4)
}

/// Relative luminance of a colour, WCAG 2.
///
/// Deliberately not `color.luma`. That one turns a color into a grey and hands
/// back a gamma-encoded value, 72.64 percent for the sage above, where the
/// relative luminance below is 0.4865. The first number answers "does this
/// look light", which it does; the second answers "can this be read on it",
/// and that is the question a contrast contract asks.
#let leuchtdichte(c) = {
  let (r, g, b) = rgb(c).components(alpha: false).map(x => kanal(x / 100%))
  0.2126 * r + 0.7152 * g + 0.0722 * b
}

/// The WCAG contrast ratio of two colours, a number from 1 to 21.
///
/// ```typ
/// #contrast(black, white)                 // 21
/// #contrast(rgb("#767b84"), white)        // 4.2539
/// ```
///
/// The reference numbers WCAG 2 names: 4.5 for body text, 3.0 for large text
/// and for lines, bars and other shapes that are not text. The package uses
/// them in that sense in `palette-report`.
///
/// Alpha is ignored. A translucent colour is measured as if it were opaque,
/// which is not what it looks like on the slide.
#let contrast(a, b) = {
  let (x, y) = (leuchtdichte(a), leuchtdichte(b))
  (calc.max(x, y) + 0.05) / (calc.min(x, y) + 0.05)
}

/// The eight entries a palette may carry.
#let palette-keys = (
  "paper", "ink", "strong", "accent", "muted", "surface", "border", "inverted",
)

/// Refuse a palette with an entry that is not one of the eight.
///
/// Without this, `palette: (acent: blue)` would do nothing at all and say
/// nothing about it.
#let palette-pruefen(p) = {
  assert(type(p) == dictionary, message:
    "typstage: palette takes a dictionary of colours, not " + str(type(p)))
  for k in p.keys() {
    assert(k in palette-keys, message:
      "typstage: a palette has no entry \"" + k + "\". It takes "
      + palette-keys.join(", ") + ".")
    // Nur die Schluessel wurden geprueft, die Werte nicht. Ein
    // `(accent: "blau")` brach dann tief drinnen mit "color string contains
    // non-hexadecimal letters" ab, und der Nutzer sah in die Innereien.
    if k == "inverted" {
      // Der einzige Eintrag, der keine Farbe ist: er sagt, ob die Palette
      // bereits die umgedrehte ist.
      assert(type(p.inverted) == bool, message:
        "typstage: palette.inverted says whether this palette is already the "
        + "turned-around one: true or false. Not " + repr(p.inverted))
    } else {
      assert(type(p.at(k)) == color, message:
        "typstage: palette." + k + " is a colour, written as a colour and not "
        + "as a string: `rgb(\"#1a3d5c\")`, `black`, `luma(40%)`. Not "
        + repr(p.at(k)))
    }
  }
  p
}

/// The palette an inverted slide is set in.
///
/// The ground becomes the palette's text colour and the text becomes its
/// ground. `muted`, `surface` and `border` are mixed from those two, so they
/// keep their relation to both. `strong` and `accent` carry over unchanged:
/// the accent is the deck's signal colour and must not turn into a different
/// colour halfway through the talk.
///
/// The mixing happens in sRGB, not in the Oklab space `color.mix` would take
/// by default. Measured on a palette with pure black ink, at the same
/// percentages as below: in Oklab the derived surface comes out as #010101 and
/// the derived border as #151515, which is 1.15 to 1 against the ground, a
/// hairline nobody sees. In sRGB the same two are #131313 and #313131, and the
/// border measures 1.62 to 1. Oklab compresses hard near black, and that is
/// exactly where a derived dark palette lives.
///
/// The percentages were set by measurement, not by eye. At 24 percent the
/// derived border measures between 1.51 and 1.84 to 1 against the derived
/// ground across the five bundled palettes, and the tightest of those is the
/// dark palette. 42 percent for the muted grey holds it between 6.47 and
/// 10.08, well clear of the 4.5 the contract wants.
#let invert-palette(p) = {
  let grund = p.ink
  let satz = p.paper
  (
    paper: grund,
    ink: satz,
    muted: satz.mix((grund, 42%), space: rgb),
    surface: grund.mix((satz, 8%), space: rgb),
    border: grund.mix((satz, 24%), space: rgb),
    strong: p.strong,
    accent: p.accent,
    inverted: not p.at("inverted", default: false),
  )
}

/// The contract, as data: pair, floor, and what the pair is for.
///
/// `accent on ink` is the odd one and the reason it is in here: on an inverted
/// slide the ink is what ends up behind the accent, so an accent tuned for one
/// ground alone would go dim there without a word.
///
/// `accent on black` is the second of that kind, and its ground is not a role
/// at all: `grund` names a colour outright. The full-screen clock is black
/// from edge to edge whatever the palette says, and its overtime digits are
/// set in the accent. Without this pair a palette with a deep accent would
/// pass everything here and still leave a room full of people squinting at a
/// number they cannot read.
#let vertrag = (
  (a: "ink", b: "paper", min: 4.5, was: "body text on the slide"),
  (a: "ink", b: "surface", min: 4.5, was: "body text in a card"),
  (a: "muted", b: "paper", min: 4.5, was: "footer, subtitle, running head"),
  (a: "accent", b: "paper", min: 3.0, was: "rules, progress bar, marker"),
  (a: "accent", b: "ink", min: 3.0, was: "the same on an inverted slide"),
  (a: "accent", b: "black", grund: black, min: 3.0,
   was: "the overtime of the full-screen clock, which stands on black"),
  (a: "border", b: "paper", min: 1.2, was: "hairlines"),
)

/// Measure a palette against the contrast contract and report every pair.
///
/// ```typ
/// #for f in palette-report(palettes.dark) [
///   #f.pair: #calc.round(f.ratio, digits: 2) (wants #f.min) #f.ok \
/// ]
/// ```
///
/// One dictionary per pair, with `pair`, `ratio`, `min`, `ok` and `role`. It
/// only measures and never changes a colour.
///
/// This is a report, not a gate. Only the five bundled palettes are actually
/// held to the contract, by an assertion in this file; a palette written in a
/// deck faces no such check, and none of the five bundled *themes* does
/// either. Four of the five do not pass it, and that is deliberate rather than
/// overlooked. See the manual.
#let palette-report(p) = vertrag.map(v => {
  // `grund` is a colour named outright, for a ground that is not a role of the
  // palette. Only `accent on black` uses it so far.
  let hinter = v.at("grund", default: none)
  let r = contrast(p.at(v.a), if hinter == none { p.at(v.b) } else { hinter })
  (pair: v.a + " on " + v.b, ratio: r, min: v.min, ok: r >= v.min, role: v.was)
})

/// The bundled palettes.
///
/// Five, one per colour world the package already had, and each of them
/// composes with every theme: `themes.lesson` in `palettes.dark` is still the
/// lesson design, only dark.
///
/// - `light` is exactly the default theme's colours, so
///   `themes.default` with it is a no-op.
/// - `mono` is `themes.plain`'s greyscale, with two greys moved so it passes
///   the contract.
/// - `textbook` is `themes.lesson`'s measured textbook colours, with `muted`
///   moved for the same reason.
/// - `parchment` is `themes.editorial`'s laid paper, with `accent` and `muted`
///   moved for the same reason.
/// - `dark` is `themes.night`'s dark ground with a deeper accent, because
///   night's own cyan does not survive an inverted slide.
///
/// The six numbers that were moved, and why, are in the comments below.
#let palettes = (
  // The default look. Not a colour of it is changed, so this palette is the
  // one that changes nothing.
  light: (
    paper: rgb("#fafafa"), ink: black, strong: rgb("#23303f"),
    accent: rgb("#eb5e28"), muted: luma(45%), surface: white,
    border: luma(84%), inverted: false,
  ),

  // Greyscale, the plain theme's world. Two changes against `themes.plain`.
  // Its muted grey is luma(55%) and measures 3.35 to 1 on white, under the
  // 4.5 that a footer wants; luma(45%) measures 4.76. And its accent equals
  // its strong, luma(12%), which measures 1.27 to 1 on black and would be
  // gone on an inverted slide; luma(40%) measures 5.74 on white and 3.66 on
  // black, so it holds on both grounds. That window is narrow for a grey:
  // anything readable on white and on black has to sit in the middle.
  mono: (
    paper: white, ink: black, strong: luma(12%), accent: luma(40%),
    muted: luma(45%), surface: white, border: luma(86%), inverted: false,
  ),

  // The German maths textbook, measured for `themes.lesson` from a sample
  // page of "Fundamente der Mathematik". Vermilion for "this you must know",
  // cyan blue for "this is what it looks like", and the warm tint of the note
  // box. One change: the theme's muted #767b84 measures 4.25 to 1 on white,
  // and the running header sets the slide number in it. #6f747d is the same
  // grey seven points darker in every channel and measures 4.70.
  textbook: (
    paper: white, ink: rgb("#16181c"), strong: rgb("#c1361c"),
    accent: rgb("#2b7fb8"), muted: rgb("#6f747d"), surface: rgb("#fdf6ee"),
    border: rgb("#f0e2d2"), inverted: false,
  ),

  // Laid paper and an old-style serif, the editorial world. Two changes. The
  // theme's accent #b4894a measures 2.84 to 1 on its paper, under the 3.0 a
  // hairline wants; #9a6f2f measures 4.01. And its muted #8a7f70 measures
  // 3.51 where the byline stands; #736858 measures 4.88. Both stay the same
  // hue, only deeper.
  parchment: (
    paper: rgb("#f7f2e6"), ink: rgb("#2a2622"), strong: rgb("#7b2d26"),
    accent: rgb("#9a6f2f"), muted: rgb("#736858"), surface: rgb("#fffdf7"),
    border: rgb("#ded2ba"), inverted: false,
  ),

  // The dimmed room. One change against `themes.night`, and it is the finding
  // this contract was built to catch: night's cyan #5ec8f2 measures 9.77 to 1
  // on the dark ground, which is why it glows there, but only 1.59 to 1 on
  // night's own ink, which is the ground an inverted slide puts behind it. Any
  // colour that holds on both has to sit between roughly 0.13 and 0.23 in
  // relative luminance; #5ec8f2 sits at 0.52. #2b8ab5 measures 4.79 on the
  // dark ground and 3.24 on the light one. It does not glow, and that is the
  // price of the guarantee. `themes.night` keeps its own cyan.
  dark: (
    paper: rgb("#0f1319"), ink: rgb("#e6ebf2"), strong: rgb("#2c3644"),
    accent: rgb("#2b8ab5"), muted: rgb("#8f9bab"), surface: rgb("#1a212b"),
    border: rgb("#2e3947"), inverted: true,
  ),
)

// The contract, enforced. Runs once when this module is loaded, over each
// bundled palette and over its inverted form, so a colour changed here cannot
// reach a deck without the arithmetic having seen it.
//
// In Typst rather than in a test script of its own, for two reasons. The
// package has no test chain, and one that nobody runs before a release is
// worse than none. And the check has to measure what *Typst* produced: the
// derived colours above come out of `color.mix`, and re-implementing that in
// another language would be the likeliest place for the two to disagree.
//
// What it costs, measured: it is one pass of arithmetic over 5 palettes times
// 2 forms times 7 pairs. Ten builds of the `theme-default` deck, three rounds
// alternating with the version before this file existed, came to 0.196 to
// 0.198 seconds per build without it and 0.198 to 0.201 with it. That is
// inside the spread of the measurement, not a cost that shows.
#let vertrag-geprueft = {
  let pruefen(name, p) = {
    for f in palette-report(p).filter(f => not f.ok) {
      assert(false, message: "typstage: palettes." + name + " misses the "
        + "contrast contract. " + f.pair + " measures "
        + str(calc.round(f.ratio, digits: 2)) + " to 1, and " + f.role
        + " wants at least " + str(f.min) + " to 1.")
    }
  }
  for (name, p) in palettes.pairs() {
    pruefen(name, p)
    pruefen(name + " inverted", invert-palette(p))
  }
}
