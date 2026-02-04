#import "@preview/cetz:0.4.2": canvas, draw

// Consonant data with place, manner, and voicing
// place: 0=bilabial, 1=labiodental, 2=dental, 3=alveolar, 4=postalveolar
//        5=retroflex, 6=palatal, 7=velar, 8=uvular, 9=pharyngeal, 10=glottal
// manner: 0=plosive, 1=nasal, 2=trill, 3=tap/flap, 4=fricative,
//         5=lateral fricative, 6=approximant, 7=lateral approximant
#let consonant-data = (
  // Plosives (row 0)
  "p": (place: 0, manner: 0, voicing: false),
  "b": (place: 0, manner: 0, voicing: true),
  "t": (place: 3, manner: 0, voicing: false),
  "d": (place: 3, manner: 0, voicing: true),
  "ʈ": (place: 5, manner: 0, voicing: false),
  "ɖ": (place: 5, manner: 0, voicing: true),
  "c": (place: 6, manner: 0, voicing: false),
  "ɟ": (place: 6, manner: 0, voicing: true),
  "k": (place: 7, manner: 0, voicing: false),
  "ɡ": (place: 7, manner: 0, voicing: true),
  "g": (place: 7, manner: 0, voicing: true), 
  "q": (place: 8, manner: 0, voicing: false),
  "ɢ": (place: 8, manner: 0, voicing: true),
  "ʔ": (place: 10, manner: 0, voicing: false),

  // Nasals (row 1)
  "m": (place: 0, manner: 1, voicing: true),
  "ɱ": (place: 1, manner: 1, voicing: true),
  "n": (place: 3, manner: 1, voicing: true),
  "ɳ": (place: 5, manner: 1, voicing: true),
  "ɲ": (place: 6, manner: 1, voicing: true),
  "ŋ": (place: 7, manner: 1, voicing: true),
  "ɴ": (place: 8, manner: 1, voicing: true),

  // Trills (row 2)
  "ʙ": (place: 0, manner: 2, voicing: true),
  "r": (place: 3, manner: 2, voicing: true),
  "ʀ": (place: 8, manner: 2, voicing: true),

  // Tap or Flap (row 3)
  "ⱱ": (place: 1, manner: 3, voicing: true),
  "ɾ": (place: 3, manner: 3, voicing: true),
  "ɽ": (place: 5, manner: 3, voicing: true),

  // Fricatives (row 4)
  "ɸ": (place: 0, manner: 4, voicing: false),
  "β": (place: 0, manner: 4, voicing: true),
  "f": (place: 1, manner: 4, voicing: false),
  "v": (place: 1, manner: 4, voicing: true),
  "θ": (place: 2, manner: 4, voicing: false),
  "ð": (place: 2, manner: 4, voicing: true),
  "s": (place: 3, manner: 4, voicing: false),
  "z": (place: 3, manner: 4, voicing: true),
  "ʃ": (place: 4, manner: 4, voicing: false),
  "ʒ": (place: 4, manner: 4, voicing: true),
  "ʂ": (place: 5, manner: 4, voicing: false),
  "ʐ": (place: 5, manner: 4, voicing: true),
  "ç": (place: 6, manner: 4, voicing: false),
  "ʝ": (place: 6, manner: 4, voicing: true),
  "x": (place: 7, manner: 4, voicing: false),
  "ɣ": (place: 7, manner: 4, voicing: true),
  "χ": (place: 8, manner: 4, voicing: false),
  "ʁ": (place: 8, manner: 4, voicing: true),
  "ħ": (place: 9, manner: 4, voicing: false),
  "ʕ": (place: 9, manner: 4, voicing: true),
  "h": (place: 10, manner: 4, voicing: false),
  "ɦ": (place: 10, manner: 4, voicing: true),

  // Lateral fricatives (row 5)
  "ɬ": (place: 3, manner: 5, voicing: false),
  "ɮ": (place: 3, manner: 5, voicing: true),

  // Approximants (row 6)
  "ʋ": (place: 1, manner: 6, voicing: true),
  "ɹ": (place: 3, manner: 6, voicing: true),
  "ɻ": (place: 5, manner: 6, voicing: true),
  "j": (place: 6, manner: 6, voicing: true),
  "ɰ": (place: 7, manner: 6, voicing: true),

  // Lateral approximants (row 7)
  "l": (place: 3, manner: 7, voicing: true),
  "ɭ": (place: 5, manner: 7, voicing: true),
  "ʎ": (place: 6, manner: 7, voicing: true),
  "ʟ": (place: 7, manner: 7, voicing: true),
)

