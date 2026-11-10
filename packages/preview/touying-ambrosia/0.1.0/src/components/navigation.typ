#import "../touying.typ": utils
#import "../utils/navigation.typ": navigation-model, navigation-window
#import "branding.typ": render-header-logo, header-logo-visible
#import "structural-navigation.typ": navigation-label

// Keep header navigation inside its declared row. Labels have one line, and
// crowded decks window around the current section/slide instead of wrapping.
#let render-header-navigation(self) = layout(bounds => context {
  let definition = self.store.flavor-definition
  let navigation = self.store.navigation-definition
  let model = navigation-model()
  let primary = (definition.navigation-primary)(self)
  let secondary = (definition.navigation-secondary)(self)
  let background = (definition.navigation-background)(self)
  let current-page = here().page()
  let roots = model.roots
  let logo = if navigation.kind == "tabs" and not definition.header-logo and header-logo-visible(self) {
    let logo-self = self
    logo-self.store.logo-background = if background == none { self.page.fill } else { background }
    render-header-logo(logo-self, bounds.height, bounds.width * 30%)
  } else { none }
  if roots.len() == 0 { return std.align(right + horizon, logo) }
  let current = calc.max(0, model.root-index)
  let count = calc.max(1, calc.floor(bounds.width / (6em).to-absolute()))
  let (start, visible) = navigation-window(roots, current, count)
  let omission(destination) = link(destination, text(size: 0.65em, fill: secondary)[…])
  let cells = ()
  if start > 0 { cells.push(omission(roots.at(start - 1).loc)) }
  for root in visible {
    let index = roots.position(h => h.loc == root.loc)
    let next-root = roots.at(index + 1, default: none)
    let active = index == model.root-index
    let ink = if active { primary } else { secondary }
    let label = text(size: 0.65em, fill: ink,
      link(root.loc, {
        [#metadata((target: root.loc.page(), active: active))<ambrosia-header-section>]
        navigation-label(utils.short-heading(self: self, root.source), lines: 1, background: background)
      }))
    if navigation.kind == "tabs" {
      cells.push(label)
    } else {
      let slides = model.scoped-slides.filter(s => s.location().page() >= root.loc.page()
        and (next-root == none or s.location().page() < next-root.loc.page()))
      cells.push(grid(rows: (0.8em, 0.55em), row-gutter: 0.05em, align: left + horizon,
        label,
        layout(cell => context {
          set text(size: 0.5em, fill: ink)
          let capacity = calc.max(3, calc.floor(cell.width / (1em).to-absolute()))
          let active-slide = calc.max(0, slides.filter(s => s.location().page() <= current-page).len() - 1)
          let (offset, shown) = navigation-window(slides, active-slide, calc.max(1, capacity - 2))
          box({
            if offset > 0 { link(slides.at(offset - 1).location())[‹] }
            for s in shown {
              let current-slide = model.slides.at(model.slide-index, default: none)
              let selected = current-slide != none and s.location() == current-slide.location()
              [#metadata((target: s.location().page(), active: selected))<ambrosia-header-dot>]
              link(s.location(), if selected { sym.circle.filled } else { sym.circle })
            }
            if offset + shown.len() < slides.len() { link(slides.at(offset + shown.len()).location())[›] }
          })
        })))
    }
  }
  if start + visible.len() < roots.len() { cells.push(omission(roots.at(start + visible.len()).loc)) }
  let columns = cells.enumerate().map(((i, _)) => if (start > 0 and i == 0)
    or (start + visible.len() < roots.len() and i == cells.len() - 1) { 0.7em } else { 1fr })
  grid(columns: (1fr, auto), column-gutter: if logo == none { 0em } else { 0.5em }, align: horizon,
    grid(columns: columns, column-gutter: 0.6em, align: horizon, ..cells), logo)
})
