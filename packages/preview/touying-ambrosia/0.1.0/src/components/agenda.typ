#import "../touying.typ": utils
#import "../utils/visibility.typ": is-covered

#let _key(hd) = (hd.level, hd.body, hd.numbering, hd.slide)
#let _headings(selector-filter, depth: 9999, focus-level: none, neighbors: 1) = {
  let headings = query(selector-filter(heading.where(outlined: true)))
  if query(<ambrosia-covered>).len() > 0 { headings = headings.filter(hd => not is-covered(hd)) }
  if focus-level != none {
    let roots = ()
    let root-keys = ()
    for hd in headings.filter(hd => hd.level == focus-level) {
      let key = (hd.body, hd.numbering, utils.slide-counter.at(hd.location()))
      if key not in root-keys { root-keys.push(key); roots.push(hd) }
    }
    let current = roots.enumerate().filter(pair => pair.last().location().page() <= here().page())
      .last(default: (0, none)).first()
    let root = roots.at(current, default: none)
    if root != none {
      let first = headings.position(hd => hd.location() == root.location())
      let next = roots.at(current + 1, default: none)
      let end = if next == none { headings.len() } else { headings.position(hd => hd.location() == next.location()) }
      let visible = headings.slice(first, end).map(hd => hd.location())
      visible += roots.slice(calc.max(0, current - neighbors), calc.min(roots.len(), current + 1 + neighbors))
        .map(hd => hd.location())
      headings = headings.filter(hd => hd.location() in visible)
    }
  }
  headings = headings.filter(hd => hd.level <= depth)
  let keys = ()
  let result = ()
  for hd in headings {
    let hd = (level: hd.level, body: hd.body, numbering: hd.numbering,
      loc: hd.location(), slide: utils.slide-counter.at(hd.location()),
      numbers: counter(heading).at(hd.location()), page: hd.location().page())
    let key = _key(hd)
    if key not in keys { keys.push(key); result.push(hd) }
  }
  result
}

