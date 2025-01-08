#import "draw-chord.typ": new-chordgen
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
  /// tuning string in format "A B C D E"
  tuning: default-tuning,
  /// at which fret to search chord
  at: none,
  /// see `draw-chord` for reference
  scale-l: 1pt) = {
  chordgen(get-chord(name, n: n, tuning: tuning, at: at), name: name, scale-l: scale-l)
}
