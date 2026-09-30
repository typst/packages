#import "/core/reading/notebook.typ"
#import "/core/theming.typ"
#import "/core/configuration.typ"
#import "/core/header-pattern.typ"
#import "preamble.typ"
#import "handling.typ"
#import "outputs.typ"
#import "cells.typ"

// The 'ctx' dict is passed to all handler calls and holds resolved settings
// (replacing most 'auto' values with resolved values) as well as contextual
// data including at least the following fields:
//
// - cell-spec: the cell specification.
// 
// - cfg: a dict with all the settings supported by callisto.config, using
//   default values for settings not set by the user (this holds the
//   non-resolved settings values).
// 
// - cell: the dict of the cell being processed.
//
// - item-desc: a dict with information on the cell item (output item or
//   attachment) being processed, or 'none' otherwise. When not 'none', the
//   dict contains at least the following fields:
//
//    - index: the item index in the cell output list (none for attachments),
//    - type: the output type, or "attachment" for attachments.
//
//   For rich items, this dict contains also
//    - format: the format selected for this rich item
//    - metadata: the format-specific metadata if present, or the whole
//      metadata dict associated with this item otherwise.
// 
// - latex-preamble: a string with all the LaTeX command definitions (of the
//   `\newcommmand` form) found in the notebook, or none if gather-latex-defs
//   is false.

// Return the language name of the given notebook json
#let _nb-lang(nb-json) = {
  if nb-json == none { return none }
  if "language_info" not in nb-json.metadata {
    // This can happen when reading an unexecuted notebook exported by Callisto
    // with lang unset
    return none
  }
  return nb-json.metadata.language_info.name
}

// Return the normalized console-text dictionary, containing at least a
// 'render' field.
#let _resolve-console-text(value) = {
  let render-values = (true, false, "strip", auto)
  if value in render-values {
    return (render: value)
  }
  if type(value) != dictionary {
    panic("invalid console-text: should be true/false/\"strip\"/auto" +
      " or a dictionary")
  }
  if "render" not in value {
    value.render = auto
  }
  if value.render not in render-values {
    panic("invalid console-text.render: should be true/false/\"strip\"/auto")
  }
  return value
}

// Build a ctx dict for the given cell and settings dict.
// The cell value can be none e.g. when building a ctx for placeholders.
#let get-ctx(
  cell,
  cell-spec: none,
  cfg: none,
  item-desc: none,
) = {

  let nb-json = notebook.get-json(cfg: cfg)
  let ctx = cfg

  ctx.cell-header-pattern = header-pattern.resolve(cfg.cell-header-pattern)
  
  if ctx.lang == auto {
    ctx.lang = _nb-lang(nb-json)
  }

  ctx.name-path = cells.resolve-name-path(cfg.name-path)

  if ctx.format == auto {
    ctx.format = outputs.default-formats
  }
  ctx.format = outputs.normalize-formats(ctx.format)

  ctx.handlers = handling.all-handlers(cfg: cfg)

  if ctx.input == auto and cell != none and cell.cell_type == "code" {
    ctx.input = cells.resolve-input(cell, cfg: cfg)
  }

  if ctx.output == auto and cell != none and cell.cell_type == "code" {
    ctx.output = cells.resolve-output(cell, cfg: cfg)
  }

  ctx.console-text = _resolve-console-text(ctx.console-text)

  let latex-preamble = none
  if ctx.gather-latex-defs and (nb-json != none or cell != none) {
    let cells = if nb-json == none { (cell,) } else { nb-json.cells }
    latex-preamble = preamble.latex-preamble(cells)
  }

  return ctx + (
    cell-spec: cell-spec,
    cfg: cfg,
    cell: cell,
    item-desc: item-desc,
    latex-preamble: latex-preamble,
  )
}
