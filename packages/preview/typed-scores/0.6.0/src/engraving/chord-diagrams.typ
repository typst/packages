#import "@preview/cetz:0.5.2"
#import "../foundation/diagnostics.typ": _score-error

// Fretboard chord diagrams: a vertical grid with the lowest string on the
// left, fret dots, barres, open and muted markers, and finger numbers.

// Geometry in staff spaces at scale 1.
#let _diagram-string-gap = 1.0
#let _diagram-fret-gap = 1.3
#let _diagram-line-thickness = 0.09
#let _diagram-nut-thickness = 0.38
#let _diagram-dot-radius = 0.36
#let _diagram-marker-radius = 0.27
#let _diagram-marker-gap = 0.6
#let _diagram-name-gap = 0.5
#let _diagram-text-size = 1.0
#let _diagram-name-size = 1.35
#let _diagram-finger-gap = 0.75
#let _diagram-position-gap = 0.4
#let _diagram-max-fret = 24
// Diagrams above a score's harmony symbols are drawn a little smaller than
// standalone ones so they sit comfortably over the staff.
#let _score-diagram-scale = 0.8
#let _diagram-min-strings = 3
#let _diagram-max-strings = 12

// ---------------------------------------------------------------------------
// Shape normalization
// ---------------------------------------------------------------------------

// Splits "x32010" into one token per string, or "x 10 12 12 11 10" and
// "x,10,12,..." at their separators so frets above 9 can be written.
#let _diagram-tokens(value) = {
  if type(value) == array { return value }
  let trimmed = value.trim()
  if trimmed.contains(" ") or trimmed.contains(",") {
    trimmed.split(regex("[\\s,]+")).filter(token => token != "")
  } else {
    trimmed.clusters()
  }
}

#let _diagram-fret(token, label) = {
  if token == none or (type(token) == str and lower(token) == "x") { return none }
  let fret = if type(token) == int { token }
    else if type(token) == str and token.match(regex("^[0-9]+$")) != none { int(token) }
    else { -1 }
  if fret < 0 or fret > _diagram-max-fret {
    _score-error(
      label,
      "chord diagram fret must be x or a fret from 0 to " + str(_diagram-max-fret),
      value: token,
      expected: "one entry per string from the lowest string, such as \"x32010\" or (\"x\", 10, 12, 12, 11, 10)",
      fix: "write x for a muted string, 0 for an open string, or the fret number",
    )
  }
  fret
}

#let _diagram-finger(token, fret, string-number, label) = {
  if token == none or (type(token) == str and token in ("0", "x", "X", "-")) or token == 0 {
    return none
  }
  let finger = if type(token) == int { str(token) } else if type(token) == str { token } else { none }
  if finger == none or finger.trim() == "" or finger.clusters().len() > 2 {
    _score-error(
      label,
      "finger must be a short label such as 1, 2, 3, 4, or T",
      value: token,
      fix: "write 0, x, or - for strings played without a finger",
    )
  }
  if fret == none or fret == 0 {
    _score-error(
      label,
      "finger " + finger + " is on string " + str(string-number) + ", which is not fretted",
      value: token,
      expected: "0, x, or - for open and muted strings",
      fix: "move the finger to a fretted string or replace it with 0",
    )
  }
  finger
}

// Strings are indexed left to right, lowest string first. A barre covers
// every string from the first to the last one stopped at its fret, and
// none of the strings between may ring open.
#let _barre-span(frets, fret, label) = {
  let stopped = range(frets.len()).filter(index => frets.at(index) == fret)
  if stopped.len() < 2 {
    _score-error(
      label,
      "barre at fret " + str(fret) + " needs at least two strings stopped at that fret",
      value: fret,
      fix: "list the barre's fret on two or more strings, or remove barre",
    )
  }
  let (first, last) = (stopped.first(), stopped.last())
  if range(first, last + 1).any(index => frets.at(index) != none and frets.at(index) < fret) {
    _score-error(
      label,
      "barre at fret " + str(fret) + " crosses a string that rings below it",
      value: fret,
      expected: "strings under the barre fretted at or above fret " + str(fret) + ", or muted",
      fix: "shorten the shape or remove barre",
    )
  }
  (fret: fret, first: first, last: last)
}

