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
//   - position (int): Bracket position in the child body
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
  pairs.map(pair => (
    type: pair.type,
    open: offset-bracket(pair.open, offset),
    close: offset-bracket(pair.close, offset),
  ))
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
//    (body: "a/(b c)", layers: ()),
//  )
//  pair = (
//    type: 0,
//    open: (child: 0, position: 2),
//    close: (child: 0, position: 6),
//  )
//
//  get-opening-children(children, pair) -> (
//    (body: "a/", layers: ()),
//  )
#let get-opening-children(children, pair) = {
  // get the "full" children up to the open child...
  children.slice(0, pair.open.child)

  // ... and add body in the "open-child" up to the open position
  let open-child = children.at(pair.open.child)
  if pair.open.position > 0 {
    let pre = open-child.body.slice(0, pair.open.position)
    ((body: pre, layers: open-child.layers),)
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
//    (body: "a/(b c)", layers: ()),
//  )
//  pair = (
//    type: 0,
//    open: (child: 0, position: 2),
//    close: (child: 0, position: 6),
//  )
//
//  get-inner-children(children, pair) -> (
//    (body: "b c", layers: ()),
//  )
#let get-inner-children(children, pair) = {
  let open-child = children.at(pair.open.child)
  let close-child = children.at(pair.close.child)

  if pair.open.child == pair.close.child {
    let body = open-child.body.slice(pair.open.position + 1, pair.close.position)
    ((body: body, layers: open-child.layers),)
  } else {
    (
      (body: open-child.body.slice(pair.open.position + 1), layers: open-child.layers),
      ..children.slice(pair.open.child + 1, pair.close.child),
      (body: close-child.body.slice(0, pair.close.position), layers: close-child.layers),
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
//    (body: "(a b)^2/c", layers: ()),
//  )
//  pair = (
//    type: 0,
//    open: (child: 0, position: 0),
//    close: (child: 0, position: 4),
//  )
//
//  get-closing-children(children, pair) -> (
//    (body: "^2/c", layers: ()),
//  )
#let get-closing-children(children, pair) = {
  let close-child = children.at(pair.close.child)

  if pair.close.position + 1 < close-child.body.len() {
    let post = close-child.body.slice(pair.close.position + 1)
    ((body: post, layers: close-child.layers),)
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
  pairs.filter(pair => (
    pair.close.child < close.child or (pair.close.child == close.child and pair.close.position < close.position)
  ))
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
  pairs.filter(pair => (
    pair.close.child > close.child or (pair.close.child == close.child and pair.close.position > close.position)
  ))
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
//  children = ((body: "a b", layers: ()),)
//  pair = (
//    type: 0,
//    open: (child: 0, position: 0),
//    close: (child: 0, position: 4),
//  )
//
//  wrap-children(children, pair) -> (
//    (body: "a b", layers: (), brackets: (0,)),
//  )
#let wrap-children(children, pair) = {
  if children.len() == 1 {
    let brackets = children.at(0).at("brackets", default: ())
    brackets.push(pair.type)
    children.at(0).insert("brackets", brackets)
    children
  } else {
    (
      (
        children: children,
        layers: (),
        brackets: (pair.type,),
      ),
    )
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
//    (body: "(a b)^2/c", layers: ()),
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
//    (body: "a b", layers: (), brackets: (0,)),
//    (body: "^2/c", layers: ()),
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
    position: pair.close.position,
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
  if s.starts-with("−") { s.trim("−", at: start) } else { "−" + s }
}

// Apply an exponent to a child
//
// - child (dictionary): The child to update
// - exponent (dictionary): The exponent to be applied
//   - body (str)
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
  } else if exponent.body == "−1" {
    child.exponent.body = invert-number(child.exponent.body)
  } else if child.exponent.body == "−1" {
    child.exponent.body = invert-number(exponent.body)
  } else {
    if pattern-non-numeric in child.exponent.body or pattern-non-numeric in exponent.body {
      panic("Exponent " + exponent.body + " cannot be applied to exponent " + child.exponent.body)
    }
    let fraction = exponent.body.split("/")
    let child-fraction = child.exponent.body.split("/")
    let numerator = int(fraction.at(0)) * int(child-fraction.at(0))
    let denominator = int(fraction.at(1, default: "1")) * int(child-fraction.at(1, default: "1"))
    let gcd = calc.gcd(numerator, denominator)
    if gcd == denominator { child.exponent.body = str(numerator / denominator) } else if gcd == 1 {
      child.exponent.body = str(numerator) + "/" + str(denominator)
    } else { child.exponent.body = str(numerator / gcd) + "/" + str(denominator / gcd) }
  }

  if child.exponent.body == "1" { _ = child.remove("exponent") }
  child
}

// Helper function to invert the exponent of a child
//
// - child (dictionary): The child to update
// -> child (dictionary)
#let invert-exponent(child) = {
  apply-exponent(child, (body: "−1", layers: ()))
}

// Find an exponent in a child with a string body
//
// - child (dictionary)
//   - body (str)
//   - layers (array)
//   - exponent (dictionary): (Optional) exponent
// - units (array): Units accumulated up to the `child`
// -> units (array): Updated array of units
//
// Any text directly after an exponent is simply ignored. There should
// always be a space after an exponent which allows the body to be split
// in this function.
// Passing all the `units` to the function is required because an exponent
// is always applied to the (current) last unit. It is possible that no
// element is added to the `units` in this function. Therefore, all of the
// `units` are passed to this function.
// The `child` will not have the field "brackets" since these cases are
// handled separately in the parent function `find-exponents()`.
#let find-exponents-body(child, units) = {
  let (body, ..child) = child
  for unit in body.split(" ") {
    if unit.trim(" ") == "" { continue } // discard empty strings again...

    let match = unit.match(pattern-exponent)
    if match == none {
      if unit.contains("^") { panic("Invalid exponent format") }
      units.push((body: unit, ..child))
      continue
    }
    let exponent = match.captures.at(1)
    // is this even necessary? The "match" should just be none already...
    assert.ne(exponent, "", message: "Empty exponent in child '" + unit + "'")

    let unit = match.captures.at(0)
    if unit != "" { units.push((body: unit, ..child)) }
    units.at(-1) = apply-exponent(units.at(-1), (body: exponent, ..child))
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
//    (body: "1", layers: ()),
//    (body: "a", layers: ()),
//    (body: ":", layers: ()),
//    (
//      body: "b",
//      layers: (),
//      exponent: (body: "2", layers: ()),
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
    if "body" in child.keys() and child.body == ":" {
      assert.ne(i, 0, message: "Colons are not allowed at the start of a group.")
      i = i + 1
      assert.ne(i, units.len(), message: "Colons are not allowed at the end of a group.")
      assert(i not in invert-units, message: "Colons are not allowed at the end of a group.")
      if units.at(i).body == ":" { panic("Consecutive colons are not allowed.") }
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
// To allow an insertion of macros, groups of unstyled units are no longer
// joined in this function. This does not require any other changes since the
// function `join-units()` already handles grouped units.
//
// Example:
//  unit[1/a:b^2]
//  units = (
//    (body: "1", layers: ()),
//    (body: "a", layers: ()),
//    (body: ":", layers: ()),
//    (
//      body: "b",
//      layers: (),
//      exponent: (body: "2", layers: ()),
//    ),
//  )
//  invert-units = (1,)
//
//  group-units(units, invert-units) -> (
//    (body: "1", layers: ()),
//    (
//      children: ((body: "a", layers: ()), (body: "b", layers: ())),
//      layers: (),
//      exponent: (body: "−2", layers: ()),
//      group: true,
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

    let single-units = group.all(unit => "body" in unit.keys())
    assert(single-units, message: "Only single units can be grouped.")

    let exponents = group.slice(0, -1).any(unit => "exponent" in unit.keys())
    assert(not exponents, message: "Only the last unit in a group can have an exponent.")

    let props = (layers: ())
    let exponent = group.at(-1).remove("exponent", default: none)
    if exponent != none { props.insert("exponent", exponent) }
    group = (children: group, ..props, group: true)
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
//    children: ((body: "1/ab^2", layers: ()),),
//    layers: (),
//    group: false,
//  )
//  children = (
//    (body: "1", layers: ()),
//    (
//      body: "ab",
//      layers: (),
//      exponent: (body: "−2", layers: ()),
//    ),
//  )
//
//  simplify-units(tree, children) -> (
//    body: "ab",
//    layers: (),
//    exponent: (body: "−2", layers: ()),
//  )
#let simplify-units(tree, children) = {
  // remove children with body "1" to avoid a leading "1" if it is not necessary
  // the "1" will be added again in `format-unit-...()` if it is required...
  children = children.filter(child => (not child.keys().contains("body")) or child.body != "1")

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
//      (body: "a", layers: ()),
//      (body: ":", layers: ()),
//      (body: "b^2", layers: ()),
//    ),
//    layers: (),
//    group: false,
//  )
//
//  interpret-exponents-and-groups(tree) -> (
//    body: "ab",
//    layers: (),
//    exponent: (body: "2", layers: ()),
//  )
#let interpret-exponents-and-groups(tree) = {
  let units = ()
  let invert-units = ()

  for child in tree.children {
    if "children" in child.keys() {
      units.push(interpret-exponents-and-groups(child))
      continue
    }
    if child.body.trim(" ") == "" { continue } // discard empty children...

    // handle subscripts...
    if child.layers.contains((sub, (:))) {
      let layers = child.layers.filter(layer => layer != (sub, (:)))
      units.at(-1).insert("subscript", (..child, layers: layers))
      continue
    }

    // remove the "body" field since it will be replaced in any new child anyway...
    let (body, ..child) = child
    // wrap everything in a sub-tree if the child is inside of a bracket...
    if "brackets" in child.keys() {
      units.push(interpret-exponents-and-groups((children: ((body: body, layers: ()),), ..child)))
      continue
    }

    while body.trim(" ") != "" {
      let match = body.match(pattern-fraction)
      if match == none {
        units = find-exponents-body((body: body, ..child), units)
        break
      }

      units = find-exponents-body((body: body.slice(0, match.start), ..child), units)
      // store the current length to invert the next child...
      invert-units.push(units.len())
      body = body.slice(match.start + 1)
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
#let _interpret-unit(tree) = {
  let pairs = ()
  let open = ()

  for i in range(tree.children.len()) {
    let child = tree.children.at(i)
    if "children" in child.keys() {
      tree.children.at(i) = _interpret-unit(child)
      continue
    }
    for match in child.body.matches(pattern-bracket) {
      // the bracket type is "encoded" in the group index
      let bracket-type = match.captures.position(x => x != none)
      // types 0, 1 and 2 are the open brackets
      if bracket-type < 3 { open.push((type: bracket-type, child: i, position: match.start)) } else {
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

// Unwrap and interpret a unit
//
// - body (content): The unit to interpret
// -> tree (dictionary)
//
// The internal function is `_interpret-unit()` which recursively interprets
// the content tree. Since `unwrap-content()` only has to be called once, it
// cannot be in `_interpret-unit()`. This function is therefore required to
// wrap the internal function of the same name.
#let interpret-unit(body) = {
  let bare-tree = unwrap-content(body)
  // wrap the "body" child to use the functions find-brackets() and group-brackets-children()...
  if "body" in bare-tree.keys() { bare-tree = (children: (bare-tree,), layers: ()) }
  // ...the tree is unwrapped again (if possible) in simplify-units()
  _interpret-unit(bare-tree)
}

// Insert macros into the content tree
//
// - tree (dictionary): The content tree
// - macros (dictionary): The available macros to insert
// -> tree (dictionary)
//
// This function will walk the content tree and replace the leaf body with
// its macro if it is defined in the macros states.
// If the leaf has an exponent, it is applied to the macro. And existing
// layers in the leaf are appended to the layers of the macro. The styling
// of the macro therefore takes precedence over the styling of the leaf.
// If the leaf has a subscript, it is applied to the macro if it does not
// already have a subscript. This matches the general behavior of units
// where multiple subscripts are not supported either.
#let insert-macros(tree, macros) = {
  if "body" in tree.keys() {
    if tree.body not in macros.keys() { return tree }
    let macro = macros.at(tree.body)
    if "exponent" in tree.keys() {
      macro = apply-exponent(macro, tree.exponent)
      macro.exponent.layers += tree.layers
    }
    if "subscript" in tree.keys() and "subscript" not in macro.keys() {
      macro.subscript = tree.subscript
      macro.subscript.layers += tree.layers
    }
    macro.layers += tree.layers
    return macro
  }

  tree.children = tree.children.map(child => insert-macros(child, macros))
  tree
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
  if tree.group { tree.children.at(-1) = apply-exponent(tree.children.at(-1), exponent) } else {
    tree.children = tree.children.map(child => apply-exponent(child, exponent))
  }
  tree
}

// Bracket wrapper function
//
// - c (content): Content to be wrapped inside the bracket
// - bracket-type (int): Bracket type 0, 1 or 2.
// -> (content)
#let unit-bracket(c, bracket-type) = {
  let body = if type(c) == math.equation and not c.block { c.body } else { c }
  if bracket-type == 0 { math.lr($(#body)$) } else if bracket-type == 1 { math.lr($[#body]$) } else if (
    bracket-type == 2
  ) { math.lr(${#body}$) } else {
    panic("Invalid bracket type " + str(bracket-type))
  }
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
      attachement.body,
      attachement.layers,
      decimal-separator: config.decimal-separator,
    )
    if key == "tr" { attachements.insert(key, math.italic(attachement)) } else if key == "br" {
      attachements.insert(key, math.upright(attachement))
    } else { attachements.insert(key, attachement) }
  }
  math.attach(unit, ..attachements)
}

// Format a child with string body
//
// - child (dictionary)
//   - body (str)
//   - layers (array)
//   - exponent (dictionary): (Optional) exponent
//   - subscript (dictionary): (Optional) subscript
// - config (dictionary): Formatting configuration
// -> (content)
//
// math.upright() is called after the body is wrapped in the layers to
// allow `emph()` or `math.italic()` to be applied to the body.
#let format-unit-body(child, config) = {
  let unit = math.upright(
    wrap-content-math(
      child.body,
      child.layers,
      decimal-separator: config.decimal-separator,
    ),
  )

  if not ("exponent" in child.keys() or "subscript" in child.keys()) {
    return unit
  }

  unit-attach(
    unit,
    config,
    tr: child.at("exponent", default: none),
    br: child.at("subscript", default: none),
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
  if "body" in tree.keys() { return format-unit-body(tree, config) }

  // the definition of protective brackets is broader here compared to `format-unit-fraction()`
  let single-child = tree.children.len() == 1 and ("body" in tree.children.at(0) or tree.children.at(0).group)
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
  // ...and handle "body-only" trees without exponents or with positive exponents
  if "exponent" in tree.keys() and tree.exponent.body.starts-with("−") {
    return math.frac([1], format-unit-fraction(invert-exponent(tree), config))
  } else if "body" in tree.keys() {
    return format-unit-body(tree, config)
  }

  // use the per-mode power for children in protective brackets
  let single-child = tree.children.len() == 1 and ("body" in tree.children.at(0) or tree.children.at(0).group)
  if "brackets" in tree.keys() and single-child {
    return format-unit-power(tree, config)
  }

  // handle global exponents
  if "exponent" in tree.keys() and ("brackets" not in tree.keys() or tree.brackets == (0,)) {
    tree = inherit-exponents(tree)
  }

  let c = ()
  for child in tree.children {
    let negative-exponent = "exponent" in child.keys() and child.exponent.body.starts-with("−")
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
  // ...and handle body-only trees without exponents or with positive exponents
  if "exponent" in tree.keys() and tree.exponent.body.starts-with("−") {
    let unit = [1] + per-separator + format-unit-power(invert-exponent(tree), config)
    return wrap-content-math(unit, tree.layers)
  } else if "body" in tree.keys() {
    return format-unit-body(tree, config)
  }

  // handle positive global exponents
  if "exponent" in tree.keys() and ("brackets" not in tree.keys() or tree.brackets == (0,)) {
    tree = inherit-exponents(tree)
  }

  let c = ()
  for child in tree.children {
    let negative-exponent = "exponent" in child.keys() and child.exponent.body.starts-with("−")
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
