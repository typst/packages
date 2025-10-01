#import "@preview/cetz:0.4.2"

#import "data.typ": *
#import "utils.typ": *

#let stave(clef, key, notes: (), notes-per-stave: none, width: auto, line-sep: 0.3cm, note-duration: "semibreve", equal-note-head-space: false) = {

  // validate arguments
  assert(clef in clef-data.keys(), 
        message: "Invalid clef argument. Must be " + clef-data.keys().map(str).join(", "))

  assert(note-duration in note-duration-data.keys(),
         message: "Invalid note-duration argument. Must be " + note-duration-data.keys().map(str).join(", "))
        
  let result = determine-key(key)
  let num-chromatics = result.num-chromatics
  let symbol-type = result.symbol-type

  let notes-per-stave = if (notes-per-stave == none) { calc.max(notes.len(), 1) } else { notes-per-stave }

  assert(notes-per-stave > 0, message: "notes-per-stave (chunk length) must be postitive. Is " + str(notes-per-stave))

  // prevent page breaks between multiple staves
  block(breakable: false, [
    #let note-chunks = if (notes.len() > 0) { notes.chunks(notes-per-stave) } else { ((), ) }
    #for (is-first-stave, is-last-stave, notes-this-stave) in first-last(note-chunks) {
      
      // wrap inside a layout so we can measure the page width
      layout(layout-size => {
        cetz.canvas(length: line-sep, {
          import cetz.draw: line, content, rect

          let leger-line-width = 1.8
          let accidental-offset = leger-line-width / 2 + 0.35 // accidentals are this far left of notes
          let stem-length = 3 + 0.2 // don't make it an integer, it looks bad
          let double-bar-sep = 0.5
          let double-bar-thick = 0.15
          let end-space = leger-line-width // space between last note and barline
          let key-note-space = 1 // space between key signature and first note (or accidental of first note)
          
          // note that x = x + 1
          // does not work in typst
          // so we do xs = (1, 2, 1)
          // and sum that array each time
          let clef-center-x = 2
          let xs = (clef-center-x, )
          
          let y = clef-data.at(clef).at("clef").at("y-offset")

        
          // clef
          content((xs.sum(), y ), [
            #image(clef-data.at(clef).at("clef").at("image"), height: (clef-data.at(clef).at("clef").at("y-span") ) * line-sep)
          ], anchor: "center")

          xs.push(3)
          
          // key signature
          for i in range(num-chromatics) {
            assert(symbol-type != "natural", message: "natural in key signature? " + key + " " + str(num-chromatics) + " " + symbol-type)
            let y = clef-data.at(clef).at("accidentals").at(symbol-type).at(i)
            
            content((xs.sum() , (y + symbol-data.at(symbol-type).at("y-offset")) ), [
              #image(symbol-data.at(symbol-type).at("image"), 
                    height: (symbol-data.at(symbol-type).at("y-span") ) * line-sep)
            ])
            xs.push(1)
          }


          xs.push(key-note-space)


          // calculate the separation between notes
          // based on the overall width

          // note that we have scaled the canvas to make each y unit equal to line-sep
          // so overall stave line length should be width / line-sep
          // They subtract clef, key sig (our current x position)
          // also subtract the width of the double bar at the end

          // how much space is taken up by stuff other than first note head to last note head
          let non-notes-width = (0,) 
          non-notes-width.push(xs.sum()) // clef, key sig
          non-notes-width.push(key-note-space) // space between key sig and first note
          if (notes-this-stave.len() > 0) and (parse-note-string(notes-this-stave.at(0)).accidental != none) {
            // extra space for first note if it has an accidental
            non-notes-width.push(accidental-offset)
          }
          if not equal-note-head-space {
            // subtract space for each accidental
            for (i, note-str) in notes-this-stave.enumerate() {
              let note = parse-note-string(note-str)
              if note.accidental != none {
                non-notes-width.push(accidental-offset)
              }
            }
          }
          non-notes-width.push(end-space) // space between last note and bar line
          if is-last-stave { // double bar
            non-notes-width.push(double-bar-sep + double-bar-thick)
          }

          // if width is passed, use that for the overall width
          // if width is note passed, try to get the available page width
          // if that's not available, use a sensible default. Don't bother calculating overall width. Just default for note-sep
          let default-note-sep = if equal-note-head-space { 3 } else { 2 }
          let note-sep = if (width == auto) and float.is-infinite(layout-size.width.cm()) {
            // no width argument passed, and page width is auto
            default-note-sep
          } else {
            let overall-width = if (width == auto) {
              // no width argument passed, guess from page width
              layout-size.width
            } else {
              // explicit width argument passed
              width
            }
            
            let notes-width = overall-width.cm() - non-notes-width.sum() * line-sep.cm()

            notes-width / calc.max(notes-this-stave.len() - 1, 1) / line-sep.cm()
          }

          // draw our notes
          for (i, (is-first-note, is-last-note, note-str)) in first-last(notes-this-stave).enumerate() {
            
            let note = parse-note-string(note-str)
            let note-height = calc-note-height(clef, note)


            let image-path = note-duration-data.at(note-duration).at("image")


            // extra space if this is the first note and it has an accidental
            if (note.accidental != none) and is-first-note {
              xs.push(accidental-offset)
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
                        height: (accidental.y-span ) * line-sep)
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
                    height: (y-span ) * line-sep)
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


            if (not is-last-note) {
              xs.push(note-sep) // space between notes
            }

          }

          // space after last note, before bar line
          xs.push(end-space)
          
          if is-last-stave {
            // double bar at end
            let x = xs.sum()
            line((x, 0), (x, 4 ))
            xs.push(double-bar-sep + double-bar-thick)
            let x = xs.sum()
            rect((x, 0), (x - double-bar-thick, 4 ), fill: black)
          } else {
            // single bar at end
            let x = xs.sum()
            line((x, 0), (x, 4))
          }

          // draw the 5 stave lines
          // left until last because only now do we know the total width
          let x = xs.sum()
          for i in range(5) {
            line((0, i ), (x, i ))
          }
          
        }) // end canvas

      }) // end layout

    } // end for loop

  ]) // end block
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


