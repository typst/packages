#import "data.typ": *

#let is-integer(char) = {
 let digits = ("0", "1", "2", "3", "4", "5", "6", "7", "8", "9")
 char in digits
}

#let zip(a, b) = {
  assert(a.len() == b.len())
  let results = ()
  for (i, ax) in a.enumerate() {
    let bx = b.at(i)
    results.push((ax, bx))
  }
  return results
}

// key can be:
// C -> C Major
// Bb -> Bb Major
// a# -> A# Minor
// bb -> Bb Minor
// none -> C Major
// "" (empty) -> C Major
// "3b" -> 3 flats (Eb Major)
#let determine-key(key) = {
 if key == none or key == "" {
   // empty key
   (
     num-chromatics: 0,
     symbol-type: "sharp"
   )
 } else if is-integer(key.at(0)) {
   // e.g. "5#"
   let num-chromatics = int(key.at(0))
   let symbol-char = key.at(1)
   assert(symbol-char in symbol-map.keys(), message: "number-based key argument must end with " + symbol-data.keys().map(str).join(" or "))
   let symbol-type = symbol-map.at(symbol-char)
   (
     num-chromatics: num-chromatics,
     symbol-type: symbol-type
   )
 } else {
   // e.g. "Fb"
   let this-key-index
   let mid-index
   let tonality
   
   if key in key-data.major {
     this-key-index = key-data.major.position(k => k == key)
     mid-index = key-data.major.position(k => k == "C")
   } else if key in key-data.minor {
     this-key-index = key-data.minor.position(k => k == key)
     mid-index = key-data.minor.position(k => k == "a")
   } else {
     panic("Invalid key: " + key)
   }

   let num-chromatics = calc.abs(this-key-index - mid-index)
   let symbol-type = if (this-key-index >= mid-index) { "sharp" } else { "flat" }
   
   (
     num-chromatics: num-chromatics,
     symbol-type: symbol-type,
   )
 }
}


#let letter-note(letter, octave, accidental: none) = {
  assert(type(octave) == int, message: "octave must be an integer. Did you mix up argument order for letter-note?")
  (
    type: "letter-note",
    letter: letter,
    accidental: accidental,
    octave: octave
  )
}


#let index-note(index, side) = {
  (
    type: "index-note",
    index: index,
    side: side
  )
}

// takes in a string
// returns a dictionary (letter-based note)
// e.g. "Cb5" => {"letter": "C", "accidental": "b", octave: 5}
// e.g. "A6" => {"letter": "C", "accidental": "n", octave: 5}
// accidental defaults to none (distinct from "n" for natural)
#let parse-note-string(note) = {
  if type(note) == dictionary and note.type == "letter-note" {
    return note
  }
  assert(type(note) == str, message: "invalid note data type")
  if note.len() < 2 or note.len() > 3 {
    panic("Invalid note format: " + note)
  }
  
  let letter = upper(note.at(0))
  let octave-result = int(note.slice(-1))
  if octave-result == none {
    panic("Unable to parse octave integer from note: " + note)
  }
  let octave = octave-result
  
  let accidental = if note.len() == 3 {
    note.at(1)
  } else {
    none
  }

  if accidental != none {
    assert(accidental in symbol-map.keys(), message: "Unable to parse note: " + note + ", unknown accidental " + accidental)
  }

  return letter-note(letter, octave, accidental: accidental)
  (
    type: "letter-note",
    letter: letter,
    accidental: accidental,
    octave: octave
  )
}

// from letter-note to string
#let serialise-note(note, suppress-natural: false, suppress-octave: false) = {
  let a = if note.accidental == none {
    ""
  } else if suppress-natural and note.accidental == "n" {
    ""
  } else {
    note.accidental
  }
  let ov = if suppress-octave { "" } else { str(note.octave) }
  return note.letter + a + ov
}

// concats letter and accidental
// handling case where accidental: none
// and optionally converting "n" -> ""
#let letter-and-accidental-str(letter, accidental, suppress-natural: false) = {
  if (accidental == "n") and suppress-natural {
    return letter-and-accidental-str(letter, none)
  } else if accidental == none {
    return letter
  } else if accidental == "s" {
    // change from "s" to "#"
    return letter-and-accidental-str(letter, "#")
  } else {
    assert(accidental in symbol-map.keys(), message: "Unable to parse note: " + letter + ", unknown accidental " + accidental)
    return letter + accidental
  }
}

