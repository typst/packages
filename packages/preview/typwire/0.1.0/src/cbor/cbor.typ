#import "angle.typ"
#import "color.typ"
#import "datetime.typ"
#import "duration.typ"
#import "gradient.typ"
#import "length.typ"
#import "ratio.typ"
#import "type.typ"
#import "version.typ"

#let is-cbor-compatible(content) = {
  (
    std.type(content) == std.int
      or std.type(content) == std.float
      or std.type(content) == std.bytes
      or std.type(content) == std.str
      or std.type(content) == std.bool
      or std.type(content) == std.content
      or content == none
  )
}

#let encode-inner(content) = {
  let result

  if is-cbor-compatible(content) {
    result = content
  } else if std.type(content) == std.array {
    result = content.map(i => encode-inner(i))
  } else if std.type(content) == std.dictionary {
    result = (:)
    for (key, value) in content.pairs() {
      result.insert(key, encode-inner(value))
    }
  } else if std.type(content) == std.angle {
    result = encode-inner(angle.encode(content))
  } else if std.type(content) == std.length {
    result = encode-inner(length.encode(content))
  } else if std.type(content) == std.ratio {
    result = encode-inner(ratio.encode(content))
  } else if std.type(content) == std.color {
    result = encode-inner(color.encode(content))
  } else if std.type(content) == std.gradient {
    result = encode-inner(gradient.encode(content))
  } else if std.type(content) == std.datetime {
    result = encode-inner(datetime.encode(content))
  } else if std.type(content) == std.duration {
    result = encode-inner(duration.encode(content))
  } else if std.type(content) == std.version {
    result = encode-inner(version.encode(content))
  } else if std.type(content) == std.type {
    result = encode-inner(type.encode(content))
  } else {
    panic("cbor.encode: Unsupported content type: " + str(std.type(content)))
  }

  result
}

/// Encode content into CBOR format.
///
/// - content (any): The content to encode.
/// -> bytes
#let encode(content) = {
  cbor.encode(encode-inner(content))
}
