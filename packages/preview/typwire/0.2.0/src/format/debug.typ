#import "../wire/lib.typ" as wire

/// Encode a value into the shared dictionary/array/primitive tree
/// `typwire.<format>.encode` would otherwise hand to a native format
/// encoder -- with no serialization step applied, so the result is a plain
/// Typst value, not `bytes`/`str`. Useful for inspecting or testing the
/// wire shape Typwire produces without a plugin round trip.
///
/// `bytes` is the one part of this tree that's still format-sensitive
/// (CBOR keeps it native; JSON tags it), so `format` picks which format's
/// tagging rules to preview -- it's otherwise unrelated to serialization,
/// which this namespace never does.
///
/// -> any
#let encode(
  /// The value to encode.
  ///
  /// -> any
  value,
  /// Which format's tagging rules to preview for `bytes`. One of `"cbor"`,
  /// `"json"`.
  ///
  /// -> str
  format: "cbor",
) = wire.encode(value, format: format)

/// The mirror of `encode`: reconstruct native Typst values from a tree that
/// was never serialized, such as one produced by `encode` above.
///
/// -> any
#let decode(
  /// A dictionary/array/primitive tree, as produced by `encode`.
  ///
  /// -> any
  data,
  /// The format `data`'s tree was produced for -- must match whatever
  /// `encode` (or a real `typwire.<format>.encode`) used to build it, so
  /// `bytes` tags are resolved the same way they were tagged.
  ///
  /// -> str
  format: "cbor",
) = wire.decode(data, format: format)
