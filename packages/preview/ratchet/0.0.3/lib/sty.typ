#import "counter.typ": *

#let _style-figure-groups(groups, body) = {
  if groups.len() == 0 {
    body
  } else {
    let group = groups.first()
    let sels = group.kinds.map(k => figure.where(kind: k))
    if sels.len() > 0 {
      show selector.or(..sels): set figure(
        numbering: n => generate-counter(group.depth, n, group.outline),
      )
      _style-figure-groups(groups.slice(1), body)
    } else {
      _style-figure-groups(groups.slice(1), body)
    }
  }
}

#let styfigure(
  counter-depth: 2,
  fig-outline: "1.1",
  figure-kinds: (image, table, raw),
  figure-groups: none,
  body,
) = {
  let groups = if figure-groups == none { ((
    kinds: figure-kinds,
    depth: counter-depth,
    outline: fig-outline,
    color: none,
  ),) } else { figure-groups }
  _style-figure-groups(groups, body)
}

#let stymatheq(
  counter-depth: 2,
  eq-outline: "(1.1)",
  body,
) = {
  set math.equation(
    numbering: n => generate-counter(counter-depth, n, eq-outline),
  )
  set math.equation(supplement: [])
  show label("-"): set math.equation(numbering: none)
  body
}

#let heading-counters(
  counter-depth: 2,
  matheq-depth: 2,
  offset: 0,
  reset-figure-kinds: (image, table, raw),
  figure-groups: none,
  init: "rebase",
  active: none,
  body,
) = {
  let is-active = () => active == none or active()
  let groups = if figure-groups == none { ((
    kinds: reset-figure-kinds,
    depth: counter-depth,
    outline: "1.1",
    color: none,
  ),) } else { figure-groups }

  context {
    if is-active() {
      if init == "reset" {
        chap-counter.update((..) => (offset, 0, 0))
      } else if init == "rebase" {
        let h = counter(heading).get()
        chap-counter.update((..) => (
          h.at(0, default: 0) + offset,
          h.at(1, default: 0),
          h.at(2, default: 0),
        ))
      } else {
        // "keep": no-op
      }

      for group in groups {
        for k in group.kinds { counter(figure.where(kind: k)).update(0) }
      }
      counter(math.equation).update(0)
    }
  }

  show heading.where(level: 1, outlined: true): it => context {
    if not is-active() { it } else {
      if matheq-depth == 2 or matheq-depth == 3 { counter(math.equation).update(0) }
      for group in groups {
        if group.depth == 2 or group.depth == 3 {
          for k in group.kinds { counter(figure.where(kind: k)).update(0) }
        }
      }
      chap-counter.step(level: 1)
      chap-counter.update((x, ..y) => (x, 0, 0))
      it
    }
  }
  show heading.where(level: 2, outlined: true): it => context {
    if not is-active() { it } else {
      if matheq-depth == 3 { counter(math.equation).update(0) }
      for group in groups {
        if group.depth == 3 {
          for k in group.kinds { counter(figure.where(kind: k)).update(0) }
        }
      }
      chap-counter.step(level: 2)
      chap-counter.update((x, y, ..z) => (x, y, 0))
      it
    }
  }
  show heading.where(level: 3, outlined: true): it => context {
    if not is-active() { it } else {
      chap-counter.step(level: 3)
      it
    }
  }
  body
}
