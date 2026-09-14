#import "@preview/elembic:1.1.1" as e
#let math-utils-wasm = plugin("math-utils.wasm")

#import "number/complex/init.typ": (
  complex,
  from as c_from,
  to-bytes as c_to-bytes,
  from-bytes as c_from-bytes,
)
#import "number/rational/init.typ": (
  rational,
  from as q_from,
  to-bytes as q_to-bytes,
  from-bytes as q_from-bytes,
)

#let casting = (
  complex: c_from,
  rational: q_from,
)
#let encoders = (
  int: int.to-bytes,
  float: float.to-bytes,
  complex: c_to-bytes,
  rational: q_to-bytes
)
#let decoders = (
  int: int.from-bytes,
  float: float.from-bytes,
  complex: c_from-bytes,
  rational: q_from-bytes,
)
#let wasm-funcs = dictionary(math-utils-wasm)

#let type-name(type) = {
  if std.type(type) == std.type {
    repr(type)
  } else if e.tid(type) != none {
    e.data(type).id.name
  } else {
    panic(repr(type) + "is not a valid type.")
  }
}

#let cast(obj, type) = {
  if std.type(type) == std.type {
    type(obj)
  } else if e.tid(type) != none {
    casting.at(e.data(type).id.name)(obj)
  } else {
    panic(repr(type) + "is not a valid type.")
  }
}

#let convert-wasm-func(func-name, arg-types, ret-type) = {
  let wasm-func = wasm-funcs.at(func-name)
  (..args) => {
    let args = args.pos()
    let encoded-args = arg-types.zip(args).map(((type, arg)) => {
      let encoder = encoders.at(type-name(type))
      encoder(cast(arg, type))
    })
    let encoded-result = wasm-func(..encoded-args)
    let decoder = decoders.at(type-name(ret-type))
    decoder(encoded-result)
  }
}

#let complex-funcs = {
  let exceptions = ("complex_pow_complex": true, "parse_complex": true, "beta_complex": true)
  let funcs = wasm-funcs.keys()
    .filter(key => key.ends-with("_complex") and key not in exceptions)
    .map(key => (key.slice(0, -"_complex".len()), convert-wasm-func(key, (complex, ), complex)))
    .to-dict()
  funcs
} + (
  beta: convert-wasm-func("beta_complex", (complex, complex), complex)
)

#let real-funcs = {
  let func-names = (
    "asinh", "acosh", "atanh",
    "airy_ai", "airy_bi", "gamma", "digamma", "erf", "zeta", "lambert_w"
  )
  func-names.map(
    key => (key, convert-wasm-func(key, (float,), float))
  ).to-dict()
} + {
  let func-names = (
    "bessel_jn", "bessel_yn"
  )
  func-names.map(
    key => (key, convert-wasm-func(key, (int, float), float))
  ).to-dict()
} + {
  let func-names = ("beta",)
  func-names.map(
    key => (key, convert-wasm-func(key, (float, float), float))
  ).to-dict()
}