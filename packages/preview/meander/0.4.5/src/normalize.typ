// This file's job is to normalize an input stream in a few ways that are important
// to Meander. For example:
// - as noted in the longstanding issue #3 (https://github.com/Vanille-N/meander.typ/issues/3),
//   references should be boxed.
// - enumerations should not be left for automatic counting.
// - etc.

/// A normalization pass that groups adjacent references
/// #property-unstable()
/// so that they are not separated and so that the citation style
/// may print grouped references differently than multiple individual references.
/// -> array(content)
#let box-refs(
  /// Sequence of content elements.
  /// -> array(content)
  seq
) = {
  let ref-accum = []
  for (i, obj) in seq.enumerate() {
    if obj.func() == ref {
      ref-accum += obj
      seq.at(i) = []
    } else if ref-accum != [] and obj.func() == [ ].func() and i + 1 < seq.len() and seq.at(i + 1).func() == ref {
      ref-accum += obj
      seq.at(i) = []
    } else {
      if ref-accum != [] {
        seq.at(i - 1) = box(ref-accum)
        ref-accum = []
      }
    }
  }
  if ref-accum != [] {
    seq.last() = box(ref-accum)
    ref-accum = []
  }
  seq
}

/// A normalization pass that turns
/// #property-unstable()
/// #codesnippet[```
/// enum.item(auto)[..]
/// enum.item(auto)[..]
/// enum.item(auto)[..]
/// ```]
/// into
/// #codesnippet[```
/// enum.item(1)[..]
/// enum.item(2)[..]
/// enum.item(3)[..]
/// ```]
/// to prevent the enumeration counter from resetting on every split.
/// -> array(content)
#let count-enums(
  /// Sequence of content elements.
  /// -> array(content)
  seq,
) = {
  let cur-number = 1
  for (i, obj) in seq.enumerate() {
    if obj.func() == enum.item {
      let (body, ..fields) = obj.fields()
      if "number" in fields {
        cur-number = fields.remove("number")
      }
      obj = enum.item(cur-number, body, ..fields)
      seq.at(i) = obj
      cur-number += 1
    } else if obj.func() in ([ ].func(), parbreak) {
      continue
    } else {
      cur-number = 1
    }
  }
  seq
}

/// A normalization pass that turns
/// #property-unstable()
/// #codesnippet[```typc
/// enum.item(..)
/// enum.item(..)
/// enum.item(..)
/// ```]
/// into
/// #codesnippet[```typc
/// enum(
///   enum.item(..),
///   enum.item(..),
///   enum.item(..)
/// )
/// ```]
/// to improve bisection heuristics on numbered lists.
/// -> array(content)
#let group-enums(
  /// Sequence of content elements.
  /// -> array(content)
  seq,
) = {
  let initial-item = 0
  let items = ()
  let tight = true
  for (i, obj) in seq.enumerate() {
    if obj.func() == enum.item {
      if items == () {
        initial-item = i
      }
      seq.at(i) = none
      items.push(obj)
    } else if items != () and obj.func() == parbreak {
      seq.at(i) = none
      tight = false
    } else if items != () and obj.func() == [ ].func() {
      //seq.at(i) = [ ]
    } else {
      if items != () {
        seq.at(initial-item) = enum(..items, tight: tight)
        items = ()
        tight = true
      }
    }
  }
  if items != () {
    seq.at(initial-item) = enum(..items, tight: tight)
  }
  seq.filter(e => e != none)
}

#let subst-apply(cfg, func, arg) = {
  let key = repr(func)
  let resolved = cfg.at(key, default: func)
  if resolved == none {
    arg
  } else if type(resolved) == function {
    resolved(arg)
  } else {
    panic("Provided normalizer '" + repr(func) + "' is not a function.")
  }
}

/// Apply sequence normalization passes.
/// #property-unstable()
/// All of these are heuristics, and may be imperfect.
///
/// Here we apply:
/// - @cmd:normalize:box-refs
/// - @cmd:normalize:count-enums
#let normalize-seq(seq, cfg) = {
  seq = subst-apply(cfg, box-refs, seq)
  //seq = subst-apply(cfg, group-enums, seq)
  seq = subst-apply(cfg, count-enums, seq)
  seq
}

/// Apply numbered lists normalization passes.
/// #property-unstable()
/// All of these are heuristics, and may be imperfect.
///
/// Here we apply:
/// - @cmd:normalize:count-enums
#let normalize-enum(seq, cfg) = {
  seq = subst-apply(cfg, count-enums, seq)
  seq
}
