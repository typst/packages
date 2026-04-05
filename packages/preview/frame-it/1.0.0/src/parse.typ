#let calculate-colors(count) = {
  let samples = for i in range(count) {
    (i * 100% / count,)
  }
  gradient
    .linear(..color.map.rainbow.rev())
    .samples(..samples)
    .map(color => color.lighten(70%).desaturate(50%))
}

#let parse-args(frames) = {
  assert(
    frames.pos() == (),
    message: "Unexpected positional arguments: " + repr(frames.pos()),
  )

  // Canonicalize and validate arguments
  let args = for (id, args) in frames.named() {
    assert(
      type(args) == array,
      message: "Please provide an array of the form '(<substitute name>, [<custom argument passed to styling function>])', where the latter is optional.
      The problem arises from frame-kind " + repr(id) + " which receives arguments " + repr(args),
    )
    let (supplement, col, ..) = args + (
      auto,
    ) // Denote color with 'auto' if omitted
    assert(type(supplement) in (content, str))
    assert(
      type(col) in (color, type(auto)),
      message: "Please provide a color as second arguments: " + supplement + " (was " + type(col) + ")",
    )
    ((id, supplement, col),)
  }

  // Count auto in args and generate colors
  let auto-count = args.filter(((_, _, col)) => col == auto).len()
  let generated-colors = calculate-colors(auto-count)
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
