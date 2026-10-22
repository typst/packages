// Inspect public Typst metadata fields without depending on Touying internals.
#let is-kind(it, kind) = (
  type(it) == content and it.func() == metadata
  and type(it.value) == dictionary
  and it.value.at("kind", default: none) == kind
)