// One finger laid across several strings at one fret is a barre, when no
// string in between rings open or below that fret.
#let _finger-barres(frets, fingers) = {
  let barres = ()
  for finger in fingers.filter(finger => finger != none).dedup() {
    let strings = range(fingers.len()).filter(index => fingers.at(index) == finger)
    if strings.len() < 2 { continue }
    let fret = frets.at(strings.first())
    if strings.any(index => frets.at(index) != fret) { continue }
    let (first, last) = (strings.first(), strings.last())
    if range(first, last + 1).all(index => frets.at(index) == none or frets.at(index) >= fret) {
      barres.push((fret: fret, first: first, last: last))
    }
  }
  barres
}

#let _normalize-chord-shape(
  frets,
  fingers: none,
  barre: auto,
  position: auto,
  fret-count: 4,
  label: "chord diagram",
) = {
  if type(frets) not in (str, array) {
    _score-error(
      label,
      "chord diagram frets must be a string or an array",
      value: frets,
      expected: "a shape such as \"x32010\", \"x 10 12 12 11 10\", or (\"x\", 3, 2, 0, 1, 0)",
      fix: "list one fret per string from the lowest string",
    )
  }
  let fret-list = _diagram-tokens(frets).map(token => _diagram-fret(token, label))
  let string-count = fret-list.len()
  if string-count < _diagram-min-strings or string-count > _diagram-max-strings {
    _score-error(
      label,
      "chord diagram has an unsupported number of strings",
      value: frets,
      expected: "from " + str(_diagram-min-strings) + " to " + str(_diagram-max-strings) + " strings",
      fix: "list one fret or x per string",
    )
  }
  if fret-list.all(fret => fret == none) {
    _score-error(
      label,
      "chord diagram mutes every string",
      value: frets,
      fix: "give at least one string an open or fretted value",
    )
  }
  if type(fret-count) != int or fret-count < 1 {
    _score-error(
      label,
      "fret-count must be a positive integer",
      value: fret-count,
      fix: "choose how many frets the grid shows at least, such as 4",
    )
  }
  let finger-list = if fingers == none { fret-list.map(_ => none) } else {
    if type(fingers) not in (str, array) {
      _score-error(
        label,
        "fingers must be a string or an array",
        value: fingers,
        expected: "one entry per string, such as \"032010\"",
        fix: "list a finger or 0 for every string",
      )
    }
    let tokens = _diagram-tokens(fingers)
    if tokens.len() != string-count {
      _score-error(
        label,
        "fingers list " + str(tokens.len()) + " strings for a " + str(string-count) + "-string shape",
        value: fingers,
        fix: "list one finger, 0, or x for every string",
      )
    }
    range(string-count).map(index => _diagram-finger(
      tokens.at(index),
      fret-list.at(index),
      string-count - index,
      label,
    ))
  }
  let barres = if barre == auto {
    _finger-barres(fret-list, finger-list)
  } else if barre == none {
    ()
  } else {
    let requested = if type(barre) == array { barre } else { (barre,) }
    if requested.len() == 0 or requested.any(fret => type(fret) != int or fret < 1) {
      _score-error(
        label,
        "barre must be auto, none, a fret number, or an array of fret numbers",
        value: barre,
        fix: "write the fret the barre stops, such as barre: 1",
      )
    }
    requested.map(fret => _barre-span(fret-list, fret, label))
  }
  let stopped = fret-list.filter(fret => fret != none and fret > 0)
  let highest = if stopped.len() == 0 { 0 } else { calc.max(..stopped) }
  let base = if position == auto {
    if highest <= fret-count { 1 } else { calc.min(..stopped) }
  } else {
    if type(position) != int or position < 1 {
      _score-error(
        label,
        "position must be auto or the fret shown at the top of the grid",
        value: position,
        fix: "choose a fret number of 1 or more",
      )
    }
    if stopped.any(fret => fret < position) {
      _score-error(
        label,
        "position " + str(position) + " starts above a fretted note",
        value: position,
        expected: "at most " + str(calc.min(..stopped)),
        fix: "lower position or remove it to place the grid automatically",
      )
    }
    position
  }
  (
    frets: fret-list,
    fingers: finger-list,
    barres: barres,
    base: base,
    rows: calc.max(fret-count, highest - base + 1),
    strings: string-count,
  )
}

