/// Read-only recursive scans over content. Used by the tokenizer to decide
/// whether a piece of content must be unwrapped (it contains division
/// markers) and by the planner to detect page-breaking/fr-height elements.

#import "markers.typ": marker_value, rubric_value
#import "prelude.typ": PREFIX, e
#import "constants.typ": BATCH

/// The eid of examy's `answer-box`, which elembic makes from an element's
/// prefix and name alone: read from one declared under the same, as
/// answer-box.typ, which imports this module, cannot be imported here (it
/// checks that the two agree).
#let ANSWER_BOX_EID = e.eid(e.element.declare("answer-box", prefix: PREFIX, display: it => none, fields: ()))

/// The internal `sequence` and `styled` element functions.
#let SEQUENCE_FUNC = [#none#none].func()
#let STYLED_FUNC = {
  set text(fill: red)
  [x]
}.func()

/// Whether `c` is a `pagebreak()` or `colbreak()` element.
#let is_break(c) = {
  type(c) == content and (c.func() == pagebreak or c.func() == colbreak)
}

/// Extract the explicitly-set height of elements that can carry one
/// (including examy height hints). Returns `none` if no height is set.
#let extract_height(c) = {
  if type(c) != content { return none }
  let f = c.func()
  if f == v { return c.at("amount", default: none) }
  if f == box or f == block or f == image { return c.at("height", default: none) }
  let m = marker_value(c)
  if m != none and m.kind == "height" { return m.height }
  none
}

/// The labels elembic (1.1.1, pinned in prelude.typ) tags a rule with. A
/// `#show: e.set_(..)` rule turns the rest of its scope into
/// `[#context { .. doc .. }#metadata((doc: doc, rule: rule, ..))<tag>]`: the
/// `context` is opaque, but the metadata keeps the original `doc`, so the
/// divisions inside it can still be found.
#let _ELEMBIC_RULE_TAGS = (<__elembic_element_rule_v2>, <__elembic_element_rule>)

/// Whether `c` is the tag that ends the content an elembic rule left in its
/// place (see `_ELEMBIC_RULE_TAGS`).
#let _is_rule_tag(c) = {
  if type(c) != content or c.func() != metadata or c.at("label", default: none) not in _ELEMBIC_RULE_TAGS {
    return false
  }
  type(c.value) == dictionary and "doc" in c.value and "rule" in c.value
}

/// The `(doc, rule)` an elembic rule (see `_ELEMBIC_RULE_TAGS`) was applied
/// to, if `c` is the content such a rule left in its place; else `none`.
/// That content is a sequence of exactly two, the rule's output and its tag.
/// Joined to other content (`a + rule`, a `.join()`), the two are spliced
/// into the sequence they join, after what came before them: that sequence
/// ends in the tag, but is not the rule (see `unwrap`).
#let elembic_rule(c) = {
  if type(c) != content or c.func() != SEQUENCE_FUNC or c.children.len() != 2 { return none }
  let tag = c.children.last()
  if not _is_rule_tag(tag) { return none }
  (doc: tag.value.doc, rule: tag.value.rule)
}

#let EMPTY_SCAN = (has_marker: false, has_break: false, fr: none, marker_names: ())

#let _merge_scans(a, b) = (
  has_marker: a.has_marker or b.has_marker,
  has_break: a.has_break or b.has_break,
  fr: if a.fr == none { b.fr } else if b.fr == none { a.fr } else { a.fr + b.fr },
  marker_names: a.marker_names + b.marker_names,
)

/// What a sequence, styled content, or elembic rule (see `elembic_rule`)
/// is made of, in order; `none` for anything else. These are what a
/// document made the exam by `#show: exam` nests a level deeper with every
/// set or show rule in it, and what the walks over content look through.
/// A sequence with a rule spliced into its end (see `elembic_rule`) is made
/// of what comes before the rule, and the rule, apart again.
#let unwrap(c) = {
  if type(c) != content { return none }
  let rule = elembic_rule(c)
  if rule != none { return (rule.doc,) }
  let f = c.func()
  if f == SEQUENCE_FUNC and c.children.len() > 2 and _is_rule_tag(c.children.last()) {
    return (..c.children.slice(0, -2), SEQUENCE_FUNC(c.children.slice(-2)))
  }
  if f == SEQUENCE_FUNC { return c.children }
  if f == STYLED_FUNC { return (c.child,) }
  none
}

