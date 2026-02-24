#import "../renderer.typ": renderer
#import "../anchors.typ" as anchors
#import "cetz.typ" as cetz

// A debug renderer for cetz that draws the objects' anchors
#let debug = {
  let draw-anchors(obj, style) = {
    let len = style.at("length", default: {
      if obj("anchors").len() < 0 {
        0pt
      } else {
        let t = type(obj("anchors").values().at(0).x)
        if t == length { 1mm } else { 2 }
      }
    })
    for (key, anc) in obj("anchors") {
      let factor = if key == obj("active") { 1.5 } else { 1 }
      // normal
      cetz.draw.line(
        (anc.x, anc.y),
        (
          (anc.x + 2.5*factor*len*calc.cos(anc.rot+90deg)), 
          (anc.y + 2.5*factor*len*calc.sin(anc.rot+90deg))
        ),
        stroke: if "stroke" not in style { 
          1pt*factor + green
        } else if type(style.stroke) == stroke {
          style.stroke
        } else if type(style.stroke) == length {
          style.stroke + green
        } else if type(style.stroke) == color {
          style.stroke + 1pt*factor
        } else {
          1pt*factor + green
        }
      )
      cetz.draw.content((
        (anc.x + 3.5*factor*len*calc.cos(anc.rot+90deg)), 
        (anc.y + 3.5*factor*len*calc.sin(anc.rot+90deg))
      ), text(
        key, 
        size: style.at("size", default: 8pt) * factor, 
        fill: style.at("fill", default: black)
      ))
      // tangent
      cetz.draw.line(
        (anc.x, anc.y),
        (
          (anc.x + factor*len*calc.cos(anc.rot)), 
          (anc.y + factor*len*calc.sin(anc.rot))
        ),
        stroke: if "stroke" not in style { 
          1pt*factor + red
        } else if type(style.stroke) == stroke {
          style.stroke
        } else if type(style.stroke) == length {
          style.stroke + red
        } else if type(style.stroke) == color {
          style.stroke + 1pt*factor
        } else {
          1pt*factor + red
        }
      )
    }
  };

  renderer((
    rect: draw-anchors,
    circle: draw-anchors,
    incline: draw-anchors,
    arrow: draw-anchors,
    point: draw-anchors,
    rope: draw-anchors,
    polygon: draw-anchors,
    spring: draw-anchors,
    terrain: draw-anchors,
    trajectory: draw-anchors,
    axes: draw-anchors,
  ))
}