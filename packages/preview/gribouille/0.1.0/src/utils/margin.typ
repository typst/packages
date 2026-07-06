// Shared margin and length resolution helpers used by the renderer and theme
// code. Converts user-supplied lengths (absolute or em) to cm floats consumed
// by the cetz canvas, and provides fall-through semantics so unset sides keep
// the renderer default.

// Convert a Typst length (which may contain em components) to a float in cm.
// `size-pt` is the surface font size as a unitless point value; em components
// are resolved against it using Typst's exact pt-to-cm conversion so absolute
// and relative parts stay consistent.
#let length-to-cm(value, size-pt) = {
  if type(value) == length {
    value.abs / 1cm + value.em * (size-pt * 1pt / 1cm)
  } else if type(value) == int or type(value) == float {
    float(value)
  } else {
    0.0
  }
}

// Resolve a margin-side input to a float in cm, falling back when the input
// is `auto` or otherwise unset. `value` may be `auto`, `none`, or a length.
// `fallback` may be a length or a cm-as-float; em components in either are
// resolved against `size-pt`.
#let resolve-margin-side-cm(value, fallback, size-pt: 9) = {
  if type(value) == length {
    return length-to-cm(value, size-pt)
  }
  if type(fallback) == length {
    return length-to-cm(fallback, size-pt)
  }
  if type(fallback) == int or type(fallback) == float {
    return float(fallback)
  }
  0.0
}

// The other side of an axis (right<->left, top<->bottom). Used to map a
// rect surface side ("right" legend on canvas right) onto its
// panel-facing outset side ("left").
#let opposite-side = (
  top: "bottom",
  right: "left",
  bottom: "top",
  left: "right",
)

// The two sides perpendicular to a given side: horizontal sides return
// the vertical axis pair and vice versa.
#let perpendicular-sides = (
  top: ("left", "right"),
  right: ("top", "bottom"),
  bottom: ("left", "right"),
  left: ("top", "bottom"),
)

// Resolve a margin-side input to a float in cm against a reference cm
// dimension. Accepts the full Typst `relative` shape (length + ratio):
// `auto` / `none` -> 0; `length` -> absolute / em via `length-to-cm`;
// `ratio` (e.g., `5%`) -> `value.get() * ref-cm`; `relative` -> the sum
// of its `ratio` and `length` parts. Per-axis callers pass the axis-
// relevant reference (width-units for left / right, height-units for
// top / bottom).
#let resolve-margin-side-rel-cm(value, ref-cm, size-pt: 9) = {
  if type(value) == length {
    return length-to-cm(value, size-pt)
  }
  if type(value) == ratio {
    return (value / 100%) * ref-cm
  }
  if type(value) == relative {
    return (value.ratio / 100%) * ref-cm + length-to-cm(value.length, size-pt)
  }
  if type(value) == int or type(value) == float {
    return float(value)
  }
  0.0
}

