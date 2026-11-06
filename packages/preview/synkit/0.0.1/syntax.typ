// Syntax tree module for synkit
// Draws phrase structure trees from bracket notation input.
// Usage: #tree("[CP [C' [C did] [TP [DP she] [T' [T e] [VP [V leave]]]]]]")

#import "@preview/cetz:0.4.2"
#import "_symbols.typ": apply-symbols as _apply-symbols, symbol-map as _symbol-map

// ── Constants ────────────────────────────────────────────────────────────────
#let _leaf-w = 1.0        // horizontal width per leaf
#let _v-gap = 1.2         // vertical gap between levels
#let _loff = 0.25         // label offset for anchor connections


// ── Tokenizer ────────────────────────────────────────────────────────────────
// Splits bracket notation into tokens: "[", "]", and word strings.
#let _tokenize(input) = {
  let tokens = ()
  let buf = ""
  let brace-depth = 0
  for ch in input.clusters() {
    if ch == "{" {
      brace-depth = brace-depth + 1
      buf = buf + ch
    } else if ch == "}" {
      brace-depth = calc.max(0, brace-depth - 1)
      buf = buf + ch
    } else if brace-depth > 0 {
      // Inside braces: everything is literal (no splitting on [ ] or spaces)
      buf = buf + ch
    } else if ch == "[" or ch == "]" {
      if buf.trim() != "" { tokens.push(buf.trim()) }
      buf = ""
      tokens.push(ch)
    } else if ch == " " or ch == "\t" or ch == "\n" {
      if buf.trim() != "" { tokens.push(buf.trim()) }
      buf = ""
    } else {
      buf = buf + ch
    }
  }
  if buf.trim() != "" { tokens.push(buf.trim()) }
  tokens
}

// ── Strip formatting markers for anchor naming ──────────────────────────────
// Removes *, **, _subscript, and ^superscript from a label to get the bare name.
#let _strip-fmt(label) = {
  let s = label
  // Remove escapes for literal formatting characters before stripping markers.
  // This keeps anchors usable for labels like \muP\* -> muP, not muP\.
  s = s.replace("\\*", "").replace("\\@", "").replace("\\&", "").replace("\\~", "")
  // Strip subscript: first _ and everything after (e.g., CP_i → CP)
  if s.contains("_") {
    let idx = s.position("_")
    s = s.slice(0, idx)
  }
  // Strip superscript: first ^ and everything after (e.g., NP^max → NP)
  if s.contains("^") {
    let idx = s.position("^")
    s = s.slice(0, idx)
  }
  // Strip *, @, &, ~ for bold/italic/smallcaps/underline/strikethrough
  s = s.replace("*", "")
  s = s.replace("@", "")
  s = s.replace("&", "")
  s = s.replace("~", "")
  // Strip angle brackets and commas (for semantic type labels like <et,t> → ett)
  s = s.replace("<", "")
  s = s.replace(">", "")
  s = s.replace(",", "")
  // Strip symbol shortcuts: \lambda → lambda, \phiP → phiP, etc.
  for (key, _val) in _symbol-map {
    if s.contains(key) {
      s = s.replace(key, key.slice(1)) // \lambda → lambda
    }
  }
  s
}

// ── Anchor key ───────────────────────────────────────────────────────────────
// Canonical anchor stem used everywhere labels become automatic anchor names.
#let _anchor-key(label) = {
  _strip-fmt(label).replace("'", "bar").replace("\u{2019}", "bar").replace(" ", "-")
}

// ── Anchor name ──────────────────────────────────────────────────────────────
// Normalizes a label into an anchor name: lowercase, ' → p, spaces → -, append count.
#let _anchor-name(label, count) = {
  _anchor-key(label) + str(count)
}

// ── Parser ───────────────────────────────────────────────────────────────────
// Recursive descent parser: tokens → tree node.
// Returns (node, next-position, updated-counts).
// Node: (label: str, anchor: str, children: array, is-leaf: bool)
#let _parse(tokens, pos, counts) = {
  if tokens.at(pos) == "[" {
    // Empty node: [ ] → blank placeholder
    if tokens.at(pos + 1) == "]" {
      let key = "empty"
      let c = counts.at(key, default: 0) + 1
      counts.insert(key, c)
      return (
        (
          label: "",
          anchor: key + str(c),
          children: (),
          is-leaf: false,
        ),
        pos + 2,
        counts,
      )
    }
    // Non-terminal: [LABEL children... ]
    let label = tokens.at(pos + 1)
    let key = _anchor-key(label)
    let c = counts.at(key, default: 0) + 1
    counts.insert(key, c)
    let anchor = key + str(c)
    let children = ()
    let p = pos + 2
    while tokens.at(p) != "]" {
      if tokens.at(p) == "[" {
        let (child, np, nc) = _parse(tokens, p, counts)
        children.push(child)
        p = np
        counts = nc
      } else {
        // Bare word = leaf child
        let leaf-label = tokens.at(p)
        let lk = _anchor-key(leaf-label)
        let lc = counts.at(lk, default: 0) + 1
        counts.insert(lk, lc)
        children.push((
          label: leaf-label,
          anchor: lk + str(lc),
          children: (),
          is-leaf: true,
        ))
        p = p + 1
      }
    }
    // Skip closing ]
    (
      (
        label: label,
        anchor: anchor,
        children: children,
        is-leaf: false,
      ),
      p + 1,
      counts,
    )
  } else {
    // Bare word at top level
    let label = tokens.at(pos)
    let key = _anchor-key(label)
    let c = counts.at(key, default: 0) + 1
    counts.insert(key, c)
    (
      (
        label: label,
        anchor: key + str(c),
        children: (),
        is-leaf: true,
      ),
      pos + 1,
      counts,
    )
  }
}


// ── Collect all leaf labels under a node ─────────────────────────────────────
#let _collect-leaves(node) = {
  if node.is-leaf or node.children.len() == 0 { return (node.label,) }
  let result = ()
  for child in node.children {
    result = result + _collect-leaves(child)
  }
  result
}

// ── Find a node by anchor in the parsed tree ─────────────────────────────────
#let _find-node(node, anchor) = {
  if node.anchor == anchor { return node }
  if node.children.len() == 0 { return none }
  for child in node.children {
    let found = _find-node(child, anchor)
    if found != none { return found }
  }
  none
}

// ── Collect all leaf anchors under a node ────────────────────────────────────
#let _collect-leaf-anchors(node) = {
  if node.is-leaf or node.children.len() == 0 { return (node.anchor,) }
  let result = ()
  for child in node.children {
    result = result + _collect-leaf-anchors(child)
  }
  result
}

// ── Detect trace leaves ─────────────────────────────────────────────────────
// A trace is any leaf whose label starts with *t* (explicit italic marker).
// Plain t/T is only a trace when followed by a subscript: t_i, T_DP, etc.
// Bare t or T without subscript is treated as a regular node (e.g., tense head).
#let _is-trace(label) = {
  let s = label
  // Explicit italic markers → always a trace
  if s.starts-with("*t*") or s.starts-with("*T*") { return true }
  // T0, t0, t^x → NOT traces (null heads, etc.)
  if s.contains("0") or s.contains("^") { return false }
  // Plain t/T: only a trace when followed by _subscript
  if not s.contains("_") { return false }
  let main = s.slice(0, s.position("_"))
  main == "t" or main == "T"
}

// Walk tree and collect trace info: (trace-number, leaf-anchor, parent-anchor, word-index-in-parent)
#let _find-traces(node, parent-anchor: none) = {
  // Match traces as leaves OR as bracketed nodes with no children (e.g., [*t*_DP])
  if node.is-leaf or (node.children.len() == 0 and _is-trace(node.label)) {
    if _is-trace(node.label) {
      return ((leaf-anchor: node.anchor, parent-anchor: parent-anchor, label: node.label),)
    }
    return ()
  }
  let result = ()
  for child in node.children {
    result = result + _find-traces(child, parent-anchor: node.anchor)
  }
  result
}

// ── Estimate rendered character count (strips formatting markers) ────────────
// Counts visible characters after stripping *, @, &, _subscript, and ^superscript.
#let _esc-star = "\u{FFFD}" // placeholder for escaped \*

#let _rendered-len(s) = {
  let result = _apply-symbols(s)
  // Escaped asterisk \* → single placeholder char (counts as 1 visible char)
  result = result.replace("\\*", _esc-star)
  // Strip formatting markers and braces
  result = result.replace("*", "").replace("@", "").replace("&", "").replace("~", "").replace("{", "").replace("}", "")
  // Strip sub/superscript markers but keep the content (it contributes to width)
  // _text and ^text → text is rendered smaller, count at ~0.7x
  let words = result.split(" ")
  let total = 0
  for w in words {
    // Find first _ or ^ to split main from annotation
    let sub-pos = if w.contains("_") { w.position("_") } else { none }
    let sup-pos = if w.contains("^") { w.position("^") } else { none }
    let split = if sub-pos != none and sup-pos != none { calc.min(sub-pos, sup-pos) } else if sub-pos != none {
      sub-pos
    } else if sup-pos != none { sup-pos } else { none }
    if split != none {
      let main-part = w.slice(0, split)
      let ann-part = w.slice(split).replace("_", "").replace("^", "")
      total = total + main-part.clusters().len() + calc.ceil(ann-part.clusters().len() * 0.7)
    } else {
      total = total + w.clusters().len()
    }
    total = total + 1 // space between words
  }
  calc.max(0, total - 1) // remove trailing space
}

// ── Leaf count (triangle-aware) ──────────────────────────────────────────────
// If a node is in the triangle set, use at least 2 leaf widths for spacing.
// When \n breaks are present, use the widest line's word count instead of total.
// Wide leaf labels claim proportionally more slots.
#let _leaf-count(node, tri-set, leaf-w: 1.0, content-size: 0.8, annotation-leaf-widths: (:)) = {
  if node.is-leaf or node.children.len() == 0 {
    // Check if the label is wider than one slot
    let char-w = 0.22 * content-size
    let label-w = _rendered-len(node.label) * char-w
    let slots = calc.max(1, calc.ceil(label-w / leaf-w))
    return slots
  }
  if node.anchor in tri-set {
    // Use minimal slot count — triangle text overflows visually,
    // and rightward collision with siblings is resolved in the layout loop.
    return 2
  }
  let total = 0
  for child in node.children {
    total = total + _leaf-count(
      child,
      tri-set,
      leaf-w: leaf-w,
      content-size: content-size,
      annotation-leaf-widths: annotation-leaf-widths,
    )
  }
  // Ensure non-leaf node's own label fits within the allocated width.
  // Node labels use full-size font (char-w ≈ 0.22), so wide labels like
  // ⟨st,⟨st,t⟩⟩ need more slots than their leaf count would suggest.
  // Uses exact (non-ceiled) width to avoid over-spacing.
  let char-w = 0.22
  let label-w = _rendered-len(node.label) * char-w
  let needed = label-w / leaf-w
  let annotation-needed = annotation-leaf-widths.at(node.anchor, default: 0)
  calc.max(total, needed, annotation-needed)
}

