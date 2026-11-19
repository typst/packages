#import "../../utils.typ": is-debug-assert

#let type-name = "alignment"

// `alignment` has no `str()` conversion and no dedicated accessor for its
// component tags, so components are matched by equality against Typst's own
// global alignment constants instead of parsing `repr()` -- there are only
// 5 horizontal and 3 vertical values, all fixed, so an equality chain is
// simpler and more robust than a text-parsing trick.

#let h-tag(value) = {
  if value == none {
    none
  } else if value == start {
    "start"
  } else if value == left {
    "left"
  } else if value == center {
    "center"
  } else if value == right {
    "right"
  } else if value == end {
    "end"
  } else {
    panic("alignment.encode: unknown horizontal alignment " + repr(value))
  }
}

#let v-tag(value) = {
  if value == none {
    none
  } else if value == top {
    "top"
  } else if value == horizon {
    "horizon"
  } else if value == bottom {
    "bottom"
  } else {
    panic("alignment.encode: unknown vertical alignment " + repr(value))
  }
}

#let h-from-tag(tag) = {
  if tag == "start" {
    start
  } else if tag == "left" {
    left
  } else if tag == "center" {
    center
  } else if tag == "right" {
    right
  } else if tag == "end" {
    end
  } else {
    panic("alignment.decode: unknown horizontal alignment tag " + tag)
  }
}

#let v-from-tag(tag) = {
  if tag == "top" {
    top
  } else if tag == "horizon" {
    horizon
  } else if tag == "bottom" {
    bottom
  } else {
    panic("alignment.decode: unknown vertical alignment tag " + tag)
  }
}

/// Encode a 1D or 2D alignment into a wire-compatible dictionary.
///
/// -> dictionary
#let encode(
  /// The alignment to encode.
  ///
  /// -> alignment
  value,
  /// The wire format being encoded for. Unused -- `alignment` has the same
  /// tagged-dictionary shape in every format.
  ///
  /// -> str
  format: "cbor",
) = {
  if is-debug-assert {
    assert(
      type(value) == alignment,
      message: "alignment.encode: value must be of type alignment",
    )
  }

  (
    typwire-type: type-name,
    x: h-tag(value.x),
    y: v-tag(value.y),
  )
}

/// Decode a wire-compatible dictionary into a 1D or 2D alignment.
///
/// -> alignment
#let decode(
  /// A dictionary produced by `encode`.
  ///
  /// -> dictionary
  value,
  /// The wire format being decoded from. Unused -- `alignment` decodes the
  /// same way regardless of format.
  ///
  /// -> str
  format: "cbor",
) = {
  if is-debug-assert {
    assert(
      value.typwire-type == type-name,
      message: "alignment.decode: value must be a tagged with type "
        + type-name
        + ". Found "
        + value.typwire-type,
    )
  }

  if value.x != none and value.y != none {
    h-from-tag(value.x) + v-from-tag(value.y)
  } else if value.x != none {
    h-from-tag(value.x)
  } else {
    v-from-tag(value.y)
  }
}
