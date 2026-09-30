#import "./utils.typ": has-number, parse-content, size-to-scale

// Note list with sharp and flat accidentals
#let sharp-notes = ("C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B")
#let flat-notes  = ("C", "Db", "D", "Eb", "E", "F", "Gb", "G", "Ab", "A", "Bb", "B")

// A dictionary with the full notes and their indices
#let full-notes-dict = (
  "C":  0, "B#": 0,
  "C#": 1, "Db": 1,
  "D":  2,
  "D#": 3, "Eb": 3,
  "E":  4, "Fb": 4,
  "F":  5, "E#": 5,
  "F#": 6, "Gb": 6,
  "G":  7,
  "G#": 8, "Ab": 8,
  "A":  9,
  "A#": 10, "Bb": 10,
  "B":  11, "Cb": 11,
)

// Transposes a chord using custom symbols and accidental preferences
#let transpose-chord(name, transpose, accidental-prefer, sharp-symbol, flat-symbol) = {
  let name = parse-content(name).join()

  if transpose == 0 {
    return name
  }

  name.replace(
    regex("([A-G])(#|b|" + sym.sharp + "|" + sym.flat + ")?"),
    match => {
      let note = match.captures.at(0)
      let accidental = match.captures.at(1)

      if accidental == str(sym.sharp) { accidental = "#" }
      if accidental == str(sym.flat) { accidental = "b" }
      if accidental == none { accidental = "" }

      let full-note = note + accidental

      if full-note in full-notes-dict {
        let current = full-notes-dict.at(full-note)
        let new-value = calc.rem(current + transpose, 12)

        if new-value < 0 { new-value += 12 }

        if accidental-prefer == "sharp" {
          return sharp-notes.at(new-value).replace("#", sharp-symbol)
        }

        return flat-notes.at(new-value).replace("b", flat-symbol)
      }

      return match.text
    }
  )
}

/// The single chord a chord without diagram used to show the chord name over a word.
/// -> content
#let single-chord(
  /// Embeds the native *text* parameters from the standard library of *typst*. *Optional*.
  /// -> auto
  ..text-params,

  /// Sets the inner gap between the bottom word and the chord name. *Optional*.
  /// -> length
  inner-gap: 0.2em,

  /// Sets the outer gap between the upper paragraph and the chord name. *Optional*.
  /// -> length
  outer-gap: 0.6em,

  /// Sets the background color of the chord. *Optional*.
  /// -> color
  background: rgb(0, 0, 0, 0),

  /// Preferred musical accidental. *Optional*.
  ///  - ```js "sharp```: prefers sharp accidentals.
  ///  - ```js "flat```: prefers flat accidentals.
  /// -> str
  accidental: "sharp",

  /// Sets the sharp symbol. *Optional*.
  /// -> str
  sharp-symbol: "#",

  /// Sets the flat symbol. *Optional*.
  /// -> str
  flat-symbol: "b",

  /// Sets the number of semitones to transpose the chord. *Optional*.
  /// -> int
  transpose: 0,

  /// Is the word or words where the chord goes. *Required*.
  /// -> content
  body,

  /// Displays the chord name over the selected words in the body. *Required*.
  /// -> content
  name,

  /// Positions the chord on a specific body character. *Required*.
  ///  - ```typ []```: chord name centered on the body.
  ///  - ```typ [0]```: chord name placed before the body.
  ///  - ```typ [number]```: the chord name starts on a specific body character. (First position ```typ [1]```)
  /// -> content
  position,
) = context {
  assert.eq(type(inner-gap), length)
  assert.eq(type(outer-gap), length)
  assert.eq(type(background), color)
  assert(accidental in ("sharp", "flat"), message: "`accidental` must to be \"sharp\" or \"flat\"")
  assert.eq(type(transpose), int)
  assert.eq(type(body), content)
  assert.eq(type(name), content)
  assert.eq(type(position), content)

  let scale = 1

  if "size" in text-params.named().keys() {
    let (size,) = text-params.named()
    scale = size-to-scale(size, 12pt)
  }

  let horizontal-offset = 0pt
  let horizontal-preshift = 0pt
  let vertical-offset = 0em
  let anchor = center
  let name = transpose-chord(name, transpose, accidental, sharp-symbol, flat-symbol)

  let size = (:)
  size.body = measure(body)
  size.name = measure(text(..text-params)[#name])
  let body-array = parse-content(body)

  if position.has("text") {
    assert(
      has-number(position.at("text")) == true,
      message: "the \"position\" must to be a \"content\" with only numbers",
    )

    let pos = int(position.at("text")) - 1
    let chord-char = name.at(0)
    let chord-char-width = measure(text(..text-params)[#chord-char]).width
    if (pos >= 0) {
      let min-pos = 0
      let max-pos = body-array.len() - 1
      pos = calc.clamp(pos, min-pos, max-pos)

      let body-chars-offset = measure([#body-array.slice(0, pos).join()]).width

      // gets the char-offset to center the first character of
      // the chord with the selected character of the body
      let body-char-width = measure([#body-array.at(pos)]).width
      let char-offset = (chord-char-width - body-char-width) / 2

      // final horizontal offset
      horizontal-offset = body-chars-offset - char-offset
    } else {
      horizontal-preshift = chord-char-width
    }
    anchor = left
  }

  if size.body.height > 0em {
    vertical-offset = size.body.height + 0.2em + inner-gap
  }

  size.canvas = (
    width: 0pt,
    height: size.body.height + size.name.height + outer-gap + inner-gap,
    dx: horizontal-offset,
    dy: -vertical-offset,
  )

  size.canvas.width = {
    if horizontal-offset > 0pt and size.name.width + horizontal-offset >= size.body.width {
      size.name.width + horizontal-offset
    } else if horizontal-offset <= 0pt and size.name.width >= size.body.width + horizontal-preshift {
      size.name.width
    } else {
      size.body.width + horizontal-preshift
    }
  }

  box(
    width: size.canvas.width,
    height: size.canvas.height,
    {
      place(
        anchor + bottom,
        dx: size.canvas.dx,
        dy: size.canvas.dy,
        box(
          fill: background,
          outset: (x: 2pt * scale, y: 3pt * scale),
          radius: 2pt * scale,
          text(..text-params)[#name],
        ),
      )
      place(
        anchor + bottom,
        dx: horizontal-preshift,
        box(..size.body, body),
      )
    },
  )
}