#let _entry(self, hd, numbered: true, fill: none) = {
  let prefix = if numbered and hd.numbering != none {
    [#std.numbering(hd.numbering, ..hd.numbers)#h(0.3em)]
  } else { [] }
  let slide-number = hd.slide.first()
  let last-main = utils.last-slide-counter.final().first()
  // Appendix entries match the footer's appendix-numbering, including none.
  // Like the footer, a numbering function also receives the appendix total.
  let pattern = self.store.at("appendix-numbering", default: "i")
  let page-number = if slide-number <= last-main { str(slide-number) }
    else if type(pattern) == function and self.store.at("appendix-total", default: false) {
      std.numbering(pattern, slide-number - last-main, utils.slide-counter.final().first() - last-main)
    } else if pattern != none { std.numbering(pattern, slide-number - last-main) }
  let title = [#metadata((target: hd.page, slide: hd.slide.first(), level: hd.level))<ambrosia-agenda-entry>#prefix#hd.body]
  if page-number == none { return link(hd.loc, title) }
  let number = text(size: 0.7em, page-number)
  if fill == none {
    link(hd.loc, grid(columns: (1fr, auto), column-gutter: 0.7em, title, number))
  } else {
    link(hd.loc, [#title#h(0.35em)#box(width: 1fr, fill)#h(0.35em)#number])
  }
}

#let _rows(self, headings, fill: none, base-level: 1, numbered: true, focus: false, muted: false) = {
  set align(left)
  set par(justify: false, leading: 0.55em, spacing: 0.55em)
  for hd in headings {
    let root = hd.level == base-level
    let ink = if muted { self.colors.primary.transparentize(65%) } else { self.colors.primary }
    block(width: 100%, above: 0.35em, below: 0em,
      inset: (left: calc.max(0, hd.level - base-level) * 0.9em), {
        set text(fill: ink, size: if focus and root { 1.25em } else if muted { 0.85em } else { 1em },
          weight: if root { "bold" } else { "regular" })
        _entry(self, hd, numbered: numbered, fill: fill)
      },
    )
  }
}

// One measured rail owns every node and connector. Labels use a known cap
// edge, so nodes center on the first line even when a label wraps or grows.
#let _path(self, headings, fill: none, base-level: 1, numbered: true, focus: false, active: none) = layout(bounds => context {
  set align(left)
  set par(justify: false, leading: 0.4em, spacing: 0em)
  let rail = (0.65em).to-absolute()
  let gap = (0.55em).to-absolute()
  let padding = (0.28em).to-absolute()
  let x = rail / 2
  let rows = ()
  let y = 0pt
  for hd in headings {
    let root = hd.level == base-level
    let size = if focus and root { 1.25em } else { 1em }
    let weight = if root { "bold" } else { "regular" }
    let cap = measure(text(size: size, weight: weight,
      top-edge: "cap-height", bottom-edge: "baseline", [H])).height
    let label = block(width: bounds.width - rail - gap, above: 0em, below: 0em,
      inset: (left: calc.max(0, hd.level - base-level) * 0.9em), {
        set text(size: size, weight: weight, fill: self.colors.primary,
          top-edge: "cap-height", bottom-edge: "baseline")
        _entry(self, hd, numbered: numbered, fill: fill)
      })
    let height = measure(label).height
    rows.push((hd: hd, body: label, y: y + padding, center: y + padding + cap / 2,
      radius: (if root { 0.22em } else { 0.13em }).to-absolute(), cap: cap))
    y += height + 2 * padding
  }
  block(width: bounds.width, height: y, breakable: false, above: 0em, below: 0em, {
    for (i, row) in rows.enumerate() {
      let next = rows.at(i + 1, default: none)
      if next != none {
        let start = row.center + row.radius
        let end = next.center - next.radius
        place(top + left, dx: x, dy: start, {
          [#metadata((length: (end - start).pt()))<ambrosia-agenda-path-spine>]
          line(end: (0pt, end - start), stroke: 0.08em + self.colors.border)
        })
      }
      place(top + left, dx: rail + gap, dy: row.y, row.body)
      place(top + left, dx: x - row.radius, dy: row.center - row.radius,
        link(row.hd.loc, box(width: row.radius * 2, height: row.radius * 2, {
          [#metadata((radius: row.radius.pt(), cap: row.cap.pt(), target: row.hd.page))<ambrosia-agenda-path-node>]
          circle(radius: row.radius, fill: if row.hd.loc == active { self.colors.primary } else { none },
            stroke: 0.08em + self.colors.primary)
        })))
    }
  })
})

// Treatments consume the same selected heading records; selection, scope and
// fitting stay independent. Cards are intentionally for small agendas.
#let agenda-styles = ("list", "cards", "path")
#let _style(self, value, headings, base) = {
  let value = if value == auto { self.store.agenda-style } else { value }
  assert(value in agenda-styles, message: "Agenda style must be list, cards, or path.")
  let roots = headings.filter(hd => hd.level == base).len()
  if value == "cards" and (roots > 6 or headings.len() > 18) { "list" } else { value }
}

#let _branches(headings, base) = {
  let groups = ()
  for hd in headings {
    if hd.level == base or groups.len() == 0 { groups.push(()) }
    let i = groups.len() - 1
    groups.at(i).push(hd)
  }
  groups
}

#let _entries(self, headings, style, fill: none, base-level: 1, numbered: true, focus: false, active: none) = {
  if style == "list" or headings.len() == 0 {
    return _rows(self, headings, fill: fill, base-level: base-level, numbered: numbered, focus: focus)
  }
  if style == "path" {
    _path(self, headings, fill: fill, base-level: base-level, numbered: numbered, focus: focus, active: active)
  } else {
    let groups = _branches(headings, base-level)
    let columns = if groups.len() > 1 { 2 } else { 1 }
    grid(columns: (1fr,) * columns, gutter: 0.8em,
      ..groups.map(group => {
        let current = group.first().loc == active
        block(width: 100%, breakable: false,
          fill: if current { self.colors.surface-alt } else { self.colors.surface }, radius: 0.35em,
          stroke: 0.05em + if current { self.colors.primary } else { self.colors.border },
          inset: (x: 0.85em, y: 0.6em), {
            [#metadata((active: current))<ambrosia-agenda-card>]
            set text(size: 0.9em)
            _rows(self, group, fill: fill, base-level: base-level, numbered: numbered, focus: focus)
          })
      }))
  }
}

