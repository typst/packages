#import "../util/utils.typ": rawc
#import "../core/themes.typ": themable

// TODO: (jneug) shorten values if they are large dicts / modules
/// Shows #arg[value] as content.
/// - #ex(`#value("string")`)
/// - #ex(`#value([string])`)
/// - #ex(`#value(true)`)
/// - #ex(`#value(1.0)`)
/// - #ex(`#value(3em)`)
/// - #ex(`#value(50%)`)
/// - #ex(`#value(left)`)
/// - #ex(`#value((a: 1, b: 2))`)
///
/// -> content
#let value(
  /// - Value to show.
  /// -> any
  value,
  /// If #value(true), parses strings as type names.
  /// -> boolean
  parse-str: false,
) = {
  if parse-str and type(value) == str {
    themable(theme => rawc(theme.values.default, value))
  } else {
    themable(theme => rawc(theme.values.default, std.repr(value)))
  }
}

#let _v = value


/// Highlights the default value of a set of #cmd[choices].
/// - #ex(`#default("default-value")`)
/// - #ex(`#default(true)`)
///
/// -> content
#let default(
  /// The value to highlight.
  /// -> any
  value,
  /// If #value(true), parses strings as type names.
  /// -> boolean
  parse-str: true,
) = {
  themable(theme => underline(_v(value, parse-str: parse-str), offset: 0.2em, stroke: .8pt + theme.values.default))
}
#let _d = default


/// Shows a list of choices possible for an argument.
///
/// If #arg[default] is set to something else than #value("__none__"), the value
/// is highlighted as the default choice. If #arg[default] is already present in
/// #arg[values] the value is highlighted at its current position. Otherwise
/// #arg[default] is added as the first choice in the list.
/// // - #ex(`#choices(left, right, center)`)
/// // - #ex(`#choices(left, right, center, default:center)`)
/// // - #ex(`#choices(left, right, default:center)`)
/// // - #ex(`#arg(align: choices(left, right, default:center))`)
/// -> content
#let choices(
  /// The default value to highlight.
  /// -> any
  default: "__none__",
  /// Seperator between choices.
  /// -> content
  sep: sym.bar.v,
  /// Values to choose from.
  /// -> any
  ..values,
) = {
  let list = values.pos().map(_v)
  if default != "__none__" {
    if default in values.pos() {
      let pos = values.pos().position(v => v == default)
      list.at(pos) = _d(default)
    } else {
      list.insert(0, _d(default))
    }
  }
  list.join(box(inset: (left: 1pt, right: 1pt), sep))
}
