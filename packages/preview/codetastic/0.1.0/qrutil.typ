
// TODO: This probably should be improved / optimized.

#import "bits.typ"
#import "qrluts.typ"

// aliases
#let pow2(n) = calc.pow(n, 2)

#let mod = calc.rem
#let mod2(x) = calc.rem(x, 2)
#let mod3(x) = calc.rem(x, 3)
#let mod255(x) = calc.rem(x, 255)
#let mod256(x) = calc.rem(x, 256)
#let mod285(x) = calc.rem(x, 285)


/// >>> qrutil.check-version(1)
/// >>> qrutil.check-version(7)
/// >>> qrutil.check-version(30)
/// >>> qrutil.check-version(40)
/// >>> not qrutil.check-version(0)
/// >>> not qrutil.check-version(41)
#let check-version(version) = version >= 1 and version <= 40

/// >>> qrutil.check-ecl("l")
/// >>> qrutil.check-ecl("h")
/// >>> qrutil.check-ecl("m")
/// >>> qrutil.check-ecl("q")
/// >>> not qrutil.check-ecl("a")
/// >>> not qrutil.check-ecl("Q")
#let check-ecl(ecl) = ecl in ("l", "m", "q", "h")

/// >>> qrutil.size(1) == 21
/// >>> qrutil.size(2) == 25
/// >>> qrutil.size(7) == 45
/// >>> qrutil.size(33) == 149
/// >>> qrutil.size(40) == 177
#let size(version) = { return 21 + (version - 1)*4 }

/// >>> qrutil.total-modules(1) == 208
/// >>> qrutil.total-modules(7) == 1568
/// >>> qrutil.total-modules(16) == 5867
/// >>> qrutil.total-modules(40) == 29648
#let total-modules(version) = {
  if version == 1 {
    return 21 * 21 - 3 * 8 * 8 - 2 * 15 - 1 - 2 * 5;
  }

  let n = calc.floor(version / 7) + 2;
  return 16 * pow2(version + 4) - pow2(5 * n - 1) - if version > 6 {172} else {136}
}

/// >>> qrutil.total-codewords(1) == 26
/// >>> qrutil.total-codewords(7) == 196
/// >>> qrutil.total-codewords(16) == 733
/// >>> qrutil.total-codewords(40) == 3706
#let total-codewords(version) = {
  return calc.floor(total-modules(version) / 8);
}

/// >>> qrutil.data-codewords(1, "l") == 19
/// >>> qrutil.data-codewords(6, "m") == 108
/// >>> qrutil.data-codewords(7, "l") == 156
/// >>> qrutil.data-codewords(7, "m") == 124
/// >>> qrutil.data-codewords(7, "q") == 88
/// >>> qrutil.data-codewords(7, "h") == 66
/// >>> qrutil.data-codewords(18, "q") == 397
/// >>> qrutil.data-codewords(19, "h") == 341
#let data-codewords(version, ecl) = {
  let (ecw-count, blocks) = qrluts.blocks.at(version - 1).at(ecl)
  return total-codewords(version) - blocks * ecw-count;
}


// =================================
//  Code capacity lookup table
// =================================
/// >>> qrutil.capacities(1, "l") == (41, 25, 17, 10)
/// >>> qrutil.capacities(7, "l") == (370, 224, 154, 95)
/// >>> qrutil.capacities(7, "m") == (293, 178, 122, 75)
/// >>> qrutil.capacities(7, "q") == (207, 125, 86, 53)
/// >>> qrutil.capacities(7, "h") == (154, 93, 64, 39)
#let capacities(version, ecl) = {
  let key = str(version) + "-" + ecl
  return qrluts.capacities.at(key)
}

/// >>> qrutil.best-version(36, "l", 0) == 1
/// >>> qrutil.best-version(42, "l", 0) == 2
/// >>> qrutil.best-version(120, "l", 0) == 3
/// >>> qrutil.best-version(130, "l", 0) == 4
/// >>> qrutil.best-version(7089, "l", 0) == 40
/// >>> qrutil.best-version(7090, "l", 0) == none
/// >>> qrutil.best-version(755, "q", 2) == 27
/// >>> qrutil.best-version(3908, "m", 0) == 33
/// >>> qrutil.best-version(3910, "m", 0) == 34
#let best-version(char-count, ecl, mode) = {
  for ver in range(40) {
    let cap = capacities(ver + 1, ecl)
    if cap.at(mode) >= char-count {
      return ver + 1
    }
  }
  return none
}


// =================================
//  Encoding
// =================================

