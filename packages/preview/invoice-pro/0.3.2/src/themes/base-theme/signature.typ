#let render-signature(ctx, view) = {
  let strings = ctx.locale.strings
  let sig-str = strings.signature

  block(breakable: false, {
    v(1em)
    sig-str.closing
    v(1em)

    view.signature

    if view.name != none and view.name != "" [
      #view.name
    ]
  })
}