// ---------------------------------------------------------------------------
// Geometry
// ---------------------------------------------------------------------------

#let _diagram-grid-width(shape, scale) = (shape.strings - 1) * _diagram-string-gap * scale
#let _diagram-has-fingers(shape) = shape.fingers.any(finger => finger != none)

// Ink above and below the grid, in staff spaces, excluding any name.
#let _chord-diagram-extent(shape, scale) = {
  let grid-height = shape.rows * _diagram-fret-gap * scale
  let above = (_diagram-marker-gap + _diagram-marker-radius) * scale
  let below = if _diagram-has-fingers(shape) {
    (_diagram-finger-gap + _diagram-text-size * 0.5) * scale
  } else {
    0
  }
  let side = calc.max(_diagram-dot-radius, _diagram-marker-radius) * scale
  // The "5fr" position label hangs off the right edge.
  let right = if shape.base > 1 {
    side + (_diagram-position-gap + 1.7 * _diagram-text-size * 0.8) * scale
  } else {
    side
  }
  (
    width: _diagram-grid-width(shape, scale) + side + right,
    height: above + grid-height + below,
    above: above,
    below: below,
    grid-height: grid-height,
    left: side,
    right: right,
  )
}

// Draws the diagram with its grid centered on x and its lowest ink on
// bottom-y. With a name, the name sits centered above the markers.
#let _draw-chord-diagram(shape, x, bottom-y, unit: 8pt, scale: 1.0, name: none, paint: black) = {
  // Named imports: cetz.draw's own `scale` would shadow the parameter.
  import cetz.draw: circle, content, line, rect
  let extent = _chord-diagram-extent(shape, scale)
  let string-gap = _diagram-string-gap * scale
  let fret-gap = _diagram-fret-gap * scale
  let left = x - _diagram-grid-width(shape, scale) / 2
  let right = left + _diagram-grid-width(shape, scale)
  let grid-bottom = bottom-y + extent.below
  let grid-top = grid-bottom + extent.grid-height
  let line-stroke = _diagram-line-thickness * scale * unit + paint
  let text-size = unit * _diagram-text-size * scale
  let string-x(index) = left + index * string-gap
  let fret-y(fret) = grid-top - (fret - shape.base + 0.5) * fret-gap

  for index in range(shape.strings) {
    line((string-x(index), grid-bottom), (string-x(index), grid-top), stroke: line-stroke)
  }
  for row in range(shape.rows + 1) {
    let y = grid-top - row * fret-gap
    line((left, y), (right, y), stroke: line-stroke)
  }
  if shape.base == 1 {
    let half-line = _diagram-line-thickness * scale / 2
    rect(
      (left - half-line, grid-top),
      (right + half-line, grid-top + _diagram-nut-thickness * scale),
      fill: paint,
      stroke: none,
    )
  } else {
    content(
      (right + (_diagram-dot-radius + _diagram-position-gap) * scale, grid-top - fret-gap / 2),
      text(size: text-size * 0.8, fill: paint, str(shape.base) + "fr"),
      anchor: "west",
      padding: 0pt,
    )
  }
  let marker-y = grid-top + _diagram-marker-gap * scale + if shape.base == 1 { _diagram-nut-thickness * scale / 2 } else { 0 }
  let marker-radius = _diagram-marker-radius * scale
  for (index, fret) in shape.frets.enumerate() {
    let sx = string-x(index)
    if fret == none {
      line((sx - marker-radius, marker-y - marker-radius), (sx + marker-radius, marker-y + marker-radius), stroke: line-stroke)
      line((sx - marker-radius, marker-y + marker-radius), (sx + marker-radius, marker-y - marker-radius), stroke: line-stroke)
    } else if fret == 0 {
      circle((sx, marker-y), radius: marker-radius, stroke: line-stroke, fill: none)
    }
  }
  let dot-radius = _diagram-dot-radius * scale
  for barre in shape.barres {
    line(
      (string-x(barre.first), fret-y(barre.fret)),
      (string-x(barre.last), fret-y(barre.fret)),
      stroke: (thickness: 2 * dot-radius * unit, paint: paint, cap: "round"),
    )
  }
  for (index, fret) in shape.frets.enumerate() {
    if fret == none or fret == 0 { continue }
    let under-barre = shape.barres.any(barre => barre.fret == fret and barre.first <= index and index <= barre.last)
    if not under-barre {
      circle((string-x(index), fret-y(fret)), radius: dot-radius, fill: paint, stroke: none)
    }
  }
  if _diagram-has-fingers(shape) {
    for (index, finger) in shape.fingers.enumerate() {
      if finger == none { continue }
      content(
        (string-x(index), grid-bottom - _diagram-finger-gap * scale),
        text(size: text-size, fill: paint, finger),
        anchor: "center",
        padding: 0pt,
      )
    }
  }
  if name != none {
    content(
      (x, grid-top + extent.above + _diagram-name-gap * scale),
      text(size: unit * _diagram-name-size * scale, weight: "bold", fill: paint, name),
      anchor: "south",
      padding: 0pt,
    )
  }
}

