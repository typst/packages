// Envelope windows as DATA, the always-visible band they imply on the sheet, and the
// print-proof overlay (`theme.custom.proof(true)`): print one sheet, hold it against
// the envelope. No new concepts: an envelope is a record on the layout, the band is
// derived, the overlay is drawn by the frame in the foreground layer.
//
// Model (all lengths absolute):
//   * the sheet is Z-folded at `fold` (auto = layout.marks.fold); the address panel
//     is [0, first fold]; the folded packet is as tall as the TALLEST panel;
//   * the packet may sit anywhere inside the envelope (outer size = conservative:
//     real pockets are 1-3 mm smaller, so real play is smaller than assumed);
//   * `band` = the part of the sheet that shows through the window in EVERY position
//     (Royal Mail and USPS test this by tapping the letter on all four edges).

#let _fail(path, msg) = panic(path.join("::") + " " + msg)

#let _abs(v, total) = {
  if v == auto { return auto }
  if type(v) == ratio { return v / 100% * total }
  if type(v) == relative { return v.ratio / 100% * total + v.length }
  v
}

/// Validates one envelope record; returns it normalized with `rect` (window in
/// envelope coordinates, origin top-left of the front face).
#let normalize-envelope(e, path) = {
  if type(e) != dictionary {
    _fail(
      path,
      "must be an envelope record (name:, size:, window:), found " + repr(e),
    )
  }
  for k in e.keys() {
    if k not in ("name", "size", "window", "fold", "note") {
      _fail(
        path,
        "has no field `"
          + k
          + "`; envelope fields: name, size, window, fold, note",
      )
    }
  }
  for k in ("name", "size", "window") {
    if k not in e { _fail(path, "needs `" + k + "`") }
  }
  if type(e.name) != str { _fail(path + ("name",), "must be a string") }
  let size = e.size
  if (
    type(size) != array or size.len() != 2 or size.any(v => type(v) != length)
  ) {
    _fail(
      path + ("size",),
      "must be (width, height) as lengths, e.g. (220mm, 110mm)",
    )
  }
  let (ew, eh) = size
  let w = e.window
  if type(w) != dictionary {
    _fail(
      path + ("window",),
      "must be a dictionary (left|right, top|bottom, width, height)",
    )
  }
  for k in w.keys() {
    if k not in ("left", "right", "top", "bottom", "width", "height") {
      _fail(
        path + ("window",),
        "has no field `"
          + k
          + "`; window fields: left, right, top, bottom, width, height",
      )
    }
  }
  if ("left" in w) == ("right" in w) {
    _fail(path + ("window",), "needs exactly one of `left` or `right`")
  }
  if ("top" in w) == ("bottom" in w) {
    _fail(path + ("window",), "needs exactly one of `top` or `bottom`")
  }
  if "width" not in w or "height" not in w {
    _fail(path + ("window",), "needs `width` and `height`")
  }
  let x = if "left" in w { w.left } else { ew - w.right - w.width }
  let y = if "top" in w { w.top } else { eh - w.bottom - w.height }
  if x < 0mm or y < 0mm or x + w.width > ew or y + w.height > eh {
    _fail(
      path + ("window",),
      "lies outside the envelope (" + repr(ew) + " x " + repr(eh) + ")",
    )
  }
  (
    e
      + (
        fold: e.at("fold", default: auto),
        rect: (x: x, y: y, w: w.width, h: w.height),
      )
  )
}

