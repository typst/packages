#import "reading/cell.typ": cells, cell
#import "reading/common.typ": placeholder-enabled, get-placeholder
#import "util.typ": handle
#import "configuration.typ": parse-main-args, read-enabled
#import "ctx/ctx.typ": get-ctx

// Render the specified cells according to the settings (see common.typ).
#let render(..args) = {
  // Make sure the handlers are called with a context with result: "value"
  let (cell-spec, cfg) = parse-main-args(
    ..args,
    apply-theme: true,
    result: "value",
  )
  if read-enabled(cfg: cfg) == false { return none }
  for c in cells(..args) {
    handle(c, mime: "cell", ctx: get-ctx(c, cell-spec: cell-spec, cfg: cfg))
  }
}

// Helper for rendering from a single cell
#let _render-cell(..args, func-name: none) = {
  // Make sure the handlers are called with a context with result: "value"
  let (cell-spec, cfg) = parse-main-args(
    ..args,
    apply-theme: true,
    result: "value",
  )

  let cs = cells(..args)

  if placeholder-enabled(cfg: cfg) and (
    cs.len() == 0 or
    cs.len() == 1 and func-name == "Out" and cs.first().execution_count == none
  ) {
    let ctx = get-ctx(none, cell-spec: cell-spec, cfg: cfg)
    return get-placeholder(mime: "placeholder-" + func-name, ctx: ctx)
  }
  
  if cs.len() != 1 {
    panic("expected 1 cell, found " + str(cs.len()) +
      ". Cell spec was " + repr(cell-spec))
  }

  let c = cs.first()
  handle(c, mime: "cell", ctx: get-ctx(c, cell-spec: cell-spec, cfg: cfg))
}

// Render a single cell
#let Cell(..args) = _render-cell(
  ..args,
  func-name: "Cell",
)
// Render a single code cell's input
#let In(..args) = _render-cell(
  ..args,
  cell-type: "code",
  input: true,
  output: false,
  func-name: "In",
)
// Render a single code cell's output
#let Out(..args) = _render-cell(
  ..args,
  cell-type: "code",
  input: false,
  output: true,
  func-name: "Out",
)
