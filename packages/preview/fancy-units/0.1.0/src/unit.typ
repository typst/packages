#import "content.typ": unwrap-content, wrap-content-math


#let pattern-exponent = regex("^([^^]*)\^(−?[a-zA-Z0-9\.\/]+)$")
#let pattern-fraction = regex("\/ *(?:[\D]|$)")
#let pattern-non-numeric = regex("[^−\d\/]+")

#let brackets = ("(", "[", "{", ")", "]", "}")
#let pattern-bracket = regex(brackets.map(bracket => "(\\" + bracket + ")").join("|"))

// Offset a bracket location
//
// - bracket (dictionary): Open or close bracket
//   - child (int): Child index in the content tree
//   - position (int): Bracket position in the child text
// - offset (dictionary): Offset to apply to the `bracket`
//   - child (int)
//   - position (int)
// -> bracket (dictionary): Bracket with shifted child or position
//
// If the bracket and the offset have a different child index, the offset
// points to a different child. In that case the child index has to be
// changed but the position is conserved.
// If the bracket and the offset have the same child index, only the
// position has to be shifted.
#let offset-bracket(bracket, offset) = {
  // the offset.child always has to be subtracted!
  let child = bracket.child - offset.child
  // the position is only subtracted if bracket.child and offset.child are equal!
  let position = if child > 0 { bracket.position } else { bracket.position - offset.position - 1 }
  return (child: child, position: position)
}

// Offset the locations of bracket pairs
//
// - pairs (array): All (remaining) bracket pairs
// - offset (dictionary): Offset to apply to the brackets in `pairs`
//   - child (int)
//   - position (int)
// -> pairs (array): Shifted bracket pairs
//
// This function will apply `offset-bracket()` to every "open" and
// "close" bracket in the `pairs`.
#let offset-bracket-pairs(pairs, offset) = {
  pairs.map(
    pair => (
      type: pair.type,
      open: offset-bracket(pair.open, offset),
      close: offset-bracket(pair.close, offset)
    )
  )
}

// Get the children before the opening bracket
//
// - children (array): All the children in the current tree level
// - pair (dictionary): Bracket pair
//   - type (int): Bracket type
//   - open (dictionary): Open bracket
//   - close (dictionary): Close bracket
// -> (array): The children up to the opening bracket
// 
// Example:
//  unit[a/(b c)]
//  children = (
//    (text: "a/(b c)", layers: ()),
//  )
//  pair = (
//    type: 0,
//    open: (child: 0, position: 2),
//    close: (child: 0, position: 6),
//  )
// 
//  get-opening-children(children, pair) -> (
//    (text: "a/", layers: ()),
//  )
#let get-opening-children(children, pair) = {
  // get the "full" children up to the open child...
  children.slice(0, pair.open.child)

  // ... and add text in the "open-child" up to the open position
  let open-child = children.at(pair.open.child)
  if pair.open.position > 0 {
    let pre = open-child.text.slice(0, pair.open.position)
    ((text: pre, layers: open-child.layers),)
  }
}

// Get the children inside the bracket pair
//
// - children (array): All the children in the current tree level
// - pair (dictionary): Bracket pair
//   - type (int): Bracket type
//   - open (dictionary): Open bracket
//   - close (dictionary): Close bracket
// -> (array): The children inside the bracket `pair`
// 
// Example:
//  unit[a/(b c)]
//  children = (
//    (text: "a/(b c)", layers: ()),
//  )
//  pair = (
//    type: 0,
//    open: (child: 0, position: 2),
//    close: (child: 0, position: 6),
//  )
// 
//  get-inner-children(children, pair) -> (
//    (text: "b c", layers: ()),
//  )
#let get-inner-children(children, pair) = {
  let open-child = children.at(pair.open.child)
  let close-child = children.at(pair.close.child)

  if pair.open.child == pair.close.child {
    let text = open-child.text.slice(pair.open.position + 1, pair.close.position)
    ((text: text, layers: open-child.layers),)
  } else {
    (
      (text: open-child.text.slice(pair.open.position + 1), layers: open-child.layers),
      ..children.slice(pair.open.child + 1, pair.close.child),
      (text: close-child.text.slice(0, pair.close.position), layers: close-child.layers)
    )
  }
}

