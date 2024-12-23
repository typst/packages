#import "utils.typ": z-fill, bin-to-int
#let b32-alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"

/// Decodes a base32-encoded value
/// #test(
///   `jumble.b32-decode("LFHVKUCJ") == bytes("YOUPI")`
/// )
/// ```example
/// #str(b32-decode("LFHVKUCJ"))
/// ```
/// -> bytes
#let b32-decode(
  /// -> str
  encoded
) = {
  let decoded-bin = ()
  for char in encoded {
    if char == "=" {
      break
    }
    let i = b32-alphabet.position(char)
    decoded-bin += z-fill(str(i, base: 2), 5).clusters().map(int)
  }
  decoded-bin = decoded-bin.slice(
    0,
    calc.div-euclid(decoded-bin.len(), 8) * 8
  )
  let decoded-bytes = decoded-bin.chunks(8).map(bin-to-int)
  return bytes(decoded-bytes)
}

/// Encodes a value in base32
/// #test(
///   `jumble.b32-encode(bytes("YOUPI")) == "LFHVKUCJ"`
/// )
/// ```example
/// #b32-encode(bytes("YOUPI"))
/// ```
/// -> str
#let b32-encode(
  /// -> bytes
  decoded
) = {
  let encoded = ""
  let decoded-bin = array(decoded).map(b => z-fill(str(b, base: 2), 8)).join()
  decoded-bin = decoded-bin.clusters().map(int)
  let groups = decoded-bin.chunks(40)
  for group in groups {
    let chars = group.chunks(5)
    if chars.last().len() != 5 {
      chars.last() += (0,) * (5 - chars.last().len())
    }
    let chars = chars.map(bin-to-int)
                     .map(c => b32-alphabet.at(c))
    encoded += chars.join()
    let pad = 8 - chars.len()
    if pad != 0 {
      encoded += "=" * pad
    }
  }
  return encoded
}