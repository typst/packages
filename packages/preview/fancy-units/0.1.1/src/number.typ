#import "content.typ": unwrap-content, find-leaves, wrap-component, wrap-content-math

#let pattern-value = regex("^\(?([+−]?[\d\.]+)")
#let pattern-exponent = regex("\)?[eE]([+−\d\.]+)$")
#let pattern-absolute-uncertainty = regex("\+ ?([\d\.]+)? ?− ?([\d\.]+)")
#let pattern-relative-uncertainty = regex("\((?:(\d+)\:)?(\d+)\)")
#let pattern-decimal-places = regex("^−?\d+(?:\.(\d+))")


// Find the value in the number leaves
//
// - leaves (array)
// -> (dictionary):
//   - leaves (array): Leaves with the value removed
//   - value (dictionary): Value component
#let find-value(leaves) = {
  let match = leaves.at(0).body.match(pattern-value)
  if match == none { panic("Unable to match value in number") }

  let value = match.captures.at(0)
  if match.end == leaves.at(0).body.len() {
    let value = (..leaves.remove(0), body: value)
    return (leaves: leaves, value: value)
  }

  let value = (..leaves.at(0), body: value)
  leaves.at(0).body = leaves.at(0).body.slice(match.end)
  return (leaves: leaves, value: value)
}

// Find the (global) exponent in the number leaves
//
// - leaves (array)
// -> (dictionary):
//   - leaves (array): Leaves with the (global) exponent removed
//   - exponent (dictionary): Exponent component
#let find-exponent(leaves) = {
  if leaves == () { return (leaves: (), exponent: none) }
  let match = leaves.at(-1).body.match(pattern-exponent)
  if match == none { return (leaves: leaves, exponent: none) }

  let exponent = match.captures.at(0)
  if match.start == 0 {
    let exponent = (..leaves.remove(-1), body: exponent)
    return (leaves: leaves, exponent: exponent)
  }

  let exponent = (..leaves.at(-1), body: exponent)
  leaves.at(-1).body = leaves.at(-1).body.slice(0, match.start + 1)
  return (leaves: leaves, exponent: exponent)
}

// Remove the matched value from the leaves
//
// - match (dictionary): The matched value
// - leaves (array): All the leaves
// -> (dictionary):
//   - value (dictionary): The value with the text and the path
//   - leaves (array): The remaining leaves
//
// When the value starts with a hyphen, Typst will separate it from
// the (absolute) value even if there is no space between the two.
// This would not happen with an actual minus sign, but not allowing
// the hyphen as input is not an option.
// In most cases the value is not spread over multiple leaves and the
// path is unambiguous. The most recently checked leaf can therefore be
// used to set the path for the value.
// If the value is spread over multiple leaves, the most recent leaf is
// still a reasonable choice since this will be the leaf that holds the
// absolute value. The styling of the sign is then simply ignored.
#let remove-value-from-leaves(match, leaves) = {
  let leaf
  let i = 0
  let offset = match.start
  while true {
    leaf = leaves.at(i)
    let length = match.end - offset

    if leaf.body.len() == length {
      i += 1
      break
    } else if leaf.body.len() > length {
      // do not increment i since leaves.at(i) is not empty (yet)
      leaves.at(i).body = leaf.body.slice(match.end - offset)
      break
    }

    offset += leaf.body.len()
    i += 1
  }

  (
    value: (..leaf, body: match.captures.at(0)),
    leaves: leaves.slice(i),
  )
}

// Find the value and the exponent in the number leaves
//
// - leaves (array)
// -> (dictionary):
//   - leaves (array): Leaves with the value and the exponent removed
//   - value (dictionary)
//   - exponent (dictionary): `none` if there is no exponent in the number
//
// The value and the exponent are handled in the same function since the
// different input formats of uncertainties require a different handling
// of the parenthesis in the match of the exponent pattern.
//
// The closing parenthesis ")" is part of the exponent-pattern to validate
// the number format. This parenthesis has to be removed if it belongs to
// the pair that encloses the number and the uncertainties. If it belongs
// to a relative uncertainty however, the parenthesis has to be kept to
// have a valid format for `find-uncertainties()`.
#let find-value-and-exponent(leaves) = {
  let number = leaves.map(leaf => leaf.body).join()
  let match-value = number.match(pattern-value)
  assert.ne(match-value, none, message: "Invalid number format")
  let parentheses = match-value.text.starts-with("(")
  let match-exponent = number.match(pattern-exponent)

  if parentheses {
    if match-exponent == none {
      assert(number.ends-with(")"), message: "Invalid number format")
      leaves.at(-1).body = leaves.at(-1).body.slice(0, -1)
    } else {
      assert(match-exponent.text.starts-with(")"), message: "Invalid number format")
    }
  }

  let (value, leaves) = remove-value-from-leaves(match-value, leaves)
  if match-exponent == none { (return (leaves: leaves, value: value, exponent: none)) }

  let exponent = (..leaves.at(-1), body: match-exponent.captures.at(0))
  if match-exponent.text.len() >= leaves.at(-1).body.len() { _ = leaves.remove(-1) } else {
    let parenthesis-offset = int(match-exponent.text.starts-with(")"))
    let end = match-exponent.start - match-exponent.end + parenthesis-offset
    leaves.at(-1).body = leaves.at(-1).body.slice(0, end)
  }
  if parentheses and leaves.at(-1).body.ends-with(")") {
    leaves.at(-1).body = leaves.at(-1).body.slice(0, -1)
  }
  (leaves: leaves, value: value, exponent: exponent)
}

