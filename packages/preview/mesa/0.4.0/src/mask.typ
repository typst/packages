#import "kernel.typ" as _kernel

/// Invert polygon geometry within the layer-stack bounds.
#let invert(shapes) = (
  operation: "invert",
  shapes: shapes,
)

/// Merge overlapping polygon shapes into a normalized mask.
#let merge(shapes) = _kernel.merge(shapes)

/// Subtract polygon geometry from a mask.
#let difference(subject, mask) = _kernel.difference(subject, mask)
