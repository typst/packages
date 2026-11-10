/// Content splitting algorithm

#import "geometry.typ"
#import "normalize.typ"

#let symbol_func = [#sym.chevron.l].func()

/// #property(requires-context: true)
/// Tests if content fits inside a box.
/// #warning-alert[
///   Horizontal fit is not very strictly checked
///   A single word may be said to fit in a box that is less wide than the word.
///   This is an inherent limitation of `measure(box(...))` and I will try
///   to develop workarounds for future versions.
/// ]
///
/// The closure of this function constitutes the basis of the entire content
/// splitting algorithm: iteratively add content until it no longer fits inside the box,
/// with what "iteratively add content" means being defined by the content structure.
/// Essentially all remaining functions in this file are about defining content
/// that can be split and the correct way to invoke @cmd:bisect:fits-inside on them.
///
/// ```typ
/// #let dims = (width: 100%, height: 50%)
/// #box(width: 7cm, height: 3cm)[#layout(size => context {
///   let words = [#lorem(12)]
///   [#fits-inside(dims, words, size: size)]
///   linebreak()
///   box(..dims, stroke: 0.1pt, words)
/// })]
/// ```
///
/// ```typ
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
/// Inspired by #universe("wrap-it")'s implementation
/// (see: #cmd("_rewrap") in #link("https://github.com/ntjess/wrap-it/blob/main/wrap-it.typ")[`github:ntjess/wrap-it`])
///
/// ```typ
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
/// ```typ
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
/// ```typ
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
  /// What "inner" field to fetch (e.g. ```typc "body"```, ```typc "text"```,
  /// ```typc "children"```, etc.)
  /// -> string
  inner-field,
) = {
  let fields = ct.fields()
  // These fields are positional, but stored in the dictionary as named.
  let inner = fields.remove(inner-field)
  let splat-inner = (inner-field == "children" and ct.func() in (enum, list))
  let number = if "number" in fields { (fields.remove("number"),) } else { () }
  let alignment = if "alignment" in fields { (fields.remove("alignment"),) } else { () }
  let dest = if "dest" in fields { (fields.remove("dest"),) } else { () }
  let styles = if "styles" in fields { (fields.remove("styles"),) } else { () }
  // Construct the closure
  let rebuild(inner) = {
    assert(inner != none)
    let inner = if splat-inner {
      (..inner,)
    } else {
      (inner,)
    }
    let pos = (..dest, ..inner, ..number, ..styles, ..alignment)
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
  /// Closure to determine if the content fits (see @cmd:bisect:fits-inside). -> function
  fits-inside,
) = {
  if fits-inside(ct) {
    (ct, none)
  } else {
    (none, ct)
  }
}

/// Split one word according to hyphenation patterns, if enabled.
/// -> (content?, content?)
#let split-word(
  /// Word to split.
  /// -> string
  ww,
  /// Closure to determine if the content fits (see @cmd:bisect:fits-inside). -> function
  fits-inside,
  /// Extra configuration options. -> dictionary
  cfg,
) = {
  assert(cfg.hyphenate != false)
  import "@preview/hy-dro-gen:0.1.1" as hy
  let syllables = hy.syllables(ww, lang: cfg.lang, fallback: auto)
  for i in range(syllables.len()) {
    if fits-inside(syllables.slice(0, i + 1).join("") + "-") {
      continue
    } else {
      if i == 0 {
        let left = none
        let right = ww
        return (left, right)
      } else {
        let left = syllables.slice(0, i).join("") + "-"
        let right = syllables.slice(i).join("")
        assert(fits-inside(left))
        return (left, right)
      }
    }
  }
  // TODO: assert that left fits and find test case that hits this
  return (left, none)
}

