#import "/core/util.typ": ensure-array, handle
#import "/core/configuration.typ": parse-main-args, read-enabled
#import "/core/ctx/ctx.typ": get-ctx
#import "common.typ": final-result, single-output
#import "cell.typ": cells
#import "rich-object.typ"
#import "stream.typ"
#import "error.typ"

#let all-output-types = ("display", "result", "stream", "error")
#let rich-output-types = ("display", "result")

// Map of json output type to our output type
#let output-types-from-json = (
  "display_data": "display",
  "execute_result": "result",
  "stream": "stream",
  "error": "error",
)

// The module that implements 'preprocess' for each output type
#let processor-modules = (
  display: rich-object,
  result: rich-object,
  stream: stream,
  error: error,
)

// Resolve 'output-type' setting to a list of desired output types
#let _output-types(types) = {
  if types == "all" { return all-output-types }
  let types = ensure-array(types)
  for typ in types {
    if typ not in all-output-types {
      panic("invalid output type: " + repr(typ))
    }
  }
  return types
}

// Extract outputs from the specified cell.
// Can return several outputs per cell. The return value is always an array.
#let outputs(..args) = {
  let (cell-spec, cfg) = parse-main-args(..args)
  if read-enabled(cfg: cfg) == false { return () }
  let output-types = _output-types(cfg.output-type)
  let outs = ()
  for cell in cells(..args, cell-type: "code") {
    for (i, item) in cell.outputs.enumerate() {
      // Ignore items with undesired output type
      let output-type = output-types-from-json.at(item.output_type)
      if output-type not in output-types { continue }
      // Make context for processor
      let ctx = get-ctx(
        cell,
        cell-spec: cell-spec,
        cfg: cfg,
        item-desc: (index: i, type: output-type),
      )

      // The processing is split in two output-type-specific steps:
      // preprocessing and "rendering". The preprocessed data is used
      // as argument to the handler and to populate the final result when
      // 'result' is "dict". The handler takes the preprocessed data and
      // returns the rendered value.

      // Get processor module
      let proc-module = processor-modules.at(output-type)
      // Get dict with normalized data for this item
      let preprocessed = proc-module.preprocess(item, ctx: ctx)
      if preprocessed == none { continue }
      let value = handle(preprocessed, mime: "output", ctx: ctx)
      if value == none { continue }
      // Make final result (value or dict)
      let result = final-result(preprocessed, value, ctx: ctx)
      outs.push(result)
    }
  }
  return outs
}

// Extract a single output
#let output(..args) = {
  let (cell-spec, cfg) = parse-main-args(..args)
  let ctx = get-ctx(none, cell-spec: cell-spec, cfg: cfg)
  single-output(outputs(..args), ctx: ctx)
}
