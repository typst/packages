#import "../theme/resolver.typ": resolve-spacing, resolve-token
#import "../core/state.typ": folio-state

#let missing(field-name) = context {
  let st = folio-state.get()
  let danger-color = resolve-token(st, "palette.intent.danger")
  let bg-color = danger-color.lighten(80%)

  rect(
    fill: bg-color,
    stroke: danger-color,
    radius: resolve-token(st, "geometry.radius.sm"),
    inset: resolve-spacing(st, multiplier: 0.5),
    text(fill: danger-color, style: "italic", size: resolve-token(
      st,
      "typography.size.sm",
    ))[
      Missing: #field-name
    ],
  )
}
