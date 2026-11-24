#import "types/foundations/arguments.typ"

// `auto` is a Typst keyword/literal, not an ordinary identifier -- a bare
// `auto` always evaluates to that literal, so the module must be imported
// under a different name to be reachable at all.
#import "types/foundations/auto.typ" as auto-value
// Imported under a distinct name for the same reason `encode.typ` does --
// see its own comment on this import.
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

/// Every tagged type's `decode`, keyed by its `typwire-type` tag. One
/// dictionary lookup per tagged value instead of an `if`/`else` chain, and
/// no extra closure layer in between -- see `encode.typ::encode` for why
/// closure calls are worth avoiding here.
///
/// `bytes` is only ever tagged by formats with no native byte string
/// (`Json`): CBOR's own `bytes` values pass straight through `decode`'s
/// leaf case, never reaching this table.
///
/// -> dictionary
#let decoders = (
  (
    (alignment.type-name): alignment.decode,
    (angle.type-name): angle.decode,
    (arguments.type-name): arguments.decode,
    (auto-value.type-name): auto-value.decode,
    (bytes-type.type-name): bytes-type.decode,
    (datetime.type-name): datetime.decode,
    (decimal.type-name): decimal.decode,
    (duration.type-name): duration.decode,
    (label.type-name): label.decode,
    (length.type-name): length.decode,
    (path.type-name): path.decode,
    (ratio.type-name): ratio.decode,
    (regex.type-name): regex.decode,
    (stroke.type-name): stroke.decode,
    (symbol.type-name): symbol.decode,
    (type.type-name): type.decode,
    (version.type-name): version.decode,
  )
    + color.decoders
    + gradient.decoders
)

/// The mirror of `encode.typ::encode`: recursively reconstruct native
/// Typst values from a plain dictionary/array/primitive tree. This is the
/// shared layer every `typwire.<format>.decode` wraps a native format
/// decoder with (`cbor(...)`, `json(...)`, ...).
///
/// Like `encode`, it avoids closure calls wherever it can: only nested
/// arrays/dictionaries are recursed into, and a container holding none is
/// returned as-is.
///
/// -> any
#let decode(
  /// A tree produced by `encode`, after a native format decoder has
  /// parsed it back out of the wire bytes.
  ///
  /// -> any
  value,
  /// The wire format being decoded from -- one of `"cbor"`, `"json"`.
  /// Forwarded to every per-type `decode`, though almost none of them
  /// actually need it: a tag alone already fully determines how to decode
  /// it, independent of which format the bytes originally came from.
  ///
  /// -> str
  format: "cbor",
) = {
  let value-type = std.type(value)

  if value-type == array {
    let types = value.map(std.type).dedup()
    if array in types or dictionary in types {
      let result = ()
      for item in value {
        let item-type = std.type(item)
        result.push(if item-type == array or item-type == dictionary {
          decode(item, format: format)
        } else { item })
      }
      result
    } else {
      value
    }
  } else if value-type == dictionary {
    let decoded = value
    let types = value.values().map(std.type).dedup()
    if array in types or dictionary in types {
      for (key, field) in value {
        let field-type = std.type(field)
        if field-type == array or field-type == dictionary {
          decoded.insert(key, decode(field, format: format))
        }
      }
    }

    if "typwire-type" in decoded {
      let tag = decoded.typwire-type

      assert(
        std.type(tag) == str,
        message: "typwire.decode: typwire-type must be a string",
      )

      let decoder = decoders.at(tag, default: none)
      if decoder == none {
        panic("typwire.decode: unknown typwire-type tag `" + tag + "`")
      }

      decoder(decoded, format: format)
    } else {
      decoded
    }
  } else {
    value
  }
}
