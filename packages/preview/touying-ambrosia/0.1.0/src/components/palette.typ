#import "context.typ": component-wrapper

#let _roles = ("background", "surface", "surface-alt", "primary", "foreground", "muted", "info", "success", "warning", "danger")

#let render-palette-showcase(self: none, roles: _roles, columns: auto, title: auto, codes: true) = {
  assert(type(roles) == array and roles.len() > 0, message: "Palette showcase roles must be a nonempty array.")
  assert(columns == auto or (type(columns) == int and columns > 0), message: "Palette showcase columns must be auto or a positive integer.")
  assert(type(codes) == bool, message: "Palette showcase codes must be true or false.")
  let colors = self.colors + (background: self.page.fill)
  assert(roles.all(role => role in colors), message: "Unknown palette showcase role.")
  let title = if title == auto { self.store.palette } else { title }
  if title != none { block(below: 0.6em, text(weight: "semibold", title)) }
  layout(bounds => context {
    let count = if columns == auto { calc.max(1, calc.min(5, calc.floor(bounds.width / (6.5 * text.size)))) } else { columns }
    [#metadata((palette: self.store.palette, columns: count, colors: roles.map(role => (role: role, color: colors.at(role)))))<ambrosia-palette-showcase>]
    grid(columns: (1fr,) * count, gutter: 0.55em,
      ..roles.map(role => {
        let color = colors.at(role)
        block(width: 100%, fill: self.colors.surface, stroke: 0.035em + self.colors.border,
          radius: 0.3em, clip: true)[
          #block(width: 100%, height: 1.6em, fill: color, below: 0em)[]
          #block(inset: (x: 0.45em, y: 0.35em), above: 0em, below: 0em)[
            #set text(size: 0.65em, fill: self.colors.foreground)
            #role
            #if codes {
              linebreak()
              text(size: 0.9em, font: self.store.mono-font, fill: self.colors.muted,
                if type(color) == std.color { color.to-hex() } else { "custom" })
            }
          ]
        ]
      }),
    )
  })
}

/// Show the actual current colors, including branding and per-slide overrides.
#let ambrosia-palette-showcase(..args) = component-wrapper(render-palette-showcase, ..args)
