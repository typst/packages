/// Tagged disjoint unions with opaque payloads.
#import "schema.typ"
#let left(value) = (side: "left", value: value)
#let right(value) = (side: "right", value: value)

/// Merge A -> C and B -> C into A + B -> C.
/// Only the selected branch runs. No policy semantics or panic recovery.
#let merge(on-left, on-right) = {
  let on-left = schema.checked(on-left, schema.callable, scope: ("on-left",))
  let on-right = schema.checked(on-right, schema.callable, scope: ("on-right",))
  value => {
    let value = schema.checked(value, schema.sum)
    if value.side == "left" { on-left(value.value) } else {
      on-right(value.value)
    }
  }
}
