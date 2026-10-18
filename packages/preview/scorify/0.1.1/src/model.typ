// model.typ - Internal data structures for the sheet-music library
//
// All music events are represented as Typst dictionaries with a "type" field.
// The parser produces arrays of these events, and the layout/renderer consume them.

// --- Event constructors ---

/// Create a note event.
/// - name: "c", "d", "e", "f", "g", "a", "b"
/// - accidental: none, "sharp", "flat", "natural", "double-sharp", "double-flat"
/// - octave: integer (4 = middle C octave)
/// - duration: 1, 2, 4, 8, 16, 32, 64
/// - dots: 0, 1, or 2
/// - tie: boolean - starts a tie from this note
/// - slur-start: boolean
/// - slur-end: boolean
/// - beam-start: boolean
/// - beam-end: boolean
/// - articulations: array of strings
/// - dynamic: optional dynamic marking string (e.g., "f", "pp", "sfz")
/// - fingering: optional fingering value (int, or array of ints for multiple fingers)
/// - fingering-position: "above" or "below" (default: "above")
/// - chord-symbol: optional chord symbol string (e.g., "C", "Am7", "Bb/F")
#let make-note(
  name,
  accidental: none,
  octave: 4,
  duration: 4,
  dots: 0,
  tie: false,
  slur-start: false,
  slur-end: false,
  beam-start: false,
  beam-end: false,
  articulations: (),
  dynamic: none,
  fingering: none,
  fingering-position: "above",
  chord-symbol: none,
  tuplet-n: 1,
  tuplet-m: 1,
  tuplet-start: false,
  tuplet-end: false,
) = (
  type: "note",
  name: name,
  accidental: accidental,
  octave: octave,
  duration: duration,
  dots: dots,
  tie: tie,
  slur-start: slur-start,
  slur-end: slur-end,
  beam-start: beam-start,
  beam-end: beam-end,
  articulations: articulations,
  dynamic: dynamic,
  fingering: fingering,
  fingering-position: fingering-position,
  chord-symbol: chord-symbol,
  tuplet-n: tuplet-n,
  tuplet-m: tuplet-m,
  tuplet-start: tuplet-start,
  tuplet-end: tuplet-end,
)

/// Create a rest event.
#let make-rest(
  duration: 4,
  dots: 0,
  tuplet-n: 1,
  tuplet-m: 1,
  tuplet-start: false,
  tuplet-end: false,
) = (
  type: "rest",
  duration: duration,
  dots: dots,
  tuplet-n: tuplet-n,
  tuplet-m: tuplet-m,
  tuplet-start: tuplet-start,
  tuplet-end: tuplet-end,
)

/// Create a spacer (invisible rest) event.
#let make-spacer(
  duration: 4,
  dots: 0,
) = (
  type: "spacer",
  duration: duration,
  dots: dots,
)

/// Create a barline event.
/// - style: "single", "double", "final", "repeat-start", "repeat-end", "repeat-both"
#let make-barline(
  style: "single",
) = (
  type: "barline",
  style: style,
)

/// Create a system/line break event.
/// This signals the renderer to start a new system at this point.
#let make-line-break() = (
  type: "line-break",
)

/// Create a clef change event.
/// - clef: "treble", "bass", "alto", "tenor", "treble-8", "treble+8", "percussion"
#let make-clef(
  clef,
) = (
  type: "clef",
  clef: clef,
)

/// Create a key signature event.
/// - key: "C", "G", "D", "A", "E", "B", "F#", "C#",
///         "F", "Bb", "Eb", "Ab", "Db", "Gb", "Cb"
///   Lowercase for minor: "a", "e", "b", "f#", "c#", "g#", "d#",
///                         "d", "g", "c", "f", "bb", "eb", "ab"
/// - mode: "major" or "minor"
#let make-key-sig(
  key,
  mode: "major",
) = (
  type: "key-sig",
  key: key,
  mode: mode,
)

/// Create a time signature event.
/// - upper: numerator (integer or string for compound, e.g., "3+2")
/// - lower: denominator (integer)
/// - symbol: none, "common", "cut"
#let make-time-sig(
  upper,
  lower,
  symbol: none,
) = (
  type: "time-sig",
  upper: upper,
  lower: lower,
  symbol: symbol,
)

/// Create a chord (simultaneous notes) event.
/// - notes: array of note events (without individual durations/dots)
/// - duration, dots, etc. apply to the whole chord
#let make-chord(
  notes,
  duration: 4,
  dots: 0,
  tie: false,
  slur-start: false,
  slur-end: false,
  beam-start: false,
  beam-end: false,
  articulations: (),
  dynamic: none,
  fingering: none,
  fingering-position: "above",
  chord-symbol: none,
) = (
  type: "chord",
  notes: notes,
  duration: duration,
  dots: dots,
  tie: tie,
  slur-start: slur-start,
  slur-end: slur-end,
  beam-start: beam-start,
  beam-end: beam-end,
  articulations: articulations,
  dynamic: dynamic,
  fingering: fingering,
  fingering-position: fingering-position,
  chord-symbol: chord-symbol,
)

// --- Staff description ---

/// Create a staff configuration.
#let make-staff(
  clef: "treble",
  music: "",
  label: none,
) = (
  clef: clef,
  music: music,
  label: label,
)

// --- Laid-out event (after layout pass) ---
// These have x, y positions assigned.
// Produced by the layout engine and consumed by the renderer.

#let make-laid-out-event(
  event,
  x: 0,
  y: 0,
  stem-dir: none,  // "up" or "down"
  stem-y-end: none,  // y coordinate of stem tip
) = (
  event: event,
  x: x,
  y: y,
  stem-dir: stem-dir,
  stem-y-end: stem-y-end,
)
