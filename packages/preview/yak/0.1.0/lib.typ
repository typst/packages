#import "internal.typ" as _internal

#let yak(data, filter) = cbor(_internal.wasm.jq(cbor.encode(data), bytes(filter)))
