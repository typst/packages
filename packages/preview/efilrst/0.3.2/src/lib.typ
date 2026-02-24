#let s = counter("_efilrst-counter")
#let counter-prefix = "_efilrst-"

#let _make-pairs(children) = {
  let childrenPairs = ()

  // Gather children in body-label pairs
  for (n, val) in children.enumerate() {
    if (type(val) == content) {
      childrenPairs.push((val, none))
    } else if (type(val) == label and n > 0) {
      let (body, lbl) = childrenPairs.last()
      childrenPairs.last() = (body, val)
    } else if (type(val) == array) {
      let body = _make-pairs(val)
      childrenPairs.push((body, none))
    }
  }

  return childrenPairs
}

#let _get-counter(counter-name, counter-prefix, start) = {
  let private-counter-name = ""
  if (counter-name == auto) {
    private-counter-name = counter-prefix + str(s.get().at(0))
  } else {
    private-counter-name = counter-prefix + counter-name
  }


  let c = counter(private-counter-name)
  let level = 0
  let counter-val = c.get().at(level)
  if counter-val == 0 {
    counter-val = start
  }
  return (c, counter-val)
}

#let _make-children(
  childrenPairs,
  counter-val,
  ref-style,
  name,
  list-style,
  full,
  ref-joiner,
  numbers: (),
) = {
  let children = ()
  let n = 0
  for (body, lbl) in childrenPairs {
    if type(body) == content {
      if type(lbl) == label {
        let num-text = if full {
          numbering(ref-style, ..numbers, counter-val + n)
        } else {
          numbering(ref-style, counter-val + n)
        }
        let m = metadata((efilrst-type: "efilrst", efilrst-n: num-text, efilrst-name: name, efilrst-joiner: ref-joiner))
        children.push([#body#m#lbl])
      } else {
        children.push([
          #body
        ])
      }
      n += 1
    } else if type(body) == array {
      if n > 0 {
        children.last() += _make-children(
          body,
          counter-val,
          ref-style,
          name,
          list-style,
          full,
          ref-joiner,
          numbers: numbers + (n,),
        )
      }
      else {
        panic("A nested list first needs an element")
      }
    }
  }

  return enum(numbering: list-style, start: counter-val, full: full, ..children)
}


#let reflist(
  ..children,
  name: "",
  list-style: "1.1.1)",
  ref-style: "1.1.1",
  counter-name: auto,
  start: 1,
  full: true,
  ref-joiner: sym.space.nobreak,
) = (
  context {
    let childrenPairs = _make-pairs(children.pos())
    let (c, counter-val) = _get-counter(counter-name, counter-prefix, start)

    // Insert a metadata to be labelled
    _make-children(
      childrenPairs,
      counter-val,
      ref-style,
      name,
      list-style,
      full,
      ref-joiner,
    )
    s.step()
    c.update(counter-val + childrenPairs.len())
  }
)


#let show-rule(it) = {
  if (
    it.element != none and it.element.func() == metadata and type(it.element.value) == dictionary and it
      .element
      .value
      .at("efilrst-type", default: none) == "efilrst"
  ) {
    let itv = it.element.value
    let sup = if (it.supplement != auto) {
      [#it.supplement]
    } else {
      [#itv.efilrst-name]
    }

    if itv.efilrst-joiner != none and sup != [] {
      sup = [#sup#itv.efilrst-joiner#itv.efilrst-n]
    } else {
      sup = [#sup #itv.efilrst-n]
    }

    link(it.element.location(), sup)
  } else {
    it
  }
}