/// Where one envelope's window lands on the sheet.
/// -> none (fold scheme unknown) | dictionary (name, misfit: none, packet: (w, h), play: (x, y), nominal, far, band)
///    - rects as (x, y, w, h) | (name, misfit: str) when the folded sheet does not fit
#let envelope-band(
  e,
  layout,
  pw,
  ph,
  path: ("theme", "layout", "envelopes"),
) = {
  let e = normalize-envelope(e, path)
  // name the envelope in later messages (the index was only needed for malformed records)
  let path = if path.last().match(regex("^[0-9]+$")) != none {
    path.slice(0, -1) + (e.name,)
  } else { path + (e.name,) }
  // `fold: auto` follows the printed marks; without marks the fold scheme is unknown
  if (
    e.fold == auto
      and (type(layout.marks) != dictionary or layout.marks.fold.len() == 0)
  ) { return none }
  let folds = if e.fold != auto { e.fold } else { layout.marks.fold }
  let cuts = (0mm, ..folds.map(f => _abs(f, ph)), ph)
  let panels = range(cuts.len() - 1).map(i => cuts.at(i + 1) - cuts.at(i))
  if panels.any(p => p <= 0mm) {
    _fail(path + ("fold",), "fold positions must increase and lie on the sheet")
  }
  let first = cuts.at(1)
  let packet = calc.max(..panels)
  let off = packet - first // sheet top edge below the packet top (e.g. DIN form A: 18 mm)
  let (ew, eh) = e.size
  let (px, py) = (ew - pw, eh - packet)
  if px < 0mm or py < 0mm {
    // not misuse: returned as a lint finding (validate-layout), skipped by the overlay
    return (
      name: e.name,
      misfit: path.join("::")
        + " does not take the folded sheet: packet "
        + str(calc.round(pw / 1mm, digits: 1))
        + " x "
        + str(calc.round(packet / 1mm, digits: 1))
        + " mm, envelope "
        + str(calc.round(ew / 1mm, digits: 1))
        + " x "
        + str(calc.round(eh / 1mm, digits: 1))
        + " mm; check the paper, `marks.fold` or the envelope's `fold`",
      misfit-args: (
        envelope: e.name,
        packet-w: calc.round(pw / 1mm, digits: 1),
        packet-h: calc.round(packet / 1mm, digits: 1),
        envelope-w: calc.round(ew / 1mm, digits: 1),
        envelope-h: calc.round(eh / 1mm, digits: 1),
      ),
    )
  }
  let r = e.rect
  let nominal = (x: r.x, y: r.y - off, w: r.w, h: r.h) // insert pushed to the top-left corner
  let far = (x: r.x - px, y: r.y - off - py, w: r.w, h: r.h) // pushed to the bottom-right corner
  let band = (x: r.x, y: r.y - off, w: r.w - px, h: r.h - py)
  (
    name: e.name,
    misfit: none,
    note: e.at("note", default: none),
    packet: (w: pw, h: packet),
    play: (x: px, y: py),
    nominal: nominal,
    far: far,
    band: band,
  )
}

/// The rectangle that holds the recipient lines: the address area's inner box,
/// narrowed to the recipient's row when `arrange` gives fixed row heights.
#let recipient-box(layout, pw, ph, area-rect) = {
  let hits = layout
    .areas
    .pairs()
    .filter(((n, r)) => (
      r != none and r.place == "fixed" and "recipient" in r.parts
    ))
  if hits.len() == 0 { return none }
  let (n, r) = hits.first()
  let rr = area-rect(r, pw, ph)
  if rr.h == auto { return none }
  let ins = r.inset
  let (x, y, w, h) = (
    rr.x + ins.left,
    rr.y + ins.top,
    rr.w - ins.left - ins.right,
    rr.h - ins.top - ins.bottom,
  )
  let a = r.arrange
  if type(a) == dictionary and "rows" in a and "columns" not in a {
    let rows = a.rows
    let i = r.parts.position(p => p == "recipient")
    if (
      type(rows) == array
        and rows.len() == r.parts.len()
        and rows.slice(0, i + 1).all(v => type(v) == length)
    ) {
      let top = rows.slice(0, i).fold(0mm, (s, v) => s + v)
      return (area: n, x: x, y: y + top, w: w, h: rows.at(i))
    }
  }
  (area: n, x: x, y: y, w: w, h: h)
}

/// Fit of the recipient box in every declared envelope: how many lines (at the given
/// line metrics) and how wide a line always shows. Pure; `first` = height of a
/// one-line block, `pitch` = baseline-to-baseline distance.
/// -> array of (name, band, lines, width, top-ok, left-ok)
#let window-fit(
  layout,
  pw,
  ph,
  area-rect,
  first: 3.3mm,
  pitch: 4.3mm,
  clearance: 2mm,
) = {
  let box = recipient-box(layout, pw, ph, area-rect)
  if box == none { return () }
  layout
    .envelopes
    .enumerate()
    .map(((i, e)) => {
      let b = envelope-band(e, layout, pw, ph, path: (
        "theme",
        "layout",
        "envelopes",
        str(i),
      ))
      if b == none or b.misfit != none {
        return (
          name: e.at("name", default: str(i)),
          band: none,
          lines: 0,
          width: 0mm,
          top-ok: false,
          left-ok: false,
          box: box,
          unknown: true,
        )
      }
      // keep `clearance` free inside the window (Royal Mail: 2 mm; USPS: 1/8 in)
      let bb = (
        x: b.band.x + clearance,
        y: b.band.y + clearance,
        w: b.band.w - 2 * clearance,
        h: b.band.h - 2 * clearance,
      )
      let top-ok = box.y >= bb.y - 0.01mm
      let left-ok = box.x >= bb.x - 0.01mm and box.x < bb.x + bb.w
      let vis-h = calc.min(bb.y + bb.h, box.y + box.h) - box.y
      let lines = if not top-ok or vis-h < first { 0 } else {
        int(calc.floor((vis-h - first) / pitch)) + 1
      }
      let width = if left-ok {
        calc.min(bb.x + bb.w, box.x + box.w) - box.x
      } else { 0mm }
      (
        name: b.name,
        band: bb,
        lines: lines,
        width: width,
        top-ok: top-ok,
        left-ok: left-ok,
        box: box,
      )
    })
}

