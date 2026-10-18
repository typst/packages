#import "../touying.typ": utils
#import "../utils/navigation.typ": navigation-model, navigation-window
#import "structural-navigation.typ": navigation-label

// Beamer's split family: select a section on the left and a subsection within
// the active section on the right. Both lists have independent bounded windows.
#let render-panes(self) = layout(bounds => context {
  let model = navigation-model()
  if model.roots.len() == 0 { return }
  let flavor = self.store.flavor-definition
  let primary = (flavor.navigation-primary)(self)
  let secondary = (flavor.navigation-secondary)(self)
  let root-index = calc.max(0, model.root-index)
  let root = model.roots.at(root-index)
  let next = model.roots.at(root-index + 1, default: none)
  let children = model.headings.filter(h => h.level == 2 and h.loc.page() >= root.loc.page()
    and (next == none or h.loc.page() < next.loc.page()))
  let current-child = model.path.find(h => h.level == 2)
  let pane(items, current, role) = layout(area => context {
    let row-height = (0.7em).to-absolute()
    let gap = (0.08em).to-absolute()
    let count = calc.max(1, calc.floor((area.height + gap) / (row-height + gap)))
    let index = if current == none { 0 } else { items.position(h => h.loc == current.loc) }
    let (start, visible) = navigation-window(items, if index == none { 0 } else { index }, count)
    let end = start + visible.len()
    [#metadata((pane: role, shown: visible.len(), total: items.len(), omitted: items.len() - visible.len(),
      root: root.loc.page(), width: area.width.pt(), height: area.height.pt()))<ambrosia-pane-window>]
    let rows = ()
    for (i, hd) in visible.enumerate() {
      let active = current != none and current.loc == hd.loc
      let ink = if active { primary } else { secondary }
      let omissions = {
        if i == 0 and start > 0 { link(items.at(start - 1).loc)[↑#start] }
        if i == visible.len() - 1 and end < items.len() {
          if i == 0 and start > 0 { h(0.3em) }
          link(items.at(end).loc)[↓#(items.len() - end)]
        }
      }
      rows.push(text(size: 0.6em, fill: ink, weight: if active { "semibold" } else { "regular" }, {
        [#metadata((pane: role, target: hd.loc.page(), active: active))<ambrosia-pane-entry>]
        grid(columns: (0.6em, 1fr, auto), column-gutter: 0.3em, align: horizon,
          if active { [›] } else { [] },
          link(hd.loc, navigation-label(utils.short-heading(self: self, hd.source), lines: 1)),
          text(size: 0.8em, fill: secondary, omissions))
      }))
    }
    if rows.len() == 0 { rows.push(text(size: 0.6em, fill: secondary)[—]) }
    block(width: 100%, height: 100%, clip: true, breakable: false,
      grid(rows: (row-height,) * rows.len(), row-gutter: gap, align: horizon, ..rows))
  })
  grid(columns: (1fr, 0.04em, 1fr), column-gutter: 0.8em,
    pane(model.roots, model.root, "sections"),
    block(width: 100%, height: 100%, fill: secondary.transparentize(70%)),
    pane(children, current-child, "subsections"))
})
