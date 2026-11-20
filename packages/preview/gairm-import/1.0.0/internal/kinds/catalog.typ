// The public constructors of each kind, for the queries that start from
// one (find-paths) and the load-time check that no kind or
// constructor is missed. It sits above registry.typ and the
// constructors' modules: the constructors check their sub-schemas
// against the registry's kinds, so the registry cannot list them.
//
// Each kind maps to its constructors as (function, test) pairs:
// find-paths's query by that constructor finds the nodes of the kind
// the test holds for (one-of the exclusive unions). A bare function is
// a pair whose test holds for every node of the kind.

#import "../core/error.typ": _internal
#import "registry.typ": _kinds, _is-nullable
#import "leaf.typ" as _leaf-mod
#import "leaf.typ": (
  number, integer, markup, boolean, null, unknown, enum-of, const-of,
)
#import "format.typ" as _format-mod
#import "format.typ": string
#import "structure.typ" as _structure-mod
#import "structure.typ": (
  array-of, object, map, any-of, one-of, not-of, if-of, nullable,
)

#let _constructors = {
  let listed = (
    string: (string,),
    number: (number,),
    integer: (integer,),
    markup: (markup,),
    boolean: (boolean,),
    "null": (null,),
    unknown: (unknown,),
    enum: (enum-of, (const-of, s => s.values.len() == 1)),
    array: (array-of,),
    object: (object, map),
    union: (
      (any-of, s => not s.exclusive),
      (one-of, s => s.exclusive),
      (nullable, _is-nullable),
    ),
    "not": (not-of,),
    "if": (if-of,),
  )
  listed
    .pairs()
    .map(((kind, cs)) => (
      kind,
      cs.map(c => if type(c) == array { c } else { (c, _ => true) }),
    ))
    .to-dict()
}

// The kind `fn` builds and its test, or none for a function that is no
// constructor. The load-time check passes its own `constructors`.
#let _constructor(fn, constructors: _constructors) = {
  for (kind, cs) in constructors {
    let hit = cs.find(((f, _)) => f == fn)
    if hit != none { return (kind: kind, test: hit.at(1)) }
  }
}

// Every kind listed here is registered, every registered kind is
// listed, and every exported constructor is listed, so a new kind can't
// miss its descriptor or its constructors.
// `dictionary(module)` lists a module's names.
#let _check-coverage(kinds, constructors, modules) = {
  for kind in constructors.keys() {
    _internal(
      kind in kinds,
      "constructors are listed for "
        + repr(kind)
        + ", which has no descriptor.",
    )
  }
  for kind in kinds.keys() {
    _internal(
      kind in constructors,
      "kind " + repr(kind) + " has a descriptor but no constructors listed.",
    )
  }
  for mod in modules {
    for (name, v) in dictionary(mod) {
      if name.starts-with("_") { continue }
      if type(v) == function {
        _internal(
          _constructor(v, constructors: constructors) != none,
          "constructor " + name + " is listed for no kind.",
        )
      }
    }
  }
}

#_check-coverage(_kinds, _constructors, (
  _leaf-mod,
  _format-mod,
  _structure-mod,
))
