// -----------------------------------------------
// Code from https://github.com/ntjess/typst-drafting
// -----------------------------------------------
#let _run-func-on-first-loc(func, label-name: "loc-tracker") = {
  // Some placements are determined by locations relative to a fixed point. However, typst
  // will automatically re-evaluate that computation several times, since the usage
  // of that computation will change where an element is placed (and therefore update its
  // location, and so on). Get around this with a state that only checks for the first
  // update, then ignores all subsequent updates
  let lbl = label(label-name)
  [#metadata(label-name)#lbl]
  locate(loc => {
    let use-loc = query(selector(lbl).before(loc), loc).last().location()
    func(use-loc)
  })
}

/// Place content at a specific location on the page relative to the top left corner
/// of the page, regardless of margins, current container, etc.
/// -> content
#let absolute-place(dx: 0em, dy: 0em, content) = {
  _run-func-on-first-loc(loc => {
    let pos = loc.position()
    place(dx: -pos.x + dx, dy: -pos.y + dy, content)
  })
}

// -----------------------------------------------
// Core
// -----------------------------------------------

#let _pin-label(loc, name) = label("page-" + str(loc.position().page) + ":" + repr(name))

#let pin(name) = {
  _run-func-on-first-loc((loc) => {
    [#metadata("pin-tracker")#_pin-label(loc, name)]
  })
}

#let pinit(pins, func) = {
  let is-single-arg = false
  if type(pins) != array {
    is-single-arg = true
    pins = (pins,)
  }
  _run-func-on-first-loc((loc) => {
    let positions = ()
    for pin-name in pins {
      let elems = query(
        selector(_pin-label(loc, pin-name)),
        loc,
      )
      if elems == () {
        return
      }
      positions.push(elems.at(0).location().position())
    }
    if (is-single-arg) {
      func(positions.at(0))
    } else {
      func(positions)
    }
  })
}


#let pinit-place(
  dx: 0pt,
  dy: 0pt,
  pin-name,
  body,
) = {
  pinit(pin-name, pos => {
    absolute-place(dx: pos.x  + dx, dy: pos.y + dy, body)
  })
}

