#let empty-box = box(height: 0pt, width: 0pt, inset: 0pt, outset: 0pt)

/// Place content at a specific location on the page relative to the top left corner
/// of the page, regardless of margins, current container, etc.
///
/// > This function comes from [typst-drafting](https://github.com/ntjess/typst-drafting), Thanks to [ntjess]((https://github.com/ntjess/).
///
/// - `dx`: [`length`] &mdash; Length in the x-axis relative to the left edge of the page.
/// - `dy`: [`length`] &mdash; Length in the y-axis relative to the top edge of the page.
/// - `body`: [`content`] &mdash; The content you want to place.
#let absolute-place(dx: 0em, dy: 0em, body) = {
  context {
    let pos = here().position()
    place(dx: -pos.x + dx, dy: -pos.y + dy, body)
  }
}

// -----------------------------------------------
// Core
// -----------------------------------------------

#let _pin-label(loc, name) = label("page-" + str(loc.position().page) + ":" + repr(name))

/// Pinning a pin in text, the pin is supposed to be unique in one page.
///
/// - `name`: [`integer` or `string` or `any`] &mdash; Name of pin, which can be any types with unique `repr()` return value, such as integer and string.
#let pin(name) = {
  context {
    [#empty-box#_pin-label(here(), name)]
  }
}

/// Query positions of pins in the same page, then call the callback function `func`.
///
/// - `callback`: [`(..positions) => { .. }`] &mdash; A callback function accepting an array of positions (or a single position) as a parameter. Each position is a dictionary like `(page: 1, x: 319.97pt, y: 86.66pt)`. You can use the `absolute-place` function in this callback function to display something around the pins.
/// - `..pins`: [`pin`] &mdash; Names of pins you want to query. It is supposed to be arguments composed with pin or a group of pins.
#let pinit(callback: none, ..pins) = {
  assert(callback != none, message: "The callback function is required.")
  assert(pins.named().len() == 0, message: "The pin names should not be named.")
  pins = pins.pos()
  context {
    let positions = ()
    for pin-group in pins {
      let poss = ()
      if type(pin-group) != array {
        pin-group = (pin-group,)
      }
      for pin-name in pin-group {
        let elems = query(
          selector(_pin-label(here(), pin-name)),
        )
        assert(elems.len() > 0, message: "Pin not found: " + repr(pin-name))
        poss.push(elems.at(0).location().position())
      }
      if poss.len() == 1 {
        positions.push(poss.at(0))
      } else {
        positions.push((
          page: poss.at(0).page,
          x: poss.map(p => p.x).sum() / poss.len(),
          y: poss.map(p => p.y).sum() / poss.len(),
        ))
      }
    }
    callback(..positions)
  }
}

/// Place content at a specific location on the page relative to the pin.
///
/// - `pin-name`: [`pin`] &mdash; Name of the pin to which you want to locate.
/// - `body`: [`content`] &mdash; The content you want to place.
/// - `dx`: [`length`] &mdash; Offset X relative to the pin.
/// - `dy`: [`length`] &mdash; Offset Y relative to the pin.
#let pinit-place(
  pin-name,
  body,
  dx: 0pt,
  dy: 0pt,
) = {
  pinit(
    pin-name,
    callback: pos => {
      absolute-place(dx: pos.x + dx, dy: pos.y + dy, body)
    },
  )
}

