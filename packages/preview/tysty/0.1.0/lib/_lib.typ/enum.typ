#import "uid.typ": namespaces, uid
#import "util.typ": _check_names, _fetch_method, _is_type, _match, _type_accepts, _type_reserved_names

#let _ns_enum = uid(namespaces.oid, "e4f747b7-fc19-4082-9acf-cd0f1b188bba")
#let _enum_uid(name) = uid(_ns_enum, name)

// The `fields` method: return a dictionary of field-name -> value for a
// record instance.
#let _get_fields_enum(self) = {
  let typ = self._type._variants.at(self.variant)
  if (type(typ) == type) {
    ((self.variant): self.payload)
  } else {
    ((self.variant): (self.payload.fields)())
  }
}

// Every actual variant in `other` must be accepted by expected type `self`.
// Fewer actual variants are allowed; extra actual variants are rejected.
#let _enum_compare(self, other) = {
  if type(other) != dictionary { return false }
  if not ("_type_id" in other) { return false }
  if type(other.at("_variants", default: none)) != dictionary { return false }
  // Same `_type_id` → identical declaration, no need to compare variants
  if self._type_id == other._type_id {
    return true
  }
  for (name, actual) in other._variants {
    if not (name in self._variants) {
      return false
    }
    let expected = self._variants.at(name)
    let compatible = _type_accepts(expected, actual)

    if not compatible {
      return false
    }
  }
  true
}

#let _new_enum(self, variant, ..rest) = {
  let expected = self._variants.at(variant)
  let new = if type(expected) == type {
    it => {
      if not _match(expected, it) {
        assert(
          false,
          message: "variant `" + variant + "`: expected " + repr(expected) + ", got " + repr(type(it)),
        )
      }
      it
    }
  } else {
    expected.new
  }
  let instance = (
    _type: self,
    variant: variant,
    payload: new(..rest),
  )

  for (m, fn) in self._methods {
    assert(fn != none, message: "must provide a method")
    instance.insert(m, fn)
  }
  let this_call(method) = {
    let fn = instance.at(method, default: auto)
    assert(fn != auto)
    (..rest) => fn(_fetch_method(instance, this_call, self._methods.keys()), ..rest)
  }
  instance + _fetch_method(instance, this_call, self._methods.keys())
}

#let _register_enum(self, variant, ty) = {
  assert(_is_type(ty), message: "variant `" + variant + "`: expected a payload type")
  self = self + (_variants: self._variants + ((variant): ty))

  let this_call(variant) = {
    let fn = (self, ..rest) => { (self.new)(variant, ..rest) }
    (..rest) => fn(_fetch_method(self, this_call, self._variants.keys()), ..rest)
  }
  self + _fetch_method(self, this_call, self._variants.keys())
}

#let _with_enum(self, variant, ..rest) = {
  (..args) => {
    (self.new)(variant, ..rest, ..args)
  }
}

#let _enum_built-ins = (
  compare: _enum_compare,
  new: _new_enum,
  with: _with_enum,
  // NOTE: private API, for sum type construct only, no outside usage
  _register: _register_enum,
)

#let enumerator(..variants) = {
  let _description = arguments.pos(variants).join("\n")
  let _variants = arguments.named(variants)

  _check_names(
    _variants.keys(),
    _type_reserved_names + _enum_built-ins.keys() + ("fields", "description", "variant", "payload"),
  )

  // The "type" is itself just a dictionary: a UID identifying it, the
  // declared field map, and a method registry seeded with the `fields`
  // accessor. `_methods.fields` has `fn: _get_fields_record`, so every
  // instance automatically carries a `fields` method.
  let ty = (
    _type_id: _enum_uid(repr(variants)),
    _variants: _variants,
    _methods: (fields: _get_fields_enum),
    description: _description,
  )
  // Re-bind the built-ins so `self` inside them is the type-with-methods.
  let this_call(method) = {
    let fn = _enum_built-ins.at(method, default: auto)
    assert(fn != auto)
    (..rest) => fn(_fetch_method(ty, this_call, _enum_built-ins.keys()), ..rest)
  }

  for (name, typ) in _variants {
    let this_call(method) = {
      let fn = _enum_built-ins.at(method, default: auto)
      assert(fn != auto)
      (..rest) => fn(_fetch_method(ty, this_call, _enum_built-ins.keys()), ..rest)
    }
    ty = ty + _fetch_method(ty, this_call, _enum_built-ins.keys())
    ty = (ty._register)(name, typ)
  }

  ty + _fetch_method(ty, this_call, _enum_built-ins.keys())
}


#let impl_enum(ty, ..fns) = {
  let fns = arguments.named(fns)

  _check_names(
    fns.keys(),
    _type_reserved_names
      + _enum_built-ins.keys()
      + ("fields", "description", "variant", "payload")
      + ty._variants.keys(),
  )

  for (name, fn) in fns {
    assert(type(fn) == function)
    ty._methods.insert(name, fn)
    ty.insert(name, fn)
  }

  let this_call(method) = {
    let fn = _enum_built-ins.at(method, default: auto)
    assert(fn != auto)
    (..rest) => fn(_fetch_method(ty, this_call, _enum_built-ins.keys()), ..rest)
  }

  for (name, typ) in ty._variants {
    let this_call(method) = {
      let fn = _enum_built-ins.at(method, default: auto)
      assert(fn != auto)
      (..rest) => fn(_fetch_method(ty, this_call, _enum_built-ins.keys()), ..rest)
    }
    ty = ty + _fetch_method(ty, this_call, _enum_built-ins.keys())
    ty = (ty._register)(name, typ)
  }

  ty + _fetch_method(ty, this_call, _enum_built-ins.keys())
}
