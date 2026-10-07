// Complete situation validation, ordered before geometry placement.

#import "../../shared/validation-core.typ" as core
#import "schema.typ" as schema
#import "elements.typ" as elements
#import "references.typ" as references
#import "compatibility.typ" as compatibility

#let _value = core.value-representation
#let validate-physical-scalar = core.validate-physical-scalar
#let known-declaration-kinds = schema.known-declaration-kinds
#let _allowed-fields = schema.allowed-fields
#let _required-fields = schema.required-fields
#let _named-kind = schema.named-kind
#let _validate-declaration-local = elements.validate-declaration-local
#let _reference-specifications = references.reference-specifications
#let attachment-element-name = references.attachment-element-name
#let _dependency-reaches = references.dependency-reaches
#let _validate-reference = references.validate-reference
#let _validate-cross-element-compatibility = compatibility.validate-cross-element-compatibility

#let validate-situation-declarations(declarations, gravity) = {
  assert(
    type(declarations) == array and declarations.len() > 0,
    message: (
      "typed-physics: situation() needs at least one element declaration; "
        + "add a surface, body, connector, or structure"
    ),
  )
  validate-physical-scalar(gravity, "situation()", "gravity")

  let declarations-by-name = (:)
  let declaration-index-by-name = (:)
  for (declaration-index, declaration) in declarations.enumerate() {
    assert(
      type(declaration) == dictionary,
      message: (
        "typed-physics: situation() declaration "
          + str(declaration-index + 1)
          + " is "
          + _value(declaration)
          + ", not an element dictionary; pass a value returned by ground(), block(), force(), or another public constructor"
      ),
    )
    assert(
      "kind" in declaration and type(declaration.kind) == str,
      message: (
        "typed-physics: situation() declaration "
          + str(declaration-index + 1)
          + " needs a string `kind:`; use a public element constructor instead of a hand-written dictionary"
      ),
    )
    assert(
      declaration.kind in known-declaration-kinds,
      message: (
        "typed-physics: situation() declaration "
          + str(declaration-index + 1)
          + " has unknown kind "
          + _value(declaration.kind)
          + "; accepted declaration kinds are "
          + known-declaration-kinds.join(", ")
          + ". Use the matching public constructor"
      ),
    )
    let allowed-fields = _allowed-fields(declaration.kind)
    for field in declaration.keys() {
      assert(
        field in allowed-fields,
        message: (
          "typed-physics: "
            + declaration.kind
            + " declaration "
            + str(declaration-index + 1)
            + " has unknown field `"
            + field
            + ":`; accepted fields are "
            + allowed-fields.join(", ")
            + ". Use the public constructor to catch misspelled arguments"
        ),
      )
    }
    let missing-fields = _required-fields(declaration.kind).filter(
      field => field not in declaration,
    )
    assert(
      missing-fields.len() == 0,
      message: (
        "typed-physics: malformed "
          + declaration.kind
          + " declaration "
          + str(declaration-index + 1)
          + " is missing "
          + missing-fields.map(field => "`" + field + ":`").join(", ")
          + "; create it with the public "
          + declaration.kind
          + "() constructor"
      ),
    )
    _validate-declaration-local(declaration, declaration-index)
    if _named-kind(declaration.kind) {
      assert(
        declaration.name not in declarations-by-name,
        message: (
          "typed-physics: element name \""
            + declaration.name
            + "\" is declared twice (declarations "
            + str(declaration-index-by-name.at(declaration.name, default: -1) + 1)
            + " and "
            + str(declaration-index + 1)
            + "); rename one element so every reference is unambiguous"
        ),
      )
      declarations-by-name.insert(declaration.name, declaration)
      declaration-index-by-name.insert(declaration.name, declaration-index)
    }
  }

  for (declaration-index, declaration) in declarations.enumerate() {
    for specification in _reference-specifications(declaration) {
      let target-name = attachment-element-name(specification.attachment)
      if _named-kind(declaration.kind) and target-name == declaration.name {
        panic(
          "typed-physics: "
            + specification.source-description
            + " creates a placement dependency cycle by referencing itself in `"
            + specification.argument
            + ":`; reference an earlier, different element",
        )
      }
      if (
        _named-kind(declaration.kind)
          and target-name in declarations-by-name
          and _dependency-reaches(
            target-name,
            declaration.name,
            declarations-by-name,
          )
      ) {
        panic(
          "typed-physics: placement dependency cycle connects \""
            + declaration.name
            + "\" and \""
            + target-name
            + "\"; break the cycle by anchoring one element to an earlier independent element",
        )
      }
      _validate-reference(
        specification,
        declaration-index,
        declarations-by-name,
        declaration-index-by-name,
      )
    }
    _validate-cross-element-compatibility(
      declaration,
      declarations-by-name,
    )
  }
}

#let validate-body-name(scene, name, source-description) = {
  assert(
    type(name) == str,
    message: (
      "typed-physics: "
        + source-description
        + " needs a body name as a string, got "
        + _value(name)
    ),
  )
  assert(
    name in scene.bodies,
    message: (
      "typed-physics: "
        + source-description
        + " names \""
        + name
        + "\", but no such body exists; available bodies are "
        + if scene.body-order.len() == 0 { "(none)" } else {
          scene.body-order.join(", ")
        }
    ),
  )
  none
}
