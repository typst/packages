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


/// Visit every node in a tree and transform it.
/// 
/// For most tasks, a post-walk is what you want (pre-walks can lead to infinite recursion if used incorrectly).
#let walk(
  /// A root node in the format described in @trees.
  tree,
  /// Function to transform each node _before_ visiting its children.
  pre: it => it,
  /// Function to transform each node _after_ its children have been visited.
  post: it => it,
  /// Function to apply to leaf nodes, or all non-node children of nodes in the tree.
  leaf: it => it,
) = {
  if not is-node(tree) { return leaf(tree) }
  let w(it) = walk(it, pre: pre, post: post, leaf: leaf)
  tree = pre(tree)
  tree.args = tree.args.map(w)
  tree.slots = tree.slots.keys().zip(tree.slots.values().map(w)).to-dict()
  post(tree)
}


#let walk-array(it, pre: it => it, post: it => it, leaf: it => it) = {
  if type(it) != array { return leaf(it) }
  post(pre(it).map(walk-array.with(pre: pre, post: post, leaf: leaf)))
}

#let ELEMENT_ARGS = json("element-args.json")

/// Convert an element's fields into an `arguments` object that can be passed to the element function to reinstantiate it as content.
/// 
/// This works for _almost_ all elements:
/// 
/// ```typc
/// let it = /* some content */
/// let (fn, fields) = (it.func(), it.fields())
/// assert.eq(it, fn(..element-fields-to-arguments(fn, fields)))
/// ```
/// 
/// Some content functions require some fields to be given as positional or variadic arguments.
/// This function takes care of all this irregularity, providing an easier way to produce elements from field dictionaries.
/// 
/// However, there are still some elements (like `sequence` and `math.sqrt`) which need special treatment, as done by @content-to-tree.
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

/// Convert anything into a string.
/// 
/// For textual elements, returns the `"text"` field. Falls back to `repr` for other content.
#let stringify(it) = {
  if type(it) == str { it }
  else if type(it) == content and "text" in it.fields() {
    stringify(it.text)
  } else {
    repr(it)
  }
}


/// Convert content into an abstract syntax tree.
/// 
/// Each node in the resulting tree is of the form:
/// ```typc
/// (
///   head: "element-name",
///   fn: <element-fn>,
///   args: <positional-args>,
///   slots: <named-args>,
/// )
/// ```
/// The node may be converted back into content by calling `fn(..args, ..slots)`, provided its arguments and slots have also been converted from nodes into content.
/// This is what @tree-to-content does.
#let content-to-tree(
  it,
  /// Names of element functions to exclude from converting as strings.
  exclude: ()
) = {
  if type(it) != content { return it }

  if type(exclude) != array { exclude = (exclude,) }
  let c = content-to-tree.with(exclude: exclude)

  let fn = it.func()
  let head = repr(fn)

  if head in exclude.map(stringify) { it }
  else if head == "sequence" {
    (
      head: head,
      fn: (..args) => args.pos().join(),
      args: it.children.map(c),
      slots: (:) 
    )
  } else {
    let args = element-fields-to-arguments(fn, it.fields())

    // exceptions due to irregularity in typst's content model
    if head == "root" and args.pos().len() == 1 {
      fn = math.sqrt
    }

    (
      head: head,
      fn: fn,
      args: args.pos().map(c),
      slots: args.named().pairs().map(((k, v)) => (k, c(v))).to-dict(),
    )
  }
}


/// Reconstruct content from a tree given by @content-to-tree.
#let tree-to-content(tree) = walk(tree, post: ((fn, args, slots)) => fn(..args, ..slots))



/// A pseudo-random colour based on a seed value.
/// 
/// Subsequent arguments are passed to `color.oklch` and may each be a single value
/// or a pair `(min, max)` indicating a random value in a range.
/// For example, `hue: (0deg, 90deg)` produces reddish hues between `0deg` and `90deg`
/// uniformly randomly.
/// 
/// ```example
/// import parsely.util: random-color
/// "Hello world! I am random shades of blue.".split().map(word => {
///   let c = random-color(word, lightness: (20%, 70%), hue: (200deg, 300deg))
///   text(c, word)
/// }).join(" ")
/// ```
#let random-color(
  seed,
  lightness: 60%,
  chroma: (30%, 100%),
  hue: (0deg, 360deg),
) = {
  let entropy = array(bytes(repr(seed)))
  let noise(seed) = {
    for byte in entropy { seed += calc.rem((byte + seed)*67, 313) }
    calc.rem(seed, 101)/100
  }
  let vary(it, ε) = {
    let (min, max) = if type(it) == array { it } else { (it, it) }
    min + (max - min)*ε
  }
  color.oklch(
    vary(lightness, noise(21)),
    vary(chroma, noise(31)),
    vary(hue, noise(47)),
  )
}

