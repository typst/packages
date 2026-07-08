#import "/core/util.typ"
#import "/core/configuration.typ": parse-main-args, read-enabled
#import "/core/ctx/cells.typ": resolve-name-path
#import "/core/header-pattern.typ"
#import "notebook.typ"

// All possible Jupyter cell types
#let all-cell-types = ("code", "markdown", "raw")

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

// Tests whether the cell name matches the user cell spec.
// The 'name' value is interpreted as a path of the form 'x.y.z' in the cell
// dict.
#let name-matches(cell, spec, name) = {
  let value = at-path(cell, name)
  return value == spec or (type(value) == array and spec in value)
}

// List of cell types for the given cell type spec
#let _cell-types(cell-type) = {
  if cell-type == "all" { return all-cell-types }
  let types = util.ensure-array(cell-type)
  for typ in types {
    if typ not in all-cell-types {
      panic("invalid cell type: " + repr(typ))
    }
  }
  return types
}

// Filter the cell list according to the cell type setting
#let _filter-type(cells, cell-type) = {
  let types = _cell-types(cell-type)
  cells.filter(x => x.cell_type in types)
}

// Get cell indices for a single specification.
// If no cell matches, an empty array is returned.
// The cells-of-type array contains cells already filtered to match cell-type.
// The all-cells array contains all cells and can be used for performance for
// cells specified by their index.
#let _cell-indices(spec, cells-of-type, all-cells, cfg: none) = {
  if type(spec) == dictionary {
    // Literal cell
    return _filter-type((spec,), cfg.cell-type).map(c => c.index)
  }
  if type(spec) == function {
    // Filter with given predicate
    return cells-of-type.filter(spec).map(c => c.index)
  }
  if type(spec) == str {
    // Match on any of the specified names
    let names = resolve-name-path(cfg.name-path)
    return cells-of-type
      .filter(x => names.any(name-matches.with(x, spec)))
      .map(c => c.index)
  }
  if type(spec) == label {
    // Typst label: find matches in cell.metadata.callisto.export.typst-label
    return cells-of-type
      .filter(x => name-matches(x, str(spec), "metadata.callisto.export.typst-label"))
      .map(c => c.index)
  }
  if type(spec) == content and spec.func() == raw {
    // Raw element: find code cells with perfect match for source text
    // (including the cell header from cfg for spec, and from cell metadata
    // for the notebook cells).
    // We still work on cells-of-type so if the user filtered for non-code
    // cells there will be no match.

    // Parse spec source into header dict and rest string
    let spec-parsed = header-pattern.parse-text(
      spec.text,
      pattern: cfg.cell-header-pattern,
    )

    // Complete header: cfg header + override from cell text header
    let spec-header = cfg.cell-header + spec-parsed.header

    return _filter-type(cells-of-type, "code")
      .filter(x => {
        // Compare separately the header and the code without header
        x.metadata.callisto.code == spec-parsed.code and x.metadata.callisto.header == spec-header
      })
      .map(c => c.index)
  }
  if type(spec) == int {
    if cfg.count == "index" {
      // Check if index is valid, allowing negative values to count from end
      if spec >= -all-cells.len() and spec < all-cells.len() {
        // Check if type is selected
        let type-ok = all-cells.at(spec).cell_type in _cell-types(cfg.cell-type)
        if type-ok { return (spec,) }
      }
      // Invalid index or bad type -> no match
      return ()
    }
    if cfg.count == "execution" {
      // Different cells can have the same execution_count, e.g. when
      // evaluating only some cells after a kernel restart.
      return cells-of-type
        .filter(x => x.at("execution_count", default: none) == spec)
        .map(c => c.index)
    }
    panic("invalid cell count mode:" + repr(cfg.count))
  }
  panic("invalid cell specification: " + repr(spec))
}

// Return the cells matching the given user spec.
// The spec can a literal cell or array thereof in which case it is simply
// filtered according to the cfg settings. Otherwise, cells will be read from
// the notebook specified in the cfg settings before filtering.
#let _cells-from-spec(spec, cfg: none) = {
  if type(spec) == dictionary and "id" not in spec and "nbformat" in spec {
    panic("invalid literal cell, did you forget the 'nb:' keyword " +
      "while passing a notebook?")
  }
  if type(spec) == dictionary or (
     type(spec) == array and spec.all(x => type(x) == dictionary)) {
    // No need to read the notebook
    // (we assume the literal cells have been properly pre-processed, e.g.
    // to convert header lines to metadata)
    return _filter-type(util.ensure-array(spec), cfg.cell-type)
  }
  let nb-json = notebook.get-json(cfg: cfg)
  if nb-json == none {
    return ()
  }
  let all-cells = notebook.preprocess(nb-json, cfg: cfg).cells
  let cells-of-type = _filter-type(all-cells, cfg.cell-type)
  if spec == none {
    // No spec means select all cells
    return cells-of-type
  }
  let indices = ()
  for s in util.ensure-array(spec) {
    indices += _cell-indices(s, cells-of-type, all-cells, cfg: cfg)
  }
  return indices.dedup().sorted().map(i => all-cells.at(i))
}

// Cell selector: return an array of cells according to the cell specification.
// The function accepts one optional position argument, plus any config
#let cells(..args) = {
  let (cell-spec, cfg) = parse-main-args(..args)
  if read-enabled(cfg: cfg) == false { return () }
  return _cells-from-spec(cell-spec, cfg: cfg)
}

// Get a single cell
#let cell(..args) = {
  let (cell-spec, cfg) = parse-main-args(..args)
  if read-enabled(cfg: cfg) == false { return none }

  let cs = cells(..args)
  if cs.len() != 1 {
    panic("expected 1 cell, found " + str(cs.len()) +
      ". Cell spec was " + repr(cell-spec))
  }
  return cs.first()
}
