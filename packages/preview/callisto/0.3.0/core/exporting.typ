#import "/core/header-pattern.typ"
#import "/core/rendering.typ"
#import "/core/reading/reading.typ"
#import "configuration.typ"

// Label for exported raw elements
#let _element-label = label("__callisto:exported-element")

// Get all the export names found in the document. Requires context.
#let export-names() = {
  query(_element-label).map(x => x.value.export-name).dedup()
}

// Return the export metadata for the given raw element.
#let export(..args) = {

  // The cell-spec is a raw element in this case
  let (cell-spec: elem, cfg) = configuration.parse-main-args(..args)
  if type(elem) != content or elem.func() != raw {
    panic("expecting a raw element, got " +
      repr(if type(elem) == content { elem.func() } else { type(elem) }))
  }

  // Export functionality is enabled when the kernel is specified
  if cfg.kernel == none {
    panic("the Jupyter kernel must be specified")
  }

  // First get header dict and rest of source from raw source
  let parsed = header-pattern.parse-text(
    elem.text,
    pattern: cfg.cell-header-pattern,
  )
  // Now make header text from combined config header and source header
  let header-text = header-pattern.make-text(
    cfg.cell-header + parsed.header,
    pattern: cfg.cell-header-pattern,
  )

  // We store the raw fields rather than the raw element itself, to avoid
  // having it show up in `query(raw)`
  let dict = (
    export-name: cfg.export-name,
    kernel: cfg.kernel,
    text: header-text + parsed.code,
    lang: elem.at("lang", default: none),
    block: elem.at("block", default: true),
    label: elem.at("label", default: none),
  )
  return [#metadata(dict)#_element-label]
}

// Make cell metadata for given raw element dict
#let _cell-metadata(elem) = (
  callisto: (
    export: (
      lang: elem.lang,
      block: elem.block,
      typst-label: if elem.label == none { none } else { str(elem.label) },
    ),
  ),
)

// Make a JSON cell for the given raw element dict, deriving an ID from the
// given cell index.
#let _make-cell(i, elem) = {
  (
    id: "cell-id-" + str(i),
    cell_type: "code",
    metadata: _cell-metadata(elem),
    source: elem.text,
    outputs: (),
    execution_count: none,
  )
}

// Make notebook metadata
#let _notebook-metadata(kernel, lang, export-name) = {
  let md = (
    callisto: (
      version: toml("/typst.toml").package.version,
      export-name: export-name,
    ),
    // A kernelspec must contain a display name, but it's
    // not used to find the kernel so we can pick one ourselves
    kernelspec: (name: kernel, display_name: kernel),
  )
  // The language info is normally written by the kernel upon execution, but it
  // can be helpful to set it in case the notebook is read without execution
  if lang not in (auto, none) {
    md.language_info = (name: lang)
  }
  return md
}

// Make a notebook dictionary from the given raw elements (or dicts with the
// same fields as raw), language_info and kernelspec. The lang parameter is used
// to infer lang-info if unspecified.
// If lang is auto, the lang of the first element is used.
#let _notebook-from-raw-elements(elems, kernel, lang, export-name) = {
  let cells = elems.enumerate().map(x => _make-cell(..x))
  let md
  let nb = (
    cells: cells,
    metadata: _notebook-metadata(kernel, lang, export-name),
    nbformat: 4,
    nbformat_minor: 5,
  )
  return nb
}

// Return the metadata required for exporting a Jupyter notebook containing
// as code cells all the raw blocks exported with the configured export-name.
//
// This function requires context.
#let make-notebook(..args) = {
  let (cell-spec, cfg) = configuration.parse-main-args(..args)

  // Check that no cell specification was given
  if cell-spec != none {
    panic("unexpected argument: " + repr(cell-spec))
  }

  // Get all raw elements to export
  let elems = query(_element-label)
    .filter(x => x.value.export-name == cfg.export-name)
    .map(x => x.value)

  // Check that all raw elements have the same kernel
  let kernels = elems.map(x => x.kernel).dedup()
  if kernels.len() > 1 {
    panic("export \" + export-name + \"" +
      "includes elements with different kernels: " + repr(kernels))
  }

  // Give precedence to cfg.kernel to allow for override and to avoid error
  // when there's no exported cell yet, but fall back on kernel of exported raw
  // elements to allow config-less calls
  let kernel = cfg.kernel
  if kernel == none {
    if kernels.len() == 0 {
      panic("the Jupyter kernel must be specified")
    }
    kernel = kernels.first()
  }

  return _notebook-from-raw-elements(elems, kernel, cfg.lang, cfg.export-name)
}

// Return the labeled metadata element that should be inserted in the document
// so that `typst eval` can find the exported notebook.
#let stage-notebook(..args) = context {
  let (cfg,) = configuration.parse-main-args(..args)

  let export-label = cfg.export-label
  if export-label == auto {
    export-label = label(cfg.export-name)
  }

  let md = metadata(make-notebook(..args))
  return [#md#export-label]
}

// Return export metadata and cell rendering/output (depending on value-func),
// looking for the single cell that corresponds to the raw cell spec.
#let _exec(value-func: none, ..args) = {
  let (cell-spec, cfg) = configuration.parse-main-args(..args)
  let export-md = export(cell-spec, ..cfg)
  
  // Below we convert the value to content, so it can be joined with the
  // export metadata even if the value was something like an integer.

  // Disambiguate manually in case of several cells matching the cell spec
  let cs = reading.cell.cells(..args)
  if cs.len() > 1 {
    // Disambiguate based on sequence of exports in document
    return context {
      // Find how many exports before this one have the exact same cell source,
      // including the cell header as normalized by export(). The comparison
      // done here must match exactly the comparison done for raw specs in
      // cell.typ:_cell-indices.
      // If there are already n exports for this cell source, they have indices
      // 0...n-1 and we are index n.
      let exported-text = export(..args).value.text
      let sel = selector(_element-label).before(here())
      let matches = query(sel).filter(x => x.value.text == exported-text)
      let n = matches.len()
      // Use the nth cell ID as cell spec, or an empty array (which matches no
      // cell) if there is no nth cell.
      let new-spec = if cs.len() >= n {
        cs.at(n).id
      } else {
        ()
      }
      // Make sure the cell is matched by id if the spec is a string
      // (if not, the spec is raw and name-path doesn't matter)
      export-md + [#value-func(new-spec, ..cfg, name-path: "id")]
    }
  }

  // Zero or one match -> we just call the function, which will use a
  // placeholder if appropriate
  return export-md + [#value-func(cell-spec, ..cfg)]
}

// Export the given raw element and render it
#let execute = _exec.with(value-func: rendering.Cell)

// Export the given raw element and return the unique output
#let evaluate = _exec.with(value-func: reading.output.output)
