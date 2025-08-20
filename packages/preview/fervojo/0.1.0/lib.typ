#let rr-wasm = plugin("./typst_railroad.wasm")

#let _as_bytes(input) = {
    let t = type(input)
    if t == "bytes" {
        return input
    }
    if t == "string"{
        return bytes(input)
    }
    if input.has("text") {
        return _as_bytes(input.text)
    }
    assert(true, message:  "The input is not string, bytes, or a content with text")
}



#let render(
    railroad,
    css: rr-wasm.default_css(),
    ..args
) = {
    image.decode(rr-wasm.railroad(_as_bytes(railroad), _as_bytes(css)), format: "svg")
}


#let default-css() = {
    rr-wasm.default_css()
}
