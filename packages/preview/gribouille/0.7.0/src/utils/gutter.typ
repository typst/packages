// Shared gutter resolution for `compose()` and the facet renderer. A gutter
// input is either a scalar length/number applied to both axes, or a dictionary
// with `x` / `y` keys for independent horizontal / vertical spacing. Resolves
// to `(x: <cm float>, y: <cm float>)` for the cetz canvas, reusing the same
// `length-to-cm` conversion as margins.

#import "margin.typ": length-to-cm
#import "errors.typ": fail, fail-type

// Normalise a gutter value to `(x: <cm float>, y: <cm float>)`.
//   - a length / int / float applies to both axes;
//   - a dictionary sets each axis independently, and a missing key falls back
//     to `fallback` (its keys must be a subset of `x` / `y`);
// `size-pt` resolves em components; `scope` names the caller in error messages.
#let resolve-gutter(value, scope: "gutter", fallback: 0.5cm, size-pt: 9) = {
  if type(value) == dictionary {
    for key in value.keys() {
      if key != "x" and key != "y" {
        fail(
          scope,
          "gutter dictionary keys must be `x` and/or `y`; got " + repr(key),
        )
      }
    }
    return (
      x: length-to-cm(value.at("x", default: fallback), size-pt),
      y: length-to-cm(value.at("y", default: fallback), size-pt),
    )
  }
  if type(value) == length or type(value) == int or type(value) == float {
    let cm = length-to-cm(value, size-pt)
    return (x: cm, y: cm)
  }
  fail-type(
    scope,
    "gutter",
    value,
    "a length such as `0.5cm`, or a dictionary with `x` / `y` keys",
  )
}
