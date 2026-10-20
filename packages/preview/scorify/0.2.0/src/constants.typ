// constants.typ - SMuFL codepoints, key signature data, clef offsets
//
// All codepoints are from the SMuFL standard / Bravura font.
// Positions use a coordinate where 0 = top staff line,
// each increment of 1 = one half staff-space downward.

// ============================================================
// SMuFL Glyph Codepoints (Unicode Private Use Area)
// ============================================================

// --- Clefs ---
#let smufl-clefs = (
  treble: "\u{E050}",
  bass: "\u{E062}",
  alto: "\u{E05C}",
  tenor: "\u{E05C}",       // Same glyph as alto, positioned differently
  // Octave-clefs (8va / 8vb) - 'a' = alta (8 above), 'b' = bassa (8 below)
  treble-8a: "\u{E053}",   // gClef8va
  treble8a: "\u{E053}",    // alias
  treble-8b: "\u{E052}",   // gClef8vb (previously treble-8)
  treble8b: "\u{E052}",    // alias
  bass-8a: "\u{E065}",     // fClef8va
  bass8a: "\u{E065}",      // alias
  bass-8b: "\u{E064}",     // fClef8vb
  bass8b: "\u{E064}",      // alias

  // Quindicesima clefs (15ma / 15mb) - two-octave variants
  treble-15a: "\u{E054}",  // gClef15ma
  treble-15b: "\u{E051}",  // gClef15mb
  bass-15a: "\u{E066}",    // fClef15ma
  bass-15b: "\u{E063}",    // fClef15mb

  // Backwards-compatible aliases for older names
  treble-8: "\u{E052}",    // alias → treble-8b
  treble8: "\u{E052}",

  percussion: "\u{E069}",
)

// --- Noteheads ---
#let smufl-noteheads = (
  whole: "\u{E0A2}",
  half: "\u{E0A3}",
  black: "\u{E0A4}",       // quarter and shorter
)

// --- Flags ---
#let smufl-flags = (
  eighth-up: "\u{E240}",
  eighth-down: "\u{E241}",
  sixteenth-up: "\u{E242}",
  sixteenth-down: "\u{E243}",
  thirtysecond-up: "\u{E244}",
  thirtysecond-down: "\u{E245}",
  sixtyfourth-up: "\u{E246}",
  sixtyfourth-down: "\u{E247}",
)

// --- Rests ---
#let smufl-rests = (
  whole: "\u{E4E3}",
  half: "\u{E4E4}",
  quarter: "\u{E4E5}",
  eighth: "\u{E4E6}",
  sixteenth: "\u{E4E7}",
  thirtysecond: "\u{E4E8}",
  sixtyfourth: "\u{E4E9}",
)

// --- Accidentals ---
#let smufl-accidentals = (
  sharp: "\u{E262}",
  flat: "\u{E260}",
  natural: "\u{E261}",
  double-sharp: "\u{E263}",
  double-flat: "\u{E264}",
)

// --- Time signature digits ---
#let smufl-time-digits = (
  "\u{E080}",  // 0
  "\u{E081}",  // 1
  "\u{E082}",  // 2
  "\u{E083}",  // 3
  "\u{E084}",  // 4
  "\u{E085}",  // 5
  "\u{E086}",  // 6
  "\u{E087}",  // 7
  "\u{E088}",  // 8
  "\u{E089}",  // 9
)
#let smufl-time-common = "\u{E08A}"
#let smufl-time-cut = "\u{E08B}"

// --- Dynamics ---
#let smufl-dynamics = (
  p: "\u{E520}",
  m: "\u{E521}",
  f: "\u{E522}",
  r: "\u{E523}",
  s: "\u{E524}",
  z: "\u{E525}",
)

// --- Articulations ---
#let smufl-articulations = (
  staccato-above: "\u{E4A2}",
  staccato-below: "\u{E4A3}",
  accent-above: "\u{E4A0}",
  accent-below: "\u{E4A1}",
  tenuto-above: "\u{E4A4}",
  tenuto-below: "\u{E4A5}",
  marcato-above: "\u{E4AC}",
  marcato-below: "\u{E4AD}",
  fermata-above: "\u{E4C0}",
  fermata-below: "\u{E4C1}",
)

// --- Ornaments ---
#let smufl-ornaments = (
  trill: "\u{E566}",
  wiggle-trill: "\u{EAA4}",
  mordent: "\u{E56C}",
  turn: "\u{E567}",
)

// --- Other symbols ---
#let smufl-other = (
  breath-mark: "\u{E4CE}",
  caesura: "\u{E4D1}",
  dal-segno: "\u{E045}",
  segno: "\u{E047}",
  coda: "\u{E048}",
  repeat-dot: "\u{E044}",
  brace: "\u{E000}",
  augmentation-dot: "\u{E1E7}",
)

// ============================================================
// Clef Configuration
// ============================================================

// The "top-line diatonic number" for each clef.
// Diatonic number = note_index + octave*7 where C=0, D=1, E=2, F=3, G=4, A=5, B=6
// This defines which pitch sits on the top line of the staff.
// Staff position of a note = clef_top_diatonic - note_diatonic

