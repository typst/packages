// -> number/quaternion/init.typ

#import "@preview/elembic:1.1.1" as e
#let math-utils-wasm = plugin("../../math-utils.wasm")

#let quaternion = e.types.declare(
  "quaternion",
  prefix: "peano.number",
  fields: (
    e.field(
      "re",
      float,
    ),
    e.field(
      "i",
      float,
    ),
    e.field(
      "j",
      float,
    ),
    e.field(
      "k",
      float,
    ),
  ),
)

#let make-quaternion(re, i, j, k) = {
  quaternion(
    re: float(re),
    i: float(i),
    j: float(j),
    k: float(k),
  )
}

#let /*pub*/ from(..args) = {
  let args = args.pos()
  if len(args) == 1 {
    let src = args.at(0)
    if type(src) == str {
      // [TODO] implement parsing
      panic("[TODO] parsing is not yet implemented")
    } else {
      make-quaternion(src, 0, 0, 0)
    }
  } else if len(args) == 2 {
    let (re, vec) = args
    if type(vec) == array {
      let (i, j, k) = vec
      make-quaternion(re, i, j, k)
    } else {
      make-quaternion(re, vec, 0, 0)
    }
  } else if len(args) == 4 {
    make-quaternion(..args)
  } else {
    panic("too many or too few arguments")
  }
}

#let is_(obj) = {
  e.tid(obj) == e.tid(quaternion)
}

#let to-bytes-direct(x) = {
  let (re, i, j, k) = e.fields(x)
  cbor.encode((re, (i, j, k)))
}

#let /*pub*/ to-bytes(x) = {
  to-bytes-direct(from(x))
}

#let /*pub*/ from-bytes(buffer) = {
  let (re, (i, j, k)) = cbor(buffer)
  make-quaternion(re, i, j, k)
}
