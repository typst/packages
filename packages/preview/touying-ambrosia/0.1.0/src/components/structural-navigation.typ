#import "../utils/navigation.typ": navigation-model
#import "../utils/layout.typ": call-or-display
#import "../navigation.typ": resolve-sidebar-style

// Bound rich labels to a line budget. Single-line labels never wrap; longer
// labels start at the top and clip with an ellipsis inside the reserved frame.
#let navigation-label(body, lines: 2, background: white, alignment: left) = layout(bounds => context {
  let cap = (lines * 1.2em).to-absolute()
  if lines == 1 {
    let natural = measure(box(body), width: 10000pt)
    let height = calc.min(natural.height, cap)
    let overflow = natural.width > bounds.width
    let ellipsis = box(sym.dots.h.c)
    let reserved = if overflow { measure(ellipsis).width + (0.15em).to-absolute() } else { 0pt }
    return block(width: bounds.width, height: height, breakable: false, clip: true, {
      set std.align(top + alignment)
      block(width: calc.max(0pt, bounds.width - reserved), height: height, above: 0em, below: 0em, clip: true,
        place(top + alignment, box(width: natural.width, body)))
      if overflow { place(top + right, ellipsis) }
    })
  }
  let natural = measure(block(width: bounds.width, body)).height
  block(width: bounds.width, height: calc.min(natural, cap), breakable: false, clip: true, {
    set std.align(top + alignment)
    body
    if natural > cap {
      place(bottom + right, box(fill: background, inset: (left: 0.2em), sym.dots.h.c))
    }
  })
})

#let render-sidebar(self) = layout(bounds => context {
  let definition = self.store.navigation-definition
  let model = navigation-model()
  let all = model.headings.filter(h => h.level <= definition.depth)
  let path = model.path.filter(h => h.level <= definition.depth)
  let current = path.last(default: none)
  let active = if current == none { none } else { current.loc }
  let root = model.root
  let first = if root == none { 0 } else { all.position(h => h.loc == root.loc) }
  let next-root = model.roots.at(model.root-index + 1, default: none)
  let end = if next-root == none { all.len() } else { all.position(h => h.loc == next-root.loc) }
  let branch = all.slice(first, end)
  let style = resolve-sidebar-style(self)
  let background = style.surface
  let ink = style.ink
  let muted = style.muted
  let choice = (selected: all, hidden: ())
  let render(choice) = {
    set text(size: 0.62em, fill: muted)
    set par(justify: false, leading: 0.3em, spacing: 0em)
    let before = choice.hidden.filter(h => active != none and h.loc.page() < active.page())
    let after = choice.hidden.filter(h => not before.any(other => other.loc == h.loc))
    let omission(items) = if items.len() > 0 {
      block(width: 100%, below: 0.3em,
        link(items.first().loc, text(fill: muted)[… +#(items.len())]))
    }
    omission(before)
    for hd in choice.selected {
      let on-path = path.any(h => h.loc == hd.loc)
      let selected = hd.loc == active
      block(width: 100%, above: 0em, below: 0.4em,
        inset: (left: calc.min(3, hd.level - 1) * 0.8em),
        text(fill: if on-path { ink } else { muted }, weight: if on-path { "semibold" } else { "regular" }, {
          [#metadata((target: hd.loc.page(), level: hd.level, active: selected,
            ancestor: on-path, body: hd.body))<ambrosia-sidebar-entry>]
          link(hd.loc, grid(columns: (0.8em, 1fr), gutter: 0.15em,
            if selected { text(fill: ink, sym.triangle.r.filled) } else { [] },
            navigation-label(hd.body, background: background)))
        }))
    }
    omission(after)
  }
  let height(choice) = measure(block(width: bounds.width, render(choice))).height
  if height(choice) > bounds.height {
    // Collapse inactive branches before removing any section context.
    choice.selected = all.filter(h => h.level == 1 or branch.any(b => b.loc == h.loc))
    choice.hidden = all.filter(h => not choice.selected.any(s => s.loc == h.loc))
  }
  if height(choice) > bounds.height {
    let candidates = choice.selected
    let anchor = if active == none { 0 } else { candidates.position(h => h.loc == active) }
    let anchor = if anchor == none { 0 } else { anchor }
    let window(count) = {
      let start = calc.max(0, calc.min(anchor - calc.floor(count / 2), candidates.len() - count))
      let selected = candidates.slice(start, calc.min(start + count, candidates.len()))
      // Keep the section label as context when the visible window is in children.
      if root != none and not selected.any(h => h.loc == root.loc) { selected = (root,) + selected }
      (selected: selected, hidden: all.filter(h => not selected.any(s => s.loc == h.loc)))
    }
    let low = 1
    let high = candidates.len()
    while low < high {
      let mid = calc.ceil((low + high) / 2)
      if height(window(mid)) <= bounds.height { low = mid } else { high = mid - 1 }
    }
    choice = window(low)
    assert(height(choice) <= bounds.height,
      message: "Sidebar navigation is too short for its current heading. Increase the available height or reduce navigation-depth.")
  }
  block(width: bounds.width, height: bounds.height, breakable: false, clip: true, {
    [#metadata((shown: choice.selected.len(), total: all.len(), omitted: choice.hidden.len(),
      available: bounds.height.pt(), height: height(choice).pt(), width: bounds.width.pt(),
      current: if current == none { none } else { current.body }))<ambrosia-sidebar-fit>]
    render(choice)
  })
})

