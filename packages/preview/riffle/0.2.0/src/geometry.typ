// Page geometry and the low-level page fitting algorithm.
//
// The flow functions measure the page, decide how much content fits into the
// available height and emit isolated boxes that match the measured height.
// These helpers are shared by all flow functions and are not part of the public
// API.

#import "content.typ": _join

// Resolve a relative length (ratio + length) against a base length.
#let _resolve-rel(value, base) = {
  let value = 0% + 0pt + value
  value.ratio * base + value.length.to-absolute()
}

#let _get-padding(pad-required, pn) = {
  let (padl, padr) = if "inside" in pad-required {
    if calc.odd(pn) { (pad-required.inside, pad-required.outside) } else {
      (pad-required.outside, pad-required.inside)
    }
  } else {
    (0pt, 0pt)
  }
  pad.with(left: -padl - pad-required.left, right: -padr - pad-required.right, rest: 0pt)
}

#let _calc-content-dims(margin) = {
  let page-margin = if type(page.margin) == dictionary { page.margin } else { (x: page.margin, y: page.margin) }
  let dims = (width: page.width, height: page.height)
  let current-x = if "inside" in page-margin {
    (inside: page-margin.inside, outside: page-margin.outside)
  } else if "left" in page-margin {
    (left: page-margin.left, right: page-margin.right)
  } else {
    (left: page-margin.x, right: page-margin.x)
  }
  let auto-margin = (2.5 / 21) * calc.min(dims.width, dims.height)
  let current-y = (
    top: if "top" in page-margin { page-margin.top } else if "y" in page-margin { page-margin.y } else { auto-margin },
    bottom: if "bottom" in page-margin { page-margin.bottom } else if "y" in page-margin { page-margin.y } else {
      auto-margin
    },
  )
  let target-margin = if type(margin) == dictionary {
    let horizontal = (:)
    for key in ("left", "right", "inside", "outside", "x") {
      if key in margin { horizontal.insert(key, margin.at(key)) }
    }
    (top: current-y.top, bottom: current-y.bottom) + horizontal
  } else if type(margin) == length {
    (top: current-y.top, bottom: current-y.bottom) + (x: margin)
  } else if margin == "symmetric" {
    (top: current-y.top, bottom: current-y.bottom, x: calc.min(..current-x.values()))
  } else if margin == auto {
    page-margin
  } else {
    panic("margin is of unexptected type")
  }
  if "x" in target-margin {
    target-margin = target-margin + (left: target-margin.x, right: target-margin.x)
    let _ = target-margin.remove("x")
  }
  assert("left" in target-margin or "inside" in target-margin)
  let (target-x, target-x-occupy) = if "left" in target-margin {
    ((left: target-margin.left, right: target-margin.right), target-margin.left + target-margin.right)
  } else {
    ((inside: target-margin.inside, outside: target-margin.outside), target-margin.inside + target-margin.outside)
  }
  let width = dims.width - _resolve-rel(target-x-occupy, dims.width)
  let pad-required = (inside: 0pt, outside: 0pt, left: 0pt, right: 0pt)
  pad-required = pad-required + current-x
  for (k, v) in pad-required {
    if k in target-x {
      let _ = pad-required.insert(k, v - target-x.at(k))
    }
  }
  return (current-y, target-margin, pad-required, width)
}

#let _is-para-break(u) = type(u) == content and u.func() == parbreak

// Whether a unit ends a block, in which case the next chunk is a fresh
// paragraph rather than a continuation.
#let _ends-block(u) = {
  if type(u) != content { return false }
  let f = u.func()
  if repr(f) == "sequence" {
    let ch = u.children
    if ch.len() == 0 { return false }
    return _ends-block(ch.last())
  }
  if f == parbreak { return true }
  if f in (figure, heading, block, list, enum, terms, table, quote, grid, stack, columns) {
    return true
  }
  if repr(f) == "equation" and u.at("block", default: false) { return true }
  false
}

#let _columns-width(fields, width) = {
  let count = fields.at("count", default: 2)
  let gutter = _resolve-rel(fields.at("gutter", default: 4%), width)
  (width - (count - 1) * gutter) / count
}

#let _get-fli() = {
  let fli = par.first-line-indent
  let amt = if type(fli) == dictionary { fli.amount } else { fli }
  let all = type(fli) == dictionary and fli.at("all", default: false)
  return (amt, all)
}