// Find the leaves corresponding to the matched uncertainty (pair)
//
// - leaves (array): Remaining leaves that contain only the uncertainties
// - match (dictionary): Regex match of an absolute/relative uncertainty (pair)
// -> uncertainty (dictionary): Uncertainty (pair)
//   - absolute (boolean): Flag for absolute/relative uncertainty
//   - symmetric (boolean): Flag for symmetric/asymmetric uncertainty
//   - value (dictionary): Value of the symmetric uncertainty (if symmetric is true)
//   - positive (dictionary): Value of the positive uncertainty (if symmetric is false)
//   - negative (dictionary): Value of the negative uncertainty (if symmetric is false)
//
// If there is no "positive" uncertainty in the `match`, the uncertainty is symmetric
// and the "negative" uncertainty is treated as the general uncertainty "value".
#let match-uncertainty(leaves, match) = {
  let (positive, negative) = match.captures
  let uncertainty = (absolute: match.absolute, symmetric: positive == none)

  let index = 0
  for leaf in leaves {
    index += leaf.body.len()
    if index < match.start { continue }

    let value = leaf.body
    if positive != none and positive in value and "positive" not in uncertainty.keys() {
      uncertainty.insert("positive", (..leaf, body: positive))
      // prevent that "negative" matches the same leaf as "positive"
      value = value.replace(positive, "", count: 1)
    }
    if negative in value {
      if positive == none { uncertainty += (..leaf, body: negative) } else {
        uncertainty.insert("negative", (..leaf, body: negative))
      }
      return uncertainty
    }
  }
}

// Find uncertainties in the number leaves
//
// - leaves (array): Remaining leaves that contain only the uncertainties
// -> uncertainties (array)
//
// If the `leaves` are not empty, they must be matched completely by the
// uncertainties patterns. Otherwise there is a format error in the number.
#let find-uncertainties(leaves) = {
  if leaves == () { return () }
  let number = leaves.map(leaf => leaf.body).join()
  let absolute-matches = number.matches(pattern-absolute-uncertainty).map(match => (..match, absolute: true))
  let relative-matches = number.matches(pattern-relative-uncertainty).map(match => (..match, absolute: false))
  let matches = (absolute-matches + relative-matches).sorted(key: match => match.start)
  if matches == () { panic("Invalid number format") }

  assert.eq(matches.at(0).start, 0, message: "Invalid number format")
  // assert((matches.at(-1).end == number.len()) or number.at(-1) == (")"), message: "panic...")
  assert.eq(matches.at(-1).end, number.len(), message: "Invalid number format")
  let start-positions = matches.slice(1).map(match => match.start)
  let end-positions = matches.slice(0, -1).map(match => match.end)
  assert.eq(start-positions, end-positions, message: "Invalid number format")

  matches.map(match => match-uncertainty(leaves, match))
}

// Interpret content as a number
//
// - c (content)
// -> (array)
//   - (dictionary)
//     - value (dictionary): The value component
//     - uncertainties (array): The uncertainty components, can be empty
//     - exponent (dictionary): The (global) exponent component, can be `none`
//   - tree (dictionary): The content tree from `unwrap-content()`
#let interpret-number(c) = {
  let tree = unwrap-content(c)
  let leaves = find-leaves(tree).filter(leaf => leaf.body != " ")
  let leaves = leaves.map(leaf => (..leaf, body: leaf.body.replace(" ", "")))
  let (leaves, value, exponent) = find-value-and-exponent(leaves)
  let uncertainties = find-uncertainties(leaves)
  ((value: value, uncertainties: uncertainties, exponent: exponent), tree)
}


// Trim the leading zeros from a number
//
// - s (str): The number
// -> (str)
//
// If the string starts with a "." after the trimming, a zero will be added
// to the start again. This could also be solved with regex, but unfortunately
// the required lookahead is not implemented/allowed.
// If the string already started with a "." before the trimming, no zero will
// be added to the start.
#let trim-leading-zeros(s) = {
  if not s.starts-with("0") { return s }
  let trimmed = s.trim("0", at: start)
  if trimmed.starts-with(".") { "0" }
  trimmed
}

