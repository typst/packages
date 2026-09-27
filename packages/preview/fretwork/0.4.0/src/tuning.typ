// Tunings, and the mapping from (string, fret) to pitch.
//
// Pitch is carried as a MIDI note number even though phase 1 renders tablature
// only. A notation staff added later needs no new input from the user: string,
// fret and tuning already determine the sounding pitch unambiguously.

#let _semitones = (c: 0, d: 2, e: 4, f: 5, g: 7, a: 9, b: 11)

/// Parse a scientific pitch name such as `"E2"`, `"F#3"` or `"Bb1"` into a MIDI
/// note number. Middle C (C4) is 60.
#let midi-of(name) = {
  let chars = name.clusters()
  assert(chars.len() >= 2, message: "tuning: malformed pitch name '" + name + "'")
  let letter = lower(chars.at(0))
  assert(
    letter in _semitones,
    message: "tuning: '" + name + "' does not start with a note letter A-G",
  )
  let value = _semitones.at(letter)
  let i = 1
  while i < chars.len() and chars.at(i) in ("#", "b", "♯", "♭") {
    value += if chars.at(i) in ("#", "♯") { 1 } else { -1 }
    i += 1
  }
  let octave = int(chars.slice(i).join())
  value + (octave + 1) * 12
}

/// Define a tuning from a space-separated list of pitch names, given from the
/// *lowest-numbered* string downwards — i.e. string 1 first, which is the
/// highest-sounding string on a guitar.
///
/// ```typc
/// tuning("E4 B3 G3 D3 A2 E2", name: "Standard")
/// ```
#let tuning(pitches, name: none, labels: none) = {
  let names = pitches.split(" ").filter(s => s != "")
  let midi = names.map(midi-of)
  (
    name: name,
    // Index 0 is string 1. Guitarists number strings from the highest pitch.
    strings: midi,
    // Single-letter labels used by ASCII tab, top row first.
    labels: if labels != none { labels } else { names.map(n => n.slice(0, 1)) },
  )
}

/// Number of strings in a tuning.
#let string-count(t) = t.strings.len()

/// Sounding pitch of a fretted note, as a MIDI note number.
///
/// `string` is 1-based and counted from the highest-sounding string.
#let to-pitch(t, string, fret, capo: 0) = {
  assert(
    string >= 1 and string <= string-count(t),
    message: "tuning: string " + str(string) + " does not exist in this tuning",
  )
  t.strings.at(string - 1) + fret + capo
}

#let _names-sharp = ("C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B")

/// Render a MIDI note number as a scientific pitch name.
#let pitch-name(midi) = {
  _names-sharp.at(calc.rem-euclid(midi, 12)) + str(calc.div-euclid(midi, 12) - 1)
}

/// The tunings shipped with the package.
#let tunings = (
  standard: tuning("E4 B3 G3 D3 A2 E2", name: "Standard", labels: ("e", "B", "G", "D", "A", "E")),
  drop-d: tuning("E4 B3 G3 D3 A2 D2", name: "Drop D", labels: ("e", "B", "G", "D", "A", "D")),
  // Standard down a whole step with the sixth dropped another: the metal
  // tuning, and the one most often asked for after Drop D.
  drop-c: tuning("D4 A3 F3 C3 G2 C2", name: "Drop C"),
  half-step-down: tuning("Eb4 Bb3 Gb3 Db3 Ab2 Eb2", name: "Eb Standard"),
  full-step-down: tuning("D4 A3 F3 C3 G2 D2", name: "D Standard"),
  open-g: tuning("D4 B3 G3 D3 G2 D2", name: "Open G"),
  open-d: tuning("D4 A3 F#3 D3 A2 D2", name: "Open D"),
  dadgad: tuning("D4 A3 G3 D3 A2 D2", name: "DADGAD"),
  seven-string: tuning("E4 B3 G3 D3 A2 E2 B1", name: "7-string"),
  bass: tuning("G2 D2 A1 E1", name: "Bass"),
  bass-5: tuning("G2 D2 A1 E1 B0", name: "5-string bass"),
  ukulele: tuning("A4 E4 C4 G4", name: "Ukulele"),
)
