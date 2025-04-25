#import "utility.typ"

/// Converts a content value into a string if it contains only text nodes. 
/// Otherwise, `none` is returned. 
#let content-to-string(x) = {
  if x.has("text") { return x.text }
  if x.has("children") and x.children.len() != 0 and x.children.all(x => x.has("text")) {
    return x.children.map(x => x.text).join()
  }
  return none
}

#assert.eq(content-to-string([123]), "123")
#assert.eq(content-to-string([123 231.]), "123 231.")
#assert.eq(content-to-string([123] + [34]), "12334")
#assert.eq(content-to-string([a $a$]), none)


/// Converts a content value into a string if it contains only text nodes. 
/// Otherwise, `none` is returned. 
#let content-to-string-table(x) = {
  let prefix = none
  let suffix = none
  if x.has("text") { return (x.text, prefix, suffix) }
  if x.has("children") and x.children.len() != 0 {
    if x.children.all(x => x.has("text")){
      return (x.children.map(x => x.text).join(), prefix, suffix)
    }
    let main = none
    for child in x.children {
      if child.has("text") { main += child.text }
      else if child.func() == highlight {
        if main == none { prefix = child.body }
        else { suffix = child.body }
      }
      else { return none }
    }
    return (main, prefix, suffix)
  }
  return none
}

#let nonum = highlight
#assert.eq(content-to-string-table[alpha ], none)
#assert.eq(content-to-string-table[#nonum[€]12], ("12", [€], none))
#assert.eq(content-to-string-table[#nonum[€]12.43#nonum[#footnote[1]]], ("12.43", [€], footnote[1]))

/// Converts a number into a string if the input is either
/// - an integer or a float,
/// - a string,
/// - or a content value that contains only text nodes but does not start 
///   or end with a space. 
/// In case of a failure, `none` is returned. 
/// The output is normalized, meaning that both decimals separators "," and 
/// "." are unified to "." and the minus symbol "−" is replaced by the 
/// ASCII "-" character. 
#let number-to-string(number) = {
  let result
  if type(number) == str { result = number }
  else if type(number) in (int, float) { result = str(number) }
  else if type(number) == content  { result = content-to-string(number) } 
  else { result = none }
  if result == none { return none }
  return result.replace(",", ".").replace("−", "-")
}

#let number-to-string-table(number) = {
  let result
  if type(number) == str { result = number }
  else if type(number) in (int, float) { result = str(number) }
  else if type(number) == content  { result = content-to-string-table(number) } 
  else { result = none }
  if result == none { return none }
  if type(result) != array { result = (result, none, none) }
  result.at(0) = result.at(0).replace(",", ".").replace("−", "-")
  if result.len() == 0 or result.at(0).at(0) not in "0123456789+-." { 
    return none
  }
  return result
}

#assert.eq(number-to-string("123"), "123")
#assert.eq(number-to-string("-2.0"), "-2.0")
#assert.eq(number-to-string("−" + "2,0"), "-2.0")
#assert.eq(number-to-string[2], "2")
#assert.eq(number-to-string[-2.1], "-2.1")
#assert.eq(number-to-string[-2.], "-2.")
#assert.eq(number-to-string[2.], "2.")
#assert.eq(number-to-string[-.1], "-.1")
#assert.eq(number-to-string(100), "100")
#assert.eq(number-to-string(-101.24), "-101.24")

// unparsable inputs
#assert.eq(number-to-string[], none)
#assert.eq(number-to-string[$a + b$], none)
#assert.eq(number-to-string[2 ], none)
#assert.eq(number-to-string[ 2], none)
#assert.eq(number-to-string[ 2343.23 ], none)
#assert.eq(str(sym.plus), "+")



/// Decomposes a string representing an unsigned floating point into
/// integer and fractional part. If either part is not present, it is
/// returned as an empty string. Returns `(integer, fractional)`.
/// Expects a normalized input string (see @number-to-string).
///
/// *Example:*
/// #example(`decompose-unsigned-float-string("9.81")`
#let decompose-unsigned-float-string(x) = {
  let components = x.split(".")
  if components.len() == 1 { components.push("") }
  else if components.len() > 2 {assert(false, message: "weird number `" + x + "`")}
  components
}

#assert.eq(decompose-unsigned-float-string("23.2"), ("23", "2"))
#assert.eq(decompose-unsigned-float-string("23."), ("23", ""))
#assert.eq(decompose-unsigned-float-string("23"), ("23", ""))
#assert.eq(decompose-unsigned-float-string(".34"), ("", "34"))



