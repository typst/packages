// Sonority Module
// Visualize sonority profiles of phonemic transcriptions
// Based on Parker (2011) sonority scale

#import "ipa.typ": ipa, ipa-to-unicode
#import "_config.typ": phonokit-font
#import "@preview/cetz:0.5.2"

// Sonority scale: Parker (2011: 18), "Final hierarchy of relative sonority" (27).
// One index per natural class, 1–17. Classes Parker does not list are placed
// by manner and voicing: lateral fricatives with fricatives, labiodental ʋ with
// glides, implosives with voiced stops.
#let sonority-scale = (
  // Low vowels
  "a": 17,
  "ɑ": 17,
  "æ": 17,
  "ɐ": 17,
  "ɒ": 17,
  "ɶ": 17,
  // Mid peripheral vowels (not [ə])
  "e": 16,
  "ø": 16,
  "ɤ": 16,
  "o": 16,
  "ɛ": 16,
  "œ": 16,
  "ʌ": 16,
  "ɔ": 16,
  // High peripheral vowels (not [ɨ])
  "i": 15,
  "y": 15,
  "ɯ": 15,
  "u": 15,
  "ɪ": 15,
  "ʏ": 15,
  "ʊ": 15,
  // Mid interior vowels ([ə])
  "ə": 14,
  "ɘ": 14,
  "ɵ": 14,
  "ɜ": 14,
  "ɞ": 14,
  "ɚ": 14,
  "ɝ": 14,
  // High interior vowels ([ɨ])
  "ɨ": 13,
  "ʉ": 13,
  // Glides
  "j": 12,
  "w": 12,
  "ɥ": 12,
  "ɰ": 12,
  "ʋ": 12,
  // Rhotic approximants ([ɹ])
  "ɹ": 11,
  "ɻ": 11,
  // Flaps
  "ɾ": 10,
  "ɽ": 10,
  "ⱱ": 10,
  // Laterals
  "l": 9,
  "ɫ": 9,
  "ɭ": 9,
  "ʎ": 9,
  "ʟ": 9,
  // Trills
  "r": 8,
  "ʀ": 8,
  "ʙ": 8,
  // Nasals
  "m": 7,
  "ɱ": 7,
  "n": 7,
  "ɳ": 7,
  "ɲ": 7,
  "ŋ": 7,
  "ɴ": 7,
  // Voiced fricatives
  "β": 6,
  "v": 6,
  "ð": 6,
  "z": 6,
  "ʒ": 6,
  "ʐ": 6,
  "ʑ": 6,
  "ʝ": 6,
  "ɣ": 6,
  "ʁ": 6,
  "ʕ": 6,
  "ɦ": 6,
  "ɮ": 6,
  // Voiced affricates
  "d͡ʒ": 5,
  "d͡z": 5,
  "d͡ʑ": 5,
  "ɖ͡ʐ": 5,
  // Voiced stops
  "b": 4,
  "d": 4,
  "ɖ": 4,
  "ɟ": 4,
  "g": 4,
  "ɡ": 4,
  "ɢ": 4,
  "ɓ": 4,
  "ɗ": 4,
  "ʄ": 4,
  // Voiceless fricatives (including [h])
  "ɸ": 3,
  "f": 3,
  "θ": 3,
  "s": 3,
  "ʃ": 3,
  "ʂ": 3,
  "ɕ": 3,
  "ç": 3,
  "x": 3,
  "χ": 3,
  "ħ": 3,
  "h": 3,
  "ɬ": 3,
  // Voiceless affricates
  "t͡ʃ": 2,
  "t͡s": 2,
  "t͡ɕ": 2,
  "ʈ͡ʂ": 2,
  "t͡θ": 2,
  "p͡f": 2,
  // Voiceless stops (including [ʔ])
  "p": 1,
  "t": 1,
  "ʈ": 1,
  "c": 1,
  "k": 1,
  "q": 1,
  "ʔ": 1,
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
  y-range: (0, 17), // Sonority range for y-axis (Parker's scale maxes at 17)
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
    syllable-boundaries = syllable-boundaries.filter(pos => pos < 10)
  }

  let sonority-values = phonemes.map(p => get-sonority(p))
  let n-phonemes = phonemes.len()
  let height = 3

  if truncated {
    text(size: 9pt, fill: red, weight: "bold")[⚠ Warning: Truncated to first 10 phonemes.]
    v(0.5em)
  }

  // Bind locally: inside the canvas closure `scale` resolves to Typst's built-in
  let scale-factor = scale

  cetz.canvas(length: scale-factor * 1cm, {
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
        line((x1, y1), (x2, y2), stroke: (thickness: 0.5pt * scale-factor, paint: gray, dash: "dashed"))
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
        stroke: (0.5pt * scale-factor) + black,
      )

      // Add phoneme label (always black now)
      content(
        (x, y),
        context text(size: 10pt * scale-factor, font: phonokit-font.get(), fill: black)[#phoneme],
        anchor: "center",
      )
    }
  })
}
