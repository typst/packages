#import "utils.typ": strfmt

/// Create a selector from content, a selector expression, or a matching value.
///
/// This helper is useful for `show` rules that need to target arbitrary
/// content. It accepts strings, existing selectors, functions, regexes,
/// symbols, labels, or content nodes. When passed content, it resolves the
/// content's function and fields so that non-raw math elements can also be
/// targeted.
///
/// -> selector
#let select(
  /// The thing to turn into a selector.
  /// -> content
  element
) = {
  if type(element) in (str, selector, function, regex, symbol, label) {
    return selector(element)
  }

  if type(element) == content {
    // extract the element in math mode.
    if element.func() == math.equation and not element.has("label") {
      element = element.body
    }

    let func = element.func()
    let fields = element.fields()

    return selector(func.where(..fields))
  }

  panic(strfmt("Unresolvable element `{}` for casting to selector.", element))
}
