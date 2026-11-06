// oxifmt v0.2.1

// For compatibility with pre-0.8.0 Typst types, which were strings
#let _int-type = type(0)
#let _float-type = type(5.5)
#let _str-type = type("")
#let _label-type = type(<hello>)
#let _arr-type = type(())

#let _minus-sign = "\u{2212}"
#let using-080 = type(type(5)) != _str-type
#let using-090 = using-080 and str(-1).codepoints().first() == _minus-sign
#let using-0110 = using-090 and sys.version >= version(0, 11, 0)
#let using-0120 = using-090 and sys.version >= version(0, 12, 0)

#let _decimal = if using-0120 { decimal } else { none }

#let _arr-chunks = if using-0110 {
  array.chunks
} else {
  (arr, chunks) => {
    let i = 0
    let res = ()
    for element in arr {
      if i == 0 {
        res.push(())
        i = chunks
      }
      res.last().push(element)
      i -= 1
    }
    res
  }
}

// Splits an array into dynamic chunk sizes.
// 'chunks' is an array e.g. (1, 2, 3) indicating
// the sizes of each chunk. The last size is repeated if there
// are more elements than the chunks combined can cover.
//
// For example, if arr = ("a", "b", "c", "d", "e", "f", "g", "h", "i") and
// chunks = (2, 3), this will return
// (("a", "b"), ("c", "d", "e"), ("f", "g", "h"), ("i",))
#let _arr-dyn-chunks(arr, chunks) = {
  let i = 0
  let res = ()
  let chunk-i = 0
  if chunks == () {
    return ()
  }

  for element in arr {
    if i == 0 {
      res.push(())
      i = chunks.at(chunk-i)
      if i <= 0 {
        assert(false, message: "String formatter error: internal error: received chunk of invalid size")
      }
      if chunk-i + 1 != chunks.len() {
        chunk-i += 1
      }
    }
    res.last().push(element)
    i -= 1
  }
  res
}

#let _float-is-nan = if using-0110 {
  float.is-nan
} else {
  x => type(x) == _float-type and "NaN" in repr(x)
}

#let _float-is-infinite = if using-0110 {
  float.is-infinite
} else {
  x => type(x) == _float-type and "inf" in repr(x)
}