// Get the children after the closing bracket
//
// - children (array): All the children in the current tree level
// - pair (dictionary): Bracket pair
//   - type (int): Bracket type
//   - open (dictionary): Open bracket
//   - close (dictionary): Close bracket
// -> (array): The children after the opening bracket
// 
// Example:
//  unit[(a b)^2/c]
//  children = (
//    (text: "(a b)^2/c", layers: ()),
//  )
//  pair = (
//    type: 0,
//    open: (child: 0, position: 0),
//    close: (child: 0, position: 4),
//  )
// 
//  get-closing-children(children, pair) -> (
//    (text: "^2/c", layers: ()),
//  )
#let get-closing-children(children, pair) = {
  let close-child = children.at(pair.close.child)

  if pair.close.position + 1 < close-child.text.len() {
    let post = close-child.text.slice(pair.close.position + 1)
    ((text: post, layers: close-child.layers),)
  }

  // add children after the "close-child"
  children.slice(pair.close.child + 1)
}

// Get the bracket pairs inside the current bracket pair
//
// - pairs (array): All (remaining) bracket pairs
// - close (dictionary): Closing bracket of the current bracket pair
// -> pairs (array): Bracket pairs inside the current bracket pair
//
// Since the current bracket pair is always the first one, the filter only
// has to check the "child" and "position" compared to the closing bracket.
#let get-inner-pairs(pairs, close) = {
  pairs.filter(pair =>
    pair.close.child < close.child or
    (pair.close.child == close.child and pair.close.position < close.position)
  )
}

// Get the bracket pairs after the current bracket pair
//
// - pairs (array): All (remaining) bracket pairs
// - close (dictionary): Closing bracket of the current bracket pair
// -> pairs (array): Bracket pairs after the current bracket pair
//
// Since the current bracket pair is always the first one, the filter only
// has to check the "child" and "position" compared to the closing bracket.
#let get-closing-pairs(pairs, close) = {
  pairs.filter(pair =>
    pair.close.child > close.child or
    (pair.close.child == close.child and pair.close.position > close.position)
  )
}

// Wrap children in a bracket layer
//
// - children (array): Children in the bracket `pair`
// - pair (dictionary): Bracket pair
// -> (array): The branch/leaf for the content tree
//
// If there is only one child in the `children`, the bracket
// can just be added to the field "brackets".
// If there are multiple children in the `children`, everything
// has to be wrapped again in a new branch/leaf to include the
// "brackets".
// 
// Example:
//  unit[(a b)^2]
//  children = ((text: "a b", layers: ()),)
//  pair = (
//    type: 0,
//    open: (child: 0, position: 0),
//    close: (child: 0, position: 4),
//  )
// 
//  wrap-children(children, pair) -> (
//    (text: "a b", layers: (), brackets: (0,)),
//  )
#let wrap-children(children, pair) = {
  if children.len() == 1 {
    let brackets = children.at(0).at("brackets", default: ())
    brackets.push(pair.type)
    children.at(0).insert("brackets", brackets)
    children
  } else {
    ((
      children: children,
      layers: (),
      brackets: (pair.type,)
    ),)
  }
}

// Split children by bracket pairs
// 
// - children (array): Children in the content tree
// - pairs (array): Bracket pairs
// -> children (array)
// 
// Example:
//  unit[(a b)^2/c]
//  children = (
//    (text: "(a b)^2/c", layers: ()),
//  )
//  pairs = (
//    (
//      type: 0,
//      open: (child: 0, position: 0),
//      close: (child: 0, position: 4),
//    ),
//  )
// 
//  group-brackets(children, pair) -> (
//    (text: "a b", layers: (), brackets: (0,)),
//    (text: "^2/c", layers: ()),
//  )
#let group-brackets(children, pairs) = {
  // return the children if there are no (more) bracket pairs
  if pairs.len() == 0 { return children }
  // return the children if the bracket pairs start behind the children
  if children.len() < pairs.at(0).open.child { return children }
  let pair = pairs.remove(0)

  // start with the opening children
  get-opening-children(children, pair)

  // get the bracket pair and the inner children
  let inner-children = get-inner-children(children, pair)
  let inner-pairs = offset-bracket-pairs(get-inner-pairs(pairs, pair.close), pair.open)
  wrap-children(group-brackets(inner-children, inner-pairs), pair)

  // get the closing children
  let closing-children = get-closing-children(children, pair)
  let closing-offset = (
    child: children.len() - closing-children.len(),
    position: pair.close.position
  )
  let closing-pairs = offset-bracket-pairs(get-closing-pairs(pairs, pair.close), closing-offset)

  // call the function again with the remaining bracket pairs
  group-brackets(closing-children, closing-pairs)
}


