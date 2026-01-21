#import "./utils.typ": size-to-scale, parse-input-string, top-border-normal, top-border-round

// Draws a horizontal border that indicates the starting of the fretboard
#let draw-nut(self) = {
  let size = (
    width: self.grid.width,
    height: 1.2pt * self.scale
  )

  if self.fret in (none, 1) {
    if self.style == "normal" {
      top-border-normal(size, self.stroke, self.scale)
    } else {
      top-border-round(size, self.stroke, self.scale)
    }
  }
}

// Draws a grid with a width = (length of tabs) and height = (number of frets)
#let draw-grid(self) = {
  let radius = (bottom: 1pt * self.scale, top: 1pt * self.scale)
  place(
    rect(
      width: self.grid.width,
      height: self.grid.height,
      radius: if self.style == "normal" {0pt} else {radius},
      stroke: self.stroke
    )
  )

  // draws the vertical lines
  for i in range(self.grid.cols - 1) {
    let x = (i + 1) * self.step
    place(
      line(
        start: (x, 0pt),
        end: (x, self.grid.height),
        stroke: self.stroke
      )
    )
  }

  // draws the horizontal lines
  for i in range(self.grid.rows - 1) {
    let y = (i + 1) * self.step
    place(
      line(
        start: (0pt, y),
        end: (self.grid.width, y),
        stroke: self.stroke
      )
    )
  }
}

// Draws the tabs over the grid
#let draw-tabs(self) = {
  for (tab, col) in self.tabs.zip(range(self.tabs.len())) {
    if type(tab) == "string" and lower(tab) == "x" {
      let offset = col * self.step
      place(
        line(
          start: (offset - 1.5pt * self.scale, -2.5pt * self.scale),
          end: (offset + 1.5pt * self.scale, -5.5pt * self.scale),
          stroke: self.stroke
        )
      )
      place(
        line(
          start: (offset - 1.5pt * self.scale, -5.5pt * self.scale),
          end: (offset + 1.5pt * self.scale, -2.5pt * self.scale),
          stroke: self.stroke
        )
      )
      continue
    }
    if (type(tab) == str and lower(tab) == "o") {
      let radius = 1.7pt * self.scale
      place(
        dx: self.step * col - radius,
        dy: -4pt * self.scale - radius,
        circle(radius: radius, stroke: self.stroke)
      )
      continue
    }
    if type(tab) == int and tab > 0 and tab <= self.frets-amount {
      let radius = 1.7pt * self.scale
      place(
        dx: self.step * col - radius,
        dy: self.step * tab - radius - 2.5pt * self.scale,
        circle(radius: radius, stroke: none, fill: black)
      )
      continue
    }
  }
}

// Draws a capo list
//
// capo = (fret, start, end)
// fret: fret position
// start: lowest starting string
// end: highest ending string
#let draw-capos(self) = {
  let size = self.tabs.len()
  for (fret, start, end, ..) in self.capos {
    if start > size {
      start = size
    }
    if end > size {
      end = size
    }
    place(
      dy: fret * self.step - 2.5pt * self.scale,
      line(
        start: ((size - start) * self.step, 0pt),
        end: ((size - end) * self.step, 0pt),
        stroke: (paint: black, thickness: 3.4pt * self.scale, cap: "round")
      )
    )
  }
}

