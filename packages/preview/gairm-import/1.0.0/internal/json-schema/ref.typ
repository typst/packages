// `$ref` resolution: a fragment of the same document, read as a JSON
// Pointer. The dispatcher (translate.typ) follows a node's `$ref`, and
// the merges (all-of.typ, conditional.typ) read a raw member's target.

#import "../core/pointer.typ": _percent-decode, _read-pointer, _pointer-get
#import "keyword.typ": _bail, _json, _base-id, _bail-embedded-id, _into

// The target of `ref`, a `$ref` on the node at `ctx`, as `(value, at,
// path)`:
// `at` is the target's JSON Pointer, where the translation continues,
// and `path` its segments, decoded. `ctx.seen` is the chain of
// (ref, path) traversed so far: a repeated target, however its ref
// spells it (`%61` is `a`), means the
// schema contains itself — a tree that nests a tree, or an alias of an
// alias. A translated schema is a finite tree, so it can't, and the
// translator panics before Typst's recursion limit fires deep in the
// stack.
#let _resolve-ref(ref, ctx) = {
  // `#/` is not the root: as a JSON Pointer, `/` names the key "".
  if ref == "#" {
    _bail(ctx, "$ref \"#\" cannot reference the document root.")
  }
  if ref.starts-with("#") and not ref.starts-with("#/") {
    _bail(
      ctx,
      "$ref "
        + _json(ref)
        + " names an anchor, which is out of scope; reference the schema by its JSON Pointer (\"#/definitions/…\").",
    )
  }
  if not ref.starts-with("#/") {
    _bail(
      ctx,
      "only internal $ref (starting with \"#/\") is supported, got: "
        + _json(ref)
        + ".",
    )
  }
  // The fragment is a URI's, so it is percent-decoded into the pointer
  // (RFC 3986) before the pointer is read (RFC 6901): `%25` is `%`.
  let pointer = _percent-decode(ref.slice(1))
  if pointer == none {
    _bail(
      ctx,
      "$ref "
        + _json(ref)
        + " has a malformed percent escape; `%` must start a `%XX` hex escape of UTF-8 bytes (write `%25` for a literal `%`).",
    )
  }
  let read = _read-pointer(pointer)
  if read.bad != none {
    _bail(
      ctx,
      "$ref "
        + _json(ref)
        + " has an invalid escape; RFC 6901 only allows `~0` (tilde) and `~1` (slash).",
    )
  }
  if ctx.seen.any(((_, p)) => p == read.path) {
    _bail(
      ctx,
      "recursive $ref: "
        + (ctx.seen.map(((r, _)) => r) + (ref,)).map(_json).join(" → ")
        + " refers back to itself. A translated schema is a finite tree, so a schema that contains itself (a tree of trees, a list of lists) cannot be translated.",
    )
  }
  // RFC 6901: `~1` / `~0` unescape, empty segments are the "" key, and
  // a numeric segment indexes an array (e.g. "#/allOf/0") or names a key.
  let found = _pointer-get(ctx.root, read.path)
  if found.missing != none {
    _bail(
      ctx,
      "$ref "
        + _json(ref)
        + " could not be resolved (segment "
        + _json(str(found.missing))
        + " missing).",
    )
  }
  // A target below an embedded `$id` inherits its base, as one that
  // carries it does (the dispatcher's keyword check), so a `$ref` in it
  // would resolve against the wrong document: refuse every ancestor's
  // too, the root's own `$id` aside.
  for k in range(1, read.path.len()) {
    let above = _pointer-get(ctx.root, read.path.slice(0, k)).value
    if _base-id(above) != none {
      let where = _into((at: ""), ..read.path.slice(0, k)).at
      _bail-embedded-id(ctx, _base-id(above), where)
    }
  }
  (value: found.value, at: pointer, path: read.path)
}

// A raw node with its `$ref`s followed, for the merges, which read a
// member after it translated: each ref is then known to resolve
// without a cycle.
#let _follow-refs(js, ctx) = {
  let js = js
  while type(js) == dictionary and "$ref" in js {
    js = _resolve-ref(js.at("$ref"), (..ctx, seen: ())).value
  }
  js
}
