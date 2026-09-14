/// Content splitting algorithm

#import "../geometry.typ"

/// Tests if content fits inside a box.
///
/// WARNING: horizontal fit is not strictly checked
///
/// The closure of this function constitutes the basis of the entire content
/// splitting algorithm: iteratively add content until it no longer `fits-inside`,
/// with what "iteratively add content" means being defined by the content structure.
/// Essentially all remaining functions in this file are about defining content
/// that can be split and the correct way to invoke `fits-inside` on them.
///
/// ```example
/// #let dims = (width: 100%, height: 50%)
/// #box(width: 7cm, height: 3cm)[#layout(size => context {
///   let words = [#lorem(12)]
///   [#fits-inside(dims, words, size: size)]
///   linebreak()
///   box(..dims, stroke: 0.1pt, words)
/// })]
/// ```
///
/// ```example
/// #let dims = (width: 100%, height: 50%)
/// #box(width: 7cm, height: 3cm)[#layout(size => context {
///   let words = [#lorem(15)]
///   [#fits-inside(dims, words, size: size)]
///   linebreak()
///   box(..dims, stroke: 0.1pt, words)
/// })]
/// ```
///
/// -> bool
#let fits-inside(
  /// Maximum container dimensions. Relative lengths are allowed.
  /// -> (width: relative, height: relative)
  dims,
  /// Content to fit in.
  /// -> content
  ct,
  /// Dimensions of the parent container to resolve relative sizes.
  /// These must be absolute sizes.
  /// -> (width: length, height: length)
  size: none,
) = {
  assert(size != none)
  let content = measure(box(width: dims.width)[#ct], ..size)
  let container = geometry.resolve(size, ..dims)
  content.height <= container.height
}

/// Destructure and rebuild content, separating the outer content builder
/// from the rest to allow substituting the inner contents.
/// In practice what we will usually do is recursively split the inner contents
/// and rebuild the left and right halves separately.
///
/// Inspired by `wrap-it`'s implementation
/// (see: `_rewrap` in #link("https://github.com/ntjess/wrap-it/blob/main/wrap-it.typ")[`github:ntjess/wrap-it`])
///
/// ```example
/// #let content = box(stroke: red)[Initial]
/// #let (inner, rebuild) = default-rebuild(
///   content, "body",
/// )
///
/// Content: #content \
/// Inner: #inner \
/// Rebuild: #rebuild("foo")
/// ```
///
/// ```example
/// #let content = [*_Initial_*]
/// #let (inner, rebuild) = default-rebuild(
///   content, "body",
/// )
///
/// Content: #content \
/// Inner: #inner \
/// Rebuild: #rebuild("foo")
/// ```
///
/// ```example
/// #let content = [a:b]
/// #let (inner, rebuild) = default-rebuild(
///   content, "children",
/// )
///
/// Content: #content \
/// Inner: #inner \
/// Rebuild: #rebuild(([x], [y]))
/// ```
///
/// -> (dictionnary, function)
#let default-rebuild(
  /// -> content
  ct,
  /// What "inner" field to fetch (e.g. `"body"`, `"text"`, `"children"`, etc.)
  /// -> string
  inner-field,
) = {
  let fields = ct.fields()
  // These fields are positional, but stored in the dictionary as named.
  let inner = fields.remove(inner-field)
  let number = if "number" in fields { (fields.remove("number"),) } else { () }
  let styles = if "styles" in fields { (fields.remove("styles"),) } else { () }
  // Construct the closure
  let rebuild(inner) = {
    let pos = (inner, ..number, ..styles)
    ct.func()(..fields, ..pos)
  }
  (inner, rebuild)
}

/// "Split" opaque content.
/// -> (content?, content?)
#let take-it-or-leave-it(
  /// This content cannot be split.
  /// If it fits take it, otherwise keep it for later.
  /// -> content
  ct,
  /// Closure to determine if the content fits (see `fits-inside` above). -> function
  fits-inside,
) = {
  if fits-inside(ct) {
    (ct, none)
  } else {
    (none, ct)
  }
}

/// Split content with a `"text"` main field.
/// Strategy: split by `" "` and take all words that fit.
#let has-text(
  /// Content to split. -> content
  ct,
  /// Recursively passed around (see `split-dispatch` below). -> function
  split-dispatch,
  /// Closure to determine if the content fits (see `fits-inside` above). -> function
  fits-inside,
  /// Extra configuration options. -> dictionary
  cfg,
) = {
  let (inner, rebuild) = default-rebuild(ct, "text")
  let inner = inner.split(" ")
  if not fits-inside([]) {
    return (none, ct)
  }
  for i in range(inner.len()) {
    if fits-inside(rebuild(inner.slice(0, i + 1).join(" "))) {
      continue
    } else {
      let left = rebuild(inner.slice(0, i).join(" "))
      assert(fits-inside(left))
      let right = rebuild(inner.slice(i).join(" "))
      return (left, right)
    }
  }
  return (rebuild(inner.join(" ")), none)
}