#let _omission(headings, fill) = {
  if headings.len() > 0 {
    set align(left)
    block(above: 0.45em, below: 0em, text(size: 0.7em, fill: fill,
      link(headings.first().loc, [#sym.dots.h.c +#headings.len()]),
    ))
  }
}

// Keep section introductions visually distinct from their heading list. Empty
// bodies still carry Touying metadata needed by heading/navigation queries.
#let _introduction(self, body, visible: false) = {
  if not visible { return body }
  v(0.5em)
  block(width: 100%, breakable: false, above: 0em, below: 0em,
    inset: (x: 0.65em, y: 0.45em),
    fill: self.colors.surface-alt,
    stroke: (left: 0.12em + self.colors.primary),
    radius: (top-right: 0.2em, bottom-right: 0.2em), {
      [#metadata(none)<ambrosia-agenda-introduction>]
      set align(left)
      set text(size: 0.9em, fill: self.colors.foreground)
      set par(justify: false, leading: 0.45em, spacing: 0.45em)
      body
    })
}

#let _best-scale(height, available, minimum) = {
  if height(100%) <= available { return 100% }
  let low = minimum
  let high = 100%
  for _ in range(12) {
    let mid = (low + high) / 2
    if height(mid) <= available { low = mid } else { high = mid }
  }
  low
}

/// Fitted overview. Collapse depth before showing an explicitly marked window.
#let fitted-outline(self, style: auto, text-size: auto, fill: auto, depth: 1, level: none, numbered: true, min-scale: auto,
  start: auto, overflow: "window", selector-filter: sel => sel, body: [],
) = layout(bounds => context {
  let size = if text-size == auto { self.store.agenda-text-size } else { text-size }
  assert(type(size) == length and size.to-absolute() > 0pt,
    message: "Agenda text size must be a positive length.")
  let base-size = size.to-absolute()
  // Touying includes invisible headings, counters, and metadata in every body.
  // They must survive, but must not create an introduction panel or a spacer.
  let has-introduction = body != none and measure(body).height > 0pt
  let fill = if fill == auto { self.store.outline-fill } else { fill }
  assert(fill == none or type(fill) in (content, str), message: "Outline fill must be content or none.")
  let minimum = if min-scale == auto { self.store.outline-min-scale } else { min-scale }
  assert(0% < minimum and minimum <= 100%, message: "Outline minimum scale must be between 0% and 100%.")
  assert(depth >= 1, message: "Outline depth must be at least 1.")
  assert(start == auto or (type(start) == int and start >= 1), message: "Outline start must be a positive entry index or auto.")
  assert(overflow in ("window", "error"), message: "Outline overflow must be window or error.")
  let all = _headings(selector-filter, depth: depth).filter(hd => level == none or hd.level >= level)
  let base = if all.len() > 0 { calc.min(..all.map(hd => hd.level)) } else { 1 }
  let treatment = _style(self, style, all, base)
  // Resolve the current branch once, outside measurement. Per-candidate here()
  // queries would create unnecessary layout contexts during scale searches.
  let active = all.filter(hd => hd.level == base and hd.page <= here().page()).last(default: none)
  let active = if active == none { none } else { active.loc }
  let width = bounds.width * 86%
  let effective-depth = depth
  let choice = (selected: all, before: (), after: (), deeper: ())
  let render(choice, scale) = block(width: width, breakable: false, text(size: base-size * scale, {
    _omission(choice.before, self.colors.muted)
    _entries(self, choice.selected, treatment, fill: fill, base-level: base, numbered: numbered, active: active)
    _omission(choice.after + choice.deeper, self.colors.muted)
    _introduction(self, body, visible: has-introduction)
  }))
  let height(choice, scale) = measure(render(choice, scale)).height
  while height(choice, minimum) > bounds.height and effective-depth > base {
    effective-depth -= 1
    choice.selected = all.filter(hd => hd.level <= effective-depth)
    choice.deeper = all.filter(hd => hd.level > effective-depth)
  }
  let candidates = choice.selected
  let anchor = if start != auto { calc.min(start - 1, calc.max(0, candidates.len() - 1)) } else {
    let earlier = candidates.enumerate().filter(pair => pair.last().loc.page() <= here().page())
    if earlier.len() > 0 { earlier.last().first() } else { 0 }
  }
  // An explicit start creates a forward window; auto keeps the current entry in view.
  let window(count) = {
    let first = if start != auto { anchor } else { calc.max(0, calc.min(anchor - calc.floor(count / 2), candidates.len() - count)) }
    let end = calc.min(first + count, candidates.len())
    choice + (before: candidates.slice(0, first), after: candidates.slice(end), selected: candidates.slice(first, end))
  }
  if start != auto { choice = window(candidates.len()) }
  if height(choice, minimum) > bounds.height {
    assert(overflow != "error", message: "Outline is too dense at the minimum scale. Reduce depth, use a window, or lower outline-min-scale.")
    let low = 1
    let high = candidates.len()
    choice = window(low)
    assert(height(choice, minimum) <= bounds.height,
      message: "Outline entry or extra content is too tall. Shorten it or lower outline-min-scale.")
    while low < high {
      let mid = calc.ceil((low + high) / 2)
      choice = window(mid)
      if height(choice, minimum) <= bounds.height { low = mid } else { high = mid - 1 }
    }
    choice = window(low)
  }
  let chosen = _best-scale(scale => height(choice, scale), bounds.height, minimum)
  block(width: bounds.width, height: bounds.height, breakable: false, {
    [#metadata((kind: "outline", style: treatment, requested-style: if style == auto { self.store.agenda-style } else { style }, scale: chosen / 100%, depth: effective-depth,
      text-size: base-size.pt(), introduction: has-introduction,
      shown: choice.selected.len(), total: all.len(), omitted: choice.before.len() + choice.after.len() + choice.deeper.len(),
      available: bounds.height.pt(), height: height(choice, chosen).pt(), columns: if treatment == "cards" and _branches(choice.selected, base).len() > 1 { 2 } else { 1 }))<ambrosia-agenda-fit>]
    place(center + horizon, render(choice, chosen))
  })
})

