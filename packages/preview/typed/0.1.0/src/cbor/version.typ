/// Encode a version into CBOR-compatible dictionary.
///
/// Only the first five components are considered.
///
/// - version (version): A version.
/// -> dictionary
#let encode(version) = {
  assert(type(version) == std.version, message: "version.encode: version must be of type version")

  (
    "typed-type": "version",
    "major": version.at(0),
    "minor": version.at(1),
    "patch": version.at(2),
    "revision": version.at(3),
    "build": version.at(4),
  )
}
