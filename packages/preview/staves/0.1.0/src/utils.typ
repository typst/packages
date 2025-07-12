#import "data.typ": *

#let is-integer(char) = {
 let digits = ("0", "1", "2", "3", "4", "5", "6", "7", "8", "9")
 char in digits
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
   let symbol-type = if this-key-index >= mid-index { "sharp" } else { "flat" }
   
   (
     num-chromatics: num-chromatics,
     symbol-type: symbol-type
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
#let serialise-note(note, suppress-natural: false) = {
  let a = if note.accidental == none {
    ""
  } else if suppress-natural and note.accidental == "n" {
    ""
  } else {
    note.accidental
  }
  return note.letter + a + str(note.octave)
}

// concats letter and accidental
// handling case where accidental: none
// and optionally converting "n" -> ""
#let accidental-string(letter, accidental, suppress-natural: false) = {
  if (accidental == "n") and suppress-natural {
    return accidental-string(letter, none)
  } else if accidental == none {
    return letter
  } else if accidental == "s" {
    // change from "s" to "#"
    return accidental-string(letter, "#")
  } else {
    assert(accidental in symbol-map.keys(), message: "Unable to parse note: " + letter + ", unknown accidental " + accidental)
    return letter + accidental
  }
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
#let letter-to-index(note, side) = {
  if note.at("type") == "index-note" {
    // already the type we want
    return note
  }
  assert(note.at("type") == "letter-note", message: "Unknown data type when converting to index-note")

  let octaves-above-middle-c = note.octave - middle-c-octave

  let a-s = accidental-string(note.letter, note.accidental, suppress-natural: true)

  assert(side in all-notes-from-c, message: "unknown side: " + side)
  assert(a-s in all-notes-from-c.at(side), message: "unable to calculate index of " + a-s + " above C")
  
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
  assert(note.type == "letter-note")
  assert(note.accidental == none)

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
  assert(side in allowed-sides, message: "invalid side: " + side + ", must be one of " + allowed-sides.join(","))
  if steps == 0 {
    return (
      letter: start-letter,
      accidental: start-accidental,
      octave: start-octave
    )
  } else if steps >= semitones-per-octave {
    // skip a whole octave at a time
    // for performance reasons
    return add-semitones(start-letter, start-accidental, start-octave + 1, steps: steps - semitones-per-octave, side: side)
  } else if steps < 0 {
    panic("Decrementing by semitone not supported")
  } else if start-letter == "B" {
    // increment octave number when going from B to C
    return add-semitones("C", none, start-octave + 1, steps: steps - 1, side: side)
  } else if start-accidental == "b" {
    // remove the flat
    assert(side == "flat", message: "Cannot start with flat for sharp incrementing")
    return add-semitones(start-letter, none, start-octave, steps: steps - 1, side: side)
    
  } else if start-accidental in ("n", "", none) {
    if start-letter in ("B", "E") {
        // this note has no sharp, go to next white note
        return add-semitones(increment-letter(start-letter), none, start-octave, steps: steps - 1, side: side)
    } else if side == "sharp" {
      // sharpen this note
      return add-semitones(start-letter, "#", start-octave, steps: steps - 1, side: side)
    } else { // flats
      assert(side == "flat", message: "unknown side: " + side)
      // flatten the next note
      return add-semitones(increment-letter(start-letter), "b", start-octave, steps: steps - 1, side: side)
    }
  } else {
    assert(start-accidental in ("s", "#"), message: "Unknown accidental: " + start-accidental)
    assert(side == "sharp", message: "Cannot mix sharp notes and not sharp side")

    return add-semitones(increment-letter(start-letter), none, start-octave, steps: steps - 1, side: side)
  }
}
