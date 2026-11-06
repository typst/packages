// -> number/complex.typ
/// Representation and arithmetics for #link("https://en.wikipedia.org/wiki/Complex_number")[complex numbers] $CC$

#import "init.typ": *
#let math-utils-wasm = plugin("../math-utils.wasm")
#let number-type = "complex"

#let float-regex-src = `(?:[0-9]+\.[0-9]+|\.?[0-9]+)(?:e[0-9]+)?|inf|nan`.text
#let complex-regex = regex(`([\+\-]?`.text + float-regex-src + `)\s*([\+\-]\s*`.text + float-regex-src + ")i")

#let make-complex(re, im) = {
  (
    (number-label): number-type,
    re: float(re),
    im: float(im),
  )
}

#let decode-complex(src) = {
  let re = float.from-bytes(src.slice(0, 8))
  let im = float.from-bytes(src.slice(8))
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

#let /*pub as is_*/ is-complex(obj) = is-number-type(obj, "complex")

#let /*pub as from*/ complex(..args) = {
  let args = args.pos()
  if args.len() == 1 {
    let (src,) = args
    if is-complex(src) {
      src
    } else if (
      type(src) == int or
      type(src) == float or
      type(src) == decimal
    ) {
      make-complex(float(src), 0.0)
    } else if type(src) == str {
      decode-complex(
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

#let encode-complex-seq(values) = {
  values.map(it => {
    let z = complex(it)
    z.re.to-bytes() + z.im.to-bytes()
  }).join()
}

// The imaginary unit $upright(i) = 0 + 1 upright(i)$
#let /*pub*/ i = make-complex(0, 1)

// The negation of imaginary unit $-upright(i) = 0 - 1 upright(i)$.
#let /*pub*/ neg-i = make-complex(0, -1)

// The complex zero value $0 = 0 + 0 upright(i)$
#let /*pub*/ zero = make-complex(0, 0)

// The complex one value $1 = 1 + 0 upright(i)$
#let /*pub*/ one = make-complex(1, 0)

// The complex negative one value $-1 = -1 + 0 upright(i)$
#let /*pub*/ neg-one = make-complex(-1, 0)

// the 3#super[rd] unit root $omega = - 1/2 + sqrt(3)/2 upright(i)$
#let /*pub*/ omega = make-complex(-0.5, 0.5 * calc.sqrt(3))

// square (or conjugate) of the 3#super[rd] unit root $macron(omega) = - 1/2 - sqrt(3)/2 upright(i)$
#let /*pub*/ omega-2 = make-complex(-0.5, -0.5 * calc.sqrt(3))

#let /*pub*/ nan = make-complex(float.nan, float.nan)

#let /*pub*/ abs(z) = {
  let (re, im) = complex(z)
  calc.norm(re, im)
}

#let /*pub*/ arg(z) = {
  let (re, im) = complex(z)
  calc.atan2(re, im)
}

#let /*pub*/ conj(z) = {
  let (re, im) = complex(z)
  make-complex(re, -im)
}

#let /*pub*/ neg(z) = {
  let (re, im) = complex(z)
  make-complex(-re, -im)
}

#let /*pub*/ re(z) = {
  complex(z).re
}

#let /*pub*/ im(z) = {
  complex(z).im
}

#let /*pub*/ add(..args) = {
  if args.pos().len() == 0 {
    zero
  } else {
    decode-complex(
      math-utils-wasm.complex_add(encode-complex-seq(args.pos())),
    )
  }
}

#let /*pub*/ mul(..args) = {
  if args.pos().len() == 0 {
    one
  } else {
    decode-complex(
      math-utils-wasm.complex_mul(encode-complex-seq(args.pos())),
    )
  }
}

#let /*pub*/ sub(z1, z2) = {
  let z1 = complex(z1)
  let z2 = complex(z2)
  make-complex(z1.re - z2.re, z1.im - z2.im)
}

#let /*pub*/ div(z1, z2) = {
  let z1 = complex(z1)
  let z2 = complex(z2)
  decode-complex(
    math-utils-wasm.complex_div(
      z1.re.to-bytes(),
      z1.im.to-bytes(),
      z2.re.to-bytes(),
      z2.im.to-bytes(),
    ),
  )
}

#let /*pub*/ pow(z1, z2) = {
  let z1 = complex(z1)
  if type(z2) == int or type(z2) == decimal {
    z2 = float(z2)
  }
  if type(z2) == float {
    decode-complex(
      math-utils-wasm.complex_pow_real(
        z1.re.to-bytes(),
        z1.im.to-bytes(),
        z2.to-bytes(),
      ),
    )
  } else {
    let z2 = complex(z2)
    decode-complex(
      math-utils-wasm.complex_pow_complex(
        z1.re.to-bytes(),
        z1.im.to-bytes(),
        z2.re.to-bytes(),
        z2.im.to-bytes(),
      ),
    )
  }
}

#let /*pub*/ eq(z1, z2) = {
  let z1 = complex(z1)
  let z2 = complex(z2)
  z1 == z2
}
