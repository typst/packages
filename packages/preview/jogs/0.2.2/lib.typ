#let jogs-wasm = plugin("jogs.wasm")

/// Run a Javascript code snippet.
///
/// # Arguments
/// * `code` - The Javascript code string to run.
///
/// # Returns
/// The result of the Javascript code. The type is the typst type which most closely resembles the Javascript type.
///
/// # Example
/// ```typ
/// let result = eval-js("1 + 1")
/// ```
#let eval-js(code) = if type(code) == "string" {
  cbor.decode(jogs-wasm.eval(bytes(code)))
} else {
  cbor.decode(jogs-wasm.eval(bytes(code.text)))
}

#let compile-js(code) = if type(code) == "string" {
  jogs-wasm.compile(bytes(code))
} else {
  jogs-wasm.compile(bytes(code.text))
}

#let list-global-property(bytecode) = cbor.decode(jogs-wasm.list_property_keys(bytecode))

#let call-js-function(bytecode, function-name, ..args) = cbor.decode(
  jogs-wasm.call_function(
    bytecode,
    bytes(function-name),
    cbor.encode(args.pos()),
  )
)
