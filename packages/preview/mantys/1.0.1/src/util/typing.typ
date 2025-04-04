#let typst-content = content
#let typst-regex = regex

#import "is.typ"
#import "../_deps.typ": valkyrie
#import valkyrie: *


// Aliases for the original valkyrie types.
#let valkyrie-choice = choice
#let valkyrie-content = content

/// Schema for a field that always will be set to a constant value, no matter
/// the value supplied for that key. The value is taken from the supplied
/// types default value.
/// -> dictionary
#let constant(
  /// Any of the valkyrie types with a default value set.
  /// -> dictionary
  type,
) = {
  type.optional = true
  type.pre-transform = (..) => type.default
  type
}

#let optional(type) = {
  type.optional = true
  type
}

/// Augments the content type to include #dtype("symbol") as allowed type.
#let content = base-type.with(name: "content", types: (typst-content, str, symbol))

/// Type for Typst build-in #dtype("version").
#let version = base-type.with(
  name: "version",
  types: (std.version,),
  pre-transform: (self, it) => {
    if is.str(it) {
      std.version(..it.split(".").map(int))
    } else {
      it
    }
  },
)
/// Type for Typst build-in #dtype("symbol").
#let symbol = base-type.with(name: "symbol", types: (symbol,))
/// Type for Typst build-in #dtype("label").
#let label = base-type.with(name: "label", types: (label,))
/// Type for Typst build-in #dtype("auto").
#let _auto = base-type.with(name: "auto", types: (type(auto),))

#let url(
  assertions: (),
  ..args,
) = string(
  name: "url",
  assertions: (
    assert.matches(
      typst-regex("(https:\/\/www\.|http:\/\/www\.|https:\/\/|http:\/\/)?[a-zA-Z]{2,}(\.[a-zA-Z]{2,})(\.[a-zA-Z]{2,})?\/[a-zA-Z0-9]{2,}|((https:\/\/www\.|http:\/\/www\.|https:\/\/|http:\/\/)?[a-zA-Z]{2,}(\.[a-zA-Z]{2,})(\.[a-zA-Z]{2,})?)|(https:\/\/www\.|http:\/\/www\.|https:\/\/|http:\/\/)?[a-zA-Z0-9]{2,}\.[a-zA-Z0-9]{2,}\.[a-zA-Z0-9]{2,}(\.[a-zA-Z0-9]{2,})?"),
    ),
    ..assertions,
  ),
  ..args,
)


#let optional-coerce(coercion) = (self, it) => {
  if self.optional and it == none {
    return none
  } else {
    return coercion(self, it)
  }
}
