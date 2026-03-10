
#let p = plugin("digestify.wasm")

#let sha1 = p.sha1
#let sha224 = p.sha224
#let sha256 = p.sha256
#let sha384 = p.sha384
#let sha512 = p.sha512
#let md5 = p.md5
#let md4 = p.md4
#let bytes-to-hex(bytes, upper: false) = {
  let res = array(bytes)
    .map(x => {
      let s = str(x, base: 16)
      return "0" * (2 - s.len()) + s
    })
    .join()

  if upper {
    return std.upper(res)
  } else {
    return res
  }
}