#let note-to-diatonic-index = (
  c: 0, d: 1, e: 2, f: 3, g: 4, a: 5, b: 6,
)

#let supported-clefs = (
  "treble",
  "bass",
  "alto",
  "tenor",
  "treble-8a",
  "treble8a",
  "treble-8b",
  "treble8b",
  "treble-15a",
  "treble-15b",
  "treble-8",
  "treble8",
  "bass-8a",
  "bass8a",
  "bass-8b",
  "bass8b",
  "bass-15a",
  "bass-15b",
  "percussion",
)

#let clef-default-base-octave(clef) = {
  let bass-clefs = (
    "bass",
    "bass-8a",
    "bass8a",
    "bass-8b",
    "bass8b",
    "bass-15a",
    "bass-15b",
  )
  if bass-clefs.contains(clef) { 3 } else { 4 }
}

#let clef-config = (
  treble: (
    top-line-diatonic: 38,  // F5 = 3 + 5*7
    glyph: "\u{E050}",
    glyph-y-offset: 3,      // Glyph anchor is at G4 (second line), so position from top line
  ),
  bass: (
    top-line-diatonic: 26,  // A3 = 5 + 3*7
    glyph: "\u{E062}",
    glyph-y-offset: 1,      // Glyph anchor is at F3 (fourth line from bottom = second from top)
  ),
  alto: (
    top-line-diatonic: 32,  // G4 = 4 + 4*7
    glyph: "\u{E05C}",
    glyph-y-offset: 4,      // Anchor at C4 (middle line)
  ),
  tenor: (
    top-line-diatonic: 30,  // E4 = 2 + 4*7
    glyph: "\u{E05C}",
    glyph-y-offset: 4,      // Anchor at C4 (4th line from bottom = 2nd from top => pos 2)... but tenor has C4 at pos 2
  ),
  // Octave clefs (8va/8vb) - adjust top-line diatonic to shift staff mapping
  // Variants should NOT change internal pitch-to-staff mapping; keep the
  // same top-line diatonic as the base clef so note positions remain stable.
  treble-8a: (
    top-line-diatonic: 38,
    glyph: "\u{E053}",
    glyph-y-offset: 3,
  ),
  treble8a: (
    top-line-diatonic: 38,
    glyph: "\u{E053}",
    glyph-y-offset: 3,
  ),
  treble-8b: (
    top-line-diatonic: 38,
    glyph: "\u{E052}",
    glyph-y-offset: 3,
  ),
  treble8b: (
    top-line-diatonic: 38,
    glyph: "\u{E052}",
    glyph-y-offset: 3,
  ),

  bass-8a: (
    top-line-diatonic: 26,
    glyph: "\u{E065}",
    glyph-y-offset: 1,
  ),
  bass8a: (
    top-line-diatonic: 26,
    glyph: "\u{E065}",
    glyph-y-offset: 1,
  ),
  bass-8b: (
    top-line-diatonic: 26,
    glyph: "\u{E064}",
    glyph-y-offset: 1,
  ),
  bass8b: (
    top-line-diatonic: 26,
    glyph: "\u{E064}",
    glyph-y-offset: 1,
  ),

  // Quindicesima clefs (15ma/15mb) — two-octave variants, but keep base mapping
  treble-15a: (
    top-line-diatonic: 38,
    glyph: "\u{E054}",
    glyph-y-offset: 3,
  ),
  treble-15b: (
    top-line-diatonic: 38,
    glyph: "\u{E051}",
    glyph-y-offset: 3,
  ),
  bass-15a: (
    top-line-diatonic: 26,
    glyph: "\u{E066}",
    glyph-y-offset: 1,
  ),
  bass-15b: (
    top-line-diatonic: 26,
    glyph: "\u{E063}",
    glyph-y-offset: 1,
  ),
  percussion: (
    top-line-diatonic: 38,  // Same as treble (arbitrary)
    glyph: "\u{E069}",
    glyph-y-offset: 4,
  ),
)

// ============================================================
// Key Signature Data
// ============================================================

// Number of sharps (positive) or flats (negative) for each key
#let key-sig-accidental-count = (
  // Major keys
  "C": 0, "G": 1, "D": 2, "A": 3, "E": 4,  "B": 5,  "F#": 6, "C#": 7,
  "F": -1, "Bb": -2, "Eb": -3, "Ab": -4, "Db": -5, "Gb": -6, "Cb": -7,
  // Minor keys (lowercase)
  "a": 0, "e": 1, "b": 2, "f#": 3, "c#": 4, "g#": 5, "d#": 6, "a#": 7,
  "d": -1, "g": -2, "c": -3, "f": -4, "bb": -5, "eb": -6, "ab": -7,
)

// The note names in the order sharps are added to the key signature
#let sharp-order = ("f", "c", "g", "d", "a", "e", "b")
#let flat-order = ("b", "e", "a", "d", "g", "c", "f")

