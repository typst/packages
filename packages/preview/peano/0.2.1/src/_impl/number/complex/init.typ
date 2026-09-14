// -> number/complex/init.typ

#import "@preview/elembic:1.1.1" as e
#let math-utils-wasm = plugin("../../math-utils.wasm")

#let complex = e.types.declare(
  "complex",
  prefix: "peano.number",
  fields: (
    e.field(
      "re",
      float,
      doc: "Real part.",
    ),
    e.field(
      "im",
      float,
      doc: "Imaginary part.",
    ),
  ),
  doc: "Representation of a complex number.",
)


#let make-complex(re, im) = {
  complex(
    re: float(re),
    im: float(im),
  )
}

#let /*pub*/ from-bytes(src) = {
  let size = calc.div-euclid(src.len(), 2)
  let re = float.from-bytes(src.slice(0, size))
  let im = float.from-bytes(src.slice(size))
  make-complex(re, im)
}

#let complex-from-pair(arg1, arg2) = {
  let re
  let im
  if type(arg2) == angle {
    re = calc.cos(arg2) * arg1
    im = calc.sin(arg2) * arg1
  } else {
    (re, im) = (arg1, arg2)
  }
  make-complex(re, im)
}

#let /*pub*/ is_(obj) = {
  e.tid(obj) == e.tid(complex)
}

#let /*pub*/ from(..args) = {
  let args = args.pos()
  if args.len() == 1 {
    let (src,) = args
    if is_(src) {
      src
    } else if (
      type(src) == int or
      type(src) == float or
      type(src) == decimal
    ) {
      make-complex(float(src), 0.0)
    } else if type(src) == str {
      from-bytes(
        math-utils-wasm.parse_complex(bytes(src))
      )
    } else if type(src) == array {
      complex-from-pair(..src)
    } else {
      panic("Unsupported type.")
    }
  } else {
    complex-from-pair(..args)
  }
}

#let /*pub*/ to-bytes(z, size: 8) = {
  let z = from(z)
  let (re, im) = z
  re.to-bytes(size: size) + im.to-bytes(size: size)
}

#let encode-complex-seq(values) = {
  values.map(it => {
    let z = from(it)
    z.re.to-bytes() + z.im.to-bytes()
  }).join()
}

#let /*pub*/ to-point(z) = {
  let z = from(z)
  (z.re, z.im)
}
