#import "utils.typ" as _utils

#let _sizes-inner(body, paged, size) = {
  import "convert.typ": convert-mathml
  import "utils.typ": is-html
  context if is-html() {
    convert-mathml(body, size: size)
  } else {
    paged(body)
  }
}

/// Forced display style in math.
///
/// This is the normal size for block equations.
#let display(
  /// The content to size
  /// -> content
  body,
) = _sizes-inner(body, math.display, "display")

/// Forced inline (text) style in math.
///
/// This is the normal size for inline equations.
#let inline(
  /// The content to size
  /// -> content
  body,
) = _sizes-inner(body, math.inline, "text")

/// Forced script style in math.
///
/// This is the smaller size used in powers or sub- or superscripts.
#let script(
  /// The content to size
  /// -> content
  body,
) = _sizes-inner(body, math.script, "script")

/// Forced second script style in math.
///
/// This is the smallest size, used in second-level sub- and superscripts (script of the script).
/// Note that this currently is the same as `script` .
#let sscript(
  /// The content to size
  /// -> content
  body,
) = _sizes-inner(body, math.sscript, "script-script")

#let _custom-ty(ident, paged, body, ..args) = {
  assert.eq(args.pos(), ())

  import "utils.typ": is-html
  if is-html(allow-ctx: false) {
    metadata((_utils._type-ident: ident, body: body, ..args.named()))
  } else {
    paged(body)
  }
}

/// Upright (non-italic) font style in math.
#let upright(
  /// The content to style.
  /// -> content
  body,
) = _custom-ty(_utils._dict-types.upright, math.upright, body)

/// Italic font style in math.
/// 
/// For roman letters and greek lowercase letters, this is already the default.
#let italic(
  /// The content to style.
  /// -> content
  body,
) = _custom-ty(_utils._dict-types.italic, math.italic, body)

/// Bold font style in math.
#let bold(
  /// The content to style.
  /// -> content
  body,
) = _custom-ty(_utils._dict-types.bold, math.bold, body)

/// Serif (roman) font style in math.
/// This is already the default.
#let serif(
  /// The content to style.
  /// -> content
  body,
) = _custom-ty(_utils._dict-types.variant, math.serif, body, variant: "serif")

/// Sans-serif font style in math.
#let sans(
  /// The content to style.
  /// -> content
  body,
) = _custom-ty(_utils._dict-types.variant, math.sans, body, variant: "sans")

/// Fraktur font style in math.
#let frak(
  /// The content to style.
  /// -> content
  body
) = _custom-ty(_utils._dict-types.variant, math.frak, body, variant: "frak")

/// Monospace font style in math.
#let mono(
  /// The content to style.
  /// -> content
  body,
) = _custom-ty(_utils._dict-types.variant, math.mono, body, variant: "mono")

/// Blackboard bold (double-struck) font style in math.
///
/// For uppercase latin letters, blackboard bold is additionally available through symbols of the form `NN` and `RR`.
#let bb(
  /// The content to style.
  /// -> content
  body,
) = _custom-ty(_utils._dict-types.variant, math.bb, body, variant: "bb")

/// Calligraphic font style in math.
#let cal(
  /// The content to style.
  /// -> content
  body,
) = _custom-ty(_utils._dict-types.variant, math.cal, body, variant: "cal")

/// dif symbol.
#let dif = [#sym.space.thin #upright(symbol("d"))]
/// Dif symbol.
#let Dif = [#sym.space.thin #upright(symbol("D"))]