// Build the content of one column chunk. Because each chunk is placed in its
// own isolated box (a grid cell), paragraphs must get their first-line indent
// explicitly: `columns`/`block`/`grid` do not apply the ambient
// `first-line-indent` to the first paragraph of their content.
#let _chunk-content(units, cont, fill-last: false) = {
  let (amt, all) = _get-fli()
  let paras = ()
  let cur = ()
  for u in units {
    if _is-para-break(u) {
      paras.push(cur)
      cur = ()
    } else {
      cur.push(u)
    }
  }
  paras.push(cur)
  while paras.len() > 0 and paras.at(0).len() == 0 { paras = paras.slice(1) }
  while paras.len() > 0 and paras.last().len() == 0 { paras = paras.slice(0, paras.len() - 1) }
  if fill-last and paras.len() > 0 {
    let last = paras.pop()
    last.push(linebreak(justify: true))
    paras.push(last)
  }
  let out = []
  for (j, para) in paras.enumerate() {
    if j > 0 { out += parbreak() }
    let ind = if j == 0 {
      if cont { 0pt } else if all { amt } else { 0pt }
    } else {
      amt
    }
    if ind != 0pt { out += h(ind) }
    out += _join(para)
  }
  // Disable the ambient first-line indent so that the measured height matches
  // the rendered height: the indentation above is added explicitly as `h(ind)`,
  // and `_page-block` also neutralises the ambient indent. Without this, the
  // ambient indent is counted twice during measurement, which overestimates the
  // height and leaves the last column short of the bottom.
  {
    set par(first-line-indent: 0em)
    out
  }
}

// Largest prefix of `units` whose rendered height does not exceed `avail`,
// found by binary search over the measured prefix heights.
#let _cut-chunk(units, width, avail, cont) = {
  let n = units.len()
  if n == 0 { return 0 }
  let h(k) = measure(_chunk-content(units.slice(0, k), cont), width: width).height
  if h(n) <= avail { return n }
  let lo = 0
  let hi = n
  while lo + 1 < hi {
    let mid = calc.div-euclid(lo + hi, 2)
    if h(mid) <= avail { lo = mid } else { hi = mid }
  }
  lo
}

#let _page-split(
  params,
  units,
  width,
  avail,
  max-units: none,
) = {
  let full-units = units
  if max-units != none {
    units = units.slice(0, calc.min(units.len(), max-units))
  }
  let count = params.at("count", default: 2)
  let colw = _columns-width(params, width)
  // Fit one column at a time. Each chunk is placed in its own isolated box, so
  // its measured height matches its rendered height; filling every box to the
  // available height keeps the columns flush at the bottom.
  let counts = ()
  let used = 0
  for i in range(count) {
    if used >= units.len() { break }
    let cont = if i == 0 { false } else { not _ends-block(units.at(used - 1)) }
    let k = _cut-chunk(units.slice(used), colw, avail, cont)
    if k == 0 { k = 1 }
    counts.push(k)
    used += k
  }
  let chunks = ()
  used = 0
  for (i, k) in counts.enumerate() {
    let cont = if i == 0 { false } else { not _ends-block(units.at(used - 1)) }
    let fill = used + k < full-units.len() and not _is-para-break(full-units.at(used + k))
    chunks.push(_chunk-content(units.slice(used, used + k), cont, fill-last: fill))
    used += k
  }
  (chunks: chunks, consumed: used)
}

// Emit the fitted chunks as a fixed-height `grid` block, optionally followed by
// a footnote area.
#let _page-block(params, chunks, width, avail, area: none, reserve: 0pt) = {
  let count = params.at("count", default: 2)
  let colw = _columns-width(params, width)
  let gutter = _resolve-rel(params.at("gutter", default: 4%), width)
  let cellh = if area == none or reserve <= 0pt { avail } else { avail - reserve }
  let cells = ()
  for i in range(count) {
    let c = if i < chunks.len() { chunks.at(i) } else { [] }
    cells.push({
      // Disable the ambient first-line indent; `_chunk-content` controls it explicitly per paragraph (otherwise paragraphs would be indented twice, and continuation paragraphs would be indented wrongly).
      set par(first-line-indent: 0em)
      c
    })
  }
  let cols = ()
  for i in range(count) { cols.push(colw) }
  let body = grid(columns: cols, column-gutter: gutter, row-gutter: 0pt, inset: 0pt, ..cells)
  block(
    width: width,
    breakable: true,
    height: avail,
    above: 0pt,
    below: 0pt,
    spacing: 0pt,
    inset: 0pt,
    outset: 0pt,
    if area == none or reserve <= 0pt { body } else {
      body
      v(1fr, weak: true)
      area
    },
  )
}
