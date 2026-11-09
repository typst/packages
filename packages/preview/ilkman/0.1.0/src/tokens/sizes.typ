// ilkman — size scales
//
// `body` is absolute; every other role is a ratio of the current body size,
// so components follow the slide density automatically.

#let size-scales = (
  doc: (
    body: 11pt,
    h1: 20 / 11, h2: 15 / 11, h3: 12.5 / 11, h4: 1.0,
    table: 9.5 / 11,
    code: 9 / 11,
    inline: 0.9,
    caption: 9 / 11,
    note: 9 / 11,
  ),
  slides: (
    body: 22pt,
    h1: 40 / 22, h2: 30 / 22, h3: 24 / 22, h4: 1.0,
    table: 18 / 22,
    code: 16 / 22,
    inline: 0.9,
    caption: 16 / 22,
    note: 16 / 22,
  ),
)

// Slide density presets: factor applied to body (and so to everything
// relative to it). Headings shrink less (see `heading-factor`).
#let density-presets = (low: 1.15, mid: 1.0, high: 0.75)

#let density-factor(d) = {
  if d == auto or d == none { return 1.0 }
  if type(d) == str {
    assert(d in density-presets, message: "ilkman: dense must be \"low\", \"mid\", \"high\" or a number")
    return density-presets.at(d)
  }
  float(d)
}

#let heading-factor(f) = 1 + (f - 1) * 0.55

// Monospace text is internally scaled by 0.8em in Typst; compensate.
#let raw-em(ratio) = ratio / 0.8 * 1em
