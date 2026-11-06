#import "utils.typ": *

#let sha1-default-iv = (
  0x67452301,
  0xefcdab89,
  0x98badcfe,
  0x10325476,
  0xc3d2e1f0
)

#let _sha1-const(i) = {
  if i < 20 {
    return 0x5a827999
  } else if i < 40 {
    return 0x6ed9eba1
  } else if i < 60 {
    return 0x8f1bbcdc
  } else {
    return 0xca62c1d6
  }
}

#let _sha1-func(i, b, c, d) = {
  if i < 20 {
    return b.bit-and(c).bit-or(b.bit-not().bit-and(mask-32).bit-and(d))
  } else if i < 40 {
    return b.bit-xor(c).bit-xor(d)
  } else if i < 60 {
    let bc = b.bit-and(c)
    let bd = b.bit-and(d)
    let cd = c.bit-and(d)
    return bc.bit-or(bd).bit-or(cd)
  } else {
    return b.bit-xor(c).bit-xor(d)
  }
}

/// Secure Hash Algorithm 1
/// ```example
/// #bytes-to-hex(sha1("Hello World!"))
/// ```
/// -> bytes
#let sha1(
  /// Message to hash
  /// -> str | bytes
  message,
  /// Initial vector
  /// -> array
  iv: sha1-default-iv
) = {
  let message = if type(message) == str {bytes(message)} else {message}
  assert(type(message) == bytes, message: "message must be a string or bytes, but is " + repr(type(message)))

  // Complete message to multiple of 512 bits
  let bin-str = ""
  for char in message {
    bin-str += z-fill(str(char, base: 2), 8)
  }
  let l = bin-str.len()
  bin-str += "1"
  let padding = calc.rem-euclid(448 - bin-str.len(), 512)
  if padding != 0 {
    bin-str += "0" * padding
  }
  bin-str += z-fill(str(l, base: 2), 64)
  let bin = bin-str.clusters().map(int)

  // Split into blocks of 16 32-bit words
  let words = bin.chunks(32).map(bin-to-int)
  let blocks = words.chunks(16)
  
  let vec = iv

  for block in blocks {
    // Expand
    for i in range(16, 80) {
      let chosen-words = (
        block.at(i - 3),
        block.at(i - 8),
        block.at(i - 14),
        block.at(i - 16)
      )
      let word = circular-shift(
        chosen-words.fold(0, (a, b) => a.bit-xor(b))
      )
      block.push(word)
    }

    // Compress
    let (A, B, C, D, E) = vec
    for i in range(80) {
      let temp = (
        circular-shift(A, n: 5) +
        _sha1-func(i, B, C, D) +
        E +
        block.at(i) +
        _sha1-const(i)
      )
      temp = calc.rem(temp, max-32)
      (A, B, C, D, E) = (temp, A, circular-shift(B, n: 30), C, D)
    }
    vec = vec.zip((A, B, C, D, E)).map(p => {
      calc.rem(p.sum(), max-32)
    })
  }
  
  let digest-bytes = ()
  for n in vec {
    digest-bytes += (
      n.bit-rshift(24),
      n.bit-rshift(16).bit-and(0xff),
      n.bit-rshift(8).bit-and(0xff),
      n.bit-and(0xff)
    )
  }
  
  return bytes(digest-bytes)
}