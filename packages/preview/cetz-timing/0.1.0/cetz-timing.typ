  #import "@preview/cetz:0.3.2"

/// Width used for transition between different signal levels.
/// Value between 0.0 and 2.0
#let transition-width = 0.4 

#let sig-info = (
  "L": (
    level: -1,
    color: none,
  ),
  "H": (
    level: 1,
    color: none,
  ),
  "Z": (
    level: 0,
    color: blue,
  ),
  "X": (
    level: 0,
    color: red,
  ),
  "M": (
    level: 0,
    color: maroon,
  )
)

#let is_sig(c) = (
  return c in ("H", "L", "Z", "X", "M")
)

#let is_data(c) = (
  return c in ("D", "U")
)

#let resolve_color(c: str, color: color) = {
  let predefined = none
  if is_sig(c) {
    predefined = sig-info.at(c).color
  }
  else {
    predefined = none
  }

  if predefined == none {
    return color
  }
  else {
    return predefined
  }
}

#let from_data(pos, sig, amplitude: float) = {
  import cetz.draw: line
  let trans_startA = (x: pos.x, y: pos.y - amplitude / 2.0)
  let trans_startB = (x: pos.x, y: pos.y + amplitude / 2.0)
  let trans_end = (x: pos.x + transition-width / 2, y: pos.y)
  if sig == "U" {
    /* TODO: fill pattern */
  }
  line(trans_startA, trans_end)
  line(trans_startB, trans_end)
}

#let to_data(pos, sig, amplitude: float) = {
  import cetz.draw: line
  let trans_start = (x: pos.x + transition-width / 2.0, y: pos.y)
  let trans_endA = (x: pos.x + transition-width, y: pos.y - amplitude / 2.0)
  let trans_endB = (x: pos.x + transition-width, y: pos.y + amplitude / 2.0)
  if sig == "U" {
    /* TODO: fill pattern */
  }
  line(trans_start, trans_endA)
  line(trans_start, trans_endB)
}

#let pat = tiling(size: (2pt, 3pt))[
  #place(line(start: (0%, 100%), end: (100%, 0%), stroke: 0.5pt))
]

#let data(pos, sig, x_end: float, amplitude: float) = {
  import cetz.draw: line, rect
  let sig_startA = (x: pos.x, y: pos.y + amplitude / 2.0)
  let sig_endA = (x: x_end, y: pos.y + amplitude / 2.0)
  let sig_startB = (x: pos.x, y: pos.y - amplitude / 2.0)
  let sig_endB = (x: x_end, y: pos.y - amplitude / 2.0)
  if sig == "U" {
    rect(sig_startA, sig_endB, stroke: none, fill: pat)
  }
  else {
    rect(sig_startA, sig_endB, stroke: none, fill: white.transparentize(40%))
  }
  line(sig_startA, sig_endA)
  line(sig_startB, sig_endB)
}

#let from_sig(pos, sig, instant: bool, amplitude: float) = {
  import cetz.draw: line
  // resolve transition width
  let width = if instant { 0 } else { transition-width }
  let trans_start = (x: pos.x, y: pos.y + sig-info.at(sig).level * amplitude / 2.0)
  let trans_end = (x: pos.x + width / 2.0, y: pos.y)
  line(trans_start, trans_end)
}

#let to_sig(pos, sig, instant: bool, amplitude: float) = {
  import cetz.draw: line
  // resolve transition width
  let width = if instant { 0 } else { transition-width }
  let trans_start = (x: pos.x + width / 2, y: pos.y)
  let trans_end = (x: pos.x + width, y: pos.y + sig-info.at(sig).level * amplitude / 2.0)
  line(trans_start, trans_end)
}

#let sig(pos, sig, x_end: float, amplitude: float) = {
  import cetz.draw: line
  let sig_start = (x: pos.x, y: pos.y + sig-info.at(sig).level * amplitude / 2.0)
  let sig_end = (x: x_end, y: pos.y + sig-info.at(sig).level * amplitude / 2.0)
  if sig == "M" {

    // zick zack repetitions
    let rep = 4
    // zick zack amplitude
    let amp = amplitude * 0.4
    // length of one zick zack repetition
    let rep_len = (x_end - pos.x) / rep
    // length of one zick zack element
    let seg_len = rep_len / 4

    for i in range(rep) {
      let x_start = sig_start.x + i * rep_len
      // draw zick zack
      line(
        (x: x_start, y: sig_start.y),
        (x: x_start + seg_len, y: sig_start.y + amp / 2.0))
      line(
        (x: x_start + seg_len, y: sig_start.y + amp / 2.0),
        (x: x_start + 3 * seg_len, y: sig_start.y - amp / 2.0))
      line(
        (x: x_start + 3 * seg_len, y: sig_start.y - amp / 2.0),
        (x: x_start + 4 * seg_len, y: sig_end.y))
    }
  }
  else {
    line(sig_start, sig_end)
  }
}

