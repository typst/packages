#import "./utils.typ": parse-content, has-number

/// The single chords are chords without diagram used to show the chord name over a word.
///
/// - ..text-params (auto): Are the same parameters of *text* from the standard library of *typst*. *Required*.
/// -> function
#let new-single-chords(..text-params) = {
  /// Is the returned function by *new-single-chords*.
  ///
  /// - body (content): Is the word or words where the chord goes. *Required*.
  /// - name (content): Displays the chord name over the selected words in the body. *Required*.
  /// - position (content): Positions the chord over a specific character in the body. *Required*.
  ///  - ```typ []```: chord name centered on the body.
  ///  - ```typ [number]```: the chord name starts over a specific body character. (First position ```js [1]```)
  let single-chord(
    body,
    name,
    position
  ) = {
    assert.eq(type(body), content)
    assert.eq(type(name), content)
    assert.eq(type(position), content)

    style(styles => {
      let horizontal-offset = 0pt
      let vertical-offset = 1.2em
      let anchor = center
      let body-size = measure(body, styles)
      let name-size = measure(text(..text-params)[#name], styles)
      let body-array = parse-content(body)

      if position.has("text") {
        assert(has-number(position.at("text")) == true, message: "the \"position\" must to be a \"content\" with only numbers")

        let body-chars-offset = 0pt
        let pos = int(position.at("text")) - 1
        let min-pos = 0
        let max-pos = body-array.len() - 1
        pos = calc.clamp(pos, min-pos, max-pos)

        for i in range(pos) {
          body-chars-offset += measure([#body-array.at(i)], styles).width
        }

        // gets the char-offset to center the first character of
        // the chord with the selected character of the body
        let chord-char = parse-content(name).at(0)
        let chord-char-width = measure(text(..text-params)[#chord-char], styles).width
        let body-char-width = measure([#body-array.at(pos)], styles).width
        let char-offset = (chord-char-width - body-char-width) / 2

        // final horizontal offset
        horizontal-offset = body-chars-offset - char-offset
        anchor = left
      }

      let canvas = (
        width: 0pt,
        height: body-size.height + name-size.height + 0.8em,
        dx: horizontal-offset,
        dy: -vertical-offset
      )

      if horizontal-offset > 0pt and name-size.width + horizontal-offset >= body-size.width {
        canvas.width = name-size.width + horizontal-offset
      } else if horizontal-offset <= 0pt and name-size.width >= body-size.width {
        canvas.width = name-size.width
      } else {
        canvas.width = body-size.width
      }

      box(
        width: canvas.width,
        height: canvas.height, {
          place(
            anchor + bottom,
            dx: canvas.dx,
            dy: canvas.dy,
            text(..text-params)[#name]
          )
          place(
            anchor + bottom,
            box(..body-size, body)
          )
        }
      )
    })
  }
  return single-chord
}
