#import "@preview/cetz:0.3.4"

#import "data.typ": *
#import "utils.typ": *


#let stave(clef, key, notes: (), geometric-scale: 1, note-duration: "semibreve", note-sep: 1, equal-note-head-space: false) = {

  // validate arguments
  assert(clef in clef-data.keys(), 
        message: "Invalid clef argument. Must be " + clef-data.keys().map(str).join(", "))

  assert(note-duration in note-duration-data.keys(),
         message: "Invalid note-duration argument. Must be " + note-duration-data.keys().map(str).join(", "))
        
  let result = determine-key(key)
  let num-chromatics = result.num-chromatics
  let symbol-type = result.symbol-type

  
  cetz.canvas(length: geometric-scale * 0.3cm, {
    import cetz.draw: line, content, rect

    let leger-line-width = 1.8
    let accidental-offset = leger-line-width / 2 + 0.35 // accidentals are this far left of notes
    let stem-length = 3 + 0.2 // don't make it an integer, it looks bad

    
    // note that x = x + 1
    // does not work in typst
    // so we do xs = (1, 2, 1)
    // and sum that array each time
    let clef-center-x = 2
    let xs = (clef-center-x, )
    

    let y = clef-data.at(clef).at("clef").at("y-offset")
  
    // clef
    content((xs.sum(), y ), [
      #image(clef-data.at(clef).at("clef").at("image"), height: (clef-data.at(clef).at("clef").at("y-span") ) * geometric-scale * 1cm)
    ], anchor: "center")

    xs.push(3)
    
    // key signature
    for i in range(num-chromatics) {
      assert(symbol-type != "natural", message: "natural in key signature? " + key + " " + str(num-chromatics) + " " + symbol-type)
      let y = clef-data.at(clef).at("accidentals").at(symbol-type).at(i)
      
      content((xs.sum() , (y + symbol-data.at(symbol-type).at("y-offset")) ), [
        #image(symbol-data.at(symbol-type).at("image"), 
               height: (symbol-data.at(symbol-type).at("y-span") ) * geometric-scale * 1cm)
      ])
      xs.push(1)
    }

    // if there were any sharps or flats (non-empty key signature),
    // then add some extra space
    if num-chromatics > 0 {
      xs.push(1)
    }

    // draw our notes
    for (i, note-str) in notes.enumerate() {
      
      let note = parse-note-string(note-str)
      let note-height = calc-note-height(clef, note)


      let image-path = note-duration-data.at(note-duration).at("image")


      // extra space if this is the first note and it has an accidental
      if (note.accidental != none) and (i == 0) {
        xs.push(1)
      }


      let y = note-height + note-duration-data.at(note-duration).at("y-offset")
      
      // accidentals
      if note.accidental != none {
        let symbol-name = symbol-map.at(note.accidental)
        assert(symbol-name in symbol-data, message: "unknown symbol " + note.accidental + " with name " + symbol-name)
        let accidental = symbol-data.at(symbol-name)

        if equal-note-head-space {
          xs.push(- accidental-offset)
        }
        let x = xs.sum()

        content(((x) , (y + accidental.y-offset) ), [
            #image(accidental.image, 
                   height: (accidental.y-span ) * geometric-scale * 1cm)
        ])
        xs.push(accidental-offset)
        
      }

      let x = xs.sum()
      let y-span = note-duration-data.at(note-duration).at("y-span")


      // leger lines
      let left-x = x - leger-line-width / 2
      let right-x = left-x + leger-line-width
      if note-height <= -1 {
        // leger lines below
        let leger-start = calc.trunc(note-height)
        let leger-end = -1
        for h in range(leger-start, leger-end + 1) {
          line((left-x , h ), (right-x , h ))
        }
      } else if note-height >= 5 {
        // leger lines above
        let leger-start = 5
        let leger-end = calc.trunc(note-height)
        for h in range(leger-start, leger-end + 1) {
          line((left-x , h ), (right-x , h ))
        }
      }

      // note head
      content((x , y ), [
        #image(image-path, 
               height: (y-span ) * geometric-scale * 1cm)
      ])

      // stem
      if note-duration-data.at(note-duration).at("stem") {
        let head-width = note-duration-data.at(note-duration).at("width")
        if y < 2 {
          // stem up on right
          line(
            (
              (x + head-width * 0.5) , 
              y 
            ), 
            (
              (x + head-width * 0.5)  , 
              (y + stem-length) 
            )
          )
        } else {
          // stem down on left
          line(
            (
              (x - head-width * 0.5) , 
              y 
            ), 
            (
              (x - head-width * 0.5)  , 
              (y - stem-length) 
            )
          )
        }
        
      }


      if (i <= notes.len() - 2) {
        xs.push(note-sep * 3) // space between notes
      }

    }

    xs.push(2)

    
    
    if notes.len() > 0 {
      // double bar at end
      let double-bar-sep = 0.5
      let double-bar-thick = 0.15
      let x = xs.sum()
      line((x, 0), (x, 4 ))
      xs.push(double-bar-sep + double-bar-thick)
      let x = xs.sum()
      rect((x, 0), (x - double-bar-thick, 4 ), fill: black)
    }

    // draw the 5 stave lines
    // left until last because only now do we know the total width
    let x = xs.sum()
    for i in range(5) {
      line((0, i ), (x, i ))
    }
    
  })
}


