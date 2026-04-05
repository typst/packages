#import "@preview/cetz:0.2.2": draw, coordinate
#import "../ports.typ": add-ports, add-port
#import "../element.typ"

#let default-draw-shape(id, tl, tr, br, bl, fill, stroke) = {
  let f = {draw.rect(tl, br, fill: fill, stroke: stroke)}
  return (f, tl, tr, br, bl)
}


/// Draws a logic gate. This function is also available as `element.gate()`
///
/// - draw-shape (function): see #doc-ref("element.elmt")
/// - x (number, dictionary): see #doc-ref("element.elmt")
/// - y (number, dictionary): see #doc-ref("element.elmt")
/// - w (number): see #doc-ref("element.elmt")
/// - h (number): see #doc-ref("element.elmt")
/// - inputs (int): The number of inputs
/// - fill (none, color): see #doc-ref("element.elmt")
/// - stroke (stroke): see #doc-ref("element.elmt")
/// - id (str): see #doc-ref("element.elmt")
/// - inverted (str, array): Either "all" or an array of port ids to display as inverted
/// - inverted-radius (number): The radius of inverted ports dot
/// - debug (dictionary): see #doc-ref("element.elmt")
#let gate(
  draw-shape: default-draw-shape,
  x: none,
  y: none,
  w: none,
  h: none,
  inputs: 2,
  fill: none,
  stroke: black + 1pt,
  id: "",
  inverted: (),
  inverted-radius: 0.1,
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
    
    let dy
    if to == "out" {
      dy = height / 2
    } else {
      dy = height * (i + 0.5) / inputs
    }
    
    let (ctx, from-pos) = coordinate.resolve(ctx, from)
    y = from-pos.at(1) + dy - height
  }

  let tl = (x, y + height)
  let tr = (x + width, y + height)
  let br = (x + width, y)
  let bl = (x, y)

  // Workaround because CeTZ needs to have all draw functions in the body
  let func = {}
  (func, tl, tr, br, bl) = draw-shape(id, tl, tr, br, bl, fill, stroke)
  func

  let space = 100% / inputs
  for i in range(inputs) {
    let pct = (i + 0.5) * space
    let a = (tl, pct, bl)
    let b = (tr, pct, br)
    let int-name = id + "i" + str(i)
    draw.intersections(
      int-name,
      func,
      draw.hide(draw.line(a, b))
    )
    let port-name = "in" + str(i)
    let port-pos = int-name + ".0"
    if inverted == "all" or port-name in inverted {
      draw.circle(port-pos, radius: inverted-radius, anchor: "east", stroke: stroke)
      port-pos = (rel: (-2 * inverted-radius, 0), to: port-pos)
    }
    add-port(
      id, "west",
      (id: port-name), port-pos,
      debug: debug.ports
    )
  }

  let out-pos = id + ".east"
  if inverted == "all" or "out" in inverted {
    draw.circle(out-pos, radius: inverted-radius, anchor: "west", stroke: stroke)
    out-pos = (rel: (2 * inverted-radius, 0), to: out-pos)
  }
  add-port(
    id, "east",
    (id: "out"), out-pos,
    debug: debug.ports
  )
})