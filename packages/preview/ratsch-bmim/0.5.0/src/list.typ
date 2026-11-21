#import "helpers.typ"
#let enum-label-mark = metadata("bmim-enum-label")
#let enum-counter = counter("bmim-enum")
#let enum-numbering-state = state("bmim-enum-numbering", none)

#let enum-label(label) = {
  if type(label) == content {
    // informative error message
    assert(label.has("text"), message:
      "Argument 'label' of enum-label must be a string or plain text, " +
      "but was " + repr(label)
    )
    label = label.text
  }
  [#enum-label-mark#std.label(label)]
}

#let wrapped-enum-numbering(numbering) = {
  let enum-numbering = (..it,) => {
    enum-numbering-state.update(x => numbering)
    enum-counter.update(it.pos())
    std.numbering(numbering, ..it)
  }
  enum-numbering
}

#let enum-show-ref(it, opts:none) = {
  let el = it.element
  if el != none and el.func() == metadata and el == enum-label-mark {
    let supp = it.supplement
    if supp == auto {
      supp = opts.spell.item
    }
    // get the counter value in the correct format according to location
    let loc = el.location()
    let num = enum-numbering-state.at(loc)
    if std.type(num) != str {
      num = num.with(loc:loc)
    }
    let ref-counter = numbering(num, ..enum-counter.at(loc))
    if helpers.is-empty(supp) {
      link(el.location(), ref-counter)
    }
    else {
      link(el.location(), box([#supp~#ref-counter]))
    }
  } else {
    it
  }
}