/// Decomposes a string representing a (possibly signed) floating point 
/// into integer and fractional part. If either part is not present, it 
/// is returned as an empty string. Returns `(sign, integer, fractional)` 
/// where the sign is either `"+"` or `"-"`. 
/// Expects a normalized input string (see @number-to-string).
///
/// *Example:*
/// #example(`decompose-signed-float-string("-9.81")`
#let decompose-signed-float-string(x) = {
  let sign = "+"
  if x.starts-with("-") {
    sign = "-"
    x = x.slice(1)
  } else if x.starts-with("+") { x = x.slice(1) }
  return (sign, ) + decompose-unsigned-float-string(x)
}

#assert.eq(decompose-signed-float-string("23.2"), ("+", "23", "2"))
#assert.eq(decompose-signed-float-string("+23."), ("+", "23", ""))
#assert.eq(decompose-signed-float-string("-23"), ("-", "23", ""))
#assert.eq(decompose-signed-float-string("-.34"), ("-", "", "34"))
#assert.eq(decompose-signed-float-string(sym.plus + ".34"), ("+", "", "34"))



/// Decomposes a normalized number string into sign, integer, fractional,
/// uncertainty and exponent. Here, normalized means that the decimal separator
/// is `"."`, and `"+"`, `"-"` is used for all signs (as opposed to 
/// `"−"`). 
///
/// Sign, integer and fractional part are guaranteed to be valid (however, 
/// the latter two may be empty strings) while the uncertainty and the 
/// exponent may be none if not present. 
///
///
/// *Example:*
/// #example(`decompose-normalized-number-string("-10.2+-.3e3")`)
#let decompose-normalized-number-string(x) = {
  let original-number = x
  let e
  let pm
  let sign = "+"
  if "e" in x {
    let components = x.split("e")
    if components.len() > 2 { 
      assert(false, message: "Error while parsing `" + original-number + "`: Asymmetric uncertainties must be specified on both sides")
    }
    (x, e) = components
  }
  if x.starts-with("-") {
    sign = "-"
    x = x.slice(1)
  } else if x.starts-with("+") { x = x.slice(1) }

  let normalize-pm = false
  let pm-count = int("+" in x) + int("-" in x)
  if pm-count == 2 {
    if "+-" in x { (x, pm) = x.split("+-") }
    else {
      let p
      let m
      (x, m) = x.split("-")
      assert("+" in x, message: "Error while parsing `" + original-number + "`: Asymmetric uncertainties must start with the positive component")
      (x, p) = x.split("+")
      pm = (p, m)
    }
  } else if pm-count == 1 {
    assert(false, message: "Error while parsing `" + original-number + "`: Asymmetric uncertainties must be specified on both sides")
  } else if "(" in x {
    (x, pm) = x.split("(")
    assert(pm.ends-with(")"), message: "Error while parsing `" + original-number + "`: Unclosed parenthesized uncertainty")
    pm = pm.trim(")")
    normalize-pm = true
  }
  let (integer, fractional) = decompose-unsigned-float-string(x)
  if pm != none {
    if type(pm) == array {
      pm = pm.map(decompose-unsigned-float-string)
    } else {
      pm = decompose-unsigned-float-string(pm)
    }
    
    if normalize-pm {
      pm = utility.shift-decimal-left(..pm, fractional.len())
    }
  }
  return (int: integer, frac: fractional, sign: sign, pm: pm, e: e)
}


#assert.eq(
  decompose-normalized-number-string("-10e3"), 
  (sign: "-", int: "10", frac: "", pm: none, e: "3")
)
#assert.eq(
  decompose-normalized-number-string("+2.4+-0.1"), 
  (sign: "+", int: "2", frac: "4", pm: ("0", "1"), e: none)
)
#assert.eq(
  decompose-normalized-number-string("+.4+0.1-0.2e-10"), 
  (sign: "+", int: "", frac: "4", pm: (("0", "1"), ("0", "2")), e: "-10")
)
#assert.eq(
  decompose-normalized-number-string(".4(2)"), 
  (sign: "+", int: "", frac: "4", pm: ("", "2"), e: none)
)
#assert.eq(
  decompose-normalized-number-string(".4333(2)"), 
  (sign: "+", int: "", frac: "4333", pm: ("", "0002"), e: none)
)
#assert.eq(
  decompose-normalized-number-string(".4333(200)"), 
  (sign: "+", int: "", frac: "4333", pm: ("", "0200"), e: none)
)
#assert.eq(
  decompose-normalized-number-string(".43(200)"), 
  (sign: "+", int: "", frac: "43", pm: ("2", "00"), e: none)
)
#assert.eq(
  decompose-normalized-number-string("2(2)"), 
  (sign: "+", int: "2", frac: "", pm: ("2", ""), e: none)
)
#assert.eq(
  decompose-normalized-number-string("2.3(2.9)"), 
  (sign: "+", int: "2", frac: "3", pm: ("", "29"), e: none)
)
