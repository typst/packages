#import "@preview/cetz:0.2.2": draw, coordinate
#import "ports.typ": add-ports, add-port
#import "../util.typ"

#let find-port(ports, id) = {
  for (side, side-ports) in ports {
    for (i, port) in side-ports.enumerate() {
      if port.id == id {
        return (side, i)
      }
    }
  }
  panic("Could not find port with id " + str(id))
}

#let default-draw-shape(id, tl, tr, br, bl, fill, stroke) = {
  return ({}, tl, tr, br, bl)
}

/// Draws an element
/// - draw-shape (function): Draw function
/// - x (number, dictionary): The x position (bottom-left corner).
///
///   If it is a dictionary, it should be in the format `(rel: number, to: str)`, where `rel` is the offset and `to` the base anchor
/// - y (number, dictionary): The y position (bottom-left corner).
///
///   If it is a dictionary, it should be in the format `(from: str, to: str)`, where `from` is the base anchor and `to` is the id of the port to align with the anchor
/// - w (number): Width of the element
/// - h (number): Height of the element
/// - name (none, str): Optional name of the block
/// - name-anchor (str): Anchor for the optional name
/// - ports (dictionary): Dictionary of ports. The keys are cardinal directions ("north", "east", "south" and/or "west"). The values are arrays of ports (dictionaries) with the following fields:
///   - `id` (`str`): (Required) Port id
///   - `name` (`str`): Optional name displayed *in* the block
///   - `clock` (`bool`): Whether it is a clock port (triangle symbol)
///   - `vertical` (`bool`): Whether the name should be drawn vertically
/// - ports-margins (dictionary): Dictionary of ports margins (used with automatic port placement). They keys are cardinal directions ("north", "east", "south", "west"). The values are tuples of (`<start>`, `<end>`) margins (numbers)
/// - fill (none, color): Fill color
/// - stroke (stroke): Border stroke
/// - id (str): The block id (for future reference)
/// - auto-ports (bool): Whether to use auto port placements or not. If false, `draw-shape` is responsible for adding the appropiate ports
/// - ports-y (dictionary): Dictionary of the ports y offsets (used with `auto-ports: false`)
/// - debug (dictionary): Dictionary of debug options.
///
///   Supported fields include:
///     - `ports`: if true, shows dots on all ports of the element
#let elmt(
  draw-shape: default-draw-shape,
  x: none,
  y: none,
  w: none,
  h: none,
  name: none,
  name-anchor: "center",
  ports: (:),
  ports-margins: (:),
  fill: none,
  stroke: black + 1pt,
  id: "",
  auto-ports: true,
  ports-y: (:),
  debug: (
    ports: false
  )
) = draw.get-ctx(ctx => {
  let width = w
  let height = h

  let x = x
  let y = y
  if x == none { panic("Parameter x must be set") }
  if y == none { panic("Parameter y must be set") }
  if w == none { panic("Parameter w must be set") }
  if h == none { panic("Parameter h must be set") }

  if (type(x) == dictionary) {
    let offset = x.rel
    let to = x.to
    let (ctx, to-pos) = coordinate.resolve(ctx, (rel: (offset, 0), to: to))
    x = to-pos.at(0)
  }
  
  if (type(y) == dictionary) {
    let from = y.from
    let to = y.to
    let (to-side, i) = find-port(ports, to)
    let margins = (0%, 0%)
    if to-side in ports-margins {
      margins = ports-margins.at(to-side)
    }
    let used-pct = 100% - margins.at(0) - margins.at(1)
    let used-height = height * used-pct / 100%
    let top-margin = height * margins.at(0) / 100%
    
    let dy = used-height * (i + 1) / (ports.at(to-side).len() + 1)

    if not auto-ports {
      top-margin = 0
      dy = ports-y.at(to)(height)
    }
    
    let (ctx, from-pos) = coordinate.resolve(ctx, from)
    y = from-pos.at(1) + dy - height + top-margin
  }

  let tl = (x, y + height)
  let tr = (x + width, y + height)
  let br = (x + width, y)
  let bl = (x, y)

  // Workaround because CeTZ needs to have all draw functions in the body
  let func = {}
  (func, tl, tr, br, bl) = draw-shape(id, tl, tr, br, bl, fill, stroke)
  func

  if (name != none) {
    draw.content(
      (name: id, anchor: name-anchor),
      anchor: if name-anchor in util.valid-anchors {name-anchor} else {"center"},
      padding: 0.5em,
      align(center)[*#name*]
    )
  }

  if auto-ports {
    add-ports(
      id,
      tl, tr, br, bl,
      ports,
      ports-margins,
      debug: debug.ports
    )
  }
})