#let _strfmt_formatparser(s) = {
  if type(s) != _str-type {
    panic("String format parsing internal error: String format parser given non-string.")
  }
  let result = ()
  let codepoints = s.codepoints()

  // -- parsing state --
  let current-fmt-span = none
  let current-fmt-name = none
  // if we're at {abc:|, i.e. right after a colon in {}
  let last-was-fmt-colon = false
  // if the last character was an unescaped {
  let last-was-lbracket = false
  // if the last character was an unescaped }
  let last-was-rbracket = false

  // -- procedures --
  let write-format-span(last-i, result, current-fmt-span, current-fmt-name) = {
    current-fmt-span.at(1) = last-i + 1  // end index
    result.push((format: (name: current-fmt-name, span: current-fmt-span)))
    current-fmt-span = none
    current-fmt-name = none
    (result, current-fmt-span, current-fmt-name)
  }

  // -- errors --
  let excessive-lbracket() = {
    panic("String format parsing error: Inserted a second, non-escaped { inside a {format specifier}. Did you forget to insert a } somewhere, or to escape the { with {{?")
  }
  let excessive-rbracket() = {
    panic("String format parsing error: Inserted a stray } (doesn't match any { from before). Did you forget to insert a { somewhere, or to escape the } with }}?")
  }
  let missing-rbracket() = {
    panic("String format parsing error: Reached end of string with an open format specifier {, but without a closing }. Did you forget to insert a right bracket, or to escape the { with {{?")
  }

  // -- parse loop --
  let last-i = none
  let i = 0
  let code-i = 0
  for character in codepoints {
    if character == "{" {
      // double l-bracket = escape
      if last-was-lbracket {
        last-was-lbracket = false  // escape {{
        last-was-rbracket = false
        if current-fmt-span.at(0) == last-i {
          // outside a span ({...} {{ <-) => emit an 'escaped' token
          current-fmt-span = none  // cancel this span
          current-fmt-name = none
          result.push((escape: (escaped: "{", span: (last-i, i + 1))))
        } else {
          panic("String formatter error: internal error: invalid left bracket state")
        }
      } else if current-fmt-span == none {
        // begin span
        current-fmt-span = (i, none)
        current-fmt-name = ""

        // indicate we just started a span
        // in case it is escaped right afterwards
        last-was-lbracket = true
      } else if last-was-fmt-colon and codepoints.len() > code-i + 1 and codepoints.at(code-i + 1) in ("<", "^", ">") {
        // don't error on mid-span { if this { might be used for padding
        // 'escape' it right away
        // e.g. {a:{<5} => formats "bc" as "{{{bc"
        current-fmt-name += character
        last-was-lbracket = false
      } else {
        // if in the middle of a larger span ({ ... { <-):
        // error
        excessive-lbracket()
      }

      last-was-fmt-colon = false
    } else if character == "}" {
      last-was-lbracket = false
      if current-fmt-span == none {
        if last-was-rbracket {
          last-was-rbracket = false  // escape }}
          result.push((escape: (escaped: "}", span: (last-i, i + 1))))
        } else {
          // delay erroring on unmatched } to the next iteration
          // in case this is an escaped }
          last-was-rbracket = true
        }
      } else if last-was-fmt-colon and codepoints.len() > code-i + 1 and codepoints.at(code-i + 1) in ("<", "^", ">") {
        // don't close span with } if this } might be used for padding
        // e.g. {a:}<5} => formats "bc" as "}}}bc"
        current-fmt-name += character
        last-was-rbracket = false
      } else {
        // { ... } <--- ok, close the previous span
        // Do this eagerly, escaping } inside { ... } is invalid
        (result, current-fmt-span, current-fmt-name) = write-format-span(i, result, current-fmt-span, current-fmt-name)
      }

      last-was-fmt-colon = false
    } else {
      if last-was-rbracket {
        if current-fmt-span == none {
          // {...} }A <--- non-escaped } with no matching {
          excessive-rbracket()
        } else {
          // { ... }A <--- span should have been eagerly closed already
          panic("String formatter error: internal error: invalid right bracket state")
        }
      }

      if current-fmt-name == none {
        last-was-fmt-colon = false
      } else {
        // {abc <--- add character to the format name
        current-fmt-name += character
        last-was-fmt-colon = character == ":"
      }
      last-was-lbracket = false
      last-was-rbracket = false
    }

    last-i = i
    i += character.len() // index must be in bytes, and a UTF-8 codepoint can have more than one byte
    code-i += 1
  }
  // { ...
  if current-fmt-span != none {
    if last-was-rbracket {
      // ... } <--- ok, close span
      (result, current-fmt-span, current-fmt-name) = write-format-span(last-i, result, current-fmt-span, current-fmt-name)
      last-was-fmt-colon = false
    } else {
      // {abcd| <--- string ended with unclosed span
      missing-rbracket()
    }
  } else if last-was-rbracket {
    // } <--- unmatched and unescaped } at the very end
    excessive-rbracket()
  }

  result
}

#let _strfmt_parse-fmt-name(name) = {
  // {a:b} => separate 'a' from 'b'
  // (also accepts {a}, {}, {0}, {:...})
  let (name, ..extras) = name.split(":")
  let name = if type(name) != _str-type {
    name
  } else if name == "" {
    none
  } else if name.codepoints().all(x => x == "0" or x == "1" or x == "2" or x == "3" or x == "4" or x == "5" or x == "6" or x == "7" or x == "8" or x == "9") {
    int(name)
  } else {
    name
  }
  (name, extras.join())
}

#let _strfmt_is-numeric-type(obj) = {
  type(obj) in (_int-type, _float-type, _decimal)
}

#let _strfmt_stringify(obj) = {
  if type(obj) == _float-type {
    if _float-is-infinite(obj) {
      // Fix 0.12.0 inf string inconsistency
      if obj < 0 { "-" } else { "" } + "inf"
    } else {
      // Fix negative sign not being a hyphen
      // for consistency with our rich formatting output
      str(obj).replace("\u{2212}", "-")
    }
  } else if type(obj) == _int-type {
    str(obj).replace("\u{2212}", "-")
  } else if type(obj) in (_label-type, _str-type, _decimal) {
    str(obj)
  } else {
    repr(obj)
  }
}

