#import "../touying.typ": utils
#import "../utils/navigation.typ": navigation-model, navigation-window
#import "structural-navigation.typ": navigation-label

// A section overview with local progress in each linked segment. The outer
// chrome supplies the height and surface, in either a footer or header row.
#let render-segments(self) = layout(bounds => context {
  let model = navigation-model()
  let roots = model.roots
  if roots.len() == 0 { return }
  let flavor = self.store.flavor-definition
  let primary = (flavor.navigation-primary)(self)
  let secondary = (flavor.navigation-secondary)(self)
  let capacity = calc.max(1, calc.floor(bounds.width / (7em).to-absolute()))
  let (start, visible) = navigation-window(roots, calc.max(0, model.root-index), capacity)
  let omission(destination, count, before: false) = link(destination,
    text(size: 0.55em, fill: secondary)[#if before { [‹] } else { [›] } +#count])
  let cells = ()
  if start > 0 { cells.push(omission(roots.at(start - 1).loc, start, before: true)) }
  for root in visible {
    let index = roots.position(h => h.loc == root.loc)
    let next-root = roots.at(index + 1, default: none)
    let slides = model.scoped-slides.filter(s => root.loc.page() <= s.location().page()
      and (next-root == none or s.location().page() < next-root.loc.page()))
    let done = slides.filter(s => s.location().page() <= here().page()).len()
    let active = index == model.root-index
    let progress = if slides.len() == 0 { if index < model.root-index { 100% } else { 0% } }
      else { done / slides.len() * 100% }
    let ink = if active { primary } else { secondary }
    cells.push(link(root.loc, {
      [#metadata((target: root.loc.page(), active: active, current: done, total: slides.len(),
        progress: progress / 100%))<ambrosia-segment-entry>]
      grid(rows: (0.75em, 0.16em), row-gutter: 0.12em, align: left + horizon,
        text(size: 0.6em, fill: ink, weight: if active { "semibold" } else { "regular" },
          navigation-label(utils.short-heading(self: self, root.source), lines: 1)),
        block(width: 100%, height: 100%, radius: 0.08em, clip: true,
          fill: secondary.transparentize(70%),
          place(left + top, rect(width: progress, height: 100%, fill: ink, stroke: none))))
    }))
  }
  let end = start + visible.len()
  if end < roots.len() { cells.push(omission(roots.at(end).loc, roots.len() - end)) }
  let columns = cells.enumerate().map(((i, _)) => if (start > 0 and i == 0)
    or (end < roots.len() and i == cells.len() - 1) { 2.5em } else { 1fr })
  [#metadata((start: start, shown: visible.len(), total: roots.len(), omitted: roots.len() - visible.len(),
    width: bounds.width.pt(), height: bounds.height.pt()))<ambrosia-segment-window>]
  grid(columns: columns, column-gutter: 0.5em, align: horizon, ..cells)
})
