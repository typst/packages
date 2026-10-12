#import "@preview/cetz:0.5.2"
#import "ipa.typ": ipa-to-unicode
#import "_config.typ": phonokit-font

// Follows the same spacing convention as #ipa():
//   - Backslash commands need spaces: "t \\ae p" → "tæp"
//   - Single characters don't: "SIp" → "ʃɪp"
#let convert-prosody-input(input) = {
  let result = ""
  let buffer = ""
  let chars = input.codepoints()
  let i = 0

  while i < chars.len() {
    let char = chars.at(i)

    // Check if this is a structural marker
    // Note: ' and , are stress markers (not printed, just for structure)
    if char in ("'", ",", ".", "(", ")") {
      // First, process any buffered content
      if buffer != "" {
        result += ipa-to-unicode(buffer)
        buffer = ""
      }
      // Add the structural marker (will be stripped during parsing)
      result += char
    } else {
      // Add to buffer (including spaces, which will be handled by ipa-to-unicode)
      buffer += char
    }

    i += 1
  }

  // Process any remaining buffer
  if buffer != "" {
    result += ipa-to-unicode(buffer)
  }

  result
}

#let is-vowel(cluster) = {
  // Check the base character (first codepoint) to handle both
  // precomposed vowels (like "ã") and combining forms (like "a" + "̃")
  let base = cluster.codepoints().at(0)

  // Check if base is a vowel
  // Covers the full IPA vowel inventory (see vowels.typ), plus rhotacized ɚ/ɝ
  let base-is-vowel = (
    base
      in (
        "a", "e", "i", "o", "u", "y", "ɚ", "ɝ", "ɯ", "ɐ", "ɒ", "æ", "ɛ", "ɪ", "ɔ", "ø", "œ", "ɨ", "ʉ", "ʊ", "ə", "ʌ",
        "ɑ", "ʏ", "ɘ", "ɵ", "ɤ", "ɜ", "ɞ", "ɶ",
      )
  )

  // Also check for diphthongs and precomposed forms as complete clusters
  let cluster-is-vowel = (
    cluster in ("aɪ", "eɪ", "oɪ", "aʊ", "oʊ", "ã", "ẽ", "ĩ", "õ", "ũ", "ỹ", "ɛ̃", "ɔ̃", "œ̃", "ɑ̃")
  )

  // Check if cluster contains syllabicity marker (̩ U+0329)
  // Syllabic consonants (like m̩, n̩, l̩) function as vowels/nuclei
  let is-syllabic = cluster.contains("̩")

  base-is-vowel or cluster-is-vowel or is-syllabic
}

// Custom clustering that handles:
// 1. Affricates (tie bar U+0361) - merge "t͡" + "ʃ" → "t͡ʃ"
// 2. Spacing modifiers (like "ʰ") - merge "b" + "ʰ" → "bʰ"
// 3. Length marks (ː) - merge "a" + "ː" → "aː" as atomic unit
#let smart-clusters(text) = {
  let basic-clusters = text.clusters()
  let result = ()
  let i = 0

  // Define spacing modifiers that should merge with preceding segment
  let spacing-modifiers = ("ʰ", "ʷ", "ʲ", "ˠ", "ˤ", "̚")
  // Length mark (U+02D0)
  let length-mark = "ː"

  while i < basic-clusters.len() {
    let current = basic-clusters.at(i)

    // Check if this cluster contains a tie bar
    if current.contains("͡") {
      // This cluster has a tie bar - merge with next cluster (affricate)
      if i + 1 < basic-clusters.len() {
        result.push(current + basic-clusters.at(i + 1))
        i += 2 // Skip both clusters
      } else {
        result.push(current)
        i += 1
      }
    } else if i + 1 < basic-clusters.len() and basic-clusters.at(i + 1) in spacing-modifiers {
      // Next cluster is a spacing modifier - merge with current
      result.push(current + basic-clusters.at(i + 1))
      i += 2 // Skip both clusters
    } else if i + 1 < basic-clusters.len() and basic-clusters.at(i + 1) == length-mark {
      // Next cluster is a length mark - merge with current (atomic long vowel)
      result.push(current + basic-clusters.at(i + 1))
      i += 2 // Skip both clusters
    } else {
      // Regular cluster
      result.push(current)
      i += 1
    }
  }

  result
}

#let parse-syllable(syll) = {
  // Use smart-clusters() to properly handle affricates and combining diacritics
  let clusters = smart-clusters(syll)
  let onset = ""
  let nucleus = ""
  let coda = ""
  let found-nucleus = false

  for cluster in clusters {
    if is-vowel(cluster) {
      nucleus += cluster
      found-nucleus = true
    } else if not found-nucleus {
      onset += cluster
    } else {
      coda += cluster
    }
  }

  (onset: onset, nucleus: nucleus, coda: coda)
}

// Helper function to draw syllable internal structure
// Vertical spacing shared by the prosodic trees. Each gap between two tiers is
//   (clearance below the upper label) + (visible line) + (clearance above the lower label).
// `distance` scales only the visible line, which never drops below `min-tier-line`,
// so the same lower bound applies at every level of every function.
#let min-tier-line = 0.15

// With spacing: "auto", a branch spanning a horizontal run h gets at least
// branch-slope × h of vertical line (≈ the angle of the original default trees)
#let branch-slope = 0.28

#let tier-line(natural, distance, level) = {
  let factor = 1.0
  if distance != none {
    for entry in distance {
      if entry.at(0) == level {
        factor = calc.max(0, entry.at(1))
      }
    }
  }
  calc.max(min-tier-line, natural * factor)
}

// Long vowels: horizontal distance between their two moras
#let long-mora-spacing = 0.4

// In moraic trees, non-moraic segments hang straight from σ, skipping the μ tier.
// Minimum horizontal distance from the nucleus to the nearest such segment so that
// its line clears the nucleus μ label(s); depends on the actual tier heights.
#let moraic-reach(sigma-y, mora-y, terminal-y, long: false) = {
  let top = sigma-y + 0.25
  let f = (top - (mora-y + 0.2)) / (top - (terminal-y + 0.30))
  let mora-edge = (if long { long-mora-spacing / 2 } else { 0 }) + 0.15
  (mora-edge + 0.15) / f
}

#let check-spacing(spacing) = assert(
  spacing in ("auto", "fixed"),
  message: "spacing must be \"auto\" or \"fixed\"",
)

