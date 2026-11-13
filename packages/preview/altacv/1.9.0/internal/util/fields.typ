// Dict readers: a field's value, or `none` when it's absent. Reading
// the CV is for sections and `data/`; components don't import this
// module, but get values through slots (ARCHITECTURE.md).

#import "values.typ": _present, _present-str

// A field's value, or `none` when it's absent in any of those forms.
#let _field(obj, key) = {
  let v = obj.at(key, default: none)
  if _present(v) { v }
}

// Lenient readers: a value of the wrong type reads as empty.
#let _dict-or-empty(v) = if type(v) == dictionary { v } else { (:) }
#let _array-or-empty(v) = if type(v) == array { v } else { () }

// `v` when it's an array of text (strings or content), else `none`.
#let _texts(v) = if (
  type(v) == array and v.all(x => type(x) in (str, content))
) { v }

// `v` when it's a non-empty string, else `none`.
#let _string(v) = if _present-str(v) { v }

#let _string-at(obj, key) = _string(obj.at(key, default: none))

