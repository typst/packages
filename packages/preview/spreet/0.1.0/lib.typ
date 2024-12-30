#let spreet = plugin("spreet.wasm")

#let decode(data) = {
  cbor.decode(spreet.decode(data))
}

#let file-decode(path) = {
  decode(read(path, encoding: none))
}