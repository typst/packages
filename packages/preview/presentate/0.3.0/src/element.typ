// IDEA: There are two modes of parsing: array and content mode. Content mode
// assumes every parsable element is a content, so the parser terminates when
// the data is not a content. However, array mode assumes every element is an
// array with only one member, which must not be an array or parsable.
#import "utils.typ" as utils: strfmt
#import "indices.typ"

#let sequence = [].func()
#let styled = [#set text(fill: red)].func()
#let identity(it) = it

// Use .. to indicate the spread of positional arguments
#let content-positionals = (
  // models
  ([].func(), "children"),
  ([#set text(fill: red)].func(), "child", "styles"),
  (text, "text"),
  (enum.item, "number", "body"),
  (list.item, "body"),
  (terms.item, "term", "description"),
  (metadata, "value"),
  (footnote.entry, "note"),
  (link, "dest", "body"),
  (ref, "target"),
  (align, "alignment", "body"),
  (columns, "count", "body"),
  (place, "alignment", "body"),
  (rotate, "angle", "body"),
  (curve, "..components"),
  (polygon, "..vertices"),
  // Math functions
  (math.attach, "base"),
  ($a$.body.func(), "text"),
  (math.frac, "num", "denom"),
  (math.accent, "base", "accent"),
  (math.binom, "upper", "lower"),
  (math.class, "class", "body"),
  (math.mat, "..rows"),
  (math.primes, "count"),
  (math.root, (index: "2"), "radicand"),
  (math.underbrace, "body", "annotation"),
  (math.overbrace, "body", "annotation"),
  (math.underbracket, "body", "annotation"),
  (math.overbracket, "body", "annotation"),
  (math.underparen, "body", "annotation"),
  (math.overparen, "body", "annotation"),
  (math.undershell, "body", "annotation"),
  (math.overshell, "body", "annotation"),
)

#let content-functions = content-positionals.map(info => info.first())

#let content-no-parse = (
  [#state("_").update(none)].func(),
  (context {}).func(),
  $a$.body.func(),
  layout,
  image,
  bibliography,
  outline,
  cite,
  text,
  heading,
  h,
  v,
)

#let containers = (
  sequence,
  styled,
  grid.cell,
  table.cell,
)

#let empty-content = ([], [ ], parbreak(), linebreak(), pagebreak(), colbreak())

#let object(type, ..properties) = (
  __presentate-object-type__: type,
  ..properties.named(),
)

#let is-object(obj) = type(obj) == dictionary and "__presentate-object-type__" in obj.keys()

#let type-of(obj) = if is-object(obj) { obj.__presentate-object-type__ } else { type(obj) }

#let peek(i, arr: ()) = arr.at(i, default: none)

#let empty-object = object("empty")

#let mode-wrapper(mode, info) = {
  if mode == "array" { return (info,) }
  if mode == "content" { return [#metadata(info)<__presentate-mark__>] }
  panic(strfmt("Unknown mode `{}`, expected: \"array\" or \"content\".", mode))
}

// Presentate's element constructor
#let element(
  func,
  fields: (:),
  positionals: (),
  ..others,
) = object(
  "element",
  func: func,
  positionals: positionals,
  fields: fields,
  ..others,
)

#let join(children, ..props) = element(
  array.sum,
  fields: (children: children),
  positionals: ("children",),
  hidable: false,
  ..props,
)

#let generic(body, func, named: (:), ..props) = element(
  func,
  fields: (body: body) + named,
  positionals: ("body",),
  ..props,
)

#let collect(children, func, named: (:), ..props) = element(
  func,
  fields: (children: children) + named,
  positionals: ("..children",),
  ..props,
)

#let state-updater(func) = object("state-updater", func: func)

#let state-getter(func) = object("state-getter", func: func)

#let updater(mode: "content", func) = mode-wrapper(mode, state-updater(func))

#let getter(mode: "content", func) = mode-wrapper(mode, state-getter(func))

#let applier(mode: "content", template: generic, ..args) = mode-wrapper(mode, template(mode: mode, ..args))

