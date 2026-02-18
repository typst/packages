// Kip: Pikchr diagram integration for Typst
// Load the WASM plugin
#let pikchr-plugin = plugin("pikchr.wasm")

/// Render a Pikchr diagram using Kip
///
/// Takes Pikchr markup text and renders it as an SVG image.
///
/// Arguments:
/// - code: The Pikchr markup code as a string or raw block
/// - width: Optional width for the image (auto by default)
/// - height: Optional height for the image (auto by default)
/// - fit: How to fit the image ("contain", "cover", "stretch")
///
/// Example:
/// ```typst
/// #kip(```
///   arrow right 200% "Markdown" "Source"
///   box rad 10px "Markdown" "Formatter" "(markdown.c)" fit
///   arrow right 200% "HTML+SVG" "Output"
///   arrow <-> down 70% from last box.s
///   box same "Pikchr" "Formatter" "(pikchr.c)" fit
/// ```)
/// ```
///
/// Returns: An image element containing the rendered diagram
#let kip(
  code,
  width: auto,
  height: auto,
  fit: "contain",
) = {
  // Convert the code to string then bytes
  // Handle both string and content (raw blocks) inputs
  let code-str = if type(code) == str {
    code
  } else if "text" in code.fields() {
    // For raw blocks - access the text field
    code.text
  } else {
    // Fallback: convert to string
    str(code)
  }
  let input = bytes(code-str)

  // Call the WASM plugin to render the diagram
  // The plugin returns SVG as bytes
  let svg-bytes = pikchr-plugin.typst_pikchr(input)

  // Create image from SVG bytes and apply sizing and fit parameters
  if width != auto or height != auto {
    box(
      width: width,
      height: height,
      image(svg-bytes, format: "svg", fit: fit)
    )
  } else {
    image(svg-bytes, format: "svg")
  }
}

// Aliases for convenience and backwards compatibility
#let render = kip
#let pikchr = kip

/// Render a Pikchr diagram in dark mode
///
/// Same as kip() but optimized for dark backgrounds
#let render-dark(
  code,
  width: auto,
  height: auto,
  fit: "contain",
) = {
  // Note: Dark mode would require passing a flag to the WASM plugin
  // For now, this is a placeholder that calls the regular kip
  // To implement: modify pikchr_wasm.c to accept flags
  kip(code, width: width, height: height, fit: fit)
}