/// What `_find` looks inside by default: what `unwrap` gives, or else an
/// element's content fields (body, caption, ...).
#let _inside(c) = {
  if type(c) != content { return () }
  let kids = unwrap(c)
  if kids != none { kids } else { c.fields().values().filter(v => type(v) in (content, array)) }
}

/// Every item in `c` that `match` accepts, in order, without looking inside
/// them; inside the others, the items `inside` gives, of an array its
/// items. With `first: true`, only the first one found. Walked with a stack
/// of its own, not by recursing, for content nested deeper than Typst lets
/// functions recurse (see `unwrap`), in batches, for content longer than
/// Typst lets a loop run (see `BATCH`).
#let _find(c, match, inside: _inside, first: false) = {
  let out = ()
  let stack = (c,)
  while stack.len() > 0 {
    let round = 0
    while stack.len() > 0 and round < BATCH {
      round += 1
      let c = stack.pop()
      if type(c) == array {
        stack += c.rev()
      } else if match(c) {
        out.push(c)
        if first { return out }
      } else {
        stack += inside(c).rev()
      }
    }
  }
  out
}

/// The scan (see `scan`) of one element: not a sequence, styled content, or
/// an elembic rule, which `scan` looks through itself. A function of its
/// own, so that Typst memoizes it, and an element scanned once, as a field
/// of another, say, is not scanned again by `tokenize`. `scan` is passed
/// in, for the element's fields.
#let _scan_element(c, scan) = {
  let m = marker_value(c)
  if m != none {
    if m.kind == "begin" {
      return EMPTY_SCAN + (has_marker: true, marker_names: (m.fields.name,))
    }
    if m.kind == "end" {
      return EMPTY_SCAN + (has_marker: true)
    }
    if m.kind == "height" {
      let h = m.height
      return EMPTY_SCAN + (fr: if type(h) == fraction { h } else { none })
    }
    return EMPTY_SCAN
  }
  if is_break(c) { return EMPTY_SCAN + (has_break: true) }
  // An `answer-box` the exam did not draw itself (see `resolve_boxes`), inside
  // an element it does not look into: what its call gives of its height,
  // and what its body holds. Recognized by the tag that ends an elembic
  // instance, which carries the call's fields.
  if c.func() == metadata and c.at("label", default: none) == <__elembic_element_tag> {
    let v = c.value
    if type(v) == dictionary and v.at("eid", default: none) == ANSWER_BOX_EID {
      let h = v.fields.at("height", default: none)
      let inner = scan(v.fields.at("body", default: none))
      inner.fr = if type(h) == fraction { h } else { none }
      return inner
    }
  }

  // Scan all content-valued fields (body, caption, ...).
  let inner = EMPTY_SCAN
  for (name, value) in c.fields() {
    if type(value) == content or type(value) == array {
      inner = _merge_scans(inner, scan(value))
    }
  }

  let h = extract_height(c)
  if h != none and h != auto {
    // Explicitly sized: inner fr heights resolve inside this container and
    // must not propagate; markers/breaks inside are still reported.
    inner.fr = if type(h) == fraction { h } else { none }
  }
  inner
}

/// Scan `c` (content, array, or anything else) and report:
/// - `has_marker`: a division begin/end marker occurs somewhere inside
/// - `has_break`: a pagebreak/colbreak occurs somewhere inside
/// - `fr`: the summed `fraction` heights of children (heights inside
///   explicitly-sized containers do not propagate past their container)
/// - `marker_names`: constructor names of found markers (for diagnostics)
///
/// Sequences, styled content, and elembic rules are looked through with
/// `_find`, which does not recurse (see `unwrap`). Other elements nest only
/// as deep as they are written, and are scanned recursively (see
/// `_scan_element`).
#let scan(c) = {
  // Not content, or a sequence, styled content, or an elembic rule.
  let through(x) = {
    let kids = unwrap(x)
    if kids == none { () } else { kids }
  }
  let leaves = _find(c, x => type(x) == content and unwrap(x) == none, inside: through)
  leaves.fold(EMPTY_SCAN, (acc, x) => _merge_scans(acc, _scan_element(x, scan)))
}