/// >>> qrutil.best-mode("0123") == 0
/// >>> qrutil.best-mode("0000") == 0
/// >>> qrutil.best-mode("1") == 0
/// >>> qrutil.best-mode("A") == 1
/// >>> qrutil.best-mode("ABCD") == 1
/// >>> qrutil.best-mode("ABCD:XYZ$") == 1
/// >>> qrutil.best-mode("a") == 2
/// >>> qrutil.best-mode("abcxyz") == 2
/// >>> qrutil.best-mode("ABCD:XYZ!") == 2
/// >>> qrutil.best-mode("€") == none
#let best-mode(data) = {
  let nums = regex(`^\d*$`.text)
  let alphnum = regex(`^[\dA-Z $%*+\-./:]*$`.text)
  let byte = regex(`^[\x00-\xff]*$`.text)
  if data.match(nums) != none {
    return 0
  }
  if data.match(alphnum) != none {
    return 1
  }
  if data.match(byte) != none {
    return 2
  }
  return none
}

/// >>> qrutil.mode-bits(0) == (false, false, false, true)
/// >>> qrutil.mode-bits(1) == (false, false, true, false)
/// >>> qrutil.mode-bits(2) == (false, true, false, false)
/// >>> qrutil.mode-bits(3) == (true, false, false, false)
#let mode-bits(mode) = {
  return (
    (false, false, false, true),
    (false, false, true, false),
    (false, true, false, false),
    (true, false, false, false)
  ).at(mode)
}

/// >>> qrutil.char-count-bits(10, 1, 0) == bits.from-str("0000001010")
/// >>> qrutil.char-count-bits(10, 1, 1) == bits.from-str("000001010")
/// >>> qrutil.char-count-bits(10, 1, 2) == bits.from-str("00001010")
/// >>> qrutil.char-count-bits(10, 9, 2) == bits.from-str("00001010")
/// >>> qrutil.char-count-bits(10, 15, 2) == bits.from-str("0000000000001010")
/// >>> qrutil.char-count-bits(23, 15, 0) == bits.from-str("000000010111")
/// >>> qrutil.char-count-bits(23, 33, 0) == bits.from-str("00000000010111")
/// >>> qrutil.char-count-bits(23, 33, 1) == bits.from-str("0000000010111")
#let char-count-bits(char-count, version, mode) = {
  let len
  if version <= 9 {
    len = (10, 9, 8, 8).at(mode)
  } else if version <= 26 {
    len = (12, 11, 16, 10).at(mode)
  } else {
    len = (14, 13, 16, 12).at(mode)
  }
  return bits.pad(
    bits.from-int(char-count), len)
}

/// >>> qrutil.version-bits(1) == ()
/// >>> qrutil.version-bits(7) == bits.from-str("000111110010010100")
/// >>> qrutil.version-bits(7) == qrutil.calc-version-bits(7)
/// >>> qrutil.version-bits(27) == bits.from-str("011011000010001110")
/// >>> qrutil.version-bits(27) == qrutil.calc-version-bits(27)
/// >>> qrutil.version-bits(33) == bits.from-str("100001011011110000")
/// >>> qrutil.version-bits(33) == qrutil.calc-version-bits(33)
/// >>> qrutil.version-bits(40) == bits.from-str("101000110001101001")
/// >>> qrutil.version-bits(40) == qrutil.calc-version-bits(40)
#let version-bits(version) = {
  if version >= 7 {
    return bits.from-str(qrluts.version-formats.at(version - 7))
  } else {
    return ()
  }
}

// Manual calculation of version format code
#let calc-version-bits(version) = {
  import "ecc.typ": bch
  if version >= 7 {
    let ver-fmt = bits.pad(
      bits.from-int(version), 6)
    return ver-fmt + bch(ver-fmt,
      generator:"1111100100101")
  } else {
    return ()
  }
}

/// >>> qrutil.format-bits("l", 0) == bits.from-str("111011111000100")
/// >>> qrutil.format-bits("l", 0) == qrutil.calc-format-bits("l", 0)
/// >>> qrutil.format-bits("l", 5) == bits.from-str("110001100011000")
/// >>> qrutil.format-bits("l", 5) == qrutil.calc-format-bits("l", 5)
/// >>> qrutil.format-bits("q", 3) == bits.from-str("011101000000110")
/// >>> qrutil.format-bits("q", 3) == qrutil.calc-format-bits("q", 3)
/// >>> qrutil.format-bits("q", 7) == bits.from-str("010101111101101")
/// >>> qrutil.format-bits("q", 7) == qrutil.calc-format-bits("q", 7)
/// >>> qrutil.format-bits("h", 1) == bits.from-str("001001110111110")
/// >>> qrutil.format-bits("h", 1) == qrutil.calc-format-bits("h", 1)
/// >>> qrutil.format-bits("h", 6) == bits.from-str("000110100001100")
/// >>> qrutil.format-bits("h", 6) == qrutil.calc-format-bits("h", 6)
#let format-bits(ecl, mask) = {
  return bits.from-str(qrluts.format-information.at(ecl).at(mask))
}

