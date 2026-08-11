// pitch.typ - Pitch arithmetic, transposition, staff position calculation

#import "constants.typ": note-to-diatonic-index, clef-config

/// Compute the diatonic number of a pitch.
/// Diatonic number = note_index + octave * 7
/// where C=0, D=1, E=2, F=3, G=4, A=5, B=6
#let pitch-to-diatonic(name, octave) = {
  let idx = note-to-diatonic-index.at(name)
  idx + octave * 7
}

/// Compute the MIDI-style chromatic number (for interval/transposition purposes).
/// C4 = 60, C#4 = 61, etc.
#let pitch-to-chromatic(name, octave, accidental: none) = {
  let semitones = (
    c: 0, d: 2, e: 4, f: 5, g: 7, a: 9, b: 11,
  )
  let base = semitones.at(name) + octave * 12
  if accidental == "sharp" { base + 1 }
  else if accidental == "flat" { base - 1 }
  else if accidental == "double-sharp" { base + 2 }
  else if accidental == "double-flat" { base - 2 }
  else { base }
}

/// Compute the staff position for a note given a clef.
/// Returns the position where 0 = top staff line,
/// each +1 = one half-space downward.
/// Notes above the staff have negative positions.
/// Notes below the staff have positions > 8.
#let staff-position(name, octave, clef: "treble") = {
  let diatonic = pitch-to-diatonic(name, octave)
  let config = clef-config.at(clef)
  config.top-line-diatonic - diatonic
}

/// Determine stem direction based on staff position.
/// Notes on or above the middle line (position <= 4) get stems down.
/// Notes below the middle line (position > 4) get stems up.
#let auto-stem-direction(staff-pos) = {
  if staff-pos <= 4 { "down" } else { "up" }
}

/// Compute stem end Y position given note Y and stem direction.
/// Returns Y coordinate of the stem tip.
/// - note-y: Y coordinate of the notehead center
/// - stem-dir: "up" or "down"
/// - staff-space: size of one staff space
/// - min-length: minimum stem length in staff spaces (default 3.5)
#let compute-stem-end-y(note-y, staff-pos, stem-dir, staff-space, min-length: 3.5) = {
  let length = min-length * staff-space
  // Extend stem if note is far from the staff
  if staff-pos < -2 and stem-dir == "down" {
    // Note well above staff, stem needs to reach down to staff
    length = calc.max(length, (-staff-pos - 0) * staff-space / 2)
  }
  if staff-pos > 10 and stem-dir == "up" {
    // Note well below staff, stem needs to reach up to staff
    length = calc.max(length, (staff-pos - 8) * staff-space / 2)
  }
  if stem-dir == "up" {
    note-y + length  // CeTZ: up is positive Y
  } else {
    note-y - length
  }
}

/// Number of ledger lines needed for a given staff position.
/// Returns (count, direction) where direction is "above" or "below".
/// Returns (0, none) if no ledger lines are needed.
#let ledger-lines-needed(staff-pos) = {
  if staff-pos <= -2 {
    // Above the staff
    // Position -1 = space above top line (no ledger line needed)
    // Position -2 = first ledger line above
    // Position -3 = space above first ledger line (still needs that 1 line)
    // Position -4 = second ledger line above
    let count = calc.floor(calc.abs(staff-pos) / 2)
    (count: count, direction: "above")
  } else if staff-pos >= 10 {
    // Below the staff
    // Position 9 = space below bottom line (no ledger line needed)
    // Position 10 = first ledger line below
    // Position 11 = space below first ledger line (still needs that 1 line)
    // Position 12 = second ledger line below
    let count = calc.floor((staff-pos - 8) / 2)
    (count: count, direction: "below")
  } else {
    (count: 0, direction: none)
  }
}

/// Get the notes affected by a key signature.
/// Returns a dictionary mapping note names to "sharp" or "flat".
#let key-sig-accidentals(key) = {
  import "constants.typ": key-sig-accidental-count, sharp-order, flat-order
  let count = key-sig-accidental-count.at(key, default: 0)
  let result = (:)
  if count > 0 {
    for i in range(count) {
      result.insert(sharp-order.at(i), "sharp")
    }
  } else if count < 0 {
    for i in range(calc.abs(count)) {
      result.insert(flat-order.at(i), "flat")
    }
  }
  result
}