/// Split content with a ```typc "text"``` main field.
///
/// Strategy: split by ```typc " "``` and take all words that fit.
/// Then if hyphenation is enabled, split by syllables and take all syllables
/// that fit.
///
/// End the block with a #typ.linebreak that has the justification of
/// the paragraph, or other based on `cfg.linebreak`.
/// -> (content?, content?)
#let has-text(
  /// Content to split. -> content
  ct,
  /// Recursively passed around (see @cmd:bisect:dispatch). -> function
  split-dispatch,
  /// Closure to determine if the content fits (see @cmd:bisect:fits-inside). -> function
  fits-inside,
  /// Extra configuration options. -> dictionary
  cfg,
) = {
  let (inner, rebuild) = default-rebuild(ct, "text")
  let inner = inner.split(" ")
  let atom = box(width: 0pt, height: 1mm)

  let lbreak = if cfg.linebreak == auto {
    context[#linebreak(justify: par.justify)]
  } else if cfg.linebreak == true {
    linebreak(justify: true)
  } else if cfg.linebreak == false {
    linebreak(justify: false)
  } else if cfg.linebreak == none {
    []
  } else {
    panic("cfg.linebreak does not support the option " + repr(cfg.linebreak))
  }
  let lo = 0
  let hi = 1
  while true {
    if hi >= inner.len() {
      hi = inner.len()
      break
    }
    if fits-inside(rebuild(inner.slice(0, hi + 1).join(" ")) + atom) {
      lo = hi
      hi *= 2
    } else {
      break
    }
  }
  while true {
    if lo + 1 == hi {
      break
    }
    let mid = int((hi + lo) / 2)
    if fits-inside(rebuild(inner.slice(0, mid + 1).join(" ")) + atom) {
      lo = mid
    } else {
      hi = mid
    }
  }
  let final-i = none
  for i in (lo, lo + 1) {
    if fits-inside(rebuild(inner.slice(0, i + 1).join(" ")) + atom) {
      continue
    } else {
      final-i = i
      break
    }
  }
  if final-i == none {
    // TODO: assert that left fits and find test case that hits this
    return (rebuild(inner.join(" ")), none)
  }
  let i = final-i
  if cfg.hyphenate == false {
    let left = if i == 0 { none } else {
      let left = rebuild(inner.slice(0, i).join(" "))
      left += lbreak
      assert(fits-inside(left))
      left
    }
    let right = rebuild(inner.slice(i).join(" "))
    return (left, right)
  } else {
    let overhang = inner.at(i)
    let before = inner.slice(0, i)
    let after = inner.slice(i + 1)
    let (left-rec, right-rec) = split-word(inner.at(i), ww => fits-inside(rebuild((..before, ww).join(" ")) + atom), cfg)
    let left-words = if left-rec == none { before } else {
      (..before, left-rec)
    }
    let left = if left-words == () { none } else {
      rebuild(left-words.join(" ")) + lbreak
    }
    let right-words = if right-rec == none { after } else {
      (right-rec, ..after)
    }
    let right = rebuild(right-words.join(" "))
    return (left, right)
  }
}

/// Split content with a ```typc "child"``` main field.
///
/// Strategy: recursively split the child.
/// -> (content?, content?)
#let has-child(
  /// Content to split. -> content
  ct,
  /// Recursively passed around (see @cmd:bisect:dispatch). -> function
  split-dispatch,
  /// Closure to determine if the content fits (see @cmd:bisect:fits-inside). -> function
  fits-inside,
  /// Extra configuration options. -> dictionary
  cfg,
) = {
  let (inner, rebuild) = default-rebuild(ct, "child")
  let (left, right) = split-dispatch(inner, ct => fits-inside(rebuild(ct)), cfg)
  let left = if left == none { none } else {
    assert(fits-inside(rebuild(left)))
    rebuild(left)
  }
  let right = if right == none { none } else {
    rebuild(right)
  }
  (left, right)
}

/// Split an enum.
/// This generally functions the same as @cmd:bisect:has-children,
/// but the handling of numbers requires some extra trickery.
///
/// Strategy: take all children that fit.
/// -> (content?, content?)
#let is-enum(
  /// Content to split. -> content
  ct,
  /// Recursively passed around (see @cmd:bisect:dispatch). -> function
  split-dispatch,
  /// Closure to determine if the content fits (see @cmd:bisect:fits-inside). -> function
  fits-inside,
  /// Extra configuration options. -> dictionary
  cfg,
) = {
  let (inner, rebuild) = default-rebuild(ct, "children")
  if not fits-inside([]) { return (none, ct) }
  inner = normalize.normalize-enum(inner, cfg.normalize)

  if inner.len() == 0 {
    return (none, none)
  }

  let lo = 0
  let hi = inner.len()
  while true {
    if lo + 1 == hi {
      break
    }
    let mid = int((hi + lo) / 2)
    if fits-inside(rebuild(inner.slice(0, mid + 1))) {
      lo = mid
    } else {
      hi = mid
    }
  }

  let final-i = none
  for i in range(lo, calc.min(hi + 1, inner.len())) {
    // If inner.at(i) fits, take it
    if fits-inside(rebuild(inner.slice(0, i + 1))) {
      continue
    } else {
      final-i = i
      break
    }
  }
  if final-i == none {
    return (rebuild(inner), none)
  }
  assert(lo <= final-i)
  assert(final-i <= hi)
  let i = final-i
  // Otherwise try to split it
  let hanging = inner.at(i)
  let (left, right) = split-dispatch(hanging, ct => fits-inside(rebuild((..inner.slice(0, i), ct))), cfg)
  //assert(fits-inside(rebuild((..inner.slice(0, i), left))))
  let left = {
    if left == none {
      if i == 0 {
        return (none, rebuild(inner))
      } else {
        rebuild(inner.slice(0, i))
      }
    } else {
      rebuild((..inner.slice(0, i), left))
    }
  }
  let right = {
    if right == none {
      rebuild((inner.slice(i + 1),))
    } else {
      right
      // TODO: there is still a spacing issue here, but
      // it might require paragraph normalization.
      //v(par.leading - par.spacing)
      rebuild((..inner.slice(i + 1),))
      //(right, ..inner.slice(i + 1))
    }
  }
  return (left, right)
}


