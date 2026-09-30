// Chord names printed above the system.
//
// Names are set from plain text such as `Cmaj7`, `F#m7b5` or `Bb5`. Accidentals
// become proper symbols and extension figures are raised, which is how they are
// set in published sheets and what keeps `b` for flat from being confused with
// the letter B.

#import "../layout/lanes.typ": empty-lane, lane

#let _LETTERS = ("A", "B", "C", "D", "E", "F", "G")
#let _DIGITS = ("0", "1", "2", "3", "4", "5", "6", "7", "8", "9")

/// Format a chord name as content.
///
/// The first character is the root; an accidental may follow it directly. After
/// that, runs of digits are raised and everything else is set as written.
#let format(name) = {
  let chars = name.clusters()
  if chars.len() == 0 { return [] }

  let out = []
  let i = 0

  // Root, plus an accidental bound to it.
  if chars.at(0) in _LETTERS {
    out += chars.at(0)
    i = 1
    if i < chars.len() and chars.at(i) in ("#", "♯") {
      out += sym.sharp
      i += 1
    } else if i < chars.len() and chars.at(i) in ("b", "♭") {
      out += sym.flat
      i += 1
    }
  }

  // The quality. Digit runs are raised; a later `b` or `#` is an alteration of
  // the figure that follows it, so it is raised with the figure.
  while i < chars.len() {
    let c = chars.at(i)
    if c in _DIGITS or (c in ("b", "#") and i + 1 < chars.len() and chars.at(i + 1) in _DIGITS) {
      let start = i
      while i < chars.len() and (chars.at(i) in _DIGITS or chars.at(i) in ("b", "#")) { i += 1 }
      let figure = chars
        .slice(start, i)
        .map(ch => if ch == "b" { sym.flat } else if ch == "#" { sym.sharp } else { ch })
        .join()
      out += super(figure)
    } else if c == "/" {
      // A slash chord: the bass note keeps its own accidental.
      out += "/"
      i += 1
    } else {
      out += c
      i += 1
    }
  }

  out
}

/// Whether the system has any chord names to show.
#let _has-chords(system) = system.measures.any(m => m.events.any(pe => pe.event.chord != none))

#let height(theme) = theme.chord-size * 1.35

/// Draw the chord name row.
#let draw(theme, system, width) = box(width: width, height: height(theme), {
  for m in system.measures {
    for pe in m.events {
      if pe.event.chord == none { continue }
      place(
        top + left,
        dx: pe.x - 0.2 * theme.staff-space,
        dy: 0pt,
        text(
          font: theme.font,
          size: theme.chord-size,
          weight: 600,
          fill: theme.color,
          top-edge: "cap-height",
          bottom-edge: "baseline",
          format(pe.event.chord),
        ),
      )
    }
  }
})

/// The chord name lane, collapsing when the music names no chords.
#let lane-for(theme, system, width) = {
  if not _has-chords(system) { return empty-lane }
  lane(height(theme), () => draw(theme, system, width))
}
