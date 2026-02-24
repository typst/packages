#import "reading.typ": *
#import "templates.typ"

#let _template-from-name(name) = {
  if name not in templates.cell-templates {
    panic("template name not found: " + name)
  }
  return templates.cell-templates.at(name)
}

#let _subtemplate(dict, name) = {
  let f = dict.at(name, default: none)
  if f == none {
    return (..args) => none
  }
  if type(f) == str {
    return _template-from-name(f).at(name)
  }
  if type(f) != function {
    panic("unsupported template type for " + name + ": " + type(f))
  }
  return f
}

// Render a cell by using the sub-templates specified in the
// `templates` dictionary, with fields: raw, markdown, code, input, output.
#let cell-template(
  cell,
  templates: (:),
  input: true,
  output: true,
   ..args,
) = {
  if cell.cell_type != "code" or "code" in templates {
    let f = _subtemplate(templates, cell.cell_type)
    return f(cell, ..args, input: input, output: output)
  }
  // We have a code cell and no code template
  // -> render input and output separately
  if input {
    let f = _subtemplate(templates, "input")
    f(cell, ..args)
  }
  if output {
    let f = _subtemplate(templates, "output")
    f(cell, ..args)
  }
}

#let render(
  // Cell args
  ..cell-spec,
  nb: none,
  count: "index",
  name-path: auto,
  cell-type: "all",
  keep: "all",
  // Other args
  lang: auto,
  raw-lang: none,
  result: "value", // unused but accepted to have more uniform API
  stream: "all",
  format: auto,
  handlers: auto,
  ignore-wrong-format: false,
  template: "notebook",
  output-type: "all",
  input: true,
  output: true,
) = {
  if type(template) == str {
    template = _template-from-name(template)
  }
  if type(template) == dictionary {
    template = cell-template.with(templates: template)
  }
  if nb != none {
    nb = read-notebook(nb)
  }
  // Get lang from notebook if auto, so that the value can be passed to
  // templates (which don't receive the notebook itself)
  if lang == auto {
    lang = notebook-lang(nb)
  }

  // Arguments for rendering cell inputs
  let input-args = (
    lang: lang,
    raw-lang: raw-lang,
  )
  // Arguments for rendering cell outputs
  let output-args = (
    stream: stream,
    format: format,
    handlers: handlers,
    ignore-wrong-format: ignore-wrong-format,
    output-type: output-type,
  )

  for cell in cells(
    ..cell-spec,
    nb: nb,
    count: count,
    name-path: name-path,
    cell-type: cell-type,
    keep: keep,
  ) {
    template(
      cell,
      template: template,
      handlers: handlers,
      input: input,
      output: output,
      input-args: input-args,
      output-args: output-args,
    )
  }
}

#let Cell = render.with(keep: "unique")
#let In = Cell.with(output: false)
#let Out = Cell.with(input: false)
