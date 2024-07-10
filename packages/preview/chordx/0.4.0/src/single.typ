#import "./utils.typ": parse-content, has-number, size-to-scale

/// The single chord a chord without diagram used to show the chord name over a word.
///
/// - ..text-params (auto): Embeds the native *text* parameters from the standard library of *typst*. *Optional*.
///
/// - background (color): Sets the background color of the chord. *Optional*.
///
/// - body (content): Is the word or words where the chord goes. *Required*.
///
/// - name (content): Displays the chord name over the selected words in the body. *Required*.
///
/// - position (content): Positions the chord on a specific body character. *Required*.
///  - ```typ []```: chord name centered on the body.
///  - ```typ [number]```: the chord name starts on a specific body character. (First position ```typ [1]```)
///
/// -> content
#let single-chord(
  ..text-params,
  background: rgb(0, 0, 0, 0),
  body,
  name,
  position
) = context {
  assert.eq(type(background), color)
  assert.eq(type(body), content)
  assert.eq(type(name), content)
  assert.eq(type(position), content)

  let scale = 1

  if "size" in text-params.named().keys() {
    let (size,) = text-params.named()
    scale = size-to-scale(size, 12pt)
  }

  let horizontal-offset = 0pt
  let vertical-offset = 1.2em
  let anchor = center

  let size = (:)
  size.body = measure(body)
  size.name = measure(text(..text-params)[#name])
  let body-array = parse-content(body)

  if position.has("text") {
    assert(has-number(position.at("text")) == true, message: "the \"position\" must to be a \"content\" with only numbers")

    let body-chars-offset = 0pt
    let pos = int(position.at("text")) - 1
    let min-pos = 0
    let max-pos = body-array.len() - 1
    pos = calc.clamp(pos, min-pos, max-pos)

    for i in range(pos) {
      body-chars-offset += measure([#body-array.at(i)]).width
    }

    // gets the char-offset to center the first character of
    // the chord with the selected character of the body
    let chord-char = parse-content(name).at(0)
    let chord-char-width = measure(text(..text-params)[#chord-char]).width
    let body-char-width = measure([#body-array.at(pos)]).width
    let char-offset = (chord-char-width - body-char-width) / 2

    // final horizontal offset
    horizontal-offset = body-chars-offset - char-offset
    anchor = left
  }

  size.canvas = (
    width: 0pt,
    height: size.body.height + size.name.height + 0.8em,
    dx: horizontal-offset,
    dy: -vertical-offset
  )

  size.canvas.width = {
    if horizontal-offset > 0pt and size.name.width + horizontal-offset >= size.body.width {
      size.name.width + horizontal-offset
    } else if horizontal-offset <= 0pt and size.name.width >= size.body.width {
      size.name.width
    } else {
      size.body.width
    }
  }

  box(
    width: size.canvas.width,
    height: size.canvas.height, {
      place(
        anchor + bottom,
        dx: size.canvas.dx,
        dy: size.canvas.dy,
        box(
          fill: background,
          outset: (x: 2pt * scale, y: 3pt * scale),
          radius: 2pt * scale,
          text(..text-params)[#name]
        )
      )
      place(
        anchor + bottom,
        box(..size.body, body)
      )
    }
  )
}
