#import "/core/util.typ"
#import "/core/reading/common.typ": get-header-bool

// Default places to look in cell dict for cell "name"
#let default-names = ("metadata.callisto.header.label", "id", "metadata.tags")

// Resolve 'name-path' setting to an array of name paths
#let resolve-name-path(path) = {
  if path == auto {
    return default-names
  }
  return util.ensure-array(path)
}

// Resolves cfg.input using the cell header if auto
#let resolve-input(cell, cfg: none) = {
  if cfg.input == auto {
    return get-header-bool(cell, "echo", "true")
  }
  return cfg.input
}

// Resolves cfg.output using the cell header if auto
#let resolve-output(cell, cfg: none) = {
  if cfg.output == auto {
    return get-header-bool(cell, "output", "true")
  }
  return cfg.output
}
