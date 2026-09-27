#let s = counter("_efilrst-counter")
#let counter-prefix = "_efilrst-"

// #let warn(body) = {
//   let my-message = [#(label(repr(body)))]
// }


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
  let n = counter-val - 1
  for (body, lbl) in childrenPairs {
    if type(body) == content {
      if type(lbl) == label {
        let num-text = if full {
          numbering(ref-style, ..numbers, n + 1)
        } else {
          numbering(ref-style, n + 1)
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
      if children.len() > 0 {
        children.last() += _make-children(
          body,
          1,
          ref-style,
          name,
          list-style,
          full,
          ref-joiner,
          numbers: numbers + (n,),
        )
      } else {
        panic("A nested list first needs an element")
      }
    }
  }

  return enum(numbering: list-style, start: counter-val, full: full, ..children)
}

/// Creates a referenceable list. Each element can be given an optional label so
/// that it can be referenced elsewhere in the document with `@label` (together
/// with `#show ref: efilrst.show-rule`).
///
/// - children (content, label, array): Elements that will be part of the list.
///   They can be given as a `content` followed by a `label` to reference them.
///   If the `label` is not provided, the element cannot be referenced. If an
///   array is provided (e.g., `([Content], <label1>, [Content], <label2>)`), the
///   elements will be part of a sublist. Sublists can be nested but they will
///   always require at least one parent element where the sublist will be
///   attached to.
/// - name (str): Name of the list. This will be used in the list reference. If no name
///   is provided, only the number will be shown in the reference. E.g., for a reference
///   named `Constraint` and a reference `C1` it generates `[Constraint~C1]` if the default
///   `ref-joiner` is used, and `[Constraint C1]` if `ref-joiner: none` is used.
/// - list-style (str, function): Style of the list. It will be used to generate
///   the list numbers, following Typst's `numbering` conventions.
/// - ref-style (str, function): Style of the references. It will be used to
///   generate the numbers of the references, following Typst's `numbering`
///   conventions.
/// - counter-name (str, auto): Name of the counter that will be used to generate
///   the numbers. If `auto` is provided, `efilrst` will choose a non-colliding
///   name. If a name is provided and is the same as the name of a previous list,
///   the counter will continue from the last number of the previous list.
/// - start (int): Number from which the list will start.
/// - full (bool): If `true`, the full reference (including the numbers of the
///   parent lists for nested elements) will be shown. If `false`, only the
///   element's own number will be shown.
/// - ref-joiner (symbol, str, none): Symbol used to join the name of the
///   reference and the reference itself. By default, a non-breaking space is
///   added to mimic the default behaviour of Typst for references. E.g., for a
///   reference named `Constraint` and a reference `C1` it generates
///   `[Constraint~C1]`. To disable it, pass `none`.
/// -> content
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

    let counter-increase = 0

    for (body, lbl) in childrenPairs {
      if type(body) != array {
        counter-increase += 1
      }
    }

    c.update(counter-val + counter-increase)
  }
)


#let show-rule(it) = {
  if (
    it.element != none
      and it.element.func() == metadata
      and type(it.element.value) == dictionary
      and it.element.value.at("efilrst-type", default: none) == "efilrst"
  ) {
    let itv = it.element.value
    let sup = if (it.supplement != auto) {
      [#it.supplement]
    } else {
      [#itv.efilrst-name]
    }

    if sup == [] {
      sup = [#itv.efilrst-n]
    } else {
      if itv.efilrst-joiner != none {
        sup = [#sup#itv.efilrst-joiner#itv.efilrst-n]
      } else {
        sup = [#sup #itv.efilrst-n]
      }
    }

    link(it.element.location(), sup)
  } else {
    it
  }
}



