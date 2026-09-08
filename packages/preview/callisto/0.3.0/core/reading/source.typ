#import "/core/configuration.typ": parse-main-args, read-enabled
#import "/core/ctx/ctx.typ": get-ctx
#import "cell.typ": cells, cell

// Return the lang of the cell's source
#let _cell-lang(cell, ctx: none) = (
  markdown: "markdown",
  raw: ctx.raw-lang,
  code: ctx.lang,
).at(cell.cell_type)

// Return the cell source as raw block with lang set according to cell type
#let _cell-source(cell, cell-spec: none, cfg: none) = {
  let ctx = get-ctx(cell, cell-spec: cell-spec, cfg: cfg)
  let cell-lang = _cell-lang(cell, ctx: ctx)
  return raw(cell.source, lang: cell-lang, block: true)
}

// Extract the 'source' field from cells as raw blocks
#let sources(..args) = {
  let (cell-spec, cfg) = parse-main-args(..args)
  if read-enabled(cfg: cfg) == false { return () }
  return cells(..args).map(_cell-source.with(cell-spec: cell-spec, cfg: cfg))
}

// Get a single cell's source
#let source(..args) = {
  let (cell-spec, cfg) = parse-main-args(..args)
  if read-enabled(cfg: cfg) == false { return none }
  return _cell-source(cell(..args), cell-spec: cell-spec, cfg: cfg)
}
