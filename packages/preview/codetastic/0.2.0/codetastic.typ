
#import "bits.typ"
#import "bitfield.typ"
#import "util.typ"
#import "checksum.typ"
#import "ecc.typ"


/// Encode a digit into seven bits according to the
/// EAN-13 standard.
/// Each digit is encoded into seven bits via one
/// of three encoding tables, determined by
/// #arg[i] and #arg[odd].
#let ean13-encode( i, number, odd:none ) = {
  // Get code A codeword
  let code = bits.from-str((
    "0001101", "0011001", "0010011", "0111101", "0100011",
    "0110001", "0101111", "0111011", "0110111", "0001011"
  ).at(number))

  if i >= 6 {
    // Get code C codewort (right side)
    return bits.inv(code)
  } else if not odd {
    // Get code B codewort (left side, even)
    return bits.inv(code).rev()
  } else {
    // Get code A codewort (left side, odd)
    return code
  }
}


/// Create an EAN-5 barcode.
///
/// #example(side-by-side: true, `#codetastic.ean5(12345)`)
///
/// The #arg[code] can be given as a five digit number in integer
/// or string format, or as an array with five integer digits.
///
/// The size of the barcode can be scaled down to 80% and up to 200%. The height of the bars
/// can be trimmed down to 50%.
/// #example(side-by-side: true, ```#codetastic.ean5(
///   scale:(1.8, .5), "90000")
/// ```)
///
/// EAN-5 codes are usually added to ean-13 codes as add-ons:
/// #example(```
/// #grid(columns:2, row-gutter: 2pt,
///   align(center, text(6pt, font:"Arial", "ISBN: 978-1-123-12345-6")), [],
///   codetastic.ean13("9781123123456"), codetastic.ean5(scale:.9, "90000")
/// )
/// ```)
///
/// #text(.88em)[See #link("https://www.softmatic.com/barcode-ean-13.html#ean-add-on") for more
/// information about EAN-5 codes.]
///
/// - code (integer,string,array): A five digit number as integer or string, or an array with five integers.
/// - scale (float): Scale of the code between #value(.8) and #value(2).
/// - colors (array): An array with exactly two colors: background and foreground.
#let ean5(
  code,
  scale: 1,
  colors: (white, black)
) = {
  if type(scale) != "array" {
    scale = (scale, scale)
  }
  let (scale-x, scale-y) = (
    calc.clamp(scale.at(0), .8, 2),
    calc.clamp(scale.at(1), .5, 1)
  )

  let (bg, fg) = colors

  code = util.to-int-arr(code)

  let checksum = checksum.ean5(code)
  let parities = bits.from-str((
      "00111", "01011", "01101", "01110", "10011",
      "11001", "11100", "10101", "10110", "11010"
    ).at(checksum))

  // Do the encoding
  let encoded = bits.from-str("01011")
  for (i, n) in code.enumerate() {
    encoded += ean13-encode(i, n, odd:parities.at(i))
    encoded += (false, true)
  }

  // Prepare styles and canvas
  let width = 0.264mm * scale-x
  let height = 18.28mm * scale-x * scale-y
  let font-size = 8pt * scale-x

  let txt = text.with(
    font: "Arial",
    size: font-size,
    fill: fg,
    tracking: font-size * .25
  )

  util.place-code({
    util.draw-bars(
      encoded,
      bar-width:width, bar-height:height,
      fg:fg, bg:bg
    )
    util.place-content(
      0pt, -height - font-size,
      width * encoded.len(), font-size,
      txt(code.map(str).join())
    )
  })
}


