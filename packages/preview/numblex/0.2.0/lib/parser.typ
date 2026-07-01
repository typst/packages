#import "model.typ": ord, match_ord, ord_mod, const, match_const

/// -> (condition, element)
#let parse_case(s) = {
  assert(type(s) == str)
  let cond = (..args) => true
  if ":" in s {
    let (_s, cond_str) = s.split(":")
    s = _s
    cond = (..args) => eval(
      cond_str,
      mode: "code",
      scope: (
        d: args.named().depth,
        depth: args.named().depth,
      ),
    )
  }
  if regex("\[.*\]") in s {
    // Ordinal
    let ORD_PATTERN = regex("\[([^]]*)\]")
    let ord_str_arr = s.matches(ORD_PATTERN).map(x => x.captures.at(0))
    assert(
      ord_str_arr.len() == 1,
      message: "Case should have exactly one ordinal",
    )
    let ord_str = ord_str_arr.at(0)
    let res = ord(ord_str)
    let (pre, suf) = s.split(ORD_PATTERN)
    res = ord_mod(res, prefix: pre, suffix: suf)
    return (cond, res)
  }
  return (cond, const(s))
}

/// "{xxx}"
/// "xxx" -> element
#let parse_element(s) = {
  assert(type(s) == str)
  let cases = s.split(";").map(parse_case)
  assert(cases.len() > 0, message: "Element should have at least one case")
  if cases.at(0).at(1).type == "ord" {
    return match_ord(..cases)
  }
  return match_const(..cases)
}

/// Parse a string into a list of elements
#let parser(s) = {
  assert(type(s) == str)
  let res = ()
  // Ohno this is not supported
  // `let elements = s.matches(regex("(?<!\\)\{([^{}]*)\}"))`
  // TODO: support `\{` quoting
  let elements = s.matches(regex("\{([^{}]*)\}")).map(x => x.captures.at(0)).map(parse_element)
  return elements
}