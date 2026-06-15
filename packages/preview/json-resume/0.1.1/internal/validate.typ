// Subtrees under unknown keys are not walked — their expected shape
// is undefined.

#import "errors.typ": _type-name-of

#let _type-error(path, expected, value) = ((
  path: path,
  message: "expected " + expected + ", got " + _type-name-of(value) + ".",
),)

#let _validate(schema, value, path) = {
  let kind = schema.kind
  if kind in ("str", "content") {
    if type(value) != str { return _type-error(path, "string", value) }
    return ()
  }
  if kind == "number" {
    if type(value) not in (int, float) { return _type-error(path, "number", value) }
    return ()
  }
  if kind == "array" {
    if type(value) != array { return _type-error(path, "array", value) }
    return value.enumerate()
      .map(((i, elem)) => _validate(schema.elem, elem, path + (i,)))
      .flatten()
  }
  if kind == "object" {
    if type(value) != dictionary { return _type-error(path, "object", value) }
    let per-key-errs = value.pairs().map(((key, sub-value)) => {
      if key in schema.shape {
        _validate(schema.shape.at(key), sub-value, path + (key,))
      } else {
        // Valid-keys list only assembled on the unknown-key branch so
        // the happy path skips the join.
        let valid-keys-str = schema.shape.keys().join(", ")
        ((
          path: path + (key,),
          message: "unknown key " + repr(key) + ". Valid keys: " + valid-keys-str + ".",
        ),)
      }
    }).flatten()
    let required = schema.at("required-keys", default: ())
    let missing-errs = required
      .filter(k => k not in value)
      .map(k => (
        path: path + (k,),
        message: "missing required key " + repr(k) + ".",
      ))
    return per-key-errs + missing-errs
  }
  panic("json-resume: internal — unknown schema kind " + repr(kind))
}
