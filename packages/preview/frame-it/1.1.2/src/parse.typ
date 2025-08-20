#let calculate-colors(base-color, count) = (
  range(count)
    .map(i => (
      i / count * 360deg
    ))
    .map(rotation => base-color.rotate(rotation))
)

#let fill-missing-colors(
  base-color,
  frames,
) = {
  assert(
    frames.pos() == (),
    message: "Unexpected positional arguments: " + repr(frames.pos()),
  )

  // Canonicalize and validate arguments
  let args = for (id, args) in frames.named() {
    if type(args) != array {
      args = (args,)
    }
    let (supplement, col, ..) = (
      args
        + (
          auto,
        )
    ) // Denote color with 'auto' if omitted
    assert(type(supplement) in (content, str))
    assert(
      type(col) in (color, type(auto)),
      message: "Please provide a color as second arguments: "
        + supplement
        + " (was "
        + repr(type(col))
        + ")",
    )
    ((id, supplement, col),)
  }

  // Count auto in args and generate colors
  let auto-count = args.filter(((_, _, col)) => col == auto).len()
  let generated-colors = calculate-colors(base-color, auto-count)
  let next-color-idx = 0

  // Replace auto with respective colors
  for (id, supplement, col) in args {
    if col == auto {
      col = generated-colors.at(next-color-idx)
      next-color-idx += 1
    }
    ((id, supplement, col),)
  }
}