// Manual calculation of format code
#let calc-format-bits(ecl, mask) = {
  import "ecc.typ": bch
  let mask-bits = bits.pad(bits.from-int(mask), 3)
  ecl = (
    l: (false, true),
    m: (false, false),
    q: (true, true),
    h: (true, false)
  ).at(ecl)

  let fmt = ecl + mask-bits
  let crc = bch(fmt)

  return bits.xor(fmt + crc,
    bits.from-str("101010000010010"))
}


/// Encodes numeric data (only characters "0" to "9") into byte codewords.
///
/// >>> qrutil.encode-numeric("0", ()) == ((), (false, false, false, false))
/// >>> qrutil.encode-numeric("1", (false, false, true, false)) == ((33,), ())
/// >>> qrutil.encode-numeric("14", ()) == ((), (false, false, false, true, true, true, false))
/// >>> qrutil.encode-numeric("144", ()) == ((36,), (false, false))
/// >>> qrutil.encode-numeric("144", (true, false, false, false)) == ((130,), (false, true, false, false, false, false))
#let encode-numeric(nums, buffer) = {
  let code = ()
  let len = nums.len()

  for i in range(len, step:3) {
    let n = int(nums.slice(i, calc.min(len, i + 3)))
    if n < 10 {
      buffer += bits.from-int(n, pad:4)
    } else if n < 100 {
      buffer += bits.from-int(n, pad:7)
    } else {
      buffer += bits.from-int(n, pad:10)
    }

    while buffer.len() >= 8 {
      code.push( bits.to-int(buffer.slice(0, 8)) )
      buffer = buffer.slice(8)
    }
  }

  return (code, buffer)
}

#let alphnum-char-codes = (
  "0": 0, "1": 1, "2": 2, "3": 3, "4": 4,
  "5": 5, "6": 6, "7": 7, "8": 8, "9": 9,
  "A": 10, "B": 11, "C": 12, "D": 13, "E": 14,
  "F": 15, "G": 16, "H": 17, "I": 18, "J": 19,
  "K": 20, "L": 21, "M": 22, "N": 23, "O": 24,
  "P": 25, "Q": 26, "R": 27, "S": 28, "T": 29,
  "U": 30, "V": 31, "W": 32, "X": 33, "Y": 34,
  "Z": 35, " ": 36, "$": 37, "%": 38, "*": 39,
  "+": 40, "-": 41, ".": 42, "/": 43, ":": 44,
)

#let encode-alphanumeric(alphnum, buffer) = {
  let code = ()
  let len = alphnum.len()

  for i in range(len, step:2) {
    let char = alphnum.at(i)
    let char-code = alphnum-char-codes.at(char, default:0)

    if i + 1 < alphnum.len() {
      char = alphnum.at(i + 1)
      char-code = char-code*45 + alphnum-char-codes.at(char, default:0)
      buffer += bits.pad(bits.from-int(char-code), 11)
    } else {
      buffer += bits.pad(bits.from-int(char-code), 6)
    }

    while buffer.len() >= 8 {
      code.push( bits.to-int(buffer.slice(0, 8)) )
      buffer = buffer.slice(8)
    }
  }

  return (code, buffer)
}

#let ASCII = " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~"

/// >>> qrutil.encode-byte("https://www.qrcode.com/", bits.from-str("010000010111")) == ((65, 118, 135, 71, 71, 7, 51, 162, 242, 247, 119, 119, 114, 231, 23, 38, 54, 246, 70, 82, 230, 54, 246, 210), (true, true, true, true))
#let encode-byte(chars, buffer) = {
  let code = ()
  let len = chars.len()

  for i in range(len) {
    buffer += bits.from-int( 32 + ASCII.position(chars.at(i)), pad:8 )

    while buffer.len() >= 8 {
      code.push( bits.to-int(buffer.slice(0, 8)) )
      buffer = buffer.slice(8)
    }
  }

  return (code, buffer)
}

