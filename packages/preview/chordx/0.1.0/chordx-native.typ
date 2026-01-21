// typst-chordx using native primitives

#let new-graph-chords-native(strings: 6, font: "Linux Libertine") = {
  return (
    frets: 5,
    fret-number: none,
    capos: (),
    fingers: (),
    notes,
    chord-name
  ) => {

    let vertical-space = 18pt
    if fingers.len() == 0 {
      vertical-space = 13pt
    }

    let step = 5pt
    let size-x = strings - 1
    let size-y = frets
    let bx = 0pt
    let by = -(frets * step + vertical-space)
    let stroke = black + 0.5pt

    let mute(col) = {
      let offset = col * step
      place(
        dx: bx,
        dy: by,
        line(
          start: (offset - 1.5pt, -2.5pt),
          end: (offset + 1.5pt, -5.5pt),
          stroke: stroke
        )
      )
      place(
        dx: bx,
        dy: by,
        line(
          start: (offset - 1.5pt, -5.5pt),
          end: (offset + 1.5pt, -2.5pt),
          stroke: stroke
        )
      )
    }

    let draw-grid(row, col) = {
      // shows or hides guitar nut
      if fret-number == none or fret-number == 1 {
        place(
          dx: bx,
          dy: by - 1.1pt,
          rect(
            width: col * step,
            height: 1.2pt,
            stroke: stroke,
            fill: black
          )
        )
      }

      place(
        dx: bx,
        dy: by,
        rect(
          width: col * step,
          height: row * step,
          stroke: stroke
        )
      )

      let i = 1
      while i < col {
        let x = i * step
        place(
          dx: bx,
          dy: by,
          line(
            start: (x, 0pt),
            end: (x, row * step),
            stroke: stroke
            )
        )
        i += 1
      }

      let i = 1
      while i < row {
        let y = i * step
        place(
          dx: bx,
          dy: by,
          line(
            start: (0pt, y),
            end: (col * step, y),
            stroke: stroke
          )
        )
        i += 1
      }
    }

    // draws notes: (x) for mute, (0) for air notes and (number) for finger notes
    let draw-notes(size, points) = {
      for (row, col) in points.zip(range(size)) {
        if row == "x" {
          mute(col)
        } else if row == 0 {
          let radius = 1.7pt
          place(
            dx: bx + step * col - radius,
            dy: by - 4pt - radius,
            circle(radius: radius, stroke: black + 0.5pt)
          )
        } else if type(row) == "integer" {
          let radius = 1.7pt
          place(
            dx: bx + step * col - radius,
            dy: by + step * row - radius - 2.5pt,
            circle(radius: radius, stroke: none, fill: black )
          )
        }
      }
    }

    // draws a capo list
    let draw-capos(size, points) = {
      for (fret, start, end) in points {
        if start > size {
          start = size
        }
        if end > size {
          end = size
        }
        place(
          dx: bx,
          dy: by + fret * step - 2.5pt,
          line(
            start: ((size - start) * step, 0pt),
            end: ((size - end) * step, 0pt),
            stroke: (paint: black, thickness: 3.4pt, cap: "round")
          )
        )
      }
    }

    // draws the finger numbers
    let draw-fingers(size, points) = {
      for (finger, col) in points.zip(range(size)) {
        if type(finger) == "integer" and finger > 0 and finger < 6 {
          place(
            dx: bx + col * step - 1.3pt,
            dy: by + frets * step + 1pt,
            text(6pt)[#finger])
        }
      }
    }

    let chord-name = text(12pt, font: font)[#chord-name]
    let fret-number = text(8pt)[#fret-number]

    style(styles => {
      let chord-name-size = measure(chord-name, styles)
      let fret-number-size = measure(fret-number, styles)

      let grid-size = (
        width: size-x * step + step,
        height: size-y * step
      )

      let graph-size = (
        width: grid-size.width + fret-number-size.width + 2.5pt,
        height: grid-size.height + 18pt + 5pt
      )

      let canvas-size = (
        width: 0pt,
        height: graph-size.height
      )

      let chord-name-offset = 0pt
      let graph-offset = 0pt
      let fret-number-offset = 0pt

      if chord-name-size.width < grid-size.width {
        canvas-size.width = graph-size.width
        chord-name-offset = graph-size.width - grid-size.width / 2 - chord-name-size.width / 2  - 2.5pt
      }

      if chord-name-size.width > grid-size.width and chord-name-size.width < graph-size.width {
        canvas-size.width = graph-size.width + (chord-name-size.width - grid-size.width) / 2
        chord-name-offset = graph-size.width - (fret-number-size.width + grid-size.width / 2 + 2.5pt)
      }

      if chord-name-size.width > graph-size.width {
        canvas-size.width = chord-name-size.width
        graph-offset = (chord-name-size.width - grid-size.width) / 2 - fret-number-size.width
      }

      box(..canvas-size,
        align(left + bottom, {
          place(left + bottom , dx: graph-offset, {
            place(left, dx: fret-number-size.width + 2.5pt, dy: 0pt, {
              draw-grid(size-y, size-x)
              draw-notes(strings, notes)
              draw-capos(strings, capos)
              draw-fingers(strings, fingers)
            })
            place(
              left + top,
              dx: 0pt,
              dy: by - 0.25pt,
              fret-number
            )
          })
          place(
            left + bottom,
            dx: chord-name-offset,
            dy: 0pt,
            chord-name
          )
        })
      )
    })
  }
}

#let new-single-chords-native(..text-style) = {
  return (body, chord-name, body-char-pos) => {
    box(
      style(styles => {
        align(left + bottom, {

          let offset = 0pt
          let anchor = center
          let canvas-size = (width: 0pt, height: 0pt)
          let body-size = measure(body, styles)
          let chord-size = measure(text(..text-style)[#chord-name], styles)

          let content-to-array(content) = {
            if content.has("text") {
              return content.at("text").clusters()
            }
            if content.has("double") {
              return (content,)
            }
            if content.has("children") {
              for item in content.at("children") {
                content-to-array(item)
              }
            }
            if content.has("body") {
              content-to-array(content.at("body"))
            }
            if content.has("base") {
              content-to-array(content.at("base"))
            }
            if content.has("equation") {
              content-to-array(content.at("equation"))
            }
          }

          let body-array = content-to-array(body)

          if body-char-pos.has("text") and int(body-char-pos.at("text")) != 0 {
            let body-chars-offset = 0pt
            let pos = int(body-char-pos.at("text")) - 1

            for i in range(pos) {
              body-chars-offset += measure([#body-array.at(i)], styles).width
            }

            anchor = left

            // gets the char-offset to center the first character of the chord
            // with the selected character of the body
            let chord-char = content-to-array(chord-name).at(0)
            let chord-char-width = measure(text(..text-style)[#chord-char], styles).width
            let body-char-width = measure([#body-array.at(pos)], styles).width
            let char-offset = (chord-char-width - body-char-width) / 2

            // final offset
            offset = body-chars-offset - char-offset
          }

          if offset > 0pt and chord-size.width + offset >= body-size.width {
            canvas-size.width = chord-size.width + offset
          } else if offset <= 0pt and chord-size.width >= body-size.width {
            canvas-size.width = chord-size.width
          } else {
            canvas-size.width = body-size.width
          }

          box(
            width: canvas-size.width,
            height: body-size.height + 16pt, {
              place(anchor + bottom, dx: offset, dy: -16pt, text(..text-style)[#chord-name])
              place(anchor + bottom, box(..body-size, body))
            }
          )
        })
      })
    )
  }
}
