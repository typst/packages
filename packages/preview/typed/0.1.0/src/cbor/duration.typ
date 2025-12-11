#let new(seconds) = {
  assert(type(seconds) == std.float, message: "duration.new: seconds must be of type float")
  
  (
    "typed-type": "duration",
    "seconds": seconds,
  )
}

/// Encode a duration into a CBOR-compatible dictionary.
///
/// - duration (duration): A duration.
/// -> dictionary
#let encode(duration) = {
  assert(type(duration) == std.duration, message: "duration.encode: duration must be type of duration")

  new(duration.seconds())
}