/// Element functions whose content participates in inline (paragraph)
/// layout. Used to decide whether a gutter label can ride the first line.
#let _INLINE_FUNCS = (
  text,
  box,
  h,
  linebreak,
  strong,
  emph,
  link,
  ref,
  sub,
  super,
  underline,
  overline,
  strike,
  highlight,
  smallcaps,
  footnote,
)

/// Element functions of what runs in a paragraph's lines as text does (see
/// `is_plain_text`): `_INLINE_FUNCS` but `box`, and spaces, quotes,
/// symbols, and metadata, which is invisible.
#let _PLAIN_FUNCS = _INLINE_FUNCS.filter(f => f != box) + ([ ].func(), smartquote, [#sym.dot].func(), metadata)

/// How `c` begins, for placing a gutter label beside its first line:
/// `none` when `c` is invisible/transparent (spaces, metadata; keep looking),
/// otherwise `(inline: bool, inset: length)`.
/// - `inline`: whether the first visible leaf is inline (text, an inline
///   box, ...), so a label can ride its baseline; `false` for a block-level
///   one (a block, enum, figure, ...), a parbreak, or something unknown
///   (unknown defaults to block-level — the safe case).
/// - `inset`: how far below the top of `c` its first line of text starts,
///   when `c` begins with a box sized to its content (the space inside the
///   box above that content: its top inset), so that a label placed at the
///   top can be moved down to that line; `0pt` otherwise.
#let leading(c) = {
  let inline = (inline: true, inset: 0pt)
  let block_level = (inline: false, inset: 0pt)
  if type(c) == str { return if c.trim() == "" { none } else { inline } }
  if type(c) != content { return inline }
  let f = c.func()
  if f == parbreak { return block_level }
  if ([ ].func(), metadata).contains(f) { return none }
  if f == SEQUENCE_FUNC {
    for child in c.children {
      let r = leading(child)
      if r != none { return r }
    }
    return none
  }
  if f == STYLED_FUNC { return leading(c.at("child")) }
  // Equations, raw, and quotes are inline unless their `block` flag is set.
  if (math.equation, raw, quote).contains(f) {
    return if c.at("block", default: false) { block_level } else { inline }
  }
  if f == box {
    // A box with an explicit height (e.g. a fixed-height answer box) fills
    // its line well past the text baseline; a gutter label must not ride that
    // baseline. Only content-sized boxes count as text-like. A full-width
    // one does not either: it stands on a line of its own however many lines
    // it holds (`answer-box(width: 100%)[..]`), and the label would ride the
    // baseline of its last. A content-sized box's first line starts its top
    // inset below its top.
    let width = c.at("width", default: auto)
    let full = type(width) in (ratio, relative) and width == 100%
    if c.at("height", default: auto) != auto { return block_level }
    let inset = c.at("inset", default: 0pt)
    let top = if type(inset) == dictionary {
      inset.at("top", default: inset.at("y", default: inset.at("rest", default: 0pt)))
    } else { inset }
    return (inline: not full, inset: top)
  }
  if _INLINE_FUNCS.contains(f) { return inline }
  block_level
}

/// Tri-state: does `c` *begin* with inline-level content? `none` when it is
/// invisible (see `leading`).
#let starts_inline(c) = {
  let r = leading(c)
  if r == none { none } else { r.inline }
}

/// How far below the top of `c` its first line of text starts (see
/// `leading`); `none` when it is invisible.
#let leading_inset(c) = {
  let r = leading(c)
  if r == none { none } else { r.inset }
}

/// Strip leading space/parbreak elements from content (looking through
/// sequences and styled wrappers). Used so a division body written on its
/// own markup line does not render a visible space after an inline gutter
/// label.
#let trim_leading_space(c) = {
  if type(c) != content { return c }
  let f = c.func()
  if ([ ].func(), parbreak().func()).contains(f) { return none }
  if f == SEQUENCE_FUNC {
    let kids = c.children
    let i = 0
    let out = none
    while i < kids.len() {
      let trimmed = trim_leading_space(kids.at(i))
      if trimmed == none {
        i += 1
      } else {
        if trimmed != kids.at(i) { out = (trimmed, ..kids.slice(i + 1)).join() }
        break
      }
    }
    // Kept as it is with nothing to trim, and its label (a labelled answer
    // box's, say) kept on what is left, as joining would drop it.
    if out == none {
      if i == 0 { return c }
      out = kids.slice(i).join()
    }
    let lbl = c.at("label", default: none)
    return if lbl == none or out == none { out } else [#out#lbl]
  }
  if f == STYLED_FUNC {
    let trimmed = trim_leading_space(c.at("child"))
    if trimmed == none { return none }
    return STYLED_FUNC(trimmed, c.at("styles"))
  }
  c
}

