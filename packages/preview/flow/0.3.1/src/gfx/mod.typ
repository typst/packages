#import "util.typ": *
#import "render/mod.typ" as _render: segment
#import "../palette.typ": *

// make the icons easily accessible so that one can just key to
#let markers = (
  " ": "empty",
  "!": "urgent",
  ">": "progress",
  "x": "complete",
  ":": "pause",
  "-": "block",
  "/": "cancel",
  "?": "unknown",
  "i": "remark",
  "o": "hint",
  "a": "axiom",
  "d": "define",
  "t": "theorem",
  "l": "lemma",
  "p": "propose",
  "c": "corollary",
)


// need to convert to a dict so we can access by string key
#let _render = dictionary(_render)
#for (short, long) in markers.pairs() {
  let details = (
    accent: status.at(long),
    icon: _render.at(long),
    long: long,
  )
  markers.insert(short, details)
}

#let parallelopiped(start, end, shift: 0.5, ..args) = {
  import draw: *

  line(
    start,
    (start, "-|", end),
    (to: end, rel: (shift, 0)),
    (to: (start, "|-", end), rel: (shift, 0)),
    close: true,
    ..args,
  )
}

// Draws any content over a parallelopiped.
// Very useful for making a few words extra clear.
#let invert(
  accent: fg,
  shift: 1em,
  padding: (x: 1em),
  height: 1.4em,
  body,
) = context box({
  let body = pad(..padding, body)

  // idea is to draw 1 parallelopiped
  // but `place` it so it gets a zero-size box
  // while the text is still drawn normally
  // (just with the bg fill)
  let size = measure(body)
  let half-backdrop = box(
    canvas(
      length: 1em,
      {
        import draw: *
        parallelopiped(
          (0, 0),
          (size.width - 0.5em, height),
          shift: shift,
          fill: accent,
          stroke: accent,
        )
      },
    ),
  )

  place(
    dx: -shift / 4,
    dy: (size.height - height) / 2,
    half-backdrop,
  )
  text(fill: bg, body)
})

// Highlight the first grapheme cluster
// (can approximately think of it as a character)
// of each word
// using the given function.
#let fxfirst(it, fx: strong) = {
  it
    .split()
    .map(word => {
      let clusters = word.clusters()
      let first = fx(clusters.first())
      let rest = clusters.slice(1).join()
      [#first#rest]
    })
    .intersperse[ ]
    .join()
}
