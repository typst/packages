#let render-signature(ctx, view) = {
  block(breakable: false, {
    v(1em)
    [Mit freundlichen Grüßen]
    v(1em)

    view.signature

    if view.name != none and view.name != "" [
      #view.name
    ]
  })
}