#let _strfmt_display-radix(num, radix, signed: true, lowercase: false) = {
  let num = int(num)
  if type(radix) != _int-type or num == 0 or radix <= 1 {
    return "0"
  }

  // Note: only integers are accepted here, so no need to check for decimal signed zero
  let sign = if num < 0 and signed { "-" } else { "" }
  let num = calc.abs(num)
  let radix = calc.min(radix, 16)
  let digits = if lowercase {
    ("0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f")
  } else {
    ("0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F")
  }
  let result = ""

  while (num > 0) {
    let quot = calc.quo(num, radix)
    let rem = calc.floor(calc.rem(num, radix))
    let digit = digits.at(rem)
    result = digit + result
    num = quot
  }

  sign + result
}

#let _strfmt_with-precision(num, precision) = {
  if precision == none {
    return _strfmt_stringify(num)
  }
  let result = _strfmt_stringify(calc.round(if type(num) == _decimal { num } else { float(num) }, digits: calc.min(50, precision)))
  let digits-match = result.match(regex("^\\d+\\.(\\d+)$"))
  let digits-len-diff = 0
  if digits-match != none and digits-match.captures.len() > 0 {
    // get the digits capture group; its length will be digit amount
    let digits = digits-match.captures.first()
    digits-len-diff = precision - digits.len()
  } else if "." not in result {  // 5.0 or something
    // 0 digits! Difference will be exactly 'precision'
    digits-len-diff = precision
  }

  // add missing zeroes for precision
  if digits-len-diff > 0 {
    if "." not in result {
      result += "."  // decimal separator missing
    }
    result += "0" * digits-len-diff
  }

  result
}

#let _strfmt_exp-format(num, exponent-sign: "e", precision: none) = {
  assert(_strfmt_is-numeric-type(num), message: "String formatter internal error: Cannot convert '" + repr(num) + "' to a number to obtain its scientific notation representation.")

  if type(num) == _decimal {
    // Normalize signed zero
    let num = if num == 0 { _decimal("0") } else { num }
    let (integral, ..fractional) = str(num).split(".")
    // Normalize decimals with larger scales than is needed
    let fractional = fractional.sum(default: "").trim("0", at: end)
    let (integral, fractional, exponent) = if num > -1 and num < 1 and fractional != "" {
      let first-non-zero = fractional.codepoints().position(s => s != "0")
      assert(first-non-zero != none, message: "String formatter internal error: expected non-zero fractional digit")

      // Integral part is zero
      // Convert 0.00012345 -> 1.2345
      // Position of first non-zero is the amount of zeroes - 1
      // (e.g. above, position of 1 is 3 => 3 zeroes,
      // so exponent is -3 - 1 = -4)
      (
        fractional.at(first-non-zero),
        fractional.slice(first-non-zero + 1),
        -first-non-zero - 1
      )
    } else {
      // Number has non-zero integral part, or is zero
      // Convert 12345.6789 -> 1.23456789
      // Exponent is integral digits - 1
      (
        integral.at(0),
        integral.slice(1) + fractional,
        integral.len() - 1
      )
    }
    return (
      // mantissa
      integral + if fractional != "" { "." + fractional } else { "" },
      exponent-sign + _strfmt_stringify(exponent)
    )
  }

  let f = float(num)
  let exponent = if f == 0 { 1 } else { calc.floor(calc.log(calc.abs(f), base: 10)) }
  let mantissa = f / calc.pow(10.0, exponent)
  let mantissa = _strfmt_with-precision(mantissa, precision)

  (mantissa, exponent-sign + _strfmt_stringify(exponent))
}

