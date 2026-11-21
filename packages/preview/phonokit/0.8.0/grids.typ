#import "ipa.typ": ipa-to-unicode, tone-letters, tone-runs
#import "_config.typ": phonokit-font

// Helper function to parse string-based input like "te2.ne1.see3"
#let parse-grid-string(input) = {
  let units = input.split(".")
  let parsed = ()

  for unit in units {
    if unit.len() > 0 {
      // Extract the last character as the level
      let level-str = unit.at(unit.len() - 1)
      let level = int(level-str)

      // Extract everything except the last character as the syllable
      let syllable = unit.slice(0, unit.len() - 1)

      parsed.push((text: syllable, level: level))
    }
  }

  parsed
}

// Main metrical grid function - creates metrical grid representations
// Supports two input formats:
//
// 1. String format (plain text unless ipa: true):
//    met-grid("te2.ne1.see3.Ti3.tans1")
//    met-grid("te2.ne1.si3.Ti3.t\\~ans1", ipa: true)  // Converts syllables to IPA
//    Format: syllable + level number, separated by dots
//
// 2. Array format (IPA by default):
//    met-grid(("te", 2), ("ne", 1), ("see", 3))  // Auto-converts strings to IPA
//    met-grid(("te", 2), ("ne", 1), ("see", 3), ipa: false)
//    Format: array of (content, level) tuples
//
// ipa: auto converts arrays but not strings. Tone commands (\tone{51}) are
// converted in both formats, even with ipa: false
//
#let met-grid(..args, ipa: auto) = {
  assert(ipa == auto or type(ipa) == bool, message: "met-grid: ipa must be auto, true or false")
  let data = ()

  // Determine input format
  if args.pos().len() == 1 and type(args.pos().at(0)) == str {
    // String format: "te2.ne1.see3"
    data = parse-grid-string(args.pos().at(0)).map(item => {
      let syllable = if ipa == true { ipa-to-unicode(item.text) } else { tone-letters(item.text) }
      (text: context tone-runs(text(font: phonokit-font.get(), syllable)), level: item.level)
    })
  } else {
    // Array format: ("te", 2), ("ne", 1), ...
    for arg in args.pos() {
      if type(arg) == array and arg.len() == 2 {
        let text-content = arg.at(0)
        let level = arg.at(1)

        // If ipa mode is enabled and text-content is a string, convert it
        if type(text-content) == str {
          let converted = if ipa != false { ipa-to-unicode(text-content) } else { tone-letters(text-content) }
          text-content = context tone-runs(text(font: phonokit-font.get(), converted))
        }

        data.push((text: text-content, level: level))
      } else {
        return text(fill: red, weight: "bold")[⚠ Error: Each argument must be a (text, level) tuple]
      }
    }
  }

  if data.len() == 0 {
    return text(fill: red, weight: "bold")[⚠ Error: No data to display]
  }

  // Find maximum level to determine number of rows
  let max-level = 0
  for item in data {
    if item.level > max-level {
      max-level = item.level
    }
  }

  // Build the table rows from top to bottom
  let rows = ()

  // Create rows for each stress level (from highest to lowest)
  for level in range(max-level, 0, step: -1) {
    let row = ()
    for item in data {
      if item.level >= level {
        row.push($times$)
      } else {
        row.push([])
      }
    }
    rows.push(row)
  }

  // Add the syllable row at the bottom
  let syllable-row = ()
  for item in data {
    if type(item.text) == str {
      syllable-row.push(context text(font: phonokit-font.get(), item.text))
    } else {
      syllable-row.push(item.text)
    }
  }
  rows.push(syllable-row)

  // Create table with no borders, wrapped in box for inline placement
  // baseline: 50% centers the grid vertically with text baseline
  box(
    baseline: 50%,
    table(
      columns: data.len(),
      stroke: none,
      align: center,
      inset: 8pt,
      ..rows.flatten()
    )
  )
}
