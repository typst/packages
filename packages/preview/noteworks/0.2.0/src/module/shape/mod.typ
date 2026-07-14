// =====================================================
// SHAPE MODULE - Pure 2D Geometry
// =====================================================
// Re-exports all shape types and operations.

// Core utilities
#import "core.typ": *

// Geometry objects
#import "point.typ": *
#import "line.typ": (
  segment,
  line,
  ray,
  line-through-direction,
  is-segment,
  is-line,
  is-ray,
  is-linear,
  linear-direction,
  segment-length,
  ray-to-segment,
  line-to-segment,
  segment-to-line,
  segment-to-ray,
  ray-to-line,
  line-to-ray,
  line-point-slope
)
#import "circle.typ": *
#import "angle.typ": *
#import "polygon.typ": *

// Construction operations
#import "construct.typ": *

// Intersection operations
#import "intersect.typ": (
  intersect,
  intersect-linear-linear,
  intersect-ll,
  intersect-linear-circle,
  intersect-lc,
  intersect-circle-circle,
  intersect-cc,
  intersect-function-function,
  intersect-function-line,
  point-on-linear,
  point-on-circle,
)