// Draws the finger numbers below the grid
#let draw-fingers(self) = {
  let size = self.tabs.len()
  for (finger, col) in self.fingers.zip(range(size)) {
    if type(finger) == int and finger > 0 and finger < 6 {
      place(
        left + top,
        dx: col * self.step - 1.3pt * self.scale,
        dy: self.grid.height + 1.5pt * self.scale,
        text(6pt * self.scale)[#finger])
    }
  }
}

// Draws the fret start number that indicates the starting position of the fretboard
#let draw-fret(self) = {
  place(left + top,
    dx: -3pt * self.scale,
    dy: self.step / 2 - 0.2pt * self.scale,
    place(right + horizon, text(8pt * self.scale)[#self.fret])
  )
}

// Draws the chord name below the grid and finger numbers
#let draw-name(self) = {
  place(
    dx: self.grid.width / 2,
    dy: self.grid.height + self.vertical-gap-name,
    place(center + horizon, text(12pt * self.scale)[#self.name])
  )
}

// Render the chart
#let render(self) = {
  style(styles => {
    let fret-number-size = measure(text(8pt * self.scale)[#self.fret], styles)
    let chord-name-size = measure(text(12pt * self.scale)[#self.name], styles)

    let tabs-height = if "o" in self.tabs or "x" in self.tabs {
      -(4pt + 1.7pt) * self.scale
    } else {
      0pt
    }

    let graph = (
      width: self.tabs.len() * self.step,
      height: self.frets-amount * self.step
    )

    let chart = (
      width: graph.width + fret-number-size.width + self.step / 2,
      height: graph.height + chord-name-size.height / 2 + self.vertical-gap-name - tabs-height
    )

    let canvas = (
      width: calc.max(graph.width / 2, chord-name-size.width / 2) + calc.max(chart.width / 2 + fret-number-size.width, chord-name-size.width / 2),
      height: chart.height,
      dx: calc.max((chord-name-size.width - graph.width) / 2 + self.step / 2, fret-number-size.width + self.step / 2),
      dy: -(graph.height + chord-name-size.height / 2 + self.vertical-gap-name),
    )

    box(
      width: canvas.width,
      height: canvas.height,
      place(
        left + bottom,
        dx: canvas.dx,
        dy: canvas.dy, {
          draw-nut(self)
          draw-grid(self)
          draw-tabs(self)
          draw-capos(self)
          draw-fingers(self)
          draw-fret(self)
          draw-name(self)
        }
      )
    )
  })
}

/// Return a new function with default parameters to generate chart chords for stringed instruments.
///
/// - frets-amount (integer): Presets the frets amount (the grid rows). *Optional*.
/// - size (length): Presets the chart size. The default value is set to the chord name's font size. *Optional*.
/// - style (string): Sets the chart style. *Optional*.
///  - ```js "normal```: chart with right angles.
///  - ```js "round```: chart with round angles.
/// - font (string): Sets the name of the text font. *Optional*.
/// -> function
#let new-chart-chords(
  frets-amount: 5,
  size: 12pt,
  style: "normal",
  font: "Linux Libertine"
) = {
  /// Is the returned function by *new-chart-chords*.
  ///
  /// - tabs (string): Shows the tabs on the chart. *Optional*.
  ///  - *x*: mute note.
  ///  - *o*: air note.
  ///  - *n*: without note.
  ///  - *number*: note position on the fret.
  ///
  /// The string length of tabs defines the number of strings on the instrument.
  ///  #parbreak() Example:
  ///  - ```js "x32o1o"``` - (6 strings - C Guitar chord).
  ///  - ```js "ooo3"``` - (4 strings - C Ukulele chord).
  ///
  /// - fingers (string): Shows the finger numbers. *Optional*.
  ///  - *n*, *x*, *o*: without finger,
  ///  - *number*: one finger
  ///  #parbreak() Example: ```js "n32n1n"``` - (Fingers for guitar chord: C)
  ///
  /// - capos (string): Adds one or many capos on the chart. *Optional*.
  ///  - 1#super[st] digit -- *fret*: fret position.
  ///  - 2#super[nd] digit -- *start*: lowest starting string.
  ///  - 3#super[rd] digit -- *end*: highest ending string.
  ///  #parbreak() Example: ```js "115"``` $\u{2261}$ ```js "1,1,5"``` $=>$ ```js "fret,start,end"```
  ///  #parbreak() With ```js "|"``` you can add capos:
  ///  #parbreak() Example: ```js "115|312"``` $\u{2261}$ ```js "1,1,5|3,1,2"``` $=>$ ```js "fret,start,end|fret,start,end"```
  ///
  /// - fret (integer): Shows the fret number that indicates the starting position of the fretboard. *Optional*.
  /// - frets-amount (integer): Sets the frets amount (the grid rows). *Optional*.
  /// - size (length): Sets the chart size. The default value is set to the chord name's font size. *Optional*.
  /// - name (string, content): Shows the chord name. *Required*.
  /// -> content
  let chart-chord(
    tabs: "",
    fingers: "",
    capos: "",
    fret: none,
    frets-amount: frets-amount,
    size: size,
    name
  ) = {
    assert.eq(type(tabs), str)
    assert.eq(type(fingers), str)
    assert.eq(type(capos), str)
    assert.eq(type(frets-amount), int)
    assert.eq(type(size), length)
    assert(type(fret) == int or fret == none, message: "type of 'fret' must to be 'int' or 'none'")
    assert(type(name) in (str, content), message: "type of 'name' must to be 'str' or 'content'")
    assert(style in ("normal", "round"), message: "'style' must to be '\"normal\"' or '\"round\"'")

    let tabs = parse-input-string(tabs)
    let fingers = parse-input-string(fingers)
    let capos = parse-input-string(capos)
    if capos.len() != 0 and type(capos.first()) != "array" {
      capos = (capos,)
    }

    let scale = size-to-scale(size, 12pt)
    let step = 5pt * scale
    let stroke = black + 0.5pt * scale

    let vertical-gap-name = 14pt * scale
    if fingers.len() == 0 {
      vertical-gap-name = 9pt * scale
    }

    set text(font: font)

    let self = (
      scale: scale,
      step: step,
      stroke: black + 0.5pt * scale,
      vertical-gap-name: vertical-gap-name,
      grid: (
        width: (tabs.len() - 1) * step,
        height: frets-amount * step,
        rows: frets-amount,
        cols: tabs.len() - 1,
      ),
      tabs: tabs,
      fingers: fingers,
      capos: capos,
      frets-amount: frets-amount,
      fret: fret,
      style: style,
      name: name,
    )

    render(self)
  }
  return chart-chord
}
