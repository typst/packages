#let core = plugin("core.wasm")

/// Converts a boolean value to bytes.
///
/// -> bytes
#let bool-to-bytes(
  /// The boolean to convert.
  /// -> bool
  b,
) = {
  if b {
    bytes((1,))
  } else {
    bytes((0,))
  }
}

/// Gets the data from a source.
///
/// Returns a tuple of (bytes | none, string | none).
///
/// -> array
#let get-data(
  /// The source to get data from.
  /// -> bytes | path
  source,
) = {
  if type(source) == bytes {
    (source, none)
  } else if type(source) == path {
    (read(source, encoding: none), none)
  } else {
    (none, "Invalid source type. Expected bytes or path.")
  }
}

/// Decodes data using bzip2 compression.
///
/// Example:
/// ```example
/// #let data = bzip2(path("file.bz2"))
/// ```
///
/// -> bytes
#let bzip2(
  /// The source to decode.
  /// -> bytes | path
  source,
) = {
  let (data, error) = get-data(source)

  if error != none {
    error("bzip2: " + error)
  }

  core.bzip2(data)
}

/// Decodes data using gzip compression.
///
/// Example:
/// ```example
/// #let data = gzip(path("file.gz"))
/// ```
///
/// -> bytes
#let gzip(
  /// The source to decode.
  /// -> bytes | path
  source,
) = {
  let (data, error) = get-data(source)

  if error != none {
    error("gzip: " + error)
  }

  core.gzip(data)
}

/// Extracts entries from a tar archive.
///
/// Returned entries have the following shape:
///
/// ```typ
/// (
///  "type": "file" | "directory" | "link",
///  "path": string,
///  "data": bytes | none, // Only for type "file".
///  "target": string | none, // Only for type "link".
/// )
/// ```
///
/// Example:
///
/// ```example
/// #let entries = tar(path("archive.tar"))
/// #for entry in entries [
///   #entry.path
/// ]
/// ```
///
/// -> array
#let tar(
  /// The source to extract from.
  /// -> bytes | path
  source,
  /// Whether to filter out resource forks.
  /// -> bool
  filter-resource-forks: true,
) = {
  let (data, error) = get-data(source)

  if error != none {
    error("tar: " + error)
  }

  cbor(core.tar(data, bool-to-bytes(filter-resource-forks))).entries
}

/// Decodes data using xz compression.
///
/// Example:
/// ```example
/// #let data = xz(path("file.xz"))
/// ```
///
/// -> bytes
#let xz(
  /// The source to decode.
  /// -> bytes | path
  source,
) = {
  let (data, error) = get-data(source)

  if error != none {
    error("xz: " + error)
  }

  core.xz(data)
}

/// Extracts entries from a zip archive.
///
/// Returned entries have the following shape:
///
/// ```typ
/// (
///  "type": "file" | "directory" | "link",
///  "path": string,
///  "data": bytes | none, // Only for type "file".
///  "target": string | none, // Only for type "link".
/// )
/// ```
///
/// Example:
///
/// ```example
/// #let entries = zip(path("archive.zip"))
/// #for entry in entries [
///   #entry.path
/// ]
/// ```
///
/// -> array
#let zip(
  /// The source to extract from.
  /// -> bytes | path
  source,
  /// Whether to filter out resource forks.
  /// -> bool
  filter-resource-forks: true,
) = {
  let (data, error) = get-data(source)

  if error != none {
    error("zip: " + error)
  }

  cbor(core.zip(data, bool-to-bytes(filter-resource-forks))).entries
}

/// Decodes data using zstd compression.
///
/// Example:
/// ```example
/// #let data = zstd(path("file.zst"))
/// ```
///
/// -> bytes
#let zstd(
  /// The source to decode.
  /// -> bytes | path
  source,
) = {
  let (data, error) = get-data(source)

  if error != none {
    error("zstd: " + error)
  }

  core.zstd(data)
}
