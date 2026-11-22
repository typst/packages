#import "content.typ" as ct
#import "utils.typ" as ut

// -----------------------------------------------------------------------------
// Checks
// -----------------------------------------------------------------------------

// The ends of a highlight on lines skipped by a jump (see `kept-highlights`)
#let open-start(hl) = hl.at("open-start", default: false)
#let open-end(hl) = hl.at("open-end", default: false)

/// Check that the highlight range are correct.
#let check-highlight(hl) = if not hl.is-line {
  let (i_s, j_s) = hl.range.first()
  let (i_e, j_e) = hl.range.last()
  assert(
    i_s < i_e or (i_s == i_e and j_s <= j_e),
    message: "There is a empty highlight.",
  )
}

/// The style settings of a highlight (the keys of the `highlight` settings).
#let style-keys = ("expand", "sticky", "radius", "fill", "stroke", "code-style")

/// Check a pre-highlight (a highlight defined by delimiters): its delimiters (`ldel` and `rdel`, or `del` for both, a delimiter being matched with the first one after it) and its style settings. Return it with `ldel` and `rdel`.
///
/// - h (dictionary):
/// -> dictionary
#let pre-highlight(h) = {
  assert(type(h) == dictionary, message: "A highlight must be a dictionary.")
  h = ut.known-keys(h, style-keys + ("del", "ldel", "rdel"))
  if "del" in h {
    let del = h.remove("del")
    h += (ldel: del, rdel: del)
  }
  assert(
    "ldel" in h and "rdel" in h,
    message: "A highlight has no left or right delimiter.",
  )
  h
}

// -----------------------------------------------------------------------------
// Formatting
// -----------------------------------------------------------------------------

/// Convert the horizontal expansion of a highlight (`none`, `left`, `right` or `center`) to the expanded sides.
#let expand-sides(expand, is-line) = {
  assert(
    expand == none
      or expand == auto
      or (type(expand) == alignment and expand.axis() == "horizontal"),
    message: "The expansion of a highlight must be `none`, `left`, `right` or `center` (for both), use `sticky` to make it occupy the height of the lines and connect it between lines.",
  )

  (
    left: expand in (left, start, center) or (expand == auto and is-line),
    right: expand in (right, end, center) or (expand == auto and is-line),
  )
}

/// Complete a pre-highlight (a highlight defined by delimiters) with the default highlight settings.
///
/// - phl (dictionary): The pre-highlight, with its delimiters and some style fields.
/// - defaults (dictionary): The `highlight` settings, giving the value of the missing style fields.
/// -> dictionary
#let format-pre-highlight(phl, defaults) = {
  let style = ut.filter-add-dict(defaults, phl)
  // A highlight read from delimiters is not on whole lines
  if style.sticky == auto { style.sticky = false }
  (ldel: phl.ldel, rdel: phl.rdel) + style
}

/// Read the starting and end position of an highlight.
#let normalize-position(pos, name) = {
  if type(pos) == int {
    (pos, auto)
  } else if (
    type(pos) == array
      and pos.len() == 2
      and type(pos.first()) == int
      and type(pos.last()) == int
  ) {
    pos
  } else {
    panic(
      "A "
        + name
        + " of a highlight should be an integer or a pair of integers.",
    )
  }
}

#let parse-line(l) = if (
  type(l) == array
    and l.len() == 2
    and type(l.first()) == int
    and type(l.last()) == int
    and l.first() <= l.last()
) {
  l
} else if type(l) == int { (l, l) }

