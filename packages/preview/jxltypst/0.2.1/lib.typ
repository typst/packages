#let _plugin = plugin("jxltypst_opt.wasm")

// CREDIT: grayness https://typst.app/universe/package/grayness/
/// Internal function to accept bytes and paths on Typst 0.15 or later
/// -> bytes
#let _check_args(
  /// -> bytes | path
  imagedata,
) = {
  if type(imagedata) == path {
    if sys.version < version(0, 15, 0) {
      panic("Using path as argument requires Typst 0.15 or later, use bytes instead on earlier versions.")
    }
    read(imagedata, encoding: none)
  } else if type(imagedata) == bytes {
    imagedata
  } else { panic("imagedata must be raw bytes or given as path") }
}

/// Insert a JXL image in the document
///
///  _Example:_
/// ```example
/// #import "@preview/jxltypst:0.2.1": image-jxl
/// <<<#let arturo = read("Arturo_Nieto-Dorantes.webp", encoding: none)
/// #image-grayscale(arturo)
/// ```
/// -> content
#let image-jxl(
  imagedata,
  ///	extra arguments to pass to the Typst image function
  /// e.g. width, height, format, etc...
  ..args,
) = {
  let imagebytes = _check_args(imagedata)
  let decoded = cbor(_plugin.jxl(imagebytes))
  image(
    decoded.pixels,
    format: (
      width: decoded.width,
      height: decoded.height,
      encoding: decoded.encoding,
    ),
    ..args,
    ..(
      if decoded.at("icc", default: none) != none {
        (icc: decoded.icc)
      } else {
        ()
      }
    ),
  )
}
