#let call-wasm(function, args) = {
  let encoded = cbor.encode(args)
  cbor(function(encoded))
}
