#import "@preview/based:0.2.0": base64
#import "@preview/cmarker:0.1.3"
#import "@preview/mitex:0.2.5"

#let handler-base64-image(data) = image(base64.decode(data.replace("\n", "")))
#let handler-str-image(data) = image(bytes(data))
#let handler-text(data) = data
#let handler-markdown(data) = cmarker.render(data, math: mitex.mitex)
#let handler-latex(data) = mitex.mitext(data)

#let cell-header-pattern = regex("^#\|\s+(.*?):\s+(.*?)\s*$")
#let default-formats = ("image/svg+xml", "image/png", "text/markdown", "text/latex", "text/plain")
#let default-handlers = (
  "image/svg+xml": handler-str-image,
  "image/png": handler-base64-image,
  "image/jpeg": handler-base64-image,
  "text/markdown": handler-markdown,
  "text/latex": handler-latex,
  "text/plain": handler-text,
)
#let default-names = ("metadata.label", "id", "metadata.tags")
#let all-output-types = ("display_data", "execute_result", "stream", "error")

// Normalize cell dict (ensuring the source is a single string rather than an
// array with one string per line) and convert source header metadata to cell
// metadata.
#let process-cell(i, cell) = {
  if "id" not in cell {
    cell.id = str(i)
  }
  cell.index = i
  let source = cell.at("source", default: "")
  if type(source) == array {
    // Normalize source field to a single string
    source = if source.len() == 0 { "" } else { source.join() }
  }
  if cell.cell_type == "code" {
    let source_lines = source.split("\n")

    // Convert metadata in code header to cell metadata
    let n = 0
    for line in source_lines {
      let m = line.match(cell-header-pattern)
      if m == none {
        break
      }
      n += 1
      let (key, value) = m.captures
      cell.metadata.insert(key, value)
    }
    // If there was a header, remove it from the source
    if n > 0 {
      source = source_lines.slice(n).join("\n")
    }
  }
  return (
    ..cell,
    source: source,
  )
}

#let read-notebook(nb) = {
  if type(nb) not in (str, bytes, dictionary) {
    panic("invalid notebook type: " + str(type(nb)))
  }
  if type(nb) in (str, bytes) {
    nb = json(nb)
  }
  if not nb.metadata.at("nbio-processed", default: false) {
    nb.cells = nb.cells.enumerate().map( ((i, c)) => process-cell(i, c) )
  }
  return nb
}

#let notebook-lang(nb) = {
  if nb == none {
    return none
  }
  return read-notebook(nb).metadata.language_info.name
}

// Get value at given path in recursive dict.
// The path can be a string of the form `key1.key2....`, or an array
// `(key1, key2, ...)`.
#let at-path(dict, path, default: none) = {
  if type(path) == str { return at-path(dict, path.split(".")) }
  let (key, ..rest) = path
  if key not in dict { return default }
  let value = dict.at(key)
  if rest == () { return value }
  return at-path(value, rest)
}

#let ensure-array(x) = if type(x) == array { x } else { (x,) }

#let name-matches(cell, spec, name) = {
  let value = at-path(cell, name)
  return value == spec or (type(value) == array and spec in value)
}

#let _cell-type-array(cell-type) = {
  if cell-type == "all" {
    cell-type = ("code", "markdown", "raw")
  }
  return ensure-array(cell-type)
}

#let _filter-type(cells, cell-type) = {
  let types = _cell-type-array(cell-type)
  cells.filter(x => x.cell_type in types)
}

// Get cell indices for a single specification.
// If no cell matches, an empty array is returned.
// The cells-of-type array contains cells already filtered to match cell-type.
// The all-cells array contains all cells and can be used for performance for
// cells specified by their index.
#let _cell-indices(spec, cell-type, cells-of-type, all-cells, count, name-path) = {
  if type(spec) == dictionary {
    // Literal cell
    return _filter-type((spec,), cell-type).map(c => c.index)
  }
  if type(spec) == function {
    // Filter with given predicate
    return cells-of-type.filter(spec).map(c => c.index)
  }
  if type(spec) == str {
    // Match on any of the specified names
    let names = if name-path == auto {
      default-names
    } else {
      ensure-array(name-path)
    }
    return cells-of-type
      .filter(x => names.any(name-matches.with(x, spec)))
      .map(c => c.index)
  }
  if type(spec) == int {
    if count == "index" {
      let type-ok = all-cells.at(spec).cell_type in _cell-type-array(cell-type)
      return if type-ok { (spec,) } else { () }
    }
    if count == "execution" {
      // Different cells can have the same execution_count, e.g. when evaluating
      // only some cells after a kernel restart.
      return cells-of-type
        .filter(x => x.at("execution_count", default: none) == spec)
        .map(c => c.index)
    }
    panic("invalid cell count mode:" + repr(count))
  }
  panic("invalid cell specification: " + repr(spec))
}

