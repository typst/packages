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

#let _resolve-template(name) = {
  if name not in templates.cell-templates {
    panic("template name not found: " + name)
  }
  return templates.cell-templates.at(name)
}

// Return a normalized value for the given key of the given template dict,
// returning a function or none.
// Unlike _normalize-template, this doesn't create a new template function to
// handle various cell types: it only resolves a single field, possibly by
// digging recursively in dictionaries. When the key is `code`, the dict must
// have `input` and `output` keys with values already resolved to functions or
// none: these values might be used for the code template.
#let _normalize-subtemplate(dict, key) = {
  // Handle case where "code" is requested but not explicitly defined
  if key == "code" and "code" not in dict {
    if dict.input == none and dict.output == none {
      return none
    }
    return _code-template.with(dict.input, dict.output)
  }

  let value = dict.at(key, default: none)
  if type(value) == str {
    value = _resolve-template(value)
  }
  if type(value) == function or value == none {
    return value
  }
  if type(value) == dictionary {
    return _normalize-subtemplate(value, key)
  }
  panic("invalid subtemplate type: " + str(type(value)))
}

// Normalize a template name/function/dict/none to a function or none
#let _normalize-template(value) = {
  if value == none {
    return none
  }
  if type(value) == function {
    return value
  }
  if type(value) == str {
    return _normalize-template(_resolve-template(value))
  }
  if type(value) != dictionary {
    panic("invalid template type: " + str(type(value)))
  }
  let dict = value
  // For a dict, we normalize the fields and then make a template function.
  // We must normalize the input and output fields before the code field.
  dict.input = _normalize-subtemplate(dict, "input")
  dict.output = _normalize-subtemplate(dict, "output")
  dict.code = _normalize-subtemplate(dict, "code")
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
  cell-header-pattern: auto,
  keep-cell-header: false,
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
  if template == none {
    return
  }
  let processed-nb = if nb == none {
    none
  } else {
    _read-notebook(nb, cell-header-pattern, keep-cell-header)
  }
  // Get lang from notebook if auto, so that the value can be passed to
  // templates (which don't receive the notebook itself)
  if lang == auto {
    if processed-nb == none {
      lang = none
    } else {
      lang = _notebook-lang(processed-nb)
    }
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
    nb: processed-nb,
    count: count,
    name-path: name-path,
    cell-type: cell-type,
    keep: keep,
    cell-header-pattern: cell-header-pattern,
    keep-cell-header: keep-cell-header,
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
#let In = Cell.with(cell-type: "code", output: false)
#let Out = Cell.with(cell-type: "code", input: false)