#let toggle-lut = (
  "H": "L",
  "L": "H",
  "Z": "H",
  "X": "H",
  "M": "H",
  "D": "L",
  "U": "L",
)

#let timing-characters = ("H", "L", "Z", "X", "M", "D", "U", "T", "C", "|")
#let parse-sequence(sequence, depth: 0) = {
  // Resulting parsed string after resolving repetitions and groups
  let parsed = ""

  // length of the diagram, exluding command chars like '|'
  let num-ticks = 0

  // How often to repeat the next timing character
  // Examples that show different ways to specify the next repetition are
  // '11H', '11.H', '11.11H', '.11H'
  let rep = "1"

  // Grouped sub-sequence in brackets ({})
  let group = ""

  // Track group nesting level to escape '}' characters.
  let nesting-level = 0

  // State machine to parse the sequence string
  // Input event: sequence character (c)

  // Capture timing character
  let state-timing-capture = 0

  // Capture repeating timing character
  let state-multi-capture = 1

  // Capture sub group
  let state-group-capture = 2

  // Capture repetition prefix
  let state-rep-capture = 3

  // current state
  let state = state-timing-capture

  // previously parsed timing character.
  // 'none' if it was not a timing character.
  let previous = none
  let repeat = ("char": none, "rep": 0)
  for c in sequence {
    if state == state-timing-capture {
      if c == "{" {
        state = state-group-capture
        group = ""
        previous = none
      }
      else if c == "}" {
        panic("Syntax error: Extra closed bracket. Recursion level: " + str(depth) + ", sequence: ", sequence)
      }
      else if c not in timing-characters {
        state = state-rep-capture
        rep = c
        previous = none
      }
      else {
        if c == previous {
          state = state-multi-capture
          // remove last character from parsed
          // parsed = parsed.slice(0, parsed.len() - 1)
          repeat = ("char": c, "rep": 2)
        }
        else {
          parsed += c
          if c != "|" {
            num-ticks += 1
          }
          previous = c
        }
      }
    }
    else if state == state-multi-capture {
      if c == "{" {
        state = state-group-capture
        group = ""
        previous = none
      }
      else if c == "}" {
        panic("Syntax error: Extra closed bracket. Recursion level: " + str(depth) + ", sequence: ", sequence)
      }
      else if c not in timing-characters {
        state = state-rep-capture
        rep = c
        previous = none
      }
      else {
        if c == previous {
          repeat.rep += 1
        }
        else {
          state = state-timing-capture
          parsed += c
          if c != "|" {
            num-ticks += 1
          }
          previous = c
        }
      }
    }
    else if state == state-group-capture {
      previous = none
      if c == "{" {
        nesting-level += 1
        group += c
      }
      else if c == "}" {
        if nesting-level == 0 {
          // exit transition
          state = state-timing-capture
          let parsed-group = parse-sequence(group, depth: depth + 1)
          let rep_num = int(rep)
          rep = "1"
          for i in range(rep_num) {
            parsed += parsed-group.at(0)
            num-ticks += parsed-group.at(1)
          }
        }
        else {
          nesting-level -= 1
          group += c
        }
      }
      else {
        group += c
      }
    }
    else if state == state-rep-capture {
      if c == "{" {
        state = state-group-capture
        group = ""
        // keep previous
      }
      else if c == "}" {
        panic("Syntax error: Unexpected closed bracket")
      }
      else if c in timing-characters {
        state = state-timing-capture
        let rep_num = int(rep)
        rep = "1"
        for i in range(rep_num) {
          parsed += c
          if c != "|" {
            num-ticks += 1
          }
        }
      }
      else {
        rep += c
      }
    }
    else {
      panic("Invalid parser state")
    }
  }

  assert(nesting-level == 0, message: "Unclosed bracket in sequence " + sequence);
  return (parsed, num-ticks)
}

