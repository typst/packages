
#import "util.typ"

#let gtin(code) = {
  assert.eq(type(code), "array")
  assert(
    code.len() in (4, 7, 11, 12, 13),
    message: "GTIN codes may be 4,7,11,12 or 13 digits long (excluding checksum). Got " + str(code.len()),
  )

  let cs = util.weighted-sum(code.rev(), (3, 1))
  let rem = calc.rem(cs, 10)
  if rem == 0 {
    return 0
  } else {
    return 10 - calc.rem(cs, 10)
  }
}

#let gtin-test(code, checksum: auto, version: auto) = {
  assert.eq(type(code), "array")
  if type(version) == "integer" {
    assert.eq(code.len(), version)
  } else {
    assert(code.len() in (5, 8, 12, 13, 14))
  }

  if checksum == auto {
    checksum = int(code.at(-1))
    code = code.slice(0, -1)
  }

  return checksum == gtin(code)
}

#let ean5(code) = {
  assert.eq(type(code), "array")
  assert.eq(code.len(), 5)

  let cs = util.weighted-sum(code, (3, 9))
  return calc.rem(cs, 10)
}

#let ean5-test(code, checksum: auto) = {
  assert.eq(type(code), "array")
  assert.eq(code.len(), if checksum == auto { 6 } else { 5 })

  if checksum == auto {
    checksum = int(code.at(-1))
    code = code.slice(0, -1)
  }

  return checksum == ean5(code)
}

#let ean8(code) = {
  assert.eq(type(code), "array")
  assert.eq(code.len(), 7)

  return gtin(code)
}

#let ean8-test(code, checksum: auto) = {
  assert.eq(type(code), "array")
  assert.eq(code.len(), if checksum == auto { 8 } else { 7 })

  return gtin-test(code, checksum: checksum)
}

#let ean13(code) = {
  assert.eq(type(code), "array")
  assert.eq(code.len(), 12)

  return gtin(code)
}

#let ean13-test(code, checksum: auto) = {
  assert.eq(type(code), "array")
  assert.eq(code.len(), if checksum == auto { 13 } else { 12 })

  return gtin-test(code, checksum: checksum)
}

#let isbn10(code) = {
  assert.eq(type(code), "array")
  assert.eq(code.len(), 9)

  let cs = util.weighted-sum(code.rev(), (i) => i + 2)
  cs = 11 - calc.rem(cs, 11)
  if cs < 10 {
    return cs
  } else {
    return "X"
  }
}

#let isbn10-test(code, checksum: auto) = {
  assert.eq(type(code), "array")
  assert.eq(code.len(), if checksum == auto { 10 } else { 9 })

  if checksum == auto {
    checksum = int(code.at(-1))
    code = code.slice(0, -1)
  }
  if checksum == "X" {
    checksum = 10
  }

  return checksum == isbn10(code)
}

#let isbn13 = ean13

#let isbn13-test = ean13-test

#let upc-a = gtin

#let upc-a-test = gtin-test