/// Create an EAN-8 barcode.
///
/// #example(side-by-side: true, `#codetastic.ean8(2903370)`)
///
/// The #arg[code] can be given as a seven or eight digit number in integer
/// or string format, or as an array with seven or eight integer digits.
/// Codes with seven digits will have the checksum value appended to the code, while
/// for eight digit codes the given checksum is validated.
///
/// The size of the barcode can be scaled down to 80% and up to 200%. The height of the bars
/// can be trimmed down to 50%.
/// #example(side-by-side: true, ```#codetastic.ean8(
///   scale:(1.8, .5), "29033706")
/// ```)
///
/// #text(.88em)[See #link("https://www.softmatic.com/barcode-ean-8.html") for more
/// information about EAN-8 codes.]
///
/// - code (integer,string,array): Either a seven or eight digit number as integer or string, or an array with seven or eight integers.
/// - scale (float): Scale of the code between #value(.8) and #value(2).
/// - colors (array): An array with exactly two colors: background and foreground.
/// - lmi (boolean): If #value(true), _ light margin indicators_ will be shown.
///   #example(side-by-side: true, `#codetastic.ean8(lmi:true, 29033706)`)
#let ean8(
  code,
  scale: 1,
  colors: (white, black),
  lmi: false
) = {
  if type(scale) != "array" {
    scale = (scale, scale)
  }
  let (scale-x, scale-y) = (
    calc.clamp(scale.at(0), .8, 2),
    calc.clamp(scale.at(1), .5, 1)
  )

  let (bg, fg) = colors

  code = util.to-int-arr(code)
  if code.len() < 7 {
    code = (0,) * (7 - code.len()) + code
  }
  code = util.check-code(
    code, 8, checksum.ean8, checksum.ean8-test
  )

  // Do the encoding
  let encoded = bits.from-str("00000000000101")
  for (i, n) in code.slice(0,4).enumerate() {
    encoded += ean13-encode(0, n, odd:true)
  }
  encoded += bits.from-str("01010")
  for (i,n) in code.slice(4).enumerate() {
    encoded += ean13-encode(6, n)
  }
  encoded += bits.from-str("1010000000")

  // Prepare styles and canvas
  let width = 0.264mm * scale-x
  let height = 18.28mm * scale-x * scale-y
  let font-size = 6pt * scale-x

  let txt = text.with(
    font: "Arial",
    size: font-size,
    fill: fg,
    tracking: font-size * .25
  )

  util.place-code({
    util.draw-bars(
      encoded,
      bar-width:width, bar-height:height,
      fg:fg, bg:bg
    )
    util.place-content(
      14 * width, -font-size,
      28 * width, font-size, fill:bg,
      txt(code.slice(0,4).map(str).join())
    )
    util.place-content(
      47 * width, -font-size,
      28 * width, font-size, fill:bg,
      txt(code.slice(4).map(str).join())
    )
    if lmi {
      util.place-content(
        0 * width, -font-size,
        11 * width, font-size, fill:bg,
        txt(sym.lt)
      )
      util.place-content(
        78 * width, -font-size,
        7 * width, font-size, fill:bg,
        txt(sym.gt)
      )
    }
  })
}


/// Create an EAN-13 barcode.
///
/// #example(side-by-side: true, `#codetastic.ean13(240701400194)`)
///
/// The #arg[code] can be given as a 12 or 13 digit number in integer
/// or string format, or as an array with 12 or 13 integer digits.
/// Codes with 12 digits will have the checksum value appended to the code, while
/// for 13 digit codes the given checksum is validated.
///
/// The size of the barcode can be scaled down to 80% and up to 200%. The height of the bars
/// can be trimmed down to 50%.
/// #example(side-by-side: true, ```#codetastic.ean13(
///   scale:(1.8, .5), "2407014001944")
/// ```)
///
/// #text(.88em)[See #link("https://www.softmatic.com/barcode-ean-13.html") for more
/// information about EAN-13 codes.]
///
/// - code (integer,string,array): Either a 12 or eight 13 number as integer or string, or an array with 12 or 13 integers.
/// - scale (float): Scale of the code between #value(.8) and #value(2).
/// - colors (array): An array with exactly two colors: background and foreground.
/// - lmi (boolean): If #value(true), a _light margin indicator_ will be shown.
///   #example(side-by-side: true, `#codetastic.ean13(lmi:true, 9781234567897)`)
#let ean13(
  code,
  scale: 1,
  colors: (white, black),
  lmi: false
) = {
  if type(scale) != "array" {
    scale = (scale, scale)
  }
  let (scale-x, scale-y) = (
    calc.clamp(scale.at(0), .8, 2),
    calc.clamp(scale.at(1), .5, 1)
  )

  let (bg, fg) = colors

  code = util.to-int-arr(code)
  if code.len() < 12 {
    code = (0,) * (12 - code.len()) + code
  }
  code = util.check-code(
    code, 13, checksum.ean13, checksum.ean13-test
  )
  let first = code.remove(0)

  let parities = bits.from-str((
    "111111", "110100", "110010", "110001", "101100",
    "100110", "100011", "101010", "101001", "100101"
  ).at(first))

  // Do the encoding
  let encoded = bits.from-str("00000000000101")
  for (i, n) in code.slice(0,6).enumerate() {
    encoded += ean13-encode(i, n, odd:parities.at(i))
  }
  encoded += bits.from-str("01010")
  for (i,n) in code.slice(6).enumerate() {
    encoded += ean13-encode(6 + i, n)
  }
  encoded += bits.from-str("1010000000")

  // Prepare styles and canvas
  let width = 0.264mm * scale-x
  let height = 18.28mm * scale-x * scale-y
  let font-size = 6pt * scale-x

  let txt = text.with(
    font: "Arial",
    size: font-size,
    fill: fg,
    tracking: font-size * .25
  )

  util.place-code({
    util.draw-bars(
      encoded,
      bar-width:width, bar-height:height,
      fg:fg, bg:bg
    )
    util.place-content(
      0 * width, -font-size,
      11 * width, font-size, fill:bg,
      txt(str(first))
    )
    util.place-content(
      14 * width, -font-size,
      42 * width, font-size, fill:bg,
      txt(code.slice(0, 6).map(str).join())
    )
    util.place-content(
      61 * width, -font-size,
      42 * width, font-size, fill:bg,
      txt(code.slice(6).map(str).join())
    )
    if lmi {
      util.place-content(
        106 * width, -font-size,
        7 * width, font-size, fill:bg,
        txt(sym.gt)
      )
    }
  })
}