/// Encodes `data` into byte codewords.
///
/// >>> qrutil.encode("HELLO WORLD", 1, "q", mode:1) == (32, 91, 11, 120, 209, 114, 220, 77, 67, 64, 236, 17, 236)
/// >>> qrutil.encode("HELLO WORLD", 7, "l", mode:1) == (32, 91, 11, 120, 209, 114, 220, 77, 67, 64) + (236, 17) * 73
/// >>> qrutil.encode("HELLO WORLD", 7, "h", mode:1) == (32, 91, 11, 120, 209, 114, 220, 77, 67, 64) + (236, 17) * 28
/// >>> qrutil.encode("https://www.qrcode.com/", 2, "m", mode:2) == (65, 118, 135, 71, 71, 7, 51, 162, 242, 247, 119, 119, 114, 231, 23, 38, 54, 246, 70, 82, 230, 54, 246, 210, 240, 236, 17, 236)
/// >>> qrutil.encode("https://www.qrcode.com/", 7, "m", mode:2) == (65, 118, 135, 71, 71, 7, 51, 162, 242, 247, 119, 119, 114, 231, 23, 38, 54, 246, 70, 82, 230, 54, 246, 210, 240, 236) + (17, 236)*49
#let encode(data, version, ecl, mode:auto) = {
  if mode == auto {
    mode = best-mode(data)
  }

  let (codewords, buffer) = ((
    encode-numeric,
    encode-alphanumeric,
    encode-byte
  ).at(mode))(data, mode-bits(mode) + char-count-bits(data.len(), version, mode))

  // required length of data
  let cw-count = data-codewords(version, ecl)
  let cw-bits = cw-count * 8

  // Add terminator
  let diff-cw = cw-count - codewords.len()
  let diff-bits = (diff-cw * 8 - buffer.len())
  buffer += (false,) * calc.min(diff-bits, 4)

  // Pad with zeros
  let rem = calc.rem(buffer.len(), 8)
  if rem > 0 {
    buffer += (false,) * (8 - rem)
  }

  while buffer.len() >= 8 {
    codewords.push( bits.to-int(buffer.slice(0,8)) )
    buffer = buffer.slice(8)
  }

  assert.eq(buffer.len(), 0)

  // Pad to capacity
  let pad-words = (236, 17)
  diff-cw = cw-count - codewords.len()
  for i in range(cw-count - codewords.len()) {
    codewords.push( pad-words.at( mod2(i) ) )
  }

  assert.eq(codewords.len(), cw-count)

  return codewords
}

// ======================================
//  Alignment patterns and reserved areas
// ======================================

/// >>> qrutil.alignment-positions(1) == ()
/// >>> qrutil.alignment-positions(2) == (6, 18)
/// >>> qrutil.alignment-positions(5) == (6, 30)
/// >>> qrutil.alignment-positions(7) == (6, 22, 38)
/// >>> qrutil.alignment-positions(10) == (6, 28, 50)
/// >>> qrutil.alignment-positions(16) == (6, 26, 50, 74)
/// >>> qrutil.alignment-positions(29) == (6, 30, 54, 78, 102, 126)
/// >>> qrutil.alignment-positions(36) == (6, 24, 50, 76, 102, 128, 154)
/// >>> qrutil.alignment-positions(40) == (6, 30, 58, 86, 114, 142, 170)
#let alignment-positions(version) = {
  return qrluts.alignments.at(version - 1)
}

/// Checks if a position is a valid position for an alignemnt pattern.
///
/// >>> not qrutil.is-valid-alignment(0, 0, 21)
/// >>> not qrutil.is-valid-alignment(36, 0, 41)
/// >>> qrutil.is-valid-alignment(8, 1, 21)
/// >>> not qrutil.is-valid-alignment(7, 170, 177)
#let is-valid-alignment(i, j, size) = not((i < 8 and j < 8) or (i < 8 and j > size - 8) or (i > size - 8 and j < 8))


/// Checks if a module position is within a reserved area.
/// Reserved areas are finder, alignment and timing patterns,
/// spacing and format information, the black module and for higher
/// versions the version information areas.
///
/// >>> qrutil.is-reserved(0, 0, 1)
/// >>> qrutil.is-reserved(34, 0, 7)
/// >>> qrutil.is-reserved(35, 0, 7)
/// >>> qrutil.is-reserved(34, 5, 7)
/// >>> qrutil.is-reserved(0, 34, 7)
/// >>> qrutil.is-reserved(0, 35, 7)
/// >>> qrutil.is-reserved(5, 34, 7)
/// >>> qrutil.is-reserved(98, 5, 21)
/// >>> qrutil.is-reserved(5, 52, 11)
/// >>> qrutil.is-reserved(6, 52, 11)
/// >>> qrutil.is-reserved(52, 6, 11)
/// >>> qrutil.is-reserved(53, 8, 11)
/// >>> not qrutil.is-reserved(53, 9, 11)
#let is-reserved(i, j, version) = {
  let size = size(version)

  // timing patterns + black module
  if (i == 6 or j == 6) or (i == size - 8 and j == 8) {
    return true

  // finder patterns + spacing + format information
  } else if ((i < 9 or i > size - 9) and j < 9) or (i < 9 and j > size - 9) {
      return true

  // version information
  } else if version > 6 {
    if (i >= size - 11  and j < 6) or (j >= size - 11 and i < 6) {
      return true
    }
  }

  // Alignment patterns
  let a = alignment-positions(version)
  for x in a {
    for y in a {
      if is-valid-alignment(x, y, size) {
        // // Check pattern
        if j < x - 2 {
          return false
        } else if j < x + 3 and i < y - 2 {
          return false
        } else if j < x + 3 and i < y + 3 {
          return true
        }
      }
    }
  }
  return false
}

