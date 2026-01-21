#import "@preview/conchord:0.3.0": new-chordgen
#import "chords.typ": get-chord, define-chord, transpose-state

// Chord Tracking
#let used-chords = state("used-chords", (:))
#let add-chord(chord) = used-chords.update(c => c + ((chord.name): chord.frets))

// Chord Formats
#let format-chord(c) = {
  if type(c) == content {
    c = c.text
  }
  add-chord(c)
  c = c.name.replace("#", sym.sharp).replace("b", sym.flat)
  text(fill: rgb("#b32c2c"), c)
}

#let inline-chord(chord, fallback: false) = context {
  let chord = get-chord(chord)
  if fallback and chord == none {
    return text("[" + chord + "]")
  }

  text(fill: luma(50%))[\[]
  format-chord(chord)
  text(fill: luma(50%))[\]]
}
#let over-chord(chord, fallback: false) = context {
  let chord = get-chord(chord)
  if fallback and chord == none {
    return text("[" + chord + "]")
  }

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

// Chord Diagrams
#let instrument-state = state("instrument", "guitar")
#let chord-diagram(name, frets) = context {
  let instrument = instrument-state.get()
  let make-chord = new-chordgen(
    string-number: if instrument == "guitar" { 6 } else { 4 },
    scale-length: 0.8pt,
  )

  make-chord(frets, name: name)
}

// Chord Macros
#let chord(c) = [#c<chord>]
#let seq(cs) = [#cs<chord-sequence>]

// Formatting Functions
#let song(title: "Untitled", artist: none, transpose: 0) = {
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
  let diagrams = context {
    let next-song = {
      query(selector(<song>).after(here())).at(0, default: none)
    }
    let chords = if next-song == none {
      used-chords.final()
    } else {
      used-chords.at(next-song.location())
    }
    chords.pairs().map(((name, frets)) => box(chord-diagram(name, frets))).join(h(1em))
  }
  [#diagrams <diagrams>]
  v(24pt, weak: true)

  used-chords.update((:))
  transpose-state.update(transpose)
}
#let section(section, indent: auto, ..args) = {
  let body = args.pos().at(0, default: none)
  let output = {
    strong(section)
    linebreak()
    body
  }
  if indent == true or (indent == auto and body != none) {
    output = box(inset: (left: 2em), output)
  }
  output
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
  chords: "inline",
  instrument: "guitar",
  autochord: true,
  diagrams: true,
  body,
) = {
  // Style according to chord display mode
  let mode = chord-modes.at(chords)
  set par(spacing: mode.spacing, leading: mode.leading)
  show outline: set par(leading: 0.65em)

  instrument-state.update(instrument)

  show "[[": if autochord { "[" } else { "[[" }
  show "]]": if autochord { "]" } else { "]]" }
  let chord-regex = regex("\\[(.+?)\\]")
  show chord-regex: it => if autochord {
    (mode.chord.with(fallback: true))(it.text.match(chord-regex).captures.at(0))
  } else {
    it
  }

  show <chord>: mode.chord
  show <chord-sequence>: mode.seq

  show <diagrams>: it => if diagrams { it }

  body
}
