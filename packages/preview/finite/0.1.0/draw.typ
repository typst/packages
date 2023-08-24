// imports cetz and t4t
#import "./util.typ": *

/// Draw a state at the given #arg[position].
#let state(position, name, label:auto, start:false, stop:false, anchor:"center", ..style) = {
  assert.no-pos(style)

  let style = style.named()
  if not is.dict(label) {
    style.insert("label", (text:label))
  } else {
    style.insert("label", label)
  }
  if "text" not in style.label or is.a(style.label.text) {
    style.label.insert("text", name)
  }
  if start == true {
    start = left
  }

  let t = coordinate.resolve-system(position)
  ((
    name: name,
    coordinates: (position, ),
    before: prepare-ctx,
    anchor: anchor,
    add-default-anchors: false,
    custom-anchors-ctx: (ctx, pos) => {
      let style = styles.resolve(ctx.style, style, root: "state")
      return (
        center: pos,
        left: vector.add(pos, (-style.radius, 0, 0)),
        right: vector.add(pos, (style.radius, 0, 0)),
        top: vector.add(pos, (0, style.radius, 0)),
        bottom: vector.add(pos, (0, -style.radius, 0)),
        top-left: vector.add(pos, vector-set-len((-1, 1), style.radius)),
        top-right: vector.add(pos, vector-set-len((1, 1), style.radius)),
        bottom-left: vector.add(pos, vector-set-len((-1, -1), style.radius)),
        bottom-right: vector.add(pos, vector-set-len((1, -1), style.radius)),
      )
    },
    render: (ctx, center) => {
      let style = styles.resolve(ctx.style, style, root: "state")
      let (rx, ry) = util.resolve-radius(style.radius).map(util.resolve-number.with(ctx))
      cmd.ellipse(..center, rx, ry, fill: style.fill, stroke: style.stroke)

      if not is.empty(label) {
        (draw.content(
          name + ".center",
          fit-content(
            ctx,
            rx*.9 * ctx.length, ry*.9 * ctx.length,
            style.label.text,
            size: style.label.size
          )
        ).first().render)(ctx, center, center)
      }

      // Mark state as final
      if stop {
        let thickness = util.resolve-number(ctx, get.stroke-thickness(style.stroke))
        cmd.ellipse(..center, (rx - thickness)*.9, (ry - thickness)*.9, fill: none, stroke: style.stroke)
      }

      // Draw arrow to mark start state
      if start != false {
        let s-end = vector.add(
          center,
          vector.scale(align-to-vec(start), rx)
        )
        let s-start = vector.add(
          s-end,
          vector.scale(align-to-vec(start), rx)
        )
        cmd.path(
          ("line", s-start, s-end),
          stroke: style.stroke
        )
        cmd.mark(
          vector.add(s-end, vector.scale(align-to-vec(start), ctx.style.mark.size)), s-end,
          ">",
          fill: get.stroke-paint(style.stroke),
          stroke: style.stroke
        )
      }
    }
  ),)
}

/// Draw a transition between two states.
///
/// The two states #arg[from] and #arg[to] have to be drawn first.
#let transition( from, to, label: none, ..style ) = {
  assert.no-pos(style)
  let style = style.named()

  assert.all-of-type("string", from, to)
  let name = from + "-" + to

  if is.not-empty(label) {
    if is.arr(label) {
      label = label.map(str).join(",")
    }
    if not is.dict(label) {
      style.insert("label", (text:label))
    } else {
      style.insert("label", label)
    }
  }

  let coords = (
    from + ".center",
    from + ".right",
    to + ".left",
    to + ".center"
  )

  let t = coords.map(coordinate.resolve-system)
  return ((
    name: name,
    coordinates: coords,
    add-default-anchors: false,
    custom-anchors-ctx: (ctx, sc, sr, el, ec) => {
      let style = styles.resolve(ctx.style, style, root: "transition")

      let (start, end, ctrl) = transition-pts(
        sc, ec,
        sr.at(0) - sc.at(0),
        ec.at(0) - el.at(0),
        curve: style.curve
      )

      return (
        center: quadratic-point(start, end, ctrl, 0.5),
        start: start,
        end: end,
        ctrl: ctrl,
        label: label-pt(start, end, ctrl, style, loop:sc==ec)
      )
    },
    render: (ctx, sc, sr, el, ec) => {
      let style = styles.resolve(ctx.style, style, root: "transition")
      let l = style.label

      let (start, end, ctrl) = transition-pts(
        sc, ec,
        sr.at(0) - sc.at(0),
        ec.at(0) - el.at(0),
        curve: style.curve
      )

      let c1 = vector.add(start, vector.scale(vector.sub(ctrl, start), 2/3))
      let c2 = vector.add(end, vector.scale(vector.sub(ctrl, end), 2/3))

      cmd.path(
        ("cubic", start, end, c1, c2),
        stroke: style.stroke
      )

      let dir = mark-dir(start, end, ctrl, scale:ctx.style.mark.size)
      cmd.mark(
        vector.sub(end, dir), end,
        ">",
        fill: get.stroke-paint(style.stroke),
        stroke: get.stroke-thickness(style.stroke) + get.stroke-paint(style.stroke)
      )
      if is.not-empty(l.text) {
        if is.a(l.size) {
          l.size = default-style.transition.label.size
        }
        l.size = util.resolve-number(ctx, l.size) * ctx.length

        if is.a(l.color) {
          l.color = get.stroke-paint(style.stroke)
        }

        let label-pt = label-pt(start, end, ctrl, style, loop:sc==ec)
        let cnt = draw.content(
          label-pt,
          angle: if type(l.angle) == "angle" {
            l.angle
          } else if sc == ec {
            0deg
          } else {
            let d = quadratic-derivative(start, end, ctrl, l.pos)
            let a = vector.angle2((0,0), d)
            if a > 90deg and a < 270deg {
              a = vector.angle2((0,0), vector.scale(d, -1))
            }
            a
          },
          {set text(l.size, l.color); l.text;}
        ).first()
        (cnt.render)(ctx, ..cnt.coordinates)
      }
    }
  ),)
}

#let transitions( states, ..style ) = {
  assert.no-pos(style)
  style = style.named()

  for (from, transitions) in states {
    for (to, label) in transitions {
      let name = from + "-" + to

      transition(
        from,
        to,
        label: label,
        ..style.at(name, default:(:))
      )
    }
  }
}