/// Fix the range of the highlight, and complete it with the default highlight settings.
///
/// - hl (dictionary): The highlight, given by `line`, or `start` and `end`, and some style fields (delimiters being ignored, so that a predefined highlight can be spread in it).
/// - defaults (dictionary): The `highlight` settings, giving the value of the missing style fields.
/// -> dictionary
#let format-highlight(hl, defaults) = {
  hl = ut.known-keys(
    hl,
    defaults.keys() + ("line", "start", "end", "ldel", "rdel"),
  )
  let style = ut.filter-add-dict(defaults, hl)

  // A highlight on whole lines: `line: k` or `line: (k1, k2)`
  let is-line = "line" in hl
  let range = if is-line {
    let pl = parse-line(hl.line)
    let (k1, k2) = if pl != none { pl } else {
      panic(
        "The `line` of a highlight should be an integer or a pair of integers.",
      )
    }
    assert(
      k1 <= k2,
      message: "The first line of a highlight must be before the last one.",
    )
    ((k1, 0), (k2, auto))
  } else {
    assert("start" in hl, message: "A highlight has no starting point.")
    assert("end" in hl, message: "A highlight has no ending point.")

    let s = normalize-position(hl.start, "starting point")
    let e = normalize-position(hl.end, "ending point")

    (s, e)
  }

  let expand = expand-sides(style.expand, is-line)
  // By default, only the highlights on whole lines are sticky
  let sticky = if style.sticky == auto { is-line } else { style.sticky }
  (
    range: range,
    expand: expand,
    sticky: sticky,
    is-line: is-line,
    // Highlights on whole lines have square corners
    radius: if is-line {
      (
        ut.full-radius(style.radius)
          + (if expand.left { (top-left: 0mm, bottom-left: 0mm) } else { (:) })
          + (
            if expand.right { (top-right: 0mm, bottom-right: 0mm) } else { (:) }
          )
      )
    } else { ut.full-radius(style.radius) },
    // A highlight that is not sticky has sharp ends where it is broken (hidden setting)
    sharp-break: not sticky,
    fill: style.fill,
    stroke: style.stroke,
    code-style: style.code-style,
  )
}

/// Sort two list of highlights by ending position.
#let merge-right-sort-highlights(hls1, hls2) = {
  let key(h) = (
    h.range.last().first(),
    if h.range.last().last() == auto { calc.inf } else {
      h.range.last().last()
    },
    h.range.first().first(),
    if h.range.first().last() == auto { -1 } else { h.range.first().last() },
  )

  return (hls1 + hls2).sorted(key: key)
}

// -----------------------------------------------------------------------------
// Parsing
// -----------------------------------------------------------------------------

/// Indicate whether a delimiter is forbidden: before the end of the last chosen left delimiter, or over a chosen right delimiter (whose positions are the keys of `taken`).
#let is-forbidden(del, last-end, taken) = (
  del.start < last-end or range(del.start, del.end).any(p => str(p) in taken)
)

