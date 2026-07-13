#import "../utils.typ" as utils

/// Serializes content using its string representation.
#let str_serializer(ty) = v => {
  utils.assert_type(v, ty)
  import "string.typ" as string_
  return string_.serializer(str(v))
}

/// Serializes content using its repr representation.
#let repr_serializer(ty) = v => {
  utils.assert_type(v, ty)
  import "string.typ" as string_
  return string_.serializer(repr(v))
}

/// Serializes content raw.
#let raw_serializer(ty) = v => {
  utils.assert_type(v, ty)
  return v
}

/// Serializes a value with a unit, e.g., "12.5kg" into (value: 12.5, unit: "kg").
/// Args:
/// s (string): The string representation of the value with unit.
///
/// Returns:
/// (dict[str, float|str]): A dictionary with keys "value" and "unit".
#let value_unit_serializer(s) = {
  import "float.typ" as float_
  import "string.typ" as string_
  let value = s.find(regex("[0-9.+-]+"))
  let unit = s.slice(value.len())
  return raw_serializer(dictionary)((
    value: float_.serializer(float(value)),
    unit: string_.serializer(unit),
  ))
}


/// Deserializes a plain type value.
/// Args:
/// ty (type): The expected type of the value.
/// v (any): The value to deserialize.
///
/// Returns:
/// (ty): The deserialized value.
#let raw_deserializer(ty) = (v, ctx, request) => {
  utils.assert_type(v, ty)
  return v
}

/// Deserializes a value with a unit from a dictionary.
/// Args:
/// l (dict[str, float|str]): A dictionary with keys "value" and "unit".
///
/// Returns:
/// (any): The deserialized value with unit.
#let value_unit_deserializer(l, ctx, request) = {
  utils.assert_type(l, dictionary)

  import "float.typ" as float_
  return request(((l.at("value"), float_),), l, ((value,), l) => {
    let unit = l.at("unit")
    return eval(str(value) + unit)
  })
}

/// Imports the module for a given type.
/// Each module contains a serializer, deserializer and test methods for that type.
///
/// Args:
/// t (type): The type to get the module for.
///
/// Returns:
/// (module): The imported module for the type.
#let type_mod(t) = {
  import utils.type_str(t) + ".typ" as mod
  return mod
}

/// Extracts optional fields in form of `v.field()` from an object if they are present.
/// Args:
/// v: The object to extract fields from.
/// fields (list[str]): The list of field names to extract.
///
/// Returns:
/// (dict[str, str]): A dictionary with the extracted fields.
///
/// Example:
/// ```typst
/// let fields = at_optional(datetime(year: 2024, month: 6), ("year", "month", "day"));
/// assert(fields == ( "year": 2024, "month": 6 ));
/// ```
#let at_optional(v, fields) = {
  let dict = utils.str_dict()
  for field in fields {
    let value = eval(
      "v." + field + "()",
      scope: (v: v),
    )
    if value == none {
      continue
    }
    dict.insert(field, value)
  }
  return dict
}

#let PRIMITIVE = (
  "boolean",
  "integer",
  "string",
  "array",
  "bytes",
);

#let no_value() = {};

/// Serializes any content recursively into a dictionary with type and value.
/// Args:
/// content (any): The content to serialize.
///
/// Returns:
/// (str): The serialized representation of the content.
#let serializer(content) = {
  import "type.typ" as type_
  import "panic.typ" as panic_

  let is_panic = panic_.is_panic(content)

  let ty = type(content)
  let value = if is_panic {
    panic_.serializer(content)
  } else { type_mod(ty).serializer(content) }

  if utils.type_str(ty) in PRIMITIVE {
    return value
  }
  let ty = if is_panic {
    "panic"
  } else {
    type_.serializer(type(content))
  }
  if value == no_value {
    return (
      type: ty,
    )
  }
  return (
    type: ty,
    value: value,
  )
}

/// For more information see `deserializer`
#let deserialize(content, ctx) = {
  let request(deps, obj, callback) = {
    return (
      __REQUEST__: (
        deps: deps,
        obj: obj,
        callback: callback,
      ),
    )
  }
  let node(data, parent: none) = {
    return (
      data: data,
      // whether the node has been processed yet
      processed: false,
      // amount of solved dependencies
      solved_deps: array(()),
      // index of parent in the tree
      parent: parent,
    )
  }
  let reverse(arr) = {
    let reversed = array(())
    let i = arr.len() - 1
    while i >= 0 {
      reversed.push(arr.at(i))
      i -= 1
    }
    return reversed
  }
  let tree = (:)
  let len = 0

  let (value, ty_mod) = if type(content) == dictionary {
    (content.at("value"), type_mod(content.at("type")))
  } else {
    (content, type_mod(type(content)))
  }

  let d(obj) = {
    return if type(obj) == module {
      obj.deserializer
    } else {
      obj
    }
  }

  tree.insert(str(0), node(d(ty_mod)(value, ctx, request)))
  len += 1

  while tree.len() > 0 {
    let (i, n) = tree.pairs().last()
    // Check if object has dynamic dependency
    if type(n.at("data")) == dictionary and "__REQUEST__" in n.at("data") {
      let req = n.at("data").at("__REQUEST__")
      // Check if node has been processed yet, if not process dependencies
      if not n.at("processed") {
        for (dep, ty) in req.at("deps") {
          tree.insert(str(len), node(d(ty)(dep, ctx, request), parent: i))
          len += 1
        }
        tree.at(i).at("processed") = true
      }
      // check if all depdencies have been solved
      let solved_deps = n.at("solved_deps")
      let u = req.at("deps")
      if solved_deps.len() == req.at("deps").len() {
        // replace self
        tree.insert(str(len), node(req.at("callback")(reverse(solved_deps), req.at("obj")), parent: n.at("parent")))
        tree.remove(i)
        len += 1
      }
    } else {
      if n.at("parent") == none {
        return n.at("data")
      }
      tree.at(str(n.at("parent"))).at("solved_deps").push(n.at("data"))
      tree.remove(i)
    }
  }
  return tree.at(str(0)).at("data")
}

/// Deserializes content from its serialized representation.
///
/// Args:
/// content: The serialized content.
/// panic: if true deserialization will throw a runtime panic if a panic object is deserialized. The default behavior is to display a formatted error message box within the typst document.
///
/// Returns:
/// (any): The deserialized content.
///
/// Note:
/// Each type must provide the following two functions:
/// - `deserializer(obj, ctx, request) -> any`: Deserializes the object from its serialized representation. The preprocessed output and deserialized child dependencies are passed as additional arguments to avoid recursion.
#let deserializer(content, ctx, request) = {
  import "type.typ" as type_

  let ty = type(content)
  if ty != dictionary {
    return type_mod(ty).deserializer(content, ctx, request)
  }

  let ty = type_.deserializer(content.at("type"), ctx, request)
  let deserializer = type_mod(ty).deserializer
  // for singleton types like none or auto
  if "value" not in content {
    return deserializer(content, ctx, request)
  }
  return deserializer(content.at("value"), ctx, request)
}
