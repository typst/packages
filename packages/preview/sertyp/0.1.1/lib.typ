#import "utils.typ" as utils;

#import "types/generic.typ" as generic;
#import generic: serializer, deserializer;

/// Reduces most values into a intermediate representation which may for example be used for communication over the WASM boundary using additional CBOR serialization.
/// See `serialize_cbor` and `deserialize_cbor`.
/// 
/// Contrary to the string produced by `repr` or `cbor(cbor.encode(..))` this representation stores more type information an is less ambiguous.
/// Moreover the deserialization produces the actual **displayable** value instead of a representation of it.
/// Args:
/// v (any): The value to serialize.
/// 
/// Returns:
/// (any): The serialized representation of the value.
/// 
/// Example:
/// ```typst
/// #import "@preview/sertyp:0.1.1";
/// #let content = [
///     Total displaced soil by glacial flow:
///     $ 7.32 beta + sum_(i=0)^nabla (Q_i (a_i - epsilon)) / 2 $
///     #metadata(title: "Glacial Flow Calculation")
///     #table(
///         columns: (1fr, auto),
///         inset: 10pt,
///         align: horizon,
///         table.header(
///           [*Volume*], [*Parameters*],
///         ),
///         $ pi h (D^2 - d^2) / 4 $,
///         [
///           $h$: height \
///           $D$: outer radius \
///           $d$: inner radius
///         ],
///         $ sqrt(2) / 12 a^3 $,
///         [$a$: edge length]
///     )
/// ]
/// #let serialized = sertyp.serialize(content);
/// #let deserialized = sertyp.deserialize(serialized);
/// #assert(repr(deserialized) == repr(content));
/// ```
#let serialize(v) = {
  return generic.serializer(v);
};

/// Serializes a value into CBOR format using the intermediate representation.
/// See `serialize`.
/// 
/// The double serilization (first into an intermediate representation and then into CBOR) allows to transmit non ambigous serialized types over the WASM boundary.
/// 
/// Args:
/// v (any): The value to serialize.
/// 
/// Returns:
/// (bytes): The CBOR serialized representation of the value.
/// 
/// Example:
/// ```typst
/// #import "@preview/sertyp:0.1.1";
/// #let plugin = plugin("...");
/// 
/// #let I = $mat(1,0;0,1)$
/// #let It = deserialize_cbor(plugin.transpose(serialize_cbor(I)));
/// #assert(repr(It) == repr($mat(0,1;1,0)$));
/// ```
#let serialize_cbor(v) = {
  return cbor.encode(serialize(v));
};

/// Deserializes a value from its serialized representation.
/// Args:
/// v (any): The serialized representation of the value.
/// 
/// Returns:
/// (any): The deserialized value.
/// 
/// Note:
/// The deserialization framework makes heavy use of typst built-in `eval` function and may thus lead to security issues if used with untrusted input.
/// Use with caution.
#let deserialize(v) = {
  return generic.deserializer(v);
};

/// Deserializes a value from its CBOR serialized representation.
/// See `deserialize` and `serialize_cbor`.
/// 
/// Args:
/// v (bytes): The CBOR serialized representation of the value.
/// 
/// Returns:
/// (any): The deserialized value.
#let deserialize_cbor(v) = {
  return deserialize(cbor(v));
};