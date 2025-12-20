#import "sty.typ": heading-counters, styfigure, stymatheq
#import "counter.typ": generate-counter

#let _last(arr) = arr.at(arr.len() - 1)
#let _last-int(x) = if type(x) == int { x } else { _last(x) }


#let freeze-counter-number(counter-name, depth: 2, outline: "1.1", loc: none) = context {
  let loc = if loc == none { here() } else { loc }
  let n = _last-int(counter(counter-name).at(loc))
  generate-counter(depth, n, outline: outline, loc: loc)
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

#let _bn-epoch = state("better-numbering-epoch", 0)

#let _bn-guard = state("better-numbering-guard", 0)

#let _bn-cfg = state("better-numbering-config", (
  fig-depth: 2,
  fig-outline: "1.1",
  fig-color: none,
  eq-depth: 2,
  eq-outline: "1.1",
  eq-color: none,
))

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
      let inner = generate-counter(cfg.eq-depth, n, outline: cfg.eq-outline, loc: loc)
      return link(loc, _paint("(" + inner + ")", cfg.eq-color))
    }

    if el.func() == figure {
      let n = _last-int(counter(figure.where(kind: el.kind)).at(loc))
      let num = generate-counter(cfg.fig-depth, n, outline: cfg.fig-outline, loc: loc)
      let sup = _resolve-supplement(r, el)
      return link(loc, if sup == [] { _paint(num, cfg.fig-color) } else {
        _paintc([#sup #h(0.15em) #num], cfg.fig-color)
      })
    }
    r
  }
  body
}

// One-stop wrapper (use as a show rule).
#let better-numbering(
  // Heading backbone
  offset: 0,
  reset-figure-kinds: (image, table, raw),
  init: "rebase",
  // Formatting
  fig-depth: 2,
  fig-outline: "1.1",
  fig-color: none,
  eq-depth: 2,
  eq-outline: "1.1",
  eq-color: none,
  body,
) = context {
  // New session from this point onward.
  let session = _bn-epoch.get() + 1
  _bn-epoch.update(session)

  // Anchor (guard + cfg) into the document flow, otherwise the updates can be skipped
  // during iterative layout / introspection passes.
  hide(context {
    _bn-guard.update(session)
    _bn-cfg.update((
      fig_depth: fig-depth,
      fig_outline: fig-outline,
      fig_color: fig-color,
      eq_depth: eq-depth,
      eq_outline: eq-outline,
      eq_color: eq-color,
    ))
    ""
  })

  // Only the newest session at the current location should act.
  let active = () => _bn-guard.get() == session

  // Update config timeline from this point onward.
  _bn-cfg.update((
    fig-depth: fig-depth,
    fig-outline: fig-outline,
    fig-color: fig-color,
    eq-depth: eq-depth,
    eq-outline: eq-outline,
    eq-color: eq-color,
  ))

  show: heading-counters.with(
    counter-depth: fig-depth,
    matheq-depth: eq-depth,
    offset: offset,
    reset-figure-kinds: reset-figure-kinds,
    active: active,
    init: init,
  )

  show: styfigure.with(
    counter-depth: fig-depth,
    fig-outline: fig-outline,
    figure-kinds: reset-figure-kinds,
  )

  show: stymatheq.with(
    counter-depth: eq-depth,
    eq-outline: eq-outline,
  )

  show: fix-numbered-refs

  body
}
