#import "@preview/conchord:0.4.0": new-chordgen
#import "chords.typ": define-chord, get-chord
#import "state.typ": chordish-state

// Chord Tracking
#let used-chords = state("used-chords", (:))
#let add-chord(chord) = used-chords.update(c => c + ((chord.name): chord.frets))

// Chord Formats
#let format-name(name) = name.replace("#", sym.sharp).replace("b", sym.flat)

#let format-chord(c) = {
  if type(c) == content {
    c = c.text
  }
  if type(c) == str {
    c = get-chord(c)
  }
  add-chord(c)
  text(fill: rgb("#b32c2c"), format-name(c.name))
}

#let inline-chord(chord, fallback: false) = {
  let resolved = get-chord(chord)
  if fallback and resolved == none {
    return text("[" + chord + "]")
  }

  text(fill: luma(50%))[\[]
  format-chord(resolved)
  text(fill: luma(50%))[\]]
}
#let over-chord(chord, fallback: false) = {
  let resolved = get-chord(chord)
  if fallback and resolved == none {
    return text("[" + chord + "]")
  }

  box(place(bottom, dy: -1em, format-chord(resolved)))
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
#let instrument-strings = (
  guitar: 6,
  ukulele: 4,
  mandolin: 4,
)
#let chord-diagram(name, frets) = {
  let instrument = chordish-state.get().instrument
  let make-chord = new-chordgen(
    string-number: instrument-strings.at(instrument),
    scale-length: 0.8pt,
  )

  make-chord(frets, name: format-name(name))
}

// Chord Macros
#let chord(c) = [#c<chord>]
#let seq(cs) = [#cs<chord-sequence>]

#let validate-settings(settings) = {
  if "chords" in settings {
    assert(
      settings.chords in ("inline", "above"),
      message: "chords must be \"inline\" or \"above\"",
    )
  }
  if "instrument" in settings {
    assert(
      settings.instrument in ("guitar", "ukulele", "mandolin"),
      message: "instrument must be \"guitar\", \"ukulele\", or \"mandolin\"",
    )
  }
  if "autochord" in settings {
    assert(
      type(settings.autochord) == bool,
      message: "autochord must be a boolean",
    )
  }
  if "diagrams" in settings {
    assert(
      type(settings.diagrams) == bool,
      message: "diagrams must be a boolean",
    )
  }
  if "simplify-slash" in settings {
    assert(
      settings.simplify-slash in (none, "diagram", "all"),
      message: "simplify-slash must be none, \"diagram\", or \"all\"",
    )
  }
}

// Formatting Functions
#let song(
  title: "Untitled",
  artist: none,
  transpose: 0,
  chords: auto,
  instrument: auto,
  autochord: auto,
  diagrams: auto,
  simplify-slash: auto,
) = {
  let song-settings = (
    chords: chords,
    instrument: instrument,
    autochord: autochord,
    diagrams: diagrams,
    simplify-slash: simplify-slash,
  ).filter(v => v != auto)
  validate-settings(song-settings)

  [#pagebreak(weak: true) <song>]

  chordish-state.update(s => (
    ..s,
    transpose: transpose,
    // Use the defaults from the songbook...
    ..s.book-settings,
    // ...but override anything passed in #song
    ..song-settings,
  ))

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
  simplify-slash: none,
  body,
) = {
  let book-settings = (
    chords: chords,
    instrument: instrument,
    autochord: autochord,
    diagrams: diagrams,
    simplify-slash: simplify-slash,
  )
  validate-settings(book-settings)
  chordish-state.update(s => (..s, ..book-settings, book-settings: book-settings))

  // Style according to chord display mode
  let default-mode = chord-modes.at(chords)
  set par(spacing: default-mode.spacing, leading: default-mode.leading)
  show outline: set par(leading: 0.65em)
  show par: it => context {
    let mode = chord-modes.at(chordish-state.get().chords)
    if mode != default-mode and par.leading == default-mode.leading and par.spacing == default-mode.spacing {
      set par(spacing: mode.spacing, leading: mode.leading)
      block(above: mode.spacing, below: mode.spacing, it.body)
    } else {
      it
    }
  }

  show "[[": it => context if chordish-state.get().autochord { "[" } else { it }
  show "]]": it => context if chordish-state.get().autochord { "]" } else { it }
  let chord-regex = regex("\\[(.+?)\\]")
  show chord-regex: it => context {
    let s = chordish-state.get()
    if s.autochord {
      let mode = chord-modes.at(s.chords)
      (mode.chord.with(fallback: true))(it.text.match(chord-regex).captures.at(0))
    } else {
      it
    }
  }

  show <chord>: it => context {
    let mode = chord-modes.at(chordish-state.get().chords)
    (mode.chord)(it)
  }
  show <chord-sequence>: it => context {
    let mode = chord-modes.at(chordish-state.get().chords)
    (mode.seq)(it)
  }

  show <diagrams>: it => context if chordish-state.get().diagrams { it }

  body
}
