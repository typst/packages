#let version = version((0, 1, 0))

#let layout-limiter(document, max-iterations: auto) = context {
  let max-iterations = if max-iterations == auto {
    int(sys.inputs.at("max-layout-iterations", default: 5))
  } else {
    max-iterations
  }
  assert(max-iterations <= 5, message: "max-iterations must be <= 5")
  let iters = counter("__layout-ltd-iterations")
  if iters.final().first() != 5 - max-iterations {
    iters.update(iters.final().first() + 1)
  } else {
    iters.update(5 - max-iterations)
    document
  }
}