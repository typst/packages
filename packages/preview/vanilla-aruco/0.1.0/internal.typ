// Internal implementation. The package entrypoint exports only `aruco`.

#let _backend = plugin("aruco.wasm")

// Metadata only: actual codewords live in the Rust/WASM backend.
#let _dictionaries = (
  "DICT_ARUCO_ORIGINAL": (name: "DICT_ARUCO_ORIGINAL", size: 5, count: 1024),
  "DICT_4X4_50": (name: "DICT_4X4_50", size: 4, count: 50),
  "DICT_4X4_100": (name: "DICT_4X4_100", size: 4, count: 100),
  "DICT_4X4_250": (name: "DICT_4X4_250", size: 4, count: 250),
  "DICT_4X4_1000": (name: "DICT_4X4_1000", size: 4, count: 1000),
  "DICT_5X5_50": (name: "DICT_5X5_50", size: 5, count: 50),
  "DICT_5X5_100": (name: "DICT_5X5_100", size: 5, count: 100),
  "DICT_5X5_250": (name: "DICT_5X5_250", size: 5, count: 250),
  "DICT_5X5_1000": (name: "DICT_5X5_1000", size: 5, count: 1000),
  "DICT_6X6_50": (name: "DICT_6X6_50", size: 6, count: 50),
  "DICT_6X6_100": (name: "DICT_6X6_100", size: 6, count: 100),
  "DICT_6X6_250": (name: "DICT_6X6_250", size: 6, count: 250),
  "DICT_6X6_1000": (name: "DICT_6X6_1000", size: 6, count: 1000),
  "DICT_7X7_50": (name: "DICT_7X7_50", size: 7, count: 50),
  "DICT_7X7_100": (name: "DICT_7X7_100", size: 7, count: 100),
  "DICT_7X7_250": (name: "DICT_7X7_250", size: 7, count: 250),
  "DICT_7X7_1000": (name: "DICT_7X7_1000", size: 7, count: 1000),
  "DICT_ARUCO_MIP_36h12": (name: "DICT_ARUCO_MIP_36h12", size: 6, count: 250),
)

#let _resolve-dictionary(dictionary) = {
  if type(dictionary) != str {
    panic("vanilla-aruco: dictionary must be an OpenCV dictionary name")
  }
  let result = _dictionaries.at(dictionary, default: none)
  if result == none {
    panic("vanilla-aruco: unknown dictionary name")
  }
  result
}

#let _decode-path(response-bytes, unit) = {
  let response = cbor(response-bytes)
  if response.version != 1 {
    panic("vanilla-aruco: unsupported CBOR response version")
  }
  let components = ()
  for segment in response.segments {
    if segment.kind == 0 {
      components.push(curve.move((segment.dx * unit, segment.dy * unit), relative: true))
    } else if segment.kind == 1 {
      components.push(curve.line((segment.dx * unit, 0pt), relative: true))
    } else if segment.kind == 2 {
      components.push(curve.line((0pt, segment.dy * unit), relative: true))
    } else if segment.kind == 3 {
      components.push(curve.close(mode: "straight"))
    } else {
      panic("vanilla-aruco: unknown path segment")
    }
  }
  components
}

#let _request-path(id, dictionary, rotation, unit) = {
  let request = cbor.encode((
    version: 1,
    dictionary: dictionary.name,
    id: id,
    turns: calc.quo(rotation, 90),
  ))
  _decode-path(_backend.generate_path(request), unit)
}

/// Render one marker from an OpenCV-compatible predefined dictionary.
///
/// The package entrypoint intentionally exposes only this function. Use the
/// `dictionary` string to select a predefined family, for example
/// `"DICT_6X6_250"`.
#let aruco(
  id,
  dictionary: "DICT_4X4_50",
  size: 3cm,
  quiet: 1,
  rotation: 0,
  foreground: black,
  background: white,
) = {
  if quiet < 0 {
    panic("vanilla-aruco: quiet must be non-negative")
  }
  if rotation != 0 and rotation != 90 and rotation != 180 and rotation != 270 {
    panic("vanilla-aruco: rotation must be one of 0, 90, 180, or 270 degrees")
  }
  let dictionary = _resolve-dictionary(dictionary)
  if id < 0 or id >= dictionary.count {
    panic("vanilla-aruco: marker id is outside the selected dictionary")
  }
  let total = dictionary.size + 2 + 2 * quiet
  let unit = size / total
  let components = _request-path(id, dictionary, rotation, unit)
  let body = curve(
    fill: foreground,
    stroke: none,
    fill-rule: "even-odd",
    ..((curve.move((quiet * unit, quiet * unit)),) + components),
  )
  box(
    width: size,
    height: size,
    fill: background,
    stroke: none,
    clip: true,
    body,
  )
}
