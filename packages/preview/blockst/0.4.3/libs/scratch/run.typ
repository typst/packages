#import "interpreter.typ": _scratch-run-commands, blockst-run-options
#import "text/execute.typ": execute-scratch-text

#let _normalize-source(program) = {
  if type(program) == content and program.func() == raw {
    program = program.text
  }
  if type(program) == str { program } else { str(program) }
}

#let stage(
  program,
  language: auto,
  size: auto,
  scale: auto,
  start: auto,
  pen: auto,
  background: auto,
  cursor: auto,
  border: auto,
) = context {
  let program = _normalize-source(program)
  let options = blockst-run-options.final()
  let lang = if language != auto { language } else { options.at("language", default: "en") }
  let resolved-size = if size == auto { auto } else { size }
  let start-x = if start == auto { auto } else { start.at("x", default: auto) }
  let start-y = if start == auto { auto } else { start.at("y", default: auto) }
  let start-angle = if start == auto { auto } else { start.at("angle", default: auto) }
  let pen-down = if pen == auto { auto } else { pen.at("down", default: auto) }
  let start-color = if pen == auto { auto } else { pen.at("color", default: auto) }
  let start-thickness = if pen == auto { auto } else { pen.at("size", default: auto) }
  _scratch-run-commands(
    mode: "stage",
    width: if resolved-size == auto { auto } else { resolved-size.at(0) },
    height: if resolved-size == auto { auto } else { resolved-size.at(1) },
    start-x: start-x,
    start-y: start-y,
    start-angle: start-angle,
    pen-down: pen-down,
    start-color: start-color,
    start-thickness: start-thickness,
    unit: scale,
    background: background,
    show-cursor: cursor,
    show-border: border,
    ..execute-scratch-text(program, language: lang),
  )
}

#let grid(
  program,
  language: auto,
  x: auto,
  y: auto,
  step: auto,
  scale: auto,
  start: auto,
  pen: auto,
  background: auto,
  axes: auto,
  grid: auto,
  grid-style: auto,
  cursor: auto,
  fit: auto,
) = context {
  let program = _normalize-source(program)
  let options = blockst-run-options.final()
  let lang = if language != auto { language } else { options.at("language", default: "en") }
  let start-x = if start == auto { auto } else { start.at("x", default: auto) }
  let start-y = if start == auto { auto } else { start.at("y", default: auto) }
  let start-angle = if start == auto { auto } else { start.at("angle", default: auto) }
  let pen-down = if pen == auto { auto } else { pen.at("down", default: auto) }
  let start-color = if pen == auto { auto } else { pen.at("color", default: auto) }
  let start-thickness = if pen == auto { auto } else { pen.at("size", default: auto) }
  _scratch-run-commands(
    mode: "grid",
    start-x: start-x,
    start-y: start-y,
    start-angle: start-angle,
    pen-down: pen-down,
    start-color: start-color,
    start-thickness: start-thickness,
    unit: scale,
    background: background,
    show-axes: axes,
    grid-step: step,
    show-grid: grid,
    grid-stroke: grid-style,
    show-cursor: cursor,
    view-x: x,
    view-y: y,
    fit: fit,
    ..execute-scratch-text(program, language: lang),
  )
}