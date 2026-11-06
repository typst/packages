/// Recursively collects the `.value` of every `metadata` element in `body`
/// whose value is a dictionary tagged with `tag`, in document order.
/// Purely structural (no layout, no context). Shared between every
/// package built on `contexture` because it has zero coupling to any
/// package's own semantics — it was duplicated near-verbatim between
/// typst-palimpsest and typst-checkitoff before this package existed (see
/// MULTI-DOCUMENT-BUNDLE-DESIGN.md).
///
/// Walks *every* content- or array-valued field of each element, not just
/// `body`/`children` — an anchor nested in a `figure`'s `caption:` or a
/// table's cells lives in a field a shortlist would have missed.
#let collect-metadata(body, tag) = {
  let walk(node) = {
    let t = type(node)
    if t == content {
      if node.func() == metadata {
        let v = node.value
        if type(v) == dictionary and v.at("tag", default: none) == tag {
          return (v,)
        }
        return ()
      }
      return node.fields().values().map(v => {
        let t2 = type(v)
        if t2 == content or t2 == array { walk(v) } else { () }
      }).sum(default: ())
    } else if t == array {
      return node.map(walk).sum(default: ())
    }
    return ()
  }
  walk(body)
}

/// True if `body` contains no non-whitespace text anywhere in its tree.
#let is-blank(body) = {
  let walk(node) = {
    let t = type(node)
    if t == content {
      if node.func() == metadata { return false }
      if node.has("text") {
        return node.text.trim() != ""
      }
      return node.fields().values().any(v => {
        let t2 = type(v)
        if t2 == content or t2 == array { walk(v) } else { false }
      })
    } else if t == array {
      return node.any(walk)
    }
    false
  }
  not walk(body)
}

/// True if `body` (any Typst value) contains no `figure`, `table`, or
/// block-mode `math.equation` at or below its own top level — decides
/// whether an excerpt is safe to wrap in literal quotation marks.
/// Forcing quotation marks onto a figure produces two stray quote glyphs
/// sitting alone above and below it (found directly, kept as a hard rule
/// rather than a style preference).
#let is-textual(body) = {
  if type(body) != content {
    true
  } else {
    let is-block-eq = body.func() == math.equation and body.at("block", default: false)
    if body.func() == figure or body.func() == table or is-block-eq {
      false
    } else if repr(body.func()) == "sequence" {
      body.children.all(is-textual)
    } else {
      true
    }
  }
}

/// Recursively collects every non-`none` `.label` found anywhere in
/// `body`'s tree. Used by `strip-labels` (below) to detect, before
/// re-emitting a stored excerpt into a second document, whether that
/// excerpt would plant a second copy of a label that's meant to be
/// unique in the bundle.
#let collect-labels(body) = {
  let walk(node) = {
    let t = type(node)
    if t == content {
      let lbl = node.fields().at("label", default: none)
      let own = if lbl != none { (lbl,) } else { () }
      own + node.fields().values().map(v => {
        let t2 = type(v)
        if t2 == content or t2 == array { walk(v) } else { () }
      }).sum(default: ())
    } else if t == array {
      node.map(walk).sum(default: ())
    } else {
      ()
    }
  }
  walk(body)
}

/// Recursively reconstructs `node` with every label removed — so an
/// excerpt re-emitted into a second document never plants a second copy
/// of a label that's also cross-referenced elsewhere in the manuscript.
///
/// A `figure`, a labelled block `math.equation`, or a labelled `heading`
/// that still has its original label at the point this runs gets one
/// more thing done to it before that label is dropped: `query(lbl)` finds
/// the true, already-shown original (the copy being built right now
/// doesn't exist yet, so this can't resolve to itself), and its real,
/// resolved number is pinned onto the reconstructed copy's `numbering:`
/// field as a literal value — so a figure/equation/heading an excerpt
/// quotes shows the *same* number it has at its original location,
/// instead of whatever numbering happens to be active where the excerpt
/// is re-emitted. Skipped whenever there's nothing to pin: no label, the
/// label doesn't resolve anywhere, or the original's own `numbering` is
/// `none`.
#let strip-labels(node) = {
  let t = type(node)
  if t == content {
    if node.func() == metadata or collect-labels(node).len() == 0 {
      return node
    }
    let f = node.fields()
    let new-f = (:)
    for (k, v) in f {
      if k == "label" { continue }
      let t2 = type(v)
      new-f.insert(k, if t2 == content {
        strip-labels(v)
      } else if t2 == array {
        v.map(x => if type(x) == content { strip-labels(x) } else { x })
      } else {
        v
      })
    }
    let ctor = node.func()
    if ctor == figure or ctor == math.equation or ctor == heading {
      let lbl = f.at("label", default: none)
      if lbl != none {
        let hits = query(lbl)
        if hits.len() > 0 {
          let orig = hits.first()
          if orig.numbering != none {
            let cval = if ctor == figure {
              orig.counter.at(orig.location())
            } else if ctor == math.equation {
              counter(math.equation).at(orig.location())
            } else {
              counter(heading).at(orig.location())
            }
            let real-number = numbering(orig.numbering, ..cval)
            new-f.insert("numbering", (..) => real-number)
          }
        }
      }
    }
    if "body" in new-f {
      let b = new-f.remove("body")
      ctor(b, ..new-f)
    } else if "children" in new-f {
      // `children`'s calling convention isn't uniform: `sequence` wants
      // its array as one positional argument, `table`/`grid` want each
      // child spread as its own positional argument.
      let c = new-f.remove("children")
      if repr(ctor) == "sequence" { ctor(c, ..new-f) } else { ctor(..c, ..new-f) }
    } else {
      ctor(..new-f)
    }
  } else if t == array {
    node.map(strip-labels)
  } else {
    node
  }
}
