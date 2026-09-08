#import "utils.typ": strfmt

/// `class` is a dictionary with a `name` that is like a label that differentiate between each objects
#let class(name, ..fields) = {
  assert(fields.pos().len() == 0, message: "Fields of a class must be keyword arguments.")
  (
    __sanor_class_name: name,
    ..fields.named(),
  )
}

/// Check if the `obj` is a class and optionally whether the class is `name`.
#let is-class(obj) = {
  type(obj) == dictionary and "__sanor_class_name" in obj
}

/// returns the 'class' or 'type' of the `obj`.
#let class-of(obj) = {
  if is-class(obj) { obj.__sanor_class_name } else { type(obj) }
}

/// check if both `obj1` and `obj2` have the same class.
#let match-class(obj1, obj2) = {
  for obj in (obj1, obj2) {
    if not is-class(obj) {
      panic(strfmt("Expected a class, got `{}`", obj1))
    }
  }
  obj1.__sanor_class_name == obj2.__sanor_class_name
}