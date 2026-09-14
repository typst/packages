#import "parser.typ": parse-scratch-text
#import "../executable.typ": move, turn-right, turn-left, set-direction, go-to, set-x, set-y, change-x, change-y, erase-all, stamp, pen-down, pen-up, set-pen-color, change-pen-size, set-pen-size, change-pen-param, set-pen-param, set-variable, change-variable, variable, plus, minus, multiply, divide, random, modulo, round, greater, less, equals, op-and, op-or, op-not, wait

#let _parse(text, language) = parse-scratch-text(text, language: language)

#let _num(value, default: 0) = {
  if type(value) == int or type(value) == float {
    value
  } else if type(value) == str {
    float(value)
  } else {
    default
  }
}

#let _color(value, default: black) = {
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

#let _normalize-pen-param(value, default: "hue") = {
  let p = lower(str(value).trim())
  if p == "hue" or p == "color" or p == "farbe" {
    "hue"
  } else if p == "saturation" or p == "sättigung" or p == "saettigung" {
    "saturation"
  } else if p == "brightness" or p == "helligkeit" or p == "shade" or p == "farbstärke" or p == "farbstaerke" {
    "brightness"
  } else if p == "transparency" or p == "durchsichtigkeit" or p == "transparenz" {
    "transparency"
  } else {
    default
  }
}

#let _inputs(node) = {
  let out = ()
  for part in node.at("parts", default: ()) {
    if part.at("kind", default: "") == "input" {
      out.push(part)
    }
  }
  out
}

#let _input-value(node, index, default: none) = {
  let inputs = _inputs(node)
  if index < inputs.len() {
    inputs.at(index).at("value", default: default)
  } else {
    default
  }
}

#let _input-dropdown-value(node, default: none) = {
  for part in node.at("parts", default: ()) {
    if part.at("kind", default: "") == "input" and part.at("shape", default: "") == "dropdown" {
      return part.at("value", default: default)
    }
  }
  default
}

#let _input-nested(node, index) = {
  let inputs = _inputs(node)
  if index < inputs.len() {
    inputs.at(index).at("nested", default: none)
  } else {
    none
  }
}

#let _first-label(node, default: "") = {
  for part in node.at("parts", default: ()) {
    if part.at("kind", default: "") == "label" {
      return part.at("value", default: default)
    }
  }
  default
}

#let _procedure-name(node) = {
  let words = ()
  let skipped-prefix = false
  let node-id = node.at("id", default: "")
  for part in node.at("parts", default: ()) {
    if part.at("kind", default: "") == "label" {
      let value = part.at("value", default: "")
      if not skipped-prefix and (node-id == "procedures_definition" or node-id == "procedures_call" or value == "define" or value == "call") {
        skipped-prefix = true
      } else {
        skipped-prefix = true
        words.push(value)
      }
    }
  }
  if words.len() == 0 { "" } else { words.join(" ") }
}

#let _procedure-param-name(input, default: "") = {
  let nested = input.at("nested", default: none)
  if nested != none {
    let nested-id = nested.at("id", default: "")
    if nested-id == "unrecognized" or nested-id == "argument_reporter_string_number" or nested-id == "argument_reporter_boolean" {
      let label = _first-label(nested, default: default)
      if label != "" { return label }
    }
  }
  input.at("value", default: default)
}

#let _procedure-params(node) = {
  let params = ()
  for input in _inputs(node) {
    let name = _procedure-param-name(input, default: "")
    if name != "" {
      params.push(name)
    }
  }
  params
}

