// imports cetz and t4t
#import "./util.typ"
#import util: cetz

#import "layout.typ"

/// Draw a state at the given #arg[position].
///
/// #example[```
/// #cetz.canvas({
///   import finite.draw: state
///   state((0,0), "q1", label:"S1", initial:true)
///   state("q1.east", "q2", label:"S2", final:true, anchor:"west")
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
#let state(
  position,
  name,
  label: auto,
  initial: false,
  final: false,
  anchor: "center",
  ..style,
) = {
  // No extra positional arguments from the style sink
  util.assert.no-pos(style)

  // Create element function
  util.state-wrapper(
    cetz.draw.group(
      name: name,
      anchor: anchor,
      ctx => {
        let style = style.named()

        // Prepare label
        if not util.is.dict(label) {
          style.insert("label", (text: label))
        } else {
          style.insert("label", label)
        }
        if "text" not in style.label or util.is.a(style.label.text) {
          style.label.insert("text", name)
        }
        // Prepare initial marking
        style.initial = (:)
        if util.is.align(initial) {
          style.initial.insert("anchor", initial)
        } else if util.is.str(initial) {
          style.initial.insert("label", (text: initial))
        } else if util.is.dict(initial) {
          style.initial = initial
          if "label" in initial and util.is.str(initial.label) {
            style.initial.label = (text: initial.label)
          }
        }

        // Prepare padding
        if "padding" not in style.label or util.is.a(style.label.padding) {
          style.label.insert("padding", ctx.style.padding)
        }

        let style = cetz.styles.resolve(
          ctx.style,
          merge: style,
          base: util.default-style.state,
          root: "state",
        )


        cetz.draw.set-ctx(_ctx => {
          // Add new state to CetZ context
          if "finite" not in _ctx {
            _ctx.insert("finite", (states: (:)))
          }
          _ctx.finite.states.insert(name, (name: name, radius: style.radius))
          _ctx
        })

        cetz.draw.circle(position, name: "state", ..style)
        if final {
          cetz.draw.circle(position, stroke: style.stroke, radius: style.radius * style.extrude)
        }
        if initial != false {
          let color = if style.initial.stroke == auto {
            stroke(style.stroke).paint
          } else {
            stroke(style.initial.stroke).paint
          }

          let initial-anchor = util.to-anchor(style.initial.anchor)
          let align-vec = util.align-to-vec(style.initial.anchor)
          let initial-start = (
            rel: cetz.vector.scale(
              align-vec,
              style.initial.scale,
            ),
            to: "state." + initial-anchor,
          )

          cetz.draw.line(
            name: "initial",
            initial-start,
            "state." + initial-anchor,
            mark: (end: "straight"),
            stroke: style.initial.stroke,
          )
          if style.initial.label != none {
            cetz.draw.content(
              (
                rel: util.vector-set-len(
                  util.vector-rotate(
                    initial-start.rel,
                    if util.abs-angle-between(align-vec, (0, 0), -90deg, 90deg) {
                      -90deg
                    } else {
                      90deg
                    },
                  ),
                  style.initial.label.dist,
                ),
                to: initial-start,
              ),
              anchor: "south",
              angle: util.label-angle(align-vec, style.initial.anchor),
              text(style.initial.label.size, color, style.initial.label.text),
            )
          }
        }
        if label not in (none, (:)) {
          cetz.draw.content(
            "state.center",
            name: "label",
            anchor: "center",
            padding: style.label.padding,
            text(
              size: style.label.size,
              fill: style.label.fill,
              style.label.text,
            ),
          )
        }
        cetz.draw.copy-anchors("state")
      },
    ),
  )
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
#let transition(
  from,
  to,
  inputs: none,
  label: auto,
  anchor: top,
  ..style,
) = {
  // No extra positional arguments from the style sink
  util.assert.no-pos(style)

  // Name of two states required
  util.assert.all-of-type("string", from, to)
  let name = from.split(".").last() + "-" + to.split(".").last()

  return util.transition-wrapper(
    from,
    to,
    cetz.draw.group(
      name: name,
      ctx => {
        let style = style.named()

        // Prepare inputs
        let inputs = if util.is.not-empty(inputs) {
          if util.is.str(inputs) {
            inputs.split(",")
          } else if not util.is.arr(inputs) {
            (inputs,)
          } else {
            inputs
          }
        } else {
          none
        }
        // Prepare label
        if util.is.a(label) {
          if util.is.not-none(inputs) {
            style.label = (text: inputs.map(str).join(","))
          } else {
            style.label = (text: none)
          }
        } else if not util.is.dict(label) {
          style.label = (text: label)
        } else if not "text" in label and util.is.not-none(inputs) {
          style.label = (text: inputs.map(str).join(","))
        }

        let style = cetz.styles.resolve(
          ctx.style,
          merge: style,
          base: util.default-style.transition,
          root: "transition",
        )

        let (_, start, f-center, f-right, end, t-center, t-right) = cetz.coordinate.resolve(
          ctx,
          from + ".state",
          from + ".state.center",
          from + ".state.east",
          to + ".state",
          to + ".state.center",
          to + ".state.east",
        )
        let (start-rad, end-rad) = (
          f-right.at(0) - f-center.at(0),
          t-right.at(0) - t-center.at(0),
        )
        let (start, end, ctrl1, ctrl2) = util.transition-pts(
          start,
          end,
          start-rad,
          end-rad,
          curve: style.curve,
          anchor: anchor,
        )
        cetz.draw.bezier(
          name: "arrow",
          start,
          end,
          ctrl1,
          ctrl2,
          mark: (
            end: ">",
            stroke: style.stroke,
            fill: stroke(style.stroke).paint,
          ),
          ..style,
        )
        cetz.draw.copy-anchors("arrow")

        if not util.is.empty(style.label.text) {
          style.label.size = cetz.util.resolve-number(ctx, style.label.size) * ctx.length

          if style.label.color == auto {
            style.label.color = stroke(style.stroke).paint
          }
          if style.label.color == auto {
            style.label.color = black
          }

          let label-pt = util.label-pt(start, end, ctrl1, ctrl2, style, loop: start == end)
          cetz.draw.content(
            name: "label",
            label-pt,
            angle: if type(style.label.angle) == angle {
              style.label.angle
            } else if start == end {
              0deg
            } else {
              let d = util.cubic-derivative(start, end, ctrl1, ctrl2, style.label.pos)
              let a = cetz.vector.angle2((0, 0), d)
              if a > 90deg and a < 270deg {
                a = cetz.vector.angle2((0, 0), cetz.vector.scale(d, -1))
              }
              a
            },
            {
              set text(
                size: style.label.size,
                fill: style.label.color,
              )
              style.label.text
            },
          )
        }
      },
    ),
  )
}


/// Create a transition loop on a state.
///
/// This is a shortcut for @@transition that takes only one
/// state name instead of two.
#let loop(state, inputs: none, label: auto, anchor: top, ..style) = transition(
  state,
  state,
  inputs: inputs,
  label: label,
  anchor: anchor,
  ..style,
)


/// Draws all transitions from a transition table with a common style.
///
/// - states (dictionary): A transition table given as a dictionary of dictionaries.
/// - ..style (any): Styling options.
#let transitions(states, ..style) = {
  util.assert.no-pos(style)
  style = style.named()

  for (from, transitions) in states {
    for (to, label) in transitions {
      let name = from + "-" + to

      transition(
        from,
        to,
        inputs: label,
        label: label,
        ..style.at("transition", default: (:)),
        ..style.at(name, default: (:)),
      )
    }
  }
}