/// Create an UPC-A barcode.
///
/// #example(side-by-side: true, `#codetastic.upc-a("03600029145")`)
///
/// The #arg[code] can be given as a 11 or 12 digit number in integer
/// or string format, or as an array with 11 or 12 integer digits.
/// Codes with 11 digits will have the checksum value appended to the code, while
/// for 12 digit codes the given checksum is validated.
///
/// The size of the barcode can be scaled down to 80% and up to 200%. The height of the bars
/// can be trimmed down to 50%.
/// #example(side-by-side: true, ```#codetastic.upc-a(
///   scale:(1.8, .5), "03600029145")
/// ```)
///
/// #text(.88em)[See #link("https://www.softmatic.com/barcode-upc-a.html") for more
/// information about UPC-A codes.]
///
/// - code (integer,string,array): Either a 11 or eight 12 number as integer or string, or an array with 11 or 12 integers.
/// - scale (float): Scale of the code between #value(.8) and #value(2).
/// - colors (array): An array with exactly two colors: background and foreground.
/// - lmi (boolean): If #value(true), a _light margin indicator_ will be shown.
///   #example(side-by-side: true, `#codetastic.upc-a(lmi:true, "03600029145")`)
#let upc-a(
  code,
  scale: 1,
  colors: (white, black),
  lmi: false
) = {
  if type(scale) != "array" {
    scale = (scale, scale)
  }
  let (scale-x, scale-y) = (
    calc.clamp(scale.at(0), .8, 2),
    calc.clamp(scale.at(1), .5, 1)
  )


  let (bg, fg) = colors

  code = util.to-int-arr(code)
  code = util.check-code(
    code, 12, checksum.upc-a, checksum.upc-a-test
  )

  // Do the encoding
  let encoded = bits.from-str("000000000101")
  for n in code.slice(0,6) {
    encoded += ean13-encode(0, n, odd:true)
  }
  encoded += bits.from-str("01010")
  for n in code.slice(6) {
    encoded += ean13-encode(6, n)
  }
  encoded += bits.from-str("101000000000")

  // Prepare styles and canvas
  let width = 0.33mm * scale-x
  let height = 25.9mm * scale-x * scale-y + 5 * width
  let font-size = 5 * width

  let txt = text.with(
    font: "Arial",
    size: font-size,
    fill: fg,
    tracking: font-size * .25
  )

  util.place-code({
    util.draw-bars(
      encoded,
      bar-width:width, bar-height:height,
      fg:fg, bg:bg
    )
    util.place-content(
      0 * width, -font-size,
      9 * width, font-size, fill:bg,
      txt(str(code.first()))
    )
    util.place-content(
      12 * width, -font-size,
      42 * width, font-size, fill:bg,
      txt(code.slice(1, 6).map(str).join())
    )
    util.place-content(
      59 * width, -font-size,
      42 * width, font-size, fill:bg,
      txt(code.slice(6, -1).map(str).join())
    )
    if lmi {
      util.place-content(
        104 * width, -font-size,
        9 * width, font-size, fill:bg,
        txt(str(code.last()))
      )
    }
  })
}

// #let upc-e(
//   code,
//   scale: 1,
//   colors: (white, black),
//   lmi: false
// ) = {}


// #let data-matrix( data, size: 14, quiet-zone: 1 ) = {
//   // Create matrix with timing and alignment patterns
//   let field = bitfield.new(
//     14, 14,
//     init: (i,j) => {
//       i == 0 or j == 0 or (j == 13 and calc.even(i)) or (i == 13 and calc.even(j))
//     }
//   )

//   util.place-code({
//     util.draw-modules(field)
//   })
// }