#let _extract-procedure-body(nodes, start-index, proc-name: "") = {
  let has-explicit-end = false
  let j = start-index
  while j < nodes.len() {
    let probe = nodes.at(j)
    let probe-id = probe.at("id", default: "")
    let probe-shape = probe.at("shape", default: "")
    if probe-id == "scratchblocks:end" {
      has-explicit-end = true
      break
    }
    if probe-id == "procedures_definition" or probe-shape == "hat" {
      break
    }
    j += 1
  }

  let body = ()
  let i = start-index
  while i < nodes.len() {
    let current = nodes.at(i)
    let current-id = current.at("id", default: "")
    let current-shape = current.at("shape", default: "")
    if current-id == "scratchblocks:end" {
      i += 1
      break
    }
    if current-id == "procedures_definition" or current-shape == "hat" {
      break
    }
    if not has-explicit-end and proc-name != "" and current-id == "procedures_call" and _procedure-name(current) == proc-name {
      break
    }
    body.push(current)
    i += 1
  }
  (body: body, next-index: i)
}

#let _as-bool(value, default: false) = {
  if type(value) == bool {
    value
  } else if type(value) == int or type(value) == float {
    value != 0
  } else if type(value) == str {
    let s = lower(value.trim())
    if s == "true" { true }
    else if s == "false" { false }
    else { default }
  } else {
    default
  }
}

#let _compile-expr(node, env: (:), default: none) = {
  if node == none or type(node) != dictionary {
    return default
  }

  let id = node.at("id", default: "")
  let arg = (index, fallback) => {
    let nested = _input-nested(node, index)
    if nested != none {
      _compile-expr(nested, env: env, default: fallback)
    } else {
      let raw = _input-value(node, index, default: fallback)
      if type(fallback) == int or type(fallback) == float {
        _num(raw, default: fallback)
      } else if type(fallback) == bool {
        _as-bool(raw, default: fallback)
      } else {
        raw
      }
    }
  }

  if id == "DATA_VARIABLE" {
    let name = _input-value(node, 0, default: "var")
    return env.at(name, default: variable(name))
  }
  if id == "argument_reporter_string_number" or id == "argument_reporter_boolean" {
    let name = _first-label(node, default: "")
    return env.at(name, default: default)
  }
  if id == "unrecognized" and node.at("category", default: "") == "variables" {
    let name = _first-label(node, default: "var")
    return env.at(name, default: variable(name))
  }
  if id == "OPERATORS_ADD" {
    return plus(arg(0, 0), arg(1, 0))
  }
  if id == "OPERATORS_SUBTRACT" {
    return minus(arg(0, 0), arg(1, 0))
  }
  if id == "OPERATORS_MULTIPLY" {
    return multiply(arg(0, 0), arg(1, 0))
  }
  if id == "OPERATORS_DIVIDE" {
    return divide(arg(0, 0), arg(1, 1))
  }
  if id == "OPERATORS_RANDOM" {
    return random(from: arg(0, 1), to: arg(1, 10))
  }
  if id == "OPERATORS_MOD" {
    return modulo(arg(0, 0), arg(1, 1))
  }
  if id == "OPERATORS_ROUND" {
    return round(arg(0, 0))
  }
  if id == "OPERATORS_GT" {
    return greater(arg(0, 0), arg(1, 0))
  }
  if id == "OPERATORS_LT" {
    return less(arg(0, 0), arg(1, 0))
  }
  if id == "OPERATORS_EQUALS" {
    return equals(arg(0, 0), arg(1, 0))
  }
  if id == "OPERATORS_AND" {
    return op-and(arg(0, false), arg(1, false))
  }
  if id == "OPERATORS_OR" {
    return op-or(arg(0, false), arg(1, false))
  }
  if id == "OPERATORS_NOT" {
    return op-not(arg(0, false))
  }

  default
}

#let _literal-or-expr(node, index, default: none) = {
  let nested = _input-nested(node, index)
  if nested != none {
    _compile-expr(nested, env: (:), default: default)
  } else {
    let raw = _input-value(node, index, default: default)
    if type(default) == int or type(default) == float {
      _num(raw, default: default)
    } else if type(default) == bool {
      _as-bool(raw, default: default)
    } else {
      raw
    }
  }
}

#let _literal-or-expr(node, index, env: (:), default: none) = {
  let nested = _input-nested(node, index)
  if nested != none {
    _compile-expr(nested, env: env, default: default)
  } else {
    let raw = _input-value(node, index, default: default)
    if type(default) == int or type(default) == float {
      _num(raw, default: default)
    } else if type(default) == bool {
      _as-bool(raw, default: default)
    } else {
      raw
    }
  }
}

