#import "@preview/cetz:0.4.0"
#import cetz.draw: *
#import cetz.vector: *
#import "../utils/lib.typ": match-dict, resolve-stroke, part-linear-gradient
#import "resolve-connection.typ": resolve-connection

#let gap-correction = 2 * 10e-4
#let in-gap-correction = 2 * 10e-2%

#let start-cut-mark(pos) = (stroke: (paint: rgb(0, 0, 0, 0)), start: "+", scale: 0, pos: pos)
#let end-cut-mark(pos) = (stroke: (paint: rgb(0, 0, 0, 0)), end: "+", scale: 0, pos: pos)
#let draw-with-gradient(f, p1, p2, stroke: none, fill: none) = {
  return merge-path(
    mark(p1, p2, symbol: "+", scale: 0) + f + mark(p2, p1, symbol: "+", scale: 0),
    join: false,
    close: false,
    stroke: stroke,
    fill: fill,
  )
}
#let opacitize(grad, opacity, sample1, sample2) = {
  let transparentize = (100 - opacity) * 1%

  let new-grad = grad.stops()
  new-grad.insert(1, (grad.sample(sample1).transparentize(transparentize), 100% - sample1))
  new-grad.insert(2, (grad.sample(sample2).transparentize(transparentize), sample2))
  grad = gradient.linear(..new-grad)
  grad
}

#let draw-normal-bezier(node, c1, c2, gap) = {
  let p1 = c1.position
  let p2 = c2.position
  
  // control points of bezier ("inner")
  let i1 = add(p1, scale(c1.normal, node.style.connection-size * node.style.bezier-connection))
  let i2 = add(p2, scale(c2.normal, node.style.connection-size * node.style.bezier-connection))

  // close small gaps
  p1 = sub(p1, scale(c1.normal, gap-correction))
  p2 = sub(p2, scale(c2.normal, gap-correction))

  // angle between the connection points (useful for the color gradient)
  let d = sub(p2, p1)
  let angle = -calc.atan2(d.at(0), d.at(1))

  // calculate where to cut the curve
  let b1-cut = 50% + (node.style.bridge-space + node.style.bridge-offset) * 50% - in-gap-correction
  let b2-cut = 50% + (node.style.bridge-space - node.style.bridge-offset) * 50% - in-gap-correction
  let cut-pos = 50% + node.style.bridge-offset * 50%

  // get the stroke styles of the edges
  let stroke1 = c1.edge-style.stroke
  let stroke2 = c2.edge-style.stroke

  let grad = gradient.linear(stroke1.paint, stroke2.paint, angle: angle)

  if gap {
    let type = node.style.bridge-type

    if type == "gap" or type == none {

      draw-with-gradient({
        bezier(p1, p2, i1, i2, stroke: stroke1, mark: end-cut-mark(b1-cut))
      }, p1, p2, stroke: stroke1)

      draw-with-gradient({
        bezier(p1, p2, i1, i2, mark: start-cut-mark(b2-cut))
      }, p1, p2, stroke: stroke2)

    } else if type.find("opacity") != none {

      let opacity = if type == "opacity" { 50 } else { int(type.find(regex("\d+"))) }

      grad = opacitize(grad, opacity, b1-cut, b2-cut)
      
      draw-with-gradient({
          bezier(p1, p2, i1, i2, mark: end-cut-mark(50% - in-gap-correction))
      }, p1, p2, stroke: match-dict((paint: grad), stroke1))

      draw-with-gradient({
        bezier(p1, p2, i1, i2, mark: start-cut-mark(50% - in-gap-correction))
      }, p1, p2, stroke: match-dict((paint: grad), stroke2))

    } else if type.find("jump") != none or type.find("dive") != none {

      let is-jump = type.find("jump") != none
      let value = if type in ("jump", "dive") { 50 } else { int(type.find(regex("\d+"))) }

      hide(bezier( p1, p2, i1, i2, name: "b1"))
      hide(bezier( p1, p2, i1, i2, name: "b2"))

      anchor("p1", "b1." + str(int(100 - b1-cut / 1%)) + "%")
      anchor("p2", "b2." + str(int(b2-cut / 1%)) + "%")

      if value == 0 {
        line("p1", "p2", stroke: (paint: grad, cap: "round"))
      } else {
        group(ctx => {
          let (ctx, origin1) = cetz.coordinate.resolve(ctx, ("p1"))
          let (ctx, origin2) = cetz.coordinate.resolve(ctx, ("p2"))

          let d = dist(origin1, origin2)

          hide(line("p1", "p2", name: "p1-p2"))
          hide(circle("p1-p2.mid", radius: d * value / 100, name: "c"))
          if is-jump { anchor("m", "c.north") } else { anchor("m", "c.south") }
          hide(arc-through("p1", "m", "p2", name: "b"))

          draw-with-gradient({
            bezier(p1, p2, i1, i2, mark: end-cut-mark(b1-cut))
            arc-through("b.0%", "b.25%", "b." + str((50% + in-gap-correction) / 1%) + "%")
          }, p1, p2, stroke: match-dict((paint: grad), stroke1))

          draw-with-gradient({
            bezier(p1, p2, i1, i2, mark: start-cut-mark(b2-cut))
            arc-through("b." + str((50% - in-gap-correction) / 1%) + "%", "b.75%", "b.100%")
          }, p1, p2, stroke: match-dict((paint: grad), stroke2))

          draw-with-gradient({
            circle("p1", radius: stroke1.thickness / 2 / node.style.scale)
          }, p1, p2, fill: grad)

          draw-with-gradient({
            circle("p2", radius: stroke2.thickness / 2 / node.style.scale)
          }, p1, p2, fill: grad)
        })
      }


    }
  } else {
    draw-with-gradient({
      bezier(p1, p2, i1, i2, stroke: stroke1, mark: end-cut-mark(50% - in-gap-correction))
    }, p1, p2, stroke: match-dict((paint: grad), stroke1))

    draw-with-gradient({
      bezier(p1, p2, i1, i2, mark: start-cut-mark(50% - in-gap-correction))
    }, p1, p2, stroke: match-dict((paint: grad), stroke2))
  }
}

#let draw-connections(node) = {
  if node.connect == auto {
    if node.connection-points.len() == 0 {
      return
    } else if calc.rem(node.connection-points.len(), 2) == 0 {
      for i in range(node.connection-points.len(), step: 2) {
        draw-normal-bezier(node, node.connection-points.at(i), node.connection-points.at(i + 1), (node.style.bridge-type != none))
      }
    }
  } else {
    for (..args) in node.connect {
      let c1 = args.at(0)
      let c2 = args.at(1)
      let gap = if args.len() == 3 { args.at(2) } else { false }
      draw-normal-bezier(node, node.connection-points.at(c1), node.connection-points.at(c2), gap)
    }
  }
}