// Parses {format:specslikethis}.
// Rust's format spec grammar:
/*
format_spec := [[fill]align][sign]['#']['0'][width]['.' precision]type
fill := character
align := '<' | '^' | '>'
sign := '+' | '-'
width := count
precision := count | '*'
type := '' | '?' | 'x?' | 'X?' | identifier
count := parameter | integer
parameter := argument '$'
*/
#let _generate-replacement(
  fullname, extras, replacement,
  pos-replacements: (), named-replacements: (:),
  fmt-decimal-separator: auto,
  fmt-thousands-count: 3,
  fmt-thousands-separator: ""
) = {
  if extras == none {
    let is-numeric = _strfmt_is-numeric-type(replacement)

    if is-numeric {
      let is-nan = type(replacement) == _float-type and _float-is-nan(replacement)
      let is-inf = type(replacement) == _float-type and _float-is-infinite(replacement)
      let string-replacement = _strfmt_stringify(calc.abs(replacement))
      let sign = if (
        not is-nan and replacement < 0
        or replacement == 0 and type(replacement) == _decimal and (
          // Preserve signed zero decimal
          "-" in str(replacement) or _minus-sign in str(replacement)
        )
      ) {
        "-"
      } else {
        ""
      }
      let (integral, ..fractional) = string-replacement.split(".")
      if fmt-thousands-separator != "" and not is-nan and not is-inf {
        let digit-groups = if type(fmt-thousands-count) == _arr-type {
          _arr-dyn-chunks(integral.codepoints().rev(), fmt-thousands-count)
        } else {
          _arr-chunks(integral.codepoints().rev(), fmt-thousands-count)
        }
        integral = digit-groups
          .join(fmt-thousands-separator.codepoints().rev())
          .rev()
          .join()
      }

      if fractional.len() > 0 {
        let decimal-separator = if fmt-decimal-separator not in (auto, none) { _strfmt_stringify(fmt-decimal-separator) } else { "." }
        return sign + integral + decimal-separator + fractional.first()
      } else {
        return sign + integral
      }
    } else {
      return _strfmt_stringify(replacement)
    }
  }
  let extras = _strfmt_stringify(extras)
  // note: usage of [\s\S] in regex to include all characters, incl. newline
  // (dot format ignores newline)
  let extra-parts = extras.match(
    //           fill      align    sign   #   0     width(from param)      width      precision(from param)    precision  spectype
    regex("^(?:([\\s\\S])?([<^>]))?([+-])?(#)?(0)?(?:(?:(\\d+)|([^.$]+))\$|(\\d+))?(?:\\.(?:(?:(\\d+)|([^$]+))\$|(\\d+|\*)))?([^\\s]*)\\s*$")
  )
  if extra-parts == none {
    panic("String formatter error: Invalid format spec '" + extras + "', from '{" + fullname.replace("{", "{{").replace("}", "}}") + "}'. Try escaping the braces { } with {{ }} if you wanted to insert literal braces.")
  }

  let (fill, align, sign, hashtag, zero, width-posarg, width-namedarg, width-lit, precision-posarg, precision-namedarg, precision-lit, spectype) = extra-parts.captures

  // 'count' type parameters in the spec (width, precision) can be either a literal number (123),
  // a number referring to a positional argument (123$), or some text referring to a named argument (abc$).
  // The final $ is mandatory for the last two cases.
  let parse-count(lit, pos, named, spec-part-name: "unknown") = {
    if lit != none {
      int(lit)
    } else if pos != none {
      let i = int(pos)
      assert(
        pos-replacements.len() > 0,
        message: "String formatter error: Attempted to use positional argument " + str(i) + " for " + spec-part-name + ", but no positional arguments were given (from '{" + fullname.replace("{", "{{").replace("}", "}}") + "}')."
      )
      assert(
        i >= 0 and i < pos-replacements.len(),
        message: "String formatter error: Attempted to use positional argument " + str(i) + " for " + spec-part-name + ", but there is no argument at that position (from '{" + fullname.replace("{", "{{").replace("}", "}}") + "}'). Please note that positional arguments start at position 0, and are specified in order after the format string in the 'strfmt' call."
      )
      let arg = pos-replacements.at(i)
      assert(
        type(arg) == _int-type,
        message: "String formatter error: Attempted to use positional argument " + str(i) + " for " + spec-part-name + ", but it was a(n) '" + str(type(arg)) + "', not an integer (from '{" + fullname.replace("{", "{{").replace("}", "}}") + "}')."
      )

      int(arg)
    } else if named != none {
      assert(
        named-replacements.len() > 0,
        message: "String formatter error: Attempted to use named argument '" + named + "' for " + spec-part-name + ", but no named arguments were given (from '{" + fullname.replace("{", "{{").replace("}", "}}") + "}')."
      )
      assert(
        named in named-replacements,
        message: "String formatter error: Attempted to use named argument '" + named + "' for " + spec-part-name + ", but there is no argument associated to that name (from '{" + fullname.replace("{", "{{").replace("}", "}}") + "}'). Ensure you pass that argument in the 'strfmt' call, e.g. strfmt(\"string {:.myarg$}\", 5.823, myarg: 10)."
      )
      let arg = named-replacements.at(named)
      assert(
        type(arg) == _int-type,
        message: "String formatter error: Attempted to use named argument '" + named + "' for " + spec-part-name + ", but it was a(n) '" + str(type(arg)) + "', not an integer (from '{" + fullname.replace("{", "{{").replace("}", "}}") + "}')."
      )

      int(arg)
    } else {
      none
    }
  }

  if precision-lit == "*" {
    panic("String formatter error: Precision specification of type `.*` is not supported yet (from '{" + fullname.replace("{", "{{").replace("}", "}}") + "}'). Try specifying your desired precision directly on the format spec, e.g. `.5`, or through some argument, e.g. `.name$` to take it from the 'name' named argument.")
  }

  let align = if align == "" {
    none
  } else if align == "<" {
    left
  } else if align == ">" {
    right
  } else if align == "^" {
    center
  } else if align != none {
    panic("String formatter error: Invalid alignment in the format spec: '" + align + "' (must be either '<', '^' or '>').")
  }
  let width = parse-count(width-lit, width-posarg, width-namedarg, spec-part-name: "width")
  let width = if width == none { 0 } else { int(width) }
  let precision = parse-count(precision-lit, precision-posarg, precision-namedarg, spec-part-name: "precision")
  let hashtag = hashtag == "#"
  let zero = zero == "0"
  let hashtag-prefix = ""

  let valid-specs = ("", "?", "b", "x", "X", "o", "x?", "X?", "e", "E")
  let spec-error() = {
    panic(
      "String formatter error: Unknown spec type '" + spectype + "', from '{" + fullname.replace("{", "{{").replace("}", "}}") + "}'. Valid options include: '" + valid-specs.join("', '") + "'. Maybe you specified some invalid formatting spec syntax (after the ':'), which can also prompt this error. Check the oxifmt docs for more information.")
  }
  if spectype not in valid-specs {
    spec-error()
  }

  if _strfmt_is-numeric-type(replacement) {
    let is-nan = type(replacement) == _float-type and _float-is-nan(replacement)
    let is-inf = type(replacement) == _float-type and _float-is-infinite(replacement)
    if zero {
      // disable fill, we will be prefixing with zeroes if necessary
      fill = none
    } else if fill == none {
      fill = " "
      zero = false
    }
    // default number alignment to right
    if align == none {
      align = right
    }

    if replacement == 0 and type(replacement) == _decimal {
      // Preserve signed zero.
      if "-" in str(replacement) or _minus-sign in str(replacement) {
        sign = "-"
      } else if sign == "+" {
        sign = "+"
      } else {
        sign = ""
      }
    } else if sign == "+" and not is-nan and replacement >= 0 {
      // if + is specified, + will appear before all numbers >= 0.
      sign = "+"
    } else if not is-nan and replacement < 0 {
      sign = "-"
    } else {
      sign = ""
    }

    // we'll add the sign back later!
    replacement = calc.abs(replacement)

    // Separate integral from fractional parts
    // We'll recompose them later
    let integral = ""
    let fractional = ()
    let exponent-suffix = ""

    if spectype in ("e", "E") and not is-nan and not is-inf {
      let exponent-sign = if spectype == "E" { "E" } else { "e" }
      let (mantissa, exponent) = _strfmt_exp-format(calc.abs(replacement), exponent-sign: exponent-sign, precision: precision)
      (integral, ..fractional) = mantissa.split(".")
      exponent-suffix = exponent
    } else if type(replacement) != _int-type and precision != none and not is-nan and not is-inf {
      let new-replacement = _strfmt_with-precision(replacement, precision)
      (integral, ..fractional) = new-replacement.split(".")
    } else if type(replacement) == _int-type and spectype in ("x", "X", "b", "o", "x?", "X?") {
      let radix-map = (x: 16, X: 16, "x?": 16, "X?": 16, b: 2, o: 8)
      let radix = radix-map.at(spectype)
      let lowercase = spectype.starts-with("x")
      integral = _strfmt_stringify(_strfmt_display-radix(replacement, radix, lowercase: lowercase, signed: false))
      if hashtag {
        let hashtag-prefix-map = ("16": "0x", "2": "0b", "8": "0o")
        hashtag-prefix = hashtag-prefix-map.at(str(radix))
      }
    } else {
      precision = none
      let new-replacement = if spectype.ends-with("?") {
        let repr-res = repr(replacement)
        if using-090 and not using-0110 and type(replacement) == _float-type and "." not in repr-res {
          // Workaround for repr inconsistency in Typst 0.9.0 and 0.10.0
          repr-res + ".0"
        } else {
          repr-res
        }
      } else {
        _strfmt_stringify(replacement)
      }
      (integral, ..fractional) = new-replacement.split(".")
    }

    let decimal-separator = if fmt-decimal-separator not in (auto, none) { _strfmt_stringify(fmt-decimal-separator) } else { "." }
    let replaced-fractional = if fractional.len() > 0 { decimal-separator + fractional.join(decimal-separator) } else { "" }
    let exponent-suffix = exponent-suffix.replace(".", decimal-separator)

    if zero {
      let width-diff = width - (integral.len() + replaced-fractional.codepoints().len() + sign.len() + hashtag-prefix.len() + exponent-suffix.codepoints().len())
      if width-diff > 0 {  // prefix with the appropriate amount of zeroes
        integral = ("0" * width-diff) + integral
      }
    }

    // Format with thousands AFTER zeroes, but BEFORE applying textual prefixes
    if fmt-thousands-separator != "" and not is-nan and not is-inf {
      let digit-groups = if type(fmt-thousands-count) == _arr-type {
        _arr-dyn-chunks(integral.codepoints().rev(), fmt-thousands-count)
      } else {
        _arr-chunks(integral.codepoints().rev(), fmt-thousands-count)
      }
      integral = digit-groups
        .join(fmt-thousands-separator.codepoints().rev())
        .rev()
        .join()
    }

    replacement = integral + replaced-fractional + exponent-suffix
  } else {
    sign = ""
    hashtag-prefix = ""
    hashtag = false
    zero = false
    replacement = if spectype.ends-with("?") {
      repr(replacement)
    } else {
      _strfmt_stringify(replacement)
    }
    if fill == none {
      fill = " "
    }
    if align == none {
      align = left
    }
    if precision != none and replacement.len() > precision {
      replacement = replacement.slice(0, precision)
    }
  }

  // use number prefixes parsed above
  replacement = sign + hashtag-prefix + replacement

  if fill != none {
    // perform fill/width adjustments: "x" ---> "  x" if width is 4
    let width-diff = width - replacement.codepoints().len()  // number prefixes are also considered for width
    if width-diff > 0 {
      if align == left {
        replacement = replacement + (fill * width-diff)
      } else if align == right {
        replacement = (fill * width-diff) + replacement
      } else if align == center {
        let half-width = calc.quo(width-diff, 2)
        let left-fill = fill * half-width // floor div
        let right-fill = fill * (half-width + calc.rem(width-diff, 2)) // ceil div (if adding odd fill, add 1 to the right)
        replacement = left-fill + replacement + right-fill
      }
    }
  }

  replacement
}

