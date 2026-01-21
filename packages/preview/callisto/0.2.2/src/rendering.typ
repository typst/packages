#import "reading.typ": *
#import "templates.typ"

// A code template function that uses input and output template functions.
// Both input and output keywords are forwarded to the input/output templates to
// let them use this information for example to produce smaller spacing between
// input and output when both components are rendered.
#let _code-template(
  input-func,
  output-func,
  input: true,
  output: true,
   ..args,
) = {
  if input and input-func != none {
    input-func(input: input, output: output, ..args)
  }
  if output and output-func != none {
    output-func(input: input, output: output, ..args)
  }
}

// A template function that delegates to a dict field for each cell type
#let _merged-template(dict,  cell, ..args) = {
  let f = dict.at(cell.cell_type, default: none)
  if f != none {
    f(cell, ..args)
  }
}

#let _null-template(..args) = none

#let _resolve-template(name) = {
  if name not in templates.cell-templates {
    panic("template name not found: " + name)
  }
  return templates.cell-templates.at(name)
}

// Normalize a subtemplate name/function/dict/none to a function or none
#let _normalize-subtemplate(dict, name) = {
  let value = dict.at(name, default: none)
  if type(value) == str {
    value = _resolve-template(value)
  }
  if type(value) == dictionary {
    return _normalize-subtemplate(value, name)
  }
  if type(value) == function or value == none {
    return value
  }
  panic("invalid subtemplate type: " + str(type(value)))
}

// Normalize a template name/function/dict/none to a function
#let _normalize-template(value) = {
  if type(value) == function {
    return value
  }
  if value == none {
    return _null-template
  }
  if type(value) == str {
    if value not in templates.cell-templates {
      panic("template name not found: " + value)
    }
    let resolved = templates.cell-templates.at(value)
    return _normalize-template(resolved)
  }
  if type(value) != dictionary {
    panic("invalid template type: " + str(type(value)))
  }
  let dict = value
  // For a dict, we normalize the fields and then make a template function.
  // We must normalize the input and output fields before the code field.
  dict.input = _normalize-subtemplate(dict, "input")
  dict.output = _normalize-subtemplate(dict, "output")
  if "code" in dict or (dict.input == none and dict.output == none) {
    // We can normalize the existing subtemplate, or fall back on none
    dict.code = _normalize-subtemplate(dict, "code")
  } else {
    // No code subtemplate defined, but input/output is defined
    dict.code = _code-template.with(dict.input, dict.output)
  }
  dict.markdown = _normalize-subtemplate(dict, "markdown")
  dict.raw = _normalize-subtemplate(dict, "raw")

  return _merged-template.with(dict)
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
  template = _normalize-template(template)
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
      unused: none, // to check the template accepts extra arguments
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
