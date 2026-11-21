// =============================================================================
// utils/patch.typ - the ONE shared patch / merge utility (theme + locale).
//
// Semantics (concept §4.2)
//   patch `auto`          -> untouched, at every depth (never stored)
//   patch `reset()`       -> the schema default of that path (often `auto`)
//   patch `none`          -> a real value ("off"); on an area: remove it
//   dict onto dict        -> recurse, unknown keys panic (unless the path is open)
//   anything onto sides   -> fold (margin, area inset: only named sides change;
//                            a side set to `auto` is untouched, `reset()` = its default)
//   dict onto `none`      -> re-hydrate from the template, then merge
//   wrap(fn) onto fn      -> (ctx, view) => fn(ctx, view, previous)   [parts only]
//   replace(v)            -> v, wholesale
//   arrays, scalars, fns  -> replace
// =============================================================================

#let _wrap-key = "__invoice-pro-wrap__"
#let _replace-key = "__invoice-pro-replace__"
#let _reset-key = "__invoice-pro-reset__"

/// Drops `auto` values so only explicitly given fields are patched. `none` survives.
/// -> dictionary
#let clean-auto(d) = {
  let out = (:)
  for (k, v) in d { if v != auto { out.insert(k, v) } }
  out
}

/// One patch fragment as a ONE-ELEMENT ARRAY (no `return` inside the array:
/// fixes locale bug I-1), so helpers written one per line in a block join.
/// -> array
#let emit(group, payload) = {
  let d = (:)
  d.insert(group, payload)
  (d,)
}

/// Wrap marker: a plain tagged dict, so zero-import packages can build it too.
/// `fn: (ctx, view, inner) => content`. Valid only under `parts`.
/// -> dictionary
#let wrap(fn) = {
  assert(
    type(fn) == function,
    message: "variable `theme::custom::wrap`("
      + repr(fn)
      + ") must be of function",
  )
  ((_wrap-key): fn)
}
/// Replace marker: `value` replaces a dict wholesale instead of merging.
/// -> dictionary
#let replace(value) = ((_replace-key): value)
/// Reset marker: restores the schema default of the patched path (often `auto`,
/// i.e. "computed"). The only way to get back to `auto`, because `auto` in a
/// patch means "untouched".
/// -> dictionary
#let reset() = ((_reset-key): true)

#let is-wrap(v) = type(v) == dictionary and _wrap-key in v
#let is-replace(v) = type(v) == dictionary and _replace-key in v
#let is-reset(v) = type(v) == dictionary and _reset-key in v

// --- did-you-mean ------------------------------------------------------------

#let _lev(a, b) = {
  let a = a.clusters()
  let b = b.clusters()
  let prev = range(b.len() + 1)
  for i in range(a.len()) {
    let cur = (i + 1,)
    for j in range(b.len()) {
      let cost = if a.at(i) == b.at(j) { 0 } else { 1 }
      cur.push(calc.min(cur.at(j) + 1, prev.at(j + 1) + 1, prev.at(j) + cost))
    }
    prev = cur
  }
  prev.last()
}

/// " Did you mean `x`?" or "".
#let did-you-mean(key, candidates) = {
  let best = none
  let best-d = 99
  for c in candidates {
    let d = _lev(key, c)
    if d < best-d {
      best = c
      best-d = d
    }
  }
  if best != none and best-d <= calc.max(2, calc.floor(key.len() / 3)) {
    " Did you mean `" + best + "`?"
  } else { "" }
}

#let fail-unknown(path, key, allowed) = panic(
  path.join("::")
    + " has unknown key `"
    + key
    + "`."
    + did-you-mean(key, allowed)
    + " Allowed keys: "
    + allowed.join(", "),
)

// --- sides ---------------------------------------------------------------------

#let _sides = ("top", "right", "bottom", "left")

#let _apply-sides(r, value) = {
  let r = r
  if "rest" in value { for s in _sides { r.insert(s, value.rest) } }
  if "x" in value {
    r.insert("left", value.x)
    r.insert("right", value.x)
  }
  if "y" in value {
    r.insert("top", value.y)
    r.insert("bottom", value.y)
  }
  for s in _sides { if s in value { r.insert(s, value.at(s)) } }
  r
}

/// Folds a length or a partial directional dict (x, y, rest, top, ...) into a
/// fully expanded sides dict. `base` may itself be a length or a partial dict.
#let fold-sides(base, value, path) = {
  if type(value) != dictionary {
    return (top: value, right: value, bottom: value, left: value)
  }
  let allowed = _sides + ("x", "y", "rest")
  for k in value.keys() {
    if k not in allowed { fail-unknown(path, k, allowed) }
  }
  let zero = (top: 0pt, right: 0pt, bottom: 0pt, left: 0pt)
  let r = if type(base) == dictionary { _apply-sides(zero, base) } else if (
    base == none or base == auto
  ) { zero } else {
    (top: base, right: base, bottom: base, left: base)
  }
  _apply-sides(r, value)
}