#let parse-delimiters(lines, phls) = {
  let bline = lines.join("\n", default: "")

  // Find left delimiters of highlights
  let ldels = phls
    .enumerate()
    .map(((idx, h)) => {
      bline.matches(h.ldel).map(m => (hl-idx: idx, start: m.start, end: m.end))
    })
  let ldels-sort = ldels.flatten().sorted(key: d => (d.start, -d.end))

  // Find right delimiters of highlits
  let rdels = phls
    .enumerate()
    .map(h => {
      bline.matches(h.last().rdel).map(m => (start: m.start, end: m.end))
    })
  let rdels-c = rdels.map(_ => 0)

  // Order left delimiters
  let dels-map = phls.map(_ => ())
  let dels-order = ()
  let il = 0
  let last-end = -1
  let taken = (:)

  while il < ldels-sort.len() {
    let ldel = ldels-sort.at(il)

    // Check that we are not after already chosen left delimiters
    if not is-forbidden(ldel, last-end, taken) {
      let i = ldel.hl-idx
      let ir = rdels-c.at(i)

      // Check that there remain corresponding right delimiters
      if ir < rdels.at(i).len() {
        let rdel = rdels.at(i).at(ir)

        // Check that the left delimiter is before the right one
        if (
          ldel.end <= rdel.start and not is-forbidden(rdel, last-end, taken)
        ) {
          dels-map.at(i).push((left: ldel, right: rdel))
          dels-order.push(i)
          last-end = ldel.end
          for p in range(rdel.start, rdel.end) { taken.insert(str(p), true) }

          il += 1
        }
        rdels-c.at(i) += 1
      } else { il += 1 }
    } else { il += 1 }
  }

  // Instanciate sorted left delimiters
  let ordered-dels = ()
  let dels-c = dels-map.map(_ => 0)
  for d in dels-order {
    ordered-dels.push(dels-map.at(d).at(dels-c.at(d)))
    dels-c.at(d) += 1
  }

  // Improve left delimiters with more information
  let dels-pos = ordered-dels
    .enumerate()
    .map(d => (
      (
        idx: d.first(),
        hl-idx: d.last().left.hl-idx,
        left: true,
        start: d.last().left.start,
        end: d.last().left.end,
      ),
      (
        idx: d.first(),
        left: false,
        start: d.last().right.start,
        end: d.last().right.end,
      ),
    ))
    .flatten()
    .sorted(key: d => d.start)

  // Reconstruct the text without delimiters (its parts being joined once)
  let parts = ()
  let prev = 0
  for d in dels-pos {
    parts.push(bline.slice(prev, d.start))
    prev = d.end
  }
  parts.push(bline.slice(prev))
  let new-bline = parts.join()

  // Reconstruct the lines without delimiters
  let new-lines = new-bline.split("\n")
  let new-lines-len = new-lines.map(l => l.len() + 1)

  // Compute the new positions of delimiters
  let removed = 0
  let pre-dels = ()
  for d in dels-pos {
    let pos = d.start - removed
    removed += d.end - d.start
    pre-dels.push(d + (pos: pos))
  }

  // Compute the final delimited text list (the positions being increasing, their line is found in one pass)
  let dels = range(int(pre-dels.len() / 2)).map(_ => (:))
  let (l, line-start) = (0, 0)
  for d in pre-dels {
    let i = d.idx

    if "hl-idx" in d { dels.at(i).insert("idx", d.hl-idx) }

    while (
      l + 1 < new-lines-len.len() and line-start + new-lines-len.at(l) <= d.pos
    ) {
      line-start += new-lines-len.at(l)
      l += 1
    }
    // The column is counted in characters
    let c = (l, ct.text-len(new-lines.at(l).slice(0, d.pos - line-start)))
    if d.left { dels.at(i).insert("start", c) } else {
      dels.at(i).insert("end", c)
    }
  }

  return (dels, new-lines)
}

/// Create a highlight from a pre-highlight and a delimitation from the raw text.
#let make-highlight(phl, del) = (
  start: del.start,
  end: del.end,
  expand: phl.expand,
  sticky: phl.sticky,
  radius: phl.radius,
  fill: phl.fill,
  stroke: phl.stroke,
  code-style: phl.code-style,
)

/// Read the highlights in some raw text.
#let read-highlights(r, pre-highlights) = {
  let lines = r.lines.map(l => l.text)

  let (dels, lines) = parse-delimiters(lines, pre-highlights)
  let hls = dels.map(del => make-highlight(pre-highlights.at(del.idx), del))

  [
    #raw(lang: r.lang, lines.join("\n", default: "")) <uraw-code>
    #metadata(hls) <uraw-hl>
  ]
}

// -----------------------------------------------------------------------------
// Rendering
// -----------------------------------------------------------------------------

// Wether a highlight continues before (or after) the line `i` of its range, its ends on lines skipped by a jump being open (`open-start`, `open-end`)
#let continues-before(hl, i) = hl.range.first().first() < i or open-start(hl)
#let continues-after(hl, i) = i < hl.range.last().first() or open-end(hl)

/// Determine whether a highlight span on a sub-line.
#let highlight-on-sub-line(i, line-end, sl, hl) = {
  if hl.is-line { return true }

  let valid-start = (
    continues-before(hl, i) or hl.range.first().last() < sl.end
  )
  let valid-end = (
    continues-after(hl, i) or hl.range.last().last() > sl.start
  )
  let is-empty = line-end == 0 and not hl.expand.right
  return valid-start and valid-end and not is-empty
}