// Invert the sign of a number
//
// - s (str)
// -> (str)
//
// This function just checks if `s` starts with "-" and removes
// (or adds) it if it does (not) start with one.
#let invert-number(s) = {
  if s.starts-with("−") { s.trim("−", at: start) }
  else { "−" + s }
}

// Apply an exponent to a child
//
// - child (dictionary): The child to update
// - exponent (dictionary): The exponent to be applied
//   - text (str)
//   - layers (array)
// -> child (dictionary)
//
// If an exponent already exists in the `child`, the layers of that
// exponent are conserved and the `layers` of the new `exponent` are
// ignored.
// If the child does not have an exponent yet, the new exponent is
// always applied and kept, no matter the value of the exponent. This
// also allows exponents such as 0 or 1 to be used if they are specified
// in the initial unit.
// If the exponent is 1 after some kind of calculation, it will be removed
// before the child is returned. This mostly happens when the exponent -1
// is inverted, but this can also happen if the exponents 2 and 1/2 are
// combined.
#let apply-exponent(child, exponent) = {
  if not "exponent" in child.keys() {
    return (..child, exponent: exponent)
  } else if exponent.text == "−1" {
    child.exponent.text = invert-number(child.exponent.text)
  } else if child.exponent.text == "−1" {
    child.exponent.text = invert-number(exponent.text)
  } else {
    if pattern-non-numeric in child.exponent.text or pattern-non-numeric in exponent.text {
      panic("Exponent " + exponent.text + " cannot be applied to exponent " + child.exponent.text)
    }
    let fraction = exponent.text.split("/")
    let child-fraction = child.exponent.text.split("/")
    let numerator = int(fraction.at(0)) * int(child-fraction.at(0))
    let denominator = int(fraction.at(1, default: "1")) * int(child-fraction.at(1, default: "1"))
    let gcd = calc.gcd(numerator, denominator)
    if gcd == denominator { child.exponent.text = str(numerator / denominator) }
    else if gcd == 1 { child.exponent.text = str(numerator) + "/" + str(denominator) }
    else { child.exponent.text = str(numerator / gcd) + "/" + str(denominator / gcd) }
  }

  if child.exponent.text == "1" { _ = child.remove("exponent") }
  child
}

// Helper function to invert the exponent of a child
//
// - child (dictionary): The child to update
// -> child (dictionary)
#let invert-exponent(child) = {
  apply-exponent(child, (text: "−1", layers: ()))
}

// Find an exponent in a child with text
//
// - child (dictionary)
//   - text (str)
//   - layers (array)
//   - exponent (dictionary): (Optional) exponent
// - units (array): Units accumulated up to the `child`
// -> units (array): Updated array of units
//
// Any text directly after an exponent is simply ignored. There should
// always be a space after an exponent which allows the text to be split
// in this function.
// Passing all the `units` to the function is required because an exponent
// is always applied to the (current) last unit. It is possible that no
// element is added to the `units` in this function. Therefore, all of the
// `units` are passed to this function.
// The `child` will not have the field "brackets" since these cases are
// handled separately in the parent function `find-exponents()`.
#let find-exponents-text(child, units) = {
  let (text, ..child) = child
  for unit in text.split(" ") {
    if unit.trim(" ") == "" { continue } // discard empty strings again...

    let match = unit.match(pattern-exponent)
    if match == none {
      if unit.contains("^") { panic("Invalid exponent format") }
      units.push((text: unit, ..child))
      continue
    }
    let exponent = match.captures.at(1)
    // is this even necessary? The "match" should just be none already...
    assert.ne(exponent, "", message: "Empty exponent in child '" + unit + "'")

    let unit = match.captures.at(0)
    if unit != "" { units.push((text: unit, ..child)) }
    units.at(-1) = apply-exponent(units.at(-1), (text: exponent, ..child))
  }

  units
}

