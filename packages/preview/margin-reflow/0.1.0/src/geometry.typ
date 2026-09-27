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

#let _page-dimensions() = {
  (
    width: if page.width == auto { 10000pt } else { page.width },
    height: if page.height == auto { 10000pt } else { page.height },
  )
}

// Resolve a page-margin specification (`auto`, a length, or a dictionary with
// `x`/`y`/`rest`/`top`/`bottom`/`left`/`right`/`inside`/`outside`) into absolute
// top/bottom/left/right lengths for the given page number. This mirrors Typst's
// margin resolution (including inside/outside parity) so that an explicit target
// margin can be measured the same way as the ambient `page.margin`.
#let _resolve-margins(m, dims, page-no) = {
  let auto-margin = (2.5 / 21) * calc.min(dims.width, dims.height)
  let side(value, base) = if value == auto { auto-margin } else { _resolve-rel(value, base) }
  let (top, bottom, left, right) = if m == auto {
    (auto-margin, auto-margin, auto-margin, auto-margin)
  } else if type(m) == dictionary {
    let rest = m.at("rest", default: auto-margin)
    let x = m.at("x", default: rest)
    let y = m.at("y", default: rest)
    let top = m.at("top", default: y)
    let bottom = m.at("bottom", default: y)
    if "left" in m or "right" in m {
      (top, bottom, m.at("left", default: x), m.at("right", default: x))
    } else {
      let inside = m.at("inside", default: x)
      let outside = m.at("outside", default: x)
      let bind-left = page.binding == auto or page.binding == left
      if bind-left == calc.odd(page-no) {
        (top, bottom, inside, outside)
      } else {
        (top, bottom, outside, inside)
      }
    }
  } else {
    (m, m, m, m)
  }
  (
    top: side(top, dims.height),
    bottom: side(bottom, dims.height),
    left: side(left, dims.width),
    right: side(right, dims.width),
  )
}

#let _page-margins(dims) = _resolve-margins(page.margin, dims, here().page())

// Rebuild a `columns` element, taking `count` out of the forwarded fields.
#let _rebuild-columns(fields, body) = {
  let count = if "count" in fields { fields.remove("count") } else { 2 }
  columns(count, body, ..fields)
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

#let _no-indent(cont) = {
  set par(first-line-indent: 0em)
  cont
}

#let _columns-width(fields, width) = {
  let count = fields.at("count", default: 2)
  let gutter = _resolve-rel(fields.at("gutter", default: 4%), width)
  (width - (count - 1) * gutter) / count
}

// Build the content of one column chunk. Because each chunk is placed in its
// own isolated box (a grid cell), paragraphs must get their first-line indent
// explicitly: `columns`/`block`/`grid` do not apply the ambient
// `first-line-indent` to the first paragraph of their content.
#let _chunk-content(units, fli, cont, fill-last: false) = {
  let amt = if type(fli) == dictionary { fli.amount } else { fli }
  let all = type(fli) == dictionary and fli.at("all", default: false)
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
  out
}

// Largest prefix of `units` whose rendered height does not exceed `avail`,
// found by binary search over the measured prefix heights.
#let _cut-chunk(units, width, avail, fli, cont) = {
  let n = units.len()
  if n == 0 { return 0 }
  let h(k) = measure(_chunk-content(units.slice(0, k), fli, cont), width: width).height
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
  let fli = par.first-line-indent
  // Fit one column at a time. Each chunk is placed in its own isolated box, so
  // its measured height matches its rendered height; filling every box to the
  // available height keeps the columns flush at the bottom.
  let counts = ()
  let used = 0
  for i in range(count) {
    if used >= units.len() { break }
    let cont = if i == 0 { false } else { not _ends-block(units.at(used - 1)) }
    let k = _cut-chunk(units.slice(used), colw, avail, fli, cont)
    if k == 0 { k = 1 }
    counts.push(k)
    used += k
  }
  let chunks = ()
  used = 0
  for (i, k) in counts.enumerate() {
    let cont = if i == 0 { false } else { not _ends-block(units.at(used - 1)) }
    let fill = used + k < full-units.len() and not _is-para-break(full-units.at(used + k))
    chunks.push(_chunk-content(units.slice(used, used + k), fli, cont, fill-last: fill))
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
    cells.push(block(
      width: colw,
      height: cellh,
      above: 0pt,
      below: 0pt,
      inset: 0pt,
      outset: 0pt,
      {
        // Disable the ambient first-line indent; `_chunk-content` controls it
        // explicitly per paragraph (otherwise paragraphs would be indented
        // twice, and continuation paragraphs would be indented wrongly).
        set par(first-line-indent: 0em)
        c
      },
    ))
  }
  let cols = ()
  for i in range(count) { cols.push(colw) }
  let body = grid(columns: cols, column-gutter: gutter, row-gutter: 0pt, ..cells)
  let body = block(above: 0pt, below: 0pt, inset: 0pt, outset: 0pt, body)
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
      {
        body
        area
      }
    },
  )
}