// Shift the decimal position of a number
//
// - s (str): The number
// - n (int): Decimal shift
// -> (str)
//
// The sign of the parameter `n` is defined such that a positive shift
// will move the decimal position to the right. As an equation this
// function would be $s * 10^n$.
#let shift-decimal-position(s, n) = {
  let split = s.split(".")
  let integer-places = split.at(0).len()
  let decimal-places = split.at(1, default: "").len()
  s = s.replace(".", "")

  if n >= decimal-places {
    return trim-leading-zeros(s + "0" * (n - decimal-places))
  } else if -n >= integer-places {
    return "0." + "0" * calc.abs(n + integer-places) + s
  } else {
    let decimal-position = integer-places + n
    return trim-leading-zeros(s.slice(0, decimal-position) + "." + s.slice(decimal-position))
  }
}

// Convert a relative uncertainty to an absolute uncertainty
//
// - uncertainty (dictionary): The relative uncertainty
// - value (dictionary)
// -> (dictionary): The absolute uncertainty
#let convert-uncertainty-relative-to-absolute(uncertainty, value) = {
  let match = value.body.match(pattern-decimal-places)
  if match != none {
    let decimal-places = match.captures.at(0).len()
    uncertainty.body = shift-decimal-position(uncertainty.body, -decimal-places)
  }
  uncertainty.absolute = true
  uncertainty
}

// Convert an absolute uncertainty to a relative uncertainty
//
// - uncertainty (dictionary): The absolute uncertainty
// - value (dictionary)
// -> (dictionary): The relative uncertainty
#let convert-uncertainty-absolute-to-relative(uncertainty, value) = {
  let match = value.body.match(pattern-decimal-places)
  if match != none {
    let decimal-places = match.captures.at(0).len()
    uncertainty.body = shift-decimal-position(uncertainty.body, decimal-places)
  }
  uncertainty.absolute = false
  uncertainty
}

// Convert an uncertainty to another format if necessary
//
// - uncertainty (dictionary): The initial uncertainty
// - value (dictionary): The value
// - format (str): The target format
// -> (dictionary): The (converted) uncertainty
#let convert-uncertainty(uncertainty, value, format) = {
  if format == "plus-minus" and not uncertainty.absolute {
    convert-uncertainty-relative-to-absolute(uncertainty, value)
  } else if format == "parentheses" and uncertainty.absolute {
    convert-uncertainty-absolute-to-relative(uncertainty, value)
  } else {
    uncertainty
  }
}

// Format a symmetric uncertainty
//
// - uncertainty (dictionary)
// - tree (dictionary): The content tree
// - config (dictionary): Formatting configuration
// -> (content)
//
// If the `uncertainty` is absolute, it will be preceded by sym.plus.minus.
// If the `uncertainty` is not absolute, it will be wrapped in parentheses ().
#let format-symmetric-uncertainty(uncertainty, tree, config) = {
  let u = wrap-component(uncertainty, tree, config.decimal-separator)
  if uncertainty.absolute { [#sym.plus.minus] + u } else { math.lr[(#u)] }
}

// Format an asymmetric uncertainty
//
// - positive (dictionary): The positive uncertainty
// - negative (dictionary): The negative uncertainty
// - tree (dictionary): The content tree
// - config (dictionary): Formatting configuration
// -> (content)
//
// The uncertainties are not directly attached to the existing content
// in `format-number()` to ensure that their positions do not depend on
// the content before them.
#let format-asymmetric-uncertainty(positive, negative, tree, config) = {
  math.attach(
    [],
    tr: [#sym.plus] + wrap-component(positive, tree, config.decimal-separator),
    br: [#sym.minus] + wrap-component(negative, tree, config.decimal-separator),
  )
}

// Format the exponent
//
// - exponent (dictionary)
// - tree (dictionary): The content tree
// - config (dictionary): Formatting configuration
// -> (content)
//
// For now the layers are only applied to the actual exponent. The x10
// is not affected.
#let format-exponent(exponent, tree, config) = [
  #sym.times
  #math.attach([10], tr: wrap-component(exponent, tree, config.decimal-separator))
]

// Format a number
//
// - number (dictionary): The interpreted number
// - tree (dictionary): The content tree
// - config (dictionary): Formatting configuration
// -> (content)
#let format-number(number, tree, config) = {
  let c = wrap-component(number.value, tree, config.decimal-separator)
  let wrap-in-parentheses = false
  for uncertainty in number.uncertainties {
    if uncertainty.symmetric {
      uncertainty = convert-uncertainty(uncertainty, number.value, config.uncertainty-mode)
      c += format-symmetric-uncertainty(uncertainty, tree, config)
      if uncertainty.absolute { wrap-in-parentheses = true }
    } else {
      let (absolute, positive, negative) = uncertainty
      if not absolute {
        positive = convert-uncertainty-relative-to-absolute(positive, number.value)
        negative = convert-uncertainty-relative-to-absolute(negative, number.value)
      }
      c += format-asymmetric-uncertainty(positive, negative, tree, config)
      wrap-in-parentheses = true
    }
  }

  if number.exponent != none {
    if wrap-in-parentheses { c = math.lr[(#c)] }
    c += format-exponent(number.exponent, tree, config)
  }
  wrap-content-math(c, tree.layers, decimal-separator: config.decimal-separator)
}
