
#import "bits.typ"

#let crc(data, generator: "110101") = {
  generator = bits.from-str(generator)
  let n = generator.len()
  let frame = bits.shift(bits.trim(data), n - 1)

  while frame.len() >= n {
    let s = frame.len() - n
    frame = bits.xor(frame, bits.shift(generator, s))
    frame = bits.trim(frame)
  }

  return bits.pad(frame, n - 1)
}

#let crc-test(data, generator: "110101") = {
  generator = bits.from-str(generator)
  let n = generator.len()
  let frame = bits.shift(bits.trim(data), n - 1)

  while frame.len() >= n {
    let s = frame.len() - n
    frame = bits.xor(frame, bits.shift(generator, s))
    frame = bits.trim(frame)
  }

  return bits.is-zero(frame)
}

#let bch = crc.with(generator:"10100110111")
