#import "draw-chord.typ": new-chordgen, parse-tabstring
#import "../gen/gen.typ": default-tuning, get-chord

/// Just a chordgen with arbitrary number of strings
#let _simple-auto-chord = new-chordgen(string-number: auto)
/// A chordgen with arbitrary number of strings and red hold points
#let _red-auto-chord = new-chordgen(string-number: auto, colors: (hold: red.darken(20%)))

/// 2. A chordgen that marks missing perfect fifth chords with red hold points.
/// That means chords with `?` in the end will be _red_.
/// ```example
/// #red-missing-fifth("012?")
/// ```
/// -> chord
#let red-missing-fifth(tabs, name: "", scale-l: 1pt) = {
  if tabs.at(-1) == "?" {
    _red-auto-chord(tabs.slice(0, -1), name: name, scale-l: scale-l)
  } else {
    _simple-auto-chord(tabs, name: name, scale-l: scale-l)
  }
}

/// 1. Function that renders chord by its name
/// ```example
/// #smart-chord("Am")
/// ```
/// -> chord
#let smart-chord(
  /// chord name -> str
  name,
  /// chordgen to use, the default one marks imperfect chords with red hold points
  chordgen: red-missing-fifth,
  /// number of chord to select, the "best" is zero -> int
  n: 0,
  /// tuning string in format "A1 B2 C3 D4"
  tuning: default-tuning,
  /// whether to require the lowest note to be the root note 
  true-bass: true,
  /// at which fret to search chord
  at: none,
  /// see `draw-chord` for reference
  scale-l: 1pt) = {
  chordgen(get-chord(name, n: n, tuning: tuning, at: at), name: name, scale-l: scale-l)
}

#let _notes = ("A", "A#", "B", "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#")
#let _chord-root-regex = regex("[A-G][#♯b♭]?")
#let _pm = (
  "#": 1,
  "♯": 1,
  "b": -1,
  "♭": -1
)

/// 3. Shifts tonality of given chord name by given amount with regexes
/// -> str
#let shift-chord-tonality(
  /// chord name -> str
  chord,
  /// number of halftones to move tonality -> int
  tonality) = {
  if chord.match(_chord-root-regex) == none {
    panic("Not a chord", chord)
  }

  chord.replace(_chord-root-regex, 
    match => {
      let match = match.text
      let base = _notes.position(e => e == match.at(0))
      let delta = if match.len() == 1 {0} else {_pm.at(match.at(1))}
      let new = calc.rem(base + delta + tonality, 12)
      _notes.at(new)
    }
  )
}

/// Gives the played notes by the tabstring -> array
#let chord-notes(
  /// -> str
  tabstring,
  /// the same format as everywhere -> str
  tuning
) = {
  let (arr, _) = parse-tabstring(tabstring)
  for (t, c) in arr.zip(tuning.split()) {
    if type(t) == int {
      (shift-chord-tonality(c.slice(0, c.len() - 1), t), )
    }
    else {
      (t,)
    }
  }
}
