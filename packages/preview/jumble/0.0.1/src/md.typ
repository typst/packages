#import "utils.typ": *

#let rots = (
  7, 12, 17, 22,  7, 12, 17, 22,  7, 12, 17, 22,  7, 12, 17, 22,
  5,  9, 14, 20,  5,  9, 14, 20,  5,  9, 14, 20,  5,  9, 14, 20,
  4, 11, 16, 23,  4, 11, 16, 23,  4, 11, 16, 23,  4, 11, 16, 23,
  6, 10, 15, 21,  6, 10, 15, 21,  6, 10, 15, 21,  6, 10, 15, 21
)

#let _md5-const(i) = {
  return int(
    calc.floor(
      calc.abs(
        calc.sin(i + 1) * max-32
      )
    )
  )
}

#let md5-default-iv = (
  0x67452301,
  0xEFCDAB89,
  0x98BADCFE,
  0x10325476
)
#let md4-default-iv = md5-default-iv

/// Message Digest 5
/// #test(
///   `jumble.bytes-to-hex(jumble.md5("Hello World!")) == "ed076287532e86365e841e92bfc50d8c"`
/// )
/// ```example
/// #bytes-to-hex(md5("Hello World!"))
/// ```
/// -> bytes
#let md5(
  message,
  iv: md5-default-iv
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
  let len-bin = z-fill(str(l, base: 2), 64)
  // Reverse order to little-endian
  len-bin = len-bin.clusters()
                   .chunks(8)
                   .rev()
                   .flatten()
                   .join()
  bin-str += len-bin
  let bin = bin-str.clusters().map(int)

  // Split into blocks of 16 32-bit words
  let words = bin.chunks(32).map(bin-to-int).map(switch-endianness)
  let blocks = words.chunks(16)
  
  let vec = iv

  for block in blocks {
    let (A, B, C, D) = vec
    for i in range(64) {
      let (f, g) = if i < 16 {(
        B.bit-and(C).bit-or(B.bit-not().bit-and(mask-32).bit-and(D)),
        i
      )} else if i < 32 {(
        D.bit-and(B).bit-or(D.bit-not().bit-and(mask-32).bit-and(C)),
        calc.rem(5 * i + 1, 16)
      )} else if i < 48 {(
        B.bit-xor(C).bit-xor(D),
        calc.rem(3 * i + 5, 16)
      )} else {(
        C.bit-xor(B.bit-or(D.bit-not().bit-and(mask-32))),
        calc.rem(7 * i, 16)
      )}
      let temp = circular-shift(
        calc.rem(A + f + _md5-const(i) + block.at(g), max-32),
        n: rots.at(i)
      ) + B
      (A, B, C, D) = (
        D,
        calc.rem(temp, max-32),
        B,
        C
      )
    }

    vec = vec.zip((A, B, C, D)).map(p => {
      calc.rem(p.sum(), max-32)
    })
  }

  let digest-bytes = ()
  for n in vec {
    digest-bytes += (
      n.bit-and(0xff),
      n.bit-rshift(8).bit-and(0xff),
      n.bit-rshift(16).bit-and(0xff),
      n.bit-rshift(24)
    )
  }

  return bytes(digest-bytes)
}

#let _md4-round1-shift = (3, 7, 11, 19)
#let _md4-round2-shift = (3, 5, 9, 13)
#let _md4-round3-shift = (3, 9, 11, 15)

#let _md4-f(x, y, z) = {
  return x.bit-and(y).bit-or(x.bit-not().bit-and(mask-32).bit-and(z))
}

#let _md4-g(x, y, z) = {
  let xy = x.bit-and(y)
  let xz = x.bit-and(z)
  let yz = y.bit-and(z)
  return xy.bit-or(xz).bit-or(yz)
}

#let _md4-h(x, y, z) = {
  return x.bit-xor(y).bit-xor(z)
}

#let _md4-round1(a, b, c, d, x, s) = {
  let temp = a + _md4-f(b, c, d) + x
  return circular-shift(
    temp.bit-and(mask-32),
    n: s
  )
}

#let _md4-round2(a, b, c, d, x, s) = {
  let temp = a + _md4-g(b, c, d) + x + 0x5a827999
  return circular-shift(
    temp.bit-and(mask-32),
    n: s
  )
}

#let _md4-round3(a, b, c, d, x, s) = {
  let temp = a + _md4-h(b, c, d) + x + 0x6ed9eba1
  return circular-shift(
    temp.bit-and(mask-32),
    n: s
  )
}

/// Message Digest 4
/// #test(
///   `jumble.bytes-to-hex(jumble.md4("Hello World!")) == "b2a5cc34fc21a764ae2fad94d56fadf6"`
/// )
/// ```example
/// #bytes-to-hex(md4("Hello World!"))
/// ```
/// -> bytes
#let md4(
  /// -> str | bytes
  message,
  /// -> array
  iv: md4-default-iv
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
  let len-bin = z-fill(str(l, base: 2), 64)
  // Reverse order to little-endian
  len-bin = len-bin.clusters()
                   .chunks(8)
                   .rev()
                   .flatten()
                   .join()
  bin-str += len-bin
  let bin = bin-str.clusters().map(int)

  // Split into blocks of 16 32-bit words
  let words = bin.chunks(32).map(bin-to-int).map(switch-endianness)
  let blocks = words.chunks(16)
  
  let vec = iv

  for block in blocks {
    let vec2 = vec
    
    for i in range(16) {
      vec2.at(0) = _md4-round1(
        ..vec2,
        block.at(i),
        _md4-round1-shift.at(calc.rem(i, 4))
      )
      vec2.insert(0, vec2.pop())
    }

    for i in range(16) {
      let j = calc.rem(i * 4, 16) + calc.div-euclid(i, 4)
      vec2.at(0) = _md4-round2(
        ..vec2,
        block.at(j),
        _md4-round2-shift.at(calc.rem(i, 4))
      )
      vec2.insert(0, vec2.pop())
    }

    for i in range(16) {
      let j = bin-to-int(
        z-fill(
          str(i, base: 2),
          4
        ).clusters()
         .map(int)
         .rev()
      )

      vec2.at(0) = _md4-round3(
        ..vec2,
        block.at(j),
        _md4-round3-shift.at(calc.rem(i, 4))
      )
      vec2.insert(0, vec2.pop())
    }

    vec = vec.zip(vec2).map(p => {
      calc.rem(p.sum(), max-32)
    })
  }

  let digest-bytes = ()
  for n in vec {
    digest-bytes += (
      n.bit-and(0xff),
      n.bit-rshift(8).bit-and(0xff),
      n.bit-rshift(16).bit-and(0xff),
      n.bit-rshift(24),
    )
  }

  return bytes(digest-bytes)
}