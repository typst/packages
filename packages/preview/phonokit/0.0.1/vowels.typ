#import "@preview/cetz:0.4.2": canvas, draw

// Vowel data with relative positions (0-1 scale)
// frontness: 0 = front, 0.5 = central, 1 = back
// height: 1 = close, 0.67 = close-mid, 0.33 = open-mid, 0 = open
// rounded: affects horizontal positioning within minimal pairs
#let vowel-data = (
  "i": (frontness: 0.05, height: 1.00, rounded: false),
  "y": (frontness: 0.05, height: 1.00, rounded: true),
  "ɨ": (frontness: 0.50, height: 1.00, rounded: false),
  "ʉ": (frontness: 0.50, height: 1.00, rounded: true),
  "ɯ": (frontness: 0.95, height: 1.00, rounded: false),
  "u": (frontness: 0.95, height: 1.00, rounded: true),
  "ɪ": (frontness: 0.15, height: 0.85, rounded: false),
  "ʏ": (frontness: 0.25, height: 0.85, rounded: true),
  "ʊ": (frontness: 0.85, height: 0.85, rounded: true),
  "e": (frontness: 0.05, height: 0.67, rounded: false),
  "ø": (frontness: 0.05, height: 0.67, rounded: true),
  "ɘ": (frontness: 0.50, height: 0.67, rounded: false),
  "ɵ": (frontness: 0.50, height: 0.67, rounded: true),
  "ɤ": (frontness: 0.95, height: 0.67, rounded: false),
  "o": (frontness: 0.95, height: 0.67, rounded: true),
  "ə": (frontness: 0.585, height: 0.51, rounded: false),
  "ɛ": (frontness: 0.05, height: 0.34, rounded: false),
  "œ": (frontness: 0.05, height: 0.34, rounded: true),
  "ɜ": (frontness: 0.50, height: 0.34, rounded: false),
  "ɞ": (frontness: 0.50, height: 0.34, rounded: true),
  "ʌ": (frontness: 0.95, height: 0.34, rounded: false),
  "ɔ": (frontness: 0.95, height: 0.34, rounded: true),
  "æ": (frontness: 0.05, height: 0.15, rounded: false),
  "ɐ": (frontness: 0.585, height: 0.18, rounded: false),
  "a": (frontness: 0.05, height: 0.00, rounded: false),
  "ɶ": (frontness: 0.05, height: 0.00, rounded: true),
  "ɑ": (frontness: 0.95, height: 0.00, rounded: false),
  "ɒ": (frontness: 0.95, height: 0.00, rounded: true),
)

// Calculate actual position from relative coordinates
#let get-vowel-position(vowel-info, trapezoid, width, height, offset) = {
  let front = vowel-info.frontness
  let h = vowel-info.height

  // Calculate y coordinate
  let y = -height/2 + (h * height)

  // Interpolate x based on trapezoid shape at this height
  let t = 1 - h  // interpolation factor (0 at top, 1 at bottom)
  let left-x = trapezoid.at(0).at(0) * (1 - t) + trapezoid.at(3).at(0) * t
  let right-x = trapezoid.at(1).at(0) * (1 - t) + trapezoid.at(2).at(0) * t

  let x = 0

  // Front vowels (frontness < 0.4)
  if front < 0.4 {
    // Extreme front (< 0.15): tense vowels like i, e
    if front < 0.15 {
      if vowel-info.rounded {
        // Front rounded: inside (right of left edge)
        x = left-x + offset
      } else {
        // Front unrounded: outside (left of left edge)
        x = left-x - offset
      }
    }
    // Near-front (0.15-0.4): lax vowels like ɪ, ɛ
    // Always positioned inside the trapezoid
    else {
      x = left-x + (front * (right-x - left-x))
    }
  }
  // Back vowels (frontness > 0.6)
  else if front > 0.6 {
    // Extreme back (> 0.85): tense vowels like u, o
    if front > 0.85 {
      if vowel-info.rounded {
        // Back rounded: outside (right of right edge)
        x = right-x + offset
      } else {
        // Back unrounded: inside (left of right edge)
        x = right-x - offset
      }
    }
    // Near-back (0.6-0.85): lax vowels like ʊ
    // Always positioned inside the trapezoid
    else {
      x = left-x + (front * (right-x - left-x))
    }
  }
  // Central vowels
  else {
    // Calculate base central position
    let center-x = left-x + (front * (right-x - left-x))

    // Apply full offset for rounded/unrounded pairs (same as front/back)
    if vowel-info.rounded {
      x = center-x + offset  // Rounded to the right
    } else {
      x = center-x - offset  // Unrounded to the left
    }
  }

  (x, y)
}

// Language vowel inventories
#let language-vowels = (
  "spanish": "aeoiu",
  "portuguese": "iɔeaouɛ",
  "italian": "iɔeaouɛ",
  "english": "iɪaeɛæɑɔoʊuʌə",
  "french": "iœɑɔøeaouɛy",
  "german": "iyʊuɪʏeøoɔɐaɛœ",
  "japanese": "ieaou",
  "mandarin": "iəɤauy",
  "russian": "iɨueoa",
  "arabic": "aiu",
  "all": "iyɨʉɯuɪʏʊeøɘɵɤoəɛœɜɞʌɔæɐaɶɑɒ"
  // Add more languages here or adjust existing inventories
)

