#import "types/foundations/arguments.typ"
#import "utils.typ": all-in

// `auto` is a Typst keyword/literal, not an ordinary identifier -- a bare
// `auto` always evaluates to that literal, so the module must be imported
// under a different name to be reachable at all.
#import "types/foundations/auto.typ" as auto-value
// Imported under a distinct name for the same reason `path.typ`/`type.typ`
// already need one at their own call sites (`std.path`/`std.type`): the
// bare name `bytes` also names the Typst builtin's own type/constructor,
// and this file needs both (`std.type(content) == std.bytes` alongside
// `bytes-type.encode(...)`).
#import "types/foundations/bytes.typ" as bytes-type
#import "types/foundations/datetime.typ"
#import "types/foundations/decimal.typ"
#import "types/foundations/duration.typ"
#import "types/foundations/label.typ"
#import "types/foundations/path.typ"
#import "types/foundations/regex.typ"
#import "types/foundations/symbol.typ"
#import "types/foundations/type.typ"
#import "types/foundations/version.typ"
#import "types/layout/alignment.typ"
#import "types/layout/angle.typ"
#import "types/layout/length.typ"
#import "types/layout/ratio.typ"
#import "types/visualize/color/color.typ"
#import "types/visualize/gradient/gradient.typ"
#import "types/visualize/stroke.typ"

/// Types that are representable as themselves on the wire, with no
/// `typwire-type` tagging, in every format.
#let leaf-types = (std.int, std.float, std.str, std.bool, std.type(none))

/// `leaf-types`, plus `bytes` -- CBOR has a native byte string, so a `bytes`
/// value is a leaf there. Every other format routes it through
/// `bytes-type.encode` instead, which decides its shape per format the same
/// way every other tagged type's own `encode` does.
#let cbor-leaf-types = leaf-types + (std.bytes,)

/// Recursively turn a Typst value into a plain dictionary/array/primitive
/// tree: native types become `typwire-type`-tagged dictionaries, everything
/// else passes through unchanged. This is the shared layer every
/// `typwire.<format>.encode` wraps with a native format encoder
/// (`cbor.encode`, `json.encode`) -- `format` is threaded through so the
/// one format-sensitive case (`bytes`) can be resolved in this single
/// pass, rather than a separate tree-rewrite pass afterward.
///
/// Written to make as few closure calls as possible: Typst memoizes every
/// closure call, which hashes all of its arguments first, so each call
/// costs time proportional to the size of the subtree it's handed --
/// measured at ~0.8ms for a single call with a 100,000-element array
/// argument. Hence leaves are never passed to a recursive call, containers
/// made only of leaves are returned as-is (checked with native
/// `map(std.type).dedup()`, no closure per element), iteration uses `for`
/// rather than `.map(closure)`, and native types whose own `encode` already
/// returns a finished tree aren't walked a second time.
///
/// -> any
#let encode(
  /// The content to encode.
  ///
  /// -> any
  content,
  /// The wire format being encoded for -- one of `"cbor"`, `"json"`.
  ///
  /// -> str
  format: "cbor",
) = {
  let leaves = if format == "cbor" { cbor-leaf-types } else { leaf-types }
  let content-type = std.type(content)

  if content-type in leaves {
    content
  } else if content-type == std.array {
    if all-in(content.map(std.type).dedup(), leaves) {
      content
    } else {
      let result = ()
      for item in content {
        result.push(if std.type(item) in leaves { item } else {
          encode(item, format: format)
        })
      }
      result
    }
  } else if content-type == std.dictionary {
    let result = content
    if not all-in(content.values().map(std.type).dedup(), leaves) {
      for (key, value) in content {
        if std.type(value) not in leaves {
          result.insert(key, encode(value, format: format))
        }
      }
    }
    result
  } else if content-type == std.bytes {
    // Only reached for formats where `bytes` isn't a leaf. Not wrapped in a
    // recursive `encode(...)` call like the branches below that need one --
    // `bytes-type.encode` returns `bytes` unchanged for any format that
    // treats it as a leaf, so recursing into that result could loop forever.
    bytes-type.encode(content, format: format)
  } else if content == auto {
    // `auto` has no dedicated `std.type`; unlike `none` it isn't part of
    // Typst's own reliable CBOR subset, so it needs a tagged dict like the
    // other native types below, distinguishing it on the wire from `none`.
    auto-value.encode(format: format)
  } else if content-type == std.length {
    length.encode(content, format: format)
  } else if content-type == std.ratio {
    ratio.encode(content, format: format)
  } else if content-type == std.angle {
    angle.encode(content, format: format)
  } else if content-type == std.color {
    color.encode(content, format: format)
  } else if content-type == std.gradient {
    gradient.encode(content, format: format)
  } else if content-type == std.stroke {
    // Every other native type's own `encode` returns a finished tree, made
    // only of leaves and plain containers. These two instead embed
    // arbitrary values (a stroke's paint/thickness/dash, an `arguments`'
    // own arguments) that still need encoding, so their result is walked
    // once more.
    encode(stroke.encode(content, format: format), format: format)
  } else if content-type == std.arguments {
    encode(arguments.encode(content, format: format), format: format)
  } else if content-type == std.alignment {
    alignment.encode(content, format: format)
  } else if content-type == std.datetime {
    datetime.encode(content, format: format)
  } else if content-type == std.decimal {
    decimal.encode(content, format: format)
  } else if content-type == std.duration {
    duration.encode(content, format: format)
  } else if content-type == std.label {
    label.encode(content, format: format)
  } else if content-type == std.version {
    version.encode(content, format: format)
  } else if content-type == std.type {
    type.encode(content, format: format)
  } else if content-type == std.path {
    path.encode(content, format: format)
  } else if content-type == std.symbol {
    symbol.encode(content, format: format)
  } else if content-type == std.regex {
    regex.encode(content, format: format)
  } else if content-type == std.content {
    panic("typwire.encode: content values are not supported")
  } else {
    panic("typwire.encode: unsupported value type " + str(content-type))
  }
}