/// Split content with a `"child"` main field.
/// Strategy: recursively split the child.
#let has-child(
  /// Content to split. -> content
  ct,
  /// Recursively passed around (see `split-dispatch` below). -> function
  split-dispatch,
  /// Closure to determine if the content fits (see `fits-inside` above). -> function
  fits-inside,
  /// Extra configuration options. -> dictionary
  cfg,
) = {
  let (inner, rebuild) = default-rebuild(ct, "child")
  let (left, right) = split-dispatch(inner, ct => fits-inside(rebuild(ct)), cfg)
  assert(fits-inside(rebuild(left)))
  (rebuild(left), rebuild(right))
}

/// Split content with a `"children"` main field.
/// Strategy: take all children that fit.
#let has-children(
  /// Content to split. -> content
  ct,
  /// Recursively passed around (see `split-dispatch` below). -> function
  split-dispatch,
  /// Closure to determine if the content fits (see `fits-inside` above). -> function
  fits-inside,
  /// Extra configuration options. -> dictionary
  cfg,
) = {
  let (inner, rebuild) = default-rebuild(ct, "children")
  if not fits-inside([]) { return (none, ct) }
  for i in range(inner.len()) {
    // If inner.at(i) fits, take it
    if fits-inside(rebuild(inner.slice(0, i + 1))) {
      continue
    } else {
      // Otherwise try to split it
      let hanging = inner.at(i)
      let (left, right) = split-dispatch(hanging, ct => fits-inside(rebuild((..inner.slice(0, i), ct))), cfg)
      assert(fits-inside(rebuild((..inner.slice(0, i), left))))
      let left = rebuild({
        if left == none {
          if i == 0 {
            return (none, rebuild(inner))
          } else {
            inner.slice(0, i)
          }
        } else {
          (..inner.slice(0, i), left)
        }
      })
      let right = rebuild({
        if right == none {
          inner.slice(i + 1)
        } else {
          (right, ..inner.slice(i + 1))
        }
      })
      return (left, right)
    }
  }
  return (rebuild(inner), none)
}