/// Draws a QR-Code encoding #arg[data].
///
/// #example(`#codetastic.qrcode("https://qrcode.com/en")`)
///
/// #wbox[*Some caveats*:\
/// - The generation of larger codes can take quit some time.
/// - To speed-up compilation times, calculations for the optimal masking patterns don't
///   the same approach as defined in the qr-code documentation. Codes will still be valid,
///   but might look differnt than the output of other generators.
/// - Kanji and ECI encodings are not yet supported. Maybe they will be in the future.
/// - UTF-8 is not supported.]
/// #ibox[*Improving speed for larger code versions*:\
/// Generating qr-codes with large amount of data can take long. Calculating the best
/// masking pattern to produce the most readable code is currently one of the most
/// expensive calculations in code creation. This can be mitigated by manually setting
/// the mask to use. To do so, follow these steps:
/// - Compile your document while passing #arg(debug: true) to #cmd-[qrcode].
/// - After compilation finished, look for the code in your output and note the mask
///   number shown above the code.
/// - Remove the #arg[debug] argument and set #arg[mask] to the mask number.
/// Now the code creation will skip detection of the optimal mask and use the passed in
/// mask. This should speed-up compilation times considerably.]
///
/// - data (string): The data to encode.
/// - quiet-zone (integer): Whitespace around the code in number of modules. The qr-code standard
///   suggests a quiet zone of at least four modules.
/// - min-version (integer): Minimum version for the code. A number between 1 and 40. If #arg[data]
///   is to large for the minimum code verison, the next larger verison that fits the data is selected.
/// - ecl (string): Error correction level. One of #value("l"), #value("m"), #value("q") or #value("h").
/// - mask (auto, integer): Forces a mask to apply to the code. Number between (0 and 7). For #value(auto) the best mask is selected according to the qr-code standard.
/// - size (auto, length): Size of a modules square.
/// - width (auto, length): If set to a length, the module size will be adjusted to create a qr-code
///   with the given width. Will overwrite any setting for #arg[size].
/// - colors (array): An array with exactly two colors: background and foreground.
#let qrcode(
  data,
  quiet-zone: 4,
  min-version: 1,
  ecl: "l",
  mask: auto,
  size: auto,
  width: auto,
  colors: (white, black),
  debug: false
) = {
  import "qrutil.typ"

  assert(qrutil.check-ecl(ecl), message:"Error correction level need to be one of l,m,q or h. Got " + repr(ecl))

  let module-size = size
  let (bg, fg) = colors

  // prepare encoding method
  // (numeric, alphanumeric, byte or kanji)
  let mode = qrutil.best-mode(data)
  if mode == none {
    panic("Supplied data contains characters that can't be encoded with one of the supported methods numeric, alphanumeric or byte (iso-8859-1).")
  }

  // determine final qr-code version from
  // data size and min-version argument
  min-version = if min-version == auto {1} else {calc.clamp(min-version, 1, 40)}
  let version = calc.max(min-version,
    qrutil.best-version(
      data.len(), ecl, mode)
  )

  // encode data
  let encoded = qrutil.encode(data, version, ecl, mode:mode)

  // interleave data codewords and error correction
  encoded = qrutil.generate-blocks(encoded, version, ecl)

  assert.eq(encoded.len(), qrutil.total-codewords(version))

  // Create empty matrix
  let size = qrutil.size(version)
  let field = bitfield.new(size, size)
  // Reserve bits
  field = qrutil.reserve-bits(field, version)

  // Add data in zig-zag pattern
  let dir = -1
  let (i, j) = (size - 1, size - 1)
  for codeword in array(encoded) {
    let b = bits.from-int(codeword, pad:8)

    let x = 0
    while x < 8 {
      if not field.at(i).at(j) {
        field.at(i).at(j) = b.at(x)
        x += 1
      }

      if (j > 6 and calc.even(j)) or (j < 6 and calc.odd(j)) {
        j -= 1
      } else {
        i += dir
        j += 1
      }
      if i < 0 or i >= size {
        dir *= -1
        if dir == 1 {
          (i, j) = (0, j - 2)
        } else {
          (i, j) = (size - 1, j - 2)
        }

        if j == 6 {
          j -= 1
        }
      }
    }
  }

  // Masking
  if mask == auto {
    // compute best mask for this code
    (mask, field) = qrutil.best-mask(field, version)
  } else if mask != none {
    // use given mask
    mask = calc.clamp(mask, 0, 7)

    for i in range(size) {
      for j in range(size) {
        field.at(i).at(j) = qrutil.apply-mask(
          i, j, field.at(i).at(j), mask
        )
      }
    }
  } else {
    // TODO: Remove!
    // Dummy mask number for adding format information.
    // Just for debugging!
    mask = 0
  }

  field = qrutil.set-reserved-bits(field, version, ecl, mask)

  // calculate module size
  if width != auto {
    module-size = width / size
  } else if module-size == auto {
    // TODO: calculate reasonable module size from version
    module-size = 2mm
  }

  if debug {
    [Version: #version, Ecl: #ecl, Mode: #mode, Mask: #mask]
  }
  // Draw modules
  util.place-code({
    util.draw-modules(
      field,
      quiet-zone: quiet-zone,
      size: module-size,
      bg: bg, fg: fg
    )
  })
}

// #let micro-qrcode(
//   data,
//   quiet-zone: 4,
//   min-version: 1,
//   ecl: "l",
//   mask: auto,
//   size: auto,
//   width: auto,
//   colors: (white, black),
//   debug: false
// ) = {}