/// Whether content consists only of whitespace (spaces, parbreaks, metadata).
#let is_whitespace_content(it) = {
  if it == none { return true }
  if type(it) == str { return it.trim() == "" }
  if type(it) != content { return false }
  if ([ ].func(), parbreak().func(), metadata).contains(it.func()) {
    return true
  }
  if it.has("text") { return it.at("text").trim() == "" }
  if it.has("children") {
    return it.at("children").all(is_whitespace_content)
  }
  false
}

/// Whether `c` holds only what runs in a paragraph's lines as text does:
/// text and its styling, inline math and code, and metadata. Not a box, or
/// anything else laid out at a width of its own, which the paragraph's
/// width sets, not its line's: an element elembic draws, such as an inline
/// `solution`, is drawn by a `context`, and so not either. But a box of a
/// fixed width, or of nothing visible (a probe for a position, say), is.
#let is_plain_text(c) = {
  let inline_only(x) = (math.equation, raw).contains(x.func()) and not x.at("block", default: false)
  // Its width a length, kept as a `relative` of no ratio.
  let fixed(w) = type(w) == length or type(w) == relative and w.ratio == 0%
  let fixed_box(x) = (
    x.func() == box and (fixed(x.at("width", default: auto)) or is_whitespace_content(x.at("body", default: none)))
  )
  let leaf(x) = _PLAIN_FUNCS.contains(x.func()) or inline_only(x) or fixed_box(x)
  let other(x) = type(x) == content and unwrap(x) == none and not leaf(x)
  // Not into math, code, or those boxes, which hold no boxes taking the
  // paragraph's width.
  let inside(x) = if type(x) == content and (inline_only(x) or fixed_box(x)) { () } else { _inside(x) }
  _find(c, other, inside: inside, first: true).len() == 0
}

/// Elements that are always block-level, and so end the paragraph before
/// them and start a fresh one after. Anything not listed counts as inline:
/// mistaking a block for inline content merely leaves a solution
/// shrink-wrapped, whereas the reverse widens a solution in the middle of a
/// sentence and breaks the line apart.
#let _BLOCK_FUNCS = (
  parbreak,
  block,
  table,
  grid,
  figure,
  list,
  enum,
  terms,
  // What a list is written as: `- item` makes a `list.item`, which becomes
  // part of a `list` only when it is laid out.
  list.item,
  enum.item,
  terms.item,
  heading,
  image,
  align,
  pad,
  stack,
  columns,
  colbreak,
  pagebreak,
  v,
  // Since Typst 0.15, any `place` ends the paragraph it is in, floating or
  // not, aligned or not.
  place,
  rect,
  square,
  circle,
  ellipse,
  polygon,
  line,
  outline,
  bibliography,
)

/// Whether `c` is block-level, ending the paragraph before it.
#let ends_par(c) = {
  let f = c.func()
  if _BLOCK_FUNCS.contains(f) { return true }
  // Inline unless their `block` flag is set.
  if (math.equation, raw, quote).contains(f) { return c.at("block", default: false) }
  false
}