/// Split content with a ```typc "children"``` main field.
///
/// Strategy: take all children that fit.
/// -> (content?, content?)
#let has-children(
  /// Content to split. -> content
  ct,
  /// Recursively passed around (see @cmd:bisect:dispatch). -> function
  split-dispatch,
  /// Closure to determine if the content fits (see @cmd:bisect:fits-inside). -> function
  fits-inside,
  /// Extra configuration options. -> dictionary
  cfg,
) = {
  let (inner, rebuild) = default-rebuild(ct, "children")
  if not fits-inside([]) { return (none, ct) }
  inner = normalize.normalize-seq(inner, cfg.normalize)

  if inner.len() == 0 {
    return (none, none)
  }

  let lo = 0
  let hi = inner.len()
  while true {
    if lo + 1 == hi {
      break
    }
    let mid = int((hi + lo) / 2)
    if fits-inside(rebuild(inner.slice(0, mid + 1))) {
      lo = mid
    } else {
      hi = mid
    }
  }

  let final-i = none
  for i in range(lo, calc.min(hi + 1, inner.len())) {
    // If inner.at(i) fits, take it
    if fits-inside(rebuild(inner.slice(0, i + 1))) {
      continue
    } else {
      final-i = i
      break
    }
  }
  if final-i == none {
    return (rebuild(inner), none)
  }
  assert(lo <= final-i)
  assert(final-i <= hi)
  let i = final-i
  // Otherwise try to split it
  let hanging = inner.at(i)
  let (left, right) = split-dispatch(hanging, ct => fits-inside(rebuild((..inner.slice(0, i), ct))), cfg)
  assert(fits-inside(rebuild((..inner.slice(0, i), left))))
  let left = {
    if left == none {
      if i == 0 {
        return (none, rebuild(inner))
      } else {
        rebuild(inner.slice(0, i))
      }
    } else {
      rebuild((..inner.slice(0, i), left))
    }
  }
  let right = rebuild({
    if right == none {
      inner.slice(i + 1)
    } else {
      (right, ..inner.slice(i + 1))
    }
  })
  return (left, right)
}

/// Split a `list.item`.
///
/// Strategy: recursively split the body, and do some magic to simulate
/// a bullet point indent.
/// -> (content?, content?)
#let is-list-item(
  /// Content to split. -> content
  ct,
  /// Recursively passed around (see @cmd:bisect:dispatch). -> function
  split-dispatch,
  /// Closure to determine if the content fits (see @cmd:bisect:fits-inside). -> function
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
      cfg.list-markers.at(i) = hide(cfg.list-markers.at(i))
    }
    // TODO: improve the ad-hoc spacing
    [#set list(marker: cfg.list-markers); #rebuild(right)]
    //rebuild(right)
    //right
  }
  (left, right)
}

/// Split an `enum.item`.
///
/// Strategy: recursively split the body, and do some magic to simulate
/// a numbering indent.
/// -> (content?, content?)
#let is-enum-item(
  /// Content to split. -> content
  ct,
  /// Recursively passed around (see @cmd:bisect:dispatch). -> function
  split-dispatch,
  /// Closure to determine if the content fits (see @cmd:bisect:fits-inside). -> function
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

