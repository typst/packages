// Render segment displays.

#import "../util.typ": *
#import "../draw.typ": *

/// Maps from character to which bits are activated for it.
/// in a segment display.
///
/// This is a bijection:
/// Ambiguous characters are assigned exactly one
/// representant.
/// The tie-breaking rule is that
/// numbers
/// over latin uppercase alphabet
/// over latin lowercase alphabet
/// over special characters such as punctuation
/// over other scripts.
#let lookup = (
  // t  --------+
  // m  -------+|
  // b  ------+||
  // tl -----+|||
  // tr ----+||||
  // bl ---+|||||
  // br --+||||||
  // dot-+|||||||
  //     vvvvvvvv
  "0": 0b01111101,
  "1": 0b01010000,
  "2": 0b00110111,
  "3": 0b01010111,
  "4": 0b01011010,
  "5": 0b01001111,
  "6": 0b01101111,
  "7": 0b01011001,
  "8": 0b01111111,
  "9": 0b01011111,

  // alphabetic
  "A": 0b01111011,
  "C": 0b00101101,
  "E": 0b00101111,
  "F": 0b00101011,
  "H": 0b01111010,
  "J": 0b01110101,
  "L": 0b00101100,
  "N": 0b01111001,
  "P": 0b00111011,
  "Q": 0b11111101,
  "U": 0b01111100,
  "Y": 0b00111010,

  // lowercase alphabetic
  "a": 0b01110111,
  "b": 0b01101110,
  "c": 0b00100110,
  "d": 0b01110110,
  "h": 0b01101010,
  "l": 0b01101100,
  "n": 0b01100010,
  "o": 0b01100110,
  "q": 0b01011011,
  "r": 0b00100010,
  "t": 0b00101010,
  "u": 0b01100100,

  // special
  " ": 0b00000000,
  "-": 0b00000010,
  "/": 0b00110010,
  "\\": 0b01001010,
  "=": 0b00000110,
  "]": 0b01010101,
  "_": 0b00000100,
  "?": 0b00110011,
  "^": 0b00011001,
  ">": 0b01000110,
  "'": 0b00001000,
  "\"": 0b00011000,
  "`": 0b00010001,
  "´": 0b00001001,
  ".": 0b10000000,
  "@": 0b00111111,
  "°": 0b00011011,

  // greek characters
  "λ": 0b01110011,
)

/// Maps from character to best-effort representation
/// if the character is not already defined in `lookup`.
#let fallback = (
  "B": "8",
  "D": "0",
  "G": "6",
  "I": "1",
  "O": "0",
  "R": "A",
  "S": "5",
  "V": "U",
  "W": "LU",
  "X": "H",
  "Z": "2",

  "e": "6",
  "f": "F",
  "g": "9",
  "i": "I",
  "j": "J",
  "p": "P",
  "s": "5",
  "v": "u",
  "x": "H",
  "y": "Y",
  "z": "Z",

  "(": "C",
  ")": "]",
  "[": "C",
  "|": "1",
  "<": "c",
  "&": "6",
  ":": "=",
  "%": "°/o",
  "$": "S",
  "+": "-t",

  "α": "o=",
)

/// Takes the `n`th bit out of `bits`,
/// returning a boolean.
/// `n` starts from 0:
/// The first bit is `n = 0`,
/// the second one is `n = 1` and so on.
#let _bit(bits, n) = {
  bits.bit-rshift(n).bit-and(1) == 1
}

/// Display one particular bit combination.
/// Use `lookup` to, well, look up which character
/// belongs to which bit combination this function expects.
#let direct(
  bits,
  bottom-left: (0, 0),
  top-right: (1, 2),
  // How much space there is to the next character.

  off: round-stroke() + (paint: gamut.sample(30%)),
  on: round-stroke() + (paint: fg, thickness: 0.15em),
) = group({
  let (bl, tr) = (bottom-left, top-right)

  // Derive the rest of the positions
  let br = (bl, "-|", tr) // Bottom right
  let tl = (bl, "|-", tr) // Top left

  let c = (bl, 50%, tr) // Center
  let cl = (bl, "|-", c) // Center left
  let cr = (c, "-|", tr) // Center right

  let l(start, end, cut: 20%) = line(
    (start, cut, end),
    (start, 100% - cut, end),
  )

  let leds = (
    () => l(tl, tr),
    () => l(cl, cr),
    () => l(bl, br),
    () => l(tl, cl),
    () => l(tr, cr),
    () => l(cl, bl),
    () => l(cr, br),
    () => circle(br, radius: 0.025),
  )
  leds
    .enumerate()
    .map(((n, led)) => {
      let accent = if _bit(bits, n) {
        on
      } else {
        off
      }

      set-style(
        fill: accent.paint,
        stroke: accent,
      )
      led()
    })
    .join()
})

/// Uses several segment displays to show the given text.
#let run(
  /// Text to render.
  /// Must be a string.
  /// Will panic if the chosen segment display
  /// cannot display a character in the text.
  body,
  /// Size of one character.
  size: (1, 2),
  /// Horizontal and vertical space between characters.
  space: (0.5, 0.75),

  ..args,
) = canvas({
  let (width, height) = size
  let (space-h, space-v) = space
  // Logical position in the text at the moment.
  let (x, y) = (0, 0)

  for ch in body.clusters() {
    if ch == "\n" {
      x = 0
      y -= 1
      continue
    }

    let bottom-left = (
      (width + space-h) * x,
      (height + space-v) * y,
    )
    direct(
      lookup.at(ch),
      bottom-left: bottom-left,
      top-right: (rel: size, to: bottom-left),
      ..args,
    )

    x += 1
  }
})