#let _apply-keep(cells, keep) = {
  if keep == "all" {
    return cells
  }
  if keep == "unique" {
    if cells.len() != 1 {
      panic("expected 1 cell, found " + str(cells.len()))
    }
    return cells
  }
  if type(keep) == int {
    return (cells.at(keep),)
  }
  if type(keep) == array {
    return keep.map(i => cells.at(i))
  }
  panic("invalid keep value: " + repr(keep))
}

#let _cells-from-spec(spec, nb, count, name-path, cell-type) = {
  if type(spec) == dictionary and "id" not in spec and "nbformat" in spec {
    panic("invalid literal cell, did you forget the `nb:` keyword while passing a notebook?")
  }
  if type(spec) == dictionary or (
     type(spec) == array and spec.all(x => type(x) == dictionary)) {
    // No need to read the notebook
    return _filter-type(ensure-array(spec), cell-type)
  }
  let all-cells = read-notebook(nb).cells
  let cells-of-type = _filter-type(all-cells, cell-type)
  if spec == none {
    // No spec means select all cells
    return cells-of-type
  }
  let indices = ()
  for s in ensure-array(spec) {
    indices += _cell-indices(s, cell-type, cells-of-type, all-cells, count, name-path)
  }
  return indices.dedup().sorted().map(i => all-cells.at(i))
}

// Cell selector
#let cells(
  ..args,
  nb: none,
  count: "index",
  name-path: auto,
  cell-type: "all",
  keep: "all",
) = {
  if args.named().len() > 0 {
    panic("invalid named arguments: " + repr(args.named()))
  }
  if args.pos().len() > 1 {
    panic("expected 1 positional argument, got " + str(args.pos().len()))
  }
  let spec = args.pos().at(0, default: none)
  let cs = _cells-from-spec(spec, nb, count, name-path, cell-type)
  return _apply-keep(cs, keep)
}

#let cell(..args, keep: "unique") = cells(..args, keep: keep).first()

#let normalize-formats(formats) = {
  formats = ensure-array(formats)
  let i = formats.position(x => x == auto)
  if i != none {
    // Replace auto value with list of default formats
    formats = formats.slice(0, i) + default-formats + formats.slice(i + 1)
  }
  return formats
}

#let pick-format(available, precedence: auto) = {
  precedence = normalize-formats(precedence)
  // Pick the first desired format that is available, or none
  return precedence.find(f => f in available)
}

#let get-all-handlers(handlers) = {
  if handlers == auto {
    return default-handlers
  }
  if type(handlers) != dictionary {
    panic("handlers must be auto or a dictionary mapping formats to functions")
  }
  // Start with default handlers and add/overwrite with provided ones
  return default-handlers + handlers
}

#let read-mime(data, format: default-formats, handlers: auto) = {
  if type(data) == array {
    data = data.join()
  }
  let all-handlers = get-all-handlers(handlers)
  if format not in all-handlers {
    panic("format " + repr(format) + " has no registered handler")
  }
  let handler = all-handlers.at(format)
  if type(handler) != function {
    panic("handler must be a function or a dict of functions")
  }
  return handler(data)
}

// Process a "rich" item, which can have various formats.
// Can return none if item is available only in unsupported formats (and
// ignore-wrong-format is true) or if the item is empty (data dict empty in
// notebook JSON).
#let process-rich(
  item,
  format: auto,
  handlers: auto,
  ignore-wrong-format: false,
  ..args,
) = {
  let item-formats = item.data.keys()
  if item-formats.len() == 0 {
    return none
  }
  let fmt = pick-format(item-formats, precedence: format)
  if fmt == none {
    if not ignore-wrong-format {
      panic("output item has no appropriate format: item has " +
        repr(item-formats) + ", we want " + repr(normalize-formats(format)))
    }
    return none
  }
  let value = read-mime(item.data.at(fmt), format: fmt, handlers: handlers)
  return (
    type: item.output_type,
    format: fmt,
    metadata: item.metadata.at(fmt, default: none),
    value: value,
  )
}