/// `c` cut where its first paragraph ends, looking through `styled` and
/// `sequence`: `(before, after)`, `after` starting with the paragraph break
/// or block-level element that ends it; `after` is `none` when the paragraph
/// does not end in `c`, and `before` is `none` when it ends at once. Each
/// `styled` cut keeps its styles on both sides; a sequence is rebuilt from
/// its own children, as joining them would splice elembic's rules into it.
///
/// Found with a stack of its own, not by recursing, for content nested
/// deeper than Typst lets functions recurse (see `unwrap`), in batches (see
/// `BATCH`); then cut along the way down to it, from the bottom up.
#let split_first_par(c) = {
  // Each entry: a piece of content, how deep it is, and its index among
  // its siblings.
  let todo = ((c: c, d: 0, i: 0),)
  // The `styled` and `sequence` the piece met last is in, outermost first,
  // each with the index of the child of it that the way goes down.
  let path = ()
  let found = none
  while todo.len() > 0 and found == none {
    let round = 0
    while todo.len() > 0 and round < BATCH {
      round += 1
      let t = todo.pop()
      if type(t.c) != content { continue }
      if path.len() > t.d { path = path.slice(0, t.d) }
      if t.d > 0 { path.at(-1).i = t.i }
      if ends_par(t.c) {
        found = t.c
        break
      }
      let f = t.c.func()
      if f != SEQUENCE_FUNC and f != STYLED_FUNC { continue }
      let kids = if f == SEQUENCE_FUNC { t.c.children } else { (t.c.child,) }
      path.push((c: t.c, i: none))
      for (i, k) in kids.enumerate().rev() { todo.push((c: k, d: t.d + 1, i: i)) }
    }
  }
  if found == none { return (c, none) }
  let (before, after) = (none, found)
  for p in path.rev() {
    if p.c.func() == STYLED_FUNC {
      before = if before != none { STYLED_FUNC(before, p.c.styles) }
      after = STYLED_FUNC(after, p.c.styles)
    } else {
      let kids = p.c.children
      let b = (..kids.slice(0, p.i), before).filter(x => x != none)
      before = if b != () { SEQUENCE_FUNC(b) }
      after = SEQUENCE_FUNC((after, ..kids.slice(p.i + 1)))
    }
  }
  (before, after)
}

/// Whether `c` runs over more than one paragraph: it holds a paragraph break
/// or a block-level element, looking through `styled` and `sequence`.
#let is_multi_par(c) = {
  if type(c) != content { return false }
  if ends_par(c) { return true }
  let f = c.func()
  if f == STYLED_FUNC { return is_multi_par(c.child) }
  if f == SEQUENCE_FUNC { return c.children.any(is_multi_par) }
  false
}

/// Whether `c` holds a rubric marker anywhere inside it. A rubric marker is
/// invisible, as `is_whitespace_content` says, but it must not be dropped
/// with the whitespace around it.
#let has_rubric(c) = _find(c, x => rubric_value(x) != none, first: true).len() > 0

/// Whether `c` holds `metadata` anywhere: content that takes no room, so
/// counts as blank (see `is_whitespace_content`), but is there to be found
/// (with a label, by `query`, a link, ...), so must not be left out of the
/// document where blank content is. A rubric is one.
#let has_metadata(c) = _find(c, x => type(x) == content and x.func() == metadata, first: true).len() > 0

/// What `_find` looks inside to reach the fields of elements kept in
/// metadata too (a `solution`'s body, a division's `rubric:`), which
/// `_inside` does not look into. Of elembic's own data, only what can hold
/// content: the content a rule is applied to, and an element's fields, not
/// the rest of what elembic keeps with them (the element's whole
/// description, for one), which would take long to walk, for every answer
/// box (which holds a rule on its solutions) and every solution. A rule is
/// looked through as `unwrap` does, to the content it is applied to alone,
/// so that nothing in it is reached twice.
#let _inside_kept(x) = {
  if type(x) == dictionary { return x.values() }
  if type(x) != content { return () }
  let kids = unwrap(x)
  if kids != none { return kids }
  if x.func() != metadata { return x.fields().values() }
  // A rule's tag `unwrap` does not take apart with its rule: one spliced
  // into the middle of a sequence.
  if _is_rule_tag(x) { return (x.value.doc,) }
  let v = x.value
  if x.at("label", default: none) == <__elembic_element_tag> and type(v) == dictionary and "fields" in v {
    v.fields.values()
  } else { (v,) }
}

/// Whether `c` holds a rubric marker anywhere at all, also in the fields of
/// elements kept in metadata (see `_inside_kept`), which `has_rubric` does
/// not look into. For the exam to know whether it has rubrics to draw,
/// before drawing anything.
#let has_any_rubric(c) = _find(c, x => rubric_value(x) != none, inside: _inside_kept, first: true).len() > 0

/// Every rubric marker inside `c`, in order: what a hidden `solution`
/// leaves in its place, so that its rubrics are still found. With `kept`,
/// also those in the fields of elements kept in metadata (see
/// `_inside_kept`): the solutions a hidden one would have drawn after itself
/// (its `_then`).
#let rubric_markers(c, kept: false) = _find(c, x => rubric_value(x) != none, inside: if kept {
  _inside_kept
} else { _inside })