#let finder = (
  "1111111",
  "1000001",
  "1011101",
  "1011101",
  "1011101",
  "1000001",
  "1111111"
).map(bits.from-str)

#let alignment = (
  "11111",
  "10001",
  "10101",
  "10001",
  "11111"
).map(bits.from-str)


// =================================
//  Galois field math
// =================================
#let exp(i) = qrluts.exp.at(i)
#let log(i) = qrluts.log.at(i)

/// >>> qrutil.gf-add(0, 0) == 0
/// >>> qrutil.gf-add(0, 1) == 1
/// >>> qrutil.gf-add(1, 0) == 1
/// >>> qrutil.gf-add(1, 1) == 0
/// >>> qrutil.gf-add(2, 1) == 3
/// >>> qrutil.gf-add(2, 3) == 1
/// >>> qrutil.gf-add(55, 87) == 96
#let gf-add(x, y) = {
  // TODO: This is stupid! How can this be made faster?
  return bits.to-int(
    bits.xor(
      bits.from-int(x, pad:8),
      bits.from-int(y, pad:8)
    )
  )
}

/// >>> qrutil.gf-mul(0, 255) == 0
/// >>> qrutil.gf-mul(255, 0) == 0
/// >>> qrutil.gf-mul(0, 0) == 0
/// >>> qrutil.gf-mul(255, 1) == 255
/// >>> qrutil.gf-mul(1, 255) == 255
/// >>> qrutil.gf-mul(2, 255) == 227
///
#let gf-mul(x, y) = {
  if x==0 or y==0 { return 0 }
  return exp(mod255(log(x) + log(y)))
}

/// >>> qrutil.gf-poly-add((1,), (1,)) == (0,)
/// >>> qrutil.gf-poly-add((1,), (1,)) == (qrutil.gf-add(1,1),)
/// >>> qrutil.gf-poly-add((4,2,1), (1,)) == (4,2,0)
/// >>> qrutil.gf-poly-add((4,2,1), (1,1,)) == (4,3,0)
#let gf-poly-add(p, q) = {
  let (lp, lq, lr) = (p.len(), q.len(), calc.max(p.len(), q.len()))
  let r = (0,) * lr
  for i in range(lp) {
    r.at(i + lr - lp) = p.at(i)
  }
  for i in range(lq) {
    r.at(i + lr - lq) = gf-add(r.at(i + lr - lq), q.at(i))
  }
  return r
}

/// >>> qrutil.gf-poly-mul((1,), (1,)) == (1,)
/// >>> qrutil.gf-poly-mul((2,), (5,)) == (qrutil.gf-mul(2,5),)
#let gf-poly-mul(p, q) = {
  let (lp, lq) = (p.len(), q.len())
  let r = (0,) * (lp + lq - 1)

  for i in range(r.len()) {
    for pi in range(i + 1) {
      let qi = i - pi
      if pi < lp and qi < lq {
        r.at(i) = gf-add(
          r.at(i),
          gf-mul(p.at(pi), q.at(qi))
        )
      }
    }
  }

  return r
}

#let gf-poly-rem(p, q) = {
  let d = p
  let (lp, lq) = (p.len(), q.len())
  for i in range(lp - lq + 1) {
    let coef = d.at(i)
    if coef != 0 {
      for j in range(1, lq) {
        if q.at(j) != 0 {
          d.at(i + j) = gf-add(
            d.at(i + j),
            gf-mul(q.at(j), coef)
          )
        }
      }
    }
  }
  let sep = -(lq - 1)

  return d.slice(sep)
}

/// Returns a generator polynomial to use for reed solomon
/// error correction.
/// Polynomials with 7 to 30 coefficients (required for qrcode error correction)
/// are taken from a precomputed table, while larger polynomials will have to be
/// computed.
///
/// >>> qrutil.rs-generator(0) == (1,)
/// >>> qrutil.rs-generator(1) == (1, 1)
/// >>> qrutil.rs-generator(7) == (1, 127, 122, 154, 164, 11, 68, 117)
/// >>> qrutil.rs-generator(16) == (1, 59, 13, 104, 189, 68, 209, 30, 8, 163, 65, 41, 229, 98, 50, 36, 59)
/// >>> qrutil.rs-generator(30) == (1, 212, 246, 77, 73, 195, 192, 75, 98, 5, 70, 103, 177, 22, 217, 138, 51, 181, 246, 72, 25, 18, 46, 228, 74, 216, 195, 11, 106, 130, 150)
#let rs-generator(cw-count) = {
  if cw-count >= 7 and cw-count <= 30 {
    return qrluts.generators.at(cw-count - 7)
  }
  let g = (1,)
  let start = 0
  if cw-count > 30 {
    g = qrluts.generators.at(23)
    start = 30
  }
  for i in range(start, cw-count) {
    g = gf-poly-mul(g, (1, exp(i)))
  }
  return g
}