// Process a stream item.
// Can return none if the item is from an undesired stream (cf `stream` arg.)
#let process-stream(item, stream: "all", ..args) = {
  if stream == none {
    return none
  }
  if stream == "all" {
    stream = ("stdout", "stderr")
  }
  let streams = ensure-array(stream)
  if item.name not in streams {
    return none
  }
  let value = item.text
  if type(value) == array {
    value = value.join()
  }
  return (
    type: "stream",
    name: item.name,
    value: value,
  )
}

// Process an error item.
#let process-error(item, ..args) = (
  type: "error",
  name: item.ename,
  value: item.evalue,
  traceback: item.traceback,
)

#let processors = (
  display_data: process-rich,
  execute_result: process-rich,
  stream: process-stream,
  error: process-error,
)

#let cell-output-dict(cell) = (
  index: cell.index,
  id: cell.id,
  metadata: cell.metadata,
  type: cell.cell_type,
) + if cell.cell_type == "code" {
  (execution-count: cell.execution_count)
}

#let final-output(cell, result-spec, dict) = { 
  if result-spec == "value" {
    return dict.value
  }
  if result-spec == "dict" {
    dict.cell = cell-output-dict(cell)
    return dict
  }
  panic("invalid result specification: " + repr(result))
}

#let outputs(
  ..cell-args,
  output-type: "all",
  format: default-formats,
  handlers: auto,
  ignore-wrong-format: false,
  stream: "all",
  result: "value",
) = {
  if output-type == "all" {
    output-type = all-output-types
  }
  let output-types = ensure-array(output-type)
  for typ in output-types {
    if typ not in all-output-types {
      panic("invalid output type: " + typ)
    }
  }
  let process-args = (
    format: format,
    handlers: handlers,
    ignore-wrong-format: ignore-wrong-format,
    stream: stream,
  )
  let cs = cells(..cell-args, cell-type: "code")
  let outs = ()
  for cell in cs {
    outs += cell.outputs
      .filter(x => x.output_type in output-types)
      .map(x => (processors.at(x.output_type))(x, ..process-args))
      .filter(x => x != none)
      .map(final-output.with(cell, result))
  }
  return outs
}

#let single-item(items, item: "unique") = {
  if items.len() == 0 {
    panic("No matching item found")
  }
  if item == "unique" {
    if items.len() != 1 {
      panic("expected 1 item, found " + str(items.len()))
    }
    item = 0
  }
  return items.at(item)
}

#let output(..args, item: "unique") = single-item(outputs(..args), item: item)

#let displays     = outputs.with(output-type: "display_data")
#let results      = outputs.with(output-type: "execute_result")
#let errors       = outputs.with(output-type: "error")
#let stream-items = outputs.with(output-type: "stream")

#let display     = output.with(output-type: "display_data")
#let result      = output.with(output-type: "execute_result")
#let error       = output.with(output-type: "error")
#let stream-item = output.with(output-type: "stream")

// Same as stream-items, but merges all streams (matching `stream`) of the same cell, and always returns an item (possibly with an empty string as value) for each selected cell (of code type).
#let streams(
  ..cell-args,
  output-type: "all",
  format: default-formats,
  handlers: auto,
  ignore-wrong-format: false,
  stream: "all",
  result: "value",
) = {
  let cs = cells(..cell-args, cell-type: "code")
  let outs = ()
  for cell in cs {
    // Start value
    let out = (
      type: "stream",
      name: stream,
      value: "",
    )
    // Append all stream items to value
    for item in outputs(cell, output-type: "stream", stream: stream, result: "value") {
      out.value += item
    }
    outs.push(final-output(cell, result, out))
  }
  return outs
}

#let stream(..args, item: "unique") = single-item(streams(..args), item: item)

#let _cell-lang(cell, lang, raw-lang) = (
  markdown: "markdown",
  raw: raw-lang,
  code: lang,
).at(cell.cell_type)

#let sources(..args, result: "value", lang: auto, raw-lang: none) = {
  if lang == auto {
    let nb = args.named().at("nb", default: none)
    lang = notebook-lang(nb)
  }
  let cs = cells(..args)
  let srcs = ()
  for cell in cs {
    let cell-lang = _cell-lang(cell, lang, raw-lang)
    let value = raw(cell.source, lang: cell-lang, block: true)
    srcs.push(final-output(cell, result, (value: value)))
  }
  return srcs
}

#let source(..args, item: "unique") = single-item(sources(..args), item: item)