// Find the indices of the units to group together
// 
// - units (array): The units in the content tree
// - invert-units (array): The indices of the units to invert
// -> (array): The indices to group together
// 
// Example:
//  unit[1/a:b^2]
//  units = (
//    (text: "1", layers: ()),
//    (text: "a", layers: ()),
//    (text: ":", layers: ()),
//    (
//      text: "b",
//      layers: (),
//      exponent: (text: "2", layers: ()),
//    ),
//  )
//  invert-units = (1,)
// 
//  find-groups(units, invert-units) -> ((0,), (1, 3))
#let find-groups(units, invert-units) = {
  let i = 0
  let groups = ()
  while i < units.len() {
    let child = units.at(i)
    // if the "child" has the key "children", it is treated just like a single unit here
    if "text" in child.keys() and child.text == ":" {
      assert.ne(i, 0, message: "Colons are not allowed at the start of a group.")
      i = i + 1
      assert.ne(i, units.len(), message: "Colons are not allowed at the end of a group.")
      assert(i not in invert-units, message: "Colons are not allowed at the end of a group.")
      if units.at(i).text == ":" { panic("Consecutive colons are not allowed.") }
      groups.at(-1).push(i)
    } else {
      groups.push((i,))
    }
    i = i + 1
  }
  return groups 
}

// Find and apply groups in the units
// 
// - units (array): The units in the content tree
// - invert-units (array): The indices of the units to invert
// -> (array): The grouped units
// 
// Example:
//  unit[1/a:b^2]
//  units = (
//    (text: "1", layers: ()),
//    (text: "a", layers: ()),
//    (text: ":", layers: ()),
//    (
//      text: "b",
//      layers: (),
//      exponent: (text: "2", layers: ()),
//    ),
//  )
//  invert-units = (1,)
// 
//  group-units(units, invert-units) -> (
//    (text: "1", layers: ()),
//    (
//      text: "ab",
//      layers: (),
//      exponent: (text: "−2", layers: ()),
//    ),
//  )
#let group-units(units, invert-units) = {
  for indices in find-groups(units, invert-units) {
    let group = indices.map(i => units.at(i))
    if group.len() == 1 {
      let child = group.at(0)
      if "children" in child.keys() { child.insert("group", false) }
      if indices.at(0) in invert-units { child = invert-exponent(child) }
      (child,)
      continue
    }

    let single-units = group.all(unit => "text" in unit.keys())
    assert(single-units, message: "Only single units can be grouped.")

    let exponents = group.slice(0, -1).any(unit => "exponent" in unit.keys())
    assert(not exponents, message: "Only the last unit in a group can have an exponent.")

    let props = (layers: ())
    let exponent = group.at(-1).remove("exponent", default: none)
    if exponent != none { props.insert("exponent", exponent) }

    // immediately join group if all units are unstyled
    if group.all(unit => unit.layers == ()) {
      group = (text: group.map(unit => unit.text).join(), ..props)
    } else {
      group = (children: group, ..props, group: true)
    }

    if indices.at(0) in invert-units { group = invert-exponent(group) }
    (group,)
  }
}

// Remove unnecessary levels and children
// 
// - tree (dictionary): The content tree
// - children (array): The children with exponents and groups
// -> (dictionary)
// 
// The `tree` is only used for global layers, exponents and brackets.
// The `children` are already the processed version of `tree.children`.
// 
// Example:
//  unit[1/ab^2]
//  tree = (
//    children: ((text: "1/ab^2", layers: ()),),
//    layers: (),
//    group: false,
//  )
//  children = (
//    (text: "1", layers: ()),
//    (
//      text: "ab",
//      layers: (),
//      exponent: (text: "−2", layers: ()),
//    ),
//  )
// 
//  simplify-units(tree, children) -> (
//    text: "ab",
//    layers: (),
//    exponent: (text: "−2", layers: ()),
//  )
#let simplify-units(tree, children) = {
  // remove children with text "1" to avoid a leading "1" if it is not necessary
  // the "1" will be added again in `format-unit-...()` if it is required...
  children = children.filter(child => (not child.keys().contains("text")) or child.text != "1")
  
  if children.len() > 1 or "brackets" in tree.keys() {
    (..tree, children: children)
  } else {
    let child = children.at(0)
    child.layers += tree.layers
    if "subscript" in child.keys() { child.subscript.layers += tree.layers }
    if "exponent" in child.keys() { child.exponent.layers += tree.layers }
    if "exponent" in tree.keys() { child = apply-exponent(child, tree.exponent) }
    child
  }
}