/// Label contents such that the label will only appear once.
/// Example usage:
/// ```typst
/// #labeler(
///   figure(image("example.png"), caption: [A caption.]),
///   <name>
/// )
/// From @name, it is an example.
/// ```
/// -> content
#let labeler(
  /// The content to get labeled.
  /// -> content
  body,
  /// The label 
  /// -> label
  name,
) = getter(s => {
  if s.at(0).subslide == s.at(0).steps { [#body#name] } else { body }
})

/// A custom interface that makes Presentate reach the content inside.
/// -> function
#let interface(
  /// The environment function. Such as `cetz.canvas`.
  /// -> function
  func,
  /// Inner mode of parsing
  /// -> "array" | "content"
  inner: "array",
  /// Outer mode of parsing, i.e. the environment surrounding this element.
  /// -> "array" | "content"
  outer: "content",
  /// Default hider used by `pause`
  /// -> function | auto
  hider: auto,
) = (..args) => mode-wrapper(outer, collect(
  args.pos(),
  func,
  mode: inner,
  named: args.named(),
  inner-hider: hider,
))

/// Another custom interface, used within the `interface`, i.e.
/// when the inner and outer mode is the same. You can use this to wraps around `context` in content mode.
///
/// -> function
#let bridge(
  /// The sub-environment function, such as `group()` in CeTZ or `branch()` in alchemist package.
  /// -> function
  func,
  /// Mode of parsing, which determines the 'kind' of content inside.
  /// -> "array" | "content"
  mode: "array",
  ..props,
) = (..args) => applier(
  args.pos(),
  func,
  mode: mode,
  named: args.named(),
  template: collect,
  ..props,
)