#let arpeggio(clef, key, start-octave, num-octaves: 1, ..kwargs) = {
  // remove flat/sharp from key, increment letters and octaves
  // assume the key signature will handle flats/sharps for us
  let notes = ()
  let start-note = remove-accidental(parse-note-string(key + str(start-octave)))

  // ascent
  for ov in range(num-octaves) {
    // root
    notes.push(shift-octave(start-note, ov))

    // third
    notes.push(increment-wholenote(notes.at(-1), steps: 2))
    
    
    // fifth
    notes.push(increment-wholenote(notes.at(-1), steps: 2))
    
  }

  // peak
  let peak = shift-octave(start-note, num-octaves)

  let notes = notes + (peak, ) + notes.rev()
  
  stave(clef, key, notes: notes, ..kwargs)
}

#let major-scale(clef, key, start-octave, num-octaves: 1, ..kwargs) = {
  // remove flat/sharp from key, increment letters and octaves
  // assume the key signature will handle flats/sharps for us
  
  assert(key.at(0) == upper(key.at(0)), message: "key must be uppercase for major-scale")
  let start-note = remove-accidental(parse-note-string(key + str(start-octave)))
  let notes = (start-note, )

  // ascent
  for i in range(num-octaves * num-letters-per-octave) {
    notes.push(increment-wholenote(notes.at(-1)))
  }

  let peak = notes.pop()

  let notes = notes + (peak, ) + notes.rev()
  
  stave(clef, key, notes: notes, ..kwargs)
}


#let minor-types = ("natural", "harmonic")
#let seventh-types = ("n", "x")
// harmonic minor by default
// let the key signature handle sharps/flats
// just increment letters
// then handle the 7th based on the root note, not the key
#let minor-scale(clef, key, start-octave, num-octaves: 1, minor-type: "harmonic", seventh: "n", ..kwargs) = {
  // remove flat/sharp from key, increment letters and octaves
  // assume the key signature will handle flats/sharps for us
  
  assert(minor-type in minor-types, message: "minor-type must be one of " + minor-types.join(", "))
  assert(seventh in seventh-types, message: "seventh argument must be one of " + seventh-types.join(", "))

  if key.at(0) == upper(key.at(0)) {
    // set first character to uppercase
    let new-key = lower(key.at(0)) + key.slice(1)
    return minor-scale(clef, new-key, start-octave, num-octaves: 1, minor-type: minor-type, seventh: seventh, ..kwargs)
  }

  let start-note-raw = parse-note-string(key + str(start-octave))
  let key-accidental = start-note-raw.accidental
  let start-note = remove-accidental(start-note-raw)
  let notes = ()

  // ascent
  for ov in range(num-octaves) {
    // root
    let root-note = shift-octave(start-note, ov)
    notes.push(root-note)
    for i in range(1, num-letters-per-octave) {
      let n = increment-wholenote(notes.at(-1))
      if (minor-type == "harmonic") and (calc.rem-euclid(i, num-letters-per-octave) == num-letters-per-octave - 1) {
        // handle the 7th specially, to flatten it
        if key-accidental in (none, "n") {
          if upper(key.at(0)) in ("C", "F") {
            // undo a flat for these special cases
            notes.push(set-accidental(n, "n"))
          } else {
            // 7th note will be a sharp
            notes.push(set-accidental(n, "#"))
          }
        } else if key-accidental == "b" {
          // 7th note will be a natural accidental, with a flat in the key signature
          // add it with an explicit natural
          notes.push(set-accidental(n, "n"))
        } else {
          assert(key-accidental in ("s", "#"))
          if seventh == "n" {
            // 7th note will be a double-sharp
            // use the root note with an explicit natural
            notes.push(set-accidental(shift-octave(root-note, 1), "n"))
            start-note = set-accidental(start-note, "#")
          } else {
            assert(seventh == "x")
            notes.push(set-accidental(n, "x"))
          }
          
        }
        assert(minor-type == "harmonic", message: "minor-type: " + minor-type) 
      } else {
        notes.push(n)
      }
    }
  }

  let peak = shift-octave(start-note, num-octaves)

  let notes = notes + (peak, ) + notes.rev()

  if notes.at(0) != start-note {

    // if we have a double-sharp 7th, then accidental for the root
    // add an accidental for the last note 
    // (root, with no prior accidental in that octave)
    notes.push(set-accidental(notes.pop(), "#"))
  }
  
  stave(clef, key, notes: notes, ..kwargs)
}

#let chromatic-scale(clef, start-note, num-octaves: 1, side: "sharp", ..kwargs) = {
  assert(side in allowed-sides, message: "side argument must be in : " + allowed-sides.join(", "))
  let start-note-parsed = parse-note-string(start-note)
  let notes = ()

  // ascent
  for i in range(12 * num-octaves + 1) {
    let note = add-semitones(start-note-parsed.letter, start-note-parsed.accidental, start-note-parsed.octave, steps: i, side: side)
    let a = if note.accidental == none {
      ""
    } else {
      note.accidental
    }
    notes.push(
      note.letter + a + str(note.octave)
    )
  }

  // descent
  for i in range(12 * num-octaves - 1 , 0 - 1, step: -1) {
    let note = add-semitones(start-note-parsed.letter, start-note-parsed.accidental, start-note-parsed.octave, steps: i, side: side)
    let a = if note.accidental == none {
      ""
    } else {
      note.accidental
    }
    notes.push(
      note.letter + a + str(note.octave)
    )
  }
  
  stave(clef, "C", notes: notes, ..kwargs)
}