// Find exponents and groups in the content tree
// 
// - tree (dictionary): The content tree
// -> (dictionary)
// 
// The brackets are already handled prior to this function in
// `interpret-unit()`. The rest of the interpretation is then
// handled inside this function, and the tree is finally also
// simplified to remove unnecessary levels and children.
// 
// Example:
//  unit[a:b^2]
//  tree = (
//    children: (
//      (text: "a", layers: ()),
//      (text: ":", layers: ()),
//      (text: "b^2", layers: ()),
//    ),
//    layers: (),
//    group: false,
//  )
// 
//  interpret-exponents-and-groups(tree) -> (
//    text: "ab",
//    layers: (),
//    exponent: (text: "2", layers: ()),
//  )
#let interpret-exponents-and-groups(tree) = {
  let units = ()
  let invert-units = ()

  for child in tree.children {
    if "children" in child.keys() { units.push(interpret-exponents-and-groups(child)); continue }
    if child.text.trim(" ") == "" { continue } // discard empty children...

    // handle subscripts...
    if child.layers.contains((sub, (:))) { 
      let layers = child.layers.filter(layer => layer != (sub, (:)))
      units.at(-1).insert("subscript", (..child, layers: layers))
      continue
    }

    // remove the "text" field since it will be replaced in any new child anyway...
    let (text, ..child) = child
    // wrap everything in a sub-tree if the child is inside of a bracket...
    if "brackets" in child.keys() {
      units.push(interpret-exponents-and-groups((children: ((text: text, layers: ()),), ..child)))
      continue
    }

    while text.trim(" ") != "" {
      let match = text.match(pattern-fraction)
      if match == none {
        units = find-exponents-text((text: text, ..child), units)
        break
      }

      units = find-exponents-text((text: text.slice(0, match.start), ..child), units)
      // store the current length to invert the next child...
      invert-units.push(units.len())
      text = text.slice(match.start + 1)
    }
  }

  simplify-units(tree, group-units(units, invert-units))
}

// Recursively interpret the unit content tree
// 
// - tree (dictionary): The content tree
// -> tree (dictionary)
//
// This function builds upon the previous function `find-brackets()`. In order
// to make the bracket finding recursive, the group and exponents also have to
// be handled in this function.
//
// If a child with the key "children" is found, the function is called recursively
// and the original child is then just replaced by the return value. Brackets can
// therefore not be tracked across different depths!
//
// The (open) brackets are tracked across the children and kept in a separate list.
// When a closing bracket is found, it is paired up with the last open bracket.
// If the bracket types do not match, an error will be raised.
// If there are any open brackets left after iterating over all children, an error
// will also be raised.
#let interpret-unit(tree) = {
  let pairs = ()
  let open = ()

  for i in range(tree.children.len()) {
    let child = tree.children.at(i)
    if "children" in child.keys() { tree.children.at(i) = interpret-unit(child); continue }
    for match in child.text.matches(pattern-bracket) {
      // the bracket type is "encoded" in the group index
      let bracket-type = match.captures.position(x => x != none)
      // types 0, 1 and 2 are the open brackets
      if bracket-type < 3 { open.push((type: bracket-type, child: i, position: match.start)) }
      else {
        assert.ne(open, (), message: "error when matching brackets...")
        let (type: open-bracket-type, ..open-bracket) = open.pop()
        assert.eq(bracket-type - 3, open-bracket-type, message: "error when matching brackets...")
        pairs.push((type: open-bracket-type, open: open-bracket, close: (child: i, position: match.start)))
      }
    }
  }

  if open.len() > 0 { panic("error when matching brackets...") }

  // sort the pairs to be ordered by open.child and open.position
  pairs = pairs.sorted(key: pair => pair.open.position).sorted(key: pair => pair.open.child)
  interpret-exponents-and-groups((
    children: group-brackets(tree.children, pairs),
    layers: tree.layers,
    group: false, // make sure that the topmost level also has the 'group' field...
  ))
}


