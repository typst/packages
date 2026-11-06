#import "@preview/staves:0.1.0": *

#let line-sep = 0.2cm
#let major-scale = major-scale.with(line-sep: line-sep)
#let minor-scale = minor-scale.with(line-sep: line-sep)
#let arpeggio = arpeggio.with(line-sep: line-sep)
#let chromatic-scale = chromatic-scale.with(line-sep: line-sep)


#let capitalise-first-char(s) = {
  return upper(s.at(0)) + s.slice(1)
}

= Flute Scales

== Major Scales


#for k in key-data.at("major") {
  [#k Major]
  major-scale("treble", k, 4, note-duration: "crotchet", notes-per-stave: 2 * num-letters-per-octave + 1, num-octaves: 2)
}

== Harmonic Minor Scales

#for k in key-data.at("minor") {
  [=== #capitalise-first-char(k) Harmonic Minor]
  minor-scale("treble", k, 4, minor-type: "harmonic", equal-note-head-space: true, note-duration: "crotchet", notes-per-stave: 2 * num-letters-per-octave + 1, num-octaves: 2)
}


== Major Arpeggios

#for k in key-data.at("major") {
  [#k Major Arpeggio]
  arpeggio("treble", k, 4, num-octaves: 2, note-duration: "crotchet")
}

== Harmonic Arpeggios

#for k in key-data.at("minor") {
  [=== #capitalise-first-char(k) Minor Arpeggio]
  arpeggio("treble", k, 4, num-octaves: 2, note-duration: "crotchet")
}


== Chromatic Scales

#for side in allowed-sides {
  [=== Chromatic Scales (#side)]
  for k in all-notes-from-c.at(side) {
    [
      #k Chromatic
    ]
    chromatic-scale("treble", k, 4, num-octaves: 1, side: side, note-duration: "crotchet")
  }
}

== Modes (by index)


#for k in key-data.at("major") {
  [=== Modes with the key of #k Major]
  for mode-index in range(1, num-letters-per-octave + 1) {
    let mode-name = capitalise-first-char(mode-names.at(mode-index - 1))
    [Mode #mode-index (#mode-name) of the key matching  #k Major]
    mode-by-index("treble", k, 4, mode-index, note-duration: "crotchet", notes-per-stave: 2 * num-letters-per-octave + 1, num-octaves: 2)
  }
}