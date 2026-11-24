// Shared recursive traversal and container-preserving transformation helpers
// over Typst `content` trees.

#let _seq-func = [].func()
#let _html-elem-func = if "html" in dictionary(std) { std.html.elem } else {
  none
}

/// Find the first non-`none` result produced by `match-fn(node)` in pre-order traversal.
/// Set `descend` to prune subtrees (e.g. skipping mounted subpages).
/// -> any
#let find-content(
  /// Root `content` value (or arbitrary value).
  /// -> any
  c,
  /// Visitor returning `none` to continue searching or any non-`none` value to short-circuit.
  /// -> function
  match-fn,
  /// Predicate deciding whether to recurse into `c`'s children.
  /// -> function
  descend: _ => true,
) = {
  if type(c) != content {
    return none
  }
  let direct = match-fn(c)
  if direct != none {
    return direct
  }
  if not descend(c) {
    return none
  }
  if c.has("child") {
    let r = find-content(c.child, match-fn, descend: descend)
    if r != none { return r }
  }
  if c.has("body") {
    let r = find-content(c.body, match-fn, descend: descend)
    if r != none { return r }
  }
  if c.has("children") {
    for ch in c.children {
      let r = find-content(ch, match-fn, descend: descend)
      if r != none { return r }
    }
  }
  none
}

/// Return `true` when any node in `c` satisfies `pred(node)`.
/// -> bool
#let any-content(c, pred, descend: _ => true) = {
  (
    find-content(c, n => if pred(n) { true } else { none }, descend: descend) == true
  )
}

/// Collect an array of items extracted by `extract-fn(node)` across `c`.
/// `extract-fn(node)` should return an `array` of records (`()` when nothing matches).
/// -> array
#let collect-content(
  /// Root `content` value.
  /// -> any
  c,
  /// Extractor returning `()` or an `array` of extracted items for `node`.
  /// -> function
  extract-fn,
  /// Predicate deciding whether to recurse into `c`'s children.
  /// -> function
  descend: _ => true,
) = {
  if type(c) != content {
    return ()
  }
  let out = extract-fn(c)
  if not descend(c) {
    return out
  }
  if c.has("child") {
    out += collect-content(c.child, extract-fn, descend: descend)
  }
  if c.has("body") {
    out += collect-content(c.body, extract-fn, descend: descend)
  }
  if c.has("children") {
    for ch in c.children {
      out += collect-content(ch, extract-fn, descend: descend)
    }
  }
  out
}

#let _reattach-label(orig, rebuilt) = {
  if orig.has("label") {
    [#rebuilt#orig.label]
  } else {
    rebuilt
  }
}

/// Transform nodes inside `c` via `transform-fn(node)` (which returns `auto` to descend,
/// or a replacement `content` value), preserving sequences, HTML-safe layout containers
/// (`block`, `box`, `align`, `pad`, `list.item`, `enum.item`, `quote`), and typed `html.*`
/// (`html.elem`) wrappers at arbitrary nesting depth while short-circuiting untouched subtrees.
/// -> content
#let map-containers(
  /// Root `content` tree.
  /// -> any
  c,
  /// Mapper returning `auto` when `c` is not replaced directly, or replacement `content`.
  /// -> function
  transform-fn,
) = {
  if type(c) != content {
    return c
  }
  let direct = transform-fn(c)
  if direct != auto {
    return direct
  }

  let go(x) = map-containers(x, transform-fn)
  let fn = c.func()

  if fn == _seq-func and c.has("children") {
    let changed = false
    let mapped = ()
    for ch in c.children {
      let m = go(ch)
      if m != ch {
        changed = true
      }
      mapped.push(m)
    }
    if not changed {
      return c
    }
    return if mapped.len() > 0 { mapped.join() } else { [] }
  }
  if (
    fn in (block, box, align, pad, list.item, enum.item, quote) and c.has("body")
  ) {
    let f = c.fields()
    let b = f.remove("body")
    let mb = go(b)
    if mb == b {
      return c
    }
    return _reattach-label(c, fn(..f, mb))
  }
  if _html-elem-func != none and fn == _html-elem-func and c.has("body") {
    let f = c.fields()
    let b = f.at("body")
    if b != none {
      let mb = go(b)
      if mb == b {
        return c
      }
      let tag = f.at("tag")
      let attrs = f.at("attrs", default: (:))
      return _reattach-label(c, std.html.elem(tag, attrs: attrs, mb))
    }
  }
  c
}
