#let button(variant, body) = {
  context {
    let theme = state("theme-state").final()
    let selected-variant = if variant == 0 {
      theme.accent.a-0
    } else if variant == 1 {
      theme.accent.a-1
    } else if variant == 2 {
      theme.accent.a-2
    } else if variant == 3 {
      theme.accent.a-3
    } else if variant == 4 {
      theme.accent.a-4
    } else {
      assert(true, "Selected button variant '" + variant + "' is not available.")
    }

    set text(fill: theme.elem-fg)

    box(
      inset: (y: 8pt, x: 16pt),
      fill: selected-variant,
      radius: 4pt,
    )[
      #body
    ]
  }
}
