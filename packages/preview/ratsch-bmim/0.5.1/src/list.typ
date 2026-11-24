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

// Enum numbering with the heading numbers as prefix, e.g. "2.3.1" for the
// first item in section 2.3; `depth` limits the prefix to the first levels.
// Meant for `wrapped-enum-numbering`: references with `enum-label` call it with
// `loc`, so the prefix is that of the item, not of the reference.
#let heading-prefix-numbering(depth: none, ..args, loc: none) = context {
  let hdr = counter(heading).at(if loc == none { here() } else { loc })
  if depth != none {
    hdr = (hdr + (0,) * depth).slice(0, depth)
  }
  (hdr + args.pos()).map(str).join(".")
}

#let wrapped-enum-numbering(numbering) = {
  let enum-numbering = (..it,) => {
    enum-numbering-state.update(x => numbering)
    enum-counter.update(it.pos())
    std.numbering(numbering, ..it)
  }
  enum-numbering
}

#let enum-show-ref(it, opts:none) = helpers.marked-ref(it, enum-label-mark, opts.spell.item, loc => {
  // the counter value in the numbering at the location of the item
  let num = enum-numbering-state.at(loc)
  if std.type(num) != str {
    num = num.with(loc:loc)
  }
  numbering(num, ..enum-counter.at(loc))
})
