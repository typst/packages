#import "@preview/elembic:1.1.1" as e
#import "../int/init.typ": mp-int, mp-int-buffer
#import "../int/arith.typ": neg as mpz_neg
#let math-utils-wasm = plugin("../../../math-utils.wasm")
#let zero-byte = bytes((0,))

#let mp-rational = e.types.declare(
  "mp-rational",
  prefix: "peano.number.mp",
  fields: (
    e.field(
      "buffer",
      bytes,
    ),
  ),
)

#let /*pub*/ is_(obj) = {
  e.tid(obj) == e.tid(mp-rational)
}

#let verify-bytes(buffer) = {
  math-utils-wasm.verify_mpq(buffer) != zero-byte
}

#let /*pub*/ from-bytes(buffer) = {
  assert(verify-bytes(buffer))
  mp-rational(buffer: buffer)
}

#let to-bytes-direct(n) = {
  e.fields(n).buffer
}

#let mp-rational-buffer(..args) = {
  let args = args.pos()
  if args.len() == 1 {
    let src = args.at(0)
    if type(src) == bytes and verify-bytes(src) {
      src
    } else if type(src) == str or type(src) == decimal {
      math-utils-wasm.parse_mpq(bytes(str(src)))
    } else if type(src) == int {
      math-utils-wasm.mpq_from_int(src.to-bytes())
    } else if type(src) == float {
      math-utils-wasm.mpq_from_float(src.to-bytes())
    } else if e.tid(src) == e.tid(mp-int) {
      math-utils-wasm.mpq_from_mpz(mp-int.buffer)
    } else if e.tid(src) == e.tid(rational) {
      let (sign, num, den) = src
      num = mp-int-buffer(num)
      den = mp-int-buffer(den)
      if not sign {
        num = mpz_neg(num)
      }
      math-utils-wasm.mpq_from_mpz_pair(num, den)
    } else {
      panic("unknown input type")
    }
  } else if args.len() == 2 {
    let (num, den) = args
    num = mp-int-buffer(num)
    den = mp-int-buffer(den)
    math-utils-wasm.mpq_from_mpz_pair(num, den)
  } else {
    panic("invalid number of arguments")
  }
}

#let /*pub*/ from(arg0, ..args) = {
  if is_(arg0) {
    arg0
  } else {
    mp-rational(buffer: mp-rational-buffer(arg0, ..args))
  }
}

#let /*pub*/ to-bytes(n) = {
  if is_(n) {
    n.buffer
  } else {
    mp-rational-buffer(n)
  }
}

#let /*pub*/ num(x, signed: false) = {
  mp-int(
    buffer: (
      if signed { math-utils-wasm.mpq_num_signed }
      else { math-utils-wasm.mpq_num }
    )(to-bytes(x))
  )
}

#let /*pub*/ den(x, signed: false) = {
  mp-int(
    buffer: (
      if signed { math-utils-wasm.mpq_den_signed }
      else { math-utils-wasm.mpq_den }
    )(to-bytes(x))
  )
}


