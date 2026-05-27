// interpreter.typ — Executable Scratch environment (Turtle Graphics)
// Implements scratch-run() and the associated state/settings.
// Imported and re-exported by lib.typ.

// =====================================================
// State & global settings for scratch-run
// =====================================================

#let blockst-run-options = state("blockst-run-options", (:))

// Global settings for scratch-run
// Usage: #set-scratch-run(show-grid: 50, show-axes: true)
#let set-scratch-run(
  width: none,
  height: none,
  start-x: none,
  start-y: none,
  start-angle: none,
  start-color: none,
  start-thickness: none,
  unit: none,
  background: none,
  show-axes: none,
  show-grid: none,
  show-border: none,
  show-cursor: none,
) = {
  blockst-run-options.update(old => {
    let new-opts = old
    if width != none { new-opts.insert("width", width) }
    if height != none { new-opts.insert("height", height) }
    if start-x != none { new-opts.insert("start-x", start-x) }
    if start-y != none { new-opts.insert("start-y", start-y) }
    if start-angle != none { new-opts.insert("start-angle", start-angle) }
    if start-color != none { new-opts.insert("start-color", start-color) }
    if start-thickness != none { new-opts.insert("start-thickness", start-thickness) }
    if unit != none { new-opts.insert("unit", unit) }
    if background != none { new-opts.insert("background", background) }
    if show-axes != none { new-opts.insert("show-axes", show-axes) }
    if show-grid != none { new-opts.insert("show-grid", show-grid) }
    if show-border != none { new-opts.insert("show-border", show-border) }
    if show-cursor != none { new-opts.insert("show-cursor", show-cursor) }
    new-opts
  })
}

// =====================================================
// scratch-run — Interpreter & Canvas renderer
// =====================================================

