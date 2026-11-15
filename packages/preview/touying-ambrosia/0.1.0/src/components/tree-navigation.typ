#import "../utils/navigation.typ": navigation-model
#import "../utils/layout.typ": call-or-display
#import "../touying.typ": utils
#import "../palettes.typ": on-color
#import "structural-navigation.typ": navigation-label

// Beamer's tree family: the talk title, then the visible ancestor path. Each
// row is one line, with a small branch hook and increasing indentation.
#let render-tree(self) = layout(bounds => context {
  let definition = self.store.navigation-definition
  let model = navigation-model()
  let depth = calc.min(definition.depth, calc.max(0, self.slide-level - 1))
  let row-height = definition.height / (depth + 1)
  let flavor = self.store.flavor-definition
  let base = (flavor.navigation-background)(self)
  let base = if type(base) == color { base } else { self.colors.primary }
  let first = model.scoped-slides.first(default: none)
  let title = call-or-display(self, if self.info.short-title == auto { self.info.title } else { self.info.short-title })
  let hook(ink) = box(width: 0.7em, height: 0.7em, {
    place(left + top, line(start: (0em, 0em), end: (0em, 0.5em), stroke: 0.045em + ink))
    place(left + top, line(start: (0em, 0.5em), end: (0.55em, 0.5em), stroke: 0.045em + ink))
  })
  [#metadata((height: bounds.height.pt(), width: bounds.width.pt(), depth: depth))<ambrosia-tree-region>]
  grid(rows: (row-height,) * (depth + 1), row-gutter: 0em,
    ..range(depth + 1).map(level => {
      let heading = model.path.find(h => h.level == level)
      let body = if level == 0 { title }
        else if heading == none { none } else { utils.short-heading(self: self, heading.source) }
      let destination = if level == 0 { if first == none { none } else { first.location() } }
        else if heading == none { none } else { heading.loc }
      let fill = color.mix((base, 100% - level * 22%), (self.page.fill, level * 22%))
      let ink = on-color(fill)
      block(width: 100%, height: row-height, above: 0em, below: 0em, clip: true,
        fill: fill, inset: (left: 1.5em + level * 0.6em, right: calc.max((1.5em).to-absolute(), self.store.at("header-fade-inset", default: 0pt)), y: 0.08em), {
          set text(size: 0.5em, fill: ink)
          let label = navigation-label(if body == none { [] } else { body }, lines: 1, background: fill)
          [#metadata((level: level, target: if destination == none { none } else { destination.page() },
            body: body, fill: fill, ink: ink))<ambrosia-tree-entry>]
          std.align(horizon, grid(columns: if level == 0 { (1fr,) } else { (0.9em, 1fr) },
            column-gutter: 0.3em, align: horizon,
            ..if level == 0 { () } else { (if destination == none { [] } else { hook(ink) },) },
            if destination == none { label } else { link(destination, label) }))
        })
    }))
})
