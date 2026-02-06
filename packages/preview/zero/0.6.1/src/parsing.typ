#import "utility.typ"

/// Converts a content value into a string if it contains only text nodes.
/// Otherwise, `none` is returned.
/// -> str | none
#let content-to-string(
  /// -> content
  body,
) = {
  if body.has("text") {
    return body.text
  }

  if (
    body.has("children")
      and body.children.len() != 0
      and body.children.all(child => child.has("text"))
  ) {
    body.children.map(child => child.text).join()
  }
}



/// Same as @content-to-string but also extract special prefix and suffix elements.
/// Returns `none`, if the content does not only contain text nodes and a tuple
/// `(text: str, prefix: content, suffix: content)` otherwise
#let content-to-string-table(body) = {
  if body.has("text") {
    return (body.text, none, none)
  }

  if body.has("children") and body.children.len() != 0 {
    if body.children.all(child => child.has("text")) {
      return (body.children.map(child => child.text).join(), none, none)
    }

    let main = none
    let prefix = none
    let suffix = none
    for child in body.children {
      if child.has("text") { main += child.text } else if (
        child.func() == highlight
      ) {
        if main == none { prefix = child.body } else { suffix = child.body }
      } else { return none }
    }
    return (main, prefix, suffix)
  }
}


/// The nonum element makes it possible to add _protected_ content before and
/// after a numeral in a table cell.
#let nonum = highlight



/// Converts the input into a numeral string if the input is of type `int`,
/// `float`, `str`, or `content` that contains only text nodes but does not
/// start or end with a space.
///
/// In case of a conversion failure, `none` is returned.
///
/// The output is normalized, meaning that both decimals separators "," and
/// "." are unified to "." and the minus symbol "−" is replaced by the
/// ASCII "-" character.
///
/// -> str | none
#let to-normalized-numeral(
  /// The input
  /// -> int | float | str | content
  number,
) = {
  let result = if type(number) == str {
    number
  } else if type(number) in (int, float) {
    str(number)
  } else if type(number) == content {
    content-to-string(number)
  }

  if result in (none, "") { return none }

  result.replace(",", ".").replace("−", "-")
}


/// Same as @to-normalized-numeral but for table cell contents.
#let to-normalized-numeral-table(number) = {
  let result = if type(number) == str {
    number
  } else if type(number) in (int, float) {
    str(number)
  } else if type(number) == content {
    content-to-string-table(number)
  }
  if result == none { return none }

  if type(result) != array {
    result = (result, none, none)
  }

  if result.at(0) == "" { return none }

  result.at(0) = result.at(0).replace(",", ".").replace("−", "-")

  if result.len() == 0 or result.at(0).at(0) not in "0123456789+-." {
    return none
  }

  result
}




/// Decomposes a string representing an unsigned floating point into
/// integer and fractional part. If either part is not present, it is
/// returned as an empty string. Returns `(integer, fractional)`.
/// Expects a normalized input string (see @number-to-string).
///
/// *Example:*
/// #example(`decompose-unsigned-float-numeral("9.81")`
///
/// -> (str, str)
#let decompose-unsigned-float-numeral(
  /// The numeral to decompose.
  /// -> str
  numeral,
) = {
  let components = numeral.split(".")
  if components.len() == 1 {
    components.push("")
  } else if components.len() > 2 {
    assert(false, message: "unparsable number `" + numeral + "`")
  }
  components
}




/// Decomposes a string representing a (possibly signed) floating point
/// into integer and fractional part. If either part is not present, it
/// is returned as an empty string. Returns `(sign, integer, fractional)`
/// where the sign is either `"+"` or `"-"`.
/// Expects a normalized input string (see @number-to-string).
///
/// *Example:*
/// #example(`decompose-signed-float-numeral("-9.81")`
///
/// -> ("+" | "-", str, str)
#let decompose-signed-float-numeral(
  /// The numeral to decompose.
  /// -> str
  numeral,
) = {
  let sign = "+"
  if numeral.starts-with("-") {
    sign = "-"
    numeral = numeral.slice(1)
  } else if numeral.starts-with("+") {
    numeral = numeral.slice(1)
  }

  (sign,) + decompose-unsigned-float-numeral(numeral)
}



