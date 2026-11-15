// Non-standard UUID containers holding deterministic FNV-1a 32 identifiers.
// A namespace has 8-4-4-4-12 hexadecimal form (case-insensitive), or 16 raw bytes.
// Names are UTF-8 strings or bytes; their spelling is preserved exactly.
#let _uid_compute(namespace, name) = {
  let hex-digits = "0123456789abcdef"
  let namespace-bytes = if type(namespace) == bytes {
    assert(namespace.len() == 16, message: "uid namespace must contain 16 bytes")
    namespace
  } else {
    assert(type(namespace) == str, message: "uid namespace must be an identifier string or bytes")
    assert(
      namespace.match(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$")) != none,
      message: "uid namespace must have 8-4-4-4-12 hexadecimal form",
    )
    let digits = lower(namespace).replace("-", "")
    bytes(range(0, 32, step: 2).map(i => {
      hex-digits.position(digits.at(i)) * 16 + hex-digits.position(digits.at(i + 1))
    }))
  }
  assert(type(name) == str or type(name) == bytes, message: "uid name must be a string or bytes")

  // FNV-1a 32 over namespace bytes followed by the exact name bytes.
  // The product fits in Typst's signed 64-bit integer before masking.
  let hash = 2166136261
  for byte in namespace-bytes + bytes(name) {
    hash = int.bit-and(int.bit-xor(hash, byte) * 16777619, 4294967295)
  }
  let hex = range(7, -1, step: -1).map(shift => {
    hex-digits.at(int.bit-and(int.bit-rshift(hash, shift * 4), 15))
  }).join("")
  // Non-standard UUID: only borrow the container, with 32 effective hash bits.
  // Fixed version/variant-shaped fields are formatting, not UUID semantics.
  hex + "-0000-8000-8000-000000000000"
}

#let uid = _uid_compute

#let namespaces = (
  dns: "6ba7b810-9dad-11d1-80b4-00c04fd430c8",
  url: "6ba7b811-9dad-11d1-80b4-00c04fd430c8",
  oid: "6ba7b812-9dad-11d1-80b4-00c04fd430c8",
  x500: "6ba7b814-9dad-11d1-80b4-00c04fd430c8",
)