// ---------------------------------------------------------------------------
// Chord library
// ---------------------------------------------------------------------------

// Common voicings in standard tuning, lowest string first: open shapes
// where players use them, and E- or A-shape barres elsewhere.
#let _library-roots = (
  (names: ("C",), major: ("x32010", "032010"), minor: ("x35543", "013421"), dominant: ("x32310", "032410"), minor-seventh: ("x35343", "013121"), major-seventh: ("x32000", "032000")),
  (names: ("C#", "Db"), major: ("x46664", "013331"), minor: ("x46654", "013421"), dominant: ("x46464", "013141"), minor-seventh: ("x46454", "013121"), major-seventh: ("x46564", "013241")),
  (names: ("D",), major: ("xx0232", "000132"), minor: ("xx0231", "000231"), dominant: ("xx0212", "000213"), minor-seventh: ("xx0211", "000211"), major-seventh: ("xx0222", "000123")),
  (names: ("D#", "Eb"), major: ("x68886", "013331"), minor: ("x68876", "013421"), dominant: ("x68686", "013141"), minor-seventh: ("x68676", "013121"), major-seventh: ("x68786", "013241")),
  (names: ("E",), major: ("022100", "023100"), minor: ("022000", "023000"), dominant: ("020100", "020100"), minor-seventh: ("022030", "012030"), major-seventh: ("021100", "031200")),
  (names: ("F",), major: ("133211", "134211"), minor: ("133111", "134111"), dominant: ("131211", "131211"), minor-seventh: ("131111", "131111"), major-seventh: ("xx3210", "003210")),
  (names: ("F#", "Gb"), major: ("244322", "134211"), minor: ("244222", "134111"), dominant: ("242322", "131211"), minor-seventh: ("242222", "131111"), major-seventh: ("xx4321", "004321")),
  (names: ("G",), major: ("320003", "210003"), minor: ("355333", "134111"), dominant: ("320001", "320001"), minor-seventh: ("353333", "131111"), major-seventh: ("320002", "320001")),
  (names: ("G#", "Ab"), major: ("466544", "134211"), minor: ("466444", "134111"), dominant: ("464544", "131211"), minor-seventh: ("464444", "131111"), major-seventh: ("xx6543", "004321")),
  (names: ("A",), major: ("x02220", "001230"), minor: ("x02210", "002310"), dominant: ("x02020", "002030"), minor-seventh: ("x02010", "002010"), major-seventh: ("x02120", "002130")),
  (names: ("A#", "Bb"), major: ("x13331", "013331"), minor: ("x13321", "013421"), dominant: ("x13131", "013141"), minor-seventh: ("x13121", "013121"), major-seventh: ("x13231", "013241")),
  (names: ("B",), major: ("x24442", "013331"), minor: ("x24432", "013421"), dominant: ("x21202", "021304"), minor-seventh: ("x24232", "013121"), major-seventh: ("x24342", "013241")),
)

