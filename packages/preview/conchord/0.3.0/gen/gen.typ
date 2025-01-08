/// This module uses WASM


/// Classic 6-string Guitar tuning: `E A D G B E` 
#let default-tuning = "E A D G B E"

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
  /// Tuning in format "A B C" -> str
  tuning: default-tuning,
  /// What fret to find chords at -> int | none
  at: none) = {
  let at = if at == none {255} else {at}
  str(conchord_gen.get_chords(bytes(tuning), bytes(name), bytes((at,)))).split(";")
}

/// Gets individual chord string
#let get-chord(name, n: 0, tuning: default-tuning, at: none) = {
  get-chords(name, tuning: tuning, at: at).at(n)
}