// =================================
//  Error correction
// =================================
/// >>> qrutil.data-blocks(1, "l") == 1
/// >>> qrutil.data-blocks(6, "m") == 4
/// >>> qrutil.data-blocks(7, "l") == 2
/// >>> qrutil.data-blocks(7, "m") == 4
/// >>> qrutil.data-blocks(7, "q") == 6
/// >>> qrutil.data-blocks(7, "h") == 5
/// >>> qrutil.data-blocks(18, "q") == 18
/// >>> qrutil.data-blocks(19, "h") == 25
#let data-blocks(version, ecl) = {
  let (_, blocks) = qrluts.blocks.at(version - 1).at(ecl)
  return blocks
}

/// >>> qrutil.ec-codewords(1, "l") == 7
/// >>> qrutil.ec-codewords(2, "m") == 16
/// >>> qrutil.ec-codewords(6, "m") == 16
/// >>> qrutil.ec-codewords(7, "l") == 20
/// >>> qrutil.ec-codewords(7, "m") == 18
/// >>> qrutil.ec-codewords(7, "q") == 18
/// >>> qrutil.ec-codewords(7, "h") == 26
/// >>> qrutil.ec-codewords(18, "q") == 28
/// >>> qrutil.ec-codewords(19, "h") == 26
#let ec-codewords(version, ecl) = {
  let (ecw-count, _) = qrluts.blocks.at(version - 1).at(ecl)
  return ecw-count
}

/// >>> qrutil.ec-total-codewords(1, "l") == 7
/// >>> qrutil.ec-total-codewords(6, "m") == 64
/// >>> qrutil.ec-total-codewords(7, "q") == 108
/// >>> qrutil.ec-total-codewords(18, "q") == 504
/// >>> qrutil.ec-total-codewords(19, "h") == 650
#let ec-total-codewords(version, ecl) = {
  let (ecw-count, blocks) = qrluts.blocks.at(version - 1).at(ecl)
  return ecw-count * blocks
}

/// >>> qrutil.block-sizes(1, "l") == (19,)
/// >>> qrutil.block-sizes(1, "q") == (13,)
/// >>> qrutil.block-sizes(6, "m") == (27,27,27,27)
/// >>> qrutil.block-sizes(7, "l") == (78,78)
/// >>> qrutil.block-sizes(7, "m") == (31,31,31,31)
/// >>> qrutil.block-sizes(7, "q") == (14,14,15,15,15,15)
/// >>> qrutil.block-sizes(7, "h") == (13,13,13,13,14)
/// >>> qrutil.block-sizes(18, "q") == (22,) * 17 + (23,)
/// >>> qrutil.block-sizes(28, "l") == (117,117,117) + (118,)*10
#let block-sizes(version, ecl) = {
  let (ecw-count, blocks) = qrluts.blocks.at(version - 1).at(ecl)
  let dcw-count = data-codewords(version, ecl)

  let group1-size = calc.floor(dcw-count / blocks)
  let group1-blocks = blocks - calc.rem(dcw-count, blocks)

  let block-sizes = (group1-size,) * group1-blocks
  if group1-blocks < blocks {
    block-sizes += (group1-size + 1,) * (blocks - group1-blocks)
  }

  return block-sizes
}

