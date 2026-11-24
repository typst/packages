#import "sty.typ": heading-counters, styfigure, stymatheq
#import "counter.typ": generate-counter

#let _last(arr) = arr.at(arr.len() - 1)
#let _last-int(x) = if type(x) == int { x } else { _last(x) }

#let _figure-config(groups, kind, fallback) = {
  let config = fallback
  for group in groups {
    if group.kinds.contains(kind) { config = group }
  }
  config
}


#let freeze-counter-number(counter-name, depth: 2, outline: "1.1", loc: none) = context {
  let loc = if loc == none { here() } else { loc }
  let n = _last-int(counter(counter-name).at(loc))
  generate-counter(depth, n, outline, loc: loc)
}

#let install-counter-resets(counter-names, depth: 2, body) = {
  show heading.where(level: 1, outlined: true): it => {
    if depth == 2 or depth == 3 { for name in counter-names { counter(name).update(0) } }
    it
  }
  show heading.where(level: 2, outlined: true): it => {
    if depth == 3 { for name in counter-names { counter(name).update(0) } }
    it
  }
  body
}

#let _bn-guard = state("ratchet-guard", none)

#let _bn-cfg = state("ratchet-config", (
  fig-depth: 2,
  fig-outline: "1.1",
  fig-color: none,
  figure-groups: (),
  eq-depth: 2,
  eq-outline: "(1.1)",
  eq-color: none,
))

// Return the configured number of a figure kind at its own location.
// This is useful for custom figure renderers that need to place the number
// inside their body instead of using Typst's standard caption.
#let figure-number(kind, loc: none) = context {
  let loc = if loc == none { here() } else { loc }
  let cfg = _bn-cfg.at(loc)
  let fig = _figure-config(cfg.figure-groups, kind, (
    depth: cfg.fig-depth,
    outline: cfg.fig-outline,
    color: cfg.fig-color,
  ))
  let n = _last-int(counter(figure.where(kind: kind)).at(loc))
  generate-counter(fig.depth, n, fig.outline, loc: loc)
}

#let _resolve-supplement(r, el) = {
  if r.supplement == none or r.supplement == auto { [#el.supplement] } else if type(r.supplement) == function {
    r.supplement(el)
  } else { r.supplement }
}

#let fix-numbered-refs(body) = {
  let _paint(content, color) = if color == none { content } else { text(content, fill: color) }
  let _paintc(content, color) = if color == none { content } else { text(fill: color)[#content] }

  show ref: r => context {
    let el = r.element
    if el == none { return r }

    if el.has("numbering") and el.numbering == none { return r }

    let loc = el.location()
    let cfg = _bn-cfg.at(loc)

    if el.func() == math.equation {
      let n = _last-int(counter(math.equation).at(loc))
      let num = generate-counter(cfg.eq-depth, n, cfg.eq-outline, loc: loc)
      return link(loc, _paint(num, cfg.eq-color))
    }

    if el.func() == figure {
      let fig = _figure-config(cfg.figure-groups, el.kind, (
        depth: cfg.fig-depth,
        outline: cfg.fig-outline,
        color: cfg.fig-color,
      ))
      let n = _last-int(counter(figure.where(kind: el.kind)).at(loc))
      let num = generate-counter(fig.depth, n, fig.outline, loc: loc)
      let sup = _resolve-supplement(r, el)
      return link(loc, if sup == [] { _paint(num, fig.color) } else {
        _paintc([#sup #h(0.15em) #num], fig.color)
      })
    }
    r
  }
  body
}

#let fix-numbered-outline(body) = {
  let _paint(content, color) = if color == none { content } else { text(content, fill: color) }
  let _paintc(content, color) = if color == none { content } else { text(fill: color)[#content] }
  show outline.entry: it => context {
    let el = it.element
    if el == none {
      // fallback: keep default behavior
      return link(it.element.location(), it.indented(it.prefix(), it.inner()))
    }
    let loc = el.location()
    // If the element explicitly disabled numbering, keep default prefix.
    if el.has("numbering") and el.numbering == none {
      return link(loc, it.indented(it.prefix(), it.inner()))
    }
    // Fetch the config at the TARGET location (not at the outline page).
    let cfg = _bn-cfg.at(loc)
    // Fix equations inside outlines (equation list).
    if el.func() == math.equation {
      let n = _last-int(counter(math.equation).at(loc))
      let num = generate-counter(cfg.eq-depth, n, outline: cfg.eq-outline, loc: loc)
      let prefix = _paint(num, cfg.eq-color)
      return link(loc, it.indented(prefix, it.inner()))
    }
    // Fix figures inside outlines (list of figures / tables).
    if el.func() == figure {
      let fig = _figure-config(cfg.figure-groups, el.kind, (
        depth: cfg.fig-depth,
        outline: cfg.fig-outline,
        color: cfg.fig-color,
      ))
      let n = _last-int(counter(figure.where(kind: el.kind)).at(loc))
      let num = generate-counter(fig.depth, n, fig.outline, loc: loc)
      // Mimic outline.entry.prefix(): add supplement for figures.
      let sup = [#el.supplement]
      let prefix = if sup == [] { _paint(num, fig.color) } else {
        _paintc([#sup #h(0.15em) #num], fig.color)
      }
      return link(loc, it.indented(prefix, it.inner()))
    }
    // Headings / others: keep default.
    link(loc, it.indented(it.prefix(), it.inner()))
  }
  body
}


// One-stop wrapper (use as a show rule).
#let ratchet(
  // Heading backbone
  offset: 0,
  reset-figure-kinds: (image, table, raw),
  init: "rebase",
  // Formatting
  fig-depth: 2,
  fig-outline: "1.1",
  fig-color: none,
  // Additional independently configured figure kinds.
  // Each group is (kinds: (...), depth: int, outline: str/function, color: color/none).
  figure-groups: (),
  eq-depth: 2,
  eq-outline: "(1.1)",
  eq-color: none,
  body,
) = context {
  let all-figure-groups = ((
    kinds: reset-figure-kinds,
    depth: fig-depth,
    outline: fig-outline,
    color: fig-color,
  ),) + figure-groups

  // A wrapper's document location is stable across layout iterations and
  // uniquely identifies its configuration session.
  let session = here()

  // Anchor (guard + cfg) into the document flow, otherwise the updates can be skipped
  // during iterative layout / introspection passes.
  context {
    _bn-guard.update(session)
    _bn-cfg.update((
      fig-depth: fig-depth,
      fig-outline: fig-outline,
      fig-color: fig-color,
      figure-groups: all-figure-groups,
      eq-depth: eq-depth,
      eq-outline: eq-outline,
      eq-color: eq-color,
    ))
  }

  // Only the newest session at the current location should act.
  let active = () => _bn-guard.get() == session

  show: heading-counters.with(
    counter-depth: fig-depth,
    matheq-depth: eq-depth,
    offset: offset,
    reset-figure-kinds: reset-figure-kinds,
    figure-groups: all-figure-groups,
    active: active,
    init: init,
  )

  show: styfigure.with(
    counter-depth: fig-depth,
    fig-outline: fig-outline,
    figure-kinds: reset-figure-kinds,
    figure-groups: all-figure-groups,
  )

  show: stymatheq.with(
    counter-depth: eq-depth,
    eq-outline: eq-outline,
  )

  show: fix-numbered-refs
  show: fix-numbered-outline

  body
}
