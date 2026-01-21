// assert the element is of the given typ
#let assert-element(element, func) = {
  assert.eq(type(element), content, message: "element must be content, was " + repr(type(element)))
  assert.eq(element.func(), func, message: "element must be a " + repr(func))
}

// split a selector into a pair of selector and post filter
#let into-sel-filter-pair(sel) = {
  if type(sel) in (selector, function) {
    (selector(sel), (_, _) => true)
  } else if (
    type(sel) == array and sel.len() == 2
    and type(sel.at(0)) in (selector, function) and type(sel.at(1)) == function
  ) {
    let (sel, func) = sel
    (selector(sel), func)
  } else {
    panic("sel must be a selector or a selector and filter function")
  }
}

