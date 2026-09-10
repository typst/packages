// Reference rendering helpers.

#import "./settings.typ": environment-counter-names
#import "./counters.typ": heading-number-at


#let environment-ref(it) = context {
  let loc = it.element.location()
  let top-level-number = heading-number-at(loc, 1)

  let env-numbers = counter(figure.where(kind: it.element.kind)).at(loc)
  let env-number = if env-numbers.len() > 0 {
    env-numbers.first()
  } else {
    1
  }

  let displayed-number = if it.element.kind == "axiom" {
    [#env-number]
  } else {
    [#top-level-number.#env-number]
  }

  link(it.target)[#it.element.supplement~#displayed-number]
}

#let reference-rule(it) = {
  let is-env-ref = (
    it.form == "normal" and
    it.element != none and
    it.element.func() == figure and
    environment-counter-names.contains(it.element.kind)
  )

  if is-env-ref {
    environment-ref(it)
  } else {
    it
  }
}
