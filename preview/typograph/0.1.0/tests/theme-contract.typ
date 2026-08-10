// Theme boundary contract: the renderer is neutral, appearances are explicit,
// and a user-owned theme is only data plus shape-builder functions.
#import "/src/lib.typ" as typ
#import "/src/theme.typ": resolve-theme

#assert(typ.neutral-theme.node-presets == (:))
#assert(typ.neutral-theme.edge-defaults == (:))
#assert(typ.neutral-theme.edge-presets == (:))
#assert(typ.neutral-theme.palette == (:))

// Plain dictionaries are accepted and normalized, while theme() is the
// convenient validated constructor for reusable theme modules.
#let partial = resolve-theme((node-presets: (token: (fill: aqua)),))
#assert(partial.node-presets.token.fill == aqua)
#assert(
  partial.palette == (:)
    and partial.edge-defaults == (:)
    and partial.edge-presets == (:),
)

#let token-shape = typ.shapes.regular(vertices: 5, rotate: -90deg)
#let user-theme = typ.theme(
  node-presets: (
    token: (
      shape: token-shape,
      fill: aqua.lighten(70%),
      stroke: 0.8pt + teal,
      min-size: 14pt,
      inset: 3pt,
    ),
  ),
  edge-defaults: (stroke: 0.9pt + navy),
  edge-presets: (
    alert: (stroke: 1.2pt + red, highlight: red.lighten(70%)),
  ),
)
#let token = typ.node-type("token")
#let user-diagram = typ.diagram.with(theme: user-theme)

#user-diagram({
  let a = token(0, 0, label: [A])
  let b = token(1.5, 0, label: [B], style: (fill: yellow))
  typ.edge(a, b, preset: "alert", label: [custom])
})

// A theme preset beats constructor defaults; diagram and instance layers can
// still override it through the normal style resolver.
#let factory = (shape: typ.shapes.circle, fill: gray)
#let themed = typ.resolve-node-style(
  "token",
  (:),
  factory,
  user-theme.node-presets.token,
  (stroke: 2pt + blue),
  (fill: orange),
)
#assert(themed.shape == token-shape)
#assert(themed.stroke == 2pt + blue)
#assert(themed.fill == orange)

// Theme selection is per diagram. Rendering a neutral generic node between
// two differently themed semantic diagrams must require no global state.
#let plain-theme = (
  node-presets: (
    token: (
      shape: typ.shapes.square,
      fill: luma(235),
      stroke: 0.6pt + black,
      min-size: 12pt,
    ),
  ),
)
#stack(
  dir: ltr,
  spacing: 8pt,
  user-diagram({ token(0, 0, label: [5]) }),
  typ.diagram({
    typ.node(0, 0, label: [N], style: (
      shape: typ.shapes.circle,
      fill: white,
      stroke: 0.6pt + black,
      min-size: 12pt,
    ))
  }),
  typ.diagram(theme: plain-theme, { token(0, 0, label: [4]) }),
)
