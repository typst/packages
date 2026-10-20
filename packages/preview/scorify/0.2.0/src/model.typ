// model.typ - Internal data structures for the scorify library
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
/// - hairpin: optional span type ("cresc" or "decresc")
/// - trill: whether a trill symbol should be rendered
/// - trill-line: whether the trill includes a wavy continuation line
/// - grace: whether this note is part of a grace-note group
/// - grace-slash: whether the grace group should render an acciaccatura slash
/// - ending: optional ending label string (e.g., "1.", "2nd")
/// - fingering: optional fingering value (int, or array of ints for multiple fingers)
/// - fingering-position: "above" or "below" (default: "above")
/// - chord-symbol: optional chord symbol string (e.g., "C", "Am7", "Bb/F")
/// - staff-markers: optional array of above-staff symbol markers
/// - staff-text: optional staff-level annotation rendered above chord symbols/fingerings
/// - expression-text: optional italic expression text rendered below the staff near dynamics
/// - lyrics: optional array of lyric attachment dictionaries
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
  hairpin: none,
  hairpin-start: false,
  hairpin-end: false,
  trill: false,
  trill-line: false,
  trill-start: false,
  trill-end: false,
  grace: false,
  grace-slash: false,
  ending: none,
  ending-start: false,
  ending-end: false,
  fingering: none,
  fingering-position: "above",
  chord-symbol: none,
  staff-markers: (),
  staff-text: none,
  expression-text: none,
  lyrics: (),
  tuplet-beats: 0,
  tuplet-number: 0,
  tuplet-count: 0,
  tuplet-start: false,
  tuplet-end: false,
  octave-line-number: 0,
  octave-line-direction: none,
  octave-line-start: false,
  octave-line-end: false,
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
  hairpin: hairpin,
  hairpin-start: hairpin-start,
  hairpin-end: hairpin-end,
  trill: trill,
  trill-line: trill-line,
  trill-start: trill-start,
  trill-end: trill-end,
  grace: grace,
  grace-slash: grace-slash,
  ending: ending,
  ending-start: ending-start,
  ending-end: ending-end,
  fingering: fingering,
  fingering-position: fingering-position,
  chord-symbol: chord-symbol,
  staff-markers: staff-markers,
  staff-text: staff-text,
  expression-text: expression-text,
  lyrics: lyrics,
  tuplet-beats: tuplet-beats,
  tuplet-number: tuplet-number,
  tuplet-count: tuplet-count,
  tuplet-start: tuplet-start,
  tuplet-end: tuplet-end,
  octave-line-number: octave-line-number,
  octave-line-direction: octave-line-direction,
  octave-line-start: octave-line-start,
  octave-line-end: octave-line-end,
)

/// Create a rest event.
#let make-rest(
  duration: 4,
  dots: 0,
  tuplet-beats: 0,
  tuplet-number: 0,
  tuplet-count: 0,
  tuplet-start: false,
  tuplet-end: false,
  octave-line-number: 0,
  octave-line-direction: none,
  octave-line-start: false,
  octave-line-end: false,
  hairpin: none,
  hairpin-start: false,
  hairpin-end: false,
  trill: false,
  trill-line: false,
  trill-start: false,
  trill-end: false,
  grace: false,
  grace-slash: false,
  ending: none,
  ending-start: false,
  ending-end: false,
) = (
  type: "rest",
  duration: duration,
  dots: dots,
  tuplet-beats: tuplet-beats,
  tuplet-number: tuplet-number,
  tuplet-count: tuplet-count,
  tuplet-start: tuplet-start,
  tuplet-end: tuplet-end,
  octave-line-number: octave-line-number,
  octave-line-direction: octave-line-direction,
  octave-line-start: octave-line-start,
  octave-line-end: octave-line-end,
  hairpin: hairpin,
  hairpin-start: hairpin-start,
  hairpin-end: hairpin-end,
  trill: trill,
  trill-line: trill-line,
  trill-start: trill-start,
  trill-end: trill-end,
  grace: grace,
  grace-slash: grace-slash,
  ending: ending,
  ending-start: ending-start,
  ending-end: ending-end,
)

/// Create a spacer (invisible rest) event.
#let make-spacer(
  duration: 4,
  dots: 0,
  ending: none,
  ending-start: false,
  ending-end: false,
) = (
  type: "spacer",
  duration: duration,
  dots: dots,
  ending: ending,
  ending-start: ending-start,
  ending-end: ending-end,
)

/// Create a manual spacing gap event.
#let make-gap(
  amount: 1,
) = (
  type: "gap",
  amount: amount,
)

/// Create a barline event.
/// - style: "single", "double", "final", "repeat-start", "repeat-end", "repeat-both"
#let make-barline(
  style: "single",
  ending: none,
  ending-start: false,
  ending-end: false,
) = (
  type: "barline",
  style: style,
  ending: ending,
  ending-start: ending-start,
  ending-end: ending-end,
)

/// Create a system/line break event.
/// This signals the renderer to start a new system at this point.
#let make-line-break() = (
  type: "line-break",
)

/// Create a clef change event.
/// - clef: "treble", "bass", "alto", "tenor", "treble-8a", "treble-8b", "treble-15a", "treble-15b", "bass-8a", "bass-8b", "bass-15a", "bass-15b", "percussion"
#let make-clef(
  clef,
  ending: none,
  ending-start: false,
  ending-end: false,
) = (
  type: "clef",
  clef: clef,
  ending: ending,
  ending-start: ending-start,
  ending-end: ending-end,
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
  ending: none,
  ending-start: false,
  ending-end: false,
) = (
  type: "time-sig",
  upper: upper,
  lower: lower,
  symbol: symbol,
  ending: ending,
  ending-start: ending-start,
  ending-end: ending-end,
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
  hairpin: none,
  hairpin-start: false,
  hairpin-end: false,
  trill: false,
  trill-line: false,
  trill-start: false,
  trill-end: false,
  grace: false,
  grace-slash: false,
  ending: none,
  ending-start: false,
  ending-end: false,
  fingering: none,
  fingering-position: "above",
  chord-symbol: none,
  staff-markers: (),
  staff-text: none,
  expression-text: none,
  lyrics: (),
  tuplet-beats: 0,
  tuplet-number: 0,
  tuplet-count: 0,
  tuplet-start: false,
  tuplet-end: false,
  octave-line-number: 0,
  octave-line-direction: none,
  octave-line-start: false,
  octave-line-end: false,
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
  hairpin: hairpin,
  hairpin-start: hairpin-start,
  hairpin-end: hairpin-end,
  trill: trill,
  trill-line: trill-line,
  trill-start: trill-start,
  trill-end: trill-end,
  grace: grace,
  grace-slash: grace-slash,
  ending: ending,
  ending-start: ending-start,
  ending-end: ending-end,
  fingering: fingering,
  fingering-position: fingering-position,
  chord-symbol: chord-symbol,
  staff-markers: staff-markers,
  staff-text: staff-text,
  expression-text: expression-text,
  lyrics: lyrics,
  tuplet-beats: tuplet-beats,
  tuplet-number: tuplet-number,
  tuplet-count: tuplet-count,
  tuplet-start: tuplet-start,
  tuplet-end: tuplet-end,
  octave-line-number: octave-line-number,
  octave-line-direction: octave-line-direction,
  octave-line-start: octave-line-start,
  octave-line-end: octave-line-end,
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
