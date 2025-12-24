#import "../renderer.typ": renderer
#import "../anchors.typ" as anchors
#import "cetz.typ" as cetz

// The standard renderer for cetz
#let standard = {
  let draw-rect(obj, style) = {
    let style = (stroke: auto, fill: auto, radius: 0pt) + style

    let points = obj("anchors")
    let width = obj("data").width
    let height = obj("data").height

    // Convert the std.rect style dictionary into the cetz.draw.rect style dictionary  
    let cetz-radius = if type(style.radius) == dictionary {
      let priority-at(dict, ..options, default: none) = {
        let options = options.pos()
        for op in options {
          if op in dict {
            return dict.at(op)
          }
        }
        return default
      }      
      (
        north-east: priority-at(style.radius, "top-right", "top", "right", "rest", default: 0pt),
        north-west: priority-at(style.radius, "top-left", "left", "top", "rest", default: 0pt),
        south-east: priority-at(style.radius, "bottom-right", "right", "bottom", "rest", default: 0pt),
        south-west: priority-at(style.radius, "bottom-left", "left", "bottom", "rest", default: 0pt),
      )
    } else { style.radius }

    if type(style.stroke) != dictionary {
      // in this case we can use the normal cetz rectangle
      return cetz.draw.scope({
        cetz.draw.translate(x: points.c.x, y: points.c.y)
        cetz.draw.rotate(points.c.rot)
        cetz.draw.rect(
            (-width/2, -height/2), 
            (+width/2, +height/2),
            radius: cetz-radius,
            stroke: style.stroke, 
            fill: style.fill, 
        )
      })
    } else {
      // since the user wants control over the stroke at a side-per-side level
      // we need to use the std.rect instead (warning: can be affected by show rules!)
      return ctx => {
        let res = cetz.draw.group({
          cetz.draw.content(
            (points.c.x, points.c.y),
            rotate(-points.c.rot, std.rect(
              stroke: style.stroke, 
              fill: style.fill, 
              radius: style.radius,
              width: if type(width) == length { width } else { width * ctx.length }, 
              height: if type(height) == length { height } else { height * ctx.length },
              inset: 0pt,
              outset: 0pt,
            ), reflow: true)
          )
          // Hidden shape for correct intersections
          cetz.draw.hide(bounds: true, 
          cetz.draw.scope({
            cetz.draw.translate(x: points.c.x, y: points.c.y)
            cetz.draw.rotate(points.c.rot)
            cetz.draw.rect(
              (-width/2, -height/2), 
              (+width/2, +height/2),
              radius: cetz-radius,
            )
          }))
        }).at(0)(ctx)

        // Remove intersections with the content
        res.drawables.at(1).tags.push(cetz.drawable.TAG.mark)
        res.drawables.at(0).tags.push(cetz.drawable.TAG.mark)

        res
      }
    }

  }

  let draw-circle(obj, style) = {
    let style = (stroke: auto, fill: auto) + style
    
    let points = obj("anchors")
    cetz.draw.circle(stroke: style.stroke, fill: style.fill,
      (points.c.x, points.c.y), 
      radius: obj("data").radius
    )
  }
  
  let draw-incline(obj, style) = {
    let style = (stroke: auto, fill: auto) + style

    let points = obj("anchors")
    if obj("data").angle > 0deg {
      cetz.draw.line(close: true, stroke: style.stroke, fill: style.fill,
        (points.tr.x, points.tr.y),
        (points.tl.x, points.tl.y),
        (points.br.x, points.br.y),
      )
    } else {
      cetz.draw.line(close: true, stroke: style.stroke, fill: style.fill,
        (points.bl.x, points.bl.y),
        (points.lt.x, points.lt.y),
        (points.br.x, points.br.y),
      )
    }
  }
  
  let draw-arrow(obj, style) = {
    let paint = stroke(style.at("stroke", default: black)).paint
    let style = (
      stroke: auto, 
      mark: (end: "triangle", fill: if paint == auto { black } else { paint }),
    ) + style


    let points = obj("anchors")
    cetz.draw.line(stroke: style.stroke, mark: style.mark,
      (points.start.x, points.start.y),
      (points.end.x, points.end.y),
    )
  }
  
  let draw-point(obj, style) = {
    let style = (
      radius: if style.at("label", default: none) == none { 1 } else { 0 },
      stroke: none,
      fill: black, 
      align: center + horizon, 
      label: none,
      lx: 0 * obj().x,
      ly: 0 * obj().x,
    ) + style

    let align-to-cetz-anchor(align) = (
           if align in (left, left + horizon) { "west" }
      else if align in (right, right + horizon) { "east" }
      else if align in (center, center + horizon) { "center" }
      else if align in (top, top + center) { "north" }
      else if align in (horizon, horizon + center) { "center" }
      else if align in (bottom, bottom + center) { "south" }
      else if align == top + left { "north-west" }
      else if align == bottom + left { "south-west" }
      else if align == top + right { "north-east" }
      else if align == bottom + right { "south-east" }
      else { align }
    )

    let points = obj("anchors")
    cetz.draw.circle(stroke: style.stroke, fill: style.fill, radius: style.radius,
      (points.c.x, points.c.y)
    );

    if style.label != none {
      cetz.draw.content( 
        anchor: align-to-cetz-anchor(style.align), 
        angle: points.c.rot,
        (points.c.x + style.lx, points.c.y + style.ly), style.label
      )
    }
  }
  
  let draw-rope(obj, style) = {
    let style = (stroke: auto) + style

    let path = none

    let ancs = obj("anchors")
    let radii = obj("data").radii
    let count = obj("data").count

    let tip = none
    for i in range(0, count) {
      let id = str(i + 1)
      if tip == none {
        // This is the first point: 
        // position the tip and do nothing
        tip = ancs.at(id)
      } else if i == count - 1 or radii.at(id) == 0 {
        // This is the last point or this point has zero radius: 
        // draw to it and position the tip
        path += cetz.draw.line((tip.x, tip.y), (ancs.at(id).x, ancs.at(id).y))
        tip = ancs.at(id)
      } else if radii.at(id) != 0 {
        // This point has a finite radius:
        //  - draw a straight line from tip to in-point
        //  - draw an arc from in-point to out-point  
        //  - position the tip
        path += cetz.draw.line((tip.x, tip.y), (ancs.at(id + "i").x, ancs.at(id + "i").y))
        path += cetz.draw.arc-through(
          (ancs.at(id + "i").x, ancs.at(id + "i").y),
          (ancs.at(id + "m").x, ancs.at(id + "m").y),
          (ancs.at(id + "o").x, ancs.at(id + "o").y),
        )
        tip = ancs.at(id + "o")
      }    
    }

    return cetz.draw.merge-path(path, stroke: style.stroke)
  }

  let draw-polygon(obj, style) = {
    let style = (stroke: auto, fill: auto) + style
    
    let ancs = obj("anchors")
    return cetz.draw.line(close: true, stroke: style.stroke, fill: style.fill,
      ..for i in range(0, obj("data").count) {
        ((ancs.at(str(i + 1) + "i").x, ancs.at(str(i + 1) + "i").y), )
      }
    )
  }

  let draw-spring(obj, style) = {
    let style = (
      stroke: auto, 
      pitch: auto, // distance between windings
      n: auto, // number of windings
      pad: auto, // length of flat bit at the start and at the end
      radius: auto, // size of the windings
      curliness: 70%, // set to none for a zig-zag pattern
    ) + style

    if style.pitch == auto and style.n == auto {
      // Default to 10 revolutions
      style.n = 10
    } else if style.pitch != auto and style.n != auto {
      panic("At least one between `n` and `pitch` has to be set to `auto`, but neither is.")
    }

    // Choose a radius
    if style.radius == auto {
      if style.pitch != auto { style.radius = style.pitch }
      else if style.n != auto { style.radius = obj("data").length / style.n * 1.25 }
    }
    // Choose a padding
    if style.pad == auto { style.pad = style.radius * 0.6 }

    // Calculate space to cover with the zig-zag pattern
    let free = obj("data").length - style.pad*2

    // Calculate number of windings or pitch if necessary
    if style.pitch != auto {
      style.n = calc.floor(free / style.pitch)
      // Compensate with extra padding for non integer free/pitch ratios
      style.pad += (free - style.pitch*style.n) / 2
    } else {
      style.pitch = free / style.n
    }

    // Actually draw the string
    let ancs = obj("anchors")

    let u = (x: +calc.cos(ancs.start.rot), y: calc.sin(ancs.start.rot))
    let v = (x: -u.y, y: u.x)

    let padded-start = (x: ancs.start.x + u.x*style.pad, y: ancs.start.y + u.y*style.pad)
    let padded-end = (x: ancs.end.x - u.x*style.pad, y: ancs.end.y - u.y*style.pad)

    if style.curliness == none {
      return cetz.draw.line(stroke: style.stroke,
        // padding
        (ancs.start.x, ancs.start.y),
        (padded-start.x, padded-start.y),
        ..for i in range(0, style.n) {(
          // higher point
          (
            x: padded-start.x + style.pitch*i*u.x + style.pitch/4*u.x + style.radius*v.x, 
            y: padded-start.y + style.pitch*i*u.y + style.pitch/4*u.y + style.radius*v.y,
          ),      
          // lower point
          (
            x: padded-start.x + style.pitch*i*u.x + style.pitch*3/4*u.x - style.radius*v.x, 
            y: padded-start.y + style.pitch*i*u.y + style.pitch*3/4*u.y - style.radius*v.y,
          )
        )},
        // half down
        // padding
        (padded-end.x, padded-end.y),
        (ancs.end.x, ancs.end.y),
      )
    } else {
      let delta = (style.curliness/100% + 1)*style.pitch/2
      let transformed(x, y) = (padded-start.x + u.x * x + v.x * y, padded-start.y + u.y * x + v.y * y)
      return cetz.draw.merge-path({
        cetz.draw.line(
          (ancs.start.x, ancs.start.y),
          (padded-start.x, padded-start.y)
        )
        cetz.draw.bezier(
          transformed(0,0), 
          transformed(style.pitch/2, -style.radius),
          transformed(0, -style.radius)
        )
        for k in range(1, style.n) {
          cetz.draw.bezier(
            transformed(style.pitch*(k - 1/2),-style.radius), 
            transformed(style.pitch*(k      ), +style.radius), 
            transformed(style.pitch*(k - 1/2) + delta, -style.radius), 
            transformed(style.pitch*(k - 1/2) + delta, +style.radius)
          )
          cetz.draw.bezier(
            transformed(style.pitch*(k    ), +style.radius), 
            transformed(style.pitch*(k+1/2), -style.radius), 
            transformed(style.pitch*(k+1/2) - delta, +style.radius), 
            transformed(style.pitch*(k+1/2) - delta, -style.radius)
          )
        }
        cetz.draw.bezier(
          transformed(style.pitch*(style.n - 1/2), -style.radius), 
          transformed(style.pitch*(style.n      ), 0),
          transformed(style.pitch*(style.n      ), -style.radius),
        )
        cetz.draw.line(
          (padded-end.x, padded-end.y),
          (ancs.end.x, ancs.end.y),
        )
      })
    }
  }

  let draw-terrain(obj, style) = {
    let data = obj("data")
    let ancs = obj("anchors")
    
    let style = (epsilon: 0.5%, fill: auto, stroke: auto, smooth: true) + style
    style.epsilon = if type(style.epsilon) == ratio { 
      style.epsilon/100% * (data.range.last() - data.range.first()) 
    } else { style.epsilon }

    let element-function = if style.smooth { cetz.draw.hobby } else { cetz.draw.line }

    let x-values = {
      let x = data.range.first()
      let to-x(x) = if type(x) == ratio { 
        data.range.first() + (data.range.last() - data.range.first()) * x/100% 
      } else { x }
      (
        while x < data.range.last() { (x, ); x += style.epsilon } +
        (data.range.last(), ) +
        data.stops.values().map(to-x)
      ).sorted().dedup()
    }
    return cetz.draw.merge-path(close: true, stroke: style.stroke, fill: style.fill, {
      element-function(
        ..for x in x-values {
          let point = anchors.anchor(
            x*data.scale, 
            (data.fn)(x)*data.scale,
            0deg
          )
          point = anchors.pivot(point, (0*point.x,0*point.y), ancs.origin.rot)
          point = anchors.move(point, ancs.origin.x, ancs.origin.y)
          ((point.x, point.y), )
        },
      )
      cetz.draw.line(
        (ancs.end.x, ancs.end.y), 
        (ancs.br.x, ancs.br.y), 
        (ancs.bl.x, ancs.bl.y),
      )
    })
  }

  let draw-trajectory(obj, style) = {
    let data = obj("data")
    let ancs = obj("anchors")
    
    let style = (epsilon: 0.5%, stroke: auto, smooth: true) + style
    style.epsilon = if type(style.epsilon) == ratio { 
      style.epsilon/100% * (data.range.last() - data.range.first()) 
    } else { style.epsilon }

    let t-values = {
      let t = data.range.first()
      let to-t(t) = if type(t) == ratio { 
        data.range.first() + (data.range.last() - data.range.first()) * t/100% 
      } else { t }
      (
        while t < data.range.last() { (t, ); t += style.epsilon } +
        (data.range.last(), ) +
        data.stops.values().map(to-t)
      ).sorted().dedup()
    }

    let element-function = if style.smooth { cetz.draw.hobby } else { cetz.draw.line }
    return element-function(stroke: style.stroke,
      ..for t in t-values {
        let fn-t = (data.fn)(t)
        let point = anchors.anchor(
          fn-t.at(0)*data.scale,
          fn-t.at(1)*data.scale,
          0deg
        )
        point = anchors.pivot(point, (0*point.x,0*point.y), ancs.origin.rot)
        point = anchors.move(point, ancs.origin.x, ancs.origin.y)
        ((point.x, point.y), )
      }
    )
  }

  let draw-axes(obj, style) = {
    let style = (stroke: 1pt, mark: none) + style
    let ancs = obj("anchors")

    return cetz.draw.group({
      if "x-" in ancs or "x+" in ancs {
        cetz.draw.line(
          stroke: style.at("xstroke", default: style.stroke),
          mark: style.at("xmark", default: style.mark),
          (ancs.at("x-", default: ancs.at("c")).x, ancs.at("x-", default: ancs.at("c")).y),
          (ancs.at("x+", default: ancs.at("c")).x, ancs.at("x+", default: ancs.at("c")).y),
        )
      }
      if "y-" in ancs or "y+" in ancs {
        cetz.draw.line(
          stroke: style.at("ystroke", default: style.stroke),
          mark: style.at("ymark", default: style.mark),
          (ancs.at("y-", default: ancs.at("c")).x, ancs.at("y-", default: ancs.at("c")).y),
          (ancs.at("y+", default: ancs.at("c")).x, ancs.at("y+", default: ancs.at("c")).y),
        )
      }
    })
  }

  renderer((
    rect: draw-rect,
    circle: draw-circle,
    incline: draw-incline,
    arrow: draw-arrow,
    point: draw-point,
    rope: draw-rope,
    polygon: draw-polygon,
    spring: draw-spring,
    terrain: draw-terrain,
    trajectory: draw-trajectory,
    axes: draw-axes,
  ))
}