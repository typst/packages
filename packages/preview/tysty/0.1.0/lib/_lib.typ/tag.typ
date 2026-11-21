// typst-mode: tag.typ
// Hierarchical tag system. Tags form a tree: `register` creates a root tag
// plus one child per given name, and `sub` grows further children. Each tag
// tracks the documents attached to it via its own `_state` slot.

#import "record.typ": impl_record, record
#import "state.typ": _mkstate, _state
#import "doc.typ": documents

#import "uid.typ": namespaces, uid

// uid namespace for tags, mirroring the scheme used in doc.typ.
#let _ns_tag = uid(namespaces.oid, "ac562613-54f4-4584-8ea4-1401df8d1ed2")
#let _tag_uid(name) = uid(_ns_tag, name)

// A tag: `_parent` is the id of its parent ("" for the root), `id`/`name`
// identify it, `documents` is a `_state` slot accumulating attached
// document ids.
#let tag = record(
  _parent: str,
  id: str,
  name: str,
  documents: _state,
)

#let tag = impl_record(
  tag,
  // Create a child tag under this one. The child gets a fresh, empty
  // `documents` slot so it tracks its own documents. `self._type.new` (rather
  // than a captured `tag.new`) keeps the child wired to the *full* tag type —
  // a closure defined before `impl` finishes would otherwise capture the
  // bare, method-less type.
  sub: (self, name) => {
    let id = _tag_uid(self.id + ":" + name)
    (self._type.new)(
      _parent: self.id,
      id: id,
      name: name,
      documents: _mkstate(id, ()),
    )
  },
  get-doc: self => {
    documents().filter(doc => doc.tags.any(t => t.id == self.id))
  },
)

// Recursively turn a dictionary of child names into a dictionary of nodes.
// Each node contains its actual tag record and another `children` dictionary.
// An empty dictionary denotes a leaf.
#let _build-children(parent, tree) = {
  assert(type(tree) == dictionary, message: "tag children must be a dictionary")
  let children = (:)
  for (name, descendants) in tree {
    assert(type(descendants) == dictionary, message: "tag children must be a dictionary: " + name)
    let child = (parent.sub)(name)
    children.insert(name, (
      tag: child,
      children: _build-children(child, descendants),
    ))
  }
  children
}

// Register a hierarchy. Example:
// #let tree = (tag.register)("notes", (science: (physics: (:),),))
// #let physics = tree.children.science.children.physics.tag
#let tag = (
  tag
    + (
      register: (namespace, tree) => {
        assert(type(tree) == dictionary, message: "tag tree must be a dictionary")
        let root_id = _tag_uid(repr(("registration", namespace)))
        let root = (tag.new)(
          _parent: namespace,
          id: root_id,
          name: namespace,
          documents: _mkstate(root_id + ":" + "f8480bdb-6c76-44b5-a0a3-211e55105521", ()),
        )
        (
          tag: root,
          children: _build-children(root, tree),
        )
      },
    )
)