// Assume that every content can be deconstructed to a dictionary containing 1)
// its element function, 2) its reconstructed fields dictionary. The field
// dictionary as two sub-fields: named and positional fields, which are
// important for reconstruct such element.
#let reconstruct-one(elem, states: ()) = {
  if type-of(elem) != "element" { return elem }

  let (positionals, fields, func) = elem
  let named = fields
  let pos = ()
  let label
  // restore the positional arguments.
  for arg in positionals {
    let value = empty-object
    let name = arg
    if type(arg) == dictionary {
      value = arg.values().first()
      name = arg.keys().first()
    }
    // Extract from the fields
    if name.trim("..") in fields.keys() {
      value = named.remove(name.trim(".."))
    }
    // Spread
    if name.starts-with("..") {
      pos += value
    } else {
      pos.push(value)
    }
  }

  if "label" in named.keys() {
    label = named.remove("label")
  }

  pos = pos.filter(it => not type-of(it) == "empty")

  if elem.at("contextual", default: false) { func = func.with(states) }
  // restored element
  let restored = func(..pos, ..named)
  // returning phase...
  if elem.at("mode", default: auto) != "content" { return restored }
  if label != none { return [#restored#label] }

  return restored
}

// Main element reconstruction function.
#let reconstruct(
  tree,
  states: (),
  scope: (
    item-counter: 0,
    item-lead-parbreak: false,
    item-follow-parbreak: false,
    hider: auto,
  ),
) = {
  // Hiding element mechanism 
  //
  // There are 3 states governing the hiding of an element. 
  // The first is `pause-state.hidden`, which is controlled by put a `#pause`, `#jump()`, or `#meanwhile` markers.
  // The second is `uncover-state.hidden` which is controlled by the animation functions such as `#uncover()`, `#only()`, `#alert()`, and others (except `#render()` and `#motion()`, since the inner function is not accessible.)
  // The third is `hidden-leader`, which is like a decision maker that tells whether an element should be hidden because of applying `#pause` or `#uncover`.  
  states.at(0).parsing-state.shown = false

  let hiding(s) = if s.at(0).hidden-leader == "pause" {
    s.at(0).pause-state.hidden
  } else if s.at(0).hidden-leader == "uncover" {
    s.at(0).uncover-state.hidden
  }
  // for scoped hider, the `inner-hider` of an element property.
  let hider = if scope.hider == auto {
    states.at(0).pause-state.hider
  } else { scope.hider }
  // decision whether an element is showing or hiding
  let visible(s) = {
    not hiding(s) or s.at(0).parsing-state.shown
  }

  let item-funcs = (enum.item, list.item)

  if type-of(tree) == array {
    let peek = peek.with(arr: tree)
    let item-object = object(
      "item",
      group: (),
      tight: true,
      lead-parbreak: false,
      follow-parbreak: false,
    )

    let allowed-empty-between-item(it) = (
      (it in ([], [ ], parbreak()))
        or {
          type-of(it) == "state-updater"
        }
    )
    let allowed-between-item(it) = (
      allowed-empty-between-item(it)
        or {
          type-of(it) == "element" and it.func in item-funcs
        }
    )

    let this-item = item-object
    let item-count = 0
    let inter-tree = ()
    // Get properties about items. This `inter-tree` parsing must not
    // remove/insert any elements. All elements can be categorized into 3
    // groups: 1) the allowed between items, but present before the items, 2)
    // the allowed between items, and 3) the not-allowed between items. This
    // loop will handle all of these cases.
    for (i, sub-tree) in tree.enumerate() {
      if type-of(sub-tree) == "element" {
        if sub-tree.func in item-funcs {
          item-count += 1
          if item-count == 1 {
            this-item.lead-parbreak = peek(i - 1) == parbreak()
          }
        }
      }
      // The allowed between items, after the first item.
      if item-count > 0 and allowed-between-item(sub-tree) {
        this-item.group.push(sub-tree)
        if sub-tree == parbreak() { this-item.tight = false }
      }
      // The not-allowed between items, after the first item. This will
      // terminates item groupping.
      if not allowed-between-item(sub-tree) and item-count > 0 {
        item-count = 0
        this-item.follow-parbreak = true
        inter-tree.push(this-item)
        this-item = item-object
      }
      // The other not-allowed between items
      if not allowed-between-item(sub-tree) {
        inter-tree.push(sub-tree)
      }
      // The allowed between items, but present before the items.
      if item-count == 0 and allowed-empty-between-item(sub-tree) {
        inter-tree.push(sub-tree)
      }
    }
    // Collect the leftover.
    if item-count > 0 { inter-tree.push(this-item) }
    // length of the array must be preserved to ensure no element is dropped.
    if inter-tree.map(it => if type-of(it) == "item" { it.group } else { (it,) }).sum(default: ()).len() != tree.len() {
      panic(strfmt("Intermediate parsing of items failed, inter-tree={}, tree={}", inter-tree.len(), tree.len()))
    }
    // main reconstruction loop.
    let new-tree = ()
    let shown-tag = false
    for sub-tree in inter-tree {
      // Force realization of tight or non-tight items, which will be important
      // for determining item spacing later.
      if type-of(sub-tree) == "item" {
        scope.item-counter = 0
        scope.item-lead-parbreak = sub-tree.lead-parbreak
        scope.item-follow-parbreak = sub-tree.follow-parbreak
        scope.item-tight = sub-tree.tight
        // The loop is important to see the states' updates sequentially.
        for item in sub-tree.group {
          if type-of(item) == "element" and item.func in item-funcs {
            scope.item-counter += 1
          }
          (states, item) = reconstruct(item, states: states, scope: scope)
          if visible(states) { shown-tag = true }
          new-tree.push(item)
        }
        // reset item counter
        scope.item-counter = 0
      } else {
        // Elements-other-than-items' reconstruction.
        (states, sub-tree) = reconstruct(sub-tree, states: states, scope: scope)
        if visible(states) { shown-tag = true }
        new-tree.push(sub-tree)
      }
    }
    // If the visible state of any child in a children is 'shown', the parent
    // element will not be hidden -> parsing.state.shown = true
    if shown-tag {
      states.at(0).parsing-state.shown = shown-tag
    }
    // filtering out the updater
    new-tree = new-tree.filter(it => type-of(it) != "state-updater")

    return (states, new-tree)
  }

  if type-of(tree) == "state-updater" {
    states = (tree.func)(states)
    return (states, tree)
  }

  if type-of(tree) == "state-getter" {
    return reconstruct((tree.func)(states), states: states)
  }

  if type-of(tree) != "element" {
    return (states, tree)
  }

  let wrapper(s, body) = {
    let hider = hider
    let normal = identity
    // Resolving spacing between items. This will break the items but force the
    // label to be hidden.
    if tree.func in item-funcs {
      if scope.item-counter == 1 and not scope.item-tight {
        normal = it => parbreak() + it
      }

      hider = it => hider(context {
        if not scope.item-tight { return block(it) }

        let style = (:)
        if scope.item-counter == 1 {
          if scope.item-lead-parbreak {
            style.above = par.spacing
          } else {
            style.above = par.leading
          }
        } else if scope.item-counter > 1 {
          if not scope.item-follow-parbreak {
            style.below = par.leading
          }
          style.above = par.leading
        }

        block(..style, it)
      })
    }

    // Only when the parent element does not contain any visible children will its
    // element be hidden.
    if not s.at(0).parsing-state.shown and hiding(states) {
      hider(body)
    } else {
      normal(body)
    }
  }

  let states-prior = states
  // scoped hider for inner element if specified.
  if tree.at("inner-hider", default: auto) != auto {
    scope.hider = tree.inner-hider
  }

  for (k, v) in tree.fields.pairs() {
    (states, v) = reconstruct(v, states: states, scope: scope)
    tree.fields.at(k) = v
  }
  // context provided to the element must be prior to its children.
  let restored = reconstruct-one(tree, states: states-prior)
  // some intermediate elements are not hidable.
  if tree.at("hidable", default: true) { restored = wrapper(states, restored) }

  return (states, restored)
}

