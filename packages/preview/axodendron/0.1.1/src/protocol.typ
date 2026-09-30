// WASM protocol, validation helpers, and SWC loading.

#let _protocol-version = 2
#let _plugin = plugin("../plugin.wasm")

#let _request(value) = cbor.encode((protocol_version: _protocol-version, value: value))

#let _required(name, value) = {
  if value == none {
    panic("Axodendron: missing required argument `" + name + "`")
  }
  value
}

#let _positive(name, value) = {
  let value = _required(name, value)
  if (type(value) != int and type(value) != float) or value <= 0 {
    panic("Axodendron: `" + name + "` must be a positive number")
  }
  value
}

#let _nonnegative-length(name, value) = {
  if type(value) != length or value < 0pt {
    panic("Axodendron: `" + name + "` must be a non-negative length")
  }
  value
}

#let _length-offset(name, value) = {
  if type(value) != dictionary or not "x" in value or not "y" in value {
    panic("Axodendron: `" + name + "` must be a dictionary containing `x` and `y`")
  }
  if type(value.at("x")) != length or type(value.at("y")) != length {
    panic("Axodendron: `" + name + ".x` and `" + name + ".y` must be lengths")
  }
  value
}

#let _node-id-array(name, value) = {
  if type(value) != array or not value.all(node => type(node) == int) {
    panic("Axodendron: `" + name + "` must be an array of integer node IDs")
  }
  value
}

#let _unique(values) = values.fold((), (result, value) => {
  if value in result { result } else { result + (value,) }
})

#let _unwrap(raw) = {
  let response = cbor(raw)
  if response.at("protocol_version") != _protocol-version {
    panic("Axodendron protocol version mismatch")
  }
  if not response.at("ok") {
    let error = response.at("error")
    panic("Axodendron " + error.at("code") + ": " + error.at("message"))
  }
  response.at("value")
}

#let _format-diagnostic(item) = {
  let line = item.at("line")
  let column = item.at("column")
  let location = if line == none {
    ""
  } else if column == none {
    " at line " + str(line)
  } else {
    " at line " + str(line) + ", column " + str(column)
  }
  "[" + item.at("code") + "] " + item.at("message") + location
}

#let _parse-bytes(source, profile: "permissive", fail-on-error: true) = {
  let value = _unwrap(_plugin.parse(
    source,
    _request((profile: profile)),
  ))
  if fail-on-error and not value.at("valid") {
    panic(value.at("diagnostics").map(_format-diagnostic).join("\n"))
  }
  (
    payload: if value.at("payload") == none {
      none
    } else {
      cbor.encode(value.at("payload"))
    },
    valid: value.at("valid"),
    diagnostics: value.at("diagnostics"),
    fingerprint: value.at("fingerprint"),
    source-fingerprint: value.at("source_fingerprint"),
    node-count: value.at("node_count"),
    units: value.at("units"),
    metadata: value.at("metadata"),
  )
}

#let _require-payload(cell) = {
  if cell.at("payload") == none {
    panic("Axodendron: this morphology is invalid and has no computational payload")
  }
  cell.at("payload")
}

#let _cell-from-payload(payload) = {
  let morphology = payload.at("morphology")
  (
    payload: cbor.encode(payload),
    valid: true,
    diagnostics: (),
    fingerprint: morphology.at("fingerprint"),
    source-fingerprint: morphology.at("source_fingerprint"),
    node-count: morphology.at("ids").len(),
    units: morphology.at("units"),
    metadata: morphology.at("metadata"),
  )
}

#let _v15-or-later() = sys.version >= version(0, 15, 0)

#let _source-to-bytes(source) = {
  if _v15-or-later() and repr(type(source)) == "path" {
    read(source, encoding: none)
  } else if type(source) == bytes {
    source
  } else {
    bytes(source)
  }
}

/// Load and validate SWC input. Typst 0.15.0 and later may pass `path(...)`
/// directly; Typst 0.14.x should pass `read("neuron.swc", encoding: none)` so
/// the path is resolved at the calling document.
///
/// Geometry values remain unitless numbers in the physical unit named by
/// `cell.units` (SWC convention: micrometres). Typst layout lengths are only
/// used by `render`.
///
/// - source (any): SWC input as bytes or text, or a `path` on Typst 0.15.0 and later.
/// - profile (str): Validation profile, either `"permissive"` or `"incf-strict"`.
/// - fail-on-error (bool): Whether validation errors should stop evaluation.
/// -> dictionary
#let load(source, profile: "permissive", fail-on-error: true) = _parse-bytes(
  _source-to-bytes(source),
  profile: profile,
  fail-on-error: fail-on-error,
)

/// Parse and validate SWC source already held in memory.
///
/// - source (str, bytes): SWC source text or its byte representation.
/// - profile (str): Validation profile, either `"permissive"` or `"incf-strict"`.
/// - fail-on-error (bool): Whether validation errors should stop evaluation.
/// -> dictionary
#let from-text(source, profile: "permissive", fail-on-error: true) = _parse-bytes(
  if type(source) == bytes { source } else { bytes(source) },
  profile: profile,
  fail-on-error: fail-on-error,
)

/// Return all validation diagnostics retained by a cell.
///
/// - cell (dictionary): A morphology returned by `load`, `from-text`, or a transformation.
/// -> array
#let diagnostics(cell) = cell.at("diagnostics")

/// Return retained SWC header comments and recognized descriptive fields.
/// Metadata such as scale or shrinkage correction is never applied implicitly.
///
/// - cell (dictionary): A morphology returned by `load`, `from-text`, or a transformation.
/// -> dictionary
#let metadata(cell) = cell.at("metadata")

#let _view(projection) = if type(projection) == str {
  (kind: projection)
} else {
  (
    kind: "orthographic",
    direction: projection.at("direction"),
    up: projection.at("up"),
  )
}


/// Package version reported by the bundled plugin.
///
/// -> str
#let version = str(_plugin.version())
