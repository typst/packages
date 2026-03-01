#let is-space(it) = {
  if type(it) == str { return it.trim() == "" }
  if type(it) == content {
    if repr(it.func()) == "space" { return true }
    if repr(it.func()) == "symbol" {
      return it.fields().text.trim() == ""
    }
  }
  return false
}

#let is-content-type(name, it) = type(it) == content and repr(it.func()) == name
#let is-equation = is-content-type.with("equation")
#let is-sequence = is-content-type.with("sequence")

#let as-array(it) = {
  if type(it) == array { it }
  else if it == none { () }
  else if is-sequence(it) { it.children }
  else { (it,) }
}

#let flatten-sequence(seq) = {
  if is-sequence(seq) { seq = seq.children }
  if type(seq) == array { seq.map(flatten-sequence).flatten() }
  else { seq }
}

#let is-node(it) = type(it) == dictionary and "head" in it

#let walk(it, pre: it => it, post: it => it, leaf: it => it) = {
  if not is-node(it) { return leaf(it) }
  let w(it) = walk(it, pre: pre, post: post, leaf: leaf)
  it = pre(it)
  it.args = it.args.map(w)
  it.slots = it.slots.keys().zip(it.slots.values().map(w)).to-dict()
  post(it)
}


#let walk-array(it, pre: it => it, post: it => it, leaf: it => it) = {
  if type(it) != array { return leaf(it) }
  post(pre(it).map(walk-array.with(pre: pre, post: post, leaf: leaf)))
}

#let ELEMENT_ARGS = json("element-args.json")

/// Construct an element given the content function and a dictionary of fields.
/// 
/// Some content functions require some fields to be given as positional or variadic arguments.
/// This function takes care of those, providing a uniform interface for constructing elements.
/// 
/// The field dictionary should be in the same order as given when calling `element.fields()`.
#let element-fields-to-arguments(fn, fields) = {
  let arg-types = ELEMENT_ARGS.at(repr(fn), default: (:))

  let pos = ()
  if "positional" in arg-types {
    for field in fields.keys() {
      if field in arg-types.positional {
        pos.push(fields.remove(field))
      }
    }
  }
  if "variadic" in arg-types {
    pos += fields.remove(arg-types.variadic)
  }
  
  arguments(..pos, ..fields)
}

#let walk-content(it, pre: it => it, post: it => it) = {
  if type(it) != content { return it }
  let w(it) = walk-content(it, pre: pre, post: post)
  let fields = pre(it).fields().pairs().map(((k, v)) => {
    if type(v) == array { (k, v.map(w)) }
    else { (k, w(v)) }
  }).to-dict()
  let fn = it.func()
  let args = element-fields-to-arguments(fn, fields)
  post(fn(..args))
}


#let node-depths(tree) = walk(tree, post: it => {
  let depth = 0
  for sub in it.args + it.slots.values() {
    if type(sub) == dictionary and "depth" in sub {
      depth = calc.max(depth, sub.depth)
    }
  }
  it + (depth: depth + 1)
})

#let stringify(it) = {
  if type(it) == str { return it }
  if "text" in it.fields() {
    stringify(it.text)
  } else {
    repr(it)
  }
}