/// Split content with a ```typc "body"``` main field.
/// There is a special strategy for ```typc list.item``` and ```typc enum.item```
/// which are handled separately.
/// Elements #typ.strong, #typ.emph, #typ.underline, #typ.stroke, #typ.overline,
/// #typ.highlight, #typ.par, #typ.align, #typ.link are splittable,
/// the rest are treated as non-splittable.
/// -> (content?, content?)
#let has-body(
  /// Content to split. -> content
  ct,
  /// Recursively passed around (see @cmd:bisect:dispatch). -> function
  split-dispatch,
  /// Closure to determine if the content fits (see @cmd:bisect:fits-inside). -> function
  fits-inside,
  /// Extra configuration options. -> dictionary
  cfg,
) = {
  if ct.func() == list.item {
    is-list-item(ct, split-dispatch, fits-inside, cfg)
  } else if ct.func() == enum.item {
    is-enum-item(ct, split-dispatch, fits-inside, cfg)
  } else if ct.func() in (strong, emph, underline, stroke, overline, highlight, par, align, link) {
    let (inner, rebuild) = default-rebuild(ct, "body")
    let (left, right) = split-dispatch(inner, ct => fits-inside(rebuild(ct)), cfg)
    let left = if left == none { none } else {
      assert(fits-inside(rebuild(left)))
      rebuild(left)
    }
    let right = if right == none { none } else {
      rebuild(right)
    }
    (left, right)
  } else {
    take-it-or-leave-it(ct, fits-inside)
  }
}

/// Based on the fields on the content, call the appropriate splitting
/// function. This function is involved in a mutual recursion loop, which is
/// why all other splitting functions take this one as a parameter.
/// -> (content?, content?)
#let dispatch(
  /// Content to split. -> content
  ct,
  /// Closure to determine if the content fits (see @cmd:bisect:fits-inside). -> function
  fits-inside,
  /// Extra configuration options. -> dictionary
  cfg,
) = {
  //panic(cfg)
  if ct.func() == parbreak {
    // TODO: this is very ad-hoc
    take-it-or-leave-it(v(1em), fits-inside)
  } else if ct.has("text") and ct.func() != raw and ct.func() != symbol_func {
    has-text(ct, dispatch, fits-inside, cfg)
  } else if ct.has("child") {
    has-child(ct, dispatch, fits-inside, cfg)
  } else if ct.func() == enum {
    is-enum(ct, dispatch, fits-inside, cfg)
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
/// in a box of given size. Returns a tuple of the content that fits and the
/// content that overflows separated.
/// -> (content, content)
#let fill-box(
  /// Container size.
  /// -> size
  dims,
  /// Content to split.
  /// -> content
  ct,
  /// Parent container size.
  /// -> size
  size: none,
  /// Configuration options.
  ///
  /// - #arg(list-markers: ([•], [‣], [–]) * 2) an array of content describing
  ///   the markers used for list items.
  ///   If you change the default markers, put the new value in the parameters
  ///   so that lists are correctly split.
  /// - #arg(enum-numbering: ("1.",) * 6) an array of numbering patterns for enumerations.
  ///   If you change the numbering style, put the new value in
  ///   the parameters so that enums are correctly split.
  /// - #arg(hyphenate: auto) determines if the text can be hyphenated.
  ///   Defaults to `text.hyphenate`.
  /// - #arg(lang: auto) specifies the language of the text.
  ///   Defaults to `text.lang`.
  /// - #arg(linebreak: auto) determines the behavior of linebreaks at the end
  ///   of boxes. Supports the following values:
  ///   - #typ.v.true $->$ justified linebreak
  ///   - #typ.v.false $->$ non-justified linebreak
  ///   - #typ.v.none $->$ no linebreak
  ///   - #typ.v.auto $->$ linebreak with the same justification as the current paragraph
  /// - #arg(leading: auto) determines the paragraph leading.
  /// - #arg(spacing: auto) determines the paragraph spacing.
  /// - #arg(do-no-split: ()) list of items that should not be split.
  ///   Accepts the following item identifiers:
  ///   TODO
  /// - #arg(normalize: (:))
  ///   is itself a dictionary that configures the normalization options on sequences.
  ///   See normalize for more information.
  ///   TODO
  ///
  /// -> dictionary
  cfg: (:),
) = {
  assert(size != none)
  if "list-markers" not in cfg {
    cfg.insert("list-markers", ([•], [‣], [–]) * 2)
  }
  cfg.insert("list-depth", 0)
  if "enum-numbering" not in cfg {
    cfg.insert("enum-numbering", ("1.",) * 6)
  }
  if "hyphenate" not in cfg or cfg.hyphenate == auto {
    cfg.hyphenate = text.hyphenate
  }
  if "lang" not in cfg or cfg.lang == auto {
    cfg.lang = text.lang
  }
  if "linebreak" not in cfg {
    cfg.linebreak = auto
  }
  if "normalize" not in cfg {
    cfg.normalize = (:)
  }
  cfg.insert("enum-depth", 0)
  // TODO: include vertical and horizontal spacing here.
  dispatch([#ct], ct => fits-inside(dims, ct, size: size), cfg)
}

