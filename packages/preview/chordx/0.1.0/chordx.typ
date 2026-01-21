#import "@preview/cetz:0.0.1"

#let new-graph-chords(strings: 6, font: "Linux Libertine") = {
  return (
    frets: 5,
    fret-number: none,
    capos: (),
    fingers: (),
    notes,
    chord-name
  ) => {
    box(
      cetz.canvas({
        import cetz.draw: circle, content, line, rect, stroke

        let step = 5pt
        stroke(black + 0.5pt)

        let mute(col) = {
          let offset = col * step
          line((offset - 1.5pt, 2.5pt), (offset + 1.5pt, 5.5pt))
          line((offset - 1.5pt, 5.5pt), (offset + 1.5pt, 2.5pt))
        }

        // draws the grid
        let draw-grid(row, col, number) = {
          // Show or hide guitar nut
          if number == none or number == 1 {
            rect((0pt, -0.1pt), (col * step, 1.2pt), fill: black)
          }

          rect((0pt, 0pt), (col * step, -row * step))

          let i = 1
          while i < col {
            let x = i * step
            line((x, 0pt), (x, -row * step ))
            i += 1
          }

          let i = 1
          while i < row {
            let y = i * step
            line((0pt, -y), (col * step, -y))
            i += 1
          }
        }

        // draws notes: (x) for mute, (0) for air notes and (number) for finger notes
        let draw-notes(size, points) = {
          for (row, col) in points.zip(range(size)) {
            if row == "x" {
              mute(col)
            } else if row == 0 {
              circle(
                (col * step, 4pt),
                radius: 0.06,
                stroke: black + 0.5pt,
                fill: none
              )
            } else if type(row) == "integer" {
              circle(
                (col * step, step / 2 - row * step),
                radius: 0.06,
                stroke: none,
                fill: black
              )
            }
          }
        }

        // draw a capo list
        let draw-capos(size, points) = {
          for (fret, start, end) in points {
            if start > size {
              start = size
            }
            if end > size {
              end = size
            }

            line(
              ((size - start) * step, step / 2 - fret * step),
              ((size - end) * step, step / 2 - fret * step),
              stroke: (paint: black, thickness: 3.4pt, cap: "round")
            )
          }
        }

        // draws the finger numbers
        let draw-fingers(size, points) = {
          for (finger, col) in points.zip(range(size)) {
            if type(finger) == "integer" and finger > 0 and finger < 6 {
              content((col * step, -(frets * step + 3pt)), text(6pt)[#finger])
            }
          }
        }

        draw-grid(frets, strings - 1, fret-number)
        draw-notes(strings, notes)
        draw-capos(strings, capos)
        draw-fingers(strings, fingers)

        // shows the fret number
        content((-3pt, -2.25pt), anchor: "right", text(8pt)[#fret-number])

        let space = 14pt
        if fingers.len() == 0 {
          space = 9pt
        }

        // shows the chord name
        content((step / 2 * (strings - 1), -(frets * step + space)), text(12pt, font: font)[#chord-name])
      })
    )
  }
}

#let new-single-chords(..text-style) = {
  return (body, chord-name, body-char-pos) => {
    box(
      style(body-styles => {
        cetz.canvas({
          import cetz.draw: content

          let offset = 0pt
          let anchor = "center"

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

          // computes the width of the word until the pos index
          if body-char-pos.has("text") and int(body-char-pos.at("text")) != 0 {
          let body-chars-offset = 0pt
            let pos = int(body-char-pos.at("text")) - 1

            for i in range(pos) {
              body-chars-offset += measure([#body-array.at(i)], body-styles).width
            }
            let body-width = measure(body, body-styles).width

            anchor = "left"

            // gets the char-offset to center the first character of the chord
            // with the selected character of the body
            let chord-char = content-to-array(chord-name).at(0)
            let chord-char-width = measure(text(..text-style)[#chord-char], body-styles).width
            let body-char-width = measure([#body-array.at(pos)], body-styles).width
            let char-offset = (chord-char-width - body-char-width) / 2

            // final offset
            offset = body-chars-offset - (body-width / 2) - char-offset
          }

          content((offset, 16pt), text(..text-style)[#chord-name], anchor: anchor)
          content((0pt, 0pt), body)
        })
      })
    )
  }
}
