#import "@preview/staves:0.1.0": *

#import "@preview/suiji:0.4.0": shuffle-f, gen-rng-f, choice

#let line-sep = 0.2cm
#let major-scale = major-scale.with(line-sep: line-sep)
#let minor-scale = minor-scale.with(line-sep: line-sep)
#let arpeggio = arpeggio.with(line-sep: line-sep)
#let chromatic-scale = chromatic-scale.with(line-sep: line-sep)
#let mode-by-index = mode-by-index.with(line-sep: line-sep)


#let capitalise-first-char(s) = {
  return upper(s.at(0)) + s.slice(1)
}

= Random Flute Scales

Playing C Major, C\# Major, then D Major etc is boring.
Here we generate a random list of scales, across keys and scale types.


#let scales = (:)

// What I can play on the flute
// Bn below middle C to C 3 octaves above middle c
// so scales starting at B or C should be 3 octaves
// everything else, 2 octaves, starting from octave 4
// takes in string, e.g. "Bb"
// returns start-octave and num-octaves
#let my-range(note) = {
  if note in ("C", "Cb") {
    return (middle-c-octave, 3)
  } else if note in ("B", "Bn", "Bs", "B#") {
    return (middle-c-octave - 1, 3)
  } else {
    return (middle-c-octave, 2)
  }

}

#scales.insert("major", ())
#for k in key-data.at("major") {
  let (start-octave, num-octaves) = my-range(k)
  scales.major.push([
    == #k Major
    #major-scale("treble", k, start-octave, note-duration: "crotchet", notes-per-stave: 2 * num-letters-per-octave + 1, num-octaves: num-octaves)
  ])
}

#scales.insert("minor", ())
#for k in key-data.at("minor") {
  let (start-octave, num-octaves) = my-range(k)
  scales.minor.push([
    == #capitalise-first-char(k) Harmonic Minor
    #minor-scale("treble", k, start-octave, minor-type: "harmonic", equal-note-head-space: true, note-duration: "crotchet", notes-per-stave: 2 * num-letters-per-octave + 1, num-octaves: num-octaves)
  ])
}

#scales.insert("major-arpeggio", ())
#for k in key-data.at("major") {
  let (start-octave, num-octaves) = my-range(k)
  scales.major-arpeggio.push([
    == #k Major Arpeggio
    #arpeggio("treble", k, start-octave, num-octaves: num-octaves, note-duration: "crotchet")
  ])
}

#scales.insert("minor-arpeggio", ())
#for k in key-data.at("minor") {
  let (start-octave, num-octaves) = my-range(k)
  scales.minor-arpeggio.push([
    == #capitalise-first-char(k) Minor Arpeggio

    #arpeggio("treble", k, start-octave, num-octaves: num-octaves, note-duration: "crotchet")
  ])
}

#scales.insert("chromatic", ())
#for side in allowed-sides {
  for k in all-notes-from-c.at(side) {
    let (start-octave, num-octaves) = my-range(k)
    scales.chromatic.push([
      == #k Chromatic
      #chromatic-scale("treble", k, start-octave, num-octaves: num-octaves, side: side, note-duration: "crotchet", notes-per-stave: semitones-per-octave + 1)
    ])
  }
}


// skip mode 1, because we already have major scales
// skip mode 6, because we already have natural minor scales
#let modes-to-skip = (1, 6)

#scales.insert("modes", ())
#for k in key-data.at("major") {
  for mode-index in range(1, num-letters-per-octave + 1) {
    if not mode-index in modes-to-skip {
      let mode-name = capitalise-first-char(mode-names.at(mode-index - 1))
      scales.modes.push([
        == Mode #mode-index (#mode-name) of the key matching  #k Major
        #mode-by-index("treble", k, 4, mode-index, note-duration: "crotchet", notes-per-stave: 2 * num-letters-per-octave + 1, num-octaves: 2)
      ])
    }
    
  }
}

#let rng = gen-rng-f(1902)
#let rngs = (rng,)

#let num-scales = 30

// First randomly choose a scale type
// Then randomly choose a scale of that type
// Otherwise we mostly get chromatic scales, because there's a lot of them to choose from
#for i in range(num-scales) {
  let (rng, scale-type) = choice(rngs.at(-1), scales.keys())
  rngs.push(rng)
  // assert(false, message: "Scale type is " + json.encode(scale-type))
  let (rng, scale) = choice(rngs.at(-1), scales.at(scale-type))
  scale
  rngs.push(rng)
}
