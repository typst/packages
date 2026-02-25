#import "@preview/cetz:0.4.2": canvas, draw
#import "ipa.typ": ipa-to-unicode
#import "_config.typ": phonokit-font

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
  "w": (place: 0, manner: 6, voicing: true), // labiovelar, shown under bilabial
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

// Aspirated plosive data (shown in separate row when aspirated: true)
#let aspirated-plosive-data = (
  // Aspirated plosives (voiceless only - aspiration is contrastive with plain voiceless)
  "pʰ": (place: 0, voicing: false),
  "tʰ": (place: 3, voicing: false),
  "ʈʰ": (place: 5, voicing: false),
  "cʰ": (place: 6, voicing: false),
  "kʰ": (place: 7, voicing: false),
  "qʰ": (place: 8, voicing: false),
)

// Affricate data (shown in separate row when affricates: true)
// These appear after fricatives in the chart
// Note: Displayed without tie bars since the row label makes it clear they're affricates
#let affricate-data = (
  // Labiodental affricates
  "pf": (place: 1, voicing: false),
  "bv": (place: 1, voicing: true),
  // Alveolar affricates
  "ts": (place: 3, voicing: false),
  "dz": (place: 3, voicing: true),
  // Postalveolar affricates
  "tʃ": (place: 4, voicing: false),
  "dʒ": (place: 4, voicing: true),
  // Retroflex affricates
  "ʈʂ": (place: 5, voicing: false),
  "ɖʐ": (place: 5, voicing: true),
  // Alveolo-palatal affricates
  "tɕ": (place: 4, voicing: false), // Use postalveolar column
  "dʑ": (place: 4, voicing: true),
)

// Aspirated affricate data (shown when both affricates: true AND aspirated: true)
#let aspirated-affricate-data = (
  // Aspirated affricates (voiceless only)
  "tsʰ": (place: 3, voicing: false),
  "tʃʰ": (place: 4, voicing: false),
  "ʈʂʰ": (place: 5, voicing: false),
  "tɕʰ": (place: 4, voicing: false), // Alveolo-palatal
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
  "all": "pbtdʈɖcɟkɡqɢʔmɱnɳɲŋɴʙrʀⱱɾɽɸβfvθðszʃʒʂʐçʝxɣχʁħʕhɦɬɮʋɹɻjɰwlɭʎʟ",
  "english": "pbmnŋtdkɡfvθðszʃʒhlɹwj",
  "spanish": "pbmnɲtdkɡfθsxlrɾj",
  "french": "pbmnɲtdkɡfrvszʃʒljw",
  "german": "pbmntdkɡfvszʃʒçxhʁlj",
  "italian": "pbmnɲtdkɡfvszʃʎlrj",
  "japanese": "pbmnɲtdkɡçɸsʃzʒhɾj",
  "portuguese": "pbmnɲtdkɡfvszʃʒʎxlɾjw",
  "russian": "pbmntdkɡfvszʃʒxlrj",
  "arabic": "btdkqʔmnfvðszʃxɣħʕhlrj",
)

// Language affricate inventories (used when affricates: true)
// Note: No tie bars needed - the "Affricate" row label makes it clear
// Note: Only one affricate pair per place - "all" uses more common variants
#let language-affricates = (
  "all": "pfbvtsdztʃdʒʈʂɖʐ", // tʃ/dʒ chosen over tɕ/dʑ (more common)
  "english": "tʃdʒ",
  "spanish": "tʃ",
  "french": "", // No native affricates
  "german": "pfts",
  "italian": "tsdztʃdʒ",
  "japanese": "", // Do not include allophones
  "portuguese": "tʃdʒ",
  "russian": "tstʃ",
  "arabic": "", // No native affricates
)

// Language aspirated plosive inventories (used when aspirated: true)
#let language-aspirated-plosives = (
  "all": "pʰtʰʈʰcʰkʰqʰ",
  "english": "", // English aspiration is allophonic, not phonemic
  "spanish": "",
  "french": "",
  "german": "",
  "italian": "",
  "japanese": "",
  "portuguese": "",
  "russian": "",
  "arabic": "",
)