// --- merge ---------------------------------------------------------------------

/// Composes a wrapper with the inherited renderer (wraps stack in layer order).
#let compose-wrap(inherited, wrapper) = {
  let inner = if type(inherited) == function { inherited } else { (..) => none }
  (ctx, view) => wrapper(ctx, view, inner)
}

#let _lookup(tree, key) = {
  let v = tree
  for k in key.split("::") {
    if type(v) != dictionary or k not in v { return auto }
    v = v.at(k)
  }
  v
}

/// Strict deep merge. `rules` = (open, sides, templates, defaults, wrap-ok):
/// `open`/`sides`/`wrap-ok` are arrays of rule keys ("a::b"), `templates` maps
/// a rule key to a template dict, `defaults` is the default tree for `reset()`.
/// `path` is only used for messages; `key` is the rule key (defaults to the path
/// without its first segment).
/// -> any
#let merge(base, patch, path, rules, key: auto) = {
  let key = if key == auto { path.slice(1).join("::") } else { key }
  if patch == auto { return base }
  if is-reset(patch) {
    let d = _lookup(rules.at("defaults", default: (:)), key)
    return if type(d) == dictionary and "__field__" in d { d.default } else {
      d
    }
  }
  if is-replace(patch) { return patch.at(_replace-key) }
  if is-wrap(patch) {
    let ok = rules.at("wrap-ok", default: ())
    if not ok.any(p => key.starts-with(p)) {
      panic(
        path.join("::")
          + ": a wrap marker is only valid for a part (theme.custom.wrap(name, ..)), not here",
      )
    }
    return compose-wrap(base, patch.at(_wrap-key))
  }
  if key in rules.at("atomic", default: ()) { return patch }
  if key in rules.sides and patch != none {
    // per side: `auto` = untouched, `reset()` = the schema default of that side
    let patch = patch
    if type(patch) == dictionary {
      let d = _lookup(rules.at("defaults", default: (:)), key)
      let d = if type(d) == dictionary and "__field__" in d { d.default } else {
        d
      }
      let d = fold-sides(
        none,
        if type(d) in (dictionary, length) { d } else { 0pt },
        path,
      )
      let out = (:)
      for (k, v) in patch {
        if v == auto { continue }
        if is-reset(v) {
          for s in (
            rest: _sides,
            x: ("left", "right"),
            y: ("top", "bottom"),
          ).at(k, default: (k,)) { out.insert(s, d.at(s, default: auto)) }
        } else { out.insert(k, v) }
      }
      patch = out
    }
    return fold-sides(base, patch, path)
  }
  if base == none and type(patch) == dictionary and key in rules.templates {
    return merge(rules.templates.at(key), patch, path, rules, key: key)
  }
  if type(base) != dictionary or type(patch) != dictionary { return patch }
  let open = key in rules.open
  let result = base
  for (k, v) in patch {
    if v == auto { continue }
    let sub = if key == "" { k } else { key + "::" + k }
    if k in result {
      result.insert(k, merge(result.at(k), v, path + (k,), rules, key: sub))
    } else if open {
      result.insert(k, if is-wrap(v) {
        merge(none, v, path + (k,), rules, key: sub)
      } else if is-replace(v) {
        v.at(_replace-key)
      } else if is-reset(v) { none } else { v })
    } else {
      fail-unknown(path, k, base.keys())
    }
  }
  result
}

/// Flattens `.with(..)` positional args and DSL blocks into an array of dicts.
/// `none` (from a false `if` in a block) is ignored; anything else panics.
/// Numbering counts only the caller's own arguments (`#2`, nested `#2[3]`).
/// -> array
#let flatten-patches(items, scope, label: "") = {
  let out = ()
  for (i, p) in items.enumerate() {
    let here = if label == "" { "#" + str(i + 1) } else {
      label + "[" + str(i + 1) + "]"
    }
    if p == none { continue }
    if type(p) == array {
      out += flatten-patches(p, scope, label: here)
    } else if type(p) == dictionary { out.push(p) } else {
      panic(
        scope
          + ": patch "
          + here
          + " must be a theme.custom result or a patch dictionary, found "
          + str(type(p))
          + " ("
          + repr(p)
          + ")",
      )
    }
  }
  out
}