// "b" -> "flat"
// "s" -> "sharp"
// "#" -> "sharp"
#let side-from-accidental(accidental) = {
  let side = symbol-map.at(accidental)
  assert(side in allowed-sides, message: "Unable to determine side from accidental")
  return side
}

// takes in a letter-note
// sets it to flat, sharp or natural
#let set-accidental(note, accidental, overwrite-existing: false) = {
  if not overwrite-existing {
    assert(note.accidental == none, message: "would overwrite accidental in set-accidental without overwrite-existing")
  }
  return letter-note(note.letter, note.octave, accidental: accidental)
}



// convert from letter-note type to index-note type
#let letter-to-index(note, side: none) = {
  if note.at("type") == "index-note" {
    // already the type we want
    return note
  }
  assert(note.at("type") == "letter-note", message: "Unknown data type when converting to index-note")

  if note.accidental in (none, "n") {
    assert(side != none, message: "Must specify side if note is a natural")
  } else if side == none {
    side = side-from-accidental(note.accidental)
  }

  // edge cases: C flat, E sharp etc
  if ((note.accidental == "b") and (note.letter == "C")) {
    // C flat equal b
    // but need to decrement octave index
    let new-note = letter-note("B", note.octave - 1, accidental: none)
    return letter-to-index(new-note, side: side)
  } else if ((note.accidental == "b") and (note.letter == "F")) {
    let new-note = letter-note("E", note.octave, accidental: none)
    return letter-to-index(new-note, side: side)
  } else if ((note.accidental in ("s", "#")) and (note.letter == "B")) {
    // B sharp equals C natural
    // but need to increment octave index
    let new-note = letter-note("C", note.octave + 1, accidental: none)
    return letter-to-index(new-note, side: side)
  } else if ((note.accidental in ("s", "#")) and (note.letter == "E")) {
    let new-note = letter-note("F", note.octave, accidental: none)
    return letter-to-index(new-note, side: side)
  }
  

  let octaves-above-middle-c = note.octave - middle-c-octave

  let a-s = letter-and-accidental-str(note.letter, note.accidental, suppress-natural: true)

  assert(side in allowed-sides, message: "unknown side: " + side)
  assert(side in all-notes-from-c, message: "unknown side: " + side)
  assert(a-s in all-notes-from-c.at(side), message: "unable to calculate index of " + a-s + " above C with side=" + side)
  
  let semitones-above-c = all-notes-from-c.at(side).position(s => s == a-s)

  let index = middle-c-index + semitones-above-c + semitones-per-octave * octaves-above-middle-c

  return index-note(index, side)
  
}

// convert from index-note type to letter-note type
#let index-to-letter(note) = {
  if note.at("type") == "letter-note" {
    return note
  }
  assert(note.at("type") == "index-note", message: "unknown type for index-to-letter, type: " + str(type(note)))

  let semitones-above-middle-c = note.index - middle-c-index
  let octaves-above-middle-c = calc.div-euclid(semitones-above-middle-c, semitones-per-octave)
  let semitones-above-c = calc.rem-euclid(semitones-above-middle-c, semitones-per-octave)
  let octave = middle-c-octave + octaves-above-middle-c
  
  let a-s = all-notes-from-c.at(note.side).at(semitones-above-c)
  let letter = a-s.at(0)
  let accidental = if a-s.len() == 1 {
    none
  } else {
    a-s.at(2 - 1)
  }

  return letter-note(letter, octave, accidental: accidental)
  
}


// "sharp" -> "flat"
// "flat" -> "sharp"
#let flip-side(side) = {
  // if it's the first side, take the second
  // if it's the second side, take the first
  return allowed-sides.at(1 - allowed-sides.position(s => s == side))
}

// takes in a letter-note
// flips from sharp to flat, for the same note
// e.g. F# to Gb
#let flip-accidental(note) = {
  assert(note.at("type") == "letter-note")
  assert(note.accidental != none, message: "flip-accidental applies to non-natural notes")
  if note.accidental == "s" {
    note.accidental = "#"
  }
  assert(note.accidental in ("#", "b"), message: "Expected # or b. Got " + note.accidental)

  let side = side-from-accidental(note.accidental)
  let index-note = letter-to-index(note, side: side-from-accidental(note.accidental))
  index-note.side = flip-side(index-note.side)

  return index-to-letter(index-note)

}



