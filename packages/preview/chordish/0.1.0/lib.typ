#import "@preview/conchord:0.2.0": new-chordgen
#import "chords.typ": chords

// Chord Tracking
#let used-chords = state("used-chords", (:))
#let add-chord(chord) = used-chords.update(c => c + ((chord): true))

// Chord Formats
#let format-chord(c) = {
  add-chord(if type(c) == str { c } else { c.text })
  text(fill: rgb("#b32c2c"), c)
}

#let inline-chord(chord) = {
  text(fill: luma(50%))[\[]
  format-chord(chord)
  text(fill: luma(50%))[\]]
}
#let over-chord(chord) = {
  box(place(bottom, dy: -1em, format-chord(chord)))
}

#let inline-seq(chords) = {
  v(1em, weak: true)
  for chord in chords.text.split() {
    inline-chord(chord)
  }
}
#let over-seq(chords) = {
  v(1em, weak: true)
  for chord in chords.text.split() {
    format-chord(chord)
    h(1em)
  }
}

// Custom Chords
#let custom-chords = state("custom-chords", (:))
#let define-chord(name, frets) = custom-chords.update(c => c + ((name): frets))

// Chord Diagrams
#let instrument-state = state("instrument", "guitar")
#let chord-diagram(chord) = context {
  let instrument = instrument-state.get()
  let make-chord = new-chordgen(
    string-number: if instrument == "guitar" { 6 } else { 4 }
  )

  let frets = custom-chords.final().at(chord, default: none)
  if frets == none {
    let inst-chords = chords.at(instrument)
    frets = inst-chords.at(chord, default: none)
  }
  if frets == none {
    panic("Unknown chord " + chord)
  }
  make-chord(frets, name: chord)
}

// Chord Macros
#let seq(cs) = [#cs<chord-sequence>]

// Formatting Functions
#let song(title: "Untitled", artist: none) = {
  [#pagebreak(weak: true) <song>]

  // Song Info
  heading(title)
  if artist != none {
    v(8pt, weak: true)
    heading(artist, level: 2)
  }
  line(length: 100%, stroke: 0.5pt + luma(50%))

  v(12pt, weak: true)

  // Chord Diagrams
  context {
    let next-song = {
      query(selector(<song>).after(here()))
        .at(0, default: none)
    }
    let chords = if next-song == none {
      used-chords.final()
    } else {
      used-chords.at(next-song.location())
    }
    chords.keys()
      .map(chord => box(chord-diagram(chord)))
      .intersperse(h(1em))
      .join()
  }
  v(24pt, weak: true)

  used-chords.update((:))
}
#let section(section) = {
  strong(section)
  linebreak()
}

// Main Template
#let chord-modes = (
  inline: (
    chord: inline-chord,
    seq: inline-seq,
    leading: 1em,
    spacing: 2em,
  ),
  above: (
    chord: over-chord,
    seq: over-seq,
    leading: 2em,
    spacing: 4em,
  ),
)
#let songbook(
  title: "Untitled Song",
  artist: none,
  chords: "inline",
  instrument: "guitar",
  body
) = {
  // Style according to chord display mode
  let mode = chord-modes.at(chords)
  set par(spacing: mode.spacing, leading: mode.leading)
  show outline: set par(leading: 0.65em)

  instrument-state.update(instrument)

  let chord-regex = regex("\\[(.+?)\\]")
  show chord-regex: it => (mode.chord)(
    it.text.match(chord-regex).captures.at(0)
  )
  show <chord-sequence>: mode.seq

  body
}