// Pass down the exponent from the tree to the children
//
// - tree (dictionary)
//   - children (array)
//   - exponent (dictionary)
// -> tree (dictionary)
//
// The field "exponent" is always removed from the returned tree.
// If the tree is a grouped unit, the exponent is only applied to the last
// child. Otherwise the exponent is applied to all children.
#let inherit-exponents(tree) = {
  let exponent = tree.remove("exponent")
  if tree.group { tree.children.at(-1) = apply-exponent(tree.children.at(-1), exponent) }
  else { tree.children = tree.children.map(child => apply-exponent(child, exponent)) }
  tree
}

// Bracket wrapper function
//
// - c (content): Content to be wrapped inside the bracket
// - type (int): Bracket type 0, 1 or 2.
// -> (content)
#let unit-bracket(c, type) = {
  if type == 0 { math.lr[(#c)] }
  else if type == 1 { math.lr[[#c]] }
  else if type == 2 { math.lr[{#c}] }
  else { panic("Invalid bracket type " + str(type)) }
}

// Apply brackets to a unit
//
// - unit (content): The content to wrap in the brackets
// - brackets (array): The array of brackets to apply
// -> unit (content)
//
// If the outermost brackets are parentheses (type 0), they are removed
// from the array of brackets. This follows the convention that the first
// pair of parentheses is only used for grouping.
#let apply-brackets(unit, brackets) = {
  if brackets.at(-1) == 0 { _ = brackets.pop() }
  for bracket in brackets { unit = unit-bracket(unit, bracket) }
  unit
}

// Join units with a separator
//
// - c (array): Individual (formatted) units
// - group (boolean): Flag to group the units
// - unit-separator (content): Separator if group is false
// -> (content)
#let join-units(c, group, unit-separator) = {
  let join-symbol = if group { [] } else { unit-separator }
  c.join(join-symbol)
}


// Format and attach content to a unit
// 
// - unit (content): Base unit
// - config (dictionary): Formatting configuration
// - args (dictionary): Named arguments for the function `math.attach()`
// -> (content)
// 
// This is supposed to be used for exponents and subscripts, but in principle
// any valid attachement key can be passed to this function. 
//
// Exponents are wrapped in `math.italic()` by default since an exponent will
// most likely be a variable such as "n".
// Subscripts are wrapped in `math.upright()` by default since a subscript will
// most likely be a text to describe a unit or variable such as "rec".
#let unit-attach(unit, config, ..args) = {
  let attachements = args.named()
  for key in attachements.keys() {
    let attachement = attachements.at(key)
    if attachement == none or type(attachement) == str { continue }
    attachement = wrap-content-math(
      attachement.text,
      attachement.layers,
      decimal-separator: config.decimal-separator
    )
    if key == "tr" { attachements.insert(key, math.italic(attachement)) }
    else if key == "br" { attachements.insert(key, math.upright(attachement)) }
    else { attachements.insert(key, attachement) }
  }
  math.attach(unit, ..attachements)
}

// Format a child with text
// 
// - child (dictionary)
//   - text (str)
//   - layers (array)
//   - exponent (dictionary): (Optional) exponent
//   - subscript (dictionary): (Optional) subscript
// - config (dictionary): Formatting configuration
// -> (content)
// 
// math.upright() is called after the text is wrapped in the layers to
// allow `emph()` or `math.italic()` to be applied to the text.
#let format-unit-text(child, config) = {
  let unit = math.upright(wrap-content-math(
    child.text,
    child.layers,
    decimal-separator: config.decimal-separator
  ))

  if not ("exponent" in child.keys() or "subscript" in child.keys()) {
    return unit
  }

  unit-attach(
    unit,
    config,
    tr: child.at("exponent", default: none),
    br: child.at("subscript", default: none)
  )
}

// Format children into a single unit
// 
// - children (array): Individually formatted children
// - tree (dictionary): The (remaining) tree of the unit
// - config (dictionary): Formatting configuration
// -> (content)
#let format-unit(children, tree, config) = {
  let unit = join-units(children, tree.group, config.unit-separator)
  if "brackets" in tree.keys() { unit = apply-brackets(unit, tree.brackets) }
  if "exponent" in tree.keys() { unit = unit-attach(unit, config, tr: tree.exponent) }
  wrap-content-math(unit, tree.layers)
}

// Format units with the power mode
// 
// - tree (dictionary): The fully interpreted content tree
// - config (dictionary): The configuration for the formatting
// -> (content)
// 
// Around brackets the separator `h(0.2em)` is always used and the
// "unit-separator" in the `config` is ignored. If the configured
// separator is e.g. a dot ".", it just looks wrong to join units
// and brackets with that separator.
#let format-unit-power(tree, config) = {
  if "text" in tree.keys() { return format-unit-text(tree, config) }

  // the definition of protective brackets is broader here compared to `format-unit-fraction()`
  let single-child = tree.children.len() == 1 and ("text" in tree.children.at(0) or tree.children.at(0).group)
  let protective-brackets = "brackets" in tree.keys() and (single-child or tree.brackets != (0,))

  // handle global exponents
  if "exponent" in tree.keys() and not protective-brackets {
    tree = inherit-exponents(tree)
  }

  let c = ()
  let previous-brackets = false
  for child in tree.children {
    let unit = format-unit-power(child, config)
    let brackets = "brackets" in child.keys() and child.brackets != (0,)
    if (brackets or previous-brackets) and c.len() > 0 {
      unit = c.pop() + h(0.2em) + unit
    }
    previous-brackets = brackets
    c.push(unit)
  }

  format-unit(c, tree, config)
}

// Format units with the fraction mode
// 
// - tree (dictionary): The fully interpreted content tree
// - config (dictionary): The configuration for the formatting
// -> (content)
// 
// Unless a unit or multiple units are protected by brackets,
// the fractions in different levels can be nested. If there
// are multiple ungrouped units with negative indices, they
// will be put in individual fractions that are then joined
// by the `config.unit-separator`.
#let format-unit-fraction(tree, config) = {
  // handle negative global exponents...
  // ...and handle "text-only" trees without exponents or with positive exponents
  if "exponent" in tree.keys() and tree.exponent.text.starts-with("−") {
    return math.frac([1], format-unit-fraction(invert-exponent(tree), config))
  } else if "text" in tree.keys() {
    return format-unit-text(tree, config)
  }

  // use the per-mode power for children in protective brackets
  let single-child = tree.children.len() == 1 and ("text" in tree.children.at(0) or tree.children.at(0).group)
  if "brackets" in tree.keys() and single-child {
    return format-unit-power(tree, config)
  }

  // handle global exponents
  if "exponent" in tree.keys() and ("brackets" not in tree.keys() or tree.brackets == (0,)) {
    tree = inherit-exponents(tree)
  }

  let c = ()
  for child in tree.children {
    let negative-exponent = "exponent" in child.keys() and child.exponent.text.starts-with("−")
    if negative-exponent { child = invert-exponent(child) }

    let unit = format-unit-fraction(child, config)
    if negative-exponent {
      // a new fraction is started if the previous child is a fraction...
      let previous = if c.len() > 0 and c.at(-1).func() != math.frac { c.pop() } else { [1] }
      unit = math.frac(previous, unit)
    }
    c.push(unit)
  }

  format-unit(c, tree, config)
}

// Format units with the slash mode
// 
// - tree (dictionary): The fully interpreted content tree
// - config (dictionary): The configuration for the formatting
// -> (content)
// 
// The slash is only used for fractions in the topmost level of
// the hierarchy. Any nested fractions will be formatted with the
// function `format-unit-power()`.
#let format-unit-slash(tree, config) = {
  let per-separator = h(0.05em) + sym.slash + h(0.05em)

  // handle negative global exponents...
  // ...and handle text-only trees without exponents or with positive exponents
  if "exponent" in tree.keys() and tree.exponent.text.starts-with("−") {
    let unit = [1] + per-separator + format-unit-power(invert-exponent(tree), config)
    return wrap-content-math(unit, tree.layers)
  } else if "text" in tree.keys() {
    return format-unit-text(tree, config)
  }

  // handle positive global exponents
  if "exponent" in tree.keys() and ("brackets" not in tree.keys() or tree.brackets == (0,)) {
    tree = inherit-exponents(tree)
  }

  let c = ()
  for child in tree.children {
    let negative-exponent = "exponent" in child.keys() and child.exponent.text.starts-with("−")
    if negative-exponent { child = invert-exponent(child) }

    let unit = format-unit-power(child, config)
    if negative-exponent {
      let previous = if c.len() > 0 { c.pop() } else { [1] }
      unit = previous + per-separator + unit
    }
    c.push(unit)
  }

  format-unit(c, tree, config)
}