// Assume every element is a content, which can be destructed into its fields /
// and element function. The native 'parsed' element will be stored in
// `metadata` function.
#let make-tree(
  body,
  states: (),
  scope: (
    mode: "content",
    semantic-array: false,
  ),
) = {
  // if scope.mode == "array" { scope.semantic-array = true }
  let make-tree = make-tree.with(scope: scope)

  if type-of(body) == "state-updater" {
    states = (body.func)(states)
    return (states, body)
  }

  if type-of(body) == "state-getter" {
    (states, _) = make-tree((body.func)(states), states: states)
    return (states, body)
  }

  if type-of(body) == "element" {
    // change the mode according to the element. Important for `interface`.
    if body.at("mode", default: auto) != auto { scope.mode = body.mode }
    for (k, v) in body.fields.pairs() {
      let new-value
      // this array is NOT a semantic array, it is just a container.
      if { ".." + k } in body.positionals {
        new-value = ()
        for sub-tree in v {
          (states, sub-tree) = make-tree(sub-tree, states: states, scope: scope)
          new-value.push(sub-tree)
        }
      } else {
        (states, new-value) = make-tree(v, states: states, scope: scope)
      }
      // set the new, parsed value to the fields.
      body.fields.at(k) = new-value
    }
    return (states, body)
  }

  if type-of(body) == array {
    // Handling array joining elements, such as in CeTZ, by separating each
    // joined element into individuals, and suming them later. The normal
    // sequence will work as usual.
    let new-tree = ()
    for sub-tree in body {
      // unwrap double concealed element, such as (pause,)
      if type-of(sub-tree) == content and sub-tree.func() == metadata and is-object(sub-tree.value) {
        sub-tree = sub-tree.value
      }
      // protect the inner element
      if scope.mode == "array" and not is-object(sub-tree) {
        let make-array(it) = (it,)
        sub-tree = generic(sub-tree, make-array, mode: scope.mode)
      }
      // then generate tree
      (states, sub-tree) = make-tree(sub-tree, states: states)

      new-tree.push(sub-tree)
    }
    // This `join` will cancels the splitted sub-arrays of the assumed elements.
    if scope.mode == "array" { new-tree = join(new-tree, mode: scope.mode) }
    return (states, new-tree)
  }

  if type-of(body) != content {
    return (states, body)
  }

  if body.func() == metadata and is-object(body.value) {
    return make-tree(body.value, states: states, scope: scope)
  }

  if body in empty-content {
    return (states, body)
  }

  if body.func() in content-no-parse {
    let no-parse() = body
    return (states, element(no-parse))
  }

  let func = body.func()
  let positionals = ()

  if func not in content-functions {
    if body.has("body") {
      positionals.push("body")
    } else if body.has("child") {
      positionals.push("child")
    } else if body.has("children") {
      positionals.push("..children")
    } else if body.has("text") {
      positionals.push("text")
    }
  } else {
    (_, ..positionals) = content-positionals.find(f => f.first() == func)
  }

  return make-tree(
    element(
      func,
      fields: body.fields(),
      positionals: positionals,
      hidable: not func in containers,
    ),
    states: states,
  )
}