/// Computes the reed solomon error correction codewords
/// for the given data codewords and error correction level.
///
/// >>> qrutil.rs-codewords((32, 91, 11, 120, 209, 114, 220, 77, 67, 64, 236, 17, 236, 17, 236, 17), 1, "m") == (196, 35, 39, 119, 235, 215, 231, 226, 93, 23)
/// >>> qrutil.rs-codewords((32, 91, 11, 120, 209, 114, 220, 77, 67, 64) + (236, 17)*34, 7, "l") == (91, 2, 102, 15, 224, 203, 242, 110, 15, 230, 29, 12, 200, 155, 139, 51, 72, 68, 172, 13)
/// >>> qrutil.rs-codewords((236, 17)*39, 7, "l") == (44, 103, 50, 234, 161, 185, 11, 175, 110, 82, 242, 131, 109, 162, 175, 240, 131, 250, 74, 60)
/// >>> qrutil.rs-codewords((32, 91, 11, 120, 209, 114, 220, 77, 67, 64, 236, 17, 236, 17, 236, 17), 7, "m") == (164, 98, 130, 114, 171, 107, 27, 65, 50, 175, 129, 240, 155, 77, 250, 132, 137, 165)
/// >>> qrutil.rs-codewords((32, 91, 11, 120, 209, 114, 220, 77, 67, 64, 236, 17, 236, 17, 236, 17), 7, "h") == (163, 10, 238, 68, 145, 138, 74, 25, 128, 199, 247, 20, 104, 9, 102, 110, 101, 62, 244, 230, 53, 30, 28, 155, 231, 64)
/// >>> qrutil.rs-codewords((16, 32, 12, 86, 97, 128, 236, 17, 236, 17, 236, 17, 236, 17, 236, 17), 1, "m") == (165, 36, 212, 193, 237, 54, 199, 135, 44, 85)
/// >>> qrutil.rs-codewords((65, 166, 135, 71, 71, 7, 51, 162, 242, 247, 119, 119, 114, 231, 23, 38, 54, 246, 70, 82, 230, 54, 246, 210, 240, 236, 17, 236), 2, "m") == (43, 26, 183, 84, 208, 221, 49, 187, 191, 133, 63, 208, 63, 44, 207, 202)
#let rs-codewords(data-codewords, version, ecl) = {
  let cw-count = ec-codewords(version, ecl)
  let gen = rs-generator(cw-count)
  let r = gf-poly-rem(array(data-codewords) + (0,) * cw-count, gen)

  return r
}


// =================================
//  Interleaving blocks
// =================================
/// >>> qrutil.get-remainders(1) == 0
/// >>> qrutil.get-remainders(5) == 7
/// >>> qrutil.get-remainders(7) == 0
/// >>> qrutil.get-remainders(18) == 3
/// >>> qrutil.get-remainders(22) == 4
#let get-remainders(version) = {
  if version in (2,3,4,5,6) {
    return 7
  } else if version in (14,15,16,17,18,19,20, 28,29,30,31,32,33,34) {
    return 3
  } else if version in (21,22,23,24,25,26,27) {
    return 4
  } else {
    return 0
  }
}

/// >>> qrutil.generate-blocks((65, 166, 135, 71, 71, 7, 51, 162, 242, 247, 119, 119, 114, 231, 23, 38, 54, 246, 70, 82, 230, 54, 246, 210, 240, 236, 17, 236), 2, "m") == (65, 166, 135, 71, 71, 7, 51, 162, 242, 247, 119, 119, 114, 231, 23, 38, 54, 246, 70, 82, 230, 54, 246, 210, 240, 236, 17, 236, 43, 26, 183, 84, 208, 221, 49, 187, 191, 133, 63, 208, 63, 44, 207, 202)
/// >>> qrutil.generate-blocks((32, 91, 11, 120, 209, 114, 220, 77, 67, 64) + (236, 17) * 73, 7, "l") == (32, 236, 91, 17, 11, 236, 120, 17, 209, 236, 114, 17, 220, 236, 77, 17, 67, 236, 64, 17, 236, 236, 17, 17, 236, 236, 17, 17, 236, 236, 17, 17, 236, 236, 17, 17, 236, 236, 17, 17, 236, 236, 17, 17, 236, 236, 17, 17, 236, 236, 17, 17, 236, 236, 17, 17, 236, 236, 17, 17, 236, 236, 17, 17, 236, 236, 17, 17, 236, 236, 17, 17, 236, 236, 17, 17, 236, 236, 17, 17, 236, 236, 17, 17, 236, 236, 17, 17, 236, 236, 17, 17, 236, 236, 17, 17, 236, 236, 17, 17, 236, 236, 17, 17, 236, 236, 17, 17, 236, 236, 17, 17, 236, 236, 17, 17, 236, 236, 17, 17, 236, 236, 17, 17, 236, 236, 17, 17, 236, 236, 17, 17, 236, 236, 17, 17, 236, 236, 17, 17, 236, 236, 17, 17, 236, 236, 17, 17, 236, 236, 17, 17, 236, 236, 17, 17, 91, 44, 2, 103, 102, 50, 15, 234, 224, 161, 203, 185, 242, 11, 110, 175, 15, 110, 230, 82, 29, 242, 12, 131, 200, 109, 155, 162, 139, 175, 51, 240, 72, 131, 68, 250, 172, 74, 13, 60)
#let generate-blocks(codewords, version, ecl) = {
  codewords = array(codewords)

  let block-sizes = block-sizes(version, ecl)
  if block-sizes.len() == 1 {
    return codewords + array(rs-codewords(codewords, version, ecl))
  } else {
    let blocks = ()
    let ec-codewords = ()

    // Get blocks and error correction codewords
    let i = 0
    for bs in block-sizes {
      let block = codewords.slice(i, i + bs)
      blocks.push(block)
      ec-codewords.push(rs-codewords(block, version, ecl))

      i += bs
    }

    // generate interleaved data
    codewords = ()
    let max = calc.max(..block-sizes)
    for i in range(max) {
      for b in blocks {
        if i < b.len() {
          codewords.push( b.at(i) )
        }
      }
    }
    // interleave ec codewords
    max = ec-codewords.first().len()
    for i in range(max) {
      for ec in ec-codewords {
        codewords.push( ec.at(i) )
      }
    }

    return codewords
  }
}


