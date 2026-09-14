// Sonority Module
// Visualize sonority profiles of phonemic transcriptions
// Based on Parker (2011) sonority scale

#import "ipa.typ": ipa, ipa-to-unicode
#import "_config.typ": phonokit-font
#import "@preview/cetz:0.4.2"

// Sonority scale based on Parker (2011)
#let sonority-scale = (
  "a": 13,
  "ɑ": 13,
  "æ": 13,
  "ɐ": 13,
  "ɛ": 12,
  "ɔ": 12,
  "ʌ": 12,
  "œ": 12,
  "e": 12,
  "o": 12,
  "ə": 12,
  "ɘ": 12,
  "ɵ": 12,
  "ø": 12,
  "ɚ": 12,
  "ɝ": 12,
  "i": 12,
  "u": 12,
  "ɪ": 12,
  "ʊ": 12,
  "y": 12,
  "ɯ": 12,
  "ɨ": 12,
  "ʉ": 12,
  "j": 11,
  "w": 11,
  "ɥ": 11,
  "ɰ": 11,
  "ɾ": 10,
  "ɽ": 10,
  "l": 9,
  "ɫ": 9,
  "ʎ": 9,
  "ʟ": 9,
  "ɬ": 8,
  "ɮ": 8,
  "r": 8,
  "ʀ": 8,
  "ɹ": 8,
  "ʁ": 8,
  "ɻ": 8,
  "m": 7,
  "n": 7,
  "ŋ": 7,
  "ɲ": 7,
  "ɳ": 7,
  "ɴ": 7,
  "ɱ": 7,
  "v": 6,
  "z": 6,
  "ʒ": 6,
  "ð": 6,
  "ʐ": 6,
  "ʝ": 6,
  "ɣ": 6,
  "β": 6,
  "f": 3,
  "s": 3,
  "ʃ": 3,
  "θ": 3,
  "x": 3,
  "χ": 3,
  "ħ": 3,
  "h": 3,
  "ɸ": 3,
  "ç": 3,
  "ʂ": 3,
  "b": 4,
  "d": 4,
  "g": 4,
  "ɡ": 4,
  "ɢ": 4,
  "ɖ": 4,
  "ʄ": 4,
  "ɗ": 4,
  "ɓ": 4,
  "p": 1,
  "t": 1,
  "k": 1,
  "q": 1,
  "ʔ": 1,
  "ʈ": 1,
  "c": 1,
  "d͡ʒ": 5,
  "d͡z": 5,
  "d͡ʑ": 5,
  "ɖ͡ʐ": 5,
  "t͡ʃ": 2,
  "t͡s": 2,
  "t͡ɕ": 2,
  "ʈ͡ʂ": 2,
  "t͡θ": 2,
  "p͡f": 2,
)

#let get-sonority(phoneme) = {
  if phoneme in sonority-scale {
    sonority-scale.at(phoneme)
  } else {
    let base = phoneme.codepoints().at(0)
    if base in sonority-scale {
      sonority-scale.at(base)
    } else {
      5
    }
  }
}

// Parse IPA string into individual phonemes and syllable boundaries
#let parse-phonemes(ipa-string) = {
  let cleaned = ipa-string.replace("ˈ", "").replace("ˌ", "").replace("ː", "")
  let syllable-boundaries = ()
  let phonemes = ()
  let position = 0
  let basic-clusters = cleaned.clusters()
  let i = 0

  while i < basic-clusters.len() {
    let cluster = basic-clusters.at(i)
    if cluster == "." {
      syllable-boundaries.push(position)
      i += 1
    } else if cluster == " " or cluster == "-" {
      i += 1
    } else if cluster.contains("͡") {
      if i + 1 < basic-clusters.len() {
        let next = basic-clusters.at(i + 1)
        if next != " " and next != "-" and next != "." {
          phonemes.push(cluster + next)
          i += 2
          position += 1
        } else {
          phonemes.push(cluster)
          i += 1
          position += 1
        }
      } else {
        phonemes.push(cluster)
        i += 1
        position += 1
      }
    } else {
      phonemes.push(cluster)
      i += 1
      position += 1
    }
  }
  (phonemes, syllable-boundaries)
}

// Main sonority plotting function
#let sonority(
  word, // Tipa-style string
  syl: none, // (Legacy/unused directly in calculation now, kept for API compatibility)
  stressed: none, // Index of stressed syllable
  box-size: 0.8, // Size of phoneme boxes
  scale: 1.0, // Overall scale
  y-range: (0, 8), // Sonority range for y-axis
  show-lines: true, // Connect phonemes with lines
) = {
  // Convert tipa-style input to IPA
  let ipa-string = ipa-to-unicode(word)
  let (phonemes, syllable-boundaries) = parse-phonemes(ipa-string)

  // Truncation check
  let original-count = phonemes.len()
  let truncated = original-count > 10
  if truncated {
    phonemes = phonemes.slice(0, 10)
    syllable-boundaries = syllable-boundaries.filter(pos => pos <= 10)
  }

  let sonority-values = phonemes.map(p => get-sonority(p))
  let n-phonemes = phonemes.len()
  let width = n-phonemes * 1.5
  let height = 3

  if truncated {
    text(size: 9pt, fill: red, weight: "bold")[⚠ Warning: Truncated to first 10 phonemes.]
    v(0.5em)
  }

  cetz.canvas(length: scale * 1cm, {
    import cetz.draw: *
    set-origin((0, 0))

    // Draw connecting lines first
    if show-lines and n-phonemes > 1 {
      for i in range(n-phonemes - 1) {
        let x1 = float(i) * 1.5
        let y1 = float((sonority-values.at(i) - y-range.at(0))) / float((y-range.at(1) - y-range.at(0))) * float(height)
        let x2 = float(i + 1) * 1.5
        let y2 = (
          float((sonority-values.at(i + 1) - y-range.at(0))) / float((y-range.at(1) - y-range.at(0))) * float(height)
        )
        line((x1, y1), (x2, y2), stroke: (thickness: 0.5pt, paint: gray, dash: "dashed"))
      }
    }

    // Draw phoneme boxes with syllable-based alternating colors
    for (i, phoneme) in phonemes.enumerate() {
      let sonority = sonority-values.at(i)
      let x = float(i) * 1.5
      let y = float((sonority - y-range.at(0))) / float((y-range.at(1) - y-range.at(0))) * float(height)

      // Determine syllable index by checking how many boundaries we have passed
      let syllable-index = syllable-boundaries.filter(b => b <= i).len()

      // Alternate colors: Even syllables = White, Odd syllables = Gray
      let box-fill = if calc.even(syllable-index) {
        white
      } else {
        rgb("dddddd") // Light gray
      }

      // Draw box
      rect(
        (x - box-size / 2, y - box-size / 2),
        (x + box-size / 2, y + box-size / 2),
        fill: box-fill,
        stroke: 0.5pt + black,
      )

      // Add phoneme label (always black now)
      content(
        (x, y),
        context text(size: 10pt, font: phonokit-font.get(), fill: black)[#phoneme],
        anchor: "center",
      )
    }
  })
}