#let wave(
  origin: (x: 0, y: 0),
  initchar: none,
  stroke: 1pt + black,
  xunit: 2.0,
  amplitude: 1.0,
  sequence
) = {
  import cetz.draw: set-style, rect
  let (parsed, num-ticks) = parse-sequence(sequence)
  // Must always draw invisible rect to allocate canvas space
  rect((origin.x, origin.y - amplitude / 2.0), (origin.x + num-ticks * xunit, origin.y + amplitude / 2.0), stroke: none)

  // Resolve toggle commands
  let previous = initchar
  if previous == none {
    previous = parsed.at(0)
  }
  if previous == "T" {
    previous = "L"
  }
  if previous == "C" {
    previous = "L"
  }

  // parse char sequence
  let tick = 0
  let explicit-transition = false
  for c in parsed {
    let instant = false
    if c == "|" {
      explicit-transition = true
      continue
    }
    else if c == "T" {
      c = toggle-lut.at(previous)
    }
    else if c == "C" {
      c = toggle-lut.at(previous)
      instant = true
    }
    let col = resolve_color(c: c, color: stroke.paint)
    set-style(stroke: stroke.thickness + col)
    let pos = (x: origin.x + tick * xunit, y: origin.y)
    let sig_pos = pos
    if c != previous or explicit-transition {
      if is_sig(previous) {
        from_sig(pos, previous, instant: instant, amplitude: amplitude)
      }
      else if is_data(previous) {
        from_data(pos, previous, amplitude: amplitude)
      }
      if is_sig(c) {
        to_sig(pos, c, instant: instant, amplitude: amplitude)
      }
      else if is_data(c){
        to_data(pos, c, amplitude: amplitude)
      }
      if not instant {
        sig_pos.x += transition-width
      }
    }
    if is_sig(c) {
      sig(
        sig_pos,
        c,
        x_end: pos.x + xunit,
        amplitude: amplitude
      )
    }
    else if is_data(c) {
      data(
        sig_pos,
        c,
        x_end: pos.x + xunit,
        amplitude: amplitude
      )
    }
    previous = c
    tick += 1
    explicit-transition = false
  }
}

#let texttiming(strok: black + 1pt, initchar: none, draw-grid: false, sequence) = {
  let (_, diagram-ticks) = parse-sequence(sequence)
  if diagram-ticks == 0 {
    return
  }
  context{
    // cetz-units per character.
    let xunit = 2.0

    // Signal amplitude
    let amplitude = 2.0

    // Length of one cetz-unit.
    // Normalized to xunit to make sure signal edges are
    // always at full cetz-units.
    let cetz-length = measure("X").height / xunit

    import cetz.draw: *
    box()[
    #cetz.canvas(padding: 0, length: cetz-length,
      {
        // Draw background grid
        //
        // It must always be drawn so signals always have the correct
        // relative position.
        //
        // If draw-grid is turned off, we set transparency to 100%.
        if draw-grid {
          grid((0, -amplitude / 2.0), (diagram-ticks * xunit, amplitude / 2.0), stroke: gray.transparentize(20%))
        }

        wave(
          initchar: initchar,
          stroke: strok,
          amplitude: amplitude,
          xunit: xunit,
          sequence
          )
      }
    )
    ]
  }
}

#let timingtable(
  row-dist: auto,
  col-dist: 10pt,
  xunit: 2.0,
  amplitude: 2.0,
  show-grid: false,
  ..body) = {
    context {
    let args = ()
    let i = 0
    let row = (
      "name": none,
      "sequence": none,
      "parsed": none,
      "ticks": none
      )
    let max-ticks = 0
    for arg in body.pos() {
      if calc.rem(i, 2) == 0 {
        if i > 0 {
          args.push(row)
        }
        row.at("name") = arg
      }
      else {
        row.at("sequence") = arg.text
        let (parsed, ticks) = parse-sequence(arg.text)
        row.at("parsed") = parsed
        row.at("ticks") = ticks
        if ticks > max-ticks {
          max-ticks = ticks
        }
      }
      i += 1
    }
    args.push(row)

    // CeTZ unit length
    let length = measure("X").height / xunit


    // Calculate row distance based on text height or user input
    let rowdist-pt = if row-dist == auto {
      // auto selection
      calc.max(text.size, length * amplitude) * 1.4
    }
    else {
      // user input
      row-dist
    }

    // Convert pixel distance to CeTZ unit
    let rowdist = rowdist-pt / length

    cetz.canvas(length: length, {
      import cetz.draw: *
      if show-grid {
        grid((0, amplitude / 2.0), (max-ticks * xunit, -(args.len() - 1) * rowdist - amplitude / 2.0), stroke: gray)
      }
      let row = 0
      for arg in args {
        content((-col-dist, -row * rowdist), anchor: "mid-east", arg.name)
        wave(
          origin: (x: 0, y: -row * rowdist),
          stroke: 1pt + black,
          xunit: xunit,
          amplitude: amplitude,
          arg.sequence
          )
        row += 1
      }
    })
    }
}