#let _library-qualities = (
  major: "", minor: "m", dominant: "7", minor-seventh: "m7", major-seventh: "maj7",
)

#let guitar-chords = {
  let library = (:)
  for root in _library-roots {
    for (quality, suffix) in _library-qualities {
      let (frets, fingers) = root.at(quality)
      for name in root.names {
        library.insert(name + suffix, (frets: frets, fingers: fingers))
      }
    }
  }
  library + (
    "Asus2": (frets: "x02200", fingers: "001200"),
    "Asus4": (frets: "x02230", fingers: "001230"),
    "Cadd9": (frets: "x32033", fingers: "021034"),
    "Dsus2": (frets: "xx0230", fingers: "000130"),
    "Dsus4": (frets: "xx0233", fingers: "000134"),
    "Esus4": (frets: "022200", fingers: "023400"),
  )
}

// Symbols that mean "no chord" never take a diagram.
#let _no-chord-symbols = ("N.C.", "NC", "N.C")

// A chord-diagrams entry: a shape string or array, a dictionary with frets
// and optional fingers, barre, position, and fret-count, or none to leave a
// symbol without a diagram.
#let _normalize-diagram-entry(entry, label) = {
  if entry == none { return none }
  if type(entry) == dictionary {
    for field in entry.keys() {
      if field not in ("frets", "fingers", "barre", "position", "fret-count") {
        _score-error(
          label,
          "chord diagram has unknown field",
          value: field,
          expected: "frets, fingers, barre, position, or fret-count",
          fix: "remove or rename the unknown field",
        )
      }
    }
    if "frets" not in entry {
      _score-error(
        label,
        "chord diagram dictionary is missing frets",
        value: entry,
        fix: "add frets such as frets: \"x32010\"",
      )
    }
    _normalize-chord-shape(
      entry.frets,
      fingers: entry.at("fingers", default: none),
      barre: entry.at("barre", default: auto),
      position: entry.at("position", default: auto),
      fret-count: entry.at("fret-count", default: 4),
      label: label,
    )
  } else {
    _normalize-chord-shape(entry, label: label)
  }
}

#let _validate-chord-diagrams(value) = {
  if value != none and type(value) != dictionary {
    _score-error(
      "score chord-diagrams",
      "chord-diagrams must be a dictionary or none",
      value: value,
      expected: "a dictionary from harmony symbols to shapes, such as guitar-chords",
      fix: "pass guitar-chords, add your own entries with guitar-chords + (\"Cadd9\": \"x32033\"), or remove chord-diagrams",
    )
  }
  value
}

// The diagram shown above one harmony symbol, or none.
#let _harmony-diagram(symbol, chord-diagrams, bar-number) = {
  if chord-diagrams == none or symbol in _no-chord-symbols { return none }
  let label = "chord diagram for " + repr(symbol) + " in bar " + str(bar-number)
  if symbol not in chord-diagrams {
    _score-error(
      label,
      "harmony symbol has no chord diagram",
      value: symbol,
      expected: "an entry for every harmony symbol in chord-diagrams",
      fix: "add it, for example chord-diagrams: guitar-chords + (" + repr(symbol) + ": \"x32010\"), or map it to none to omit its diagram",
    )
  }
  _normalize-diagram-entry(chord-diagrams.at(symbol), label)
}