// Column labels (places of articulation)
#let places = (
  "Bilabial",
  "Labiodental",
  "Dental",
  "Alveolar",
  "Postalveolar",
  "Retroflex",
  "Palatal",
  "Velar",
  "Uvular",
  "Pharyngeal",
  "Glottal",
)

// Row labels (manners of articulation)
#let manners = (
  "Plosive",
  "Nasal",
  "Trill",
  "Tap or Flap",
  "Fricative",
  "Lateral fricative",
  "Approximant",
  "Lateral approximant",
)

// Language consonant inventories
#let language-consonants = (
  "all": "pbtdʈɖcɟkɡqɢʔmɱnɳɲŋɴʙrʀⱱɾɽɸβfvθðszʃʒʂʐçʝxɣχʁħʕhɦɬɮʋɹɻjɰlɭʎʟ",
  "english": "pbmnŋtdkɡfvθðszʃʒhlɹj",
  "spanish": "pbmnɲtdkɡfθsxlrɾj",
  "french": "pbmnɲtdkɡfrvszʃʒlj",
  "german": "pbmntdkɡfvszʃʒçxhʁlj",
  "italian": "pbmnɲtdkɡfvszʃʎlrj",
  "japanese": "pbmnɲtdkɡçɸsʃzʒhɾj",
  "portuguese": "pbmnɲtdkɡfvszʃʒʎxlɾj",
  "russian": "pbmntdkɡfvszʃʒxlrj",
  "arabic": "btdkqʔmnfvðszʃxɣħʕhlrj",
)

