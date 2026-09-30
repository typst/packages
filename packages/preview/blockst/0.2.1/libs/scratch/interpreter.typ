// interpreter.typ — Executable Scratch environment (Turtle Graphics)
// Implements scratch-run() and the associated state/settings.
// Imported and re-exported by lib.typ.

// =====================================================
// State & global settings for scratch-run
// =====================================================

#let blockst-run-options = state("blockst-run-options", (:))

// Internal package scale for Scratch pen sizes.
// Intentionally not exposed as a user setting.
#let _pen-size-scale = 0.2834646

// Global settings for scratch-run
// Usage: #set-scratch-run(scale: 2, start: (x: 0, y: 0, angle: 90), stage: (size: (300, 240)))
#let set-scratch-run(
  scale: none,
  start: none,
  pen: none,
  background: none,
  cursor: none,
  stage: none,
  grid: none,
  language: none,
) = {
  blockst-run-options.update(old => {
    let new-opts = old
    if scale != none { new-opts.insert("scale", scale) }
    if language != none { new-opts.insert("language", language) }
    if start != none {
      new-opts.insert("start", start)
      new-opts.insert("start-x", start.at("x", default: old.at("start-x", default: 0)))
      new-opts.insert("start-y", start.at("y", default: old.at("start-y", default: 0)))
      new-opts.insert("start-angle", start.at("angle", default: old.at("start-angle", default: 90)))
    }
    if pen != none {
      new-opts.insert("pen", pen)
      new-opts.insert("pen-down", pen.at("down", default: old.at("pen-down", default: false)))
      new-opts.insert("start-color", pen.at("color", default: old.at("start-color", default: rgb("#1A1AFF"))))
      new-opts.insert("start-thickness", pen.at("size", default: old.at("start-thickness", default: 0.5)))
    }
    if background != none { new-opts.insert("background", background) }
    if cursor != none {
      new-opts.insert("cursor", cursor)
      new-opts.insert("show-cursor", cursor)
    }
    if stage != none {
      new-opts.insert("stage", stage)
      let stage-size = stage.at("size", default: none)
      if stage-size != none {
        new-opts.insert("stage-size", stage-size)
        new-opts.insert("width", stage-size.at(0))
        new-opts.insert("height", stage-size.at(1))
      }
      let border = stage.at("border", default: none)
      if border != none {
        new-opts.insert("border", border)
        new-opts.insert("show-border", border)
      }
    }
    if grid != none {
      new-opts.insert("grid-config", grid)
      let visible = grid.at("visible", default: none)
      if visible != none {
        new-opts.insert("grid", visible)
        new-opts.insert("show-grid", visible)
      }
      let axes = grid.at("axes", default: none)
      if axes != none {
        new-opts.insert("axes", axes)
        new-opts.insert("show-axes", axes)
      }
      let step = grid.at("step", default: none)
      if step != none {
        new-opts.insert("step", step)
        new-opts.insert("grid-step", step)
      }
      let style = grid.at("style", default: none)
      if style != none {
        new-opts.insert("grid-style", style)
        new-opts.insert("grid-stroke", style)
      }
      let x = grid.at("x", default: none)
      if x != none {
        new-opts.insert("x", x)
        new-opts.insert("view-x", x)
      }
      let y = grid.at("y", default: none)
      if y != none {
        new-opts.insert("y", y)
        new-opts.insert("view-y", y)
      }
      let fit = grid.at("fit", default: none)
      if fit != none { new-opts.insert("fit", fit) }
    }
    new-opts
  })
}

// =====================================================
// scratch-run — Interpreter & Canvas renderer
// =====================================================