#let scratch-run(
  width: auto,
  height: auto,
  start-x: auto,
  start-y: auto,
  start-angle: auto,
  start-color: auto,
  start-thickness: auto,
  unit: auto,
  background: auto,
  show-axes: auto,
  show-grid: auto,
  show-border: auto,
  show-cursor: auto,
  ..commands,
) = context {
  import "@preview/cetz:0.4.2": canvas, draw

  // Read global options
  let opts = blockst-run-options.get()

  // Use parameter if provided, else global option, else default
  let get-option(param, global-key, default) = {
    if param != auto { param } else { opts.at(global-key, default: default) }
  }

  let width = get-option(width, "width", 480)
  let height = get-option(height, "height", 360)
  let start-x = get-option(start-x, "start-x", 0)
  let start-y = get-option(start-y, "start-y", 0)
  let start-angle = get-option(start-angle, "start-angle", 90)
  let start-color = get-option(start-color, "start-color", rgb("#1A1AFF"))
  let start-thickness = get-option(start-thickness, "start-thickness", 0.5)
  let unit = get-option(unit, "unit", 1)
  let background = get-option(background, "background", none)
  let show-axes = get-option(show-axes, "show-axes", false)
  let show-grid = get-option(show-grid, "show-grid", false)
  let show-border = get-option(show-border, "show-border", true)
  let show-cursor = get-option(show-cursor, "show-cursor", true)

  // Collect all commands from arguments
  let commands-array = commands.pos()

  // If a single content element was passed, raise an error
  if commands-array.len() == 1 and type(commands-array.first()) == content {
    panic("scratch-run requires an array of commands. Return the commands array at the end of the block, e.g.: `let befehle = (); befehle.push(stift-ein()); ...; befehle`")
  }

  // Flatten nested arrays
  let flatten(arr) = {
    let result = ()
    for item in arr {
      if type(item) == array {
        result += flatten(item)
      } else {
        result.push(item)
      }
    }
    result
  }

  let commands = flatten(commands-array)

  // Helper: evaluate a value (may be a dictionary expression or a plain value)
  let eval-value(val, state, vars) = {
    if type(val) == dictionary and "type" in val {
      if val.type == "get" {
        state.at(val.property, default: 0)
      } else if val.type == "get-var" {
        vars.at(val.name, default: 0)
      } else if val.type == "add" {
        eval-value(val.a, state, vars) + eval-value(val.b, state, vars)
      } else if val.type == "subtract" {
        eval-value(val.a, state, vars) - eval-value(val.b, state, vars)
      } else if val.type == "multiply" {
        eval-value(val.a, state, vars) * eval-value(val.b, state, vars)
      } else if val.type == "divide" {
        let b = eval-value(val.b, state, vars)
        if b != 0 { eval-value(val.a, state, vars) / b } else { 0 }
      } else if val.type == "random" {
        let range-size = val.to - val.from + 1
        val.from + calc.rem(calc.abs(calc.sin(state.x * 123.456)), range-size)
      } else if val.type == "mod" {
        calc.rem(eval-value(val.a, state, vars), eval-value(val.b, state, vars))
      } else if val.type == "round" {
        calc.round(eval-value(val.value, state, vars))
      } else if val.type == "greater" {
        eval-value(val.a, state, vars) > eval-value(val.b, state, vars)
      } else if val.type == "less" {
        eval-value(val.a, state, vars) < eval-value(val.b, state, vars)
      } else if val.type == "equals" {
        eval-value(val.a, state, vars) == eval-value(val.b, state, vars)
      } else if val.type == "and" {
        eval-value(val.a, state, vars) and eval-value(val.b, state, vars)
      } else if val.type == "or" {
        eval-value(val.a, state, vars) or eval-value(val.b, state, vars)
      } else if val.type == "not" {
        not eval-value(val.a, state, vars)
      } else {
        0
      }
    } else {
      val
    }
  }

  // Fixed stage size — oversized drawings are clipped, box never grows
  let stage-w = width * unit * 1cm / 100
  let stage-h = height * unit * 1cm / 100
  box(
    width: stage-w,
    height: stage-h,
    clip: true,
    stroke: 1pt + rgb("#e0e0e0"),
    radius: 2pt,
    inset: 0pt,
    fill: background,
    canvas(length: unit * 1cm / 100, {
      import draw: *

      // Anchor canvas to full stage bounds so cetz never shrinks viewport
      rect((-width / 2, -height / 2), (width / 2, height / 2), fill: none, stroke: none)

      // Background (if set)
      if background != none {
        rect((-width / 2, -height / 2), (width / 2, height / 2), fill: background, stroke: none)
      }

      // Grid
      if show-grid != false {
        let grid-step = if type(show-grid) == int { show-grid } else { 10 }
        let grid-x0 = calc.floor(-width / 2 / grid-step) * grid-step
        let grid-y0 = calc.floor(-height / 2 / grid-step) * grid-step
        let grid-x1 = calc.ceil(width / 2 / grid-step) * grid-step
        let grid-y1 = calc.ceil(height / 2 / grid-step) * grid-step
        grid(
          (grid-x0, grid-y0),
          (grid-x1, grid-y1),
          step: grid-step,
          stroke: (paint: rgb("#d0d0d0"), thickness: 0.3pt),
          fill: none,
        )
      }

      // Axes
      if show-axes {
        line((-width / 2, 0), (width / 2, 0), stroke: (paint: gray, dash: "dashed", thickness: 0.5pt))
        line((0, -height / 2), (0, height / 2), stroke: (paint: gray, dash: "dashed", thickness: 0.5pt))
      }

      // Initial turtle state
      let state = (
        x: start-x,
        y: start-y,
        angle: start-angle,
        pen-down: false,
        color: start-color,
        size: start-thickness,
      )
      let vars = (:)
      let draw-commands = ()

      // Interpret each command
      for cmd in commands {
        if type(cmd) != dictionary or "type" not in cmd { continue }
        let cmd-type = cmd.type

        // ---- MOTION ----
        if cmd-type == "move" {
          let steps = eval-value(cmd.steps, state, vars)
          let rad = state.angle * calc.pi / 180
          let new-x = state.x + steps * calc.cos(rad)
          let new-y = state.y + steps * calc.sin(rad)
          if state.pen-down {
            draw-commands.push((type: "line", from: (state.x, state.y), to: (new-x, new-y), stroke: (paint: state.color, thickness: state.size * 1pt, join: "miter", cap: "butt", miter-limit: 10)))
          }
          state.x = new-x
          state.y = new-y
        } else if cmd-type == "turn-right" {
          state.angle -= eval-value(cmd.degrees, state, vars)
        } else if cmd-type == "turn-left" {
          state.angle += eval-value(cmd.degrees, state, vars)
        } else if cmd-type == "set-direction" {
          state.angle = eval-value(cmd.angle, state, vars)
        } else if cmd-type == "goto" {
          let new-x = eval-value(cmd.x, state, vars)
          let new-y = eval-value(cmd.y, state, vars)
          if state.pen-down {
            draw-commands.push((type: "line", from: (state.x, state.y), to: (new-x, new-y), stroke: (paint: state.color, thickness: state.size * 1pt, join: "miter", cap: "butt", miter-limit: 10)))
          }
          state.x = new-x
          state.y = new-y
        } else if cmd-type == "set-x" {
          let new-x = eval-value(cmd.x, state, vars)
          if state.pen-down {
            draw-commands.push((type: "line", from: (state.x, state.y), to: (new-x, state.y), stroke: (paint: state.color, thickness: state.size * 1pt, join: "miter", cap: "butt", miter-limit: 10)))
          }
          state.x = new-x
        } else if cmd-type == "set-y" {
          let new-y = eval-value(cmd.y, state, vars)
          if state.pen-down {
            draw-commands.push((type: "line", from: (state.x, state.y), to: (state.x, new-y), stroke: (paint: state.color, thickness: state.size * 1pt, join: "miter", cap: "butt", miter-limit: 10)))
          }
          state.y = new-y
        } else if cmd-type == "change-x" {
          let new-x = state.x + eval-value(cmd.dx, state, vars)
          if state.pen-down {
            draw-commands.push((type: "line", from: (state.x, state.y), to: (new-x, state.y), stroke: (paint: state.color, thickness: state.size * 1pt, join: "miter", cap: "butt", miter-limit: 10)))
          }
          state.x = new-x
        } else if cmd-type == "change-y" {
          let new-y = state.y + eval-value(cmd.dy, state, vars)
          if state.pen-down {
            draw-commands.push((type: "line", from: (state.x, state.y), to: (state.x, new-y), stroke: (paint: state.color, thickness: state.size * 1pt, join: "miter", cap: "butt", miter-limit: 10)))
          }
          state.y = new-y

        // ---- PEN ----
        } else if cmd-type == "clear" {
          // Canvas is redrawn from scratch; no explicit clear needed
        } else if cmd-type == "stamp" {
          draw-commands.push((type: "circle", center: (state.x, state.y), radius: state.size * 2, fill: state.color))
        } else if cmd-type == "pen-down" {
          state.pen-down = true
        } else if cmd-type == "pen-up" {
          state.pen-down = false
        } else if cmd-type == "set-color" {
          state.color = cmd.color
        } else if cmd-type == "set-size" {
          state.size = eval-value(cmd.size, state, vars)
        } else if cmd-type == "change-size" {
          state.size += eval-value(cmd.delta, state, vars)

        // ---- VARIABLES ----
        } else if cmd-type == "set-var" {
          vars.insert(cmd.name, eval-value(cmd.value, state, vars))
        } else if cmd-type == "change-var" {
          vars.insert(cmd.name, vars.at(cmd.name, default: 0) + eval-value(cmd.delta, state, vars))

        // ---- OUTPUT ----
        } else if cmd-type == "say" or cmd-type == "think" {
          draw-commands.push((type: "text", position: (state.x, state.y + 5), text: cmd.message))

        // ---- CLOSE PATH ----
        } else if cmd-type == "close" {
          draw-commands.push((type: "close"))
        }
      }

      // Merge consecutive collinear lines into single polyline paths
      let combined-paths = ()
      let current-path = ()
      let current-stroke = none
      for draw-cmd in draw-commands {
        if draw-cmd.type == "line" {
          let can-extend = current-path.len() > 0 and current-stroke == draw-cmd.stroke and current-path.last() == draw-cmd.from
          if can-extend {
            current-path.push(draw-cmd.to)
          } else {
            if current-path.len() > 0 { combined-paths.push((points: current-path, stroke: current-stroke)) }
            current-path = (draw-cmd.from, draw-cmd.to)
            current-stroke = draw-cmd.stroke
          }
        } else if draw-cmd.type == "close" {
          if current-path.len() > 0 {
            combined-paths.push((points: current-path, stroke: current-stroke, closed: true))
            current-path = ()
            current-stroke = none
          }
        } else {
          if current-path.len() > 0 {
            combined-paths.push((points: current-path, stroke: current-stroke))
            current-path = ()
            current-stroke = none
          }
          combined-paths.push(draw-cmd)
        }
      }
      if current-path.len() > 0 { combined-paths.push((points: current-path, stroke: current-stroke)) }

      // Render merged paths
      for path in combined-paths {
        if "points" in path {
          line(..path.points, closed: path.at("closed", default: false), stroke: path.stroke)
        } else if path.type == "circle" {
          circle(path.center, radius: path.radius, fill: path.fill, stroke: none)
        } else if path.type == "text" {
          content(path.position, [#path.text], anchor: "south")
        }
      }

      // Turtle cursor
      if show-cursor {
        import "mod.typ": icons
        on-layer(0, {
          let rotation = state.angle - 90
          content(
            (state.x, state.y),
            angle: rotation * 1deg,
            image(icons.pencil, height: 25pt),
            anchor: "south-west",
          )
        })
      }
    }),
  )
}
