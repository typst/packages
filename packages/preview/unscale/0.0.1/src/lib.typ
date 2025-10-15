#let version = version((0, 0, 1))

#let _unscale_state = state("__unscale_factor", (x: 100%, y: 100%))

#let scale-rule(it) = context {
  _unscale_state.update((
    x: 100% / it.x * 100%,
    y: 100% / it.y * 100%,
  ))
  it
}

#let unscale(body, reflow: true) = context {
  let args = _unscale_state.get()
  std.scale(
    body,
    x: args.x,
    y: args.y,
    reflow: reflow,
  )
}

#let rescale(body, reflow: false) = unscale(body, reflow: reflow)
