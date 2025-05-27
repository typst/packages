
// imports cetz and t4t
#import "./util.typ"
#import util: cetz

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
/// -> array
#let state(
  /// Position of the states center.
  /// -> coordinate
  position,
  /// Name for the state.
  /// -> str
  name,
  /// Label for the state. If set to #value(auto), the #arg[name] is used.
  /// -> str | content | auto | none
  label: auto,
  /// Whether this is an initial state. This can be either
  ///   - #value(true),
  ///   - an #dtype("alignment") to specify an anchor for the inital marking,
  ///   - a #dtype("string") to specify text for the initial marking,
  ///   - an #dtype("dictionary") with the keys `anchor` and `label` to specifiy both an anchor and a text label for the marking. Additionally, the keys `stroke` and `scale` can be used to style the marking.
  /// -> boolean | alignment | dictionary
  initial: false,
  /// Whether this is a final state.
  /// -> boolean
  final: false,
  /// Anchor to use for drawing.
  /// -> str
  anchor: none,
  /// Styling options.
  /// -> any
  ..style,
) = {
  // No extra positional arguments from the style sink
  util.assert.no-pos(style)

  // Create element function
  cetz.draw.group(
    name: name,
    anchor: anchor,
    ctx => {
      let style = style.named()

      // Prepare label
      if not util.is-dict(label) {
        style.insert("label", (text: label))
      } else {
        style.insert("label", label)
      }
      if "text" not in style.label or util.is-auto(style.label.text) {
        style.label.insert("text", name)
      }
      // Prepare initial marking
      style.initial = (:)
      if util.is-align(initial) {
        style.initial.insert("anchor", initial)
      } else if util.is-str(initial) {
        style.initial.insert("label", (text: initial))
      } else if util.is-dict(initial) {
        style.initial = initial
        if "label" in initial and util.is-str(initial.label) {
          style.initial.label = (text: initial.label)
        }
      }

      // Prepare padding
      if "padding" not in style.label or util.is-auto(style.label.padding) {
        style.label.insert("padding", ctx.style.padding)
      }

      let style = cetz.styles.resolve(
        ctx.style,
        merge: style,
        base: util.default-style.state,
        root: "state",
      )

      // resolve coordinates
      let (_, pos) = cetz.coordinate.resolve(ctx, position)

      cetz.draw.circle(pos, name: "state", ..style)
      if final {
        cetz.draw.circle(pos, stroke: style.stroke, radius: style.radius * style.extrude)
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
            name: "initial-label",
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
        if style.label.fill in (auto, none) {
          style.label.fill = stroke(style.stroke).paint
        }
        if style.label.fill == auto {
          style.label.fill = black
        }

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
      cetz.draw.anchor("default", "state.center")
    },
  )
  // Update prev coordinate
  cetz.draw.set-ctx(ctx => {
    let (ctx, _) = cetz.coordinate.resolve(ctx, position)
    ctx
  })
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
/// -> array
#let transition(
  /// Name of the starting state.
  /// -> str
  from,
  /// Name of the ending state.
  /// -> str
  to,
  /// A list of input symbols for the transition.
  /// If provided as a #typ.t.str, it is split at commas to get the list of
  /// input symbols.
  /// -> str | array | none
  inputs: none,
  /// A label for the transition. For #typ.v.auto
  /// the #arg[input] symbols are joined with commas (`,`). Can be a #typ.t.dictionary with
  /// a `text` key and additional styling keys.
  /// -> str | content | auto | dictionary
  label: auto,
  /// Anchor for loops. Has no effect on normal transitions.
  /// -> alignment
  anchor: top,
  ///Styling options.
  /// -> any
  ..style,
) = {
  // No extra positional arguments from the style sink
  util.assert.no-pos(style)

  // TODO: (jneug) allow labels with math or content

  // Name of two states required
  util.assert.all-of-type(str, from, to)
  let name = from.split(".").last() + "-" + to.split(".").last()

  cetz.draw.group(
    name: name,
    ctx => {
      let style = style.named()

      // Prepare inputs
      let inputs = if util.not-empty(inputs) {
        if util.is-str(inputs) {
          inputs.split(",")
        } else if not util.is-arr(inputs) {
          (inputs,)
        } else {
          inputs
        }
      } else {
        none
      }
      // Prepare label
      if util.is-auto(label) {
        if util.not-none(inputs) {
          style.label = (text: inputs.map(str).join(","))
        } else {
          style.label = (text: none)
        }
      } else if not util.is-dict(label) {
        style.label = (text: label)
      } else {
        style.label = label
      }
      if not "text" in style.label and util.not-none(inputs) {
        // TODO: (jneug) add input-label-format function
        style.label.insert("text", inputs.map(str).join(","))
      }

      let style = cetz.styles.resolve(
        ctx.style,
        merge: style,
        base: util.default-style.transition,
        root: "transition",
      )
      // resolve loop styles on top
      if from == to {
        style = cetz.styles.resolve(
          ctx.style,
          merge: ctx.style.at("loop", default: (:)),
          base: style,
          root: "transition",
        )
      }

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
        curve: style.curve * .75,
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

      if not util.is-empty(style.label.text) {
        style.label.size = cetz.util.resolve-number(ctx, style.label.size) * ctx.length

        if style.label.fill in (auto, none) {
          style.label.fill = stroke(style.stroke).paint
        }
        if style.label.fill == auto {
          style.label.fill = black
        }

        let label-pt = util.label-pt(start, end, ctrl1, ctrl2, style, loop: start == end)
        cetz.draw.content(
          name: "label",
          label-pt,
          angle: if util.is-angle(style.label.angle) {
            style.label.angle
          } else if start == end {
            0deg
          } else {
            let d = util.cubic-derivative(start, end, ctrl1, ctrl2, style.label.pos)
            let a = cetz.vector.angle2((0, 0), d)
            if a < 0deg { a += 360deg }
            if a > 90deg and a < 270deg {
              a = cetz.vector.angle2((0, 0), cetz.vector.scale(d, -1))
            }
            a
          },
          {
            let label-style = (size: style.label.size)
            if style.label.fill != none {
              label-style.insert("fill", style.label.fill)
            }
            set text(
              size: style.label.size,
              fill: style.label.fill,
            )
            style.label.text
          },
        )
      }
    },
  )
  // Update prev coordinate
  cetz.draw.set-ctx(ctx => {
    let (ctx, _) = cetz.coordinate.resolve(ctx, to)
    ctx
  })
}


/// Create a transition loop on a state.
/// #example[```
/// #cetz.canvas({
///   import finite.draw: state, loop
///   state((0,0), "q1")
///   loop("q1", label:"a")
///   loop("q1", anchor: bottom+right, label:"b")
/// })
/// ```]
///
/// This is a shortcut for @cmd:transition that takes only one
/// state name instead of two.
#let loop(
  /// Name of the state to draw the loop on.
  /// -> str
  state,
  /// A list of input symbols for the loop.
  /// If provided as a #typ.t.str, it is split at commas to get the list of
  /// input symbols.
  /// -> str | array | none
  inputs: none,
  /// A label for the loop. For #typ.v.auto
  /// the #arg[input] symbols are joined with commas (`,`). Can be a #typ.t.dictionary with
  /// a `text` key and additional styling keys.
  /// -> str | content | auto | dictionary
  label: auto,
  /// Anchor for the loop.
  /// -> alignment
  anchor: top,
  ///Styling options.
  /// -> any
  ..style,
) = transition(
  state,
  state,
  inputs: inputs,
  label: label,
  anchor: anchor,
  ..style,
)


/// Draws multiple transitions from a transition table with a common style.
/// #example[```
/// #cetz.canvas({
///   import finite.draw: state, transitions
///   state((0,0), "q1")
///   state((2,0), "q2")
///   transitions(
///     (
///       q1: (q2: (0, 1)),
///       q2: (q1: 0, q2: 1)
///     ),
///     transition: (stroke: green)
///   )
/// })
/// ```]
///
/// -> content
#let transitions(
  /// A transition table given as a #typ.t.dictionary of dictionaries.
  /// -> transition-table
  states,
  /// Styling options.
  /// -> any
  ..style,
) = {
  util.assert.no-pos(style)
  style = style.named()

  for (from, transitions) in states {
    for (to, label) in transitions {
      let name = from + "-" + to

      transition(
        from,
        to,
        inputs: label,
        // label: label,
        ..style.at("transition", default: (:)),
        ..style.at(name, default: (:)),
      )
    }
  }
}
