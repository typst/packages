#import "parser/lib.typ" as parser
#import "render.typ"

/// Parse and render an atomic state.
///
/// ```example
/// $ #atostate("[He] 2s2.2p4.(3P).3s.(2P).np:1P*") $
/// ```
///
/// ```example
/// $
///   #atostate(
///     "[Kr] 4d10.5s2.(2P<3/2>*).6s:2[3/2]*",
///     parity-marker: circle(
///       radius: 0.2em,
///       fill: red,
///     ),
///     display-single-occupation: true,
///   )
/// $
/// ```
/// -> content
#let atostate(
  /// The atomic state to render.
  /// -> str
  state,
  /// The symbol to use to indicate that a term has odd parity.
  /// -> str | content
  parity-marker: sym.circle.tiny,
  /// Whether to display the occupation number of an orbital that only has one electron.
  /// -> bool
  display-single-occupation: false
) = {
  assert(state.len() > 0, message: "can't render empty string")

  let ast = parser.state(state)
  render.state(ast, parity-marker, display-single-occupation)
}

/// Parse and render a single term symbol.
///
/// ```example
/// $ #atoterm("2P<3/2>*") $
/// ```
///
/// ```example
/// $
///   #atoterm(
///     "2[3/2]*",
///     parity-marker: "#",
///   )
/// $
/// ```
///
/// -> content
#let atoterm(
  /// The term symbol to render.
  /// -> str
  term,
  /// The symbol to use to indicate that the term has odd parity.
  /// -> str | content
  parity-marker: sym.circle.tiny
) = {
  assert(term.len() > 0, message: "can't render empty string")

  let (_, ast) = parser.term-symbol(term)
  render.term-symbol(ast, parity-marker)
}
