// Default list of supported formats, in order of precedence: we will use
// the first format in this list that is available in the object dict.
#let default-formats = (
  "text/vnd.typst",
  "image/svg+xml",
  "image/png",
  "image/jpeg",
  "image/gif",
  "text/markdown",
  "text/latex",
  "text/html",
  "text/plain",
  "application/json",
)

// Return a normalized list of desired formats:
// - a single value is wrapped in an array
// - if the array contains the value 'auto', the default list is spliced at
//   that position
#let normalize-formats(formats) = {
  if type(formats) != array {
    formats = (formats,)
  }
  let i = formats.position(x => x == auto)
  if i != none {
    // Replace auto value with list of default formats
    formats = formats.slice(0, i) + default-formats + formats.slice(i + 1)
  }
  return formats
}