// --- overlay -------------------------------------------------------------------------
#let _proof-ink = rgb("#d9480f")
#let _ok-ink = rgb("#2b8a3e")
#let _warn-ink = rgb("#b08800")
#let _hatch = tiling(size: (3pt, 3pt), place(line(
  start: (0%, 100%),
  end: (100%, 0%),
  stroke: 0.3pt + _ok-ink.transparentize(40%),
)))

#let _rect(r, ..args) = place(top + left, dx: r.x, dy: r.y, rect(
  width: calc.max(r.w, 0mm),
  height: calc.max(r.h, 0mm),
  ..args,
))

/// Proof overlay for one page (foreground). `which`: true or an array of envelope names.
/// `metrics` = (first:, pitch:) measured by the caller with the recipient's text settings.
#let proof-overlay(layout, pw, ph, area-rect, which, page, metrics) = {
  set text(size: 6.5pt, fill: _proof-ink)
  let folds = if type(layout.marks) == dictionary { layout.marks.fold } else {
    ()
  }
  // fold and punch lines across the whole sheet (every page is folded)
  for f in folds {
    place(top + left, dy: f, line(length: pw, stroke: (
      paint: _proof-ink,
      thickness: 0.4pt,
      dash: "dashed",
    )))
    place(
      top + right,
      dx: -2mm,
      dy: f - 2.6mm,
      [fold #calc.round(f / 1mm, digits: 1) mm],
    )
  }
  if type(layout.marks) == dictionary and layout.marks.punch != none {
    let p = layout.marks.punch
    place(top + left, dy: p, line(length: 14mm, stroke: (
      paint: _proof-ink,
      thickness: 0.4pt,
      dash: "dotted",
    )))
    place(top + left, dx: 15mm, dy: p - 1.3mm, [punch])
  }
  if page != 1 { return }
  let envs = layout.envelopes.filter(e => which == true or e.name in which)
  let fits = window-fit(
    layout + (envelopes: envs),
    pw,
    ph,
    area-rect,
    first: metrics.first,
    pitch: metrics.pitch,
  )
  let ink-of(n) = if n >= 5 { _ok-ink } else if n == 4 { _warn-ink } else {
    _proof-ink
  }
  for (i, e) in envs.enumerate() {
    let b = envelope-band(e, layout, pw, ph)
    if b == none or b.misfit != none { continue }
    let ink = ink-of(fits.at(i, default: (lines: 0)).lines)
    // the window with the insert in both extreme corners, and the band that always shows
    _rect(
      b.nominal,
      stroke: (paint: ink, thickness: 0.5pt, dash: "dashed"),
      radius: 2mm,
    )
    _rect(
      b.far,
      stroke: (
        paint: ink.transparentize(40%),
        thickness: 0.4pt,
        dash: "dotted",
      ),
      radius: 2mm,
    )
    _rect(b.band, fill: _hatch, stroke: 0.4pt + ink)
  }
  let rb = recipient-box(layout, pw, ph, area-rect)
  let worst = if fits.len() == 0 { 0 } else {
    calc.min(..fits.map(f => f.lines))
  }
  if rb != none {
    _rect(rb, stroke: 0.7pt + ink-of(worst))
    place(top + left, dx: rb.x, dy: rb.y + rb.h + 0.6mm, text(
      fill: ink-of(worst),
    )[recipient box: #worst lines always visible])
  }
  // legend: what always shows (2 mm clearance), per envelope
  place(bottom + left, dx: 12mm, dy: -(layout.margin.bottom + 2mm), block(
    fill: white.transparentize(10%),
    stroke: 0.4pt + _proof-ink,
    inset: 1.6mm,
    {
      set par(leading: 0.35em)
      strong[PROOF - #layout.name] + [ (remove `proof(true)` before sending)]
      linebreak()
      [dashed: window, insert top-left · dotted: insert bottom-right · hatched: always visible · folds and punch: red lines]
      for (i, e) in envs.enumerate() {
        let f = fits.at(i, default: none)
        linebreak()
        text(fill: ink-of(if f == none { 0 } else {
          f.lines
        }))[#e.name#if e.at("note", default: none) != none [ (#e.note)]: #if f == none [no recipient box] else [#f.lines lines, lines up to #calc.round(f.width / 1mm, digits: 0) mm]]
      }
    },
  ))
}
