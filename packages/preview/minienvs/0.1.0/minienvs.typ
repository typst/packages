#let _counter_prefix = "minienvs:"
#let _current = state("minienvs:current", none)
#let _config = state("minienvs:config", (
  no-numbering: (
    proof: true,
  ),
  bbox: (:),
  head-style: (
    proof: it => [_#{it}_],
  ),
  transforms: (
    proof: it => [#it #h(1fr) $space qed$],
  )
))

#let _recognize(term_content) = {
  let _get_nth_bit(x, i) = {
    if x.has("children") {
      _get_nth_bit(x.children.at(i), i)
    } else {
      x
    }
  }
  let _split_head_tail(x) = {
    if x.has("children") {
      (x.children.at(0), x.children.slice(1, none).join([]))
    } else {
      (x, none)
    }
  }

  let (head, tail) = _split_head_tail(term_content)

  if not head.has("text") {
    return none
  }

  if tail == none {
    return (head.text, none)
  } else {
    (head.text, tail)
  }
}

// TODO hanging indent?
#let _minienv(term, config) = {
  let maybe_recognized = _recognize(term.term)
  if maybe_recognized == none {
    // TODO: just return a plain term, but without falling prey to infinite recursion
    // return term

    return [
      *#{term.term}* _#{term.description}_
    ]
  }
  let (head, tail) = maybe_recognized
  let kind = lower(head)

  let c = counter(_counter_prefix + kind)
  c.step()
  locate(loc => _current.update((head: head, count: c.at(loc))))

  let head-format = config.head-style.at(kind, default: it => [*#{it}*])

  block({
    head-format[#head]
    if not config.no-numbering.at(kind, default: false) {
      head-format[ #{c.display()}]
    }
    if tail != none {
      head-format[#tail]
    }
    head-format[.]
    _current.update(none)
    config.transforms.at(kind, default: it => [_#{it}_])([#{term.description}])
  }, width: 100%, ..config.bbox.at(kind, default: ()))
}

#let minienvs(doc, config: auto) = {
  if config != auto {
    // FIXME: dict update instead of overwrite
    _config.update(x => config)
  }

  show figure.where(kind: "minienv"): _ => []
  show terms: (ts => _config.display(c => ts.children.map(t => _minienv(t, c)).join([])))
  doc
}

#let envlabel(label) = locate(loc => _current.display(current => [
  #if current == none {
    panic("`envlabel` used out-of-place. Must be used within the head of a minienv")
  }
  #let relevant_counter = counter(figure.where(kind: "minienv"))
  #let saved_count = relevant_counter.at(loc)
  #relevant_counter.update((current.count.at(0) - 1, ..current.count.slice(1, none)))
  #figure([], gap: 0pt, placement: none, kind: "minienv", supplement: current.head)
  #label
  #relevant_counter.update(saved_count)
]))