/// Whether `c` ends with inline content, in a paragraph's line. Unsure
/// means no (see `glue_rubrics`).
#let _ends_inline(c) = {
  // Down its last child, with a loop of its own (see `_find`).
  while true {
    if type(c) == str { return c.trim() != "" }
    if type(c) != content { return false }
    let f = c.func()
    if f == SEQUENCE_FUNC {
      let kids = c.children.filter(k => not is_whitespace_content(k) or rubric_value(k) != none)
      if kids.len() == 0 { return false }
      if rubric_value(kids.last()) != none { return true }
      c = kids.last()
    } else if f == STYLED_FUNC {
      c = c.child
    } else {
      if (math.equation, raw).contains(f) { return not c.at("block", default: false) }
      return _INLINE_FUNCS.contains(f) or f == smartquote or f == [#sym.dot].func()
    }
  }
}

/// A sequence's children `kids`, already glued (see `glue_rubrics`), with
/// each rubric marker among them glued to the text beside it.
#let _glue_kids(kids) = {
  let space = [ ].func()
  let wj = text("\u{2060}")
  let out = ()
  for (i, k) in kids.enumerate() {
    if rubric_value(k) == none {
      out.push(k)
      continue
    }
    // What comes before it as glued so far: a marker glued after the text
    // before it is followed by its joiner, which the next one is glued to.
    let prev = out.rev().find(x => not (type(x) == content and x.func() == space))
    let next = kids.slice(i + 1).find(x => not (type(x) == content and x.func() == space))
    if prev != none and _ends_inline(prev) {
      out += (k, wj)
    } else if next != none and rubric_value(next) == none and starts_inline(next) == true {
      out += (wj, k)
    } else {
      out.push(k)
    }
  }
  out.join()
}

/// Glue each rubric marker to the text beside it in its paragraph, with a
/// word joiner: after it when text comes before it, before it when it starts
/// the paragraph and text follows. Unglued, a marker that ends a paragraph
/// is placed after the paragraph (at its left edge, below it), and one that
/// starts it at the paragraph's top, not on its first line: where a rubric's
/// leader is drawn from. A marker with no text on either side is left as it
/// is, as a joiner would make a line of its own. Only the siblings in a
/// sequence are looked at (through `styled`), so a case unsure of is left
/// as it is: placed less well, but never moving the layout.
///
/// Rebuilt from the inside out, with a stack of its own rather than by
/// recursing (see `_find`): each sequence and `styled` is visited, then
/// its children are, then it is rebuilt from them, if any changed.
#let glue_rubrics(c) = {
  // To visit: `(c, n: none)`, or `(c, n)` to rebuild `c` from the last `n`
  // results. Each result: `(content, whether it changed)`.
  let todo = ((c: c, n: none),)
  let results = ()
  while todo.len() > 0 {
    // In batches (see `BATCH`).
    let round = 0
    while todo.len() > 0 and round < BATCH {
      round += 1
      let t = todo.pop()
      let c = t.c
      let f = if type(c) == content { c.func() }
      if t.n == none {
        if f == SEQUENCE_FUNC or f == STYLED_FUNC {
          let kids = if f == SEQUENCE_FUNC { c.children } else { (c.child,) }
          todo.push((c: c, n: kids.len()))
          for k in kids.rev() { todo.push((c: k, n: none)) }
        } else {
          results.push((c, false))
        }
        continue
      }
      // Popped, not sliced off: a slice copies all of `results`, at every
      // container (see `tokenize`). A `for` loop has no limit on its rounds.
      let glued = ()
      for _ in range(t.n) { glued.push(results.pop()) }
      let glued = glued.rev()
      let kids = glued.map(g => g.first())
      if f == STYLED_FUNC {
        let (child, changed) = glued.first()
        results.push((if changed { STYLED_FUNC(child, c.styles) } else { c }, changed))
      } else if glued.any(g => g.last()) or kids.any(k => rubric_value(k) != none) {
        results.push((_glue_kids(kids), true))
      } else {
        results.push((c, false))
      }
    }
  }
  results.first().first()
}
