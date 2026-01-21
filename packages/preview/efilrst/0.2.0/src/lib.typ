#let reflist(..children, name: "", list-style: "1)", ref-style: "1", counter-name: "list") = context {
  // Gather children in body-label pairs
  let childrenArray = children.pos()
  let childrenPairs = ()
  
  for (n, val) in childrenArray.enumerate() {
    if (type(val) == content) {
      childrenPairs.push((val, none))
    } else if (type(val) == label and n > 0) {
      let (body, lbl) = childrenPairs.last()
      childrenPairs.last() = (body, val)
    }
  }

  let private-counter-name = "_efilrst-" + counter-name

  let c = counter(private-counter-name)
  let counter-val = c.get().at(0)
  
  // Insert a metadata to be labelled
  let children = childrenPairs.enumerate().map(
    ((n, (body, lbl))) => if (type(lbl) == label) {
      let num-text = numbering(ref-style, counter-val+n+1)
      let m = metadata((reflist-type: "reflist", reflist-n: num-text, reflist-name: name))
      [#body#m#lbl]
    }
    else [
      #body
    ]
  )

  c.update(counter-val + childrenPairs.len())

  enum(numbering: list-style, start: counter-val + 1, ..children)
}


#let show-rule(it) = {
  if (it.element != none 
      and it.element.func() == metadata 
      and type(it.element.value) == dictionary 
      and it.element.value.at("reflist-type", default: none) == "reflist") {
    let itv = it.element.value
    let sup = if (it.supplement != auto) { it.supplement } else { itv.reflist-name }
    link(it.element.location(), [#sup #itv.reflist-n])
  } else {
    it
  }
}



