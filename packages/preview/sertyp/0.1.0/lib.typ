#import "utils.typ" as utils
#import "test.typ" as test;

#import "types/generic.typ" as generic;
#import generic: serialize, deserialize;

/// Serializes mostly any typst value into a string which may be used to communicate cross WASM boundary.
/// Contrary to the string produced by `repr` this representation stores more type information an is less ambiguous.
/// Args:
/// v (any): The value to serialize.
/// 
/// Returns:
/// (str): The serialized representation of the value.
/// 
/// Example:
/// ```typst
/// #import "@preview/sertyp:0.1.0";
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
  return generic.serialize(v);
};

/// Deserializes a value from its serialized representation.
/// Args:
/// s (str): The serialized representation of the value.
/// 
/// Returns:
/// (any): The deserialized value.
/// 
/// Note:
/// The deserialization framework makes heavy use of typst built-in `eval` function and may thus lead to security issues if used with untrusted input.
/// Use with caution.
#let deserialize(s) = {
  return generic.deserialize(eval(s));
};