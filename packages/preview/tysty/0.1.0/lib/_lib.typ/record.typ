// typst-mode: record.typ
// A small structural type-system built on top of plain Typst dictionaries.
//
// A *record type* is a dictionary carrying three private keys:
//   _type_id — a UID unique to this type (derived from its field map)
//   _fields  — dictionary of field-name -> expected type
//   _methods — dictionary of method-name -> (name, type, fn)
// A *record instance* is a dictionary carrying `_type` (its type) plus one
// value per declared field, with every method pre-bound so that it receives
// the instance as `self`.
//
// Matching is *structural*: two record types are equal iff every field of
// the first also exists in the second with a matching type. Extra fields on
// the second are allowed (asymmetric / structural-subtype behaviour). Raw
// Typst types (`int`, `str`, ...) match against `type(value)`.

#import "uid.typ": namespaces, uid
#import "util.typ": _check_names, _fetch_method, _is_type, _match, _type_accepts, _type_reserved_names

#let _ns_record = uid(namespaces.oid, "e2487d38-8caa-481f-9a15-a7a3853e1d72")
#let _record_uid(name) = uid(_ns_record, name)

// The `fields` method: return a dictionary of field-name -> value for a
// record instance.
#let _get_fields_record(self) = {
  let out = (:)
  for (n, t) in self._type._fields {
    if type(t) == type {
      out.insert(n, self.at(n))
    } else {
      out.insert(n, (self.at(n).fields)())
    }
  }
  out
}

// Constructor (`new`): build an instance of `self` from named arguments.
// 1. validate every declared field against its expected type,
// 2. copy the type's method definitions into the instance,
// 3. re-bind every method so `self` is this instance (with its own bound
//    methods), which lets methods call each other.
#let _new_record(self, ..rest) = {
  assert(arguments.pos(rest).len() == 0, message: "record construictor accepts named fields only")

  for name in arguments.named(rest).keys() {
    assert(
      name in self._fields,
      message: "unknown record field `" + name + "`",
    )
  }
  let instance = (_type: self)

  // field must have a explicit type, if you need null for a field, use enum
  for (f, ty) in self._fields {
    let v = rest.at(f, default: none)
    // Format potentially large values only on the failure path.
    if v == none {
      assert(false, message: "field `" + f + "`: not exist:" + repr(rest))
    }
    if not _match(ty, v) {
      assert(
        false,
        message: "field `" + f + "`:" + "`" + repr(ty) + "` do not match `" + repr(v) + "`",
      )
    }
    instance.insert(f, v)
  }

  for (m, fn) in self._methods {
    assert(fn != none, message: "must provide a method")
    instance.insert(m, fn)
  }

  // `this_call(method)` closes over the fresh instance: it returns a
  // function whose first argument is `_fetch_method(instance, ...)` —
  // i.e. `self` arrives already carrying its own bound methods.
  let this_call(method) = {
    let fn = instance.at(method, default: auto)
    assert(fn != auto)
    (..rest) => fn(_fetch_method(instance, this_call, self._methods.keys()), ..rest)
  }
  instance + _fetch_method(instance, this_call, self._methods.keys())
}

// Copy-and-replace update: validate every field of `instance`, then construct
// a new instance overriding the given fields.
#let _update_record(self, instance, ..rest) = {
  assert(arguments.pos(rest).len() == 0, message: "record construictor accepts named fields only")

  for name in arguments.named(rest).keys() {
    assert(
      name in self._fields,
      message: "unknown record field `" + name + "`",
    )
  }
  let newobj = (:)

  for (k, expected-type) in self._fields {
    let value = instance.at(k, default: none)
    assert(value != none)
    assert(_match(expected-type, value))
    newobj.insert(k, value)
  }

  (self.new)(..newobj, ..rest)
}

// Partial application of the constructor: `(ty.with)(a: 1)` fixes `a` and
// returns a function that fills in the remaining fields when finally called.
#let _with_record(self, ..rest) = {
  (..args) => {
    (self.new)(..rest, ..args)
  }
}

// Structural type comparison: every field of `self` must exist in `other`
// with a matching type. Extra fields on `other` are allowed (asymmetric /
// structural-subtype behaviour).
#let _record_compare(self, other) = {
  if type(other) != dictionary { return false }
  if not ("_type_id" in other) { return false }
  if type(other.at("_fields", default: none)) != dictionary { return false }
  // Same `_type_id` → identical declaration, no need to compare fields
  if self._type_id == other._type_id {
    return true
  }
  let same = true
  for (name, t) in self._fields {
    if not (name in other._fields) {
      // `other` is missing this field → not a subtype
      same = false
      break
    }
    same = _type_accepts(t, other._fields.at(name))
    if not same {
      break
    }
  }
  same
}

// Built-in methods every record type gets.
#let _record_built-ins = (
  compare: _record_compare,
  new: _new_record,
  update: _update_record,
  with: _with_record,
)

/// Defines a record
///
/// *Example*
///
/// ```typst
/// #let Adder = record(
///   x: int,
/// )
/// ```
///
/// You can compare types by:
/// ```typst
/// #(Adder.compare)(Another-Type)
/// ```
///
/// *Returns:*
///
/// A record type.
///
/// *Arguments:*
///
/// - fields (dictionary): field-type pairs
#let record(..fields) = {
  let _description = arguments.pos(fields).join("\n")
  let _fields = arguments.named(fields)

  _check_names(_fields.keys(), _type_reserved_names + ("fields",))

  for (name, ty) in _fields {
    assert(_is_type(ty), message: "field `" + name + "`: expected a type; use an enum for alternatives")
  }

  // The "type" is itself just a dictionary: a UID identifying it, the
  // declared field map, and a method registry seeded with the `fields`
  // accessor. `_methods.fields` has `fn: _get_fields_record`, so every
  // instance automatically carries a `fields` method.
  let ty = (
    _type_id: _record_uid(repr(fields)),
    _fields: _fields,
    _methods: (fields: _get_fields_record),
    description: _description,
  )
  // Re-bind the built-ins so `self` inside them is the type-with-methods.
  let this_call(method) = {
    let fn = _record_built-ins.at(method, default: auto)
    assert(fn != auto)
    (..rest) => fn(_fetch_method(ty, this_call, _record_built-ins.keys()), ..rest)
  }

  ty + _fetch_method(ty, this_call, _record_built-ins.keys())
}

// Attach extra methods to an existing record type. Each method is stored in
// `_methods` (so newly-created instances pick it up) and also exposed
// directly on the type. Built-ins are re-bound at the end so `self` still
// resolves to the extended type.
// This implementation makes rebind (decorate) method possible
#let impl_record(ty, ..fns) = {
  let fns = arguments.named(fns)

  // Type-level built-ins and instance methods are separate: an instance
  // `update` method is valid (state.typ uses it). Data and metadata are not.
  _check_names(
    fns.keys(),
    _type_reserved_names + ("fields", "description") + ty._fields.keys(),
  )

  for (name, fn) in fns {
    assert(type(fn) == function)
    ty._methods.insert(name, fn)
    ty.insert(name, fn)
  }

  // Update type built-ins
  let this_call(method) = {
    let fn = _record_built-ins.at(method, default: auto)
    assert(fn != auto)
    (..rest) => fn(_fetch_method(ty, this_call, _record_built-ins.keys()), ..rest)
  }
  ty + _fetch_method(ty, this_call, _record_built-ins.keys())
}