/// Return the starting position of a sub-line (in its content).
#let sub-line-start-pos(i, pos-indent, k, sl, hl) = {
  if hl.is-line {
    // (a sub-line shown at the indentation starts after it)
    if not hl.expand.left and sl.offset == 0 { pos-indent.last() } else { 0 }
  } else if continues-before(hl, i) {
    if not hl.expand.left and k == 0 { pos-indent.last() } else { 0 }
  } else if hl.range.first().last() < sl.start {
    0
  } else {
    hl.range.first().last() - sl.start
  }
}

/// Return the ending position of a sub-line.
#let sub-line-end-pos(i, sl, hl, max-width, char-width) = {
  if hl.is-line {
    if not hl.expand.right { sl.end - sl.start } else { max-width / char-width }
  } else if continues-after(hl, i) or hl.range.last().last() > sl.end {
    if hl.expand.right { max-width / char-width } else { sl.end - sl.start }
  } else {
    hl.range.last().last() - sl.start
  }
}

/// The position of a column of a sub-line, from its start: the columns are `char-width` wide, unless their positions were measured (`xs`).
#let column-x(sl, c, char-width) = {
  let xs = sl.at("xs", default: none)
  if xs == none { c * char-width } else if c < xs.len() { xs.at(c) } else {
    xs.last() + (c - xs.len() + 1) * char-width
  }
}

/// The horizontal range of a highlight block on a sub-line (as lengths, from the start of the code): the sub-line is shown at its `offset`, and a highlight expanding on the left from the start of a sub-line reaches the start of the code.
#let block-span(hl, sl, start, end, spaning-start, char-width) = (
  if hl.expand.left and (spaning-start or hl.is-line) and start == 0 {
    0pt
  } else {
    sl.offset * char-width + column-x(sl, start, char-width)
  },
  if type(end) == int {
    sl.offset * char-width + column-x(sl, end, char-width)
  } else { end * char-width },
)

/// Check if a highlight is spanning at the start of the sub-line.
#let is-spaning-start(i, m, hl) = {
  continues-before(hl, i) or 0 < m
}

/// Check if a highlight is spanning at the end of the sub-line.
#let is-spaning-end(i, m, sl-len, hl) = {
  continues-after(hl, i) or m < sl-len - 1
}

/// The blocks of a highlight on a line, as `(k, start, end)` for each sub-line `k`.
#let line-spans(i, l, hl, width, inset, char-width) = {
  l
    .slines
    .enumerate()
    .filter(sl => highlight-on-sub-line(i, l.line-end, sl.last(), hl))
    .map(((k, sl)) => (
      k: k,
      sl: sl,
      start: sub-line-start-pos(i, l.pos-indent, k, sl, hl),
      end: sub-line-end-pos(
        i,
        sl,
        hl,
        width + inset.right.to-absolute(),
        char-width,
      ),
    ))
}

/// The key of the block of a highlight on the sub-line `k` of the line `i`.
#let block-key(i, k) = str(i) + "-" + str(k)

/// The space added on the left of a highlight block: the left inset of the code when the highlight expands on the left (and does not start on this block).
#let block-outset-left(hl, spaning-start, inset) = if (
  (spaning-start or hl.is-line) and hl.expand.left
) { inset.left.to-absolute() } else { 0pt }