// Main vowels function
#let vowels(
  vowel-string,  // Positional parameter (no default to allow positional args)
  lang: none,
  width: 8,
  height: 6,
  rows: 3,  // Only 2 internal horizontal lines
  cols: 2,  // Only 1 vertical line inside trapezoid
  scale: 0.7,  // Scale factor for entire chart
) = {
  // Determine which vowels to plot
  let vowels-to-plot = ""
  let error-msg = none

  // Check if vowel-string is actually a language name
  if vowel-string in language-vowels {
    // It's a language name - use language vowels
    vowels-to-plot = language-vowels.at(vowel-string)
  } else if lang != none {
    // Explicit lang parameter provided
    if lang in language-vowels {
      vowels-to-plot = language-vowels.at(lang)
    } else {
      // Language not available - prepare error message
      let available = language-vowels.keys().join(", ")
      error-msg = [*Error:* Language "#lang" not available. \ Available languages: #available]
    }
  } else if vowel-string != "" {
    // Use as manual vowel specification
    vowels-to-plot = vowel-string
  } else {
    // Nothing specified
    error-msg = [*Error:* Either provide vowel string or language name]
  }

  // If there's an error, display it and return
  if error-msg != none {
    return error-msg
  }

  // Calculate scaled dimensions
  let scaled-width = width * scale
  let scaled-height = height * scale
  let scaled-offset = 0.55 * scale
  let scaled-circle-radius = 0.35 * scale
  let scaled-bullet-radius = 0.09 * scale
  let scaled-font-size = 22 * scale
  let scaled-line-thickness = 0.85 * scale

  canvas({
    import draw: *

    // Define the trapezoidal quadrilateral using scaled dimensions
    let trapezoid = (
      (-scaled-width/2, scaled-height/2.),
      (scaled-width/2., scaled-height/2),
      (scaled-width/2., -scaled-height/2),
      (-scaled-width/10, -scaled-height/2),
    )

    // Draw horizontal grid lines
    for i in range(1, rows) {
      let t = i / rows
      let left-x = trapezoid.at(0).at(0) * (1 - t) + trapezoid.at(3).at(0) * t
      let right-x = trapezoid.at(1).at(0) * (1 - t) + trapezoid.at(2).at(0) * t
      let y = scaled-height/2 - (scaled-height * t)

      line((left-x, y), (right-x, y), stroke: (paint: gray.lighten(30%), thickness: scaled-line-thickness * 1pt))
    }

    // Draw vertical grid lines
    for i in range(1, cols) {
      let t = i / cols
      let top-x = trapezoid.at(0).at(0) * (1 - t) + trapezoid.at(1).at(0) * t
      let bottom-x = trapezoid.at(3).at(0) * (1 - t) + trapezoid.at(2).at(0) * t

      line((top-x, scaled-height/2), (bottom-x, -scaled-height/2), stroke: (paint: gray.lighten(30%), thickness: scaled-line-thickness * 1pt))
    }

    // Draw the outline
    line(..trapezoid, close: true, stroke: (paint: gray.lighten(30%), thickness: scaled-line-thickness * 1pt))

    // Collect vowel positions
    let vowel-positions = ()
    for vowel in vowels-to-plot.clusters() {
      if vowel in vowel-data {
        let vowel-info = vowel-data.at(vowel)
        let pos = get-vowel-position(vowel-info, trapezoid, scaled-width, scaled-height, scaled-offset)
        vowel-positions.push((vowel: vowel, info: vowel-info, pos: pos))
      }
    }

    // Draw bullets between minimal pairs (same frontness/height, different rounding)
    for i in range(vowel-positions.len()) {
      for j in range(i + 1, vowel-positions.len()) {
        let v1 = vowel-positions.at(i)
        let v2 = vowel-positions.at(j)

        // Check if they form a minimal pair
        let same-front = v1.info.frontness == v2.info.frontness
        let same-height = v1.info.height == v2.info.height
        let diff-round = v1.info.rounded != v2.info.rounded

        if same-front and same-height and diff-round {
          // Draw bullet at midpoint between vowels
          let mid-x = (v1.pos.at(0) + v2.pos.at(0)) / 2
          let mid-y = (v1.pos.at(1) + v2.pos.at(1)) / 2
          circle((mid-x, mid-y), radius: scaled-bullet-radius, fill: black)
        }
      }
    }

    // Plot vowels with white background circles
    for vp in vowel-positions {
      // Draw white circle to cover grid lines
      circle(vp.pos, radius: scaled-circle-radius, fill: white, stroke: none)
      // Draw vowel on top
      content(vp.pos, text(size: scaled-font-size * 1pt, font: "Charis SIL", vp.vowel))
    }
  })
}
