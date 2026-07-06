#let _loc_before(a, b) = {
  let pa = a.position()
  let pb = b.position()
  pa.page < pb.page or (pa.page == pb.page and pa.y < pb.y)
}

#let _THM_KINDS = ("definicion", "teorema", "corolario")

#let _local_n(key, loc) = {
  let last_sub = query(heading.where(level: 1).or(heading.where(level: 2))).filter(h => _loc_before(
    h.location(),
    loc,
  ))
  if last_sub.len() == 0 {
    counter(key).at(loc).first()
  } else {
    counter(key).at(loc).first() - counter(key).at(last_sub.last().location()).first() + 1
  }
}

#let _section_tag(loc) = {
  let h = counter(heading).at(loc)
  str(h.at(0, default: 0)) + "." + str(h.at(1, default: 0))
}

#let _thm_block(thm_kind, thm_supplement, body) = figure(
  kind: thm_kind,
  supplement: [#thm_supplement],
  caption: none,
  numbering: _ => "",
  block(breakable: false, context {
    counter("thm-" + thm_kind).step()
    let loc = here()
    let tag = _section_tag(loc) + "." + str(_local_n("thm-" + thm_kind, loc))
    [#metadata(tag) <thm-tag>*#thm_supplement #tag.* #body]
  }),
)

#let definicion(body) = _thm_block("definicion", "Definición", body)
#let teorema(body) = _thm_block("teorema", "Teorema", body)
#let corolario(body) = _thm_block("corolario", "Corolario", body)

#let sty-math(doc) = {
  show figure.where(kind: "definicion"): set align(left)
  show figure.where(kind: "teorema"): set align(left)
  show figure.where(kind: "corolario"): set align(left)

  set math.equation(numbering: "(1)")
  show math.equation.where(block: true): it => context {
    let loc = here()
    let tag = _section_tag(loc) + "." + str(_local_n("equation", loc))
    [#metadata(tag) <eq-tag>]
    grid(
      columns: (1fr, auto),
      align: (center, right),
      it.body, [(#tag)],
    )
  }
  show ref: it => {
    let el = it.element
    if el == none { return it }
    context {
      let loc = el.location()
      let prefix = _section_tag(loc)
      if el.func() == math.equation {
        link(loc)[Ecuación #prefix.#str(_local_n("equation", loc))]
      } else if el.func() == figure and el.kind in _THM_KINDS {
        link(loc)[#el.supplement #prefix.#str(_local_n("thm-" + el.kind, loc))]
      } else {
        it
      }
    }
  }
  doc
}