/// For each block of a sticky highlight, the horizontal ranges (as lengths, from the start of the code) of the blocks of the same highlight touching it from above and below.
///
/// - hl (dictionary): The highlight.
/// - lines (array): The formatted code lines of the highlight, from its first one (only them, as the arguments of a call are hashed).
/// - width (length): The code width.
/// - inset (dictionary): The code inset.
/// - char-width (length):
/// -> dictionary
#let compute-touches(hl, lines, width, inset, char-width) = {
  if not hl.sticky { return (:) }

  let blocks = ()
  for i in range(hl.range.first().first(), hl.range.last().first() + 1) {
    let l = lines.at(i - hl.range.first().first())
    for (m, b) in line-spans(i, l, hl, width, inset, char-width).enumerate() {
      let (start, end) = block-span(
        hl,
        b.sl,
        b.start,
        b.end,
        is-spaning-start(i, m, hl),
        char-width,
      )
      b.start = start
      b.end = end
      blocks.push((
        i: i,
        k: b.k,
        last: b.k == l.slines.len() - 1,
        start: b.start
          - block-outset-left(hl, is-spaning-start(i, m, hl), inset),
        end: b.end,
      ))
    }
  }

  let touches = (:)
  for b in blocks {
    touches.insert(block-key(b.i, b.k), (top: none, bottom: none))
  }

  for n in range(blocks.len() - 1) {
    let (b1, b2) = (blocks.at(n), blocks.at(n + 1))
    let adjacent = (
      (b1.i == b2.i and b2.k == b1.k + 1)
        or (
          b2.i == b1.i + 1 and b1.last and b2.k == 0
        )
    )

    if adjacent and b1.start < b2.end and b2.start < b1.end {
      touches.at(block-key(b1.i, b1.k)).bottom = (b2.start, b2.end)
      touches.at(block-key(b2.i, b2.k)).top = (b1.start, b1.end)
    }
  }

  touches
}

/// The touches of a block not touching any other block.
#let no-touches = (top: none, bottom: none)

/// The space added above the code of a highlight block, sticky highlights occupy the whole height of the line.
#let block-top-pad(hl, inset) = if hl.sticky { inset.top } else { .24em }

/// The space added below the code of a highlight block, sticky highlights occupy the whole height of the line.
#let block-bottom-pad(hl, inset) = if hl.sticky { inset.bottom } else { .25em }

/// Compute the radius of the highlight block.
#let compute-radius(radius, sharp-start, sharp-end) = (
  radius
    + if sharp-start { (top-left: 0mm, bottom-left: 0mm) } else { (:) }
    + if sharp-end { (top-right: 0mm, bottom-right: 0mm) } else { (:) }
)

