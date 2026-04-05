/// This module uses WASM


/// Classic 6-string Guitar tuning: `E1 A1 D2 G2 B2 E3` 
#let default-tuning = "E1 A1 D2 G2 B2 E3"

#let conchord_gen = plugin("conchord_gen.wasm")

#let n-best(arr, n: 18) = {
  arr.slice(0, calc.min(n, arr.len()))
}

/// Gets all possible chord strings with given tuning (and optionally at given fret)
/// Complex chord with omitted perfect fifth will have `?` in end
/// 
/// ```example
/// #get-chords("Cmaj7").slice(0, 10)
/// ```
/// -> array[str]
#let get-chords(
  /// Chord name -> str
  name,
  /// Tuning in format "A1 B2 C3" -> str
  tuning: default-tuning,
  /// What fret to find chords at -> int | none
  at: none,
  /// Whether to require the lowest note to be the root note. 
  /// Note that doesn't affect chords with `/` that set bass, like `A/E`.
  /// You can abuse it to make chords have true bass with `Am/A`.
  /// 
  /// Best to leave `true` for guitar, but `false` for ukulele, where the bas is not as important 
  true-bass: true) = {
  let at = if at == none {255} else {at}
  let true-bass = if true-bass {255} else {0}
  str(conchord_gen.get_chords(bytes(tuning), bytes(name), bytes((at,)), bytes((true-bass, )))).split(";")
}

/// Gets individual chord string
#let get-chord(name, n: 0, tuning: default-tuning, at: none, true-bass: true) = {
  get-chords(name, tuning: tuning, at: at, true-bass: true-bass).at(n)
}
