#import "/core/ctx/handling.typ": all-handlers
#import "/core/header-pattern.typ"
#import "/core/configuration.typ": read-enabled

// Return the notebook as JSON, without any processing
#let get-json(cfg: none) = {
  if cfg.nb == none {
    return none
  }
  if type(cfg.nb) == bytes {
    return json(cfg.nb)
  }
  if type(cfg.nb) == dictionary {
    return cfg.nb
  }
  if type(cfg.nb) != path {
    panic("invalid notebook type: " + str(type(cfg.nb)))
  }
  if not read-enabled(cfg: cfg) {
    return none
  }
  let handlers = all-handlers(cfg: cfg)
  return json(cfg.nb)
}

// Ensure each cell source is a single string.
#let normalize-cell-source(cell) = {
  if "source" in cell and type(cell.source) == array {
    cell.source = cell.source.join() // will be none if array is empty
  }
  if "source" not in cell or cell.source == none {
    cell.source = ""
  }
  return cell
}

// Convert metadata in code header to cell metadata
#let _process-cell-header(cell, cfg: none) = {
  let parsed = header-pattern.parse-text(
    cell.source,
    pattern: cfg.cell-header-pattern,
  )
  cell.metadata.callisto.header = parsed.header
  cell.metadata.callisto.code = parsed.code

  // Remove header from source if necessary
  if not cfg.keep-cell-header {
    cell.source = parsed.code
  }

  return cell
}

// Normalize cell dict (ensuring the source is a single string rather than an
// array with one string per line) and convert source header metadata to cell
// metadata, using cell-header-pattern to recognize and parse cell header lines.
// Also ensures that the cell has a metadata.callisto dictionary.
// The positional parameters are the cell index and original cell dict.
#let _preprocess-cell(cell, index: none, cfg: none) = {
  if type(index) != int {
    panic("cell index must be an integer")
  }

  if "id" not in cell {
    cell.id = str(index)
  }
  cell.index = index

  // Normalize source field to a single string
  cell = normalize-cell-source(cell)

  if "callisto" not in cell.metadata {
    cell.metadata.callisto = (:)
  }
  if cell.cell_type == "code" {
    cell = _process-cell-header(cell, cfg: cfg)
  }
  return cell
}

// Preprocess notebook dict, so it can be used as 'nb' setting in Callisto
// functions
#let preprocess(nb-json, cfg: none) = {
  nb-json.cells = nb-json.cells.enumerate().map(
    ((i, c)) => _preprocess-cell(c, index: i, cfg: cfg)
  )
  return nb-json
}