// Language aspirated affricate inventories (used when both affricates: true AND aspirated: true)
#let language-aspirated-affricates = (
  "all": "tsʰtʃʰʈʂʰtɕʰ",
  "english": "",
  "spanish": "",
  "french": "",
  "german": "",
  "italian": "",
  "japanese": "",
  "portuguese": "",
  "russian": "",
  "arabic": "",
)

// Helper function to extract braced content {phoneme} from input
// Braced content can be affricates, aspirated consonants, etc.
#let extract-braced-content(input) = {
  let braced-items = ()
  let cleaned = ""
  let in-braces = false
  let current-item = ""

  for char in input.clusters() {
    if char == "{" {
      in-braces = true
      current-item = ""
    } else if char == "}" {
      if in-braces and current-item != "" {
        braced-items.push(current-item)
      }
      in-braces = false
      current-item = ""
    } else if in-braces {
      current-item += char
    } else {
      cleaned += char
    }
  }

  (braced-items: braced-items, cleaned: cleaned)
}

// Helper function to categorize braced items into affricates, aspirated plosives, and aspirated affricates
#let categorize-braced-items(braced-items) = {
  let affricates = ()
  let aspirated-plosives = ()
  let aspirated-affricates = ()

  for item in braced-items {
    // Convert IPA notation to Unicode (spaces are required for diacritics like \h)
    let converted = ipa-to-unicode(item)

    // Check which category this belongs to
    if converted in aspirated-affricate-data {
      aspirated-affricates.push(converted)
    } else if converted in aspirated-plosive-data {
      aspirated-plosives.push(converted)
    } else if converted in affricate-data {
      affricates.push(converted)
    }
    // Unknown braced items are silently ignored
  }

  (
    affricates: affricates,
    aspirated-plosives: aspirated-plosives,
    aspirated-affricates: aspirated-affricates,
  )
}

