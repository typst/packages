#let equate-sub-numbering-state = state("equate/sub-numbering", false)

#let counting-symbols = "1aAiIαΑ一壹あいアイא가ㄱ*١۱१১ক①⓵"
#let non-counting = "[^" + counting-symbols + "]"
#let pattern = regex("^" + non-counting + "*(.*?)" + non-counting + "*$")

#let trim-numbering(s) = s.match(pattern).captures.at(0)

#let patch-numbering(the-numbering, ref: false) = {
  if the-numbering == none {
    none
  } else if type(the-numbering) == str {
    if ref {
      trim-numbering(the-numbering)
    } else {
      the-numbering
    }
  } else {
    the-numbering.with(ref: ref)
  }
}

#let my-numbering(the-numbering, ref: false, ..nums) = {
  numbering(patch-numbering(the-numbering, ref: ref), ..nums)
}

#let get-numbering(target, ref: false, location: none) = {
  if location == none {
    location = here()
  }
  patch-numbering(
    query(selector(target).before(location))
      .last(default: (numbering: none))
      .numbering,
    ref: ref,
  )
}

#let display-numbering(target, ref: false) = {
  let numbering = get-numbering(target, ref: ref)
  if numbering == none {
    return none
  }
  counter(target).display(numbering)
}

#let normal-figure = (
  figure
    .where(kind: image)
    .or(figure.where(kind: table))
    .or(figure.where(kind: raw))
)

#let outer-figure-counter-value() = (
  query(selector(normal-figure).before(here())).last().counter.get()
)

#let numera(level: 0) = it => {
  show heading: it => {
    if it.level <= level {
      counter(math.equation).update(0)
      counter(figure.where(kind: image)).update(0)
      counter(figure.where(kind: table)).update(0)
      counter(figure.where(kind: raw)).update(0)
    }
    it
  }

  show normal-figure: outer => {
    counter(figure.where(kind: "subfigure")).update(0)

    show figure.where(kind: "subfigure"): set figure(
      supplement: outer.supplement,
    )

    outer
  }

  // imitates default show rule but passes (ref: true) to numbering
  show ref: it => {
    if it.element == none or it.element.func() != math.equation { return it }
    let here = here()
    let location = it.element.location()
    assert(here != location)
    let rendered = counter(math.equation).display(
      patch-numbering(it.element.numbering, ref: true),
      at: location,
    )
    let result = if it.element.supplement == [] {
      rendered
    } else {
      [#it.element.supplement~#rendered]
    }
    link(location, result)
  }

  // imitates default show rule but passes (ref: true) to numbering
  show ref: it => {
    if it.element == none or it.element.func() != figure { return it }
    if it.element.kind not in (image, table, raw, "subfigure") { return it }
    let here = here()
    let location = it.element.location()
    assert(here != location)
    let rendered = it.element.counter.display(
      patch-numbering(it.element.numbering, ref: true),
      at: location,
    )
    let result = if it.element.supplement == [] {
      rendered
    } else {
      [#it.element.supplement~#rendered]
    }
    link(location, result)
  }

  // equate compatibility for (ref: true) and correct location context
  // TODO upstream the display(at: ) as that should already fix quite a bit.
  // or rather try refactoring upstream so the numbering function can retrieve this value.
  show ref: it => {
    if it.element == none { return it }
    if it.element.func() != figure { return it }
    if it.element.kind != math.equation { return it }
    if it.element.body == none { return it }
    if it.element.body.func() != metadata { return it }

    let nums = if equate-sub-numbering-state.at(it.element.location()) {
      it.element.body.value
    } else {
      (
        it.element.body.value.first()
          + it.element.body.value.slice(1).sum(default: 1)
          - 1,
      )
    }

    assert(
      it.element.numbering != none,
      message: "cannot reference equation without numbering.",
    )

    let here = here()
    let location = it.element.location()
    assert(here != location)
    let rendered = it.element.counter.display(
      (..) => numbering(
        patch-numbering(it.element.numbering, ref: true),
        ..nums,
      ),
      at: location,
    )
    let result = if it.element.supplement == [] {
      rendered
    } else {
      [#it.element.supplement~#rendered]
    }
    link(location, result)
  }

  it
}
