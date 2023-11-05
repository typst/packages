#let jogs-wasm = plugin("jogs.wasm")

/// Run a Javascript code snippet.
/// 
/// # Arguments
/// * `code` - The Javascript code string to run.
/// 
/// # Returns
/// The result of the Javascript code in string
/// 
/// # Example
/// ```typ
/// let result = eval-js("1 + 1")
/// ```
#let eval-js(code) = if type(code) == "string" {
  str(jogs-wasm.eval(bytes(code)))
} else {
  str(jogs-wasm.eval(bytes(code.text)))
}