#let draw-syllable-structure(
  x-offset,
  sigma-y,
  syll,
  terminal-y,
  diagram-scale: 1.0,
  geminate-coda-x: none,
  geminate-onset-x: none,
  geminate-coda-text: none,
  geminate-onset-text: none,
  compact: false,
  or-y: none,
  n-y: none,
) = {
  import cetz.draw: *

  // O/R and N/C level positions (defaults preserve original hardcoded offsets)
  let or-level = if or-y == none { sigma-y - 0.75 } else { or-y }
  let n-level = if n-y == none { sigma-y - 1.65 } else { n-y }

  // Choose offset values based on compact mode
  let (line-offset, text-offset) = if compact {
    (0.70, 0.40) // Compact: shorter lines, raised segments
  } else {
    (0.30, 0) // Standard: longer lines, lower segments
  }

  let has-onset = syll.onset != ""
  let has-coda = syll.coda != ""

  // Calculate segment counts for adaptive spacing
  // Use smart-clusters() to properly count segments including affricates
  let onset-segments = if has-onset { smart-clusters(syll.onset) } else { () }
  let num-onset = if has-onset { onset-segments.len() } else { 0 }

  let nucleus-segments = smart-clusters(syll.nucleus)
  let num-nucleus = nucleus-segments.len()

  let coda-segments = if has-coda { smart-clusters(syll.coda) } else { () }
  let num-coda = if has-coda { coda-segments.len() } else { 0 }

  let segment-spacing = 0.35
  let min-gap = 0.75

  // Headedness: Rhyme is head of syllable, Nucleus is head of Rhyme
  // Heads align vertically, non-heads are angled
  let rhyme-x = x-offset // vertical (head of syllable)
  let nucleus-x = rhyme-x // MUST stay at rhyme-x (vertical, head of rhyme)

  // Adaptive positioning for onset (move left if many segments)
  let onset-x = if has-onset {
    let min-offset = (num-onset - 1) * segment-spacing / 2 + (num-nucleus - 1) * segment-spacing / 2 + min-gap
    let default-offset = 0.7
    if min-offset > default-offset { x-offset - min-offset } else { x-offset - default-offset }
  } else {
    x-offset
  }

  // Adaptive positioning for coda (move right to avoid nucleus segments)
  let coda-x = if has-coda {
    let min-offset = (num-nucleus + num-coda - 2) * segment-spacing / 2 + min-gap
    let default-offset = 0.7
    if min-offset > default-offset { rhyme-x + min-offset } else { rhyme-x + default-offset }
  } else {
    rhyme-x
  }

  // Branches from syllable
  if has-onset {
    line((x-offset, sigma-y + 0.25), (onset-x, or-level + 0.30))
    content((onset-x, or-level), context text(size: 10 * diagram-scale * 1pt, font: phonokit-font.get())[O])

    // Branch to each onset segment
    let onset-segments = smart-clusters(syll.onset)
    let num-onset = onset-segments.len()

    // Always draw all segments, but handle geminates specially
    let onset-total-width = (num-onset - 1) * segment-spacing
    let onset-start-x = onset-x - onset-total-width / 2

    for (i, segment) in onset-segments.enumerate() {
      let seg-x = onset-start-x + i * segment-spacing

      // Check if this segment is the geminate
      let is-geminate = (geminate-onset-x != none and segment == geminate-onset-text)

      if is-geminate {
        // Geminate: draw line to geminate position (text drawn separately in geminate section)
        line((onset-x, or-level - 0.35), (geminate-onset-x, terminal-y + line-offset))
      } else {
        // Normal segment: draw line and text
        line((onset-x, or-level - 0.35), (seg-x, terminal-y + line-offset))
        content(
          (seg-x, terminal-y + text-offset),
          context text(size: 11 * diagram-scale * 1pt, font: phonokit-font.get(), bottom-edge: "descender")[#segment],
          anchor: "north",
        )
      }
    }
  }

  // Rhyme branch
  line((x-offset, sigma-y + 0.25), (rhyme-x, or-level + 0.30))
  content((rhyme-x, or-level), context text(size: 10 * diagram-scale * 1pt, font: phonokit-font.get())[R])

  // Nucleus
  line((rhyme-x, or-level - 0.35), (nucleus-x, n-level + 0.30))
  content((nucleus-x, n-level), context text(size: 10 * diagram-scale * 1pt, font: phonokit-font.get())[N])

  // Branch to each nucleus segment
  let nucleus-total-width = (num-nucleus - 1) * segment-spacing
  let nucleus-start-x = nucleus-x - nucleus-total-width / 2

  for (i, segment) in nucleus-segments.enumerate() {
    let seg-x = nucleus-start-x + i * segment-spacing
    line((nucleus-x, n-level - 0.25), (seg-x, terminal-y + line-offset))
    content(
      (seg-x, terminal-y + text-offset),
      context text(size: 11 * diagram-scale * 1pt, font: phonokit-font.get(), bottom-edge: "descender")[#segment],
      anchor: "north",
    )
  }

  // Coda (if exists)
  if has-coda {
    line((rhyme-x, or-level - 0.35), (coda-x, n-level + 0.30))
    content((coda-x, n-level), context text(size: 10 * diagram-scale * 1pt, font: phonokit-font.get())[C])

    // Branch to each coda segment
    // Always draw all segments, but handle geminates specially
    let coda-total-width = (num-coda - 1) * segment-spacing
    let coda-start-x = coda-x - coda-total-width / 2

    for (i, segment) in coda-segments.enumerate() {
      let seg-x = coda-start-x + i * segment-spacing

      // Check if this segment is the geminate
      let is-geminate = (geminate-coda-x != none and segment == geminate-coda-text)

      if is-geminate {
        // Geminate: draw line to geminate position (text drawn separately in geminate section)
        line((coda-x, n-level - 0.25), (geminate-coda-x, terminal-y + line-offset))
      } else {
        // Normal segment: draw line and text
        line((coda-x, n-level - 0.25), (seg-x, terminal-y + line-offset))
        content(
          (seg-x, terminal-y + text-offset),
          context text(size: 11 * diagram-scale * 1pt, font: phonokit-font.get(), bottom-edge: "descender")[#segment],
          anchor: "north",
        )
      }
    }
  }
}

// Visualizes a single syllable's internal structure (On/Rh/Nu/Co)
// Now accepts IPA-style input like "k a" or "'t a"
#let syllable(input, scale: 1.0, symbol: ("σ",), distance: none, spacing: "auto") = {
  check-spacing(spacing)
  // Check for syllable boundary markers
  if input.contains(".") {
    return text(fill: red, weight: "bold")[⚠ Warning: For more than one syllable, use \#foot() or \#word().]
  }

  // Check for problematic diacritic sequences
  let problematic-sequences = ("''", ",,", "\\* \\*", "\\t \\t", "::", "((", "))")
  for seq in problematic-sequences {
    if input.contains(seq) {
      return text(fill: red, weight: "bold")[⚠ Warning: Problematic sequence involving diacritics: "#seq"]
    }
  }

  // Convert IPA-style input to Unicode
  let converted = convert-prosody-input(input)

  // Parse a single syllable
  // Strip ALL stress markers (' for primary, , for secondary) regardless of position
  let stressed = converted.starts-with("'") or converted.starts-with(",")
  let clean-input = converted.replace("'", "").replace(",", "")

  let parsed = parse-syllable(clean-input)

  // Check for too many codas (limit: 5 to avoid crossing lines)
  let coda-segments-temp = if parsed.coda != "" { smart-clusters(parsed.coda) } else { () }
  if coda-segments-temp.len() > 5 {
    return text(
      fill: red,
      weight: "bold",
    )[⚠ Warning: Too many coda consonants (max 5 to avoid line crossings). Found: #coda-segments-temp.len()]
  }

  // Check for too many onsets (limit: 5 to avoid crossing lines)
  let onset-segments-temp = if parsed.onset != "" { smart-clusters(parsed.onset) } else { () }
  if onset-segments-temp.len() > 5 {
    return text(
      fill: red,
      weight: "bold",
    )[⚠ Warning: Too many onset consonants (max 5 to avoid line crossings). Found: #onset-segments-temp.len()]
  }

  // Check for too many nucleus segments (limit: 5)
  let nucleus-segments-temp = smart-clusters(parsed.nucleus)
  if nucleus-segments-temp.len() > 5 {
    return text(
      fill: red,
      weight: "bold",
    )[⚠ Warning: Too many nucleus segments (max 5 to avoid line crossings). Found: #nucleus-segments-temp.len()]
  }
  let syll = (
    onset: parsed.onset,
    nucleus: parsed.nucleus,
    coda: parsed.coda,
    stressed: stressed,
  )

  let sym_syll = symbol.at(0, default: "σ")

  let diagram-scale = scale
  box(baseline: 50%, cetz.canvas(length: 1cm * diagram-scale, {
    import cetz.draw: *
    set-style(stroke: 0.7 * diagram-scale * 1pt)

    let line-len(natural, level) = tier-line(natural, distance, level)

    let sigma-y = 0
    let x-offset = 0

    // Default lines never get shorter going up the tree (each is at least as
    // long as the one directly below it); explicit `distance` factors are
    // applied afterwards. No upper tiers here, so `spacing` has no effect.

    // Sub-syllable level positions (0=σ→O/R, 1=O/R→N/C, 2=N/C→segments)
    let n-seg-line = 0.55
    let or-n-line = calc.max(0.55, n-seg-line)
    let sigma-or-line = calc.max(0.70, or-n-line)
    let or-level = sigma-y + 0.25 - line-len(sigma-or-line, 0) - 0.30
    let n-level = or-level - 0.35 - line-len(or-n-line, 1) - 0.35
    let terminal-y = n-level - 0.25 - line-len(n-seg-line, 2) - 0.70

    // Standalone syllable spacing: Nu/Co positioned lower (halfway between Rh and segments)
    let line-offset = 0.70
    let text-offset = 0.40

    let has-onset = syll.onset != ""
    let has-coda = syll.coda != ""

    // Calculate segment counts for adaptive spacing
    let onset-segments = if has-onset { smart-clusters(syll.onset) } else { () }
    let num-onset = if has-onset { onset-segments.len() } else { 0 }

    let nucleus-segments = smart-clusters(syll.nucleus)
    let num-nucleus = nucleus-segments.len()

    let coda-segments = if has-coda { smart-clusters(syll.coda) } else { () }
    let num-coda = if has-coda { coda-segments.len() } else { 0 }

    let segment-spacing = 0.35
    let min-gap = 0.75

    // Headedness: Rhyme is head of syllable, Nucleus is head of Rhyme
    let rhyme-x = x-offset
    let nucleus-x = rhyme-x

    // Adaptive positioning for onset
    let onset-x = if has-onset {
      let min-offset = (num-onset - 1) * segment-spacing / 2 + (num-nucleus - 1) * segment-spacing / 2 + min-gap
      let default-offset = 0.7
      if min-offset > default-offset { x-offset - min-offset } else { x-offset - default-offset }
    } else {
      x-offset
    }

    // Adaptive positioning for coda
    let coda-x = if has-coda {
      let min-offset = (num-nucleus + num-coda - 2) * segment-spacing / 2 + min-gap
      let default-offset = 0.7
      if min-offset > default-offset { rhyme-x + min-offset } else { rhyme-x + default-offset }
    } else {
      rhyme-x
    }

    // Syllable node
    content((x-offset, sigma-y + 0.54), context text(
      size: 12 * diagram-scale * 1pt,
      font: phonokit-font.get(),
    )[#sym_syll])

    // Onset branches (if exists)
    if has-onset {
      line((x-offset, sigma-y + 0.25), (onset-x, or-level + 0.30))
      content((onset-x, or-level), context text(size: 10 * diagram-scale * 1pt, font: phonokit-font.get())[O])

      let onset-total-width = (num-onset - 1) * segment-spacing
      let onset-start-x = onset-x - onset-total-width / 2

      for (i, segment) in onset-segments.enumerate() {
        let seg-x = onset-start-x + i * segment-spacing
        line((onset-x, or-level - 0.35), (seg-x, terminal-y + line-offset))
        content(
          (seg-x, terminal-y + text-offset),
          context text(size: 11 * diagram-scale * 1pt, font: phonokit-font.get(), bottom-edge: "descender")[#segment],
          anchor: "north",
        )
      }
    }

    // Rhyme branch
    line((x-offset, sigma-y + 0.25), (rhyme-x, or-level + 0.30))
    content((rhyme-x, or-level), context text(size: 10 * diagram-scale * 1pt, font: phonokit-font.get())[R])

    // Nucleus
    line((rhyme-x, or-level - 0.35), (nucleus-x, n-level + 0.35))
    content((nucleus-x, n-level), context text(size: 10 * diagram-scale * 1pt, font: phonokit-font.get())[N])

    // Branch to each nucleus segment
    let nucleus-total-width = (num-nucleus - 1) * segment-spacing
    let nucleus-start-x = nucleus-x - nucleus-total-width / 2

    for (i, segment) in nucleus-segments.enumerate() {
      let seg-x = nucleus-start-x + i * segment-spacing
      line((nucleus-x, n-level - 0.25), (seg-x, terminal-y + line-offset))
      content(
        (seg-x, terminal-y + text-offset),
        context text(size: 11 * diagram-scale * 1pt, font: phonokit-font.get(), bottom-edge: "descender")[#segment],
        anchor: "north",
      )
    }

    // Coda (if exists)
    if has-coda {
      line((rhyme-x, or-level - 0.35), (coda-x, n-level + 0.35))
      content((coda-x, n-level), context text(size: 10 * diagram-scale * 1pt, font: phonokit-font.get())[C])

      let coda-total-width = (num-coda - 1) * segment-spacing
      let coda-start-x = coda-x - coda-total-width / 2

      for (i, segment) in coda-segments.enumerate() {
        let seg-x = coda-start-x + i * segment-spacing
        line((coda-x, n-level - 0.25), (seg-x, terminal-y + line-offset))
        content(
          (seg-x, terminal-y + text-offset),
          context text(size: 11 * diagram-scale * 1pt, font: phonokit-font.get(), bottom-edge: "descender")[#segment],
          anchor: "north",
        )
      }
    }
  }))
}

// Visualizes moraic structure (Hyman 1976)
// Onsets: non-moraic (connect directly to σ)
// Nucleus: always moraic (connects to μ, which connects to σ)
// Coda: optionally moraic (coda: false → connects to σ; coda: true → connects to μ)
#let mora(input, coda: false, scale: 1.0, symbol: ("σ", "μ"), distance: none, spacing: "auto") = {
  check-spacing(spacing)
  // Check for syllable boundary markers
  if input.contains(".") {
    return text(fill: red, weight: "bold")[⚠ Warning: For more than one syllable, use \#foot() or \#word().]
  }

  // Check for problematic diacritic sequences
  let problematic-sequences = ("''", ",,", "\\* \\*", "\\t \\t", "::", "((", "))")
  for seq in problematic-sequences {
    if input.contains(seq) {
      return text(fill: red, weight: "bold")[⚠ Warning: Problematic sequence involving diacritics: "#seq"]
    }
  }

  // Convert IPA-style input to Unicode
  let converted = convert-prosody-input(input)

  // Parse syllable
  // Strip ALL stress markers (' for primary, , for secondary) regardless of position
  let clean-input = converted.replace("'", "").replace(",", "")

  let parsed = parse-syllable(clean-input)

  // Check for too many codas (limit: 5 to avoid crossing lines)
  let coda-segments-temp = if parsed.coda != "" { smart-clusters(parsed.coda) } else { () }
  if coda-segments-temp.len() > 5 {
    return text(
      fill: red,
      weight: "bold",
    )[⚠ Warning: Too many coda consonants (max 5 to avoid line crossings). Found: #coda-segments-temp.len()]
  }

  // Check for too many onsets (limit: 5 to avoid crossing lines)
  let onset-segments-temp = if parsed.onset != "" { smart-clusters(parsed.onset) } else { () }
  if onset-segments-temp.len() > 5 {
    return text(
      fill: red,
      weight: "bold",
    )[⚠ Warning: Too many onset consonants (max 5 to avoid line crossings). Found: #onset-segments-temp.len()]
  }

  // Check for too many nucleus segments (limit: 5)
  let nucleus-segments-temp = smart-clusters(parsed.nucleus)
  if nucleus-segments-temp.len() > 5 {
    return text(
      fill: red,
      weight: "bold",
    )[⚠ Warning: Too many nucleus segments (max 5 to avoid line crossings). Found: #nucleus-segments-temp.len()]
  }

  let sym_syll = symbol.at(0, default: "σ")
  let sym_mora = symbol.at(1, default: "μ")

  let diagram-scale = scale
  box(baseline: 50%, cetz.canvas(length: 1cm * diagram-scale, {
    import cetz.draw: *
    set-style(stroke: 0.7 * diagram-scale * 1pt)

    let line-len(natural, level) = tier-line(natural, distance, level)

    let sigma-y = 0
    let segment-spacing = 0.35
    let x-offset = 0

    // Syllable node
    content((x-offset, sigma-y + 0.54), context text(
      size: 12 * diagram-scale * 1pt,
      font: phonokit-font.get(),
    )[#sym_syll])

    // Calculate segment counts
    let onset-segments = if parsed.onset != "" { smart-clusters(parsed.onset) } else { () }
    let nucleus-segments = smart-clusters(parsed.nucleus)
    let coda-segments = if parsed.coda != "" { smart-clusters(parsed.coda) } else { () }

    let num-onset = onset-segments.len()
    let num-nucleus = nucleus-segments.len()
    let num-coda = coda-segments.len()

    // Default lines never get shorter going up the tree (each is at least as
    // long as the one directly below it); explicit `distance` factors are
    // applied afterwards. No upper tiers here, so `spacing` has no effect.

    // Position calculations (σ→μ = level 0, μ→segments = level 1)
    let mu-seg-line = 0.55
    let sigma-mu-line = calc.max(0.70, mu-seg-line)
    let mora-y = sigma-y + 0.25 - line-len(sigma-mu-line, 0) - 0.35
    let terminal-y = mora-y - 0.35 - line-len(mu-seg-line, 1) - 0.30
    let nucleus-mora-x = x-offset

    // Onset position (left of nucleus mora)
    // Adaptive positioning: move left based on number of segments to avoid crossings
    let reach = moraic-reach(sigma-y, mora-y, terminal-y, long: parsed.nucleus.contains("ː"))
    let onset-x = if num-onset > 0 {
      let min-offset = (num-onset - 1) * segment-spacing / 2 + 0.8
      let default-offset = 1.2
      let clear-offset = reach + (num-onset - 1) * segment-spacing / 2
      nucleus-mora-x - calc.max(min-offset, default-offset, clear-offset)
    } else {
      nucleus-mora-x
    }

    // Coda position (right of nucleus mora)
    // Adaptive positioning: move right based on number of segments to avoid crossings
    let coda-x = if num-coda > 0 {
      let min-offset = (num-coda - 1) * segment-spacing / 2 + 0.8
      let default-offset = 1.2
      // A non-moraic coda hangs from σ like an onset
      let clear-offset = if coda { 0 } else { reach + (num-coda - 1) * segment-spacing / 2 }
      nucleus-mora-x + calc.max(min-offset, default-offset, clear-offset)
    } else {
      nucleus-mora-x
    }

    // Draw ONSET (non-moraic - connects directly to σ)
    if num-onset > 0 {
      let onset-total-width = (num-onset - 1) * segment-spacing
      let onset-start-x = onset-x - onset-total-width / 2

      for (i, segment) in onset-segments.enumerate() {
        let seg-x = onset-start-x + i * segment-spacing
        line((x-offset, sigma-y + 0.25), (seg-x, terminal-y + 0.30))
        content(
          (seg-x, terminal-y),
          context text(size: 11 * diagram-scale * 1pt, font: phonokit-font.get(), bottom-edge: "descender")[#segment],
          anchor: "north",
        )
      }
    }

    // Check if nucleus contains long vowel (Vː)
    let has-long-vowel = parsed.nucleus.contains("ː")

    // Draw NUCLEUS MORA(E) - one mora for short vowel, two for long vowel
    if has-long-vowel {
      // Long vowel: draw TWO morae that branch from σ and converge on Vː
      let mora-spacing = long-mora-spacing
      let mora1-x = nucleus-mora-x - mora-spacing / 2
      let mora2-x = nucleus-mora-x + mora-spacing / 2

      // Draw two μ nodes
      content((mora1-x, mora-y), context text(size: 12 * diagram-scale * 1pt, font: phonokit-font.get())[#sym_mora])
      content((mora2-x, mora-y), context text(size: 12 * diagram-scale * 1pt, font: phonokit-font.get())[#sym_mora])

      // Lines from σ to both morae
      line((x-offset, sigma-y + 0.25), (mora1-x, mora-y + 0.35))
      line((x-offset, sigma-y + 0.25), (mora2-x, mora-y + 0.35))

      // Both morae converge to the long vowel segment
      let nucleus-total-width = (num-nucleus - 1) * segment-spacing
      let nucleus-start-x = nucleus-mora-x - nucleus-total-width / 2

      for (i, segment) in nucleus-segments.enumerate() {
        let seg-x = nucleus-start-x + i * segment-spacing
        // Lines from both morae converge to the segment
        line((mora1-x, mora-y - 0.35), (seg-x, terminal-y + 0.30))
        line((mora2-x, mora-y - 0.35), (seg-x, terminal-y + 0.30))
        content(
          (seg-x, terminal-y),
          context text(size: 11 * diagram-scale * 1pt, font: phonokit-font.get(), bottom-edge: "descender")[#segment],
          anchor: "north",
        )
      }
    } else {
      // Short vowel: one mora
      content((nucleus-mora-x, mora-y), context text(
        size: 12 * diagram-scale * 1pt,
        font: phonokit-font.get(),
      )[#sym_mora])
      line((x-offset, sigma-y + 0.25), (nucleus-mora-x, mora-y + 0.35))

      // Draw nucleus segments below mora
      let nucleus-total-width = (num-nucleus - 1) * segment-spacing
      let nucleus-start-x = nucleus-mora-x - nucleus-total-width / 2

      for (i, segment) in nucleus-segments.enumerate() {
        let seg-x = nucleus-start-x + i * segment-spacing
        line((nucleus-mora-x, mora-y - 0.35), (seg-x, terminal-y + 0.30))
        content(
          (seg-x, terminal-y),
          context text(size: 11 * diagram-scale * 1pt, font: phonokit-font.get(), bottom-edge: "descender")[#segment],
          anchor: "north",
        )
      }
    }

    // Draw CODA
    if num-coda > 0 {
      if coda {
        // Moraic coda: ONE μ for all coda segments (they share the mora)
        // Draw the coda μ
        content((coda-x, mora-y), context text(size: 12 * diagram-scale * 1pt, font: phonokit-font.get())[#sym_mora])

        // Line from σ to coda μ
        line((x-offset, sigma-y + 0.25), (coda-x, mora-y + 0.35))

        // All coda segments branch from this single μ
        let coda-total-width = (num-coda - 1) * segment-spacing
        let coda-start-x = coda-x - coda-total-width / 2

        for (i, segment) in coda-segments.enumerate() {
          let seg-x = coda-start-x + i * segment-spacing

          // Line from shared μ to each segment
          line((coda-x, mora-y - 0.35), (seg-x, terminal-y + 0.30))

          // Draw segment
          content(
            (seg-x, terminal-y),
            context text(size: 11 * diagram-scale * 1pt, font: phonokit-font.get(), bottom-edge: "descender")[#segment],
            anchor: "north",
          )
        }
      } else {
        // Non-moraic coda: connects directly to σ
        let coda-total-width = (num-coda - 1) * segment-spacing
        let coda-start-x = coda-x - coda-total-width / 2

        for (i, segment) in coda-segments.enumerate() {
          let seg-x = coda-start-x + i * segment-spacing
          line((x-offset, sigma-y + 0.25), (seg-x, terminal-y + 0.30))
          content(
            (seg-x, terminal-y),
            context text(size: 11 * diagram-scale * 1pt, font: phonokit-font.get(), bottom-edge: "descender")[#segment],
            anchor: "north",
          )
        }
      }
    }
  }))
}

// Helper function to draw moraic structure (used by foot.mora and word.mora)
#let draw-moraic-structure(
  x-offset,
  sigma-y,
  syll,
  terminal-y,
  coda: false,
  diagram-scale: 1.0,
  geminate-coda-x: none,
  geminate-onset-x: none,
  mora-symbol: "μ",
  mora-y-override: none,
) = {
  import cetz.draw: *

  let segment-spacing = 0.35

  // Calculate segment counts
  let onset-segments = if syll.onset != "" { smart-clusters(syll.onset) } else { () }
  let nucleus-segments = smart-clusters(syll.nucleus)
  let coda-segments = if syll.coda != "" { smart-clusters(syll.coda) } else { () }

  let num-onset = onset-segments.len()
  let num-nucleus = nucleus-segments.len()
  let num-coda = coda-segments.len()

  // Check if nucleus contains long vowel (needed for spacing calculations)
  let has-long-vowel = syll.nucleus.contains("ː")

  // Position calculations
  let mora-y = if mora-y-override != none { mora-y-override } else { 0.4 * (sigma-y + 0.54) + 0.6 * terminal-y }
  let nucleus-mora-x = x-offset

  // Adaptive onset position (same formula as draw-syllable-structure for uniform spacing)
  let reach = moraic-reach(sigma-y, mora-y, terminal-y, long: has-long-vowel)
  let onset-x = if num-onset > 0 {
    let min-gap = 0.75
    let min-offset = (num-onset - 1) * segment-spacing / 2 + (num-nucleus - 1) * segment-spacing / 2 + min-gap
    let default-offset = 0.7
    let clear-offset = reach + (num-onset - 1) * segment-spacing / 2
    nucleus-mora-x - calc.max(min-offset, default-offset, clear-offset)
  } else {
    nucleus-mora-x
  }

  // Adaptive coda position (same formula as draw-syllable-structure for uniform spacing)
  let coda-x = if num-coda > 0 {
    let min-gap = 0.75
    let min-offset = (num-nucleus + num-coda - 2) * segment-spacing / 2 + min-gap
    let default-offset = 0.7
    // A non-moraic coda hangs from σ like an onset
    let clear-offset = if coda { 0 } else { reach + (num-coda - 1) * segment-spacing / 2 }
    nucleus-mora-x + calc.max(min-offset, default-offset, clear-offset)
  } else {
    nucleus-mora-x
  }

  // Draw ONSET (non-moraic - connects directly to σ)
  if num-onset > 0 {
    // Check if this is a geminate onset
    if geminate-onset-x != none {
      // Geminate: draw line to geminate position
      line((x-offset, sigma-y + 0.25), (geminate-onset-x, terminal-y + 0.30))
    } else {
      // Normal onset: draw branches to individual segments
      let onset-total-width = (num-onset - 1) * segment-spacing
      let onset-start-x = onset-x - onset-total-width / 2

      for (i, segment) in onset-segments.enumerate() {
        let seg-x = onset-start-x + i * segment-spacing
        line((x-offset, sigma-y + 0.25), (seg-x, terminal-y + 0.30))
        content(
          (seg-x, terminal-y),
          context text(size: 11 * diagram-scale * 1pt, font: phonokit-font.get(), bottom-edge: "descender")[#segment],
          anchor: "north",
        )
      }
    }
  }

  // Draw NUCLEUS MORA(E)
  if has-long-vowel {
    // Long vowel: TWO morae
    let mora-spacing = long-mora-spacing
    let mora1-x = nucleus-mora-x - mora-spacing / 2
    let mora2-x = nucleus-mora-x + mora-spacing / 2

    content((mora1-x, mora-y), context text(size: 12 * diagram-scale * 1pt, font: phonokit-font.get())[#mora-symbol])
    content((mora2-x, mora-y), context text(size: 12 * diagram-scale * 1pt, font: phonokit-font.get())[#mora-symbol])

    line((x-offset, sigma-y + 0.25), (mora1-x, mora-y + 0.35))
    line((x-offset, sigma-y + 0.25), (mora2-x, mora-y + 0.35))

    let nucleus-total-width = (num-nucleus - 1) * segment-spacing
    let nucleus-start-x = nucleus-mora-x - nucleus-total-width / 2

    for (i, segment) in nucleus-segments.enumerate() {
      let seg-x = nucleus-start-x + i * segment-spacing
      line((mora1-x, mora-y - 0.35), (seg-x, terminal-y + 0.30))
      line((mora2-x, mora-y - 0.35), (seg-x, terminal-y + 0.30))
      content(
        (seg-x, terminal-y),
        context text(size: 11 * diagram-scale * 1pt, font: phonokit-font.get(), bottom-edge: "descender")[#segment],
        anchor: "north",
      )
    }
  } else {
    // Short vowel: ONE mora
    content((nucleus-mora-x, mora-y), context text(
      size: 12 * diagram-scale * 1pt,
      font: phonokit-font.get(),
    )[#mora-symbol])
    line((x-offset, sigma-y + 0.25), (nucleus-mora-x, mora-y + 0.35))

    let nucleus-total-width = (num-nucleus - 1) * segment-spacing
    let nucleus-start-x = nucleus-mora-x - nucleus-total-width / 2

    for (i, segment) in nucleus-segments.enumerate() {
      let seg-x = nucleus-start-x + i * segment-spacing
      line((nucleus-mora-x, mora-y - 0.35), (seg-x, terminal-y + 0.30))
      content(
        (seg-x, terminal-y),
        context text(size: 11 * diagram-scale * 1pt, font: phonokit-font.get(), bottom-edge: "descender")[#segment],
        anchor: "north",
      )
    }
  }

  // Draw CODA
  if num-coda > 0 {
    if coda {
      // Moraic coda: ONE μ shared by all segments
      content((coda-x, mora-y), context text(size: 12 * diagram-scale * 1pt, font: phonokit-font.get())[#mora-symbol])
      line((x-offset, sigma-y + 0.25), (coda-x, mora-y + 0.35))

      // Check if this is a geminate coda
      if geminate-coda-x != none {
        // Geminate: draw line to geminate position
        line((coda-x, mora-y - 0.35), (geminate-coda-x, terminal-y + 0.30))
      } else {
        // Normal coda: all segments branch from shared μ
        let coda-total-width = (num-coda - 1) * segment-spacing
        let coda-start-x = coda-x - coda-total-width / 2

        for (i, segment) in coda-segments.enumerate() {
          let seg-x = coda-start-x + i * segment-spacing
          line((coda-x, mora-y - 0.35), (seg-x, terminal-y + 0.30))
          content(
            (seg-x, terminal-y),
            context text(size: 11 * diagram-scale * 1pt, font: phonokit-font.get(), bottom-edge: "descender")[#segment],
            anchor: "north",
          )
        }
      }
    } else {
      // Non-moraic coda: connects directly to σ
      // Check if this is a geminate coda
      if geminate-coda-x != none {
        // Geminate: draw line to geminate position
        line((x-offset, sigma-y + 0.25), (geminate-coda-x, terminal-y + 0.30))
      } else {
        // Normal coda: branches to individual segments
        let coda-total-width = (num-coda - 1) * segment-spacing
        let coda-start-x = coda-x - coda-total-width / 2

        for (i, segment) in coda-segments.enumerate() {
          let seg-x = coda-start-x + i * segment-spacing
          line((x-offset, sigma-y + 0.25), (seg-x, terminal-y + 0.30))
          content(
            (seg-x, terminal-y),
            context text(size: 11 * diagram-scale * 1pt, font: phonokit-font.get(), bottom-edge: "descender")[#segment],
            anchor: "north",
          )
        }
      }
    }
  }
}

// Visualizes foot and syllable levels
// Now accepts IPA-style input like "k a.'v a.l o"
#let foot(input, scale: 1.0, symbol: ("Σ", "σ"), distance: none, spacing: "auto") = {
  check-spacing(spacing)
  // Check for parentheses (foot should not have multiple feet)
  if input.contains("(") or input.contains(")") {
    return text(
      fill: red,
      weight: "bold",
    )[⚠ Warning: foot() is for a single foot. If you need multiple feet, use word() instead.]
  }

  // Convert IPA-style input to Unicode
  let converted = convert-prosody-input(input)

  // Parse syllables from dotted input
  let syllables = ()
  let buffer = ""
  let chars = converted.codepoints()
  let i = 0

  while i < chars.len() {
    let char = chars.at(i)

    if char == "." {
      if buffer != "" {
        let clean-buffer = if buffer.starts-with("'") { buffer.slice(1) } else { buffer }
        let parsed = parse-syllable(clean-buffer)
        syllables.push((
          onset: parsed.onset,
          nucleus: parsed.nucleus,
          coda: parsed.coda,
          stressed: buffer.starts-with("'"),
        ))
        buffer = ""
      }
    } else {
      buffer += char
    }
    i += 1
  }

  // Handle remaining buffer
  if buffer != "" {
    let clean-buffer = if buffer.starts-with("'") { buffer.slice(1) } else { buffer }
    let parsed = parse-syllable(clean-buffer)
    syllables.push((
      onset: parsed.onset,
      nucleus: parsed.nucleus,
      coda: parsed.coda,
      stressed: buffer.starts-with("'"),
    ))
  }

  // Check for too many onsets/codas/nucleus in any syllable (limit: 5 to avoid crossing lines)
  for (i, syll) in syllables.enumerate() {
    let coda-segments-temp = if syll.coda != "" { smart-clusters(syll.coda) } else { () }
    if coda-segments-temp.len() > 5 {
      return text(
        fill: red,
        weight: "bold",
      )[⚠ Warning: Too many coda consonants in syllable #(i + 1) (max 5 to avoid line crossings). Found: #coda-segments-temp.len()]
    }
    let onset-segments-temp = if syll.onset != "" { smart-clusters(syll.onset) } else { () }
    if onset-segments-temp.len() > 5 {
      return text(
        fill: red,
        weight: "bold",
      )[⚠ Warning: Too many onset consonants in syllable #(i + 1) (max 5 to avoid line crossings). Found: #onset-segments-temp.len()]
    }
    let nucleus-segments-temp = smart-clusters(syll.nucleus)
    if nucleus-segments-temp.len() > 5 {
      return text(
        fill: red,
        weight: "bold",
      )[⚠ Warning: Too many nucleus segments in syllable #(i + 1) (max 5 to avoid line crossings). Found: #nucleus-segments-temp.len()]
    }
  }

  // Find stressed syllable (head of foot)
  let head-idx = 0
  for (i, syll) in syllables.enumerate() {
    if syll.stressed {
      head-idx = i
      break
    }
  }

  let sym_foot = symbol.at(0, default: "Σ")
  let sym_syll = symbol.at(1, default: "σ")

  let diagram-scale = scale

  box(baseline: 50%, cetz.canvas(length: 1cm * diagram-scale, {
    import cetz.draw: *
    set-style(stroke: 0.7 * diagram-scale * 1pt)

    let line-len(natural, level) = tier-line(natural, distance, level)

    let segment-spacing = 0.35
    let min-gap-between-sylls = 0.8
    let default-spacing = 1.6

    // Calculate extents for each syllable
    let syllable-extents = ()
    for syll in syllables {
      let has-onset = syll.onset != ""
      let has-coda = syll.coda != ""
      let num-onset = if has-onset { smart-clusters(syll.onset).len() } else { 0 }
      let num-nucleus = smart-clusters(syll.nucleus).len()
      let num-coda = if has-coda { smart-clusters(syll.coda).len() } else { 0 }
      let min-gap = 0.75

      // Calculate constituent positions
      let onset-x-rel = if has-onset {
        let min-offset = (num-onset - 1) * segment-spacing / 2 + (num-nucleus - 1) * segment-spacing / 2 + min-gap
        let default-offset = 0.7
        if min-offset > default-offset { -min-offset } else { -default-offset }
      } else { 0 }

      let coda-x-rel = if has-coda {
        let min-offset = (num-nucleus + num-coda - 2) * segment-spacing / 2 + 0.4
        let default-offset = 0.7
        if min-offset > default-offset { min-offset } else { default-offset }
      } else { 0 }

      // Calculate segment widths
      let onset-width = if has-onset { (num-onset - 1) * segment-spacing } else { 0 }
      let nucleus-width = (num-nucleus - 1) * segment-spacing
      let coda-width = if has-coda { (num-coda - 1) * segment-spacing } else { 0 }

      // Calculate left and right extents
      let left-parts = (
        if has-onset { onset-x-rel - onset-width / 2 } else { 0 },
        -nucleus-width / 2,
        if has-coda { coda-x-rel - coda-width / 2 } else { 0 },
      )
      let right-parts = (
        if has-onset { onset-x-rel + onset-width / 2 } else { 0 },
        nucleus-width / 2,
        if has-coda { coda-x-rel + coda-width / 2 } else { 0 },
      )

      let left-extent = calc.min(..left-parts)
      let right-extent = calc.max(..right-parts)

      syllable-extents.push((left: left-extent, right: right-extent))
    }

    // Calculate adaptive spacing and positions
    let syllable-positions = ()
    for (i, extent) in syllable-extents.enumerate() {
      if i == 0 {
        syllable-positions.push(0)
      } else {
        let prev-right = syllable-extents.at(i - 1).right
        let required-spacing = prev-right - extent.left + min-gap-between-sylls
        let actual-spacing = calc.max(required-spacing, default-spacing)
        let prev-position = syllable-positions.at(i - 1)
        syllable-positions.push(prev-position + actual-spacing)
      }
    }

    // Center the structure
    let first-left = syllable-positions.at(0) + syllable-extents.at(0).left
    let last-right = syllable-positions.at(-1) + syllable-extents.at(-1).right
    let total-width = last-right - first-left
    let start-x = -total-width / 2 - first-left

    let foot-x = start-x + syllable-positions.at(head-idx)

    // Default lines never get shorter going up the tree (each is at least as
    // long as the one directly below it); explicit `distance` factors are
    // applied afterwards. spacing: "auto" additionally lengthens upper lines
    // to fit wide branches; "fixed" keeps them constant so trees align.
    let fit = spacing == "auto"

    // Sub-syllable tiers (σ → O/R → N/C → segments)
    let n-seg-line = 0.40
    let or-n-line = calc.max(0.25, n-seg-line)
    let sigma-or-line = calc.max(0.70, or-n-line)
    let sigma-y = -2.4
    let sigma-y-label = sigma-y + 0.54
    let or-y = sigma-y-label - 0.29 - line-len(sigma-or-line, 1) - 0.30
    let n-y = or-y - 0.35 - line-len(or-n-line, 2) - 0.30
    let terminal-y = n-y - 0.25 - line-len(n-seg-line, 3) - 0.30
    let below-sigma-line = sigma-or-line

    // Σ → σ: "auto" fits the line to the widest branch; "fixed" grows it with the syllable count
    let foot-run = 0
    for (i, _) in syllables.enumerate() {
      foot-run = calc.max(foot-run, calc.abs(start-x + syllable-positions.at(i) - foot-x))
    }
    let foot-line = if fit {
      calc.max(0.45, branch-slope * foot-run, below-sigma-line)
    } else { below-sigma-line }
    let ft-height = sigma-y-label + 0.26 + line-len(foot-line, 0) + 0.25

    // Draw Ft node above the head
    content((foot-x, ft-height), context text(size: 12 * diagram-scale * 1pt, font: phonokit-font.get())[#sym_foot])

    // Detect geminates
    // A geminate occurs when the last consonant of a coda matches the first consonant of the next onset
    let geminates = ()
    for i in range(syllables.len() - 1) {
      if syllables.at(i).coda != "" and syllables.at(i + 1).onset != "" {
        let coda-segments = smart-clusters(syllables.at(i).coda)
        let onset-segments = smart-clusters(syllables.at(i + 1).onset)
        let last-coda = coda-segments.at(-1)
        let first-onset = onset-segments.at(0)

        // Check if they match and are consonants (not vowels)
        if last-coda == first-onset and not is-vowel(last-coda) {
          let gem-x = start-x + (syllable-positions.at(i) + syllable-positions.at(i + 1)) / 2
          geminates.push((syll-idx: i, gem-x: gem-x, gem-text: last-coda))
        }
      }
    }

    // Draw syllables
    for (i, syll) in syllables.enumerate() {
      let x-offset = start-x + syllable-positions.at(i)

      // Syllable node
      content((x-offset, sigma-y + 0.54), context text(
        size: 12 * diagram-scale * 1pt,
        font: phonokit-font.get(),
      )[#sym_syll])

      // Line from Ft to σ
      line((foot-x, ft-height - 0.25), (x-offset, sigma-y + 0.8))

      // Check for geminate
      let gem-coda-x = none
      let gem-coda-text = none
      let gem-onset-x = none
      let gem-onset-text = none
      for gem in geminates {
        if gem.syll-idx == i {
          gem-coda-x = gem.gem-x
          gem-coda-text = gem.gem-text
        }
        if gem.syll-idx == i - 1 {
          gem-onset-x = gem.gem-x
          gem-onset-text = gem.gem-text
        }
      }

      draw-syllable-structure(
        x-offset,
        sigma-y,
        syll,
        terminal-y,
        diagram-scale: diagram-scale,
        geminate-coda-x: gem-coda-x,
        geminate-onset-x: gem-onset-x,
        geminate-coda-text: gem-coda-text,
        geminate-onset-text: gem-onset-text,
        or-y: or-y,
        n-y: n-y,
      )
    }

    // Draw geminate segments
    for gem in geminates {
      content(
        (gem.gem-x, terminal-y),
        context text(size: 11 * diagram-scale * 1pt, font: phonokit-font.get(), bottom-edge: "descender")[#gem.gem-text],
        anchor: "north",
      )
    }
  }))
}

// Visualizes word, foot, and syllable levels
// Now accepts IPA-style input like "(k a.'v a).l o"
#let word(input, foot: "R", scale: 1.0, symbol: ("ω", "Σ", "σ"), distance: none, spacing: "auto") = {
  check-spacing(spacing)
  // Convert IPA-style input to Unicode
  let converted = convert-prosody-input(input)

  let syllables = ()
  let feet = ()
  let current-foot = ()
  let in-foot = false
  let buffer = ""

  let chars = converted.codepoints()
  let i = 0

  while i < chars.len() {
    let char = chars.at(i)

    if char == "(" {
      in-foot = true
      current-foot = ()
    } else if char == ")" {
      if buffer != "" {
        let clean-buffer = if buffer.starts-with("'") { buffer.slice(1) } else { buffer }
        let parsed = parse-syllable(clean-buffer)
        syllables.push((
          onset: parsed.onset,
          nucleus: parsed.nucleus,
          coda: parsed.coda,
          stressed: buffer.starts-with("'"),
        ))
        current-foot.push(syllables.len() - 1)
        buffer = ""
      }
      if current-foot.len() > 0 {
        feet.push(current-foot)
      }
      in-foot = false
    } else if char == "." {
      if buffer != "" {
        let clean-buffer = if buffer.starts-with("'") { buffer.slice(1) } else { buffer }
        let parsed = parse-syllable(clean-buffer)
        syllables.push((
          onset: parsed.onset,
          nucleus: parsed.nucleus,
          coda: parsed.coda,
          stressed: buffer.starts-with("'"),
        ))

        if in-foot {
          current-foot.push(syllables.len() - 1)
        }

        buffer = ""
      }
    } else {
      buffer += char
    }

    i += 1
  }

  // Handle remaining buffer
  if buffer != "" {
    let clean-buffer = if buffer.starts-with("'") { buffer.slice(1) } else { buffer }
    let parsed = parse-syllable(clean-buffer)
    syllables.push((
      onset: parsed.onset,
      nucleus: parsed.nucleus,
      coda: parsed.coda,
      stressed: buffer.starts-with("'"),
    ))

    if in-foot {
      current-foot.push(syllables.len() - 1)
    }
  }

  // Check for too many onsets/codas/nucleus in any syllable (limit: 5 to avoid crossing lines)
  for (i, syll) in syllables.enumerate() {
    let coda-segments-temp = if syll.coda != "" { smart-clusters(syll.coda) } else { () }
    if coda-segments-temp.len() > 5 {
      return text(
        fill: red,
        weight: "bold",
      )[⚠ Warning: Too many coda consonants in syllable #(i + 1) (max 5 to avoid line crossings). Found: #coda-segments-temp.len()]
    }
    let onset-segments-temp = if syll.onset != "" { smart-clusters(syll.onset) } else { () }
    if onset-segments-temp.len() > 5 {
      return text(
        fill: red,
        weight: "bold",
      )[⚠ Warning: Too many onset consonants in syllable #(i + 1) (max 5 to avoid line crossings). Found: #onset-segments-temp.len()]
    }
    let nucleus-segments-temp = smart-clusters(syll.nucleus)
    if nucleus-segments-temp.len() > 5 {
      return text(
        fill: red,
        weight: "bold",
      )[⚠ Warning: Too many nucleus segments in syllable #(i + 1) (max 5 to avoid line crossings). Found: #nucleus-segments-temp.len()]
    }
  }

  // Determine which syllables are in feet
  let in-foot-set = ()
  for foot in feet {
    for syll-idx in foot {
      in-foot-set.push(syll-idx)
    }
  }

  let sym_word = symbol.at(0, default: "ω")
  let sym_foot = symbol.at(1, default: "Σ")
  let sym_syll = symbol.at(2, default: "σ")

  let diagram-scale = scale

  // Draw the structure
  box(baseline: 50%, cetz.canvas(length: 1cm * diagram-scale, {
    import cetz.draw: *

    set-style(stroke: 0.7 * diagram-scale * 1pt)

    let segment-spacing = 0.35
    let min-gap-between-sylls = 0.8
    let default-spacing = 1.6

    let line-len(natural, level) = tier-line(natural, distance, level)

    // Default lines never get shorter going up the tree (each is at least as
    // long as the one directly below it); explicit `distance` factors are
    // applied afterwards. spacing: "auto" additionally lengthens upper lines
    // to fit wide branches; "fixed" keeps them constant so trees align.
    let fit = spacing == "auto"

    // Sub-syllable tiers (σ → O/R → N/C → segments)
    let n-seg-line = 0.40
    let or-n-line = calc.max(0.25, n-seg-line)
    let sigma-or-line = calc.max(0.70, or-n-line)
    let sigma-y = -2.4
    let sigma-y-label = sigma-y + 0.54
    let or-y = sigma-y-label - 0.29 - line-len(sigma-or-line, 2) - 0.30
    let n-y = or-y - 0.35 - line-len(or-n-line, 3) - 0.30
    let terminal-y = n-y - 0.25 - line-len(n-seg-line, 4) - 0.30
    let below-sigma-line = sigma-or-line


    // Calculate extents for each syllable
    let syllable-extents = ()
    for syll in syllables {
      let has-onset = syll.onset != ""
      let has-coda = syll.coda != ""
      let num-onset = if has-onset { smart-clusters(syll.onset).len() } else { 0 }
      let num-nucleus = smart-clusters(syll.nucleus).len()
      let num-coda = if has-coda { smart-clusters(syll.coda).len() } else { 0 }
      let min-gap = 0.75

      let onset-x-rel = if has-onset {
        let min-offset = (num-onset - 1) * segment-spacing / 2 + (num-nucleus - 1) * segment-spacing / 2 + min-gap
        let default-offset = 0.7
        if min-offset > default-offset { -min-offset } else { -default-offset }
      } else { 0 }

      let coda-x-rel = if has-coda {
        let min-offset = (num-nucleus + num-coda - 2) * segment-spacing / 2 + 0.4
        let default-offset = 0.7
        if min-offset > default-offset { min-offset } else { default-offset }
      } else { 0 }

      let onset-width = if has-onset { (num-onset - 1) * segment-spacing } else { 0 }
      let nucleus-width = (num-nucleus - 1) * segment-spacing
      let coda-width = if has-coda { (num-coda - 1) * segment-spacing } else { 0 }

      let left-parts = (
        if has-onset { onset-x-rel - onset-width / 2 } else { 0 },
        -nucleus-width / 2,
        if has-coda { coda-x-rel - coda-width / 2 } else { 0 },
      )
      let right-parts = (
        if has-onset { onset-x-rel + onset-width / 2 } else { 0 },
        nucleus-width / 2,
        if has-coda { coda-x-rel + coda-width / 2 } else { 0 },
      )

      let left-extent = calc.min(..left-parts)
      let right-extent = calc.max(..right-parts)

      syllable-extents.push((left: left-extent, right: right-extent))
    }

    // Calculate adaptive spacing and positions
    let syllable-positions = ()
    for (i, extent) in syllable-extents.enumerate() {
      if i == 0 {
        syllable-positions.push(0)
      } else {
        let prev-right = syllable-extents.at(i - 1).right
        let required-spacing = prev-right - extent.left + min-gap-between-sylls
        let actual-spacing = calc.max(required-spacing, default-spacing)
        let prev-position = syllable-positions.at(i - 1)
        syllable-positions.push(prev-position + actual-spacing)
      }
    }

    // Center the structure
    let first-left = syllable-positions.at(0) + syllable-extents.at(0).left
    let last-right = syllable-positions.at(-1) + syllable-extents.at(-1).right
    let total-width = last-right - first-left
    let start-x = -total-width / 2 - first-left

    // Determine PWd x-position
    let pwd-x = 0

    if feet.len() > 0 {
      let target-foot = if foot == "L" { feet.at(0) } else { feet.at(-1) }

      let head-idx = target-foot.at(0)
      for syll-idx in target-foot {
        if syllables.at(syll-idx).stressed {
          head-idx = syll-idx
          break
        }
      }
      pwd-x = start-x + syllable-positions.at(head-idx)
    } else if syllables.len() > 0 {
      // If the user marked stress with ' (even without using feet), align
      // the PWd node to that syllable instead of defaulting to L/R extremes.
      let stressed-idx = none
      for (idx, syll) in syllables.enumerate() {
        if syll.stressed {
          stressed-idx = idx
          break
        }
      }
      let target-idx = if stressed-idx != none {
        stressed-idx
      } else if foot == "L" { 0 } else { syllables.len() - 1 }
      pwd-x = start-x + syllable-positions.at(target-idx)
    }

    // Upper tiers (ω, Σ). With spacing: "auto", a branch spanning a horizontal
    // run h gets at least slope × h of vertical line (≈ the angle of the default
    // trees), and vertical branches get a short line. With spacing: "fixed",
    // lines are constant so trees with the same tiers align exactly.

    let foot-xs = ()
    for ft in feet {
      let head-idx = ft.at(0)
      for syll-idx in ft {
        if syllables.at(syll-idx).stressed {
          head-idx = syll-idx
          break
        }
      }
      foot-xs.push(start-x + syllable-positions.at(head-idx))
    }

    // Σ → σ
    let foot-run = 0
    for (j, ft) in feet.enumerate() {
      for syll-idx in ft {
        foot-run = calc.max(foot-run, calc.abs(start-x + syllable-positions.at(syll-idx) - foot-xs.at(j)))
      }
    }
    let foot-line = if fit { calc.max(0.45, branch-slope * foot-run, below-sigma-line) } else { below-sigma-line }
    let foot-y = sigma-y-label + 0.26 + line-len(foot-line, 1) + 0.25

    // ω → Σ, or ω → σ directly when there are no feet
    let sigma-top = sigma-y-label + 0.21
    let below-top = if feet.len() > 0 { foot-y + 0.25 } else { sigma-top }
    let pwd-line = if fit {
      let need = if feet.len() > 0 { foot-line } else { below-sigma-line }
      for fx in foot-xs {
        need = calc.max(need, branch-slope * calc.abs(fx - pwd-x))
      }
      // Unfooted σ hang from ω across the whole ω–σ distance
      for (i, syll) in syllables.enumerate() {
        if i not in in-foot-set {
          let run = calc.abs(start-x + syllable-positions.at(i) - pwd-x)
          need = calc.max(need, branch-slope * run - (below-top - sigma-top))
        }
      }
      need
    } else if feet.len() > 0 { foot-line } else { below-sigma-line }
    let pwd-height = below-top + line-len(pwd-line, 0) + 0.3

    // ω lines to unfooted σ must pass clear above any Σ lying between them
    let clearance-margin = 0.25
    for (i, syll) in syllables.enumerate() {
      if i not in in-foot-set {
        let syll-x = start-x + syllable-positions.at(i)
        for fx in foot-xs {
          let is-between = (pwd-x < fx and fx < syll-x) or (syll-x < fx and fx < pwd-x)
          if is-between and calc.abs(syll-x - pwd-x) > 0.01 {
            let t = (fx - pwd-x) / (syll-x - pwd-x)
            let required = 0.3 + (foot-y + 0.25 + clearance-margin - t * sigma-top) / (1 - t)
            pwd-height = calc.max(pwd-height, required)
          }
        }
      }
    }

    content((pwd-x, pwd-height), context text(size: 12 * diagram-scale * 1pt, font: phonokit-font.get())[#sym_word])

    // Detect geminates
    // A geminate occurs when the last consonant of a coda matches the first consonant of the next onset
    let geminates = ()
    for i in range(syllables.len() - 1) {
      if syllables.at(i).coda != "" and syllables.at(i + 1).onset != "" {
        let coda-segments = smart-clusters(syllables.at(i).coda)
        let onset-segments = smart-clusters(syllables.at(i + 1).onset)
        let last-coda = coda-segments.at(-1)
        let first-onset = onset-segments.at(0)

        // Check if they match and are consonants (not vowels)
        if last-coda == first-onset and not is-vowel(last-coda) {
          let gem-x = start-x + (syllable-positions.at(i) + syllable-positions.at(i + 1)) / 2
          geminates.push((syll-idx: i, gem-x: gem-x, gem-text: last-coda))
        }
      }
    }

    // Draw footless syllables
    for (i, syll) in syllables.enumerate() {
      if i not in in-foot-set {
        let x-offset = start-x + syllable-positions.at(i)

        content((x-offset, sigma-y + 0.54), context text(
          size: 12 * diagram-scale * 1pt,
          font: phonokit-font.get(),
        )[#sym_syll])
        line((pwd-x, pwd-height - 0.3), (x-offset, sigma-y + 0.75))

        let gem-coda-x = none
        let gem-coda-text = none
        let gem-onset-x = none
        let gem-onset-text = none
        for gem in geminates {
          if gem.syll-idx == i {
            gem-coda-x = gem.gem-x
            gem-coda-text = gem.gem-text
          }
          if gem.syll-idx == i - 1 {
            gem-onset-x = gem.gem-x
            gem-onset-text = gem.gem-text
          }
        }

        draw-syllable-structure(
          x-offset,
          sigma-y,
          syll,
          terminal-y,
          diagram-scale: diagram-scale,
          geminate-coda-x: gem-coda-x,
          geminate-onset-x: gem-onset-x,
          geminate-coda-text: gem-coda-text,
          geminate-onset-text: gem-onset-text,
          or-y: or-y,
          n-y: n-y,
        )
      }
    }

    // Draw each foot
    for foot in feet {
      let head-idx = foot.at(0)
      for syll-idx in foot {
        if syllables.at(syll-idx).stressed {
          head-idx = syll-idx
          break
        }
      }

      let foot-x = start-x + syllable-positions.at(head-idx)

      content((foot-x, foot-y), context text(size: 12 * diagram-scale * 1pt, font: phonokit-font.get())[#sym_foot])
      line((pwd-x, pwd-height - 0.3), (foot-x, foot-y + 0.25))

      for syll-idx in foot {
        let x-offset = start-x + syllable-positions.at(syll-idx)
        let syll = syllables.at(syll-idx)

        content((x-offset, sigma-y + 0.54), context text(
          size: 12 * diagram-scale * 1pt,
          font: phonokit-font.get(),
        )[#sym_syll])
        line((foot-x, foot-y - 0.25), (x-offset, sigma-y + 0.8))

        let gem-coda-x = none
        let gem-coda-text = none
        let gem-onset-x = none
        let gem-onset-text = none
        for gem in geminates {
          if gem.syll-idx == syll-idx {
            gem-coda-x = gem.gem-x
            gem-coda-text = gem.gem-text
          }
          if gem.syll-idx == syll-idx - 1 {
            gem-onset-x = gem.gem-x
            gem-onset-text = gem.gem-text
          }
        }

        draw-syllable-structure(
          x-offset,
          sigma-y,
          syll,
          terminal-y,
          diagram-scale: diagram-scale,
          geminate-coda-x: gem-coda-x,
          geminate-onset-x: gem-onset-x,
          geminate-coda-text: gem-coda-text,
          geminate-onset-text: gem-onset-text,
          or-y: or-y,
          n-y: n-y,
        )
      }
    }

    // Draw geminate segments
    for gem in geminates {
      content(
        (gem.gem-x, terminal-y),
        context text(size: 11 * diagram-scale * 1pt, font: phonokit-font.get(), bottom-edge: "descender")[#gem.gem-text],
        anchor: "north",
      )
    }
  }))
}

// Visualizes foot with moraic structure
// Now accepts IPA-style input like "k a.'v a.l o"
#let foot-mora(input, coda: false, scale: 1.0, symbol: ("Σ", "σ", "μ"), distance: none, spacing: "auto") = {
  check-spacing(spacing)
  // Check for problematic diacritic sequences
  let problematic-sequences = ("''", ",,", "\\* \\*", "\\t \\t", "::", "((", "))")
  for seq in problematic-sequences {
    if input.contains(seq) {
      return text(fill: red, weight: "bold")[⚠ Warning: Problematic sequence involving diacritics: "#seq"]
    }
  }

  // Convert IPA-style input to Unicode
  let converted = convert-prosody-input(input)

  // Parse syllables from dotted input
  let syllables = ()
  let buffer = ""
  let chars = converted.codepoints()
  let i = 0

  while i < chars.len() {
    let char = chars.at(i)

    if char == "." {
      if buffer != "" {
        let clean-buffer = if buffer.starts-with("'") { buffer.slice(1) } else { buffer }
        let parsed = parse-syllable(clean-buffer)
        syllables.push((
          onset: parsed.onset,
          nucleus: parsed.nucleus,
          coda: parsed.coda,
          stressed: buffer.starts-with("'"),
        ))
        buffer = ""
      }
    } else if char == "(" or char == ")" {
      // Skip parentheses - they're just delimiters, not segments
    } else {
      buffer += char
    }
    i += 1
  }

  // Handle remaining buffer
  if buffer != "" {
    let clean-buffer = if buffer.starts-with("'") { buffer.slice(1) } else { buffer }
    let parsed = parse-syllable(clean-buffer)
    syllables.push((
      onset: parsed.onset,
      nucleus: parsed.nucleus,
      coda: parsed.coda,
      stressed: buffer.starts-with("'"),
    ))
  }

  // Check for too many onsets/codas/nucleus in any syllable (limit: 5 to avoid crossing lines)
  for (i, syll) in syllables.enumerate() {
    let coda-segments-temp = if syll.coda != "" { smart-clusters(syll.coda) } else { () }
    if coda-segments-temp.len() > 5 {
      return text(
        fill: red,
        weight: "bold",
      )[⚠ Warning: Too many coda consonants in syllable #(i + 1) (max 5 to avoid line crossings). Found: #coda-segments-temp.len()]
    }
    let onset-segments-temp = if syll.onset != "" { smart-clusters(syll.onset) } else { () }
    if onset-segments-temp.len() > 5 {
      return text(
        fill: red,
        weight: "bold",
      )[⚠ Warning: Too many onset consonants in syllable #(i + 1) (max 5 to avoid line crossings). Found: #onset-segments-temp.len()]
    }
    let nucleus-segments-temp = smart-clusters(syll.nucleus)
    if nucleus-segments-temp.len() > 5 {
      return text(
        fill: red,
        weight: "bold",
      )[⚠ Warning: Too many nucleus segments in syllable #(i + 1) (max 5 to avoid line crossings). Found: #nucleus-segments-temp.len()]
    }
  }

  // Find stressed syllable (head of foot)
  let head-idx = 0
  for (i, syll) in syllables.enumerate() {
    if syll.stressed {
      head-idx = i
      break
    }
  }

  let sym_foot = symbol.at(0, default: "Σ")
  let sym_syll = symbol.at(1, default: "σ")
  let sym_mora = symbol.at(2, default: "μ")

  let diagram-scale = scale

  box(baseline: 50%, cetz.canvas(length: 1cm * diagram-scale, {
    import cetz.draw: *
    set-style(stroke: 0.7 * diagram-scale * 1pt)

    let line-len(natural, level) = tier-line(natural, distance, level)

    // Mora tiers (σ → μ = level 1, μ → segments = level 2)
    let mu-seg-line = 0.55
    let sigma-mu-line = calc.max(0.70, mu-seg-line)
    let sigma-y = -2.4
    let sigma-y-label = sigma-y + 0.54
    let mora-y = sigma-y-label - 0.29 - line-len(sigma-mu-line, 1) - 0.35
    let terminal-y = mora-y - 0.35 - line-len(mu-seg-line, 2) - 0.30
    let below-sigma-line = sigma-mu-line

    let segment-spacing = 0.35
    let min-gap-between-sylls = 0.8 // Same as foot() to prevent overlap
    let default-spacing = 1.6 // Same as foot() to prevent overlap

    // Calculate extents for each syllable
    let syllable-extents = ()
    for syll in syllables {
      let has-onset = syll.onset != ""
      let has-coda = syll.coda != ""
      let num-onset = if has-onset { smart-clusters(syll.onset).len() } else { 0 }
      let num-nucleus = smart-clusters(syll.nucleus).len()
      let num-coda = if has-coda { smart-clusters(syll.coda).len() } else { 0 }
      let min-gap = 0.75

      // Calculate constituent positions (simplified like word())
      // Use segment-based extents without mora adjustments for uniform spacing
      // Non-moraic onsets/codas must clear the μ labels (same rule as draw-moraic-structure)
      let reach = moraic-reach(sigma-y, mora-y, terminal-y, long: syll.nucleus.contains("ː"))
      let onset-x-rel = if has-onset {
        let min-offset = (num-onset - 1) * segment-spacing / 2 + (num-nucleus - 1) * segment-spacing / 2 + min-gap
        let default-offset = 0.7
        let clear-offset = reach + (num-onset - 1) * segment-spacing / 2
        -calc.max(min-offset, default-offset, clear-offset)
      } else { 0 }

      let coda-x-rel = if has-coda {
        let min-offset = (num-nucleus + num-coda - 2) * segment-spacing / 2 + 0.4
        let default-offset = 0.7
        let clear-offset = if coda { 0 } else { reach + (num-coda - 1) * segment-spacing / 2 }
        calc.max(min-offset, default-offset, clear-offset)
      } else { 0 }

      // Calculate segment widths
      let onset-width = if has-onset { (num-onset - 1) * segment-spacing } else { 0 }
      let nucleus-width = (num-nucleus - 1) * segment-spacing
      let coda-width = if has-coda { (num-coda - 1) * segment-spacing } else { 0 }

      // Calculate left and right extents (same as word())
      let left-parts = (
        if has-onset { onset-x-rel - onset-width / 2 } else { 0 },
        -nucleus-width / 2,
        if has-coda { coda-x-rel - coda-width / 2 } else { 0 },
      )
      let right-parts = (
        if has-onset { onset-x-rel + onset-width / 2 } else { 0 },
        nucleus-width / 2,
        if has-coda { coda-x-rel + coda-width / 2 } else { 0 },
      )

      let left-extent = calc.min(..left-parts)
      let right-extent = calc.max(..right-parts)

      syllable-extents.push((left: left-extent, right: right-extent))
    }

    // Calculate spacing (same as regular foot() for uniform segment spacing)
    let syllable-positions = ()
    for (i, extent) in syllable-extents.enumerate() {
      if i == 0 {
        syllable-positions.push(0)
      } else {
        let prev-right = syllable-extents.at(i - 1).right
        let required-spacing = prev-right - extent.left + min-gap-between-sylls
        let actual-spacing = calc.max(required-spacing, default-spacing)
        let prev-position = syllable-positions.at(i - 1)
        syllable-positions.push(prev-position + actual-spacing)
      }
    }

    // Center the structure
    let first-left = syllable-positions.at(0) + syllable-extents.at(0).left
    let last-right = syllable-positions.at(-1) + syllable-extents.at(-1).right
    let total-width = last-right - first-left
    let start-x = -total-width / 2 - first-left

    let foot-x = start-x + syllable-positions.at(head-idx)

    // Vertical level positions
    // Default lines never get shorter going up the tree (each is at least as
    // long as the one directly below it); explicit `distance` factors are
    // applied afterwards. spacing: "auto" additionally lengthens upper lines
    // to fit wide branches; "fixed" keeps them constant so trees align.
    let fit = spacing == "auto"


    // Σ → σ: "auto" fits the line to the widest branch; "fixed" grows it with the syllable count
    let foot-run = 0
    for (i, _) in syllables.enumerate() {
      foot-run = calc.max(foot-run, calc.abs(start-x + syllable-positions.at(i) - foot-x))
    }
    let foot-line = if fit {
      calc.max(0.45, branch-slope * foot-run, below-sigma-line)
    } else { below-sigma-line }
    let ft-height = sigma-y-label + 0.26 + line-len(foot-line, 0) + 0.25

    // Draw Ft node above the head
    content((foot-x, ft-height), context text(size: 12 * diagram-scale * 1pt, font: phonokit-font.get())[#sym_foot])

    // Detect geminates
    // A geminate occurs when the last consonant of a coda matches the first consonant of the next onset
    let geminates = ()
    for i in range(syllables.len() - 1) {
      if syllables.at(i).coda != "" and syllables.at(i + 1).onset != "" {
        let coda-segments = smart-clusters(syllables.at(i).coda)
        let onset-segments = smart-clusters(syllables.at(i + 1).onset)
        let last-coda = coda-segments.at(-1)
        let first-onset = onset-segments.at(0)

        // Check if they match and are consonants (not vowels)
        if last-coda == first-onset and not is-vowel(last-coda) {
          let gem-x = start-x + (syllable-positions.at(i) + syllable-positions.at(i + 1)) / 2
          geminates.push((syll-idx: i, gem-x: gem-x, gem-text: last-coda))
        }
      }
    }

    // Draw syllables with moraic structure
    for (i, syll) in syllables.enumerate() {
      let x-offset = start-x + syllable-positions.at(i)

      // Syllable node
      content((x-offset, sigma-y + 0.54), context text(
        size: 12 * diagram-scale * 1pt,
        font: phonokit-font.get(),
      )[#sym_syll])

      // Line from Ft to σ
      line((foot-x, ft-height - 0.25), (x-offset, sigma-y + 0.8))

      // Check for geminate
      let gem-coda-x = none
      let gem-onset-x = none
      for gem in geminates {
        if gem.syll-idx == i {
          gem-coda-x = gem.gem-x
        }
        if gem.syll-idx == i - 1 {
          gem-onset-x = gem.gem-x
        }
      }

      draw-moraic-structure(
        x-offset,
        sigma-y,
        syll,
        terminal-y,
        coda: coda,
        diagram-scale: diagram-scale,
        geminate-coda-x: gem-coda-x,
        geminate-onset-x: gem-onset-x,
        mora-symbol: sym_mora,
        mora-y-override: mora-y,
      )
    }

    // Draw geminate segments
    for gem in geminates {
      content(
        (gem.gem-x, terminal-y),
        context text(size: 11 * diagram-scale * 1pt, font: phonokit-font.get(), bottom-edge: "descender")[#gem.gem-text],
        anchor: "north",
      )
    }
  }))
}

// Visualizes word with moraic structure
// Now accepts IPA-style input like "(k a.'v a).l o"
#let word-mora(input, foot: "R", coda: false, scale: 1.0, symbol: ("ω", "Σ", "σ", "μ"), distance: none, spacing: "auto") = {
  check-spacing(spacing)
  // Check for problematic diacritic sequences
  let problematic-sequences = ("''", ",,", "\\* \\*", "\\t \\t", "::", "((", "))")
  for seq in problematic-sequences {
    if input.contains(seq) {
      return text(fill: red, weight: "bold")[⚠ Warning: Problematic sequence involving diacritics: "#seq"]
    }
  }

  // Convert IPA-style input to Unicode
  let converted = convert-prosody-input(input)

  let syllables = ()
  let feet = ()
  let current-foot = ()
  let in-foot = false
  let buffer = ""

  let chars = converted.codepoints()
  let i = 0

  while i < chars.len() {
    let char = chars.at(i)

    if char == "(" {
      in-foot = true
      current-foot = ()
    } else if char == ")" {
      if buffer != "" {
        let clean-buffer = if buffer.starts-with("'") { buffer.slice(1) } else { buffer }
        let parsed = parse-syllable(clean-buffer)
        syllables.push((
          onset: parsed.onset,
          nucleus: parsed.nucleus,
          coda: parsed.coda,
          stressed: buffer.starts-with("'"),
        ))
        current-foot.push(syllables.len() - 1)
        buffer = ""
      }
      if current-foot.len() > 0 {
        feet.push(current-foot)
      }
      in-foot = false
    } else if char == "." {
      if buffer != "" {
        let clean-buffer = if buffer.starts-with("'") { buffer.slice(1) } else { buffer }
        let parsed = parse-syllable(clean-buffer)
        syllables.push((
          onset: parsed.onset,
          nucleus: parsed.nucleus,
          coda: parsed.coda,
          stressed: buffer.starts-with("'"),
        ))

        if in-foot {
          current-foot.push(syllables.len() - 1)
        }

        buffer = ""
      }
    } else {
      buffer += char
    }

    i += 1
  }

  // Handle remaining buffer
  if buffer != "" {
    let clean-buffer = if buffer.starts-with("'") { buffer.slice(1) } else { buffer }
    let parsed = parse-syllable(clean-buffer)
    syllables.push((
      onset: parsed.onset,
      nucleus: parsed.nucleus,
      coda: parsed.coda,
      stressed: buffer.starts-with("'"),
    ))

    if in-foot {
      current-foot.push(syllables.len() - 1)
    }
  }

  // Check for too many onsets/codas/nucleus in any syllable (limit: 5 to avoid crossing lines)
  for (i, syll) in syllables.enumerate() {
    let coda-segments-temp = if syll.coda != "" { smart-clusters(syll.coda) } else { () }
    if coda-segments-temp.len() > 5 {
      return text(
        fill: red,
        weight: "bold",
      )[⚠ Warning: Too many coda consonants in syllable #(i + 1) (max 5 to avoid line crossings). Found: #coda-segments-temp.len()]
    }
    let onset-segments-temp = if syll.onset != "" { smart-clusters(syll.onset) } else { () }
    if onset-segments-temp.len() > 5 {
      return text(
        fill: red,
        weight: "bold",
      )[⚠ Warning: Too many onset consonants in syllable #(i + 1) (max 5 to avoid line crossings). Found: #onset-segments-temp.len()]
    }
    let nucleus-segments-temp = smart-clusters(syll.nucleus)
    if nucleus-segments-temp.len() > 5 {
      return text(
        fill: red,
        weight: "bold",
      )[⚠ Warning: Too many nucleus segments in syllable #(i + 1) (max 5 to avoid line crossings). Found: #nucleus-segments-temp.len()]
    }
  }

  // Determine which syllables are in feet
  let in-foot-set = ()
  for foot in feet {
    for syll-idx in foot {
      in-foot-set.push(syll-idx)
    }
  }

  let sym_word = symbol.at(0, default: "ω")
  let sym_foot = symbol.at(1, default: "Σ")
  let sym_syll = symbol.at(2, default: "σ")
  let sym_mora = symbol.at(3, default: "μ")

  let diagram-scale = scale

  // Draw the structure
  box(baseline: 50%, cetz.canvas(length: 1cm * diagram-scale, {
    import cetz.draw: *

    set-style(stroke: 0.7 * diagram-scale * 1pt)

    let line-len(natural, level) = tier-line(natural, distance, level)

    // Mora tiers (σ → μ = level 2, μ → segments = level 3)
    let mu-seg-line = 0.55
    let sigma-mu-line = calc.max(0.70, mu-seg-line)
    let sigma-y = -2.4
    let sigma-y-label = sigma-y + 0.54
    let mora-y = sigma-y-label - 0.29 - line-len(sigma-mu-line, 2) - 0.35
    let terminal-y = mora-y - 0.35 - line-len(mu-seg-line, 3) - 0.30
    let below-sigma-line = sigma-mu-line

    let segment-spacing = 0.35
    let min-gap-between-sylls = 0.6
    let default-spacing = 1.4

    // Calculate extents for each syllable
    let syllable-extents = ()
    for syll in syllables {
      let has-onset = syll.onset != ""
      let has-coda = syll.coda != ""
      let num-onset = if has-onset { smart-clusters(syll.onset).len() } else { 0 }
      let num-nucleus = smart-clusters(syll.nucleus).len()
      let num-coda = if has-coda { smart-clusters(syll.coda).len() } else { 0 }

      // Calculate constituent positions (simplified like word())
      // Use segment-based extents without mora adjustments for uniform spacing
      let min-gap = 0.75

      // Non-moraic onsets/codas must clear the μ labels (same rule as draw-moraic-structure)
      let reach = moraic-reach(sigma-y, mora-y, terminal-y, long: syll.nucleus.contains("ː"))
      let onset-x-rel = if has-onset {
        let min-offset = (num-onset - 1) * segment-spacing / 2 + (num-nucleus - 1) * segment-spacing / 2 + min-gap
        let default-offset = 0.7
        let clear-offset = reach + (num-onset - 1) * segment-spacing / 2
        -calc.max(min-offset, default-offset, clear-offset)
      } else { 0 }

      let coda-x-rel = if has-coda {
        let min-offset = (num-nucleus + num-coda - 2) * segment-spacing / 2 + 0.4
        let default-offset = 0.7
        let clear-offset = if coda { 0 } else { reach + (num-coda - 1) * segment-spacing / 2 }
        calc.max(min-offset, default-offset, clear-offset)
      } else { 0 }

      // Calculate segment widths
      let onset-width = if has-onset { (num-onset - 1) * segment-spacing } else { 0 }
      let nucleus-width = (num-nucleus - 1) * segment-spacing
      let coda-width = if has-coda { (num-coda - 1) * segment-spacing } else { 0 }

      // Calculate left and right extents (same as word())
      let left-parts = (
        if has-onset { onset-x-rel - onset-width / 2 } else { 0 },
        -nucleus-width / 2,
        if has-coda { coda-x-rel - coda-width / 2 } else { 0 },
      )
      let right-parts = (
        if has-onset { onset-x-rel + onset-width / 2 } else { 0 },
        nucleus-width / 2,
        if has-coda { coda-x-rel + coda-width / 2 } else { 0 },
      )

      let left-extent = calc.min(..left-parts)
      let right-extent = calc.max(..right-parts)

      syllable-extents.push((left: left-extent, right: right-extent))
    }

    // Calculate spacing based on uniform segment-to-segment distance
    let syllable-positions = ()
    for (i, extent) in syllable-extents.enumerate() {
      if i == 0 {
        syllable-positions.push(0)
      } else {
        // Use same spacing calculation as word() for uniform segment spacing
        let prev-right = syllable-extents.at(i - 1).right
        let required-spacing = prev-right - extent.left + min-gap-between-sylls
        let actual-spacing = calc.max(required-spacing, default-spacing)
        let prev-position = syllable-positions.at(i - 1)
        syllable-positions.push(prev-position + actual-spacing)
      }
    }

    // Center the structure
    let first-left = syllable-positions.at(0) + syllable-extents.at(0).left
    let last-right = syllable-positions.at(-1) + syllable-extents.at(-1).right
    let total-width = last-right - first-left
    let start-x = -total-width / 2 - first-left

    // Determine PWd x-position
    let pwd-x = 0

    if feet.len() > 0 {
      let target-foot = if foot == "L" { feet.at(0) } else { feet.at(-1) }
      let target-syll-idx = target-foot.at(0)
      for (i, syll) in target-foot.enumerate() {
        let this-syll = syllables.at(syll)
        if this-syll.stressed {
          target-syll-idx = syll
          break
        }
      }
      pwd-x = start-x + syllable-positions.at(target-syll-idx)
    } else if syllables.len() > 0 {
      // If the user marked stress with ' (even without using feet), align
      // the PWd node to that syllable instead of defaulting to L/R extremes.
      let stressed-idx = none
      for (idx, syll) in syllables.enumerate() {
        if syll.stressed {
          stressed-idx = idx
          break
        }
      }
      let target-idx = if stressed-idx != none {
        stressed-idx
      } else if foot == "L" { 0 } else { syllables.len() - 1 }
      pwd-x = start-x + syllable-positions.at(target-idx)
    }

    // Default lines never get shorter going up the tree (each is at least as
    // long as the one directly below it); explicit `distance` factors are
    // applied afterwards. spacing: "auto" additionally lengthens upper lines
    // to fit wide branches; "fixed" keeps them constant so trees align.
    let fit = spacing == "auto"


    // Upper tiers (ω, Σ). With spacing: "auto", a branch spanning a horizontal
    // run h gets at least slope × h of vertical line (≈ the angle of the default
    // trees), and vertical branches get a short line. With spacing: "fixed",
    // lines are constant so trees with the same tiers align exactly.

    let foot-xs = ()
    for ft in feet {
      let head-idx = ft.at(0)
      for syll-idx in ft {
        if syllables.at(syll-idx).stressed {
          head-idx = syll-idx
          break
        }
      }
      foot-xs.push(start-x + syllable-positions.at(head-idx))
    }

    // Σ → σ
    let foot-run = 0
    for (j, ft) in feet.enumerate() {
      for syll-idx in ft {
        foot-run = calc.max(foot-run, calc.abs(start-x + syllable-positions.at(syll-idx) - foot-xs.at(j)))
      }
    }
    let foot-line = if fit { calc.max(0.45, branch-slope * foot-run, below-sigma-line) } else { below-sigma-line }
    let ft-y = sigma-y-label + 0.26 + line-len(foot-line, 1) + 0.25

    // ω → Σ, or ω → σ directly when there are no feet
    let sigma-top = sigma-y-label + 0.21
    let below-top = if feet.len() > 0 { ft-y + 0.25 } else { sigma-top }
    let pwd-line = if fit {
      let need = if feet.len() > 0 { foot-line } else { below-sigma-line }
      for fx in foot-xs {
        need = calc.max(need, branch-slope * calc.abs(fx - pwd-x))
      }
      // Unfooted σ hang from ω across the whole ω–σ distance
      for (i, syll) in syllables.enumerate() {
        if i not in in-foot-set {
          let run = calc.abs(start-x + syllable-positions.at(i) - pwd-x)
          need = calc.max(need, branch-slope * run - (below-top - sigma-top))
        }
      }
      need
    } else if feet.len() > 0 { foot-line } else { below-sigma-line }
    let pwd-y = below-top + line-len(pwd-line, 0) + 0.3

    // ω lines to unfooted σ must pass clear above any Σ lying between them
    let clearance-margin = 0.25
    for (i, syll) in syllables.enumerate() {
      if i not in in-foot-set {
        let syll-x = start-x + syllable-positions.at(i)
        for fx in foot-xs {
          let is-between = (pwd-x < fx and fx < syll-x) or (syll-x < fx and fx < pwd-x)
          if is-between and calc.abs(syll-x - pwd-x) > 0.01 {
            let t = (fx - pwd-x) / (syll-x - pwd-x)
            let required = 0.3 + (ft-y + 0.25 + clearance-margin - t * sigma-top) / (1 - t)
            pwd-y = calc.max(pwd-y, required)
          }
        }
      }
    }

    // Draw PWd node
    content((pwd-x, pwd-y), context text(size: 12 * diagram-scale * 1pt, font: phonokit-font.get())[#sym_word])

    // Detect geminates
    // A geminate occurs when the last consonant of a coda matches the first consonant of the next onset
    let geminates = ()
    for i in range(syllables.len() - 1) {
      if syllables.at(i).coda != "" and syllables.at(i + 1).onset != "" {
        let coda-segments = smart-clusters(syllables.at(i).coda)
        let onset-segments = smart-clusters(syllables.at(i + 1).onset)
        let last-coda = coda-segments.at(-1)
        let first-onset = onset-segments.at(0)

        // Check if they match and are consonants (not vowels)
        if last-coda == first-onset and not is-vowel(last-coda) {
          let gem-x = start-x + (syllable-positions.at(i) + syllable-positions.at(i + 1)) / 2
          geminates.push((syll-idx: i, gem-x: gem-x, gem-text: last-coda))
        }
      }
    }

    // Draw feet
    for (foot-idx, foot-sylls) in feet.enumerate() {
      // Find head of foot (stressed syllable)
      let head-idx = foot-sylls.at(0)
      for syll-idx in foot-sylls {
        if syllables.at(syll-idx).stressed {
          head-idx = syll-idx
          break
        }
      }

      let foot-x = start-x + syllable-positions.at(head-idx)
      content((foot-x, ft-y), context text(size: 12 * diagram-scale * 1pt, font: phonokit-font.get())[#sym_foot])
      line((pwd-x, pwd-y - 0.3), (foot-x, ft-y + 0.25))

      // Draw lines from Ft to syllables in this foot
      for syll-idx in foot-sylls {
        let syll-x = start-x + syllable-positions.at(syll-idx)
        line((foot-x, ft-y - 0.25), (syll-x, sigma-y + 0.8))
      }
    }

    // Draw lines from PWd to unfooted syllables
    for (i, syll) in syllables.enumerate() {
      if i not in in-foot-set {
        let syll-x = start-x + syllable-positions.at(i)
        line((pwd-x, pwd-y - 0.3), (syll-x, sigma-y + 0.75))
      }
    }

    // Draw syllables with moraic structure
    for (i, syll) in syllables.enumerate() {
      let x-offset = start-x + syllable-positions.at(i)

      // Syllable node
      content((x-offset, sigma-y + 0.54), context text(
        size: 12 * diagram-scale * 1pt,
        font: phonokit-font.get(),
      )[#sym_syll])

      // Check for geminate
      let gem-coda-x = none
      let gem-onset-x = none
      for gem in geminates {
        if gem.syll-idx == i {
          gem-coda-x = gem.gem-x
        }
        if gem.syll-idx == i - 1 {
          gem-onset-x = gem.gem-x
        }
      }

      draw-moraic-structure(
        x-offset,
        sigma-y,
        syll,
        terminal-y,
        coda: coda,
        diagram-scale: diagram-scale,
        geminate-coda-x: gem-coda-x,
        geminate-onset-x: gem-onset-x,
        mora-symbol: sym_mora,
        mora-y-override: mora-y,
      )
    }

    // Draw geminate segments
    for gem in geminates {
      content(
        (gem.gem-x, terminal-y),
        context text(size: 11 * diagram-scale * 1pt, font: phonokit-font.get(), bottom-edge: "descender")[#gem.gem-text],
        anchor: "north",
      )
    }
  }))
}