/// Parses a normalized compound numeral string into sign, integer,
/// fractional, uncertainty and exponent.
///
/// Here, normalized means that the decimal separator/// is `"."`, and
/// `"+"`, `"-"` is used for all signs (as opposed to `"−"`).
///
/// Sign, integer and fractional part are guaranteed to be valid (however,
/// the latter two may be empty strings) while the uncertainty and the
/// exponent may be none if not present.
///
///
/// *Example:*
/// #example(`parse-normalized-compound-numeral("-10.2+-.3e3")`)
///
/// -> (int: str, frac: str, sign: str, pm: array | str, e: str)
#let parse-normalized-compound-numeral(numeral) = {
  let original-numeral = numeral
  let e
  let pm
  let sign = "+"
  if "e" in numeral {
    let components = numeral.split("e")
    if components.len() > 2 {
      assert(
        false,
        message: "Error while parsing `"
          + original-numeral
          + "`: Asymmetric uncertainties must be specified on both sides",
      )
    }
    (numeral, e) = components
  }
  if numeral.starts-with("-") {
    sign = "-"
    numeral = numeral.slice(1)
  } else if numeral.starts-with("+") { numeral = numeral.slice(1) }

  let normalize-pm = false
  let pm-count = int("+" in numeral) + int("-" in numeral)
  if pm-count == 2 {
    if "+-" in numeral { (numeral, pm) = numeral.split("+-") } else {
      let p
      let m
      (numeral, m) = numeral.split("-")
      assert(
        "+" in numeral,
        message: "Error while parsing `"
          + original-numeral
          + "`: Asymmetric uncertainties must start with the positive component",
      )
      (numeral, p) = numeral.split("+")
      pm = (p, m)
    }
  } else if pm-count == 1 {
    assert(
      false,
      message: "Error while parsing `"
        + original-numeral
        + "`: Asymmetric uncertainties must be specified on both sides",
    )
  } else if "(" in numeral {
    (numeral, pm) = numeral.split("(")
    assert(
      pm.ends-with(")"),
      message: "Error while parsing `"
        + original-numeral
        + "`: Unclosed parenthesized uncertainty",
    )
    pm = pm.trim(")")
    normalize-pm = true
  }
  let (integer, fractional) = decompose-unsigned-float-numeral(numeral)
  if pm != none {
    if type(pm) == array {
      pm = pm.map(decompose-unsigned-float-numeral)
    } else {
      pm = decompose-unsigned-float-numeral(pm)
    }

    if normalize-pm {
      pm = utility.shift-decimal-left(..pm, digits: fractional.len())
    }
  }
  if integer == "" {
    integer = "0"
  }

  (int: integer, frac: fractional, sign: sign, pm: pm, e: e)
}




/// Like @parse-normalized-compound-numeral but also normalizes the input.
#let parse-numeral(numeral) = {
  let numeral = to-normalized-numeral(numeral)
  if numeral == none {
    assert(false, message: "Cannot parse the number `" + repr(it.number) + "`")
  }
  parse-normalized-compound-numeral(numeral)
}


#let compute-sci-digits(num-info) = {
  let integer = num-info.int
  let fractional = num-info.frac
  let e = if num-info.e == none { 0 } else { int(num-info.e) }

  let exponent = 0
  if integer == "0" {
    let leading-zeros = fractional.len() - fractional.trim("0", at: start).len()

    exponent = -leading-zeros - 1
  } else {
    exponent = integer.len() - 1
  }
  exponent + e
}

#let compute-eng-digits(num-info) = {
  calc.floor(compute-sci-digits(num-info) / 3) * 3
}
