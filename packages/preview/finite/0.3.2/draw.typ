// imports cetz and t4t
#import "./util.typ": *

#import "layout.typ"


/// Draw a state at the given #arg[position].
///
/// #example[```
/// #cetz.canvas({
///   import finite.draw: state
///   state((0,0), "q1", label:"S1", initial:true)
///   state("q1.right", "q2", label:"S2", final:true, anchor:"left")
/// })
/// ```]
///
/// - position (coordinate): Position of the states center.
/// - name (string): Name for the state.
/// - label (string,content,auto,none): Label for the state. If set to #value(auto), the #arg[name] is used.
/// - initial (boolean,alignment,dictionary): Whether this is an initial state. This can be either
///   - #value(true),
///   - an #dtype("alignment") to specify an anchor for the inital marking,
///   - a #dtype("string") to specify text for the initial marking,
///   - an #dtype("dictionary") with the keys `anchor` and `label` to specifiy both an anchor and a text label for the marking. Additionally, the keys `stroke` and `scale` can be used to style the marking.
/// - final (boolean): Whether this is a final state.
/// - anchor (string): Anchor to use for drawing.
/// - ..style (any): Styling options.
#let state(position, name, label:auto, initial:false, final:false, anchor:"center", ..style) = {
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
  if initial == true {
    initial = (:)
  } else if is.align(initial) {
    initial = (anchor: initial)
  } else if is.str(initial) {
    initial = (label: initial)
  }

  let t = coordinate.resolve-system(position)
  ((
    name: name,
    coordinates: (position, ),
    radius: (ctx) => styles.resolve(ctx.style, style, root: "state").at("radius", default:default-style.state.radius),
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
        let cnt = draw.content(
          // name + ".center",
          center,
          fit-content(
            ctx,
            rx*.9 * ctx.length, ry*.9 * ctx.length,
            style.label.text,
            size: style.label.size
          ),
          frame: none
        ).first()
        (cnt.render)(ctx, ..(cnt.transform-coordinates)(ctx, ..cnt.coordinates))
      }

      // Mark state as final
      if final {
        let thickness = util.resolve-number(ctx, get.stroke-thickness(style.stroke))
        cmd.ellipse(..center, (rx - thickness)*.9, (ry - thickness)*.9, fill: none, stroke: style.stroke)
      }

      // Draw arrow to mark initial state
      if initial != false {
        style.insert("initial", (
          anchor: left,
          label: "Start",
          "stroke": style.stroke,
          scale: 1
        ) + initial)

        let thickness = util.resolve-number(ctx, get.stroke-thickness(style.initial.stroke))
        let color = get.stroke-paint(style.initial.stroke)

        let align-vec = align-to-vec(style.initial.anchor)
        let s-end = vector.add(
          center,
          vector.scale(align-vec, (rx + thickness))
        )
        let s-start = vector.scale(vector.add(
          s-end,
          vector.scale(align-vec, rx)
        ), style.initial.scale)
        cmd.path(
          ("line", s-start, s-end),
          stroke: style.initial.stroke
        )
        cmd.mark(
          vector.add(s-end, vector.scale(align-vec, ctx.style.mark.size)), s-end,
          ">",
          fill: color,
          stroke: style.initial.stroke
        )
        if "label" in style.initial {
          let s-label = vector.add(
            s-start,
            vector-rotate(
              vector.scale(
                align-vec, .2),
              -90deg
            )
          )
          let cnt = draw.content(
            s-label,
            angle: {
              if style.initial.anchor in (top, top+right, right, bottom+right) {
                vector.angle2((0,0), align-vec)
              } else {
                vector.angle2(align-vec, (0,0))
              }
            },
            text(.88em, color, style.initial.label)
          ).first()
          (cnt.render)(ctx, ..(cnt.transform-coordinates)(ctx, ..cnt.coordinates))
        }
      }
    },
    after: (ctx, ..) => {
      ctx.nodes.at(name).insert(
        "radius",
        styles.resolve(ctx.style, style, root: "state").at("radius", default:default-style.state.radius)
      )
      return ctx
    }
  ),)
}