// Staff positions (0 = top line) for key signature accidentals per clef
// Each is an array of 7 positions - use only the first N for N sharps/flats
#let key-sig-sharp-positions = (
  treble:   (0, 3, -1, 2, 5, 1, 4),
  bass:     (2, 5, 1, 4, 7, 3, 6),
  alto:     (1, 4, 0, 3, 6, 2, 5),
  tenor:    (3, 6, 2, 5, 1, 4, 7),
  treble-8a: (0, 3, -1, 2, 5, 1, 4),
  treble8a:  (0, 3, -1, 2, 5, 1, 4),
  treble-8b: (0, 3, -1, 2, 5, 1, 4),
  treble8b:  (0, 3, -1, 2, 5, 1, 4),
  treble-15a: (0, 3, -1, 2, 5, 1, 4),
  treble-15b: (0, 3, -1, 2, 5, 1, 4),
  percussion: (0, 3, -1, 2, 5, 1, 4),
)

#let key-sig-flat-positions = (
  treble:   (4, 1, 5, 2, 6, 3, 7),
  bass:     (6, 3, 7, 4, 8, 5, 2),
  alto:     (5, 2, 6, 3, 7, 4, 1),
  tenor:    (7, 4, 1, 5, 2, 6, 3),
  treble-8a: (4, 1, 5, 2, 6, 3, 7),
  treble8a:  (4, 1, 5, 2, 6, 3, 7),
  treble-8b: (4, 1, 5, 2, 6, 3, 7),
  treble8b:  (4, 1, 5, 2, 6, 3, 7),
  treble-15a: (4, 1, 5, 2, 6, 3, 7),
  treble-15b: (4, 1, 5, 2, 6, 3, 7),
  percussion: (4, 1, 5, 2, 6, 3, 7),
)

// ============================================================
// Default Dimensions (in staff spaces)
// ============================================================

#let default-staff-space = 1.75mm
#let default-staff-line-thickness = 0.13   // in staff spaces (≈ 0.23mm)
#let default-stem-thickness = 0.12         // in staff spaces
#let default-beam-thickness = 0.5          // in staff spaces
#let default-beam-spacing = 0.25           // gap between beams in staff spaces
#let default-barline-thickness = 0.16      // in staff spaces
#let default-thick-barline = 0.35          // in staff spaces
#let default-min-stem-length = 3.5         // in staff spaces
#let default-ledger-line-extension = 0.4   // how far ledger lines extend past the notehead

// Horizontal spacing constants (in staff spaces)
#let default-inline-clef-scale = 0.8       // Cue-sized clefs for mid-system clef changes
#let default-clef-padding = 0.5            // Space after clef
#let default-key-sig-padding = 1.0         // Space after key signature
#let default-time-sig-padding = 1.25       // Space after time signature
#let default-note-spacing-base = 2.5       // Base spacing for quarter note
#let default-barline-padding = 0.5         // Space before/after barlines
#let default-accidental-padding = 0.35     // Space for accidental before notehead

// Font sizing
#let default-music-font-size-factor = 4.0  // Multiple of staff-space for glyph rendering

// ============================================================
// Clef SMuFL Metadata Mappings
// ============================================================

// SMuFL glyph names for each clef (for bounding box / advance lookups)
#let clef-smufl-name = (
  treble: "gClef",
  bass: "fClef",
  alto: "cClef",
  tenor: "cClef",
  // 8va / 8vb glyph name mappings
  treble-8a: "gClef8va",
  treble8a: "gClef8va",
  treble-8b: "gClef8vb",
  treble8b: "gClef8vb",
  bass-8a: "fClef8va",
  bass8a: "fClef8va",
  bass-8b: "fClef8vb",
  bass8b: "fClef8vb",
  // 15ma / 15mb
  treble-15a: "gClef15ma",
  treble-15b: "gClef15mb",
  bass-15a: "fClef15ma",
  bass-15b: "fClef15mb",
  // Backwards-compatible aliases
  treble-8: "gClef8vb",
  treble8: "gClef8vb",
  percussion: "unpitchedPercussionClef1",
)

// Number of staff-spaces from the TOP staff line down to the clef's reference line.
// treble: G4 on 2nd line from bottom = 4th from top → 3 sp
// bass:   F3 on 4th line from bottom = 2nd from top → 1 sp
// alto:   C4 on 3rd line (middle) → 2 sp
// tenor:  C4 on 4th line from bottom = 2nd from top → 1 sp
#let clef-origin-offset = (
  treble: 3.0,
  bass: 1.0,
  alto: 2.0,
  tenor: 1.0,
  // 8va / 8vb use the same visual anchor offsets as the base clefs
  treble-8a: 3.0,
  treble8a: 3.0,
  treble-8b: 3.0,
  treble8b: 3.0,
  bass-8a: 1.0,
  bass8a: 1.0,
  bass-8b: 1.0,
  bass8b: 1.0,
  // 15ma / 15mb
  treble-15a: 3.0,
  treble-15b: 3.0,
  bass-15a: 1.0,
  bass-15b: 1.0,
  // Backwards-compat
  treble-8: 3.0,
  treble8: 3.0,
  percussion: 2.0,
)
