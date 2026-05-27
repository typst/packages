/// Used inside an example to give it a label.
/// Effectively an alias of metadata.
///
/// - l (label): The label.
///
///   *Required*
///
/// -> content
#let ex-label(
  l,
) = {
  assert(type(l) == label, message: "ex-label only accepts labels")
  metadata(l)
}

#let get-ex-label(content) = {
  let label
  if "children" in content.fields() {
    label = content.children.find(it => "value" in it.fields() and type(it.value) == std.label)
  }
  if label != none {
    label = label.value
  }
  return label
}

