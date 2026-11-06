#let _plugin = plugin("jxl_loader_opt.wasm")

/// Internal function to accept bytes and paths on Typst 0.15 or later
///
/// - imagedata (path, bytes): JXL image `path` or data as `bytes`
/// -> bytes
#let _check_args(
  // CREDIT: grayness https://typst.app/universe/package/grayness/
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

/// Internal constant map from crate Encoding enum to Typst encoding strings
#let _ENCODINGS = ("rgb8", "rgba8", "luma8", "lumaa8")

/// Insert a JXL image in the document
///
/// The image can be provided as raw `bytes` or as a `path`.
/// Additional arguments are passed to Typst's `image` function.
///
/// _Example:_
/// ```example
/// #import "@preview/jxl-loader:0.4.0": image-jxl
/// #image-jxl(path("path/to/img.jxl"), width: 50%)
/// #image-jxl(read("path/to/img.jxl", encoding: none))
/// ```
///
/// - imagedata (bytes, path): The JPEG XL image `path` or data.
#let image-jxl(imagedata, ..args) = {
  let data = _plugin.jxl(_check_args(imagedata))

  // Serialization format:
  // 0..4    width       u32 LE
  // 4..8    height      u32 LE
  // 8       encoding    u8
  // 9..13   icc_len     u32 LE
  // 13..    icc + pixels
  let width = int.from-bytes(data.slice(0, count: 4), signed: false)
  let height = int.from-bytes(data.slice(4, count: 4), signed: false)
  let encoding = _ENCODINGS.at(data.at(8))
  let icc-len = int.from-bytes(data.slice(9, count: 4), signed: false)
  let pixels_start = 13 + icc-len
  let icc = data.slice(13, pixels_start)
  let pixels = data.slice(pixels_start)

  image(
    pixels,
    ..args,
    format: (
      width: width,
      height: height,
      encoding: encoding,
    ),
    ..(if icc-len > 0 { (icc: icc) } else { () }),
  )
}