/// Construct the highlight block.
#let highlight-block(
  hl,
  spaning-start,
  spaning-end,
  start,
  end,
  inset,
  char-width,
  char-height,
  touches,
) = {
  let (touch-top, touch-bottom) = (touches.top, touches.bottom)

  // The open ends are closed when the highlight sticks to the next part on this side
  let sharp-start = hl.sharp-break and spaning-start
  let sharp-end = hl.sharp-break and spaning-end
  let radius = ut.full-radius(compute-radius(hl.radius, sharp-start, sharp-end))

  // The horizontal range of the block (from the start of the code)
  let outset-left = block-outset-left(hl, spaning-start, inset)
  let (x0, x1) = (start - outset-left, end)

  // Remove the radius of the corners touching other blocks of the highlight
  if touch-top != none {
    let (s, e) = touch-top
    if s <= x0 and x0 < e { radius.top-left = 0mm }
    if s < x1 and x1 <= e { radius.top-right = 0mm }
  }
  if touch-bottom != none {
    let (s, e) = touch-bottom
    if s <= x0 and x0 < e { radius.bottom-left = 0mm }
    if s < x1 and x1 <= e { radius.bottom-right = 0mm }
  }

  // The stroke surrounds the whole highlight: there is none on the touching parts of the top and bottom sides,
  // nor on the broken ends of a highlight with sharp breaks (a highlight that is not sticky)
  let s = hl.stroke
  let broken = hl.sharp-break
  let stroke = if s == none { none } else {
    (
      left: if broken and spaning-start { none } else { s },
      right: if broken and spaning-end { none } else { s },
      top: if touch-top == none { s },
      bottom: if touch-bottom == none { s },
    )
  }

  let height = (
    block-top-pad(hl, inset) + char-height + block-bottom-pad(hl, inset)
  )

  // The stroke lies inside the block (so that the next line does not hide it): it is drawn by blocks tighter vertically on its stroked sides.
  // The width is split where the touched parts of the top and bottom sides start and end, each part being drawn by a whole stroke block clipped to it (to keep the rounded corners)
  let stroke-blocks = if s == none { () } else {
    let t = s.thickness
    let in-touch(touch, x) = (
      touch != none and touch.first() < x and x < touch.last()
    )
    let cuts = (x0, x1)
    for touch in (touch-top, touch-bottom).filter(touch => touch != none) {
      cuts += touch.filter(x => x0 < x and x < x1)
    }
    cuts = cuts.dedup().sorted()

    // The parts with the same free (stroked) sides being merged
    let parts = ()
    for (u, v) in cuts.windows(2).filter(((u, v)) => v - u > .01pt) {
      let free = (
        top: not in-touch(touch-top, (u + v) / 2),
        bottom: not in-touch(touch-bottom, (u + v) / 2),
      )
      if parts.len() > 0 and parts.last().free == free {
        parts.last().v = v
      } else { parts.push((u: u, v: v, free: free)) }
    }

    parts.map(p => {
      // The outer sides are not clipped, the inner ones go over the next part to join the side stroke of the touching block
      let u = if p.u == x0 { x0 - t } else { p.u - t / 2 }
      let v = if p.v == x1 { x1 + t } else { p.v + t / 2 }
      let dt = if p.free.top { t / 2 } else { 0pt }
      let db = if p.free.bottom { t / 2 } else { 0pt }
      place(top + left, dx: u - x0 - outset-left, dy: -t, box(
        width: v - u,
        height: height + 2 * t,
        clip: true,
        place(top + left, dx: x0 - u, dy: t + dt, block(
          width: x1 - x0,
          height: height - dt - db,
          radius: radius,
          stroke: stroke
            + (
              top: if p.free.top { s },
              bottom: if p.free.bottom { s },
            ),
        )),
      ))
    })
  }

  block(
    radius: radius,
    fill: hl.fill,
    outset: (left: outset-left),
    width: end - start,
    height: height,
    stroke-blocks.join(),
  )
}

/// Construct highlights block for the sub-lines of a line.
#let compute-highlights(
  i,
  l,
  width,
  inset,
  char-width,
  char-height,
  highlights,
) = {
  let highlight-blocks = ()
  for hl in highlights {
    // Select sub-lines affected by this highlight
    let slines = l
      .slines
      .enumerate()
      .filter(sl => highlight-on-sub-line(i, l.line-end, sl.last(), hl))

    // Create a highlight block per sub-line
    for (m, (k, sl)) in slines.enumerate() {
      // Look if the highlight is spaning on this sub-line
      let spaning-start = is-spaning-start(i, m, hl)
      let spaning-end = is-spaning-end(i, m, slines.len(), hl)

      // Get the start and end position of the highlight on this sub-line
      let start = sub-line-start-pos(i, l.pos-indent, k, sl, hl)
      let end = sub-line-end-pos(
        i,
        sl,
        hl,
        width + inset.right.to-absolute(),
        char-width,
      )

      // Style the highlighted part of the sub-line
      let (pre-hl, rest) = ct.content-split-pos(sl.body, start)
      let (in-hl, post-hl) = if type(end) != int {
        (rest, [])
      } else {
        ct.content-split-pos(rest, end - start)
      }
      l.slines.at(k).body = (
        pre-hl + ct.content-map-text(in-hl, hl.code-style) + post-hl
      )

      let touches = hl
        .at("touches", default: (:))
        .at(block-key(i, k), default: no-touches)

      let (start, end) = block-span(
        hl,
        sl,
        start,
        end,
        spaning-start,
        char-width,
      )

      let hl-block = move(
        dy: .24em - block-top-pad(hl, inset),
        highlight-block(
          hl,
          spaning-start,
          spaning-end,
          start,
          end,
          inset,
          char-width,
          char-height,
          touches,
        ),
      )

      highlight-blocks.push((k, start, hl-block))
    }
  }

  return (l.slines, highlight-blocks)
}
