/// Convert a number to a binary array and pad it.
///
/// Arguments:
/// - number: The number to convert.
/// - size: The size of the array. If given, the array will be padded with 0s.
///
/// Returns: The binary array.
#let bin(number, size: none) = {
  let result = while number > 0 {
    (calc.rem(number, 2),)
    number = calc.floor(number / 2);
  }

  if result == none { result = (0,) }
  if size != none and result.len() < size {
    result.push(((0,) * (size - result.len())));
  }

  return result.rev().flatten();
}

/// Convert a binary array to a number.
///
/// Arguments:
/// - array: The binary array to convert.
///
/// Returns: The number.
#let dec(array) = {
  array.enumerate().fold(0, (acc, (i, bit)) => {
    acc + bit * calc.pow(2, (array.len() - i - 1))
  })
}

/// Encodes the given data with the given alphabet.
///
/// Arguments:
/// - data: The data to encode. Must be of type array, bytes, or string.
/// - alphabet: The alphabet to use for encoding. Its size must be a power of 2.
/// - pad: Whether to pad the output with "=" characters.
///
/// Returns: The encoded string.
#let encode(data, alphabet, pad: true) = {
  let chunk-size = calc.log(alphabet.len(), base: 2)
  assert.eq(calc.fract(chunk-size), 0, message: "alphabet size must be a power of 2")
  chunk-size = int(chunk-size)
  
  let bytes = array(bytes(data))
  if bytes.len() == 0 { return "" }

  let bits = bytes.map(bin.with(size: 8)).flatten()

  let pad-chunk-amount = calc.rem(chunk-size - calc.rem(bits.len(), chunk-size), chunk-size)
  bits += ((0,) * pad-chunk-amount)

  let string = for i in range(0, bits.len(), step: chunk-size) {
    let chunk = bits.slice(i, i + chunk-size)
    alphabet.at(dec(chunk))
  }

  if pad {
    let lcm = calc.lcm(8, chunk-size)
    let pad-amount = calc.rem(lcm - calc.rem(bits.len(), lcm), lcm)
    string += range(int(pad-amount / chunk-size)).map(_ => "=").join("")
  }

  string
}

/// Decodes the given string with the given alphabet.
///
/// Arguments:
/// - string: The string to decode.
/// - alphabet: The alphabet to use for decoding.
///
/// Returns: The decoded bytes.
#let decode(string, alphabet) = {
  let chunk-size = calc.log(alphabet.len(), base: 2)
  assert.eq(calc.fract(chunk-size), 0, message: "alphabet size must be a power of 2")
  chunk-size = int(chunk-size)
  
  string = string.replace("=", "")

  let bits = string.codepoints()
    .map(c => alphabet.position(c))
    .filter(n => n != none)
    .map(bin.with(size: chunk-size))
    .flatten()

  let pad-amount = calc.rem(bits.len(), 8)
  if pad-amount > 0 {
    bits = bits.slice(0, -pad-amount)
  }

  let byte-array = range(0, bits.len(), step: 8).map(i => {
    let chunk = bits.slice(i, i + 8)
    dec(chunk)
  })

  bytes(byte-array)
}
