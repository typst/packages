// render-chords.typ - Chord symbol rendering
//
// Renders chord symbols (e.g., "D", "Am7", "F#m", "Bb/F") above the staff
// with standard lead-sheet typography.
//
// Chord symbols are specified as an array-of-arrays (one inner array per
// measure). The number of elements in each inner array determines placement:
//   1 chord  → beat 1
//   2 chords → beat 1, middle beat
//   3 chords → beat 1, beat before middle, middle beat
//   4+ chords → one per beat (extras discarded)

/// Compute the beat offsets (in whole-note fractions from measure start) for
/// a given number of chords in a measure with the given time signature.
///
/// Returns an array of beat offsets (floats). Each offset is in "whole-note
/// duration units" (e.g., a quarter note = 0.25).
///
/// Parameters:
/// - n-chords: how many chord symbols in this measure
/// - time-upper: numerator of time signature
/// - time-lower: denominator of time signature
#let chord-beat-offsets(n-chords, time-upper, time-lower) = {
  if n-chords == 0 { return () }

  // One beat = 1/time-lower in whole-note units
  let beat-dur = 1.0 / time-lower
  let total-beats = time-upper

  if n-chords == 1 {
    // Always on beat 1
    (0.0,)
  } else if n-chords == 2 {
    // Beat 1 and "middle beat"
    let mid = if time-upper == 3 {
      // 3/4, 3/8: second chord on beat 2
      1
    } else if time-upper == 2 {
      // 2/2, 2/4: second chord on beat 2
      1
    } else if calc.rem(time-upper, 3) == 0 and time-upper >= 6 {
      // 6/8, 6/4, 9/8, 12/8: middle beat = upper/2
      int(time-upper / 2)
    } else {
      // 4/4, 5/4, 7/8, etc.: middle = ceil(upper/2)
      int(calc.ceil(time-upper / 2))
    }
    (0.0, mid * beat-dur)
  } else if n-chords == 3 {
    // Beat 1, beat before middle, middle beat
    let mid = if time-upper == 3 {
      2
    } else if time-upper == 2 {
      // Only 2 beats: place on 0, 0, 1 → but beat-before-mid would collide.
      // Treat as: beat 1, beat 1, beat 2 (degenerate; first two overlap).
      1
    } else if calc.rem(time-upper, 3) == 0 and time-upper >= 6 {
      int(time-upper / 2)
    } else {
      int(calc.ceil(time-upper / 2))
    }
    let before-mid = calc.max(mid - 1, 1)
    (0.0, before-mid * beat-dur, mid * beat-dur)
  } else {
    // 4+ chords: one per beat, discard extras
    let count = calc.min(n-chords, total-beats)
    range(count).map(i => i * beat-dur)
  }
}

/// Parse a chord symbol string into structured parts.
///
/// Returns a dictionary with:
///   - root: string (e.g., "D", "A", "B")
///   - root-accidental: none, "sharp", or "flat"
///   - quality: string remainder after root (e.g., "m7", "maj7", "dim", "7", "sus4")
///   - bass-root: none or string (for slash chords, e.g., "G" in "D/G")
///   - bass-accidental: none, "sharp", or "flat"
#let parse-chord-symbol(sym) = {
  let s = sym.trim()
  if s.len() == 0 {
    return (root: "", root-accidental: none, quality: "", bass-root: none, bass-accidental: none)
  }

  // Split on "/" for slash chords - but only the LAST "/" to handle e.g., "A/G"
  let slash-pos = none
  // Find last "/" that separates root/bass (skip if it's part of quality text)
  let chars = s.clusters()
  let idx = chars.len() - 1
  while idx > 0 {
    if chars.at(idx) == "/" {
      // The character after "/" should be a note letter (A-G) to be a bass note
      if idx + 1 < chars.len() {
        let after = chars.at(idx + 1)
        if after in ("A", "B", "C", "D", "E", "F", "G") {
          slash-pos = idx
        }
      }
    }
    idx -= 1
  }

  let main-part = s
  let bass-part = none
  if slash-pos != none {
    main-part = chars.slice(0, slash-pos).join("")
    bass-part = chars.slice(slash-pos + 1).join("")
  }

  // Parse root from main part
  let main-chars = main-part.clusters()
  let root = main-chars.at(0)
  let root-acc = none
  let quality-start = 1

  if main-chars.len() > 1 {
    let c1 = main-chars.at(1)
    if c1 == "#" or c1 == "♯" {
      root-acc = "sharp"
      quality-start = 2
    } else if c1 == "♭" {
      root-acc = "flat"
      quality-start = 2
    } else if c1 == "b" {
      // Disambiguate: "Bb" (B-flat) vs "Bm" (B-minor) vs "Bdim"
      // "b" after a note letter is flat ONLY if:
      //   - it's the end of root portion, OR
      //   - followed by a non-letter (digit, etc.) suggesting it's Xb<quality>
      // In standard chord notation, lowercase "b" right after root = flat
      // BUT "m" after root = minor. So "b" = flat specifically.
      // Exception: if root is already not A-G... but that shouldn't happen.
      // Let's check: if next char after "b" is another "b" or is a digit or
      // is end of string, or specific quality markers, treat as flat.
      if main-chars.len() == 2 {
        // e.g., "Bb" - this is B-flat
        root-acc = "flat"
        quality-start = 2
      } else {
        let c2 = main-chars.at(2)
        // "Bbm" = B-flat minor, "Bb7" = B-flat 7
        // But "Bdim" should be B diminished (not Bd + im)
        // So "b" followed by anything that looks like quality = flat
        root-acc = "flat"
        quality-start = 2
      }
    }
  }

  let quality = if quality-start < main-chars.len() {
    main-chars.slice(quality-start).join("")
  } else {
    ""
  }

  // Parse bass note if present
  let bass-root = none
  let bass-acc = none
  if bass-part != none {
    let bc = bass-part.clusters()
    bass-root = bc.at(0)
    if bc.len() > 1 {
      let b1 = bc.at(1)
      if b1 == "#" or b1 == "♯" {
        bass-acc = "sharp"
      } else if b1 == "b" or b1 == "♭" {
        bass-acc = "flat"
      }
    }
  }

  (root: root, root-accidental: root-acc, quality: quality, bass-root: bass-root, bass-accidental: bass-acc)
}

/// Render a chord symbol string into styled Typst content.
///
/// Handles:
/// - Capitalized root notes
/// - Accidentals as ♯ / ♭
/// - Quality/extensions (m, 7, maj7, dim, aug, sus4, etc.) in smaller superscript
/// - Slash chords with bass note
#let format-chord-symbol(sym) = {
  let parsed = parse-chord-symbol(sym)
  if parsed.root == "" { return [] }

  let root-size = 10pt
  let quality-size = 7.5pt
  let bass-size = 9pt

  // Build accidental display
  let acc-text(acc) = {
    if acc == "sharp" { "♯" }
    else if acc == "flat" { "♭" }
    else { "" }
  }

  // Build root portion
  let root-display = upper(parsed.root) + acc-text(parsed.root-accidental)

  // Build the chord content
  let result = {
    text(size: root-size, weight: "bold", root-display)
    if parsed.quality != "" {
      text(size: quality-size, weight: "bold", baseline: -1.5pt, parsed.quality)
    }
    if parsed.bass-root != none {
      text(size: root-size, weight: "bold", "/")
      text(size: bass-size, weight: "bold", baseline: 1.5pt, upper(parsed.bass-root) + acc-text(parsed.bass-accidental))
    }
  }

  result
}