// Main consonants function
#let consonants(
  consonant-string,
  lang: none,
  affricates: false,
  aspirated: false,
  cell-width: 1.8,
  cell-height: 0.9,
  label-width: 3.5,
  label-height: 1.2,
  scale: 0.7,
) = {
  // Determine which consonants to plot
  let consonants-to-plot = ""
  let custom-affricates-string = ""
  let custom-aspirated-plosives-string = ""
  let custom-aspirated-affricates-string = ""
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
    // Use as manual consonant specification
    // Extract braced content first (affricates, aspirated consonants, etc.)
    let extracted = extract-braced-content(consonant-string)

    // Convert IPA notation to Unicode for consonants (excluding braced items)
    consonants-to-plot = ipa-to-unicode(extracted.cleaned)

    // Categorize braced items into their respective types
    let categorized = categorize-braced-items(extracted.braced-items)
    // Note: .join("") returns none for empty arrays in Typst, so we check length first
    if categorized.affricates.len() > 0 {
      custom-affricates-string = categorized.affricates.join("")
    }
    if categorized.aspirated-plosives.len() > 0 {
      custom-aspirated-plosives-string = categorized.aspirated-plosives.join("")
    }
    if categorized.aspirated-affricates.len() > 0 {
      custom-aspirated-affricates-string = categorized.aspirated-affricates.join("")
    }
  } else {
    error-msg = [*Error:* Either provide consonant string or language name]
  }

  // If there's an error, display it and return
  if error-msg != none {
    return error-msg
  }

  // Determine which affricates to plot (if affricates: true)
  let affricates-to-plot = ""
  if affricates {
    // Check if we used a language name
    if consonant-string in language-affricates {
      affricates-to-plot = language-affricates.at(consonant-string)
    } else if lang != none and lang in language-affricates {
      affricates-to-plot = language-affricates.at(lang)
    } else {
      // For custom input, use only the extracted affricates from braces
      affricates-to-plot = custom-affricates-string
    }
  }

  // Determine which aspirated consonants to plot (if aspirated: true)
  let aspirated-plosives-to-plot = ""
  let aspirated-affricates-to-plot = ""
  if aspirated {
    // Aspirated plosives
    if consonant-string in language-aspirated-plosives {
      aspirated-plosives-to-plot = language-aspirated-plosives.at(consonant-string)
    } else if lang != none and lang in language-aspirated-plosives {
      aspirated-plosives-to-plot = language-aspirated-plosives.at(lang)
    } else {
      // For custom input, use aspirated plosives extracted from braces
      aspirated-plosives-to-plot = custom-aspirated-plosives-string
    }

    // Aspirated affricates (only if affricates is also true)
    if affricates {
      if consonant-string in language-aspirated-affricates {
        aspirated-affricates-to-plot = language-aspirated-affricates.at(consonant-string)
      } else if lang != none and lang in language-aspirated-affricates {
        aspirated-affricates-to-plot = language-aspirated-affricates.at(lang)
      } else {
        // For custom input, use aspirated affricates extracted from braces
        aspirated-affricates-to-plot = custom-aspirated-affricates-string
      }
    }
  }

  // Build manners array with optional rows
  let display-manners = manners
  if aspirated {
    // Insert "Plosive (aspirated)" after "Plosive" (index 0)
    display-manners = manners.slice(0, 1) + ("Plosive (aspirated)",) + manners.slice(1)
  }
  if affricates {
    // Insert "Affricate" after "Fricative"
    // Index is 4 if no aspirated row, 5 if aspirated row was added
    let affricate-insert-index = if aspirated { 6 } else { 5 }
    display-manners = (
      display-manners.slice(0, affricate-insert-index) + ("Affricate",) + display-manners.slice(affricate-insert-index)
    )

    // If both affricates and aspirated, add "Affricate (aspirated)" too
    if aspirated {
      display-manners = (
        display-manners.slice(0, affricate-insert-index + 1)
          + ("Affricate (aspirated)",)
          + display-manners.slice(affricate-insert-index + 1)
      )
    }
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
  let num-rows = display-manners.len()

  canvas({
    import draw: *

    // Calculate total dimensions
    let total-width = scaled-label-width + (num-cols * scaled-cell-width)
    let total-height = scaled-label-height + (num-rows * scaled-cell-height)

    // Draw column headers (places of articulation)
    for (i, place) in places.enumerate() {
      let x = scaled-label-width + (i * scaled-cell-width) + (scaled-cell-width / 2)
      let y = total-height / 2 - (scaled-label-height / 2)

      content((x, y), context text(size: scaled-label-font-size * 1pt, font: phonokit-font.get(), place), anchor: "center")
    }

    // Draw row headers (manners of articulation)
    for (i, manner) in display-manners.enumerate() {
      let x = scaled-label-width - 0.2
      let y = total-height / 2 - scaled-label-height - (i * scaled-cell-height) - (scaled-cell-height / 2)

      content((x, y), context text(size: scaled-label-font-size * 1pt, font: phonokit-font.get(), manner), anchor: "east")
    }

    // Calculate row positions accounting for optional row insertions (needed for grid drawing)
    let fricative-row = if aspirated { 5 } else { 4 }
    let affricate-row = if affricates { (if aspirated { 6 } else { 5 }) } else { -1 }
    let aspirated-affricate-row = if (affricates and aspirated) { 7 } else { -1 }

    // Draw grid lines
    // Vertical lines
    for i in range(num-cols + 1) {
      let x = scaled-label-width + (i * scaled-cell-width)
      let y1 = total-height / 2 - scaled-label-height
      let y2 = -total-height / 2

      // Special handling: Remove lines between dental-alveolar (i=3) and alveolar-postalveolar (i=4)
      // EXCEPT in the fricative and affricate rows
      if i == 3 or i == 4 {
        // Draw line segments for each row, but only draw for fricative and affricate rows
        for row in range(num-rows) {
          if row == fricative-row or row == affricate-row or row == aspirated-affricate-row {
            let row-y1 = total-height / 2 - scaled-label-height - (row * scaled-cell-height)
            let row-y2 = row-y1 - scaled-cell-height
            line((x, row-y1), (x, row-y2), stroke: (paint: gray.lighten(20%), thickness: scaled-line-thickness * 1pt))
          }
        }
      } else {
        // Draw normal full-height vertical line for other columns
        line((x, y1), (x, y2), stroke: (paint: gray.lighten(20%), thickness: scaled-line-thickness * 1pt))
      }
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
    // Calculate row positions accounting for optional row insertions
    let plosive-row = 0
    let nasal-row = if aspirated { 2 } else { 1 }
    let trill-row = if aspirated { 3 } else { 2 }
    let tap-row = if aspirated { 4 } else { 3 }
    let fricative-row = if aspirated { 5 } else { 4 }

    // Rows after fricative need additional offset for affricate row(s)
    let affricate-offset = 0
    if affricates {
      affricate-offset += 1
      if aspirated {
        affricate-offset += 1
      }
    }

    let lat-fric-row = (if aspirated { 6 } else { 5 }) + affricate-offset
    let approx-row = (if aspirated { 7 } else { 6 }) + affricate-offset
    let lat-approx-row = (if aspirated { 8 } else { 7 }) + affricate-offset

    let impossible-cells = (
      // Lateral fricative
      (lat-fric-row, 0, "full"),
      (lat-fric-row, 1, "full"),
      (lat-fric-row, 9, "full"),
      (lat-fric-row, 10, "full"),
      // Lateral approximant
      (lat-approx-row, 0, "full"),
      (lat-approx-row, 1, "full"),
      (lat-approx-row, 9, "full"),
      (lat-approx-row, 10, "full"),
      // Trill
      (trill-row, 7, "full"),
      (trill-row, 10, "full"),
      // Tap or flap
      (tap-row, 7, "full"),
      (tap-row, 10, "full"),
      // Approximant
      (approx-row, 10, "full"),
      // Plosive - voiced side only
      (plosive-row, 9, "voiced"),
      (plosive-row, 10, "voiced"),
      // Nasal
      (nasal-row, 9, "full"),
      (nasal-row, 10, "full"),
    )

    // Add aspirated plosive impossible cells if that row exists
    if aspirated {
      impossible-cells = (
        impossible-cells
          + (
            (1, 9, "full"), // Pharyngeal aspirated plosive - physiologically impossible
            (1, 10, "full"), // Glottal aspirated plosive - physiologically impossible
          )
      )
    }

    for (row, col, half) in impossible-cells {
      let cell-x = scaled-label-width + (col * scaled-cell-width)
      let cell-y = total-height / 2 - scaled-label-height - (row * scaled-cell-height)

      if half == "full" {
        // Fill entire cell
        rect(
          (cell-x, cell-y),
          (cell-x + scaled-cell-width, cell-y - scaled-cell-height),
          fill: gray.lighten(70%),
          stroke: (paint: gray.lighten(20%), thickness: scaled-line-thickness * 1pt),
        )
      } else if half == "voiced" {
        // Fill right half of cell (voiced side)
        let mid-x = cell-x + (scaled-cell-width / 2)
        rect(
          (mid-x, cell-y),
          (cell-x + scaled-cell-width, cell-y - scaled-cell-height),
          fill: gray.lighten(70%),
          stroke: (paint: gray.lighten(20%), thickness: scaled-line-thickness * 1pt),
        )
      } else if half == "voiceless" {
        // Fill left half of cell (voiceless side)
        let mid-x = cell-x + (scaled-cell-width / 2)
        rect(
          (cell-x, cell-y),
          (mid-x, cell-y - scaled-cell-height),
          fill: gray.lighten(70%),
          stroke: (paint: gray.lighten(20%), thickness: scaled-line-thickness * 1pt),
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

    // Special handling for /w/ (labiovelar approximant)
    // If /w/ is present but /ɰ/ (velar approximant) is not, show /w/ in both bilabial and velar columns
    if consonants-to-plot.contains("w") and not consonants-to-plot.contains("ɰ") {
      let velar-approx-key = "7-6" // place 7 (velar), manner 6 (approximant)
      if velar-approx-key not in cell-consonants {
        cell-consonants.insert(velar-approx-key, (voiceless: none, voiced: none))
      }
      cell-consonants.at(velar-approx-key).voiced = "w"
    }

    // Collect aspirated plosives if enabled
    let cell-aspirated-plosives = (:)
    if aspirated {
      for asp-plosive in aspirated-plosive-data.keys() {
        if aspirated-plosives-to-plot.contains(asp-plosive) {
          let info = aspirated-plosive-data.at(asp-plosive)
          let key = str(info.place)

          if key not in cell-aspirated-plosives {
            cell-aspirated-plosives.insert(key, (voiceless: none, voiced: none))
          }

          // Aspirated plosives are always voiceless
          cell-aspirated-plosives.at(key).voiceless = asp-plosive
        }
      }
    }

    // Collect affricates if enabled
    let cell-affricates = (:)
    if affricates {
      // Strip tie bars from input (user might input t͡s, we display as ts)
      let affricates-cleaned = affricates-to-plot.replace("͡", "")

      for affricate in affricate-data.keys() {
        if affricates-cleaned.contains(affricate) {
          let info = affricate-data.at(affricate)
          let key = str(info.place)

          if key not in cell-affricates {
            cell-affricates.insert(key, (voiceless: none, voiced: none))
          }

          if info.voicing {
            cell-affricates.at(key).voiced = affricate
          } else {
            cell-affricates.at(key).voiceless = affricate
          }
        }
      }
    }

    // Collect aspirated affricates if both enabled
    let cell-aspirated-affricates = (:)
    if aspirated and affricates {
      for asp-affricate in aspirated-affricate-data.keys() {
        if aspirated-affricates-to-plot.contains(asp-affricate) {
          let info = aspirated-affricate-data.at(asp-affricate)
          let key = str(info.place)

          if key not in cell-aspirated-affricates {
            cell-aspirated-affricates.insert(key, (voiceless: none, voiced: none))
          }

          // Aspirated affricates are always voiceless
          cell-aspirated-affricates.at(key).voiceless = asp-affricate
        }
      }
    }

    // Draw consonants in cells
    for (key, pair) in cell-consonants {
      let parts = key.split("-")
      let col = int(parts.at(0))
      let manner = int(parts.at(1)) // Original manner of articulation
      let row = manner // Display row (will be adjusted)

      // Adjust row based on inserted optional rows
      if aspirated and row >= 1 {
        row = row + 1 // Plosive (aspirated) row inserted at 1
      }
      if affricates and row >= 5 {
        let affricate-offset = if aspirated { 6 } else { 5 }
        if row >= affricate-offset {
          row = row + 1 // Affricate row inserted
          if aspirated {
            row = row + 1 // Affricate (aspirated) row also inserted
          }
        }
      }

      let cell-x = scaled-label-width + (col * scaled-cell-width)
      let cell-y = total-height / 2 - scaled-label-height - (row * scaled-cell-height)
      let cell-center-x = cell-x + (scaled-cell-width / 2)
      let cell-center-y = cell-y - (scaled-cell-height / 2)

      // Check if this is a sonorant manner (not contrastive for voicing, should be centered)
      // Manners: 1=Nasal, 2=Trill, 3=Tap/Flap, 6=Approximant, 7=Lateral Approximant
      let is-sonorant = manner in (1, 2, 3, 6, 7)

      if is-sonorant {
        // Center the consonant (sonorants are always voiced in typical inventories)
        if pair.voiced != none {
          let pos = (cell-center-x, cell-center-y)
          circle(pos, radius: scaled-circle-radius, fill: white, stroke: none)
          content(pos, context text(size: scaled-font-size * 1pt, font: phonokit-font.get(), pair.voiced), anchor: "center")
        }
        // In rare cases where voiceless sonorants exist, also center them
        if pair.voiceless != none {
          let pos = (cell-center-x, cell-center-y)
          circle(pos, radius: scaled-circle-radius, fill: white, stroke: none)
          content(pos, context text(size: scaled-font-size * 1pt, font: phonokit-font.get(), pair.voiceless), anchor: "center")
        }
      } else {
        // Obstruents: use left/right positioning for voicing contrast
        let offset = scaled-cell-width * 0.25

        if pair.voiceless != none {
          let pos = (cell-center-x - offset, cell-center-y)
          circle(pos, radius: scaled-circle-radius, fill: white, stroke: none)
          content(pos, context text(size: scaled-font-size * 1pt, font: phonokit-font.get(), pair.voiceless), anchor: "center")
        }

        if pair.voiced != none {
          let pos = (cell-center-x + offset, cell-center-y)
          circle(pos, radius: scaled-circle-radius, fill: white, stroke: none)
          content(pos, context text(size: scaled-font-size * 1pt, font: phonokit-font.get(), pair.voiced), anchor: "center")
        }
      }
    }

    // Draw aspirated plosives in row 1 (after regular plosives)
    if aspirated {
      for (key, pair) in cell-aspirated-plosives {
        let col = int(key)
        let row = 1 // Plosive (aspirated) row

        let cell-x = scaled-label-width + (col * scaled-cell-width)
        let cell-y = total-height / 2 - scaled-label-height - (row * scaled-cell-height)
        let cell-center-x = cell-x + (scaled-cell-width / 2)
        let cell-center-y = cell-y - (scaled-cell-height / 2)

        // Only left position (voiceless only for aspirated)
        let offset = scaled-cell-width * 0.25

        if pair.voiceless != none {
          let pos = (cell-center-x - offset, cell-center-y)
          circle(pos, radius: scaled-circle-radius, fill: white, stroke: none)
          content(pos, context text(size: scaled-font-size * 1pt, font: phonokit-font.get(), pair.voiceless), anchor: "center")
        }
      }
    }

    // Draw affricates (after fricatives)
    if affricates {
      let affricate-row = if aspirated { 6 } else { 5 }
      for (key, pair) in cell-affricates {
        let col = int(key)
        let row = affricate-row

        let cell-x = scaled-label-width + (col * scaled-cell-width)
        let cell-y = total-height / 2 - scaled-label-height - (row * scaled-cell-height)
        let cell-center-x = cell-x + (scaled-cell-width / 2)
        let cell-center-y = cell-y - (scaled-cell-height / 2)

        // Offset for left/right positioning
        let offset = scaled-cell-width * 0.25

        if pair.voiceless != none {
          let pos = (cell-center-x - offset, cell-center-y)
          circle(pos, radius: scaled-circle-radius, fill: white, stroke: none)
          content(pos, context text(size: scaled-font-size * 1pt, font: phonokit-font.get(), pair.voiceless), anchor: "center")
        }

        if pair.voiced != none {
          let pos = (cell-center-x + offset, cell-center-y)
          circle(pos, radius: scaled-circle-radius, fill: white, stroke: none)
          content(pos, context text(size: scaled-font-size * 1pt, font: phonokit-font.get(), pair.voiced), anchor: "center")
        }
      }
    }

    // Draw aspirated affricates (after regular affricates)
    if aspirated and affricates {
      let asp-affricate-row = if aspirated { 7 } else { 6 } // After affricate row
      for (key, pair) in cell-aspirated-affricates {
        let col = int(key)
        let row = asp-affricate-row

        let cell-x = scaled-label-width + (col * scaled-cell-width)
        let cell-y = total-height / 2 - scaled-label-height - (row * scaled-cell-height)
        let cell-center-x = cell-x + (scaled-cell-width / 2)
        let cell-center-y = cell-y - (scaled-cell-height / 2)

        // Only left position (voiceless only for aspirated)
        let offset = scaled-cell-width * 0.25

        if pair.voiceless != none {
          let pos = (cell-center-x - offset, cell-center-y)
          circle(pos, radius: scaled-circle-radius, fill: white, stroke: none)
          content(pos, context text(size: scaled-font-size * 1pt, font: phonokit-font.get(), pair.voiceless), anchor: "center")
        }
      }
    }
  })
}

