#import "palette.typ": *
#import "gfx/mod.typ" as gfx

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
    gfx.canvas(
      length: 1em,
      figure: false,
      {
        gfx.parallelopiped(
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

      first + rest
    })
    .join(" ")
}

/// Capitalize the first grapheme cluster of each word.
#let tcase = fxfirst.with(fx: upper)