// takes in a 
// e.g. for clef: "treble", note-letter: "C4", height is -1
// e.g. for clef: "treble", note-letter: "F4", height is +0.5
// e.g. for clef: "treble", note-letter: "B4", height is +2
// Note that the integer changes at C, not A
// e.e.g B4, C5, D5 are consecutive
#let calc-note-height(clef, note) = {
  assert(type(note) != type(""), message: "calc-note-height expects letter-note data type, not raw string")
  assert(note.at("type") == "letter-note", message: "unsupported note type in calc-note-height")
  // find difference in letters above/below C
  // typst is zero-index based
  let notes-above-c = all-letters-from-c.position(n => n == note.letter)
  
  let mid-c-height = clef-data.at(clef).at("middle-c")

  // now calculate height
  mid-c-height + (note.octave - 4) * all-letters-from-c.len() * 0.5 + notes-above-c * 0.5
}


#let shift-octave(note, octaves) = {
  if type(note) == str {
    return shift-octave(parse-note-string(note), octaves)
  } else if note.type == "index-note" {
    return index-note(note.index + semitones-per-octave * octaves, note.side)
  } else {
    assert(note.type == "letter-note")
    return letter-note(note.letter, note.octave + octaves, accidental: note.accidental)
  }
}

// increments from one natural to the next
#let increment-wholenote(note, steps: 1) = {
  assert(note.at("type") == "letter-note")
  assert(note.accidental in (none, "n"), message: "Expected no accidental. Got " + serialise-note(note))

  if steps == 0 {
    return note
  }else if steps < 0 {
    panic("Decrementing notes not supported")
  } else if steps >= 7 {
    // skip a whole octave at a time
    // for performance reasons
    return increment-wholenote(shift-octave(note, 1), steps: (steps - num-letters-per-octave))
  }

  let old-letter-index = all-letters-from-c.position(x => x == note.letter)
  let new-letter-index = calc.rem-euclid(old-letter-index + steps, all-letters-from-c.len())
  let new-octave = if new-letter-index > old-letter-index {
    note.octave
  } else {
    // we have wrapped around
    note.octave + 1
  }
  let new-letter = all-letters-from-c.at(new-letter-index)

  return letter-note(new-letter, new-octave)

}


// A -> B -> C ... G -> A
#let increment-letter(letter) = {
  let start-index = all-letters-from-c.position(x => x == letter)
  let next-index = calc.rem-euclid(start-index + 1, all-letters-from-c.len())
  return all-letters-from-c.at(next-index)
}



// takes in a letter-note
// removes the sharp/flat/natural
// replaces with none
#let remove-accidental(note) = {
  assert(note.type == "letter-note")
  return letter-note(note.letter, note.octave)
}

#let add-semitones(start-letter, start-accidental, start-octave, steps: 1, side: "sharp") = {
  assert(start-letter.len() == 1, message: "Argument start-letter to add-semitone is more than 1 char: " + start-letter)
  assert(side in allowed-sides, message: "invalid side: " + side + ", must be one of " + allowed-sides.join(","))
  if steps == 0 {
    return letter-note(start-letter, start-octave, accidental: start-accidental)
  } else if steps >= semitones-per-octave {
    // skip a whole octave at a time
    // for performance reasons
    return add-semitones(start-letter, start-accidental, start-octave + 1, steps: steps - semitones-per-octave, side: side)
  } else if steps < 0 {
    // to decrement, drop an octave, then increase by an octave minus the decrement
    
    return add-semitones(start-letter, start-accidental, start-octave - 1, steps: steps + semitones-per-octave, side: side)
  } else if (start-letter == "B") and (start-accidental in (none, "n", "")) {
    // increment octave number when going from B to C
    return add-semitones("C", none, start-octave + 1, steps: steps - 1, side: side)
  } else if (start-letter == "E") and (start-accidental in (none, "n", "")) {
    // natural to natural, no black key
    return add-semitones("F", none, start-octave, steps: steps - 1, side: side)
  } else if start-accidental == "b" {
    // remove the flat
    return add-semitones(start-letter, none, start-octave, steps: steps - 1, side: side)
    
  } else if start-accidental in ("n", "", none) {
    // we've dealt with B -> C and E -> F already
    if side == "sharp" {
      // sharpen this note
      return add-semitones(start-letter, "#", start-octave, steps: steps - 1, side: side)
    } else { // flats
      assert(side == "flat", message: "unknown side: " + side)
      // flatten the next note
      return add-semitones(increment-letter(start-letter), "b", start-octave, steps: steps - 1, side: side)
    }
  } else {
    assert(start-accidental in ("s", "#"), message: "Unknown accidental: " + start-accidental)
    return add-semitones(increment-letter(start-letter), none, start-octave, steps: steps - 1, side: side)
    
  }
}



