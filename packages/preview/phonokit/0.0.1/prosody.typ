#import "@preview/cetz:0.4.2"

#let is-vowel(char) = {
  char in ("a", 
           "e", 
           "i", 
           "o", 
           "u", 
           "ã",
           "ẽ",
           "õ",
           "ɛ̃",
           "ɔ̃",
           "œ̃",
           "ɑ̃",
           "ɚ",
           "ɝ",
           "ɯ",
           "ɐ",
           "ɒ",
           "æ", 
           "ɛ", 
           "ɪ", 
           "ɔ", 
           "ø",
           "ɪ",
           "œ",
           "ɨ",
           "ʉ",
           "ʊ", 
           "ə", 
           "ʌ", 
           "ɑ", 
           "aɪ", 
           "eɪ", 
           "oɪ", 
           "aʊ", 
           "oʊ")
}

#let parse-syllable(syll) = {
  let chars = syll.codepoints()
  let onset = ""
  let nucleus = ""
  let coda = ""
  let found-nucleus = false

  for char in chars {
    if is-vowel(char) {
      nucleus += char
      found-nucleus = true
    } else if not found-nucleus {
      onset += char
    } else {
      coda += char
    }
  }

  (onset: onset, nucleus: nucleus, coda: coda)
}

// Helper function to draw syllable internal structure
#let draw-syllable-structure(x-offset, sigma-y, syll, terminal-y, diagram-scale: 1.0,
                            geminate-coda-x: none, geminate-onset-x: none) = {
  import cetz.draw: *

  let has-onset = syll.onset != ""
  let has-coda = syll.coda != ""

  // Calculate segment counts for adaptive spacing
  let onset-segments = if has-onset { syll.onset.codepoints() } else { () }
  let num-onset = if has-onset { onset-segments.len() } else { 0 }

  let nucleus-segments = syll.nucleus.codepoints()
  let num-nucleus = nucleus-segments.len()

  let coda-segments = if has-coda { syll.coda.codepoints() } else { () }
  let num-coda = if has-coda { coda-segments.len() } else { 0 }

  let segment-spacing = 0.35
  let min-gap = 0.75

  // Headedness: Rhyme is head of syllable, Nucleus is head of Rhyme
  // Heads align vertically, non-heads are angled
  let rhyme-x = x-offset  // vertical (head of syllable)
  let nucleus-x = rhyme-x  // MUST stay at rhyme-x (vertical, head of rhyme)

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
    line((x-offset, sigma-y + 0.25), (onset-x, sigma-y - 0.45))
    content((onset-x, sigma-y - 0.75), text(size: 10 * diagram-scale * 1pt)[On])

    // Branch to each onset segment
    let onset-segments = syll.onset.codepoints()
    let num-onset = onset-segments.len()

    // Check if this is a geminate onset
    if geminate-onset-x != none {
      // Geminate: draw line to geminate position (text drawn separately)
      line((onset-x, sigma-y - 1.1), (geminate-onset-x, terminal-y + 0.30))
    } else {
      // Normal onset: draw branches to individual segments
      let onset-total-width = (num-onset - 1) * segment-spacing
      let onset-start-x = onset-x - onset-total-width / 2

      for (i, segment) in onset-segments.enumerate() {
        let seg-x = onset-start-x + i * segment-spacing
        line((onset-x, sigma-y - 1.1), (seg-x, terminal-y + 0.30))
        content((seg-x, terminal-y), text(size: 11 * diagram-scale * 1pt)[#segment], anchor: "north")
      }
    }
  }

  // Rhyme branch
  line((x-offset, sigma-y + 0.25), (rhyme-x, sigma-y - 0.45))
  content((rhyme-x, sigma-y - 0.75), text(size: 10 * diagram-scale * 1pt)[Rh])

  // Nucleus
  line((rhyme-x, sigma-y - 1.1), (nucleus-x, sigma-y - 1.35))
  content((nucleus-x, sigma-y - 1.65), text(size: 10 * diagram-scale * 1pt)[Nu])

  // Branch to each nucleus segment
  let nucleus-total-width = (num-nucleus - 1) * segment-spacing
  let nucleus-start-x = nucleus-x - nucleus-total-width / 2

  for (i, segment) in nucleus-segments.enumerate() {
    let seg-x = nucleus-start-x + i * segment-spacing
    line((nucleus-x, sigma-y - 1.9), (seg-x, terminal-y + 0.30))
    content((seg-x, terminal-y), text(size: 11 * diagram-scale * 1pt)[#segment], anchor: "north")
  }

  // Coda (if exists)
  if has-coda {
    line((rhyme-x, sigma-y - 1.1), (coda-x, sigma-y - 1.35))
    content((coda-x, sigma-y - 1.65), text(size: 10 * diagram-scale * 1pt)[Co])

    // Branch to each coda segment
    // Check if this is a geminate coda
    if geminate-coda-x != none {
      // Geminate: draw line to geminate position (text drawn separately)
      line((coda-x, sigma-y - 1.9), (geminate-coda-x, terminal-y + 0.30))
    } else {
      // Normal coda: draw branches to individual segments
      let coda-total-width = (num-coda - 1) * segment-spacing
      let coda-start-x = coda-x - coda-total-width / 2

      for (i, segment) in coda-segments.enumerate() {
        let seg-x = coda-start-x + i * segment-spacing
        line((coda-x, sigma-y - 1.9), (seg-x, terminal-y + 0.30))
        content((seg-x, terminal-y), text(size: 11 * diagram-scale * 1pt)[#segment], anchor: "north")
      }
    }
  }
}

// Visualizes a single syllable's internal structure (On/Rh/Nu/Co)
#let syllable(input, scale: 1.0) = {
  // Parse a single syllable
  let clean-input = if input.starts-with("'") { input.slice(1) } else { input }
  let parsed = parse-syllable(clean-input)
  let syll = (
    onset: parsed.onset,
    nucleus: parsed.nucleus,
    coda: parsed.coda,
    stressed: input.starts-with("'")
  )

  let diagram-scale = scale  // Capture scale value to avoid conflict with cetz.draw.scale

  cetz.canvas(length: 1cm * diagram-scale, {
    import cetz.draw: *
    set-style(stroke: 0.7 * diagram-scale * 1pt)

    let sigma-y = 0
    let terminal-y = -3.5
    let x-offset = 0

    // Syllable node (σ)
    content((x-offset, sigma-y + 0.54), text(size: 12 * diagram-scale * 1pt)[*σ*])

    draw-syllable-structure(x-offset, sigma-y, syll, terminal-y, diagram-scale: diagram-scale)
  })
}

// Visualizes foot and syllable levels
#let foot(input, scale: 1.0) = {
  // Parse syllables from dotted input like "ka.'va.lo"
  // All syllables are part of the foot
  let syllables = ()
  let buffer = ""
  let chars = input.codepoints()
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
          stressed: buffer.starts-with("'")
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
      stressed: buffer.starts-with("'")
    ))
  }

  // Find stressed syllable (head of foot)
  let head-idx = 0
  for (i, syll) in syllables.enumerate() {
    if syll.stressed {
      head-idx = i
    }
  }

  let diagram-scale = scale  // Capture scale value to avoid conflict with cetz.draw.scale

  cetz.canvas(length: 1cm * diagram-scale, {
    import cetz.draw: *
    set-style(stroke: 0.7 * diagram-scale * 1pt)

    let segment-spacing = 0.35
    let min-gap-between-sylls = 1.2
    let default-spacing = 2.2

    // Calculate extents for each syllable
    let syllable-extents = ()
    for syll in syllables {
      let has-onset = syll.onset != ""
      let has-coda = syll.coda != ""
      let num-onset = if has-onset { syll.onset.codepoints().len() } else { 0 }
      let num-nucleus = syll.nucleus.codepoints().len()
      let num-coda = if has-coda { syll.coda.codepoints().len() } else { 0 }
      let min-gap = 0.75

      // Calculate constituent positions (same logic as draw-syllable-structure)
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

      // Calculate left and right extents relative to syllable center
      let left-parts = (
        if has-onset { onset-x-rel - onset-width / 2 } else { 0 },
        -nucleus-width / 2,
        if has-coda { coda-x-rel - coda-width / 2 } else { 0 }
      )
      let right-parts = (
        if has-onset { onset-x-rel + onset-width / 2 } else { 0 },
        nucleus-width / 2,
        if has-coda { coda-x-rel + coda-width / 2 } else { 0 }
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

    // Calculate dynamic Ft height based on number of syllables
    // Ft moves up as syllable count increases, but syllables stay at fixed position
    let ft-height = -0.9 + (syllables.len() * 0.3)
    let sigma-y = -2.4  // Fixed position
    let terminal-y = -5  // Fixed position

    // Draw Ft node above the head
    content((foot-x, ft-height), text(size: 12 * diagram-scale * 1pt)[*Σ*])

    // Detect geminates (coda of syll i == onset of syll i+1)
    let geminates = ()
    for i in range(syllables.len() - 1) {
      if syllables.at(i).coda != "" and syllables.at(i).coda == syllables.at(i + 1).onset {
        let gem-x = start-x + (syllable-positions.at(i) + syllable-positions.at(i + 1)) / 2  // Midpoint between syllables
        geminates.push((syll-idx: i, gem-x: gem-x, gem-text: syllables.at(i).coda))
      }
    }

    // Draw syllables
    for (i, syll) in syllables.enumerate() {
      let x-offset = start-x + syllable-positions.at(i)

      // Syllable node (σ)
      content((x-offset, sigma-y + 0.54), text(size: 12 * diagram-scale * 1pt)[*σ*])

      // Line from Ft to σ
      line((foot-x, ft-height - 0.25), (x-offset, sigma-y + 0.8))

      // Check if this syllable has a geminate coda or onset
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

      draw-syllable-structure(x-offset, sigma-y, syll, terminal-y,
                              diagram-scale: diagram-scale,
                              geminate-coda-x: gem-coda-x,
                              geminate-onset-x: gem-onset-x)
    }

    // Draw geminate segments
    for gem in geminates {
      let terminal-y = -5
      content((gem.gem-x, terminal-y), text(size: 11 * diagram-scale * 1pt)[#gem.gem-text], anchor: "north")
    }
  })
}

// Visualizes word, foot, and syllable levels
#let word(input, foot: "R", scale: 1.0) = {
  // Parse syllables and feet from bracketed input like "(ka.'va).lo"
  // Parentheses indicate foot boundaries
  // foot: "R" (right-aligned) or "L" (left-aligned) - determines PWd alignment

  let syllables = ()
  let feet = ()  // Array of arrays, each containing syllable indices
  let current-foot = ()
  let in-foot = false
  let buffer = ""

  // Parse the input character by character
  let chars = input.codepoints()
  let i = 0

  while i < chars.len() {
    let char = chars.at(i)

    if char == "(" {
      // Start a new foot
      in-foot = true
      current-foot = ()
    } else if char == ")" {
      // End current foot - add any buffered syllable
      if buffer != "" {
        let clean-buffer = if buffer.starts-with("'") { buffer.slice(1) } else { buffer }
        let parsed = parse-syllable(clean-buffer)
        syllables.push((
          onset: parsed.onset,
          nucleus: parsed.nucleus,
          coda: parsed.coda,
          stressed: buffer.starts-with("'")
        ))
        current-foot.push(syllables.len() - 1)
        buffer = ""
      }
      // Save this foot
      if current-foot.len() > 0 {
        feet.push(current-foot)
      }
      in-foot = false
    } else if char == "." {
      // Syllable boundary
      if buffer != "" {
        let clean-buffer = if buffer.starts-with("'") { buffer.slice(1) } else { buffer }
        let parsed = parse-syllable(clean-buffer)
        syllables.push((
          onset: parsed.onset,
          nucleus: parsed.nucleus,
          coda: parsed.coda,
          stressed: buffer.starts-with("'")
        ))

        if in-foot {
          current-foot.push(syllables.len() - 1)
        }
        // If not in foot, this syllable is footless

        buffer = ""
      }
    } else {
      buffer += char
    }

    i += 1
  }

  // Handle any remaining buffer
  if buffer != "" {
    let clean-buffer = if buffer.starts-with("'") { buffer.slice(1) } else { buffer }
    let parsed = parse-syllable(clean-buffer)
    syllables.push((
      onset: parsed.onset,
      nucleus: parsed.nucleus,
      coda: parsed.coda,
      stressed: buffer.starts-with("'")
    ))

    if in-foot {
      current-foot.push(syllables.len() - 1)
    }
  }

  // Determine which syllables are in feet
  let in-foot-set = ()
  for foot in feet {
    for syll-idx in foot {
      in-foot-set.push(syll-idx)
    }
  }

  let diagram-scale = scale  // Capture scale value to avoid conflict with cetz.draw.scale

  // Draw the structure
  cetz.canvas(length: 1cm * diagram-scale, {
    import cetz.draw: *

    set-style(stroke: 0.7 * diagram-scale * 1pt)

    let segment-spacing = 0.35
    let min-gap-between-sylls = 1.2
    let default-spacing = 2.2

    // Calculate extents for each syllable (same as in foot())
    let syllable-extents = ()
    for syll in syllables {
      let has-onset = syll.onset != ""
      let has-coda = syll.coda != ""
      let num-onset = if has-onset { syll.onset.codepoints().len() } else { 0 }
      let num-nucleus = syll.nucleus.codepoints().len()
      let num-coda = if has-coda { syll.coda.codepoints().len() } else { 0 }
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
        if has-coda { coda-x-rel - coda-width / 2 } else { 0 }
      )
      let right-parts = (
        if has-onset { onset-x-rel + onset-width / 2 } else { 0 },
        nucleus-width / 2,
        if has-coda { coda-x-rel + coda-width / 2 } else { 0 }
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

    // Step 1: Determine PWd x-position
    let pwd-x = 0  // default center

    if feet.len() > 0 {
      // Find leftmost or rightmost foot and align PWd with it
      let target-foot = if foot == "L" { feet.at(0) } else { feet.at(-1) }

      // Find the stressed syllable (head) in the target foot
      let head-idx = target-foot.at(0)
      for syll-idx in target-foot {
        if syllables.at(syll-idx).stressed {
          head-idx = syll-idx
        }
      }
      pwd-x = start-x + syllable-positions.at(head-idx)
    } else if syllables.len() > 0 {
      // No feet: align PWd with first or last syllable (depending on foot parameter)
      let target-idx = if foot == "L" { 0 } else { syllables.len() - 1 }
      pwd-x = start-x + syllable-positions.at(target-idx)
    }

    // Step 2: Calculate minimum PWd height to avoid crossings (geometric precision)
    // For each footless syllable, the line from PWd must clear all intermediate feet
    let base-height = 0.5
    let syllable-factor = 0.1
    let clearance-margin = 0.5  // Extra visual clearance above foot connections
    let min-pwd-height = base-height + (syllables.len() * syllable-factor)

    for (i, syll) in syllables.enumerate() {
      if i not in in-foot-set {
        let syll-x = start-x + syllable-positions.at(i)

        // Check all feet to find those between PWd and this footless syllable
        for ft in feet {
          // Find foot's head position
          let head-idx = ft.at(0)
          for syll-idx in ft {
            if syllables.at(syll-idx).stressed {
              head-idx = syll-idx
            }
          }
          let foot-x = start-x + syllable-positions.at(head-idx)

          // Check if foot is between PWd and footless syllable
          let is-between = (pwd-x < foot-x and foot-x < syll-x) or (syll-x < foot-x and foot-x < pwd-x)

          if is-between and calc.abs(syll-x - pwd-x) > 0.01 {  // Avoid division by zero
            // Geometric constraint: line from (pwd-x, h-0.3) to (syll-x, -1.65)
            // must pass above foot connection at (foot-x, -0.65)
            // At foot-x: y = (h - 0.3) - (h + 1.35) * (foot-x - pwd-x) / (syll-x - pwd-x)
            // We need: y > -0.65 + clearance-margin
            // Solving for h: h > (1.35*t - 0.35 + clearance-margin) / (1 - t)
            // where t = (foot-x - pwd-x) / (syll-x - pwd-x)
            let t = (foot-x - pwd-x) / (syll-x - pwd-x)
            let required-height = (1.35 * t - 0.35 + clearance-margin) / (1 - t)
            min-pwd-height = calc.max(min-pwd-height, required-height)
          }
        }
      }
    }

    let pwd-height = min-pwd-height

    content((pwd-x, pwd-height), text(size: 12 * diagram-scale * 1pt)[*PWd*])

    // Detect geminates (coda of syll i == onset of syll i+1)
    let geminates = ()
    for i in range(syllables.len() - 1) {
      if syllables.at(i).coda != "" and syllables.at(i).coda == syllables.at(i + 1).onset {
        let gem-x = start-x + (syllable-positions.at(i) + syllable-positions.at(i + 1)) / 2  // Midpoint between syllables
        geminates.push((syll-idx: i, gem-x: gem-x, gem-text: syllables.at(i).coda))
      }
    }

    // Draw footless syllables (connect directly to PWd)
    for (i, syll) in syllables.enumerate() {
      if i not in in-foot-set {
        let x-offset = start-x + syllable-positions.at(i)
        let sigma-y = -2.4
        let terminal-y = -5

        // Syllable node (σ)
        content((x-offset, sigma-y + 0.54), text(size: 12 * diagram-scale * 1pt)[*σ*])

        // Line from PWd to σ (footless)
        line((pwd-x, pwd-height - 0.3), (x-offset, sigma-y + 0.75))

        // Check if this syllable has a geminate coda or onset
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

        draw-syllable-structure(x-offset, sigma-y, syll, terminal-y,
                                diagram-scale: diagram-scale,
                                geminate-coda-x: gem-coda-x,
                                geminate-onset-x: gem-onset-x)
      }
    }

    // Draw each foot
    for foot in feet {
      // Position Ft node above the stressed syllable (head of foot)
      // Find the stressed syllable in this foot
      let head-idx = foot.at(0)  // default to first syllable
      for syll-idx in foot {
        if syllables.at(syll-idx).stressed {
          head-idx = syll-idx
        }
      }

      let foot-x = start-x + syllable-positions.at(head-idx)

      // Draw Ft node above the head
      content((foot-x, -0.9), text(size: 12 * diagram-scale * 1pt)[*Σ*])

      // Line from PWd to Ft
      line((pwd-x, pwd-height - 0.3), (foot-x, -0.65))

      // Draw syllables in this foot
      for syll-idx in foot {
        let x-offset = start-x + syllable-positions.at(syll-idx)
        let syll = syllables.at(syll-idx)
        let sigma-y = -2.4
        let terminal-y = -5

        // Syllable node (σ)
        content((x-offset, sigma-y+0.54), text(size: 12 * diagram-scale * 1pt)[*σ*])

        // Line from Ft to σ (naturally vertical for head, angled for others)
        line((foot-x, -1.15), (x-offset, sigma-y + 0.8))

        // Check if this syllable has a geminate coda or onset
        let gem-coda-x = none
        let gem-onset-x = none
        for gem in geminates {
          if gem.syll-idx == syll-idx {
            gem-coda-x = gem.gem-x
          }
          if gem.syll-idx == syll-idx - 1 {
            gem-onset-x = gem.gem-x
          }
        }

        draw-syllable-structure(x-offset, sigma-y, syll, terminal-y,
                                diagram-scale: diagram-scale,
                                geminate-coda-x: gem-coda-x,
                                geminate-onset-x: gem-onset-x)
      }
    }

    // Draw geminate segments
    for gem in geminates {
      let terminal-y = -5
      content((gem.gem-x, terminal-y), text(size: 11 * diagram-scale * 1pt)[#gem.gem-text], anchor: "north")
    }
  })
}
