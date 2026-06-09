#let p = plugin("kuddle.wasm")
#import "type_modifications.typ": apply-typst
#import "transformations.typ"



// access to plugin methods

/// typed version of kdl parser
#let parse-kdl(s) = cbor(p.parse_doc(bytes(s)))

/// typeless version of kdl parser
#let parse-kdl-typeless(s) = cbor(p.parse_doc_typeless(bytes(s)))

/// shortend typeless version of kdl parser
/// 
/// WARNING
/// This version does not behave according to the specifications. It seperates
/// arguments and properties - i.e. multiplicity and order is not available.
#let parse-kdl-short(s) = cbor(p.parse_doc_short(bytes(s)))


// modification of the results for ease of use

/// typst typed version of kdl parser
/// 
/// This function automatically tries to adjust the types of the result to adhere to
/// their typst version. Currently, only parsing of (typst), (typ) rules is possible.
#let parse-kdl-typst(s) = apply-typst(parse-kdl(s))

/// typst typed and shortened version of kdl parser
/// 
/// WARNING
/// This version does not behave according to the specifications. It seperates
/// arguments and properties - i.e. multiplicity and order is not available.
#let parse-kdl-typst-short(s) = transformations.shorten(parse-kdl-typst(s))

/// typst typed, shortened and collapsed version of kdl parser
/// 
/// WARNING
/// This version does not behave according to the specifications. It separates
/// arguments and properties - i.e. multiplicity and order is not available.
#let parse-kdl-typst-collapsed(s) = transformations.collapse(parse-kdl-typst-short(s))

/// typst typed, shortened, collapsed and minimalized version of kdl parser
/// 
/// WARNING
/// This version does not behave according to the specifications. It merges
/// arguments, properties and child nodes together - i.e. multiplicity and
/// order is not available.
#let parse-kdl-typst-minimal(s) = transformations.minimalize(parse-kdl-typst-collapsed(s))