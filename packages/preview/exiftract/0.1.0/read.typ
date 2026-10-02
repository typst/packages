// Reading the Exif block. The parsing happens in `exif.wasm`, a WebAssembly
// plugin whose Rust source is in the repository, which hands the fields back
// as JSON.
//
// Only `read-exif` is re-exported by `lib.typ`; everything here and in
// `interpret.typ` is internal to the package.

#import "interpret.typ": interpret

#let _plugin = plugin("exif.wasm")

/// Reads the Exif metadata of an image.
///
/// Returns the fields in the order the file stores them, one dictionary each:
///
/// ```typc
/// (
///   tag: "ExposureTime",  // tag name, or e.g. "exif-0x9999" if unknown
///   ifd: "exif",          // primary, thumbnail, exif, gps or interop
///   number: 33434,        // numeric tag id
///   type: "rational",     // Exif type of the value
///   count: 1,             // number of elements, before truncation
///   value: 0.005,         // the value, as a Typst type
///   unit: "s",            // its unit, or none
/// )
/// ```
///
/// An image that carries no Exif metadata is not an error: it yields `()`.
///
/// - data (bytes): The raw image file, for instance
///   `read("photo.jpg", encoding: none)`. JPEG, TIFF, PNG, WebP and
///   HEIF/HEIC/AVIF containers are understood.
/// - return-raw (bool): Hand back what the file holds instead of interpreting
///   it: rationals stay `(numerator, denominator)` pairs, dates stay strings,
///   `UNDEFINED` stays a list of byte values, and no `unit` is added.
/// - fallback (any): What to return instead of failing when the file cannot be
///   read as an image at all — it is in no container the reader knows, or its
///   Exif block is damaged past salvaging. Left at `auto`, that case panics.
///   Returned as given, never interpreted. An image that merely has no Exif
///   metadata yields `()` and never reaches this.
/// - max-values (int): How many elements of a multi-valued field to keep.
///   Guards against fields such as `MakerNote`, which can be tens of
///   kilobytes. The untruncated length stays available as `count`.
/// - keep-partial (bool): Keep the fields that could be parsed from a damaged
///   Exif block. At `false`, any damage is an error.
///
/// -> array
#let read-exif(
  data,
  return-raw: false,
  fallback: auto,
  max-values: 64,
  keep-partial: true,
) = {
  if type(data) != bytes {
    panic(
      "read-exif expects the image data as bytes, found "
        + str(type(data))
        + "; load the file with `read(\"photo.jpg\", encoding: none)`",
    )
  }
  if type(max-values) != int or max-values < 0 {
    panic("max-values must be a non-negative integer")
  }
  if type(keep-partial) != bool {
    panic("keep-partial must be a boolean")
  }
  if type(return-raw) != bool {
    panic("return-raw must be a boolean")
  }

  let options = bytes(json.encode((
    max_values: max-values,
    keep_partial: keep-partial,
  )))

  let result = json(_plugin.read_exif(data, options))

  if not result.ok {
    if fallback == auto {
      panic("could not read Exif metadata: " + result.error)
    }
    return fallback
  }

  if return-raw { result.fields } else { interpret(result.fields) }
}
