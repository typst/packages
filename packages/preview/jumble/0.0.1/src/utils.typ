/// Applies the XOR operation between two byte arrays
/// ```example
/// #let a = bytes((0b010, 0b0111))
/// #let b = bytes((0b011, 0b0101))
/// #array(xor-bytes(a, b)).map(
///   b => z-fill(str(b, base: 2), 3)
/// )
/// ```
/// -> bytes
#let xor-bytes(
  /// First byte array
  /// -> bytes
  bytes-a,
  /// Second byte array
  /// -> bytes
  bytes-b
) = {
  let length = calc.max(bytes-a.len(), bytes-b.len())
  let bytes-c = ()
  for i in range(length) {
    bytes-c.push(
      bytes-a.at(i, default: 0).bit-xor(bytes-b.at(i, default: 0))
    )
  }
  return bytes(bytes-c)
}

/// Pads a string with 0s on the left to reach a certain length
/// ```example
/// #z-fill("1011", 8)
/// ```
/// -> str
#let z-fill(
  /// -> str
  string,
  /// -> number
  length
) = {
  return "0" * (length - string.len()) + string
}

/// Converts a byte array to a hexadecimal string
/// ```example
/// #let b = bytes((0xfa, 0xca, 0xde))
/// #bytes-to-hex(b)
/// ```
/// -> str
#let bytes-to-hex(
  /// -> bytes
  bytes
) = {
  let res = ""
  for byte in bytes {
    res += z-fill(str(byte, base: 16), 2)
  }
  return res
}

/// Converts an array of bits into an integer
/// ```example
/// #let bits = (0, 0, 1, 0, 1, 0, 1, 0)
/// #bin-to-int(bits)
/// ```
/// -> number
#let bin-to-int(
  /// Bit array
  /// -> array
  bin
) = {
  return bin.fold(
    0,
    (v, b) => v.bit-lshift(1).bit-or(b)
  )
}

#let max-32 = 1.bit-lshift(32)
#let mask-32 = max-32 - 1

/// Rotates a number to the left (wrapping the leftmost bits to the right)
/// ```example
/// #let a = 42
/// #let b = circular-shift(a, n: 20)
/// #let c = circular-shift(b, n: 11)
/// #b, #c
/// ```
/// -> number
#let circular-shift(
  /// Number to rotate
  /// -> number
  x,
  /// Shift amount
  /// -> number
  n: 1
) = {
  if n < 0 {
    return circular-shift(x, n: 32 + n)
  }
  let high-bits = x.bit-rshift(32 - n)
  return x.bit-lshift(n).bit-or(high-bits).bit-and(mask-32)
}

/// Switches the endianness of the given value (32-bit integer)
/// -> number
#let switch-endianness(
  /// -> number
  value
) = {
  let a = value.bit-rshift(24)
  let b = value.bit-rshift(16).bit-and(0xff)
  let c = value.bit-rshift(8).bit-and(0xff)
  let d = value.bit-and(0xff)

  let a2 = d.bit-lshift(24)
  let b2 = c.bit-lshift(16)
  let c2 = b.bit-lshift(8)
  let d2 = a

  return a2.bit-or(b2).bit-or(c2).bit-or(d2)
}

/// Converts a UTF-8 string to UTF-16LE
/// -> bytes
#let utf8-to-utf16le(
  /// -> str
  string
) = {
  let utf16le-bytes = ()
  for c in string.codepoints() {
    let u = c.to-unicode()
    if u <= 0xffff {
      utf16le-bytes.push(u.bit-and(0xff))
      utf16le-bytes.push(u.bit-rshift(8))
    } else {
      let u2 = u - 0x10000
      let hs = 0xd800 + u2.bit-rshift(10)
      let ls = 0xdc00 + u2.bit-and(0x3ff)
      utf16le-bytes.push(hs.bit-and(0xff))
      utf16le-bytes.push(hs.bit-rshift(8))
      utf16le-bytes.push(ls.bit-and(0xff))
      utf16le-bytes.push(ls.bit-rshift(8))
    }
  }
  return bytes(utf16le-bytes)
}