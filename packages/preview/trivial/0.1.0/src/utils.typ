#let global-prefix = "__trivial"
#let global-name(..args) = global-prefix + ":" + args.pos().join(":")

#let error(msg) = panic("trivial: " + msg)

#let append-qed(body, qed) = {
  if qed == none {
    return body
  }
  let qed = [#h(1fr)#qed]

  let (candidate, remainder) = if (
    body.has("children") and body.children.len() != 0
  ) {
    if body.children.last() == [ ] {
      body = body.children.slice(0, -1).join()
    }
    (body.children.last(), body.children.slice(0, -1).join())
  } else {
    (body, none)
  }

  context if (
    candidate.func() == math.equation
      and candidate.block
      and math.equation.numbering == none
  ) {
    remainder
    set math.equation(numbering: _ => qed, number-align: bottom)
    candidate
    counter(math.equation).update(i => i - 1)
  } else if candidate.func() in (enum.item, list.item) {
    remainder
    candidate.func()(append-qed(candidate.body, qed))
  } else {
    body
    qed
  }
}