// a major scale, starting on the mode-index'th note
// 1 indexed
#let mode-by-index(clef, key, start-octave, mode-index, num-octaves: 1, ..kwargs) = {
  // remove flat/sharp from key, increment letters and octaves
  // assume the key signature will handle flats/sharps for us
  
  assert(key.at(0) == upper(key.at(0)), message: "key must be uppercase for mode-by-index")
  let root-note = remove-accidental(parse-note-string(key + str(start-octave)))
  let start-note = increment-wholenote(root-note, steps: mode-index - 1)
  let notes = (start-note, )

  // ascent
  for i in range(num-octaves * num-letters-per-octave) {
    notes.push(increment-wholenote(notes.at(-1)))
  }

  let peak = notes.pop()

  let notes = notes + (peak, ) + notes.rev()
  
  stave(clef, key, notes: notes, ..kwargs)
}



#let major-scale(clef, key, start-octave, num-octaves: 1, ..kwargs) = {
  assert(key.at(0) == upper(key.at(0)), message: "key must be uppercase for major-scale")
  // a major scale is just the ionian mode
  return mode-by-index(clef, key, start-octave, 1, num-octaves: 1, ..kwargs)
}



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
  assert(start-note.accidental == none)
  let notes = ()

  // ascent
  for ov in range(num-octaves) {
    // root
    
    let root-note = shift-octave(start-note, ov)
    notes.push(root-note)
    for i in range(1, num-letters-per-octave) {
      // in the case where the 7th is a natural,
      // the root will have an explicit sharp accidental
      // that's why we remove the accidental again
      let n = increment-wholenote(remove-accidental(notes.at(-1)))
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
            notes.push(set-accidental(shift-octave(root-note, 1), "n", overwrite-existing: true))
            start-note = set-accidental(start-note, "#", overwrite-existing: true)
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

#let chromatic-scale(clef, key, start-octave, num-octaves: 1, side: "sharp", ..kwargs) = {
  assert(side in allowed-sides, message: "side argument must be in : " + allowed-sides.join(", "))
  let start-note = parse-note-string(key + str(start-octave))
  let notes = ()

  // ascent
  for i in range(12 * num-octaves + 1) {
    let note = add-semitones(start-note.letter, start-note.accidental, start-note.octave, steps: i, side: side)
    let a = if note.accidental == none {
      if (side == "flat") and (note.letter not in ("C", "F")) {
        "n" // undo the flat
      } else {
        ""
      }
    } else {
      note.accidental
    }
    notes.push(
      note.letter + a + str(note.octave)
    )
  }

  // descent
  for i in range(12 * num-octaves - 1 , 0 - 1, step: -1) {
    let note = add-semitones(start-note.letter, start-note.accidental, start-note.octave, steps: i, side: side)
    let a = if note.accidental == none {
      if (side == "sharp") and (note.letter not in ("B", "E")) {
        "n" // undo the sharp
      } else {
        ""
      }
    } else {
      note.accidental
    }
    notes.push(
      note.letter + a + str(note.octave)
    )
  }
  
  stave(clef, "C", notes: notes, ..kwargs)
}