#let _literal-or-expr-non-dropdown(node, env: (:), default: none) = {
  let inputs = _inputs(node)
  for (i, input) in inputs.enumerate() {
    if input.at("shape", default: "") != "dropdown" {
      return _literal-or-expr(node, i, env: env, default: default)
    }
  }
  default
}

#let _flatten(commands) = {
  let out = ()
  for item in commands {
    if type(item) == array {
      out += _flatten(item)
    } else {
      out.push(item)
    }
  }
  out
}

#let _compile-node(node, procedures: (:), env: (:)) = {
  let id = node.id
  let body = node.at("body", default: ())
  let compile-body = nodes => {
    let out = ()
    for nested in nodes {
      out += _compile-node(nested, procedures: procedures, env: env)
    }
    _flatten(out)
  }

  if id == "procedures_call" {
    let name = _procedure-name(node)
    let proc = procedures.at(name, default: none)
    if proc == none {
      return ()
    }

    let call-env = (:)
    let params = proc.at("params", default: ())
    for idx in range(params.len()) {
      let param-name = params.at(idx)
      let value = _literal-or-expr(node, idx, env: env, default: 0)
      call-env.insert(param-name, value)
    }

    let expanded = ()
    for nested in proc.at("body", default: ()) {
      expanded += _compile-node(nested, procedures: procedures, env: call-env)
    }
    return _flatten(expanded)
  }
  if id == "EVENT_WHENFLAGCLICKED" or id == "EVENT_WHENKEYPRESSED" or id == "EVENT_WHENTHISSPRITECLICKED" or id == "EVENT_WHENBACKDROPSWITCHESTO" or id == "EVENT_WHENBROADCASTRECEIVED" or id == "CONTROL_START_AS_CLONE" {
    return compile-body(body)
  }
  if id == "MOTION_MOVESTEPS" {
    return (move(steps: _literal-or-expr(node, 0, env: env, default: 10)),)
  }
  if id == "MOTION_TURNRIGHT" {
    return (turn-right(degrees: _literal-or-expr(node, 0, env: env, default: 15)),)
  }
  if id == "MOTION_TURNLEFT" {
    return (turn-left(degrees: _literal-or-expr(node, 0, env: env, default: 15)),)
  }
  if id == "MOTION_POINTINDIRECTION" {
    return (set-direction(direction: _literal-or-expr(node, 0, env: env, default: 90)),)
  }
  if id == "MOTION_GOTOXY" {
    return (go-to(x: _literal-or-expr(node, 0, env: env, default: 0), y: _literal-or-expr(node, 1, env: env, default: 0)),)
  }
  if id == "MOTION_SETX" {
    return (set-x(x: _literal-or-expr(node, 0, env: env, default: 0)),)
  }
  if id == "MOTION_SETY" {
    return (set-y(y: _literal-or-expr(node, 0, env: env, default: 0)),)
  }
  if id == "MOTION_CHANGEXBY" {
    return (change-x(dx: _literal-or-expr(node, 0, env: env, default: 0)),)
  }
  if id == "MOTION_CHANGEYBY" {
    return (change-y(dy: _literal-or-expr(node, 0, env: env, default: 0)),)
  }
  if id == "PEN_CLEAR" or id == "pen.clear" {
    return (erase-all(),)
  }
  if id == "PEN_STAMP" or id == "pen.stamp" {
    return (stamp(),)
  }
  if id == "PEN_PENDOWN" or id == "pen.penDown" {
    return (pen-down(),)
  }
  if id == "PEN_PENUP" or id == "pen.penUp" {
    return (pen-up(),)
  }
  if id == "PEN_SETPENCOLORTOCOLOR" or id == "pen.setColor" {
    return (set-pen-color(color: _color(_input-value(node, 0, default: black), default: black)),)
  }
  if id == "PEN_CHANGEPENSIZEBY" or id == "pen.changeSize" {
    return (change-pen-size(size: _literal-or-expr(node, 0, env: env, default: 1)),)
  }
  if id == "PEN_SETPENSIZETO" or id == "pen.setSize" {
    return (set-pen-size(size: _literal-or-expr(node, 0, env: env, default: 1)),)
  }
  if id == "pen.changeHue" {
    return (change-pen-param("hue", value: _literal-or-expr(node, 0, env: env, default: 10)),)
  }
  if id == "pen.setHue" {
    return (set-pen-param("hue", value: _literal-or-expr(node, 0, env: env, default: 50)),)
  }
  if id == "pen.changeShade" {
    return (change-pen-param("brightness", value: _literal-or-expr(node, 0, env: env, default: 10)),)
  }
  if id == "pen.setShade" {
    return (set-pen-param("brightness", value: _literal-or-expr(node, 0, env: env, default: 50)),)
  }
  if id == "pen.changeColorParam" {
    return (change-pen-param(_normalize-pen-param(_input-value(node, 0, default: "color"), default: "hue"), value: _literal-or-expr(node, 1, env: env, default: 10)),)
  }
  if id == "pen.setColorParam" {
    return (set-pen-param(_normalize-pen-param(_input-value(node, 0, default: "color"), default: "hue"), value: _literal-or-expr(node, 1, env: env, default: 50)),)
  }
  if id == "DATA_SETVARIABLETO" {
    return (set-variable(_input-dropdown-value(node, default: "var"), _literal-or-expr-non-dropdown(node, env: env, default: 0)),)
  }
  if id == "DATA_CHANGEVARIABLEBY" {
    return (change-variable(_input-dropdown-value(node, default: "var"), _literal-or-expr-non-dropdown(node, env: env, default: 1)),)
  }
  if id == "CONTROL_REPEAT" {
    return ((
      type: "repeat",
      count: _literal-or-expr(node, 0, env: env, default: 10),
      body: compile-body(body),
    ),)
  }
  if id == "CONTROL_FOREVER" {
    return ((
      type: "forever",
      body: compile-body(body),
      limit: 20,
    ),)
  }
  if id == "CONTROL_IF" {
    return ((
      type: "if",
      condition: _literal-or-expr(node, 0, env: env, default: false),
      then_body: compile-body(body),
      else_body: compile-body(node.at("else-body", default: ())),
    ),)
  }
  if id == "CONTROL_REPEATUNTIL" {
    return ((
      type: "repeat-until",
      condition: _literal-or-expr(node, 0, env: env, default: false),
      body: compile-body(body),
      limit: 1000,
    ),)
  }
  if id == "CONTROL_WAIT" {
    return (wait(seconds: _literal-or-expr(node, 0, env: env, default: 1)),)
  }
  if id == "CONTROL_IF_ELSE" {
    return ((
      type: "if",
      condition: _literal-or-expr(node, 0, env: env, default: false),
      then_body: compile-body(body),
      else_body: compile-body(node.at("else-body", default: ())),
    ),)
  }
  ()
}

#let _compile-nodes(nodes, procedures: none, env: (:), depth: 0) = {
  if depth > 32 {
    return ()
  }

  let local-procedures = if procedures == none { (:) } else { procedures }
  let out = ()
  let i = 0
  while i < nodes.len() {
    let node = nodes.at(i)
    let id = node.at("id", default: "")

    if id == "procedures_definition" {
      let name = _procedure-name(node)
      let params = _procedure-params(node)
      let extracted = _extract-procedure-body(nodes, i + 1, proc-name: name)
      if name != "" {
        local-procedures.insert(name, (params: params, body: extracted.at("body", default: ())))
      }
      i = extracted.at("next-index", default: i + 1)
      continue
    }

    if id == "scratchblocks:end" {
      i += 1
      continue
    }

    out += _compile-node(node, procedures: local-procedures, env: env)
    i += 1
  }
  _flatten(out)
}

#let execute-scratch-text(text, language: "en") = _compile-nodes(_parse(text, language))