/// Split a `list.item`.
/// Strategy: recursively split the `body`, and do some magic to simulate
/// a bullet point indent.
#let is-list-item(
  /// Content to split. -> content
  ct,
  /// Recursively passed around (see `split-dispatch` below). -> function
  split-dispatch,
  /// Closure to determine if the content fits (see `fits-inside` above). -> function
  fits-inside,
  /// Extra configuration options. -> dictionary
  cfg,
) = {
  let (inner, rebuild) = default-rebuild(ct, "body")
  let (left, right) = {
    let cfg = cfg
    cfg.list-depth += 1
    split-dispatch(inner, ct => fits-inside(rebuild(ct)), cfg)
  }
  let left = if left == none { none } else {
    assert(fits-inside(rebuild(left)))
    rebuild(left)
  }
  let right = if right == none {
    none
  } else if left == none {
    rebuild(right)
  } else {
    // Here we need to do some magic to handle list items that were split in half.
    if cfg.list-depth >= cfg.list-markers.len() {
      panic("Not enough list markers. Decrease nesting or provide `cfg.list-markers`")
    }
    for i in range(cfg.list-depth + 1) {
      cfg.list-markers.at(i) = h(0.5em)
    }
    // TODO: improve the ad-hoc spacing
    [#set list(marker: cfg.list-markers); #rebuild(right)]
  }
  (left, right)
}

/// Split an `enum.item`.
/// Strategy: recursively split the `body`, and do some magic to simulate
/// a numbering indent.
#let is-enum-item(
  /// Content to split. -> content
  ct,
  /// Recursively passed around (see `split-dispatch` below). -> function
  split-dispatch,
  /// Closure to determine if the content fits (see `fits-inside` above). -> function
  fits-inside,
  /// Extra configuration options. -> dictionary
  cfg,
) = {
  let (inner, rebuild) = default-rebuild(ct, "body")
  let (left, right) = {
    let cfg = cfg
    cfg.enum-depth += 1
    split-dispatch(inner, ct => fits-inside(rebuild(ct)), cfg)
  }
  let left = if left == none { none } else {
    assert(fits-inside(rebuild(left)))
    rebuild(left)
  }
  let right = if right == none {
    none
  } else if left == none {
    rebuild(right)
  } else {
    // Again, some magic to simulate a `enum.item` split in half
    if cfg.enum-depth >= cfg.enum-numbering.len() {
      panic("Not enough enum markers. Decrease nesting or provide `cfg.enum-numbering`")
    }
    for i in range(cfg.enum-depth + 1) {
      cfg.enum-numbering.at(i) = ""
    }
    let numbering = (..nums) => {
      let nums = {
        if nums.pos().len() <= cfg.enum-depth {
          ()
        } else {
          nums.pos().slice(cfg.enum-depth + 1)
        }
      }
      if nums == () {
        h(0.7em) // TODO: improve the ad-hoc spacing
      } else {
        numbering(cfg.enum-numbering.join(""), ..nums)
      }
    }
    // TODO: improve the ad-hoc spacing
    [#set enum(full: true, numbering: numbering); #rebuild(right)]
  }
  (left, right)
}

/// Split content with a `"body"` main field.
/// There is a special strategy for `list.item` and `enum.item` which are handled
/// separately. Elements `strong`, `emph`, `underline`, `stroke`, `overline`,
/// `highlight` are splittable, the rest are treated as non-splittable.
#let has-body(
  /// Content to split. -> content
  ct,
  /// Recursively passed around (see `split-dispatch` below). -> function
  split-dispatch,
  /// Closure to determine if the content fits (see `fits-inside` above). -> function
  fits-inside,
  /// Extra configuration options. -> dictionary
  cfg,
) = {
  if ct.func() == list.item {
    is-list-item(ct, split-dispatch, fits-inside, cfg)
  } else if ct.func() == enum.item {
    is-enum-item(ct, split-dispatch, fits-inside, cfg)
  } else if ct.func() in (strong, emph, underline, stroke, overline, highlight) {
    let (inner, rebuild) = default-rebuild(ct, "body")
    let (left, right) = split-dispatch(inner, ct => fits-inside(rebuild(ct)), cfg)
    assert(fits-inside(rebuild(left)))
    (rebuild(left), rebuild(right))
  } else {
    take-it-or-leave-it(ct, fits-inside)
  }
}

/// Based on the fields on the content, call the appropriate splitting
/// function. This function is involved in a mutual recursion loop, which is
/// why all other splitting functions take this one as a parameter.
#let dispatch(
  /// Content to split. -> content
  ct,
  /// Closure to determine if the content fits (see `fits-inside` above). -> function
  fits-inside,
  /// Extra configuration options. -> dictionary
  cfg,
) = {
  if ct.has("text") {
    has-text(ct, dispatch, fits-inside, cfg)
  } else if ct.has("child") {
    has-child(ct, dispatch, fits-inside, cfg)
  } else if ct.has("children") {
    has-children(ct, dispatch, fits-inside, cfg)
  } else if ct.has("body") {
    has-body(ct, dispatch, fits-inside, cfg)
  } else {
    // This item is not splittable
    take-it-or-leave-it(ct, fits-inside)
  }
}

/// Initialize default configuration options and take as much content as fits
/// in a box of given size.
#let fill-box(
  /// Container size.
  /// -> (width: length, height: length)
  dims,
  /// Content to split.
  /// -> content
  ct,
  /// Parent container size.
  /// -> (width: length, height: length)
  size: (:),
  /// Configuration options.
  ///
  /// - `list-markers: (..content,)`, default value #{([•], [‣], [–]) * 2}.
  ///   If you change the markers of `list`, put the new value in the parameters
  ///   so that `list`s are correctly split.
  /// - `enum-numbering: (..str,)`, default value #{("1.",) * 6}.
  ///   If you change the numbering style of `enum`, put the new style in
  ///   the parameters so that `enum`s are correctly split.
  ///
  /// -> dictionary
  cfg: (:),
) = {
  if "list-markers" not in cfg {
    cfg.insert("list-markers", ([•], [‣], [–]) * 2)
  }
  cfg.insert("list-depth", 0)
  if "enum-numbering" not in cfg {
    cfg.insert("enum-numbering", ("1.",) * 6)
  }
  cfg.insert("enum-depth", 0)
  /*if "allow-horiz-overflow" not in cfg {
    cfg.insert("allow-horiz-overflow", false)
  }*/
  // TODO: include vertical and horizontal spacing here.
  dispatch(ct, ct => fits-inside(dims, ct, size: size), cfg)
}

