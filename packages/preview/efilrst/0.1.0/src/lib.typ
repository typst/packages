#let reflist(..children, name: "", list-style: "1)", ref-style: "1") = {
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
  
  // Insert a metadata to be labeled
  let children = childrenPairs.enumerate().map(
    ((n, (body, lbl))) => if (type(lbl) == label) {
      let num_text = numbering(ref-style, n+1)
      let m = metadata((reflist_type: "reflist", reflist_n: num_text, reflist_name: name))
      [#body#m#lbl]
    }
    else [
      #body
    ]
  )

  enum(numbering: list-style, ..children)
}


#let show-rule(it) = {
  if (it.element != none 
      and it.element.func() == metadata 
      and type(it.element.value) == dictionary 
      and it.element.value.at("reflist_type", default: none) == "reflist") {
    let itv = it.element.value
    let sup = if (it.supplement != auto) { it.supplement } else { itv.reflist_name }
    link(it.element.location(), [#sup #itv.reflist_n])
  } else {
    it
  }
}