#let _scratch-run-commands(
  mode: auto,
  width: auto,
  height: auto,
  start-x: auto,
  start-y: auto,
  pen-down: auto,
  start-angle: auto,
  start-color: auto,
  start-thickness: auto,
  unit: auto,
  background: auto,
  show-axes: auto,
  grid-step: auto,
  show-grid: auto,
  grid-stroke: auto,
  show-border: auto,
  show-cursor: auto,
  view-x: auto,
  view-y: auto,
  fit: auto,
  ..commands,
) = context {
  import "@preview/cetz:0.4.2": canvas, draw

  let normalize-color(value, default: black, allow-none: false) = {
    if value == none and allow-none {
      return none
    }
    if type(value) == color {
      return value
    }
    if type(value) == str {
      let s = lower(value.trim())
      if s.starts-with("#") { return rgb(s) }
      if s == "black" { return black }
      if s == "white" { return white }
      if s == "red" { return red }
      if s == "green" { return green }
      if s == "blue" { return blue }
      if s == "yellow" { return yellow }
      if s == "orange" { return orange }
      if s == "purple" { return purple }
      if s == "pink" { return pink }
      if s == "brown" { return brown }
      if s == "gray" or s == "grey" { return gray }
      if s == "cyan" { return cyan }
      if s == "magenta" { return magenta }
    }
    default
  }

  let normalize-hue(h) = {
    let wrapped = calc.rem(h, 100)
    if wrapped < 0 { wrapped + 100 } else { wrapped }
  }

  let hue-to-degrees(h) = normalize-hue(h) * 3.6

  let clamp-percent(value) = calc.max(0, calc.min(100, value))

  let normalize-pen-param(param) = {
    let p = lower(str(param).trim())
    if p == "hue" or p == "color" or p == "farbe" {
      "hue"
    } else if p == "saturation" or p == "sättigung" or p == "saettigung" {
      "saturation"
    } else if p == "brightness" or p == "helligkeit" or p == "shade" or p == "farbstärke" or p == "farbstaerke" {
      "brightness"
    } else if p == "transparency" or p == "durchsichtigkeit" or p == "transparenz" {
      "transparency"
    } else {
      p
    }
  }

  // Convert pen params from Scratch scale to RGB.
  // Scratch uses hue/saturation/brightness in the 0..100 range.
  // HSV conversion expects hue in degrees (0..360), so hue is scaled here.
  // Transparency is approximated by mixing towards white.
  let pen-color(hue, saturation, brightness, transparency) = {
    let h = hue-to-degrees(hue)
    let s = clamp-percent(saturation) / 100
    let v = clamp-percent(brightness) / 100
    let t = clamp-percent(transparency) / 100
    let c = v * s
    let x = 1.0 - calc.abs(calc.rem(h / 60, 2) - 1.0)
    x = c * x
    let m = v - c

    let r1 = 0.0
    let g1 = 0.0
    let b1 = 0.0

    if h < 60 {
      r1 = c
      g1 = x
      b1 = 0.0
    } else if h < 120 {
      r1 = x
      g1 = c
      b1 = 0.0
    } else if h < 180 {
      r1 = 0.0
      g1 = c
      b1 = x
    } else if h < 240 {
      r1 = 0.0
      g1 = x
      b1 = c
    } else if h < 300 {
      r1 = x
      g1 = 0.0
      b1 = c
    } else {
      r1 = c
      g1 = 0.0
      b1 = x
    }

    let r = r1 + m
    let g = g1 + m
    let b = b1 + m
    let a = 1.0 - t

    rgb(int(calc.round(r * 255)), int(calc.round(g * 255)), int(calc.round(b * 255)), int(calc.round(a * 255)))
  }

  // Read global options
  let opts = blockst-run-options.get()

  // Use parameter if provided, else global option, else default
  let get-option(param, global-key, default) = {
    if param != auto { param } else { opts.at(global-key, default: default) }
  }

  let mode-opt = if mode != auto { mode } else { opts.at("mode", default: none) }
  let mode = if mode-opt == none {
    if view-x != auto or view-y != auto { "grid" } else { "stage" }
  } else {
    mode-opt
  }

  let normalize-bool(value, default: false) = {
    if value == true or value == false {
      value
    } else if type(value) == str {
      let s = lower(value.trim())
      if s == "true" or s == "on" or s == "yes" or s == "1" {
        true
      } else if s == "false" or s == "off" or s == "no" or s == "0" {
        false
      } else {
        default
      }
    } else {
      default
    }
  }

  let size-opt = opts.at("stage-size", default: none)
  let width = if width != auto {
    width
  } else if size-opt != none {
    size-opt.at(0)
  } else {
    get-option(width, "width", 480)
  }
  let height = if height != auto {
    height
  } else if size-opt != none {
    size-opt.at(1)
  } else {
    get-option(height, "height", 360)
  }
  let start-x = get-option(start-x, "start-x", 0)
  let start-y = get-option(start-y, "start-y", 0)
  let initial-pen-down = normalize-bool(get-option(pen-down, "pen-down", false), default: false)
  let start-angle = get-option(start-angle, "start-angle", 90)
  let start-color = normalize-color(get-option(start-color, "start-color", rgb("#1A1AFF")), default: rgb("#1A1AFF"))
  let start-thickness = get-option(start-thickness, "start-thickness", 0.5)
  let scale-opt = opts.at("scale", default: auto)
  let unit = if unit != auto {
    unit
  } else if scale-opt != auto {
    scale-opt
  } else {
    get-option(unit, "unit", 1)
  }
  let background = normalize-color(get-option(background, "background", none), default: none, allow-none: true)
  let show-axes = if show-axes != auto { show-axes } else { opts.at("axes", default: get-option(show-axes, "show-axes", false)) }
  let grid-step-opt = if grid-step != auto { grid-step } else { opts.at("step", default: get-option(grid-step, "grid-step", auto)) }
  let show-grid-legacy = if show-grid != auto { show-grid } else { opts.at("grid", default: get-option(show-grid, "show-grid", false)) }
  let grid-step = if grid-step-opt != auto {
    grid-step-opt
  } else if show-grid-legacy != false {
    if type(show-grid-legacy) == int { show-grid-legacy } else { 10 }
  } else if mode == "grid" and show-grid == auto {
    1
  } else {
    none
  }
  let default-grid-stroke = (paint: rgb("#AAAAAA").lighten(10%), dash: "solid", thickness: 0.5pt)
  let grid-stroke = if grid-stroke != auto { grid-stroke } else { opts.at("grid-style", default: get-option(grid-stroke, "grid-stroke", default-grid-stroke)) }
  let show-border = if show-border != auto { show-border } else { opts.at("border", default: get-option(show-border, "show-border", mode == "stage")) }
  let show-cursor = if show-cursor != auto { show-cursor } else { opts.at("cursor", default: get-option(show-cursor, "show-cursor", true)) }
  let unit-scale = calc.max(0.01, unit)
  let pen-thickness(size) = if mode == "grid" {
    calc.max(0pt, size * _pen-size-scale * 1pt)
  } else {
    calc.max(0.1pt * unit-scale, size * _pen-size-scale * unit-scale * 1pt)
  }

  let normalize-grid-stroke(value) = {
    if type(value) == color {
      (paint: value, dash: "solid", thickness: 0.5pt)
    } else if type(value) == dictionary {
      (
        paint: value.at("paint", default: default-grid-stroke.paint),
        dash: value.at("dash", default: default-grid-stroke.dash),
        thickness: value.at("thickness", default: default-grid-stroke.thickness),
      )
    } else {
      default-grid-stroke
    }
  }

  let normalize-cursor-style(value) = {
    if value == false or value == none {
      "none"
    } else if value == true {
      "pen"
    } else if type(value) == str {
      let s = lower(value.trim())
      if s == "dot" {
        "dot"
      } else if s == "false" or s == "none" or s == "off" {
        "none"
      } else {
        "pen"
      }
    } else {
      "pen"
    }
  }

  let resolved-grid-stroke = normalize-grid-stroke(grid-stroke)
  let cursor-style = normalize-cursor-style(show-cursor)

  // View parameters: use tuples (min, max) or derive from width/height.
  let fit-opt = if fit != auto { fit } else { opts.at("fit", default: auto) }
  let resolved-fit = if fit-opt == auto { auto } else { fit-opt }
  let view-x-tuple = if view-x != auto { view-x } else { opts.at("x", default: get-option(view-x, "view-x", (-width / 2, width / 2))) }
  let view-y-tuple = if view-y != auto { view-y } else { opts.at("y", default: get-option(view-y, "view-y", (-height / 2, height / 2))) }
  let view-x-min = view-x-tuple.at(0)
  let view-x-max = view-x-tuple.at(1)
  let view-y-min = view-y-tuple.at(0)
  let view-y-max = view-y-tuple.at(1)
  let has-explicit-view = view-x != auto or view-y != auto or "x" in opts or "y" in opts or "view-x" in opts or "view-y" in opts
  let auto-fit-grid-view = if mode == "grid" {
    if resolved-fit == auto {
      not has-explicit-view
    } else {
      resolved-fit
    }
  } else {
    false
  }

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
  // If view bounds are set, their extents define the rendered stage.
  let use-view-bounds = mode == "grid" or view-x != auto or view-y != auto
  let (canvas-width, canvas-height) = if use-view-bounds {
    (view-x-max - view-x-min, view-y-max - view-y-min)
  } else {
    (width, height)
  }

  let stage-w = if use-view-bounds {
    if auto-fit-grid-view { auto } else { canvas-width * unit * 1cm }
  } else {
    canvas-width * unit * 1cm / 100
  }
  let stage-h = if use-view-bounds {
    if auto-fit-grid-view { auto } else { canvas-height * unit * 1cm }
  } else {
    canvas-height * unit * 1cm / 100
  }
  box(
    width: stage-w,
    height: stage-h,
    clip: true,
    stroke: if show-border { 1pt + rgb("#e0e0e0") } else { none },
    radius: if show-border { 2pt } else { 0pt },
    inset: 0pt,
    fill: background,
    canvas(length: if use-view-bounds { unit * 1cm } else { unit * 1cm / 100 }, {
      import draw: *

      // Anchor canvas to full view bounds so cetz never shrinks viewport.
      // In auto-fit grid mode, skip this anchor so the viewport can shrink to content bounds.
      if not auto-fit-grid-view {
        rect((view-x-min, view-y-min), (view-x-max, view-y-max), fill: none, stroke: none)
      }

      // Background (if set)
      if background != none and not auto-fit-grid-view {
        rect((view-x-min, view-y-min), (view-x-max, view-y-max), fill: background, stroke: none)
      }

      // Initial turtle state
      let initial-state = (
        x: start-x,
        y: start-y,
        angle: start-angle,
        pen-down: initial-pen-down,
        color: start-color,
        hue: 66.6666667,
        saturation: 100,
        brightness: 100,
        transparency: 0,
        size: start-thickness,
      )

      let execute_commands(cmds, state, vars, draw-commands) = {
        for cmd in cmds {
          if type(cmd) != dictionary or "type" not in cmd { continue }
          let cmd-type = cmd.type

          // ---- CONTROL ----
          if cmd-type == "if" {
            let cond = eval-value(cmd.condition, state, vars)
            if cond {
              let nested = execute_commands(cmd.at("then_body", default: ()), state, vars, draw-commands)
              state = nested.state
              vars = nested.vars
              draw-commands = nested.draw-commands
            } else {
              let nested = execute_commands(cmd.at("else_body", default: ()), state, vars, draw-commands)
              state = nested.state
              vars = nested.vars
              draw-commands = nested.draw-commands
            }
          } else if cmd-type == "repeat" {
            let count = int(calc.max(0, eval-value(cmd.count, state, vars)))
            for _i in range(count) {
              let nested = execute_commands(cmd.at("body", default: ()), state, vars, draw-commands)
              state = nested.state
              vars = nested.vars
              draw-commands = nested.draw-commands
            }
          } else if cmd-type == "repeat-until" {
            let limit = int(cmd.at("limit", default: 1000))
            for _i in range(limit) {
              if eval-value(cmd.condition, state, vars) { break }
              let nested = execute_commands(cmd.at("body", default: ()), state, vars, draw-commands)
              state = nested.state
              vars = nested.vars
              draw-commands = nested.draw-commands
            }
          } else if cmd-type == "forever" {
            let limit = int(cmd.at("limit", default: 20))
            for _i in range(limit) {
              let nested = execute_commands(cmd.at("body", default: ()), state, vars, draw-commands)
              state = nested.state
              vars = nested.vars
              draw-commands = nested.draw-commands
            }
          } else if cmd-type == "wait" {
            // No timeline yet; keep as no-op for deterministic static rendering.

          // ---- MOTION ----
          } else if cmd-type == "move" {
            let steps = eval-value(cmd.steps, state, vars)
            // Scratch uses 90=East, 0=North, -90=West, 180=South.
            let rad = (90 - state.angle) * calc.pi / 180
            let new-x = state.x + steps * calc.cos(rad)
            let new-y = state.y + steps * calc.sin(rad)
            if state.pen-down {
              draw-commands.push((type: "line", from: (state.x, state.y), to: (new-x, new-y), stroke: (paint: state.color, thickness: pen-thickness(state.size), join: "round", cap: "round", miter-limit: 10)))
            }
            state.x = new-x
            state.y = new-y
          } else if cmd-type == "turn-right" {
            state.angle += eval-value(cmd.degrees, state, vars)
          } else if cmd-type == "turn-left" {
            state.angle -= eval-value(cmd.degrees, state, vars)
          } else if cmd-type == "set-direction" {
            state.angle = eval-value(cmd.angle, state, vars)
          } else if cmd-type == "goto" {
            let new-x = eval-value(cmd.x, state, vars)
            let new-y = eval-value(cmd.y, state, vars)
            if state.pen-down {
              draw-commands.push((type: "line", from: (state.x, state.y), to: (new-x, new-y), stroke: (paint: state.color, thickness: pen-thickness(state.size), join: "round",  cap: "round", miter-limit: 10)))
            }
            state.x = new-x
            state.y = new-y
          } else if cmd-type == "set-x" {
            let new-x = eval-value(cmd.x, state, vars)
            if state.pen-down {
              draw-commands.push((type: "line", from: (state.x, state.y), to: (new-x, state.y), stroke: (paint: state.color, thickness: pen-thickness(state.size), join: "round",  cap: "round", miter-limit: 10)))
            }
            state.x = new-x
          } else if cmd-type == "set-y" {
            let new-y = eval-value(cmd.y, state, vars)
            if state.pen-down {
              draw-commands.push((type: "line", from: (state.x, state.y), to: (state.x, new-y), stroke: (paint: state.color, thickness: pen-thickness(state.size), join: "round",  cap: "round", miter-limit: 10)))
            }
            state.y = new-y
          } else if cmd-type == "change-x" {
            let new-x = state.x + eval-value(cmd.dx, state, vars)
            if state.pen-down {
              draw-commands.push((type: "line", from: (state.x, state.y), to: (new-x, state.y), stroke: (paint: state.color, thickness: pen-thickness(state.size), join: "round",  cap: "round", miter-limit: 10)))
            }
            state.x = new-x
          } else if cmd-type == "change-y" {
            let new-y = state.y + eval-value(cmd.dy, state, vars)
            if state.pen-down {
              draw-commands.push((type: "line", from: (state.x, state.y), to: (state.x, new-y), stroke: (paint: state.color, thickness: pen-thickness(state.size), join: "round",  cap: "round", miter-limit: 10)))
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
          } else if cmd-type == "change-pen-param" {
            let param = normalize-pen-param(cmd.param)
            let delta = eval-value(cmd.delta, state, vars)
            if param == "hue" {
              state.hue = normalize-hue(state.hue + delta)
              state.color = pen-color(state.hue, state.saturation, state.brightness, state.transparency)
            } else if param == "saturation" {
              state.saturation = clamp-percent(state.saturation + delta)
              state.color = pen-color(state.hue, state.saturation, state.brightness, state.transparency)
            } else if param == "brightness" {
              state.brightness = clamp-percent(state.brightness + delta)
              state.color = pen-color(state.hue, state.saturation, state.brightness, state.transparency)
            } else if param == "transparency" {
              state.transparency = clamp-percent(state.transparency + delta)
              state.color = pen-color(state.hue, state.saturation, state.brightness, state.transparency)
            }
          } else if cmd-type == "set-pen-param" {
            let param = normalize-pen-param(cmd.param)
            let value = eval-value(cmd.value, state, vars)
            if param == "hue" {
              state.hue = normalize-hue(value)
              state.color = pen-color(state.hue, state.saturation, state.brightness, state.transparency)
            } else if param == "saturation" {
              state.saturation = clamp-percent(value)
              state.color = pen-color(state.hue, state.saturation, state.brightness, state.transparency)
            } else if param == "brightness" {
              state.brightness = clamp-percent(value)
              state.color = pen-color(state.hue, state.saturation, state.brightness, state.transparency)
            } else if param == "transparency" {
              state.transparency = clamp-percent(value)
              state.color = pen-color(state.hue, state.saturation, state.brightness, state.transparency)
            }
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
        (state: state, vars: vars, draw-commands: draw-commands)
      }

      // Interpret each command
      let state = initial-state
      let vars = (:)
      let draw-commands = ()
      let result = execute_commands(commands, state, vars, draw-commands)
      state = result.state
      vars = result.vars
      draw-commands = result.draw-commands

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

      // In grid mode, if no explicit view is provided, fit the grid to the drawn figure.
      let has-shape-bounds = false
      let shape-min-x = 0
      let shape-max-x = 0
      let shape-min-y = 0
      let shape-max-y = 0

      for path in combined-paths {
        if "points" in path {
          for pt in path.points {
            let px = pt.at(0)
            let py = pt.at(1)
            if not has-shape-bounds {
              has-shape-bounds = true
              shape-min-x = px
              shape-max-x = px
              shape-min-y = py
              shape-max-y = py
            } else {
              shape-min-x = calc.min(shape-min-x, px)
              shape-max-x = calc.max(shape-max-x, px)
              shape-min-y = calc.min(shape-min-y, py)
              shape-max-y = calc.max(shape-max-y, py)
            }
          }
        } else if path.type == "circle" {
          let cx = path.center.at(0)
          let cy = path.center.at(1)
          let r = path.radius
          let p1x = cx - r
          let p2x = cx + r
          let p1y = cy - r
          let p2y = cy + r
          if not has-shape-bounds {
            has-shape-bounds = true
            shape-min-x = p1x
            shape-max-x = p2x
            shape-min-y = p1y
            shape-max-y = p2y
          } else {
            shape-min-x = calc.min(shape-min-x, p1x)
            shape-max-x = calc.max(shape-max-x, p2x)
            shape-min-y = calc.min(shape-min-y, p1y)
            shape-max-y = calc.max(shape-max-y, p2y)
          }
        } else if path.type == "text" {
          let px = path.position.at(0)
          let py = path.position.at(1)
          if not has-shape-bounds {
            has-shape-bounds = true
            shape-min-x = px
            shape-max-x = px
            shape-min-y = py
            shape-max-y = py
          } else {
            shape-min-x = calc.min(shape-min-x, px)
            shape-max-x = calc.max(shape-max-x, px)
            shape-min-y = calc.min(shape-min-y, py)
            shape-max-y = calc.max(shape-max-y, py)
          }
        }
      }

      let auto-grid-fit = auto-fit-grid-view and grid-step != none and has-shape-bounds
      let round-eps = 0.000001
      let grid-min-x = if grid-step == none {
        view-x-min
      } else if auto-grid-fit {
        calc.floor((shape-min-x + round-eps) / grid-step) * grid-step - grid-step
      } else {
        calc.floor(view-x-min / grid-step) * grid-step
      }
      let grid-min-y = if grid-step == none {
        view-y-min
      } else if auto-grid-fit {
        calc.floor((shape-min-y + round-eps) / grid-step) * grid-step - grid-step
      } else {
        calc.floor(view-y-min / grid-step) * grid-step
      }
      let grid-max-x = if grid-step == none {
        view-x-max
      } else if auto-grid-fit {
        calc.ceil((shape-max-x - round-eps) / grid-step) * grid-step + grid-step
      } else {
        calc.ceil(view-x-max / grid-step) * grid-step
      }
      let grid-max-y = if grid-step == none {
        view-y-max
      } else if auto-grid-fit {
        calc.ceil((shape-max-y - round-eps) / grid-step) * grid-step + grid-step
      } else {
        calc.ceil(view-y-max / grid-step) * grid-step
      }

      // Grid (before path rendering, so drawing stays on top)
      if grid-step != none {
        grid(
          (grid-min-x, grid-min-y),
          (grid-max-x, grid-max-y),
          step: grid-step,
          stroke: resolved-grid-stroke,
          fill: none,
        )
      }

      // Axes
      if show-axes {
        line((grid-min-x, 0), (grid-max-x, 0), stroke: (paint: gray, dash: "dashed", thickness: 0.5pt))
        line((0, grid-min-y), (0, grid-max-y), stroke: (paint: gray, dash: "dashed", thickness: 0.5pt))
      }

      // Render merged paths
      for path in combined-paths {
        if "points" in path {
          line(..path.points, closed: path.at("closed", default: false), stroke: path.stroke)
        } else if path.type == "circle" {
          circle(path.center, radius: path.radius, fill: path.fill, stroke: none)
        } else if path.type == "text" {
          content(path.position, text(path.text), anchor: "south")
        }
      }

      // Turtle cursor
      if cursor-style != "none" {
        on-layer(0, {
          if cursor-style == "dot" {
            circle((state.x, state.y), fill: black, stroke: none, radius: 1mm)
          } else {
            content(
              (state.x, state.y),
              image("assets/pencil-cursor.svg", width: 15pt),
              anchor: "south-west",
            )
          }
        })
      }
    }),
  )
}