#let strfmt(
  format,
  ..replacements,
  fmt-decimal-separator: auto,
  fmt-thousands-count: 3,
  fmt-thousands-separator: "",
) = {
  if format == "" { return "" }
  let formats = _strfmt_formatparser(format)
  let num-replacements = replacements.pos()
  let named-replacements = replacements.named()
  let unnamed-format-index = 0

  if fmt-decimal-separator != auto and type(fmt-decimal-separator) != _str-type {
    assert(
      false,
      message: "String formatter error: 'fmt-decimal-separator' must be a string or 'auto', got '" + str(type(fmt-decimal-separator)) + "' instead."
    )
  }

  if type(fmt-thousands-count) == _arr-type {
    assert(
      fmt-thousands-count.all(c => type(c) == _int-type and c > 0),
      message: "String formatter error: 'fmt-thousands-count' must be a positive integer or array of positive integers, got an array with at least one element that isn't a positive integer."
    )
    assert(fmt-thousands-count != (), message: "String formatter error: 'fmt-thousands-count' must not be an empty array, but an array of positive integers.")
  } else if type(fmt-thousands-count) == _int-type {
    if fmt-thousands-count <= 0 {
      assert(
        false,
        message: "String formatter error: 'fmt-thousands-count' must be a positive integer, got " + str(fmt-thousands-count) + " instead."
      )
    }
  } else {
    assert(
      false,
      message: "String formatter error: 'fmt-thousands-count' must be a positive integer or array of positive integers, got '" + str(type(fmt-thousands-count)) + "' instead."
    )
  }

  if type(fmt-thousands-separator) != _str-type {
    assert(
      false,
      message: "String formatter error: 'fmt-thousands-separator' must be a string (or empty string, \"\", to disable), got '" + str(type(fmt-thousands-separator)) + "' instead."
    )
  }

  for (name, _) in named-replacements {
    if name.starts-with("fmt-") {
      assert(false, message: "String formatter error: unknown format option '" + name + "'. Keys prefixed with 'fmt-' are reserved for future oxifmt options. Please use a different key name.")
    }
  }

  let parts = ()
  let last-span-end = 0
  for f in formats {
    let replace-by = none
    let replace-span = none
    if "escape" in f {
      replace-by = f.escape.escaped
      replace-span = f.escape.span
    } else if "format" in f {
      let f = f.format
      let (name, extras) = _strfmt_parse-fmt-name(f.name)
      if name == none {
        let fmt-index = unnamed-format-index
        let amount-pos-replacements = num-replacements.len()
        if amount-pos-replacements == 0 {
          panic("String formatter error: Specified a {} (or similar) format to extract positional replacements, but none were given. Try specifying them sequentially after the format string, e.g. strfmt(\"{}, {}\", 5, 1+1) would become \"5, 2\".")
        }
        if amount-pos-replacements <= fmt-index {
          let were-was = if amount-pos-replacements == 1 { "was" } else { "were" }
          panic("String formatter error: Specified more {} (or similar) formats than positional replacements (only " + str(amount-pos-replacements) + " of them " + were-was + " given!). Please specify the missing positional arguments sequentially after the format string in the 'strfmt' call.")
        }
        replace-by = num-replacements.at(fmt-index)
        unnamed-format-index += 1
      } else if type(name) == _int-type {
        let fmt-index = name
        let amount-pos-replacements = num-replacements.len()
        if amount-pos-replacements == 0 {
          panic("String formatter error: format key '" + str(name) + "' would attempt to get a positional replacement, but none were given after the string. Try specifying positional replacements after the format string in the 'strfmt' call, e.g. strfmt(\"{1}, {0}\", 2, 3) would become \"3, 2\".")
        }
        if amount-pos-replacements <= fmt-index {
          let were-was = if amount-pos-replacements == 1 { "was" } else { "were" }
          panic("String formatter error: format key '" + str(name) + "', from '{" + f.name.replace("{", "{{").replace("}", "}}") + "}', is not a valid positional replacement position (only " + str(amount-pos-replacements) + " of them " + were-was + " given). Note that the first position is 0. For example, strfmt(\"{1}, {0}\", 2, 3) would become \"3, 2\".")
        }
        replace-by = num-replacements.at(fmt-index)
      } else {  // named replacement
        if name not in named-replacements {
          panic("String formatter error: format key '" + name + "', from '{" + f.name.replace("{", "{{").replace("}", "}}") + "}', does not match any given named replacement. Try specifying it after the format string, e.g. like so: strfmt(\"Test: {myarg}\", myarg: 1 + 1) would become \"Test: 2\".")
        }
        replace-by = named-replacements.at(name)
      }
      replace-by = _generate-replacement(f.name, extras, replace-by, pos-replacements: num-replacements, named-replacements: named-replacements, fmt-decimal-separator: fmt-decimal-separator, fmt-thousands-count: fmt-thousands-count, fmt-thousands-separator: fmt-thousands-separator)
      replace-span = f.span
    } else {
      panic("String formatter error: Internal error (unexpected format received).")
    }
    // {...}ABCABCABC{...}  <--- push ABCABCABC to parts
    parts.push(format.slice(last-span-end, replace-span.at(0)))
    // push the replacement string instead of the {...} at the end
    parts.push(replace-by)
    last-span-end = replace-span.at(1)
  }
  if last-span-end < format.len() {
    parts.push(format.slice(last-span-end, format.len()))
  }

  // join all the string parts (constant parts + formatted parts + escaped parts)
  parts.join()
}
