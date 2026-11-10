#let _plugin = plugin("jxl_loader_opt.wasm")

/// Internal function to accept bytes and paths on Typst 0.15 or later
///
/// - imagedata (path, bytes): JXL image `path` or data as `bytes`
/// -> bytes
// CREDIT: grayness https://typst.app/universe/package/grayness
#let _check_args(
  imagedata,
) = {
  if type(imagedata) == path {
    if sys.version < version(0, 15, 0) {
      panic("Using path as argument requires Typst 0.15 or later, pass the image as bytes instead on earlier versions.")
    }
    read(imagedata, encoding: none)
  } else if type(imagedata) == bytes {
    imagedata
  } else { panic("imagedata must be raw bytes or given as path") }
}

/// Internal constant map from samples_per_pixel value to Typst encoding strings
#let _SAMPLES_PER_PIXEL_TO_ENCODING = (none, "luma8", "lumaa8", "rgb8", "rgba8")

/// Insert a JXL image in the document
///
/// The image can be provided as raw `bytes` or as a `path`.
/// Additional arguments are passed to Typst's `image` function.
///
/// _Example:_
/// ```example
/// #import "@preview/jxl-loader:0.5.0": image-jxl
/// #image-jxl(path("path/to/img.jxl"), width: 50%) // as `path()`
/// #image-jxl(read("path/to/img.jxl", encoding: none)) // or as `bytes()`
/// ```
///
/// - imagedata (bytes, path): The JPEG XL image `path` or data as `bytes`.
/// - ..args: Arguments accepted by Typst `image` function (https://typst.app/docs/reference/visualize/image)
#let image-jxl(imagedata, ..args) = {
  let data = _plugin.jxl(_check_args(imagedata))

  // Serialization format:
  // 0..4    width             u32 LE
  // 4..8    height            u32 LE
  // 8       samples_per_pixel u8
  // 9..13   icc_len           u32 LE
  // 13..    icc + pixels      [u8]
  let width = int.from-bytes(data.slice(0, count: 4), signed: false)
  let height = int.from-bytes(data.slice(4, count: 4), signed: false)
  let encoding = _SAMPLES_PER_PIXEL_TO_ENCODING.at(data.at(8))
  let icc-len = int.from-bytes(data.slice(9, count: 4), signed: false)
  let icc = data.slice(13, count: icc-len)
  let pixels = data.slice(13 + icc-len)

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