/// Center the current branch, fading only immediate neighbors. Never paginate implicitly.
#let focused-outline(self, style: auto, text-size: auto, fill: auto, depth: 3, level: 1, numbered: true, min-scale: auto,
  neighbors: 1, selector-filter: sel => sel, body: [],
) = layout(bounds => context {
  let size = if text-size == auto { self.store.agenda-text-size } else { text-size }
  assert(type(size) == length and size.to-absolute() > 0pt,
    message: "Agenda text size must be a positive length.")
  let base-size = size.to-absolute()
  // Touying includes invisible headings, counters, and metadata in every body.
  // They must survive, but must not create an introduction panel or a spacer.
  let has-introduction = body != none and measure(body).height > 0pt
  let fill = if fill == auto { self.store.outline-fill } else { fill }
  assert(fill == none or type(fill) in (content, str), message: "Outline fill must be content or none.")
  let minimum = if min-scale == auto { self.store.outline-min-scale } else { min-scale }
  assert(0% < minimum and minimum <= 100%, message: "Outline minimum scale must be between 0% and 100%.")
  assert(depth >= level and level >= 1, message: "Section outline depth must include its section level.")
  assert(type(neighbors) == int and neighbors >= 0 and neighbors <= 2, message: "Outline neighbors must be 0, 1, or 2.")
  let all = _headings(selector-filter, depth: depth, focus-level: level, neighbors: neighbors)
  let roots = all.filter(hd => hd.level == level)
  let current = roots.enumerate().filter(pair => pair.last().loc.page() <= here().page())
    .last(default: (0, none)).first()
  let root = roots.at(current, default: none)
  let first = if root != none { all.position(hd => _key(hd) == _key(root)) } else { 0 }
  let next = roots.at(current + 1, default: none)
  let end = if next != none { all.position(hd => _key(hd) == _key(next)) } else { all.len() }
  let branch = all.slice(first, end).filter(hd => hd.level <= depth)
  let choice = (selected: branch, omitted: (),
    before: roots.slice(calc.max(0, current - neighbors), current),
    after: roots.slice(calc.min(current + 1, roots.len()), calc.min(current + 1 + neighbors, roots.len())))
  let treatment = _style(self, style, branch, level)
  let width = bounds.width * 86%
  let scaled(scale, content) = block(width: width, breakable: false, text(size: base-size * scale, content))
  let main(choice, scale) = scaled(scale, {
    _entries(self, choice.selected, treatment, fill: fill, base-level: level, numbered: numbered, focus: true, active: if root == none { none } else { root.loc })
    _omission(choice.omitted, self.colors.muted)
    _introduction(self, body, visible: has-introduction)
  })
  let previous(choice, scale) = scaled(scale, _rows(self, choice.before, fill: fill, base-level: level, numbered: numbered, muted: true))
  let following(choice, scale) = scaled(scale, _rows(self, choice.after, fill: fill, base-level: level, numbered: numbered, muted: true))
  let dimensions(choice, scale) = {
    let middle = measure(main(choice, scale)).height
    let top = if choice.before.len() > 0 { measure(previous(choice, scale)).height + base-size * scale * 0.55 } else { 0pt }
    let bottom = if choice.after.len() > 0 { measure(following(choice, scale)).height + base-size * scale * 0.55 } else { 0pt }
    (main: middle, before: top, after: bottom, total: middle + 2 * calc.max(top, bottom))
  }
  let height(choice, scale) = dimensions(choice, scale).total
  // Preserve expanded current content before giving space to its neighbors.
  if height(choice, minimum) > bounds.height { choice.before = (); choice.after = () }
  let effective-depth = depth
  while height(choice, minimum) > bounds.height and effective-depth > level + 1 {
    effective-depth -= 1
    choice.selected = branch.filter(hd => hd.level <= effective-depth)
    choice.omitted = branch.filter(hd => hd.level > effective-depth)
  }
  if height(choice, minimum) > bounds.height {
    let candidates = choice.selected
    let deeper = choice.omitted
    let window(count) = {
      choice + (selected: candidates.slice(0, count), omitted: candidates.slice(count) + deeper)
    }
    let low = calc.min(1, candidates.len())
    let high = candidates.len()
    choice = window(low)
    assert(height(choice, minimum) <= bounds.height,
      message: "Section heading or introduction is too tall. Shorten it or lower outline-min-scale.")
    while low < high {
      let mid = calc.ceil((low + high) / 2)
      choice = window(mid)
      if height(choice, minimum) <= bounds.height { low = mid } else { high = mid - 1 }
    }
    choice = window(low)
  }
  let chosen = _best-scale(scale => height(choice, scale), bounds.height, minimum)
  let dim = dimensions(choice, chosen)
  let y = (bounds.height - dim.main) / 2
  block(width: bounds.width, height: bounds.height, breakable: false, {
    [#metadata((kind: "section", style: treatment, requested-style: if style == auto { self.store.agenda-style } else { style }, scale: chosen / 100%, depth: effective-depth,
      text-size: base-size.pt(), introduction: has-introduction, main-height: dim.main.pt(),
      shown: choice.selected.len(), total: branch.len(), omitted: choice.omitted.len(),
      neighbors: choice.before.len() + choice.after.len(), current: if root == none { none } else { root.body },
      available: bounds.height.pt(), height: dim.total.pt(), columns: 1,
      focus-center: (y + dim.main / 2).pt()))<ambrosia-agenda-fit>]
    if choice.before.len() > 0 { place(top + center, dy: y - dim.before, previous(choice, chosen)) }
    place(top + center, dy: y, main(choice, chosen))
    if choice.after.len() > 0 { place(top + center, dy: y + dim.main + base-size * chosen * 0.55, following(choice, chosen)) }
  })
})
