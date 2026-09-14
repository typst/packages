#let wasm = plugin("ctxjs.wasm")

// ! same as cbor_load.rs ! //

#let load-eval = 0
#let load-eval-format = 1
#let load-define-vars = 2
#let load-call-function = 3;
#let load-load-module-bytecode = 4;
#let load-load-module-js = 5;
#let load-call-module-function = 6;

// ! same as cbor/con.rs ! //
// https://www.iana.org/assignments/cbor-tags/cbor-tags.xhtml (private tags)

#let raw-bytes = 80000
#let eval = 80001
#let eval-format = 80002
#let json = 80003


// ! additional ! //


#let cbor-bytes-type = 0x40
#let cbor-array-type = 0x80
#let cbor-tag-type = 0xc0

#let create-cbor-type-with-len-bytes(t, l) = {
  if l <= 0x17 {
    return t.bit-or(l).to-bytes(size: 1, endian: "big")
  }
  if l <= 0xff {
    return t.bit-or(24).to-bytes(size: 1, endian: "big") + l.to-bytes(size: 1, endian: "big")
  }
  if l <= 0xffff {
    return t.bit-or(25).to-bytes(size: 1, endian: "big") + l.to-bytes(size: 2, endian: "big")
  }
  if l <= 0xffffffff {
    return t.bit-or(26).to-bytes(size: 1, endian: "big") + l.to-bytes(size: 4, endian: "big")
  }
  return t.bit-or(27).to-bytes(size: 1, endian: "big") + l.to-bytes(size: 8, endian: "big")
}

#let cbor-tagged-data(tag, cbordata) = {
  return (
    bytes("$ctxjs_cbor_")
      + cbor-tag-type.bit-or(27).to-bytes(size: 1, endian: "big")
      + tag.to-bytes(size: 8, endian: "big")
      + cbordata
  )
}

#let build-load-argument(t, value) = {
  create-cbor-type-with-len-bytes(cbor-bytes-type, value.len() + 1) + bytes((t,)) + value
}

#let build-load-data(load) = {
  let data = create-cbor-type-with-len-bytes(cbor-array-type, load.len())
  for value in load {
    data = data + value
  }
  data
}

#let transition-call(ctx, fn, transition, ..args) = {
  if transition {
    ctx = plugin.transition(fn, ..args.pos(), bytes((1,)))
    return (
      ctx,
      cbor(ctx.stored_value()),
    )
  } else {
    return (
      ctx,
      cbor(fn(..args.pos(), bytes((0,)))),
    )
  }
}