// Breadcrumbs reuse the title slot; the ordinary deeper-heading subtitle is
// omitted by chrome so that the same hierarchy is not repeated twice.
#let render-breadcrumbs(self) = layout(bounds => context {
  let secondary = if type(text.fill) == color { text.fill.transparentize(25%) } else { self.colors.muted }
  let model = navigation-model()
  let path = model.path
  if self.store.breadcrumb-title != auto {
    path = path.filter(h => h.level < self.slide-level)
    let current = model.slides.at(model.slide-index, default: none)
    if current != none {
      path.push((body: call-or-display(self, self.store.breadcrumb-title), loc: current.location(), level: self.slide-level))
    }
  }
  let render(path) = {
    for (i, hd) in path.enumerate() {
      if i > 0 { text(size: 0.8em, fill: secondary)[#h(0.3em)›#h(0.3em)] }
      [#metadata((target: hd.loc.page(), level: hd.level))<ambrosia-breadcrumb>]
      link(hd.loc, hd.body)
    }
  }
  if path.len() == 0 { return call-or-display(self, self.store.title) }
  let background = (self.store.flavor-definition.header-background)(self)
  if path.len() > 1 and measure(box(render(path))).width > bounds.width {
    // Give the current heading its own width budget; a long ancestor cannot
    // push it beyond the right edge. Intermediate ancestors share one link.
    grid(columns: (1fr, auto, 2fr), gutter: 0.3em, align: horizon,
      navigation-label(render((path.first(),)), lines: 1, background: background),
      text(size: 0.8em, fill: secondary,
        if path.len() > 2 { link(path.at(-2).loc)[› ⋯ ›] } else { [›] }),
      navigation-label(render((path.last(),)), lines: 1, background: background))
  } else {
    navigation-label(render(path), lines: 1, background: background)
  }
})

#let render-section-progress(self) = context {
  let model = navigation-model()
  let slides = model.section-slides
  if slides.len() == 0 or model.root == none { return }
  let current = calc.max(1, slides.filter(it => it.location().page() <= here().page()).len())
  let fraction = current / slides.len()
  [#metadata((current: current, total: slides.len(), target: model.root.loc.page(),
    section: model.root.body))<ambrosia-section-progress>]
  block(width: 100%, height: 1.4em, inset: (x: 3em), {
    grid(columns: (1fr, auto), gutter: 0.8em, align: horizon,
      block(width: 100%, height: 0.16em, fill: self.colors.surface-alt, clip: true,
        place(left, rect(width: fraction * 100%, height: 0.16em, fill: self.colors.primary, stroke: none))),
      link(model.root.loc, text(size: 0.8em, fill: self.colors.muted)[#current / #(slides.len())]),
    )
  })
}