// ── Layout ───────────────────────────────────────────────────────────────────
// Recursive layout: positions each node based on leaf-proportional spacing.
// Triangle nodes are collapsed to a single leaf with combined label.
// Returns flat list of (label, anchor, x, y, parent-xy, is-leaf, is-triangle).
#let _syntax-layout(
  node,
  x0,
  y,
  parent-xy,
  parent-anchor,
  leaf-w,
  v-gap,
  tri-set,
  is-horiz: false,
  append-map: (:),
  content-size: 0.8,
  level: 0,
  drop-map: (:),
  node-spacing-map: (:),
  sister-spacing-map: (:),
  sister-node-map: (:),
  annotation-map: (:),
  annotation-leaf-widths: (:),
  annotation-gaps: (:),
) = {
  if node.is-leaf or node.children.len() == 0 {
    let x = x0 + leaf-w / 2
    return (
      (
        label: node.label,
        anchor: node.anchor,
        x: x,
        y: y,
        par: parent-xy,
        par-anchor: parent-anchor,
        is-leaf: true,
        is-terminal: node.is-leaf, // true only for bare words, not empty bracket nodes
        is-triangle: false,
      ),
    )
  }

  // Triangle node: collapse entire subtree into parent + single combined leaf
  if node.anchor in tri-set {
    let lc = _leaf-count(
      node,
      tri-set,
      leaf-w: leaf-w,
      content-size: content-size,
      annotation-leaf-widths: annotation-leaf-widths,
    )
    let my-x = x0 + lc * leaf-w / 2
    let leaves = _collect-leaves(node)
    let combined-label = leaves.join(" ")
    let tri-leaves = leaves // individual labels for _display-label rendering
    return (
      (
        label: node.label,
        anchor: node.anchor,
        x: my-x,
        y: y,
        par: parent-xy,
        par-anchor: parent-anchor,
        is-leaf: false,
        is-triangle: true,
        tri-label: combined-label,
        tri-leaves: tri-leaves,
        tri-y: y - v-gap - annotation-gaps.at(node.anchor, default: 0),
        tri-span: lc * leaf-w, // allocated vertical span for horizontal triangles
      ),
    )
  }

  // Non-terminal: lay out children, then center self
  let result = ()
  let cursor = x0
  let child-positions = ()

  // Reserve extra annotation width outside the subtree, not between children.
  // This keeps siblings as tight as their own labels allow while still giving
  // the parent annotation enough room at the next level up.
  let natural-w = node
    .children
    .map(c => _leaf-count(
      c,
      tri-set,
      leaf-w: leaf-w,
      content-size: content-size,
      annotation-leaf-widths: annotation-leaf-widths,
    ) * leaf-w)
    .sum(default: 0)
  let reserved-w = calc.max(natural-w, annotation-leaf-widths.at(node.anchor, default: 0) * leaf-w)
  let cursor = x0 + calc.max(0, (reserved-w - natural-w) / 2)

  for (i, child) in node.children.enumerate() {
    let child-leaves = _leaf-count(
      child,
      tri-set,
      leaf-w: leaf-w,
      content-size: content-size,
      annotation-leaf-widths: annotation-leaf-widths,
    )
    // Per-gap horizontal multiplier: node-specific > level > default.
    // A node-specific entry scales the gap after that child, i.e. between
    // this child and its next sister.
    let h-mult = if child.anchor in sister-node-map {
      sister-node-map.at(child.anchor)
    } else if str(level + 1) in sister-spacing-map {
      sister-spacing-map.at(str(level + 1))
    } else { 1.0 }
    let child-width = child-leaves * leaf-w
    // Pre-check: if this child is a single leaf, check if its label overflows
    // leftward into the previous sibling's space. If so, push cursor right.
    let _overflow-pad = 0.2 * calc.min(child-width, 1.0) // scale padding with effective slot width
    if child.is-leaf and not is-horiz {
      let char-w = 0.22 * content-size
      let label-chars = _rendered-len(child.label)
      let text-half-w = calc.max(label-chars * char-w / 2, 0.3 * calc.min(child-width, 1.0))
      let slot-half-w = child-width / 2
      let left-overflow = text-half-w - slot-half-w
      if left-overflow > 0 {
        cursor = cursor + left-overflow + _overflow-pad
      }
    }
    // Pre-check: if this child is a triangle, check if its text would overflow
    // leftward into the previous sibling's space. If so, push cursor right first.
    if child.anchor in tri-set and not is-horiz {
      let leaves = _collect-leaves(child)
      let joined = leaves.join(" ")
      let lines = joined.split(" \\n ")
      let lines = if lines.len() == 1 { joined.split("\\n") } else { lines }
      let char-w = 0.22 * content-size
      let widest-chars = lines.fold(0, (acc, l) => {
        calc.max(acc, _rendered-len(l.trim()))
      })
      let text-half-w = calc.max(widest-chars * char-w / 2, 0.3 * calc.min(child-width, 1.0))
      let slot-half-w = child-width / 2
      let left-overflow = text-half-w - slot-half-w
      if left-overflow > 0 {
        cursor = cursor + left-overflow + _overflow-pad
      }
    }
    // Per-child vertical gap: node-specific override > level override > default
    let child-gap = (
      v-gap
        * if child.anchor in node-spacing-map {
          node-spacing-map.at(child.anchor)
        } else if str(level + 1) in drop-map {
          drop-map.at(str(level + 1))
        } else { 1.0 }
    )
    // Extra gap when *this* node (the parent) has an annotation
    if node.anchor in annotation-gaps {
      child-gap = child-gap + annotation-gaps.at(node.anchor)
    }
    let child-nodes = _syntax-layout(
      child,
      cursor,
      y - child-gap,
      none,
      none,
      leaf-w,
      v-gap,
      tri-set,
      is-horiz: is-horiz,
      append-map: append-map,
      content-size: content-size,
      level: level + 1,
      drop-map: drop-map,
      node-spacing-map: node-spacing-map,
      sister-spacing-map: sister-spacing-map,
      sister-node-map: sister-node-map,
      annotation-map: annotation-map,
      annotation-leaf-widths: annotation-leaf-widths,
      annotation-gaps: annotation-gaps,
    )
    result = result + child-nodes
    let child-pos = if child.is-leaf or child.anchor in tri-set {
      child-nodes.at(0)
    } else {
      child-nodes.at(-1)
    }
    child-positions.push(child-pos)
    cursor = cursor + child-width
    // If this child is a triangle in a vertical tree, check if rendered text
    // overflows its slot width. Push cursor so the next sibling doesn't overlap.
    // In horizontal trees, triangle text extends outward, not into sibling space.
    if child.anchor in tri-set and not is-horiz {
      let leaves = _collect-leaves(child)
      let joined = leaves.join(" ")
      let lines = joined.split(" \\n ")
      let lines = if lines.len() == 1 { joined.split("\\n") } else { lines }
      let char-w = 0.22 * content-size
      let widest-chars = lines.fold(0, (acc, l) => {
        calc.max(acc, _rendered-len(l.trim()))
      })
      let text-half-w = calc.max(widest-chars * char-w / 2, 0.3 * calc.min(child-width, 1.0))
      let slot-half-w = child-width / 2
      let overflow = text-half-w - slot-half-w
      if overflow > 0 {
        cursor = cursor + overflow + _overflow-pad
      }
    }
    // Post-check: scan the child's entire subtree for rightward overflow.
    // Any node whose label extends past cursor pushes cursor further right,
    // preventing cross-depth overlaps with the next sibling's subtree.
    if not is-horiz and child-nodes.len() > 0 {
      let _post-pad = 0.15 * calc.min(child-width, 1.0)
      for cn in child-nodes {
        let cw = if cn.is-leaf or cn.at("is-terminal", default: false) {
          0.22 * content-size
        } else { 0.22 }
        let hw = _rendered-len(cn.label) * cw / 2
        let right-edge = cn.x + hw
        if right-edge > cursor {
          cursor = right-edge + _post-pad
        }
      }
    }
    // Post-check: if this child is a single leaf, check if its label overflows
    // rightward into the next sibling's space. Push cursor if so.
    if child.is-leaf and not is-horiz {
      let char-w = 0.22 * content-size
      let label-chars = _rendered-len(child.label)
      let text-half-w = calc.max(label-chars * char-w / 2, 0.3 * calc.min(child-width, 1.0))
      let slot-half-w = child-width / 2
      let overflow = text-half-w - slot-half-w
      if overflow > 0 {
        cursor = cursor + overflow + _overflow-pad
      }
    }
    // If this child has an append annotation, push cursor to make room
    if child.anchor in append-map {
      let app-text = append-map.at(child.anchor)
      // Strip formatting markers for width estimation
      let stripped = app-text.replace("@", "").replace("*", "").replace("&", "").replace("~", "")
      let app-char-w = 0.15 // subscript chars are smaller
      let app-width = stripped.clusters().len() * app-char-w
      cursor = cursor + app-width
    }

    // Apply local spread to the actual gap between adjacent sisters.
    // Default center-to-center distance is (left-slot + right-slot) / 2.
    // Multiplying that quantity makes spread-local behave like drop-local:
    // 0.5 halves the local spread, 1.5 increases it by 50%.
    if i < node.children.len() - 1 {
      let next-child = node.children.at(i + 1)
      let next-leaves = _leaf-count(
        next-child,
        tri-set,
        leaf-w: leaf-w,
        content-size: content-size,
        annotation-leaf-widths: annotation-leaf-widths,
      )
      let next-width = next-leaves * leaf-w
      let pair-mult = calc.max(h-mult, 0.0)
      let extra-gap = (pair-mult - 1.0) * (child-width + next-width) / 2
      cursor = cursor + extra-gap
    }
  }

  // Center this node over its children's span
  let first-child-x = child-positions.at(0).x
  let last-child-x = child-positions.at(-1).x
  let my-x = (first-child-x + last-child-x) / 2

  // Update children's parent pointers
  let updated-result = ()
  for entry in result {
    let is-direct-child = node.children.any(c => c.anchor == entry.anchor)
    if is-direct-child {
      updated-result.push((..entry, par: (my-x, y), par-anchor: node.anchor))
    } else {
      updated-result.push(entry)
    }
  }

  // Add this node
  updated-result.push((
    label: node.label,
    anchor: node.anchor,
    x: my-x,
    y: y,
    par: parent-xy,
    par-anchor: parent-anchor,
    is-leaf: false,
    is-triangle: false,
  ))

  updated-result
}

