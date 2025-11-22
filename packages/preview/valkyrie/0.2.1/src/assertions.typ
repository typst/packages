#import "./assertions/length.typ" as length
#import "./assertions/comparative.typ": min, max, eq
#import "./assertions/string.typ": *

/// Asserts that the given value is contained within the provided list. Useful for complicated enumeration types.
/// - list (array): An array of inputs considered valid.
#let one-of(list) = (
  condition: (self, it) => {
    list.contains(it)
  },
  message: (self, it) => "Unknown " + self.name + " `" + repr(it) + "`",
)