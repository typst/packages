#import "utils.typ": xor-bytes
#import "sha.typ": sha1
#import "md.typ": md4
#import "utils.typ": utf8-to-utf16le, z-fill
#import "base.typ": b32-decode

#let _compute-block-sized-key(key, hash-func: sha1, block-size: 64) = {
  if key.len() > block-size {
    key = hash-func(key)
  }

  if key.len() < block-size {
    key = bytes((0,) * (block-size - key.len())) + key
  }

  return  key
}

#let _extract31(value) = {
  let bytes = array(value)
  let i = bytes.last().bit-and(0xf)
  let selected-bytes = (
    bytes.at(i).bit-and(0x7f),
    bytes.at(i+1),
    bytes.at(i+2),
    bytes.at(i+3)
  )
  return selected-bytes.fold(0, (a, b) => a.bit-lshift(8).bit-or(b))
}

/// Hash-based Message Authentication Code
/// ```example
/// #bytes-to-hex(hmac("Key", "Hello World!"))
/// ```
/// -> bytes
#let hmac(
  /// Hashing key
  /// -> str | bytes
  key,
  /// Message to hash
  /// -> str | bytes
  message,
  /// Hashing function
  /// -> function
  hash-func: sha1,
  /// Block size
  /// -> number
  block-size: 64
) = {
  let key = if type(key) == str {bytes(key)} else {key}
  let message = if type(message) == str {bytes(message)} else {message}
  assert(type(key) == bytes, message: "key must be a string or bytes, but is " + repr(type(key)))
  assert(type(message) == bytes, message: "message must be a string or bytes, but is " + repr(type(message)))

  let block-sized-key = _compute-block-sized-key(key, hash-func: hash-func, block-size: block-size)

  let i-pad = bytes((0x36,) * block-size)
  let o-pad = bytes((0x5c,) * block-size)
  let i-key-pad = xor-bytes(key, i-pad)
  let o-key-pad = xor-bytes(key, o-pad)

  return hash-func(o-key-pad + hash-func(i-key-pad + message))
}

/// New Technology LAN Manager (aka. Windows password hash)
/// ```example
/// #bytes-to-hex(ntlm("Bellevue"))
/// ```
/// -> bytes
#let ntlm(password) = {
  return md4(utf8-to-utf16le(password))
}

/// Time-based One-Time Password
/// ```example
/// #let epoch = datetime(
///   year: 1970, month: 1, day: 1,
///   hour: 0, minute: 0, second: 0
/// )
/// #let date = datetime(
///   year: 2025, month: 1, day: 4,
///   hour: 12, minute: 53, second: 30
/// )
/// #totp(
///   b32-encode(bytes("YOUPI")),
///   (date - epoch).seconds()
/// )
/// ```
/// -> str
#let totp(
  /// Secret key. Either bytes or a base32-encode value
  /// -> str | bytes
  secret,
  /// Current time (seconds since t0)
  /// -> int
  time,
  /// Time origin
  /// -> int
  t0: 0,
  /// Code duration
  /// -> int
  period: 30,
  /// Code length
  /// -> int
  digits: 6
) = {
  let secret = if type(secret) == str {b32-decode(secret)} else {secret}
  assert(type(secret) == bytes, message: "secret must be a string or bytes, but is " + repr(type(secret)))

  let count = int(calc.div-euclid(time - t0, period))
  let count-bytes = count.to-bytes(endian: "big", size: 8)
  
  let digest = hmac(secret, count-bytes)
  let hotp = _extract31(digest)
  let code = calc.rem(hotp, calc.pow(10, digits))

  return z-fill(str(code), digits)
}