// ── Display label ────────────────────────────────────────────────────────────
// Renders a node label as content. Handles:
//   ' → prime symbol (′)
//   **text** → bold
//   *text* → italic
//   label_x → subscript x
//   label^x → superscript x
//   label^x_y → both superscript and subscript
#let _display-label(label) = {
  // ── Angle bracket protector: <et,t> → ⟨et,t⟩ ──
  let label = label.replace("<", "⟨").replace(">", "⟩")
  // ── Auto-italic traces: t_X or T_X → *t*_X or *T*_X ──
  // Only when there is a subscript (bare t/T without subscript is a regular node)
  let label = {
    let si = if label.contains("_") { label.position("_") } else { none }
    let ci = if label.contains("^") { label.position("^") } else { none }
    let end = if si != none and ci != none { calc.min(si, ci) } else if si != none { si } else { none }
    let main = if end != none { label.slice(0, end) } else if ci != none { label.slice(0, ci) } else { label }
    let bare = main.replace("*", "").replace("@", "").replace("&", "").replace("~", "")
    if not bare.contains("0") and (bare == "t" or bare == "T") and si != none {
      "*" + main + "*" + if end != none { label.slice(end) } else { "" }
    } else { label }
  }
  // Extract subscript and superscript
  // Find first occurrence of _ or ^ to split main from annotations
  let sub-text = none
  let sup-text = none
  let sub-idx = if label.contains("_") { label.position("_") } else { none }
  let sup-idx = if label.contains("^") { label.position("^") } else { none }
  // Determine where the main label ends
  let split-idx = if sub-idx != none and sup-idx != none {
    calc.min(sub-idx, sup-idx)
  } else if sub-idx != none { sub-idx } else if sup-idx != none { sup-idx } else { none }
  let main = if split-idx != none { label.slice(0, split-idx) } else { label }
  // Helper: extract braced or plain annotation after a marker (_ or ^)
  // Returns (annotation-text, tail-after-annotation)
  let _extract-annotation(after, other-marker) = {
    if after.starts-with("{") {
      // Find matching closing brace
      let depth = 0
      let end = none
      for (i, ch) in after.clusters().enumerate() {
        if ch == "{" { depth = depth + 1 }
        if ch == "}" { depth = depth - 1 }
        if depth == 0 {
          end = i
          break
        }
      }
      if end != none {
        let ann = after.slice(1, end) // strip outer { }
        let tail = after.slice(end + 1) // everything after }
        (ann, tail)
      } else {
        (after.slice(1), "") // no matching }, take everything after {
      }
    } else {
      let t = if after.contains(other-marker) { after.slice(0, after.position(other-marker)) } else { after }
      (t.replace("*", ""), "")
    }
  }
  // Tail text: anything after a braced annotation (e.g., _{[+Q]}+T+mangez → tail = "+T+mangez")
  let tail-text = ""
  // Parse the annotation portion for _ and ^
  if split-idx != none {
    let rest = label.slice(split-idx)
    // Extract subscript
    if rest.contains("_") {
      let ui = rest.position("_")
      let after = rest.slice(ui + 1)
      let (ann, tail) = _extract-annotation(after, "^")
      sub-text = ann
      if tail != "" { tail-text = tail }
    }
    // Extract superscript
    if rest.contains("^") {
      let ci = rest.position("^")
      let after = rest.slice(ci + 1)
      let (ann, tail) = _extract-annotation(after, "_")
      sup-text = ann
      if tail != "" { tail-text = tail }
    }
  }
  // Escaped asterisk: \* → placeholder (avoids italic/bold detection)
  let main = main.replace("\\*", _esc-star)
  // Detect formatting markers
  let is-bold = main.starts-with("**") and main.ends-with("**") and main.len() >= 5
  let is-italic = not is-bold and main.starts-with("*") and main.ends-with("*") and main.len() >= 3
  let is-smallcaps = main.starts-with("@") and main.ends-with("@") and main.len() >= 3
  let is-underline = main.starts-with("&") and main.ends-with("&") and main.len() >= 3
  let is-strike = main.starts-with("~") and main.ends-with("~") and main.len() >= 3
  // Strip markers
  let inner = if is-bold {
    main.slice(2, main.len() - 2)
  } else if is-italic {
    main.slice(1, main.len() - 1)
  } else if is-smallcaps {
    main.slice(1, main.len() - 1)
  } else if is-underline {
    main.slice(1, main.len() - 1)
  } else if is-strike {
    main.slice(1, main.len() - 1)
  } else { main }
  // Convert symbol shortcuts (e.g., \lambda → λ, \lambdaP → λP)
  let inner = {
    let result = inner
    for (key, val) in _symbol-map {
      if result.contains(key) {
        result = result.replace(key, val)
      }
    }
    result
  }
  // Convert prime
  let display = if inner.contains("'") or inner.contains("'") {
    let parts = inner.split("'")
    let parts = if parts.len() == 1 { inner.split("'") } else { parts }
    parts.at(0) + "′" + parts.slice(1).join("′")
  } else { inner }
  // Helper: italicize Greek Unicode characters within a string
  let _greek-set = "αβγδεζηθικλμνξπρστυφχψωΑΒΓΔΕΖΗΘΙΚΛΜΝΞΠΡΣΤΥΦΧΨΩ"
  let _italicize-greek(s) = {
    if type(s) != str { return s }
    let chars = s.clusters()
    if not chars.any(c => _greek-set.contains(c)) { return s }
    let out = []
    let buf = ""
    for c in chars {
      if _greek-set.contains(c) {
        if buf != "" { out = out + [#buf]; buf = "" }
        out = out + emph(c)
      } else {
        buf = buf + c
      }
    }
    if buf != "" { out = out + [#buf] }
    out
  }
  // Auto-superscript any "0" after a non-digit in the display string (e.g., T0 → T⁰)
  let display-content = {
    let chars = display.clusters()
    let parts = ()
    let buf = ""
    for (i, ch) in chars.enumerate() {
      if ch == "0" and i > 0 and chars.at(i - 1).match(regex("\d")) == none {
        if buf != "" { parts.push((text: buf)) }
        buf = ""
        parts.push((zero: true))
      } else {
        buf = buf + ch
      }
    }
    if buf != "" { parts.push((text: buf)) }
    if parts.any(p => p.keys().contains("zero")) {
      // Has auto-superscript zeros: build mixed content
      let out = []
      for p in parts {
        if p.keys().contains("zero") {
          out = out + [#super[0]]
        } else {
          out = out + _italicize-greek(p.text)
        }
      }
      out
    } else {
      display // plain string, no zeros to superscript
    }
  }
  // Build content
  let body = if is-bold { [*#display-content*] } else if is-italic { emph(display-content) } else if is-smallcaps {
    smallcaps(display-content)
  } else if is-underline { underline(display-content) } else if is-strike { strike(display-content) } else {
    // Check for inline *...* italic segments within the label (e.g., \lambda*p*)
    if type(display-content) == str and display-content.contains("*") {
      let parts = display-content.split("*")
      let out = []
      for (i, part) in parts.enumerate() {
        if calc.rem(i, 2) == 1 {
          out = out + emph(part)
        } else if part != "" {
          out = out + _italicize-greek(part)
        }
      }
      out
    } else if type(display-content) == str {
      _italicize-greek(display-content)
    } else {
      display-content
    }
  }
  // Apply symbol substitution to sub/superscript text
  let _apply-sym(t) = {
    let r = t
    for (key, val) in _symbol-map {
      if r.contains(key) { r = r.replace(key, val) }
    }
    r
  }
  // Detect if annotation was braced (should not be italicized)
  let sub-braced = sub-text != none and label.contains("_{")
  let sup-braced = sup-text != none and label.contains("^{")
  let result = if sup-text != none and sup-text != "" and sub-text != none and sub-text != "" {
    let sup-display = _apply-sym(sup-text)
    let sub-display = _apply-sym(sub-text)
    let sup-r = if sup-braced { [#super[#sup-display]] } else { [#super[_#sup-display _]] }
    let sub-r = if sub-braced { [#sub[#sub-display]] } else { [#sub[_#sub-display _]] }
    [#body#sup-r#sub-r]
  } else if sup-text != none and sup-text != "" {
    let sup-display = _apply-sym(sup-text)
    if sup-braced { [#body#super[#sup-display]] } else { [#body#super[_#sup-display _]] }
  } else if sub-text != none and sub-text != "" {
    let sub-display = _apply-sym(sub-text)
    if sub-braced { [#body#sub[#sub-display]] } else { [#body#sub[_#sub-display _]] }
  } else { body }
  // Append tail text (e.g., +T+mangez after _{[+Q]})
  let final = if tail-text != "" {
    [#result#tail-text]
  } else { result }
  // Restore escaped asterisk placeholder → literal *
  { show _esc-star: [#"*"]; final }
}

// ── Inline formatter for append text ────────────────────────────────────────
// Processes @...@ segments as smallcaps, &...& as underline, *...* as italic,
// **...** as bold. Everything else is plain text.
#let _format-inline(s) = {
  let parts = s.split("@")
  let result = ()
  for (i, part) in parts.enumerate() {
    if calc.rem(i, 2) == 1 {
      // Odd segments: smallcaps
      result.push(smallcaps(part))
    } else if part != "" {
      result.push(part)
    }
  }
  result.join()
}

// ── Estimate label half-width in canvas units ───────────────────────────────
// Used for horizontal trees where branch offsets must clear the label width.
#let _label-half-w(label) = {
  let stripped = _strip-fmt(label)
  let char-w = 0.28 // approximate character width in canvas units
  _apply-symbols(stripped).clusters().len() * char-w / 2 + 0.05
}

// ── Delink mark ─────────────────────────────────────────────────────────────
// Draws two perpendicular bars at a given point along a given tangent direction.
// (mx, my): midpoint on the path; (tang-x, tang-y): tangent direction (will be normalized).
#let _draw-delink(mx, my, tang-x, tang-y, sw) = {
  let len = calc.sqrt(tang-x * tang-x + tang-y * tang-y)
  if len == 0 { return }
  let dir-x = tang-x / len
  let dir-y = tang-y / len
  let perp-x = -dir-y
  let perp-y = dir-x
  let bar = 0.15
  let gap = 0.03
  for sign in (-1, 1) {
    let cx = mx + sign * gap * dir-x
    let cy = my + sign * gap * dir-y
    cetz.draw.line(
      (cx - bar * perp-x, cy - bar * perp-y),
      (cx + bar * perp-x, cy + bar * perp-y),
      stroke: sw,
    )
  }
}


// ── Main function ────────────────────────────────────────────────────────────
/// Draw a syntax tree from bracket notation
///
/// Parses a bracket-notation string and renders a phrase structure tree.
/// Each node receives an automatic anchor name (lowercased label + counter,
/// e.g. `"cp1"`, `"tp2"`) that can be used for cross-node arrows.
///
/// Arguments:
/// - input (string): Bracket notation, e.g. `"[CP [C' [C did] [TP ...]]]"`
/// - arrows (array): Cross-node arrows. Each entry is either `(from, to)` or a
///   dict with keys: `from`, `to`, `color`, `bend` (arc depth, auto if omitted),
///   `shift` (horizontal bias of arc apex, default `0`), `dash` (`"dashed"`,
///   `"solid"`, `"dotted"`, etc.). Arrow names use the automatic anchors
///   and always target leaf content (the "down" position). (default: `()`)
/// - scale (number): Uniform scale factor (default: `1.0`)
/// - drop (number): Multiplier for vertical distance between levels
///   (default: `1.0`). A value of `1.2` increases branch length by 20%.
/// - spread (number): Horizontal width per leaf in canvas units (default: `1.0`)
/// - triangle (array): Anchor names whose branch should render as a triangle
///   for elided structure, e.g. `("dp1",)` (default: `()`)
/// - curved (bool): Draw arrows as Bézier curves (default: `false`)
/// - direction (string): Growth direction of the tree: `"down"` (default),
///   `"up"`, `"right"`, or `"left"`.
/// - highlight (array): Anchor names to draw a box around (like `\fbox` in LaTeX).
///   Bare names default to the node label; use `"dp1down"` to box the leaf content
///   instead. (default: `()`)
/// - bottom (bool): Align all terminal words at the bottom of the tree. When `true`,
///   leaves are pushed to the lowest level regardless of depth. (default: `false`)
/// - dash-branches (array): Array of `(parent, child)` anchor pairs whose branch
///   line should be dashed instead of solid, e.g. `dash-branches: (("np1", "det1"),)`.
///   (default: `()`)
/// - delinks (array): Anchor names matching arrow `from` fields. The delink mark
///   (two perpendicular bars) is drawn on the matching arrow's shaft, e.g.
///   `delinks: ("dp3",)`. Only interpreted when a matching arrow exists. (default: `()`)
/// - index (array): Coreference subscripts. Array of single-key dicts mapping anchor
///   names to index strings, e.g. `(("cp1": "i"), ("np2": "j"))`. Rendered as
///   subscripts after the node label. (default: `()`)
/// - drop-local (array): Per-level or per-node branch length multipliers.
///   Each entry is a tuple where the first element is a level number (int) or
///   anchor name (string):
///   - `(1, 1.5)` — all level-1 branches are 50% longer
///   - `("ip2", 0.5)` — only the branch arriving at `ip2` is 50% shorter
///   Node-specific entries override level entries. (default: `()`)
/// - spread-local (array): Per-level or per-node horizontal spacing multipliers
///   between sister nodes. Same format as `drop-local`:
///   - `(1, 1.5)` — level-1 sisters are 50% wider apart
///   - `("ip2", 0.5)` — the gap after `ip2` is 50% narrower
///   (default: `()`)
/// - dominance (array): Long-distance dominance lines (no arrowheads). Each entry
///   is a tuple `("from-anchor", "to-anchor")` or a dict with optional `ctrl`:
///   `(from: "np4", to: "np1", ctrl: (-1.0, -0.5))`. Lines depart south and
///   arrive north, matching branch connection points. (default: `()`)
/// - color (array): Colorize nodes, leaf content, or branches. Each entry is a tuple:
///   - `("np1", red)` — color the node label text of `np1`
///   - `("np1down", blue)` — color the leaf/content text under `np1`
///   - `("vp1", "v1", yellow)` — color the branch from `vp1` to `v1`
///   (default: `()`)
/// - annotation (array): Semantic annotations displayed between a node label and
///   its branches. Each entry is `("anchor", content)` where content is Typst
///   content (use `$...$` for math/logic). Example:
///   `annotation: (("dp1", $lambda Q forall x$),)` (default: `()`)
/// - annotation-size (float): Size multiplier for annotation text relative to base
///   font size. The vertical gap between node and branches adjusts automatically.
///   (default: `0.70`)
/// - annotation-leading (length or auto): Line spacing for multi-line annotations.
///   Use smaller values like `0.3em` to tighten line spacing.
///   (default: `auto`, which uses `0.45em`)
///
/// Returns: CeTZ drawing of the syntax tree
///
/// Example:
/// ```
/// #tree("[CP [C' [C did] [TP [DP she] [T' [T e] [VP [V leave]]]]]]")
/// ```
#let tree(
  input,
  arrows: (),
  scale: 1.0,
  spread: 1.0,
  triangle: (),
  content-size: 0.8,
  node-size: 1.0,
  curved: false,
  direction: "down",
  highlight: (),
  bottom: false,
  terminal-branch: false,
  dash-branches: (),
  delinks: (),
  index: (),
  append: (),
  drop: 1.0,
  drop-local: (),
  spread-local: (),
  dominance: (),
  color: (),
  annotation: (),
  annotation-size: 0.70,
  annotation-leading: auto,
  line-width: 1.0,
  font: none,
  numbers: (),
  numbers-size: 0.85,
) = {
  let scale-factor = scale
  let is-horiz = direction == "right" or direction == "left"
  let leaf-w = spread
  let v-gap = if is-horiz { 1.2 * drop * 1.05 } else { 1.2 * drop }

  // ── Build drop-local lookup maps ─────────────────────
  let _drop-map = (:) // str(level) → multiplier
  let _node-spacing-map = (:) // anchor → multiplier
  // Normalize: single entry → array
  let ls-entries = if drop-local == () {
    ()
  } else if type(drop-local.at(0, default: none)) != array {
    (drop-local,)
  } else {
    drop-local
  }
  for entry in ls-entries {
    let key = entry.at(0)
    let mult = entry.at(1)
    if type(key) == int {
      _drop-map.insert(str(key), mult)
    } else if type(key) == str {
      _node-spacing-map.insert(key, mult)
    }
  }

  // ── Build spread-local lookup maps ──────────────────────────────
  let _sister-spacing-map = (:) // str(level) → multiplier
  let _sister-node-map = (:) // anchor → multiplier
  let ss-entries = if spread-local == () {
    ()
  } else if type(spread-local.at(0, default: none)) != array {
    (spread-local,)
  } else {
    spread-local
  }
  for entry in ss-entries {
    let key = entry.at(0)
    let mult = entry.at(1)
    if type(key) == int {
      _sister-spacing-map.insert(str(key), mult)
    } else if type(key) == str {
      _sister-node-map.insert(key, mult)
    }
  }

  // ── Build color lookup maps ───────────────────────────────────
  // Normalize: single tuple → array of tuples
  let color-entries = if color == () {
    ()
  } else if type(color.at(0, default: none)) != array {
    // Single entry like (\"np1\", red) — wrap it
    (color,)
  } else {
    color
  }
  // node-color-map: anchor → color (for node labels)
  // down-color-map: anchor → color (for leaf content, keyed without "down" suffix)
  // branch-color-map: "parent|child" → color (for branches)
  let node-color-map = (:)
  let down-color-map = (:)
  let branch-color-map = (:)
  for entry in color-entries {
    if entry.len() == 3 {
      // Branch color: (parent-anchor, child-anchor, color)
      let key = entry.at(0) + "|" + entry.at(1)
      branch-color-map.insert(key, entry.at(2))
    } else if entry.len() == 2 {
      let name = entry.at(0)
      let c = entry.at(1)
      if type(name) == str and name.ends-with("-down") {
        let base = name.slice(0, name.len() - 5)
        down-color-map.insert(base, c)
      } else {
        node-color-map.insert(name, c)
      }
    }
  }
  // Bottom-aligned leaves require terminal branches; otherwise looks weird
  let terminal-branch = if bottom { true } else { terminal-branch }

  // Parse
  let tokens = _tokenize(input)
  let (tree, _, _) = _parse(tokens, 0, (:))

  // Build triangle set from anchor names
  let tri-set = triangle

  // Auto-triangle: phrase nodes (label len > 1, ends in P) with only leaf children
  let _auto-tri(node) = {
    let result = ()
    if not node.is-leaf and node.children.len() > 0 {
      let stripped = _strip-fmt(node.label)
      let is-phrase = (stripped.len() > 1 and lower(stripped).ends-with("p")) or node.label.ends-with(">")
      let all-leaves = node.children.all(c => c.is-leaf)

      if is-phrase and all-leaves {
        result.push(node.anchor)
      }

      for child in node.children {
        result = result + _auto-tri(child)
      }
    }
    result
  }
  let tri-set = tri-set + _auto-tri(tree)

  // Build append map: anchor → formatted subscript text
  let append-map = (:)
  for entry in append {
    let (anchor, text-str) = entry
    append-map.insert(anchor, text-str)
  }

  // Build annotation map: anchor → Typst content
  let annotation-map = (:)
  for entry in annotation {
    let (anchor, annotation-content) = entry
    annotation-map.insert(anchor, annotation-content)
  }
  let annotation-gap = calc.max(annotation-size * (0.45 / 0.70), 0.25)

  let _body = context {
    let em-in-cu = text.size / (scale-factor * 1cm)
    let fsz = 12 * scale-factor * 1pt

    // Measure annotation widths and heights; compute per-anchor gaps
    let annotation-leaf-widths = (:)
    let annotation-gaps = (:)
    // Resolve annotation leading
    let annotation-leading-val = if annotation-leading == auto { 0.45em } else { annotation-leading }
    for (anchor, annotation-content) in annotation-map {
      let annotation-body = {
        set text(size: fsz * annotation-size)
        set par(leading: annotation-leading-val)
        annotation-content
      }
      let measured = measure(annotation-body)
      // Convert measured width to leaf-width units (each leaf = leaf-w * scale-factor * 1cm)
      let width-in-units = measured.width / (leaf-w * scale-factor * 1cm)
      annotation-leaf-widths.insert(anchor, width-in-units)
      // Convert measured height to canvas units for vertical gap
      let height-in-units = measured.height / (scale-factor * 1cm)
      let gap = calc.max(height-in-units + 0.30, annotation-gap)
      annotation-gaps.insert(anchor, gap)
    }

    // Layout (triangle-aware)
    let nodes = _syntax-layout(
      tree,
      0.0,
      0.0,
      none,
      none,
      leaf-w,
      v-gap,
      tri-set,
      is-horiz: is-horiz,
      append-map: append-map,
      content-size: content-size,
      level: 0,
      drop-map: _drop-map,
      node-spacing-map: _node-spacing-map,
      sister-spacing-map: _sister-spacing-map,
      sister-node-map: _sister-node-map,
      annotation-map: annotation-map,
      annotation-leaf-widths: annotation-leaf-widths,
      annotation-gaps: annotation-gaps,
    )

    // Bottom-align: push all leaves and triangle text to the lowest y in the tree
    if bottom {
      let min-y = nodes.fold(0.0, (acc, e) => {
        if e.is-leaf { calc.min(acc, e.y) } else { acc }
      })
      // Also consider triangle leaf positions
      let min-y = nodes.fold(min-y, (acc, e) => {
        if e.at("is-triangle", default: false) { calc.min(acc, e.at("tri-y")) } else { acc }
      })
      nodes = nodes.map(e => {
        if e.is-leaf { (..e, y: min-y) } else if e.at("is-triangle", default: false) {
          (..e, tri-y: min-y, bottom-aligned: true)
        } else { e }
      })
    }

    // Reduce terminal-to-parent gap when no branch line is drawn
    // (skip when bottom-aligned, since bottom alignment should take precedence)
    if not terminal-branch and not bottom {
      nodes = nodes.map(e => {
        if e.at("is-terminal", default: false) and e.par != none {
          // Horizontal trees need more gap (labels extend from position)
          let pull = if is-horiz { 0.2 } else { 0.5 }
          let mid-y = e.y + (e.par.at(1) - e.y) * pull
          (..e, y: mid-y)
        } else { e }
      })
    }

    // Align terminal leaves with sibling triangles when terminal branches are drawn
    if terminal-branch and not bottom {
      // Build parent → min child y map (considering tri-y for triangles)
      let parent-min-y = (:)
      for e in nodes {
        if e.par != none {
          let pk = e.at("par-anchor", default: "")
          if pk != "" {
            let cy = if e.at("is-triangle", default: false) { e.at("tri-y") } else if e.is-leaf { e.y } else { none }
            if cy != none {
              let cur = parent-min-y.at(pk, default: cy)
              parent-min-y.insert(pk, calc.min(cur, cy))
            }
          }
        }
      }
      // Push terminal leaves to their parent's min child y
      nodes = nodes.map(e => {
        if e.at("is-terminal", default: false) and e.par != none {
          let pk = e.at("par-anchor", default: "")
          if pk != "" and pk in parent-min-y {
            let target-y = parent-min-y.at(pk)
            if target-y < e.y {
              (..e, y: target-y, is-terminal-aligned: true)
            } else { e }
          } else { e }
        } else { e }
      })
    }

    // Direction transform: map layout coords (always computed as "down") to final coords
    let _tx(x, y) = {
      if direction == "up" { (x, -y) } else if direction == "right" { (-y, -x) } else if direction == "left" {
        (y, -x)
      } else { (x, y) }
    }
    // Growth direction vector (from parent toward child in final coords)
    let (gdx, gdy) = if direction == "up" { (0, 1) } else if direction == "right" { (1, 0) } else if (
      direction == "left"
    ) {
      (-1, 0)
    } else { (0, -1) }

    // Build per-node outgoing offset (from center to where branch departs)
    // and incoming offset (from center to where branch arrives).
    // Vertical: symmetric, fixed _loff.
    // Horizontal: labels are aligned (left for "right", right for "left"),
    //   so outgoing = full label width, incoming = small gap.
    let node-out = (:) // offset for branches leaving this node
    let node-in = (:) // offset for branches arriving at this node
    for e in nodes {
      if is-horiz {
        let full-w = _label-half-w(e.label) * 2
        let is-tri = e.at("is-triangle", default: false)
        node-out.insert(e.anchor, if is-tri { full-w + 0.25 } else { full-w })
        node-in.insert(e.anchor, 0.05)
      } else {
        node-out.insert(e.anchor, _loff)
        node-in.insert(e.anchor, _loff)
      }
    }

    // Increase node-out for nodes with annotations to push branches below the annotation
    for (anchor, _) in annotation-map {
      let current = node-out.at(anchor, default: _loff)
      node-out.insert(anchor, current + annotation-gaps.at(anchor, default: annotation-gap))
    }

    // Transform all node coordinates
    nodes = nodes.map(e => {
      let (nx, ny) = _tx(e.x, e.y)
      let new-par = if e.par != none {
        let (px, py) = _tx(e.par.at(0), e.par.at(1))
        (px, py)
      } else { none }
      let result = (..e, x: nx, y: ny, par: new-par)
      if e.at("is-triangle", default: false) {
        let (_, ty-raw) = _tx(e.x, e.at("tri-y"))
        // For horizontal directions, tri position needs both coords
        let (tri-nx, tri-ny) = _tx(e.x, e.at("tri-y"))
        (..result, tri-y: tri-ny, tri-x: tri-nx)
      } else { result }
    })

    // Build name-to-pos dict (outside canvas, following geom.typ pattern)
    // Also build arrow-off-map: per-anchor arrow clearance (distance from reference to below text)
    let _text-half-h = 0.2
    let _arrow-gap = 0.25
    let name-to-pos = (:)
    let arrow-off-map = (:)
    let label-hw-map = (:) // per-anchor label half-width (horizontal semi-axis for degree arrows)
    let regular-off = _text-half-h + _arrow-gap // 0.45: from text center to below text + gap
    for e in nodes {
      name-to-pos.insert(e.anchor, (e.x, e.y, _loff))
      arrow-off-map.insert(e.anchor, regular-off)
      label-hw-map.insert(e.anchor, _rendered-len(e.label) * 0.28 / 2 + 0.05)
    }

    // Add "down" positions: point to leaf content below each non-leaf node.
    // Walk the parsed tree to find leaf descendants for each node.
    let _build-down(node, ntp, aom, lhw) = {
      if node.is-leaf or node.children.len() == 0 {
        // Leaf: "-down" is same as the node
        ntp.insert(node.anchor + "-down", ntp.at(node.anchor))
        aom.insert(node.anchor + "-down", regular-off)
        lhw.insert(node.anchor + "-down", _rendered-len(node.label) * 0.28 / 2 + 0.05)
        return (ntp, aom, lhw)
      }
      // Triangle node: "-down" = the combined label position (tri-y)
      let tri-entry = nodes.filter(e => e.anchor == node.anchor and e.at("is-triangle", default: false))
      if tri-entry.len() > 0 {
        let te = tri-entry.at(0)
        ntp.insert(node.anchor + "-down", (te.x, te.at("tri-y"), _loff))
        // Triangle text: top is at tri-y + gdy*tri-text-gap, so offset = tri-text-gap + text-height + gap
        let tri-off = 0.05 + _text-half-h * 2 + _arrow-gap
        aom.insert(node.anchor + "-down", tri-off)
        // Triangle text width: use the widest line of the combined label
        let tri-label = te.at("tri-label")
        let tri-lines = tri-label.split(" \\n ")
        let tri-lines = if tri-lines.len() == 1 { tri-label.split("\\n") } else { tri-lines }
        let widest = tri-lines.fold(0, (acc, l) => calc.max(acc, _rendered-len(l.trim())))
        let char-w = 0.22 * content-size
        let tri-hw = calc.max(widest * char-w / 2, 0.3)
        lhw.insert(node.anchor + "-down", tri-hw)
        return (ntp, aom, lhw)
      }
      // Non-triangle non-leaf: find leaf descendants, average their positions
      let leaf-anchors = _collect-leaf-anchors(node)
      let found = leaf-anchors.filter(a => a in ntp)
      if found.len() > 0 {
        let avg-x = found.map(a => ntp.at(a).at(0)).fold(0.0, (a, b) => a + b) / found.len()
        let ys = found.map(a => ntp.at(a).at(1))
        let leaf-y = if gdy < 0 { calc.min(..ys) } else { calc.max(..ys) }
        ntp.insert(node.anchor + "-down", (avg-x, leaf-y, _loff))
        aom.insert(node.anchor + "-down", regular-off)
        // Span of leaf descendants as half-width
        let xs = found.map(a => ntp.at(a).at(0))
        let span-hw = if xs.len() > 1 {
          (calc.max(..xs) - calc.min(..xs)) / 2 + 0.3
        } else {
          (
            _rendered-len(nodes.filter(e => e.anchor == found.at(0)).at(0, default: (label: "XX")).label) * 0.28 / 2
              + 0.05
          )
        }
        lhw.insert(node.anchor + "-down", span-hw)
      }
      // Recurse into children
      for child in node.children {
        (ntp, aom, lhw) = _build-down(child, ntp, aom, lhw)
      }
      (ntp, aom, lhw)
    }
    (name-to-pos, arrow-off-map, label-hw-map) = _build-down(tree, name-to-pos, arrow-off-map, label-hw-map)

    // Build trace anchors: trace1, trace2, etc.
    let trace-infos = _find-traces(tree)
    let trace-count = 0
    for ti in trace-infos {
      trace-count = trace-count + 1
      let trace-anchor = "trace" + str(trace-count)
      // Check if this trace is inside a triangle
      let parent-is-tri = ti.parent-anchor in tri-set
      if parent-is-tri {
        // Find the triangle entry to get its position
        let tri-entries = nodes.filter(e => e.anchor == ti.parent-anchor and e.at("is-triangle", default: false))
        if tri-entries.len() > 0 {
          let te = tri-entries.at(0)
          let tri-leaves = te.at("tri-leaves")
          // Find the trace's word index in the leaf list (skip \n markers)
          let word-idx = 0
          let total-words = tri-leaves.filter(w => w != "\\n").len()
          for (i, leaf) in tri-leaves.enumerate() {
            if leaf == "\\n" { continue }
            if _is-trace(leaf) { break }
            word-idx = word-idx + 1
          }
          // Use the triangle's "down" position as base (same y that works for arrows)
          let down-key = ti.parent-anchor + "-down"
          if down-key in name-to-pos {
            let (down-x, down-y, down-loff) = name-to-pos.at(down-key)
            let down-off = arrow-off-map.at(down-key, default: regular-off)
            // Estimate x offset for the trace word within the text
            let char-w = 0.22 * content-size
            let tri-label = te.at("tri-label")
            let tri-text-lines = tri-label.split(" \\n ")
            let tri-text-lines = if tri-text-lines.len() == 1 { tri-label.split("\\n") } else { tri-text-lines }
            let widest = tri-text-lines.fold(0, (acc, l) => calc.max(acc, _rendered-len(l.trim())))
            let half-w = calc.max(widest * char-w / 2, 0.3)
            let vert-growth = direction == "down" or direction == "up"
            let frac = (word-idx + 0.5) / total-words
            // Shift from text anchor to text center:
            // Triangle text is rendered with anchor "north"/"south" at tri-y + gdy*0.05.
            // Regular nodes use anchor "center", so their position IS the center.
            // To match, offset by tri-text-gap + text-half-height toward growth.
            let tri-text-gap = 0.05
            let center-shift = tri-text-gap + _text-half-h * content-size
            // sub[] extends the trace word visually to the right (in physical
            // units), shifting its apparent center; compensate in canvas units.
            let x-sub-correction = -0.08 / scale
            let (trace-x, trace-y) = if vert-growth {
              (down-x - half-w + frac * 2 * half-w + x-sub-correction, down-y + gdy * center-shift)
            } else {
              (down-x + gdx * center-shift, down-y - half-w + frac * 2 * half-w + x-sub-correction)
            }
            name-to-pos.insert(trace-anchor, (trace-x, trace-y, _loff))
            // Extra clearance: Typst's sub[] positions subscripts beyond the
            // content bounding box that CeTZ measures for anchor placement.
            // The overflow is constant in physical units, so we divide by
            // scale to keep the physical gap consistent across scales.
            let trace-off = regular-off + 0.20 / scale
            arrow-off-map.insert(trace-anchor, trace-off)
            label-hw-map.insert(trace-anchor, _rendered-len(ti.label) * 0.28 / 2 + 0.05)
          }
        }
      } else {
        // Non-triangle: trace is a regular leaf, use its position
        if ti.leaf-anchor in name-to-pos {
          name-to-pos.insert(trace-anchor, name-to-pos.at(ti.leaf-anchor))
          let trace-off = _text-half-h + 0.05
          arrow-off-map.insert(trace-anchor, trace-off)
          label-hw-map.insert(trace-anchor, _label-half-w(ti.label))
        }
      }
    }

    // Resolve highlight names into a set of actual node anchors to box.
    // Default: bare name → node itself (unlike arrows which default to "down").
    // "dp3-down" → box the leaf descendants of dp3.
    let box-set = ()
    for h in highlight {
      if h.ends-with("-down") {
        let base = h.slice(0, h.len() - 5)
        let target = _find-node(tree, base)
        if target != none {
          box-set = box-set + _collect-leaf-anchors(target)
        }
      } else if h.ends-with("up") {
        let base = h.slice(0, h.len() - 2)
        box-set.push(base)
      } else {
        box-set.push(h)
      }
    }

    // Build index lookup: anchor → subscript string.
    // Default: bare name → leaf content ("down"), like arrows.
    // "dp1up" → attach index to the DP node label itself.
    let index-map = (:)
    for entry in index {
      for (k, v) in entry.pairs() {
        if k.ends-with("up") {
          index-map.insert(k.slice(0, k.len() - 2), v)
        } else if k.ends-with("-down") {
          let base = k.slice(0, k.len() - 5)
          let target = _find-node(tree, base)
          if target != none {
            for leaf in _collect-leaf-anchors(target) {
              index-map.insert(leaf, v)
            }
          }
        } else {
          // Bare name: default to "down" only if node has exactly one leaf descendant.
          // For complex nodes (CP with many children), stay on the node itself.
          let target = _find-node(tree, k)
          if target != none and not target.is-leaf and target.children.len() > 0 {
            let leaves = _collect-leaf-anchors(target)
            if leaves.len() == 1 {
              index-map.insert(leaves.at(0), v)
            } else {
              index-map.insert(k, v)
            }
          } else {
            index-map.insert(k, v)
          }
        }
      }
    }

    // Build numbers lookup: anchor → circled digit
    let numbers-map = (:)
    let _circled = ("①", "②", "③", "④", "⑤", "⑥", "⑦", "⑧", "⑨", "⑩",
                     "⑪", "⑫", "⑬", "⑭", "⑮", "⑯", "⑰", "⑱", "⑲", "⑳")
    // Normalize: single entry (("a", 1),) vs array of entries
    let num-entries = if numbers.len() > 0 and type(numbers.at(0)) == str {
      (numbers,)
    } else { numbers }
    for entry in num-entries {
      let anchor = entry.at(0)
      let n = entry.at(1)
      let display = if n >= 1 and n <= 20 { _circled.at(n - 1) } else { "(" + str(n) + ")" }
      numbers-map.insert(anchor, display)
    }

    // Normalize arrows:
    // - single dict: (from: "a", to: "b") → wrapped in array
    // - single flat pair: ("a", "b") → wrapped in array
    // - array of arrows: (("a", "b"), ...) → used as-is
    let arrows = if type(arrows) == dictionary {
      (arrows,)
    } else if arrows.len() > 0 and type(arrows.at(0)) == str {
      (arrows,)
    } else { arrows }

    // Colors
    let _norm = luma(15%)

    box(inset: 1.2em, baseline: 40%, {
      cetz.canvas(length: scale-factor * 1cm, {
        import cetz.draw: *

        let node-fsz = fsz * node-size // non-terminal node labels
        let content-fsz = fsz * content-size // terminal/leaf content
        let sw = 0.05em * scale-factor * line-width
        let arrow-sw = 0.018
        let arrow-mark-scale = 0.5

        // ── Draw edges ──────────────────────────────────────────────────
        // Triangle nodes still get a line FROM their parent TO them;
        // the triangle itself replaces the lines from the node to its children.
        for e in nodes {
          if e.par != none and (terminal-branch or not e.at("is-terminal", default: false)) {
            let branch-key = e.at("par-anchor", default: "") + "|" + e.anchor
            let col = branch-color-map.at(branch-key, default: _norm)
            let is-dashed = (
              e.at("par-anchor", default: none) != none
                and dash-branches.any(pair => {
                  pair.at(0) == e.par-anchor and pair.at(1) == e.anchor
                })
            )
            let edge-stroke = if is-dashed {
              (paint: col, thickness: sw, dash: "dashed")
            } else {
              (paint: col, thickness: sw)
            }
            let par-off = node-out.at(e.par-anchor, default: _loff)
            let child-off = node-in.at(e.anchor, default: _loff)
            line(
              (e.par.at(0) + gdx * par-off, e.par.at(1) + gdy * par-off),
              (e.x - gdx * child-off, e.y - gdy * child-off),
              stroke: edge-stroke,
            )
          }
        }

        // ── Draw triangles ──────────────────────────────────────────────
        for e in nodes {
          if e.at("is-triangle", default: false) {
            let col = _norm
            let tri-label = e.at("tri-label")
            // Triangle label position
            let tlx = e.at("tri-x", default: e.x)
            let tly = e.at("tri-y")
            let vert-growth = direction == "down" or direction == "up"
            // Compute half-spread for triangle base
            let half-w = if vert-growth {
              // Vertical trees: base width from text character width
              let char-w = 0.22 * content-size
              let tri-text-lines = tri-label.split(" \\n ")
              let tri-text-lines = if tri-text-lines.len() == 1 { tri-label.split("\\n") } else { tri-text-lines }
              let widest = tri-text-lines.fold(0, (acc, l) => calc.max(acc, _rendered-len(l.trim())))
              calc.max(widest * char-w / 2, 0.3)
            } else {
              // Horizontal trees: base height proportional to number of text lines
              let tri-text-lines = tri-label.split(" \\n ")
              let tri-text-lines = if tri-text-lines.len() == 1 { tri-label.split("\\n") } else { tri-text-lines }
              let n-lines = tri-text-lines.len()
              let line-h = 0.55 // approximate height per line in canvas units
              calc.max(n-lines * line-h / 2, 0.4)
            }
            // Apex: node center offset toward children (same as branch offset)
            let has-sub = e.anchor in annotation-map
            let tri-off = node-out.at(e.anchor, default: _loff)
            let apex = (e.x + gdx * tri-off, e.y + gdy * tri-off)
            // Base endpoints (perpendicular to growth)
            let (b1, b2) = if vert-growth {
              (
                (tlx - half-w, tly - gdy * _loff),
                (tlx + half-w, tly - gdy * _loff),
              )
            } else {
              // Extend base outward so the triangle depth matches the apex-to-text distance
              let base-ext = _loff
              (
                (tlx + gdx * base-ext, tly - half-w),
                (tlx + gdx * base-ext, tly + half-w),
              )
            }
            line(apex, b1, stroke: (paint: col, thickness: sw))
            line(apex, b2, stroke: (paint: col, thickness: sw))
            line(b1, b2, stroke: (paint: col, thickness: sw))
          }
        }

        // ── Draw node labels ────────────────────────────────────────────
        for e in nodes {
          let col = if e.at("is-terminal", default: false) {
            down-color-map.at(e.at("par-anchor", default: ""), default: _norm)
          } else {
            node-color-map.at(e.anchor, default: _norm)
          }
          let display = _display-label(e.label)
          // Use smaller font for terminal content (leaves), full size for node labels.
          // Also treat bracketed nodes with no uppercase letters as content-sized
          // (e.g., [and] is a conjunction, not a syntactic category).
          let _has-upper = _strip-fmt(e.label).match(regex("[A-Z]")) != none
          let sz = if e.at("is-terminal", default: false) or (e.is-leaf and not _has-upper) { content-fsz } else {
            node-fsz
          }
          // Append coreference subscript if present
          let idx = index-map.at(e.anchor, default: none)
          // Build base label with optional coreference index
          let base-label = if idx != none {
            [#text(size: sz, fill: col, display)#sub[#text(
                font: font,
                size: sz * 0.75,
                style: "italic",
                fill: col,
                idx,
              )]]
          } else {
            text(size: sz, fill: col, display)
          }
          // Append is drawn separately below, so label-content is just the base
          let label-content = base-label
          let boxed = e.anchor in box-set
          let label-body = if boxed {
            box(stroke: 0.5pt + col, inset: 2pt, label-content)
          } else {
            label-content
          }

          // CeTZ anchor for label alignment in horizontal trees
          let label-anchor = if direction == "right" { "west" } else if direction == "left" { "east" } else { "center" }

          if e.at("is-triangle", default: false) {
            // Draw the node label (e.g. "DP")
            content((e.x, e.y), label-body, anchor: label-anchor)
            // Draw combined triangle label using _display-label for formatting
            let tri-leaves = e.at("tri-leaves")
            let tri-leaf-boxed = highlight.any(h => h == e.anchor + "-down")
            let tri-col = down-color-map.at(e.anchor, default: _norm)
            // Build rendered content for each leaf, split by \n markers
            let lines = ((),) // array of arrays (one per line)
            for leaf in tri-leaves {
              if leaf == "\\n" {
                lines.push(()) // start a new line
              } else {
                lines.at(-1).push(leaf)
              }
            }
            let line-contents = lines.map(words => {
              // Render each word, then join into a single text element
              // to avoid paragraph-level line spacing from content joins
              let rendered = words.map(w => _display-label(w))
              let joined = text(size: content-fsz, fill: tri-col, rendered.join([ ]))
              if tri-leaf-boxed { box(stroke: 0.5pt + tri-col, inset: 2pt, joined) } else { joined }
            })
            let tri-align = if direction == "right" { left } else if direction == "left" { right } else { center }
            let tri-body = if line-contents.len() > 1 {
              align(tri-align, stack(spacing: 0.35em, ..line-contents))
            } else {
              line-contents.at(0)
            }
            let is-bottom-aligned = e.at("bottom-aligned", default: false)
            let tri-text-gap = if is-bottom-aligned { 0 } else if is-horiz { 0.80 } else { 0.05 }
            let tlx2 = e.at("tri-x", default: e.x)
            let tly2 = e.at("tri-y")
            // Bottom-aligned: use "center" to match regular leaf alignment.
            // Otherwise: anchor at top so multi-line content grows downward only.
            let tri-anchor = if is-bottom-aligned { "center" } else if direction == "up" { "south" } else if (
              direction == "down"
            ) { "north" } else if (
              direction == "right"
            ) { "west" } else { "east" }
            content((tlx2 + gdx * tri-text-gap, tly2 + gdy * tri-text-gap), tri-body, anchor: tri-anchor)
          } else {
            // In horizontal trees, pull terminal leaves closer to their parent
            let (lx, ly) = (e.x, e.y)
            let cur-anchor = label-anchor
            let is-terminal = e.at("is-terminal", default: false)
            let is-term-aligned = e.at("is-terminal-aligned", default: false)
            // Synchronize terminal nodes with triangles when terminal branches are drawn
            if (is-terminal or is-term-aligned) and terminal-branch and not bottom {
              let tri-text-gap = if is-horiz { 0.80 } else { 0.05 }
              lx = lx + gdx * tri-text-gap
              ly = ly + gdy * tri-text-gap
              cur-anchor = if direction == "up" { "south" } else if direction == "down" { "north" } else if (
                direction == "right"
              ) { "west" } else { "east" }
            } else if not is-horiz and is-terminal {
              // Vertical terminal content should grow away from the tree, not be
              // centered on the terminal point. Center anchoring makes words with
              // different glyph shapes look vertically misaligned even when their
              // layout coordinates are identical.
              cur-anchor = if direction == "up" { "south" } else { "north" }
            } else if is-horiz and is-terminal and e.par != none {
              let pull = 0.4 // fraction of distance to reclaim
              lx = lx + (e.par.at(0) - lx) * pull
              ly = ly + (e.par.at(1) - ly) * pull
            }
            content((lx, ly), label-body, anchor: cur-anchor)
          }
          // Draw circled number to the left of the node
          let num-display = numbers-map.at(e.anchor, default: none)
          if num-display != none {
            let label-hw = _label-half-w(e.label)
            let num-body = text(size: sz * numbers-size, num-display)
            let num-gap = 0.08 // small gap between number and label
            content((e.x - label-hw - num-gap, e.y), num-body, anchor: "east")
          }
          // Draw append subscript as separate content (doesn't affect branch targeting)
          let app = append-map.at(e.anchor, default: none)
          if app != none {
            let app-content = _format-inline(app)
            let app-body = sub[#text(size: sz * 0.75, fill: col, app-content)]
            // Estimate label half-width to position append at the right edge
            let label-hw = _label-half-w(e.label)
            // Position to the right of the label, anchored at west (left edge of append)
            content((e.x + label-hw, e.y), app-body, anchor: "north-west")
          }
          // Draw annotation between node label and branches
          let annotation-content = annotation-map.at(e.anchor, default: none)
          if annotation-content != none and not e.at("is-terminal", default: false) {
            let annotation-y-off = _loff + 0.10
            let annotation-body = {
              set text(size: fsz * annotation-size, fill: col)
              set par(leading: annotation-leading-val)
              set align(center)
              annotation-content
            }
            let annotation-anchor = if direction == "up" { "south" } else if direction == "right" { "west" } else if (
              direction == "left"
            ) { "east" } else { "north" }
            content(
              (e.x + gdx * annotation-y-off, e.y + gdy * annotation-y-off),
              annotation-body,
              anchor: annotation-anchor,
            )
          }
        }

        // ── Draw arrows (only for vertical trees) ────────────────────────
        if not is-horiz {
          let head-back = 0.12
          // Compute extremal position along growth axis for rectangular arrow clearance
          // For "down": lowest y; for "up": highest y; for "right": rightmost x; for "left": leftmost x
          let y-floor = {
            let vals = nodes.map(e => {
              let v = if direction == "right" or direction == "left" { e.x } else { e.y }
              if e.at("is-triangle", default: false) {
                let tv = if direction == "right" or direction == "left" { e.at("tri-x", default: e.x) } else {
                  e.at("tri-y")
                }
                if direction == "up" or direction == "left" { calc.max(v, tv) } else { calc.min(v, tv) }
              } else {
                v
              }
            })
            if direction == "up" or direction == "left" {
              vals.fold(0.0, (a, b) => calc.max(a, b))
            } else {
              vals.fold(0.0, (a, b) => calc.min(a, b))
            }
          }

          let rect-count = 0 // counter for staggering rectangular arrows
          for arrow in arrows {
            let is-dict = type(arrow) == dictionary
            let raw-from = if is-dict { arrow.at("from") } else { arrow.at(0) }
            let raw-to = if is-dict { arrow.at("to") } else { arrow.at(1) }
            let paint = if is-dict { arrow.at("color", default: _norm) } else if arrow.len() >= 3 {
              arrow.at(2)
            } else { _norm }
            let bend-val = if is-dict { arrow.at("bend", default: none) } else { none }
            let shift-val = if is-dict { arrow.at("shift", default: 0.0) } else { 0.0 }
            let dash-style = if is-dict { arrow.at("dash", default: "dashed") } else { "dashed" }
            let arrow-lw = if is-dict { arrow.at("line-width", default: 1.0) } else { 1.0 }

            // Check if this arrow should be delinked (match raw from or to name)
            let is-delinked = delinks.any(d => d == raw-from or d == raw-to)

            // Parse degree suffix: "np1-300" → (base: "np1", degree: 300)
            // Checks full name in name-to-pos first to avoid conflicts with
            // anchors that naturally end in dash-digits (e.g. "n-31" from label "N 3").
            let _parse-deg(name) = {
              if name in name-to-pos { return (name, none) }
              let m = name.match(regex("^(.+)-(\d{1,3})$"))
              if m != none {
                let base = m.captures.at(0)
                let deg = int(m.captures.at(1))
                if base in name-to-pos { return (base, deg) }
              }
              (name, none)
            }
            let (from-base, from-deg) = _parse-deg(raw-from)
            let (to-base, to-deg) = _parse-deg(raw-to)

            // Resolve arrow names:
            // - "vp3" or "vp3-down" → leaf content below node (default)
            // - "vp3-top" → node label itself (arrow exits from side)
            let _resolve(name) = {
              if name.ends-with("-top") or name.ends-with("-down") {
                name
              } else {
                let base = name
                if base + "-down" in name-to-pos { base + "-down" } else { base }
              }
            }
            // Check for -top suffix (node label as endpoint)
            let from-is-top = from-base.ends-with("-top")
            let to-is-top = to-base.ends-with("-top")
            let from-name = _resolve(from-base)
            let to-name = _resolve(to-base)
            // For -top: strip suffix and use the node position directly
            if from-is-top {
              from-name = from-base.slice(0, from-base.len() - 4)
            }
            if to-is-top {
              to-name = to-base.slice(0, to-base.len() - 4)
            }

            if from-name in name-to-pos and to-name in name-to-pos {
              let (fx, fy, f-loff) = name-to-pos.at(from-name)
              let (tx, ty, t-loff) = name-to-pos.at(to-name)

              // Offset: -top endpoints exit from the side of the label,
              // regular endpoints offset in growth direction (below text)
              // Extra padding on "from" offset: the arrowhead mark at the "to"
              // end visually shortens the line, creating implicit clearance there.
              // The "from" end has no mark, so we add equivalent padding (~0.15).
              let f-off = arrow-off-map.at(from-name, default: 0.45) + 0.15
              let t-off = arrow-off-map.at(to-name, default: 0.45)
              // For degree: exit at specified angle on invisible ellipse around node
              // Horizontal semi-axis = label half-width + gap (clears text edge)
              // Vertical semi-axis = arrow offset (already includes gap)
              // For -top: exit horizontally from label side
              // Default: offset in growth direction (below text)
              let _deg-h-pad = 0.25 // horizontal padding beyond text edge
              if from-deg != none {
                let rad = from-deg * calc.pi / 180
                let hw = label-hw-map.at(from-name, default: 0.35) + _deg-h-pad
                fx = fx + hw * calc.cos(rad)
                fy = fy + f-off * calc.sin(rad)
              } else if from-is-top {
                let side = if tx < fx { -1 } else { 1 } // left or right based on target
                let hw = _label-half-w(nodes.filter(e => e.anchor == from-name).at(0, default: (label: "XX")).label)
                fx = fx + side * hw
              } else {
                // Offset in growth direction (same as "to" endpoint)
                fx = fx + gdx * f-off
                fy = fy + gdy * f-off
              }
              if to-deg != none {
                let rad = to-deg * calc.pi / 180
                let hw = label-hw-map.at(to-name, default: 0.35) + _deg-h-pad
                tx = tx + hw * calc.cos(rad)
                ty = ty + t-off * calc.sin(rad)
              } else if to-is-top {
                let side = if fx < tx { -1 } else { 1 }
                let hw = _label-half-w(nodes.filter(e => e.anchor == to-name).at(0, default: (label: "XX")).label)
                tx = tx + side * hw
              } else {
                tx = tx + gdx * t-off
                ty = ty + gdy * t-off
              }
              let dx = tx - fx
              let dy = ty - fy
              let len = calc.sqrt(dx * dx + dy * dy)
              if len == 0 { continue }

              let a-sw = arrow-sw * arrow-lw
              let shaft-stroke = if dash-style == "solid" {
                (paint: paint, thickness: a-sw)
              } else {
                (paint: paint, thickness: a-sw, dash: dash-style)
              }
              let head-stroke = (paint: paint, thickness: a-sw)
              let mark-style = (end: ">", fill: paint, scale: arrow-mark-scale)

              // bend or shift present → force curved for this arrow
              let is-curved = curved or bend-val != none or shift-val != 0.0
              if is-curved {
                // Quadratic Bézier (parabolic arc)
                // Auto-calculate bend if not specified: proportional to distance
                let bend = if bend-val != none { bend-val } else {
                  calc.max(calc.abs(dx) * 0.3, calc.abs(dy) * 0.3, 0.6)
                }
                // Control point: centered perpendicular to growth, offset in growth direction
                let cp = if direction == "right" or direction == "left" {
                  let mid-y = (fy + ty) / 2 + shift-val
                  let ext = if direction == "right" {
                    calc.max(fx, tx) + bend
                  } else {
                    calc.min(fx, tx) - bend
                  }
                  (ext, mid-y)
                } else {
                  let mid-x = (fx + tx) / 2 + shift-val
                  let ext = if direction == "up" {
                    calc.max(fy, ty) + bend
                  } else {
                    calc.min(fy, ty) - bend
                  }
                  (mid-x, ext)
                }
                // Convert quadratic to cubic: C1 = P0 + 2/3*(cp - P0), C2 = P2 + 2/3*(cp - P2)
                let c1 = (fx + 2.0 / 3.0 * (cp.at(0) - fx), fy + 2.0 / 3.0 * (cp.at(1) - fy))
                let c2 = (tx + 2.0 / 3.0 * (cp.at(0) - tx), ty + 2.0 / 3.0 * (cp.at(1) - ty))
                // Tangent at endpoint (cubic: B'(1) = 3(P3 - C2))
                let tang-x = tx - c2.at(0)
                let tang-y = ty - c2.at(1)
                let ed = calc.sqrt(tang-x * tang-x + tang-y * tang-y)
                let (tang-x, tang-y) = if ed > 0 { (tang-x / ed, tang-y / ed) } else { (dx / len, dy / len) }
                let hb = calc.min(head-back, len * 0.4)
                let hax = tx - tang-x * hb
                let hay = ty - tang-y * hb
                bezier((fx, fy), (hax, hay), c1, c2, stroke: shaft-stroke)
                let tiny = 0.01
                line((hax - tang-x * tiny, hay - tang-y * tiny), (tx, ty), stroke: head-stroke, mark: mark-style)
                if is-delinked {
                  // Cubic midpoint at t=0.5, using actual drawn endpoint (hax, hay)
                  let mx = 0.125 * fx + 3 * 0.125 * c1.at(0) + 3 * 0.125 * c2.at(0) + 0.125 * hax
                  let my = 0.125 * fy + 3 * 0.125 * c1.at(1) + 3 * 0.125 * c2.at(1) + 0.125 * hay
                  // Cubic tangent at t=0.5
                  let dtx = 3 * (0.25 * (c1.at(0) - fx) + 0.5 * (c2.at(0) - c1.at(0)) + 0.25 * (hax - c2.at(0)))
                  let dty = 3 * (0.25 * (c1.at(1) - fy) + 0.5 * (c2.at(1) - c1.at(1)) + 0.25 * (hay - c2.at(1)))
                  _draw-delink(mx, my, dtx, dty, (paint: paint, thickness: sw))
                }
              } else {
                // Rectangular (right-angle) path along growth axis
                // Base floor: same for all arrows (endpoints drop to here)
                let base-clearance = 1.0
                let stagger = rect-count * 0.5
                rect-count = rect-count + 1
                let sign = if direction == "up" or direction == "left" { 1 } else { -1 }
                let base-floor = y-floor + sign * base-clearance
                let bar-val = base-floor + sign * stagger
                let hb = head-back
                if direction == "right" or direction == "left" {
                  // Horizontal growth: vertical bar
                  line((fx, fy), (bar-val, fy), stroke: shaft-stroke)
                  line((bar-val, fy), (bar-val, ty), stroke: shaft-stroke)
                  line((bar-val, ty), (tx + gdx * hb, ty), stroke: shaft-stroke)
                  let tiny = 0.01
                  line((tx + gdx * (hb + tiny), ty), (tx, ty), stroke: head-stroke, mark: mark-style)
                  if is-delinked {
                    let mid-y = (fy + ty) / 2
                    _draw-delink(bar-val, mid-y, 0.0, 1.0, (paint: paint, thickness: sw))
                  }
                } else {
                  // Vertical growth: horizontal bar
                  line((fx, fy), (fx, bar-val), stroke: shaft-stroke)
                  line((fx, bar-val), (tx, bar-val), stroke: shaft-stroke)
                  line((tx, bar-val), (tx, ty + gdy * hb), stroke: shaft-stroke)
                  let tiny = 0.01
                  line((tx, ty + gdy * (hb + tiny)), (tx, ty), stroke: head-stroke, mark: mark-style)
                  if is-delinked {
                    let mid-x = (fx + tx) / 2
                    _draw-delink(mid-x, bar-val, 1.0, 0.0, (paint: paint, thickness: sw))
                  }
                }
              }
            }
          }
        } // end if not is-horiz (arrows)

        // ── Draw dominance lines ──────────────────────────────────────
        // Normalize: single entry → array of entries
        let dom-entries = if dominance == () {
          ()
        } else if type(dominance.at(0, default: none)) != array and type(dominance.at(0, default: none)) != dictionary {
          // Single entry like ("np4", "np1") — wrap it
          if type(dominance) == dictionary { (dominance,) } else { (dominance,) }
        } else {
          dominance
        }
        for entry in dom-entries {
          let is-dict = type(entry) == dictionary
          let raw-from = if is-dict { entry.at("from") } else { entry.at(0) }
          let raw-to = if is-dict { entry.at("to") } else { entry.at(1) }
          let ctrl-val = if is-dict { entry.at("ctrl", default: none) } else { none }
          let dom-color = if is-dict { entry.at("color", default: _norm) } else { _norm }
          let dom-dash = if is-dict { entry.at("dash", default: "solid") } else { "solid" }

          if raw-from in name-to-pos and raw-to in name-to-pos {
            let (fx, fy, _) = name-to-pos.at(raw-from)
            let (tx, ty, _) = name-to-pos.at(raw-to)

            // Depart south (node-out), arrive north (node-in) — matching branches
            let f-out = node-out.at(raw-from, default: _loff)
            let t-in = node-in.at(raw-to, default: _loff)
            fx = fx + gdx * f-out
            fy = fy + gdy * f-out
            tx = tx - gdx * t-in
            ty = ty - gdy * t-in

            let dx = tx - fx
            let dy = ty - fy
            let len = calc.sqrt(dx * dx + dy * dy)
            if len == 0 { continue }

            let dom-stroke = (paint: dom-color, thickness: sw, dash: dom-dash)

            // Default S-curve: depart in growth direction, arrive against it
            // ctrl adjusts (adds to) these defaults
            let v-reach = calc.abs(dy)
            let h-reach = calc.abs(dx)
            let lift1 = calc.max(v-reach * 0.50, h-reach * 0.20, 0.50)
            let dip2 = -calc.max(v-reach * 0.25, 0.40)
            // Apply growth direction sign
            let (default-c1y, default-c2y) = if direction == "up" {
              (-lift1, -dip2)
            } else {
              (lift1, dip2)
            }
            let adj0 = if ctrl-val != none { ctrl-val.at(0) } else { 0 }
            let adj1 = if ctrl-val != none { ctrl-val.at(1) } else { 0 }
            let ctrl1 = (fx + dx * 0.30, fy + default-c1y + adj0)
            let ctrl2 = (tx - dx * 0.30, ty + default-c2y + adj1)
            bezier((fx, fy), (tx, ty), ctrl1, ctrl2, stroke: dom-stroke)
          }
        }
      })
    })
  }

  if font != none {
    set text(font: font)
    _body
  } else {
    _body
  }
}

// ── Multi-tree group ──────────────────────────────────────────────────────────
// Renders multiple syntax trees in a single canvas with cross-tree
// equivalence lines.  Follows the geom-group() pattern from phonokit.
//
// Each positional argument is a spec dict with the same keys as tree():
//   (input: "[S [NP ...] [VP ...]]", direction: "down", spread: 1.0, ...)
//
// Node anchors are suffixed with tree index: "np1-1" = first NP in tree 1.
// The "-down" variant goes before the index: "np1-down-1".
//
// Equivalence entries: ("np1-1", "np1-2") or (from: "np1-1", to: "np1-2", ...)

#let garden(
  ..trees,
  equivalence: (),
  gap: 2.0,
  scale: 1.0,
  line-width: 1.0,
  font: none,
) = {
  let specs = trees.pos()
  let scale-factor = scale

  let _body = context {
    let fsz = 12 * scale-factor * 1pt
    let _norm = luma(15%)

    // ── Per-tree computation ──────────────────────────────────────────────
    let all-td = () // array of tree-data dicts

    for (idx, spec) in specs.enumerate() {
      let tidx = idx + 1
      let input = spec.at("input")
      let direction = spec.at("direction", default: "down")
      let spread-val = spec.at("spread", default: 1.0)
      let drop-val = spec.at("drop", default: 1.0)
      let content-size = spec.at("content-size", default: 0.8)
      let node-size = spec.at("node-size", default: 1.0)
      let triangle-arg = spec.at("triangle", default: ())
      let terminal-branch = spec.at("terminal-branch", default: false)
      let bottom = spec.at("bottom", default: true)

      let is-horiz = direction == "right" or direction == "left"
      let leaf-w = spread-val
      let v-gap = if is-horiz { 1.2 * drop-val * 1.05 } else { 1.2 * drop-val }

      // Parse
      let tokens = _tokenize(input)
      let (tree, _, _) = _parse(tokens, 0, (:))

      // Auto-triangle
      let tri-set = triangle-arg
      let _auto-tri(node) = {
        let result = ()
        if not node.is-leaf and node.children.len() > 0 {
          let stripped = _strip-fmt(node.label)
          let is-phrase = stripped.len() > 1 and lower(stripped).ends-with("p")
          let all-leaves = node.children.all(c => c.is-leaf)
          if is-phrase and all-leaves { result.push(node.anchor) }
          for child in node.children { result = result + _auto-tri(child) }
        }
        result
      }
      let tri-set = tri-set + _auto-tri(tree)

      // Layout
      let nodes = _syntax-layout(
        tree,
        0.0,
        0.0,
        none,
        none,
        leaf-w,
        v-gap,
        tri-set,
        is-horiz: is-horiz,
        append-map: (:),
        content-size: content-size,
        level: 0,
        drop-map: (:),
        node-spacing-map: (:),
        sister-spacing-map: (:),
        sister-node-map: (:),
        annotation-map: (:),
        annotation-leaf-widths: (:),
      )

      // Bottom-align
      if bottom {
        terminal-branch = true
        let min-y = nodes.fold(0.0, (acc, e) => if e.is-leaf { calc.min(acc, e.y) } else { acc })
        let min-y = nodes.fold(min-y, (acc, e) => {
          if e.at("is-triangle", default: false) { calc.min(acc, e.at("tri-y")) } else { acc }
        })
        nodes = nodes.map(e => {
          if e.is-leaf { (..e, y: min-y) } else if e.at("is-triangle", default: false) {
            (..e, tri-y: min-y, bottom-aligned: true)
          } else { e }
        })
      }

      // Terminal pull (reduce gap when no branch line drawn)
      if not terminal-branch {
        nodes = nodes.map(e => {
          if e.at("is-terminal", default: false) and e.par != none {
            let pull = if is-horiz { 0.2 } else { 0.5 }
            (..e, y: e.y + (e.par.at(1) - e.y) * pull)
          } else { e }
        })
      }

      // Direction transform
      let _tx(x, y) = {
        if direction == "up" { (x, -y) } else if direction == "right" { (-y, -x) } else if direction == "left" {
          (y, -x)
        } else { (x, y) }
      }
      let (gdx, gdy) = if direction == "up" { (0, 1) } else if direction == "right" { (1, 0) } else if (
        direction == "left"
      ) { (-1, 0) } else { (0, -1) }

      // Node out/in offsets for branch connections
      let node-out = (:)
      let node-in = (:)
      for e in nodes {
        if is-horiz {
          let full-w = _label-half-w(e.label) * 2
          let is-tri = e.at("is-triangle", default: false)
          node-out.insert(e.anchor, if is-tri { full-w + 0.25 } else { full-w })
          node-in.insert(e.anchor, 0.05)
        } else {
          node-out.insert(e.anchor, _loff)
          node-in.insert(e.anchor, _loff)
        }
      }

      // Transform coordinates
      nodes = nodes.map(e => {
        let (nx, ny) = _tx(e.x, e.y)
        let new-par = if e.par != none {
          let (px, py) = _tx(e.par.at(0), e.par.at(1))
          (px, py)
        } else { none }
        let result = (..e, x: nx, y: ny, par: new-par)
        if e.at("is-triangle", default: false) {
          let (tri-nx, tri-ny) = _tx(e.x, e.at("tri-y"))
          (..result, tri-y: tri-ny, tri-x: tri-nx)
        } else { result }
      })

      // Build name-to-pos, arrow-off-map, label-hw-map with tree-index suffix
      let _text-half-h = 0.2
      let _arrow-gap = 0.25
      let regular-off = _text-half-h + _arrow-gap
      let ntp = (:)
      let aom = (:)
      let lhw = (:)
      let sfx = "-" + str(tidx)
      for e in nodes {
        ntp.insert(e.anchor + sfx, (e.x, e.y, _loff))
        aom.insert(e.anchor + sfx, regular-off)
        lhw.insert(e.anchor + sfx, _rendered-len(e.label) * 0.28 / 2 + 0.05)
      }

      // Build -down entries (leaf content positions)
      let _build-down-g(node, ntp, aom, lhw) = {
        if node.is-leaf or node.children.len() == 0 {
          ntp.insert(node.anchor + "-down" + sfx, ntp.at(node.anchor + sfx))
          aom.insert(node.anchor + "-down" + sfx, regular-off)
          lhw.insert(node.anchor + "-down" + sfx, _rendered-len(node.label) * 0.28 / 2 + 0.05)
          return (ntp, aom, lhw)
        }
        let tri-entry = nodes.filter(e => e.anchor == node.anchor and e.at("is-triangle", default: false))
        if tri-entry.len() > 0 {
          let te = tri-entry.at(0)
          ntp.insert(node.anchor + "-down" + sfx, (te.x, te.at("tri-y"), _loff))
          let tri-off = 0.05 + _text-half-h * 2 + _arrow-gap
          aom.insert(node.anchor + "-down" + sfx, tri-off)
          let tri-label = te.at("tri-label")
          let tri-lines = tri-label.split(" \\n ")
          let tri-lines = if tri-lines.len() == 1 { tri-label.split("\\n") } else { tri-lines }
          let widest = tri-lines.fold(0, (acc, l) => calc.max(acc, _rendered-len(l.trim())))
          let char-w = 0.22 * content-size
          lhw.insert(node.anchor + "-down" + sfx, calc.max(widest * char-w / 2, 0.3))
          return (ntp, aom, lhw)
        }
        let leaf-anchors = _collect-leaf-anchors(node)
        let found = leaf-anchors.map(a => a + sfx).filter(a => a in ntp)
        if found.len() > 0 {
          let avg-x = found.map(a => ntp.at(a).at(0)).fold(0.0, (a, b) => a + b) / found.len()
          let ys = found.map(a => ntp.at(a).at(1))
          let leaf-y = if gdy < 0 { calc.min(..ys) } else { calc.max(..ys) }
          ntp.insert(node.anchor + "-down" + sfx, (avg-x, leaf-y, _loff))
          aom.insert(node.anchor + "-down" + sfx, regular-off)
          let xs = found.map(a => ntp.at(a).at(0))
          let span-hw = if xs.len() > 1 {
            (calc.max(..xs) - calc.min(..xs)) / 2 + 0.3
          } else {
            (
              _rendered-len(
                nodes.filter(e => e.anchor + sfx == found.at(0)).at(0, default: (label: "XX")).label,
              )
                * 0.28
                / 2
                + 0.05
            )
          }
          lhw.insert(node.anchor + "-down" + sfx, span-hw)
        }
        for child in node.children {
          (ntp, aom, lhw) = _build-down-g(child, ntp, aom, lhw)
        }
        (ntp, aom, lhw)
      }
      (ntp, aom, lhw) = _build-down-g(tree, ntp, aom, lhw)

      // Compute tree vertical extents
      let y-min = nodes.fold(0.0, (acc, e) => {
        let y = e.y
        if e.at("is-triangle", default: false) { calc.min(acc, y, e.at("tri-y")) } else { calc.min(acc, y) }
      })
      let y-max = nodes.fold(0.0, (acc, e) => {
        let y = e.y
        if e.at("is-triangle", default: false) { calc.max(acc, y, e.at("tri-y")) } else { calc.max(acc, y) }
      })

      all-td.push((
        nodes: nodes,
        ntp: ntp,
        aom: aom,
        lhw: lhw,
        tidx: tidx,
        sfx: sfx,
        direction: direction,
        gdx: gdx,
        gdy: gdy,
        is-horiz: is-horiz,
        node-out: node-out,
        node-in: node-in,
        tri-set: tri-set,
        content-size: content-size,
        node-size: node-size,
        terminal-branch: terminal-branch,
        y-min: y-min,
        y-max: y-max,
      ))
    }

    // ── Stack trees vertically ────────────────────────────────────────────
    let y-offsets = ()
    for (i, td) in all-td.enumerate() {
      if i == 0 {
        y-offsets.push(0.0)
      } else {
        let prev = all-td.at(i - 1)
        let prev-bottom = prev.y-min + y-offsets.at(i - 1)
        y-offsets.push(prev-bottom - gap - td.y-max)
      }
    }

    // Apply y-offsets to nodes and merge name-to-pos
    let shared-ntp = (:)
    let shared-aom = (:)
    let shared-lhw = (:)
    for (i, td) in all-td.enumerate() {
      let y-off = y-offsets.at(i)
      all-td.at(i).nodes = td.nodes.map(e => {
        let new-par = if e.par != none { (e.par.at(0), e.par.at(1) + y-off) } else { none }
        let result = (..e, y: e.y + y-off, par: new-par)
        if e.at("is-triangle", default: false) {
          (..result, tri-y: e.at("tri-y") + y-off)
        } else { result }
      })
      for (key, val) in td.ntp.pairs() {
        shared-ntp.insert(key, (val.at(0), val.at(1) + y-off, val.at(2)))
      }
      for (key, val) in td.aom.pairs() { shared-aom.insert(key, val) }
      for (key, val) in td.lhw.pairs() { shared-lhw.insert(key, val) }
    }

    // ── Render ────────────────────────────────────────────────────────────
    let sw = 0.05em * scale-factor * line-width

    box(inset: 1.2em, baseline: 40%, {
      cetz.canvas(length: scale-factor * 1cm, {
        import cetz.draw: *

        // Draw each tree
        for td in all-td {
          let nodes = td.nodes
          let gdx = td.gdx
          let gdy = td.gdy
          let direction = td.direction
          let is-horiz = td.is-horiz
          let node-fsz = fsz * td.node-size
          let content-fsz = fsz * td.content-size

          // ── Edges ──
          for e in nodes {
            if e.par != none and (td.terminal-branch or not e.at("is-terminal", default: false)) {
              let par-off = td.node-out.at(e.at("par-anchor", default: ""), default: _loff)
              let child-off = td.node-in.at(e.anchor, default: _loff)
              line(
                (e.par.at(0) + gdx * par-off, e.par.at(1) + gdy * par-off),
                (e.x - gdx * child-off, e.y - gdy * child-off),
                stroke: (paint: _norm, thickness: sw),
              )
            }
          }

          // ── Triangles ──
          for e in nodes {
            if e.at("is-triangle", default: false) {
              let tri-label = e.at("tri-label")
              let tlx = e.at("tri-x", default: e.x)
              let tly = e.at("tri-y")
              let vert = direction == "down" or direction == "up"
              let half-w = if vert {
                let char-w = 0.22 * td.content-size
                let tl = tri-label.split(" \\n ")
                let tl = if tl.len() == 1 { tri-label.split("\\n") } else { tl }
                calc.max(tl.fold(0, (acc, l) => calc.max(acc, _rendered-len(l.trim()))) * char-w / 2, 0.3)
              } else {
                let tl = tri-label.split(" \\n ")
                let tl = if tl.len() == 1 { tri-label.split("\\n") } else { tl }
                calc.max(tl.len() * 0.55 / 2, 0.4)
              }
              let tri-off = td.node-out.at(e.anchor, default: _loff)
              let apex = (e.x + gdx * tri-off, e.y + gdy * tri-off)
              let (b1, b2) = if vert {
                ((tlx - half-w, tly - gdy * _loff), (tlx + half-w, tly - gdy * _loff))
              } else {
                let bx = _loff
                ((tlx + gdx * bx, tly - half-w), (tlx + gdx * bx, tly + half-w))
              }
              line(apex, b1, stroke: (paint: _norm, thickness: sw))
              line(apex, b2, stroke: (paint: _norm, thickness: sw))
              line(b1, b2, stroke: (paint: _norm, thickness: sw))
            }
          }

          // ── Labels ──
          for e in nodes {
            let display = _display-label(e.label)
            let _has-upper = _strip-fmt(e.label).match(regex("[A-Z]")) != none
            let sz = if e.at("is-terminal", default: false) or (e.is-leaf and not _has-upper) {
              content-fsz
            } else { node-fsz }
            let label-body = text(size: sz, fill: _norm, display)
            let label-anchor = if direction == "right" { "west" } else if direction == "left" { "east" } else {
              "center"
            }

            if e.at("is-triangle", default: false) {
              content((e.x, e.y), label-body, anchor: label-anchor)
              let tri-leaves = e.at("tri-leaves")
              let lines = ((),)
              for leaf in tri-leaves {
                if leaf == "\\n" { lines.push(()) } else { lines.at(-1).push(leaf) }
              }
              let line-contents = lines.map(words => {
                text(size: content-fsz, fill: _norm, words.map(w => _display-label(w)).join([ ]))
              })
              let tri-align = if direction == "right" { left } else if direction == "left" { right } else { center }
              let tri-body = if line-contents.len() > 1 {
                align(tri-align, stack(spacing: 0.35em, ..line-contents))
              } else { line-contents.at(0) }
              let is-bottom-aligned = e.at("bottom-aligned", default: false)
              let tri-text-gap = if is-bottom-aligned { 0 } else if is-horiz { 0.80 } else { 0.05 }
              let tlx2 = e.at("tri-x", default: e.x)
              let tly2 = e.at("tri-y")
              let tri-anchor = if is-bottom-aligned { "center" } else if direction == "up" { "south" } else if (
                direction == "down"
              ) { "north" } else if direction == "right" { "west" } else { "east" }
              content((tlx2 + gdx * tri-text-gap, tly2 + gdy * tri-text-gap), tri-body, anchor: tri-anchor)
            } else {
              let (lx, ly) = (e.x, e.y)
              let cur-anchor = label-anchor
              if is-horiz and e.at("is-terminal", default: false) and e.par != none {
                lx = lx + (e.par.at(0) - lx) * 0.4
                ly = ly + (e.par.at(1) - ly) * 0.4
              } else if not is-horiz and e.at("is-terminal", default: false) {
                cur-anchor = if direction == "up" { "south" } else { "north" }
              }
              content((lx, ly), label-body, anchor: cur-anchor)
            }
          }
        }

        // ── Equivalence lines ──────────────────────────────────────────────
        let eq-entries = if equivalence.len() > 0 and type(equivalence.at(0)) == str {
          (equivalence,)
        } else { equivalence }

        for eq in eq-entries {
          let is-dict = type(eq) == dictionary
          let raw-from = if is-dict { eq.at("from") } else { eq.at(0) }
          let raw-to = if is-dict { eq.at("to") } else { eq.at(1) }
          let eq-color = if is-dict { eq.at("color", default: _norm) } else { _norm }
          let eq-dash = if is-dict { eq.at("dash", default: "dashed") } else { "dashed" }
          let eq-lw = if is-dict { eq.at("line-width", default: 1.0) } else { 1.0 }

          // Resolve: bare "np1-1" → "np1-down-1" if available (default to leaf text).
          // "np1-1-top" → "np1-1" (node label position, stripping -top).
          let _resolve-eq(name) = {
            // -top: strip suffix, target node label
            if name.ends-with("-top") {
              return name.slice(0, name.len() - 4)
            }
            // Already has -down: use as-is
            if name.contains("-down") { return name }
            // Try resolving to -down (leaf content)
            let m = name.match(regex("^(.+)-(\d+)$"))
            if m != none {
              let base = m.captures.at(0)
              let tidx-str = m.captures.at(1)
              let down-key = base + "-down-" + tidx-str
              if down-key in shared-ntp { return down-key }
            }
            name
          }
          let from-name = _resolve-eq(raw-from)
          let to-name = _resolve-eq(raw-to)

          if from-name in shared-ntp and to-name in shared-ntp {
            let (fx, fy, _) = shared-ntp.at(from-name)
            let (tx, ty, _) = shared-ntp.at(to-name)

            // Offset endpoints in their respective tree's growth direction
            let _get-tidx(name) = {
              let m = name.match(regex("-(\d+)$"))
              if m != none { int(m.captures.at(0)) } else { 1 }
            }
            let from-td = all-td.at(_get-tidx(from-name) - 1)
            let to-td = all-td.at(_get-tidx(to-name) - 1)
            // Uniform offset for equivalence lines so endpoints align vertically
            let eq-off = 0.45
            let f-off = eq-off
            let t-off = eq-off
            fx = fx + from-td.gdx * f-off
            fy = fy + from-td.gdy * f-off
            tx = tx + to-td.gdx * t-off
            ty = ty + to-td.gdy * t-off

            let a-sw = 0.018 * eq-lw
            let eq-stroke = if eq-dash == "solid" {
              (paint: eq-color, thickness: a-sw)
            } else {
              (paint: eq-color, thickness: a-sw, dash: eq-dash)
            }
            line((fx, fy), (tx, ty), stroke: eq-stroke)
          }
        }
      })
    })
  }

  if font != none {
    set text(font: font)
    _body
  } else {
    _body
  }
}