// takes in an array
// returns (bool, bool, any)
// (first, last, value)
#let first-last(arr) = {
  let new-arr = ()
  for (i, val) in arr.enumerate() {
    let first = i == 0
    let last = i == arr.len() - 1
    new-arr.push((first, last, val))
  }
  return new-arr
}

#let chromatics-in-major-scale(key) = {
  let key-parsed = determine-key(key) // num-chromatics and symbol-type

  let side = key-parsed.symbol-type
  let all-chromatics = if (side == "sharp") { sharp-order } else { sharp-order.rev() }

  return (side: side, chromatics: all-chromatics.slice(0, key-parsed.num-chromatics))

}

// key is a string, e.g. "C", "Cs", no octave
#let is-natural-note-in-major-scale(letter, key) = {
  let ch = chromatics-in-major-scale(key)
  for chromatic in ch.chromatics {
    if chromatic == letter {
      // this letter has a flat/sharp in the key signature
      return false
    }
  }
  return true

}


// e.g. all-letters-from("B") -> ("B", "C", "D", ... "A")
#let all-letters-from(letter) = {
  letter = upper(letter)
  assert(letter in all-letters-from-c, message: "Unknown letter " + letter)
  let start-index = all-letters-from-c.position(x => x == letter)
  let first-chunk = all-letters-from-c.slice(start-index)
  let last-chunk = all-letters-from-c.slice(0, start-index)
  return first-chunk + last-chunk
}

// takes in a key (without octave) e.g. "Bb"
// returns a list of notes, as strings, from that root note,
// up to the seventh
#let major-scale-notes(key) = {
  let ch = chromatics-in-major-scale(key)

  let notes = ()

  for letter in all-letters-from(key.at(0)) {
    if letter in ch.chromatics {
      if ch.side == "sharp" {
        notes.push(letter + "#")
      } else {
        notes.push(letter + "b")
      }
    } else {
      notes.push(letter)
    }
  }

  return notes

}


// root-note is a letter-note
// returns a key string, e.g. "Bb"
#let key-from-mode(root-note, mode-name) = {
  
  // First figure out the key, based on the mode-name
  let mode-shift = modes.at(mode-name)
  
  

  let default-side = allowed-sides.at(0)
  let side = if (root-note.accidental == none ) { default-side } else { side-from-accidental(root-note.accidental) }
  let key-note = add-semitones(root-note.letter, root-note.accidental, root-note.octave, steps: 1, side: side)
  assert(key-note.at("type") == "letter-note")
  
  // example edge case:
  // e.g. C locrian is for Db key, not C# key
  // so check that the root note is in the key of the key-note
  // if not, just flip the key-note from sharp/flat to flat/sharp
  let key-str = if (root-note.accidental == none) {
    let ks1 = serialise-note(key-note, suppress-octave: true, suppress-natural: true)
    if (not ks1 in key-data.major) or (not is-natural-note-in-major-scale(root-note.letter, ks1)) {
      key-note = flip-accidental(key-note)
    }
    let ks2 = serialise-note(key-note, suppress-octave: true, suppress-natural: true)
    assert(ks2 in key-data.major, message: "Unsure which key signature belongs to " + mode-name + " of " + serialise-note(root-note) + ". I thought " + ks2 + " but that can't be right")
    assert(is-natural-note-in-major-scale(root-note.letter, ks2))
    ks2
  } else {
    serialise-note(key-note, suppress-octave: true, suppress-natural: true)
  }
  assert(key-str in key-data.major, message: "Unsure which key signature belongs to " + mode-name + " of " + serialise-note(root-note) + ". I thought " + key-str + " but that can't be right")

  return key-str

}