#import "utils.typ"

/// Encode a ratio into a CBOR-compatible float.
///
/// - ratio (ratio): A ratio of any value.
/// -> float
#let encode(ratio) = {
  assert(type(ratio) == std.ratio, message: "ratio.encode: ratio must be of type ratio")
  
  (
    "typed-type": "ratio",
    "ratio": utils.ratio-to-float(ratio)
  )
}