/// Draw a transition between two states.
///
/// The two states #arg[from] and #arg[to] have to be existing names of states.
/// #example[```
/// #cetz.canvas({
///   import finite.draw: state, transition
///   state((0,0), "q1")
///   state((2,0), "q2")
///   transition("q1", "q2", label:"a")
///   transition("q2", "q1", label:"b")
/// })
/// ```]
///
/// - from (string): Name of the starting state.
/// - to (string): Name of the ending state.
/// - inputs (string,array,none): A list of input symbols for the transition.
///    If provided as a #dtype("string"), it is split on commas to get the list of
///    input symbols.
/// - label (string,content,auto,dictionary): A label for the transition. For #value(auto)
///    the #arg[input] symbols are joined with commas. Can be a #dtype("dictionary") with
///    a `text` and additional styling keys.
/// - anchor (alignment): Anchor for loops. Has no effect on normal transitions.
/// - ..style (any): Styling options.
#let transition( from, to, inputs: none, label: auto, anchor: top, ..style ) = {
  assert.no-pos(style)
  let style = style.named()

  assert.all-of-type("string", from, to)
  let name = from + "-" + to

  if is.not-empty(inputs) {
    if is.str(inputs) {
      inputs = inputs.split(",")
    } else if not is.arr(inputs) {
      inputs = (inputs,)
    }
  } else {
    inputs = none
  }

  if is.a(label) {
    if is.not-none(inputs) {
      label = inputs.map(str).join(",")
    } else {
      label = ""
    }
  }
  if not is.dict(label) {
    label = (text:label)
  } else if not "text" in label and is.not-none(inputs) {
    label.insert("text", inputs.map(str).join(","))
  }
  style.insert("label", label)

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

      if style.curve == left {
        style.curve = default-style.transition.curve * -1
      }

      let (start, end, c1, c2) = transition-pts(
        sc, ec,
        sr.at(0) - sc.at(0),
        ec.at(0) - el.at(0),
        curve: style.curve,
        anchor: anchor
      )

      return (
        center: mid-point(start, end, c1, c2),
        start: start,
        end: end,
        ctrl1: c1,
        ctrl2: c2,
        label: label-pt(start, end, c1, c2, style, loop:sc==ec)
      )
    },
    render: (ctx, sc, sr, el, ec) => {
      let style = styles.resolve(ctx.style, style, root: "transition")
      let l = style.label

      if style.curve == left {
        style.curve = default-style.transition.curve * -1
      }

      let (start, end, c1, c2) = transition-pts(
        sc, ec,
        sr.at(0) - sc.at(0),
        ec.at(0) - el.at(0),
        curve: style.curve,
        anchor: anchor
      )

      // let c1 = vector.add(start, vector.scale(vector.sub(ctrl, start), 2/3))
      // let c2 = vector.add(end, vector.scale(vector.sub(ctrl, end), 2/3))

      cmd.path(
        ("cubic", start, end, c1, c2),
        stroke: style.stroke
      )

      let dir = mark-dir(start, end, c1, c2, scale:ctx.style.mark.size)
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

        let label-pt = label-pt(start, end, c1, c2, style, loop:sc==ec)
        let cnt = draw.content(
          label-pt,
          angle: if type(l.angle) == "angle" {
            l.angle
          } else if sc == ec {
            0deg
          } else {
            let d = cubic-derivative(start, end, c1, c2, l.pos)
            let a = vector.angle2((0,0), d)
            if a > 90deg and a < 270deg {
              a = vector.angle2((0,0), vector.scale(d, -1))
            }
            a
          },
          {set text(l.size, l.color); l.text;}
        ).first()
        (cnt.render)(ctx, ..(cnt.transform-coordinates)(ctx, ..cnt.coordinates))
      }
    }
  ),)
}


/// Create a transition loop on a state.
///
/// This is a shortcut for @@transition that takes only one
/// state name instead of two.
#let loop( state, inputs: none, label: auto, anchor: top, ..style ) = transition(state, state, inputs: inputs, label: label, anchor: anchor, ..style )


/// Draws all transitions from a transition table with a common style.
///
/// - states (dictionary): A transition table given as a dictionary of dictionaries.
/// - ..style (any): Styling options.
#let transitions( states, ..style ) = {
  assert.no-pos(style)
  style = style.named()

  for (from, transitions) in states {
    for (to, label) in transitions {
      let name = from + "-" + to

      transition(
        from,
        to,
        inputs: label,
        label: label,
        ..style.at("transition", default:(:)),
        ..style.at(name, default:(:))
      )
    }
  }
}