// =================================
//  Masking
// =================================
#let masks = (
  (i, j) => mod2(i+j) == 0,
  (i, j) => mod2(i) == 0,
  (i, j) => mod3(j) == 0,
  (i, j) => mod3(i+j) == 0,
  (i, j) => mod2(int(i / 2) + int(j / 3)) == 0,
  (i, j) => (mod2(i * j) + mod3(i * j)) == 0,
  (i, j) => mod2(mod2(i * j) + mod3(i * j)) == 0,
  (i, j) => mod2(mod2(i + j) + mod3(i * j)) == 0
)

#let is-masked(i, j, mask) = (masks.at(mask))(i, j)

#let apply-mask(i, j, bit, mask) = is-masked(i, j, mask) != bit

#let check-mask(field, mask, version) = {
  let size = size(version)

  let mask-count = masks.len()

  let penalties = (0,0,0,0)
  let cond1-runs = (0, 0)
  let cond2-win = ()
  let cond3-pattern1 = bits.from-str("00001011101")
  let cond3-pattern2 = bits.from-str("10111010000")
  let cond4-n = 0

  for i in range(size) {
    let cond3-win = ((), ())

    for j in range(size) {
      let bits = (field.at(i).at(j),  field.at(j).at(i))
      let masked-bits = bits
      if not is-reserved(i, j, version) {
        masked-bits.at(0) = apply-mask(i, j, masked-bits.at(0), mask)
      }
      if not is-reserved(j, i, version) {
        masked-bits.at(1) = apply-mask(j, i, masked-bits.at(1), mask)
      }

      // Condition 1
      // Check rows and cols for runs of 5 or more
      // modules of same value
      for x in (0, 1) {
        if masked-bits.at(x) {
          cond1-runs.at(x) += 1
        } else {
          if cond1-runs.at(x) >= 5 {
            penalties.at(0) += 3 + calc.max(0,
              (cond1-runs.at(x) - 5))
            cond1-runs.at(x) = 0
          }
        }
      }

      // Condition 2
      // Use a running window of 2x2 modules and
      // with (i,j) in the top right and check for
      // the same value.
      if i > 0 and j > 0 {
        if cond2-win.len() < 4 {
          cond2-win = (
            masked-bits.at(0),
            apply-mask(i - 1, j, field.at(i - 1).at(j  ), mask),
            apply-mask(i, j - 1, field.at(i  ).at(j - 1), mask),
            apply-mask(i - 1, j - 1, field.at(i - 1).at(j - 1), mask)
          )
        } else {
          cond2-win = (
            masked-bits.at(0),
            apply-mask(i - 1, j, field.at(i - 1).at(j), mask),
            cond2-win.at(0),
            cond2-win.at(1)
          )
        }
        // Check for blocks of same color
        if cond2-win.all(x => x==true) or cond2-win.all(x => x==false) {
          penalties.at(1) += 3
        }
      }

      // Condition 3
      // Use running windows for rows and columns
      // to check against the predefined patterns.
      for x in (0, 1) {
        if cond3-win.at(x).len() < 11 {
          cond3-win.at(x).push( masked-bits.at(x) )
        } else {
          cond3-win.at(x) = cond3-win.at(x).slice(1) + (masked-bits.at(x),)
        }
        if cond3-win.at(x) == cond3-pattern1 or cond3-win.at(x) == cond3-pattern2 {
          penalties.at(2) += 40
        }
      }

      // Condition 4
      // Just count black modules for now
      if masked-bits.at(0) {
        cond4-n += 1
      }
    }
  }
  // Condition 4
  // compute final penalty
  let total = size * size
  let p = int((cond4-n / total) * 100)
  let v = (p - calc.rem(p, 5), p + (5 - calc.rem(p, 5)))
  v = v.map(x => calc.quo(calc.abs(x - 50), 5))
  penalties.at(3) = calc.min(..v) * 10

  // calculate sum of condition 1 to 4 panalties
  return penalties.fold(0, (s, x) => s + x)
}

#let best-mask(field, version) = {
  let mask = 0
  let penalty = check-mask(field, 0, version)
  for m in range(1, masks.len()) {
    let p = check-mask(field, m, version)
    if p < penalty {
      mask = m
      penalty = p
    }
  }
  return mask
}
