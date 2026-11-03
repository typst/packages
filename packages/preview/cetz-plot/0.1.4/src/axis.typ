#let lin-axis(name, min, max) = {
  (name: name,
   mode: "lin",
   min: min,
   max: max,)
}

#let log-axis(name, min, max, base: 10) = {
  (name: name,
   mode: "log",
   min: min,
   max: max,
   base: base,)
}

///
#let setup-cartesian-axis(ctx, axis, begin, end) = {
  if not "plot-axes" in ctx {
    ctx.cetz-plot-axes = (:)
  }

  ctx.cetz-plot-axes.insert(axis.name, axis)

  return ctx
}