// Main consonants function
#let consonants(
  consonant-string,
  lang: none,
  cell-width: 1.8,
  cell-height: 0.9,
  label-width: 3.5,
  label-height: 1.2,
  scale: 0.7,
) = {
  // Determine which consonants to plot
  let consonants-to-plot = ""
  let error-msg = none

  // Check if consonant-string is actually a language name
  if consonant-string in language-consonants {
    consonants-to-plot = language-consonants.at(consonant-string)
  } else if lang != none {
    if lang in language-consonants {
      consonants-to-plot = language-consonants.at(lang)
    } else {
      let available = language-consonants.keys().join(", ")
      error-msg = [*Error:* Language "#lang" not available. \ Available languages: #available]
    }
  } else if consonant-string != "" {
    consonants-to-plot = consonant-string
  } else {
    error-msg = [*Error:* Either provide consonant string or language name]
  }

  // If there's an error, display it and return
  if error-msg != none {
    return error-msg
  }

  // Calculate scaled dimensions
  let scaled-cell-width = cell-width * scale
  let scaled-cell-height = cell-height * scale
  let scaled-label-width = label-width * scale
  let scaled-label-height = label-height * scale
  let scaled-font-size = 18 * scale
  let scaled-label-font-size = 9 * scale
  let scaled-circle-radius = 0.3 * scale
  let scaled-line-thickness = 0.8 * scale

  let num-cols = places.len()
  let num-rows = manners.len()

  canvas({
    import draw: *

    // Calculate total dimensions
    let total-width = scaled-label-width + (num-cols * scaled-cell-width)
    let total-height = scaled-label-height + (num-rows * scaled-cell-height)

    // Draw column headers (places of articulation)
    for (i, place) in places.enumerate() {
      let x = scaled-label-width + (i * scaled-cell-width) + (scaled-cell-width / 2)
      let y = total-height / 2 - (scaled-label-height / 2)

      content((x, y), text(size: scaled-label-font-size * 1pt, place), anchor: "center")
    }

    // Draw row headers (manners of articulation)
    for (i, manner) in manners.enumerate() {
      let x = scaled-label-width - 0.2
      let y = total-height / 2 - scaled-label-height - (i * scaled-cell-height) - (scaled-cell-height / 2)

      content((x, y), text(size: scaled-label-font-size * 1pt, manner), anchor: "east")
    }

    // Draw grid lines
    // Vertical lines
    for i in range(num-cols + 1) {
      let x = scaled-label-width + (i * scaled-cell-width)
      let y1 = total-height / 2 - scaled-label-height
      let y2 = -total-height / 2
      line((x, y1), (x, y2), stroke: (paint: gray.lighten(20%), thickness: scaled-line-thickness * 1pt))
    }

    // Horizontal lines
    for i in range(num-rows + 1) {
      let y = total-height / 2 - scaled-label-height - (i * scaled-cell-height)
      let x1 = scaled-label-width
      let x2 = total-width
      line((x1, y), (x2, y), stroke: (paint: gray.lighten(20%), thickness: scaled-line-thickness * 1pt))
    }

    // Gray out impossible consonant cells
    // Format: (row, col, half) where half can be "full", "voiced", "voiceless"
    let impossible-cells = (
      // Lateral fricative (row 5)
      (5, 0, "full"), (5, 1, "full"), (5, 9, "full"), (5, 10, "full"),
      // Lateral approximant (row 7)
      (7, 0, "full"), (7, 1, "full"), (7, 9, "full"), (7, 10, "full"),
      // Trill (row 2)
      (2, 7, "full"), (2, 10, "full"),
      // Tap or flap (row 3)
      (3, 7, "full"), (3, 10, "full"),
      // Approximant (row 6)
      (6, 10, "full"),
      // Plosive (row 0) - voiced side only
      (0, 9, "voiced"), (0, 10, "voiced"),
      // Nasal (row 1)
      (1, 9, "full"), (1, 10, "full"),
    )

    for (row, col, half) in impossible-cells {
      let cell-x = scaled-label-width + (col * scaled-cell-width)
      let cell-y = total-height / 2 - scaled-label-height - (row * scaled-cell-height)

      if half == "full" {
        // Fill entire cell
        rect(
          (cell-x, cell-y),
          (cell-x + scaled-cell-width, cell-y - scaled-cell-height),
          fill: gray.lighten(70%),
          stroke: (paint: gray.lighten(20%), thickness: scaled-line-thickness * 1pt)
        )
      } else if half == "voiced" {
        // Fill right half of cell (voiced side)
        let mid-x = cell-x + (scaled-cell-width / 2)
        rect(
          (mid-x, cell-y),
          (cell-x + scaled-cell-width, cell-y - scaled-cell-height),
          fill: gray.lighten(70%),
          stroke: (paint: gray.lighten(20%), thickness: scaled-line-thickness * 1pt)
        )
      } else if half == "voiceless" {
        // Fill left half of cell (voiceless side)
        let mid-x = cell-x + (scaled-cell-width / 2)
        rect(
          (cell-x, cell-y),
          (mid-x, cell-y - scaled-cell-height),
          fill: gray.lighten(70%),
          stroke: (paint: gray.lighten(20%), thickness: scaled-line-thickness * 1pt)
        )
      }
    }

    // Collect consonants by cell
    let cell-consonants = (:)
    for consonant in consonants-to-plot.clusters() {
      if consonant in consonant-data {
        let info = consonant-data.at(consonant)
        let key = str(info.place) + "-" + str(info.manner)

        if key not in cell-consonants {
          cell-consonants.insert(key, (voiceless: none, voiced: none))
        }

        if info.voicing {
          cell-consonants.at(key).voiced = consonant
        } else {
          cell-consonants.at(key).voiceless = consonant
        }
      }
    }

    // Draw consonants in cells
    for (key, pair) in cell-consonants {
      let parts = key.split("-")
      let col = int(parts.at(0))
      let row = int(parts.at(1))

      let cell-x = scaled-label-width + (col * scaled-cell-width)
      let cell-y = total-height / 2 - scaled-label-height - (row * scaled-cell-height)
      let cell-center-x = cell-x + (scaled-cell-width / 2)
      let cell-center-y = cell-y - (scaled-cell-height / 2)

      // Offset for left/right positioning
      let offset = scaled-cell-width * 0.25

      if pair.voiceless != none {
        let pos = (cell-center-x - offset, cell-center-y)
        circle(pos, radius: scaled-circle-radius, fill: white, stroke: none)
        content(pos, text(size: scaled-font-size * 1pt, font: "Charis SIL", pair.voiceless))
      }

      if pair.voiced != none {
        let pos = (cell-center-x + offset, cell-center-y)
        circle(pos, radius: scaled-circle-radius, fill: white, stroke: none)
        content(pos, text(size: scaled-font-size * 1pt, font: "Charis SIL", pair.voiced))
      }
    }
  })
}
