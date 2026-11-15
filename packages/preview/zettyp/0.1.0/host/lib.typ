#import "../core/eval.typ" as eval

#let pure(value) = {
  let kind = type(value)
  if kind == dictionary { value.values().all(pure) } else if kind == array {
    value.all(pure)
  } else { kind in (str, int, float, bool, type(none)) }
}

#let path(value) = {
  assert(type(value) == str, message: "path must be a string")
  assert(
    not value.contains("\\")
      and not value.contains(":")
      and not value.contains("\u{0}")
      and value.split("/").all(part => part not in ("", ".", "..")),
    message: "path must be canonical and project-relative",
  )
  value
}

#let node(id, title, origin, metadata) = {
  assert(type(id) == str and type(title) == str)
  assert(type(origin) == content)
  assert(
    type(metadata) == dictionary and pure(metadata),
    message: "metadata must be pure data",
  )
  (id: id, title: title, origin: eval.inspect(origin), metadata: metadata)
}

#let host-path = path

#let create(path, content) = {
  assert(type(content) == str)
  (kind: "create", path: (host-path)(path), content: content)
}
#let replace(path, before, content) = {
  assert(type(before) == str and type(content) == str)
  (kind: "replace", path: (host-path)(path), before: before, content: content)
}
#let delete(path, before) = {
  assert(type(before) == str)
  (kind: "delete", path: (host-path)(path), before: before)
}
#let plan(effects, verify, result: (:)) = {
  assert(type(effects) == array)
  for effect in effects {
    assert(type(effect) == dictionary)
    let kind = effect.at("kind")
    assert(kind in ("create", "replace", "delete"))
    let _ = path(effect.path)
    if kind != "create" { assert(type(effect.before) == str) }
    if kind != "delete" { assert(type(effect.content) == str) }
  }
  assert(type(verify) == dictionary)
  let _ = path(verify.entry)
  assert(
    type(verify.inputs) == dictionary
      and verify.inputs.values().all(it => type(it) == str),
  )
  assert(
    type(result) == dictionary and pure(result),
    message: "result must be a pure data dictionary",
  )
  (effects: effects, verify: verify, result: result)
}

#let request() = {
  let value = json(bytes(sys.inputs.at("host.request")))
  assert(
    type(value) == dictionary,
    message: "host.request must be a JSON dictionary",
  )
  value
}
