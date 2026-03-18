// Get the content tree from a content object
//
// - c (content): The content to unwrap
// -> dictionary
//    - body (str): Actual text in the content object
//    - children (array): Children of the content object
//    - layers (array): Functions and fields that style the `body`
//      or the `children` (in reverse order)
//
// This is the complementary function to `wrap-content()`.
//
// If the content is empty [ ] or has the field "body", there is
// nothing more to unwrap. The tree is returned with the key "body".
// If the content has the field "children", run this function recursively
// for each child. The tree is returned with the key "children".
// If the content has the field "body" or "child", just store the functions
// that wrap the content as new `layers`.
//
// If the content contains text, regular minus signs "-" are replaced by
// 'math' minus signs "−". The difference between the two characters is not
// directly visible. Only when the exponents are actually formatted there
// is a visible difference.
#let unwrap-content(c) = {
  let layers = ()
  while true {
    // the exit conditions will return different keys
    if c == [ ] { return (body: " ", layers: layers.rev()) } else if c.has("text") {
      return (body: c.text.replace("-", "−"), layers: layers.rev())
    } else if c.has("children") {
      let children = ()
      // discard "empty" content (or rather content with a single space inside)?
      for child in c.children { children.push(unwrap-content(child)) }
      return (children: children, layers: layers.rev())
    }

    // get the `func` and `fields` before stepping into the next layer...
    let func = c.func()
    let fields = c.fields()
    // ...and remove the "body" or "child" from the `fields`!
    if c.has("body") { c = fields.remove("body") } else if c.has("child") { c = fields.remove("child") }
    layers.push((func, fields))
  }
}

// Walk the content tree to find (body) leaves and their paths
//
// - tree (array): The content tree from `unwrap-content()`
// - path (array, optional): The parent path, defaults to ()
// -> leaves (array): Each leaf has the keys "body" and "path"
#let find-leaves(tree, path: ()) = {
  // wrap the dictionary in a list to always have the same return type
  if "body" in tree.keys() { return ((body: tree.body, path: path),) }
  tree.children.enumerate().map(((i, child)) => find-leaves(child, path: (..path, i))).join()
}

// Apply (function) layers to a content object
//
// - c (content): The content to wrap in the functions
// - layers (array): The layers from `unwrap-content()`
// -> c (content)
//
// This is the complementary function to `unwrap-content()`.
//
// Each layer consists of a function and an (optional) fields dictionary.
// If the fields have the key "styles", they have to be passed as unnamed
// arguments to the function. This is the case when the `text()` function
// is used. The content will then be wrapped in the function `styled()`
// and there will be a field called "styles".
// In all other cases the fields can simply be destructured "into" the
// function call. This will also work if the dictionary is empty.
#let wrap-content(c, layers) = {
  for (func, fields) in layers {
    if "styles" in fields.keys() { c = func(c, fields.styles) } else { c = func(c, ..fields) }
  }
  c
}

// Apply (function) layers to a content object in math mode
//
// - c (content/str): The content to wrap in the functions
// - layers (array): The layers from `unwrap-content()`
// - decimal-separator (content/str): The separator to replace the decimal point "."
// -> c (content)
//
// Compared to `wrap-content()` this function will replace functions
// by their counterparts in math mode. See the following list:
//    strong -> math.bold
//    emph -> math.italic
//
// If the decimal-separator has to be changed, the string `c` is split
// at the "." and joined with the decimal-separator again.
#let wrap-content-math(c, layers, decimal-separator: none) = {
  if (type(c) == str) and ("." in c) and (decimal-separator != none) {
    c = c.split(".").join(decimal-separator)
  }

  for (func, fields) in layers {
    if func == strong { func = math.bold }
    if func == emph { func = math.italic }
    if "styles" in fields.keys() { c = func(c, fields.styles) } else { c = func(c, ..fields) }
  }
  math.equation(c)
}

// Wrap a component in the layers of the (content) tree
//
// - component (dictionary)
//    - body (str): The text of the component
//    - path (array): The path to the component in the `tree`
// - tree (array): The content tree from `unwrap-content()`
// - decimal-separator (content/str): The separator to replace the decimal point "."
// - apply-parent-layers (boolean): Apply the outermost layers, defaults to
//   `false`. This is useful to apply the outermost layer somewhere else if it
//   affects more than just the extracted components of a number/unit.
// -> (content)
#let wrap-component(component, tree, decimal-separator, apply-parent-layers: false) = {
  let (body: s, path: path) = component
  if path.len() == 0 {
    // call the function `wrap-content-math()` either way since the decimal-separator
    // replacement is handled there
    if apply-parent-layers {
      return wrap-content-math(s, tree.layers, decimal-separator: decimal-separator)
    } else {
      return wrap-content-math(s, (), decimal-separator: decimal-separator)
    }
  }

  // descend into the next level of the hierarchy...
  let child-tree = tree.children.at(path.remove(0))
  let c = wrap-component(
    (body: s, path: path),
    child-tree,
    decimal-separator,
    apply-parent-layers: true,
  )
  if apply-parent-layers { wrap-content-math(c, tree.layers) } else { c }
}
