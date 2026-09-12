#import "states.typ": *
#import "render.typ": *
#import "routing.typ": *
#import "utils.typ" as deixis-utils

#let text-padding = (top: 0.9em, bottom: 0.2em, x: 0.1em)

/// --------------------
/// Group layout
/// --------------------

/// The common layout for grouped notes (footnotes and endnotes).
/// - separator (auto, content): The separator override. If `auto`, uses the separator of the first note.
/// - clearance (auto, length): The clearance override. If `auto`, uses the clearance of the first note.
/// - gap (auto, length): The gap override. If `auto`, uses the local gap of each note.
/// - render-group (auto, function): The group render function. If `auto`, uses the `render-group` of the first note.
///
/// -> content
#let deixis-group-layout(
  notes-data,
  separator: auto,
  clearance: auto,
  gap: auto,
  render-group: auto,
) = {
  if notes-data.len() == 0 { return }

  let c-clearance = if clearance == auto { notes-data.first().at("clearance", default: 1em) } else { clearance }
  let c-separator = if separator == auto { notes-data.first().at("separator", default: none) } else { separator }
  let c-render-group = if render-group == auto {
    notes-data.first().at("render-group", default: deixis-default-render-group)
  } else { render-group }

  let unique-series = ()
  for data in notes-data {
    let s = data.at("series", default: "default")
    if s not in unique-series { unique-series.push(s) }
  }

  for (i, current-series) in unique-series.enumerate() {
    let series-notes = notes-data.filter(n => n.at("series", default: "default") == current-series)

    if i == 0 {
      v(c-clearance, weak: true)
      c-separator
    } else {
      v(c-clearance / 1.5, weak: true)
    }

    c-render-group(series-notes, gap: gap)
  }
}

/// --------------------
/// Margin layout
/// --------------------

#let _deixis-resolve-side(
  natural-y,
  l-current-bottom,
  r-current-bottom,
  bottom-bound,
  l-space-abs,
  r-space-abs,
  min-margin-width,
  preferred-side,
  overflowed-l: false,
  overflowed-r: false,
  strategy: auto,
) = {
  if strategy not in ("strict", "nearest", auto) {
    panic("_deixis-resolve-side: strategy must be 'strict', 'nearest', or auto.")
  }
  let actual-strategy = if strategy == auto { "nearest" } else { strategy }

  let l-valid = l-space-abs >= min-margin-width
  let r-valid = r-space-abs >= min-margin-width

  if l-valid and r-valid {
    let l-est = calc.max(natural-y, l-current-bottom)
    let r-est = calc.max(natural-y, r-current-bottom)

    let l-full = overflowed-l or (l-est >= bottom-bound - 1pt)
    let r-full = overflowed-r or (r-est >= bottom-bound - 1pt)

    if actual-strategy == "strict" {
      let pref-full = if preferred-side == right { r-full } else { l-full }
      let unpref-full = if preferred-side == right { l-full } else { r-full }

      if not pref-full { return preferred-side } else if not unpref-full {
        return if preferred-side == right { left } else { right }
      } else {
        if l-est < r-est { return left } else if r-est < l-est { return right } else { return preferred-side }
      }
    } else {
      if l-est < r-est { return left } else if r-est < l-est { return right } else { return preferred-side }
    }
  }

  if r-valid { return right }
  if l-valid { return left }

  if l-space-abs > r-space-abs + 1pt { return left }
  if r-space-abs > l-space-abs + 1pt { return right }

  return preferred-side
}

/// A lightweight margin layout engine that places each note exactly aligned with its marker.
/// It intentionally ignores collisions, gaps, and spillovers.
#let deixis-margin-note-exact-layout(
  notes,
  top-bound,
  bottom-bound,
  start-x,
  text-width,
  end-y,
  left-space,
  right-space,
  current-page,
  min-margin-width: 1in,
  pushed-notes: (),
  ..args,
) = context {
  let l-space-abs = deixis-utils.resolve-len(left-space)
  let r-space-abs = deixis-utils.resolve-len(right-space)
  let req-space = deixis-utils.resolve-len(min-margin-width)

  let pref-dir = deixis-utils.text-direction(text.dir, text.lang)
  let preferred-side = if pref-dir == rtl { left } else { right }

  let resolve-rel-len(val, ref-len, def) = {
    if val == auto { return def }
    if type(val) == ratio { return (val / 100%) * ref-len }
    if type(val) == relative { return deixis-utils.resolve-signed-len(val.length) + ((val.ratio / 100%) * ref-len) }
    return deixis-utils.resolve-signed-len(val)
  }

  let formatted-notes = ()

  for n in notes {
    let note-data = n.note-data

    let actual-side = note-data.side
    if actual-side in ("inside", "outside") {
      if note-data.at("target-id", default: "page") == "page" {
        let c-page = if "current-page" in dictionary(sys) { current-page } else { current-block.page }
        actual-side = if calc.odd(c-page) == (actual-side == "inside") { left } else { right }
      } else {
        let is-outside = (actual-side == "outside")
        actual-side = if (pref-dir == rtl) == is-outside { left } else { right }
      }
    } else if actual-side == "left" { actual-side = left } else if actual-side == "right" { actual-side = right }

    // min-margin-width safety catch
    if actual-side != auto and note-data.at("mark-align-strictness", default: "none") != "strict" {
      let margin-width = if actual-side == left { l-space-abs } else { r-space-abs }
      if margin-width < req-space {
        let opposite-width = if actual-side == left { r-space-abs } else { l-space-abs }
        if opposite-width > margin-width {
          actual-side = if actual-side == left { right } else { left }
        }
      }
    }

    let c-mark-align = note-data.at("mark-align", default: "top")
    let body-align = if type(c-mark-align) == dictionary and "body" in c-mark-align { c-mark-align.body } else if (
      type(c-mark-align) in (str, alignment)
    ) { c-mark-align } else { "top" }
    let body-align-str = if type(body-align) == alignment { repr(body-align.y) } else { str(body-align) }

    let dy-val = deixis-utils.resolve-signed-len(note-data.dy)
    let natural-y = note-data.at("y", default: 0pt) + dy-val

    if actual-side == auto {
      actual-side = _deixis-resolve-side(
        natural-y,
        natural-y,
        natural-y,
        bottom-bound,
        l-space-abs,
        r-space-abs,
        req-space,
        preferred-side,
        strategy: note-data.at("side-strategy", default: auto),
      )
    }

    let margin-width = if actual-side == left { l-space-abs } else { r-space-abs }
    let n-width = calc.max(0pt, resolve-rel-len(note-data.width, margin-width, margin-width))
    let dx-val = resolve-rel-len(note-data.dx, margin-width, (margin-width - n-width) / 2.0)

    let pad-left = if actual-side == left { margin-width - n-width - dx-val } else { dx-val }
    pad-left = calc.max(0pt, pad-left)

    let attach-x = if actual-side == left { start-x - dx-val } else { start-x + text-width + dx-val }

    let render-single = note-data.at("render-single", default: deixis-native-render-single)
    let raw-rendered = render-single(note-data, inner-width: 100%, ..args.named())

    let final-rendered = box(width: margin-width, align(left, pad(left: pad-left, block(width: n-width, raw-rendered))))
    let h = measure(final-rendered).height

    let shifted-y = natural-y
    if body-align-str == "bottom" { shifted-y -= h } else if body-align-str == "horizon" { shifted-y -= h / 2 }

    formatted-notes.push((
      mark-page: n.mark-page,
      mark-block: n.at("mark-block", default: 0),
      block-idx: n.at("block-idx", default: 0),
      mark-x: note-data.at("mark-x", default: 0pt),
      mark-y: note-data.at("mark-y", default: 0pt),
      marker-width: note-data.at("marker-width", default: 0pt),
      marker-str: note-data.at("marker-str", default: none),
      text-size: note-data.at("text-size", default: auto),
      has-inline-box: note-data.at("has-inline-box", default: false),
      mark-type: note-data.at("mark-type", default: "inline"),
      reg: note-data.at("reg", default: none),
      r-pins: note-data.at("r-pins", default: ()),
      gap: 0pt,
      side: actual-side,
      link: note-data.at("link", default: "none"),
      link-stroke: note-data.at("link-stroke", default: none),
      link-radius: note-data.at("link-radius", default: 0pt),
      link-marks: note-data.at("link-marks", default: "none"),
      link-waypoints: note-data.at("link-waypoints", default: auto),
      link-ports: note-data.at("link-ports", default: auto),
      attach-x: attach-x,
      y: shifted-y,
      final-y: shifted-y,
      h: h,
      w: n-width,
      rendered: final-rendered,
      is-incoming: n.mark-page < current-page,
      is-outgoing: false,
    ))
  }

  let text-bounds = (left: start-x, right: start-x + text-width)

  place(top + left, {
    _deixis-render-margin-links(
      formatted-notes,
      current-page,
      text-bounds,
      top-bound,
      bottom-bound,
    )
    for n in formatted-notes {
      let margin-x = if n.side == left { start-x - l-space-abs } else { start-x + text-width }
      place(dx: margin-x, dy: n.final-y, n.rendered)
    }
  })
}

#let _deixis-rubber-band(
  note-list,
  top-bound,
  bottom-bound,
) = {
  if note-list.len() == 0 { return () }

  let placed-y = ()
  let current-bottom = top-bound
  for (i, n) in note-list.enumerate() {
    let gap = if i == 0 { 0pt } else { n.at("gap", default: 0pt) }
    let target-y = calc.max(n.y, current-bottom + gap)
    placed-y.push(target-y)
    current-bottom = target-y + n.h
  }

  let final-y = ()
  let next-allowed-bottom = bottom-bound
  for i in range(note-list.len() - 1, -1, step: -1) {
    let n = note-list.at(i)
    let y = placed-y.at(i)
    let n-mark-align-strict = n.at("mark-align-strictness", default: "none")

    if y + n.h > next-allowed-bottom and n-mark-align-strict != "strict" {
      y = next-allowed-bottom - n.h
    }

    if n-mark-align-strict == "loose" {
      let min-y = calc.max(top-bound, n.mark-y - n.h)
      if y < min-y { y = min-y }
    }

    final-y.insert(0, y)
    let gap = if i == 0 { 0pt } else { n.at("gap", default: 0pt) }
    next-allowed-bottom = y - gap
  }

  let resolved-y = ()
  let cur-b = top-bound
  for (i, n) in note-list.enumerate() {
    let gap = if i == 0 { 0pt } else { n.at("gap", default: 0pt) }
    let y = calc.max(final-y.at(i), cur-b + gap)
    resolved-y.push(y)
    cur-b = y + n.h
  }

  return resolved-y
}

/// A placement-based margin layout engine that uses the rubber band algorithm under the hood.
#let deixis-margin-note-adaptive-layout(
  notes,
  top-bound,
  bottom-bound,
  start-x,
  text-width,
  end-y,
  left-space,
  right-space,
  current-page,
  min-margin-width: 1in,
  pushed-notes: (),
  ..args,
) = context {
  let l-space-abs = deixis-utils.resolve-len(left-space)
  let r-space-abs = deixis-utils.resolve-len(right-space)
  let req-space = deixis-utils.resolve-len(min-margin-width)

  let left-notes = ()
  let right-notes = ()
  let pref-dir = deixis-utils.text-direction(text.dir, text.lang)
  let preferred-side = if pref-dir == rtl { left } else { right }

  let l-current-bottom = top-bound
  let r-current-bottom = top-bound

  let _resolve-rel-len(val, ref-len, def) = {
    if val == auto { return def }
    if type(val) == ratio { return (val / 100%) * ref-len }
    if type(val) == relative { return deixis-utils.resolve-signed-len(val.length) + ((val.ratio / 100%) * ref-len) }
    return deixis-utils.resolve-signed-len(val)
  }

  for n in notes {
    let note-data = n.note-data

    let n-gap = deixis-utils.resolve-len(note-data.at("gap", default: 0.5em))

    let actual-side = note-data.side
    if actual-side in ("inside", "outside") {
      if note-data.at("target-id", default: "page") == "page" {
        let c-page = if "current-page" in dictionary(sys) { current-page } else { current-block.page }
        actual-side = if calc.odd(c-page) == (actual-side == "inside") { left } else { right }
      } else {
        let is-outside = (actual-side == "outside")
        if pref-dir == rtl {
          actual-side = if is-outside { left } else { right }
        } else {
          actual-side = if is-outside { right } else { left }
        }
      }
    } else if actual-side == "left" { actual-side = left } else if actual-side == "right" { actual-side = right }

    // min-margin-width safety catch
    if actual-side != auto and note-data.at("mark-align-strictness", default: "none") != "strict" {
      let margin-width = if actual-side == left { l-space-abs } else { r-space-abs }
      if margin-width < req-space {
        let opposite-width = if actual-side == left { r-space-abs } else { l-space-abs }
        if opposite-width > margin-width {
          actual-side = if actual-side == left { right } else { left }
        }
      }
    }

    let c-mark-align = note-data.at("mark-align", default: "top")

    let body-align = if type(c-mark-align) == dictionary and "body" in c-mark-align { c-mark-align.body } else if (
      type(c-mark-align) in (str, alignment)
    ) { c-mark-align } else { "top" }
    let body-align-str = if type(body-align) == alignment { repr(body-align.y) } else { str(body-align) }

    let dy-val = deixis-utils.resolve-signed-len(note-data.dy)
    let natural-y = note-data.at("y", default: 0pt) + dy-val

    if actual-side == auto {
      actual-side = _deixis-resolve-side(
        natural-y,
        l-current-bottom,
        r-current-bottom,
        bottom-bound,
        l-space-abs,
        r-space-abs,
        req-space,
        preferred-side,
        strategy: note-data.at("side-strategy", default: auto),
      )
    }

    let margin-width = if actual-side == left { l-space-abs } else { r-space-abs }
    let n-width = calc.max(0pt, _resolve-rel-len(note-data.width, margin-width, margin-width))
    let dx-val = _resolve-rel-len(note-data.dx, margin-width, (margin-width - n-width) / 2.0)

    let pad-left = if actual-side == left { margin-width - n-width - dx-val } else { dx-val }

    let attach-x = if actual-side == left {
      start-x - dx-val
    } else {
      start-x + text-width + dx-val
    }

    let n-link = note-data.at("link", default: "none")
    let n-link-stroke = note-data.at("link-stroke", default: none)
    let n-link-radius = note-data.at("link-radius", default: 0pt)
    let n-link-waypoints = note-data.at("link-waypoints", default: auto)
    let n-link-ports = note-data.at("link-ports", default: auto)
    let n-link-marks = note-data.at("link-marks", default: "none")

    let render-single = note-data.at("render-single", default: deixis-native-render-single)

    let raw-rendered = render-single(
      note-data,
      inner-width: 100%,
      ..args.named(),
    )

    let final-rendered = box(width: margin-width, align(left, pad(left: pad-left, block(width: n-width, raw-rendered))))
    let h = measure(final-rendered).height

    if body-align-str == "bottom" { natural-y -= h } else if body-align-str == "horizon" { natural-y -= h / 2 }

    let n-mark-align-strict = note-data.at("mark-align-strictness", default: "none")
    let obj = (
      mark-page: n.mark-page,
      mark-block: n.at("mark-block", default: 0),
      block-idx: n.at("block-idx", default: 0),
      mark-x: note-data.at("mark-x", default: 0pt),
      mark-y: note-data.at("mark-y", default: 0pt),
      marker-width: note-data.at("marker-width", default: 0pt),
      marker-str: note-data.at("marker-str", default: none),
      text-size: note-data.at("text-size", default: auto),
      has-inline-box: note-data.at("has-inline-box", default: false),
      mark-type: note-data.at("mark-type", default: "inline"),
      reg: note-data.at("reg", default: none),
      r-pins: note-data.at("r-pins", default: ()),
      gap: n-gap,
      side: actual-side,
      mark-align-strictness: n-mark-align-strict,
      link: n-link,
      link-stroke: n-link-stroke,
      link-radius: n-link-radius,
      link-marks: n-link-marks,
      link-waypoints: n-link-waypoints,
      link-ports: n-link-ports,
      attach-x: attach-x,
      y: natural-y,
      h: h,
      w: n-width,
      rendered: final-rendered,
    )

    if actual-side == left {
      let eff-gap = if left-notes.len() == 0 { 0pt } else { n-gap }
      left-notes.push(obj)
      l-current-bottom = calc.max(natural-y, l-current-bottom) + h + eff-gap
    } else {
      let eff-gap = if right-notes.len() == 0 { 0pt } else { n-gap }
      right-notes.push(obj)
      r-current-bottom = calc.max(natural-y, r-current-bottom) + h + eff-gap
    }
  }

  let l-final = _deixis-rubber-band(
    left-notes,
    top-bound,
    bottom-bound,
  )
  let r-final = _deixis-rubber-band(
    right-notes,
    top-bound,
    bottom-bound,
  )

  let render-list(note-list, final-y, margin-x) = {
    for i in range(note-list.len()) {
      let n = note-list.at(i)
      let y = final-y.at(i)
      place(dx: margin-x, dy: y, n.rendered)
    }
  }

  let text-bounds = (left: start-x, right: start-x + text-width)

  let all-notes-here = ()
  for i in range(left-notes.len()) {
    let mut-n = left-notes.at(i)
    mut-n.insert("final-y", l-final.at(i))
    mut-n.insert("is-incoming", mut-n.mark-page < current-page)
    mut-n.insert("is-outgoing", false)
    all-notes-here.push(mut-n)
  }
  for i in range(right-notes.len()) {
    let mut-n = right-notes.at(i)
    mut-n.insert("final-y", r-final.at(i))
    mut-n.insert("is-incoming", mut-n.mark-page < current-page)
    mut-n.insert("is-outgoing", false)
    all-notes-here.push(mut-n)
  }

  let formatted-pushed = pushed-notes.map(pn => {
    let note-data = pn.note-data
    (
      mark-page: pn.mark-page,
      mark-block: pn.at("mark-block", default: 0),
      block-idx: pn.at("block-idx", default: 0),
      mark-x: note-data.at("mark-x", default: 0pt),
      mark-y: note-data.at("mark-y", default: 0pt),
      marker-str: note-data.at("marker-str", default: none),
      marker-width: note-data.at("marker-width", default: 0pt),
      text-size: note-data.at("text-size", default: auto),
      has-inline-box: note-data.at("has-inline-box", default: false),
      mark-type: note-data.at("mark-type", default: "inline"),
      reg: note-data.at("reg", default: none),
      r-pins: note-data.at("r-pins", default: ()),
      side: if note-data.at("side", default: right) in ("left", left) { left } else { right },
      link: note-data.at("link", default: "none"),
      link-stroke: note-data.at("link-stroke", default: none),
      link-radius: note-data.at("link-radius", default: 0pt),
      link-waypoints: note-data.at("link-waypoints", default: auto),
      link-ports: note-data.at("link-ports", default: auto),
      link-marks: note-data.at("link-marks", default: "none"),
      attach-x: 0pt,
      final-y: 0pt,
      h: 0pt,
      w: 0pt,
      is-incoming: false,
      is-outgoing: true,
    )
  })

  place(top + left, {
    _deixis-render-margin-links(
      all-notes-here + formatted-pushed,
      current-page,
      text-bounds,
      top-bound,
      bottom-bound,
    )
    render-list(left-notes, l-final, start-x - l-space-abs)
    render-list(right-notes, r-final, start-x + text-width)
  })
}

/// A margin layout engine that stacks notes sequentially like a fluid column, ignoring strict mark alignment.
#let deixis-margin-note-flow-layout(
  notes,
  top-bound,
  bottom-bound,
  start-x,
  text-width,
  end-y,
  left-space,
  right-space,
  current-page,
  min-margin-width: 1in,
  pushed-notes: (),
  ..args,
) = context {
  let l-space-abs = deixis-utils.resolve-len(left-space)
  let r-space-abs = deixis-utils.resolve-len(right-space)
  let req-space = deixis-utils.resolve-len(min-margin-width)

  let left-notes = ()
  let right-notes = ()
  let pref-dir = deixis-utils.text-direction(text.dir, text.lang)
  let preferred-side = if pref-dir == rtl { left } else { right }

  let l-current-bottom = top-bound
  let r-current-bottom = top-bound

  let _resolve-rel-len(val, ref-len, def) = {
    if val == auto { return def }
    if type(val) == ratio { return (val / 100%) * ref-len }
    if type(val) == relative { return deixis-utils.resolve-signed-len(val.length) + ((val.ratio / 100%) * ref-len) }
    return deixis-utils.resolve-signed-len(val)
  }

  for n in notes {
    let note-data = n.note-data

    let n-gap = deixis-utils.resolve-len(note-data.at("gap", default: 0.5em))

    let actual-side = note-data.side
    if actual-side in ("inside", "outside") {
      if note-data.at("target-id", default: "page") == "page" {
        let c-page = if "current-page" in dictionary(sys) { current-page } else { current-block.page }
        actual-side = if calc.odd(c-page) == (actual-side == "inside") { left } else { right }
      } else {
        let is-outside = (actual-side == "outside")
        if pref-dir == rtl {
          actual-side = if is-outside { left } else { right }
        } else {
          actual-side = if is-outside { right } else { left }
        }
      }
    } else if actual-side == "left" { actual-side = left } else if actual-side == "right" { actual-side = right }

    // min-margin-width safety catch
    if actual-side != auto and note-data.at("mark-align-strictness", default: "none") != "strict" {
      let margin-width = if actual-side == left { l-space-abs } else { r-space-abs }
      if margin-width < req-space {
        let opposite-width = if actual-side == left { r-space-abs } else { l-space-abs }
        if opposite-width > margin-width {
          actual-side = if actual-side == left { right } else { left }
        }
      }
    }

    let c-mark-align = note-data.at("mark-align", default: "top")

    let body-align = if type(c-mark-align) == dictionary and "body" in c-mark-align { c-mark-align.body } else if (
      type(c-mark-align) in (str, alignment)
    ) { c-mark-align } else { "top" }
    let body-align-str = if type(body-align) == alignment { repr(body-align.y) } else { str(body-align) }

    let dy-val = deixis-utils.resolve-signed-len(note-data.dy)
    let natural-y = note-data.at("y", default: 0pt) + dy-val

    if actual-side == auto {
      actual-side = _deixis-resolve-side(
        natural-y,
        l-current-bottom,
        r-current-bottom,
        bottom-bound,
        l-space-abs,
        r-space-abs,
        req-space,
        preferred-side,
        strategy: note-data.at("side-strategy", default: auto),
      )
    }

    let margin-width = if actual-side == left { l-space-abs } else { r-space-abs }
    let n-width = calc.max(0pt, _resolve-rel-len(note-data.width, margin-width, margin-width))
    let dx-val = _resolve-rel-len(note-data.dx, margin-width, (margin-width - n-width) / 2.0)

    let pad-left = if actual-side == left { margin-width - n-width - dx-val } else { dx-val }

    let attach-x = if actual-side == left {
      start-x - dx-val
    } else {
      start-x + text-width + dx-val
    }

    let n-link = note-data.at("link", default: "none")
    let n-link-stroke = note-data.at("link-stroke", default: none)
    let n-link-radius = note-data.at("link-radius", default: 0pt)
    let n-link-waypoints = note-data.at("link-waypoints", default: auto)
    let n-link-ports = note-data.at("link-ports", default: auto)
    let n-link-marks = note-data.at("link-marks", default: "none")

    let render-single = note-data.at("render-single", default: deixis-native-render-single)

    let raw-rendered = render-single(
      note-data,
      inner-width: 100%,
      ..args.named(),
    )

    let final-rendered = box(width: margin-width, align(left, pad(left: pad-left, block(width: n-width, raw-rendered))))
    let h = measure(final-rendered).height

    if body-align-str == "bottom" { natural-y -= h } else if body-align-str == "horizon" { natural-y -= h / 2 }

    let obj = (
      mark-page: n.mark-page,
      mark-block: n.at("mark-block", default: 0),
      block-idx: n.at("block-idx", default: 0),
      mark-x: note-data.at("mark-x", default: 0pt),
      mark-y: note-data.at("mark-y", default: 0pt),
      marker-width: note-data.at("marker-width", default: 0pt),
      marker-str: note-data.at("marker-str", default: none),
      text-size: note-data.at("text-size", default: auto),
      has-inline-box: note-data.at("has-inline-box", default: false),
      mark-type: note-data.at("mark-type", default: "inline"),
      reg: note-data.at("reg", default: none),
      r-pins: note-data.at("r-pins", default: ()),
      gap: n-gap,
      side: actual-side,
      link: n-link,
      link-stroke: n-link-stroke,
      link-radius: n-link-radius,
      link-marks: n-link-marks,
      link-waypoints: n-link-waypoints,
      link-ports: n-link-ports,
      attach-x: attach-x,
      y: natural-y,
      h: h,
      w: n-width,
      rendered: final-rendered,
    )

    if actual-side == left {
      let eff-gap = if left-notes.len() == 0 { 0pt } else { n-gap }
      left-notes.push(obj)
      l-current-bottom = calc.max(natural-y, l-current-bottom + eff-gap) + h
    } else {
      let eff-gap = if right-notes.len() == 0 { 0pt } else { n-gap }
      right-notes.push(obj)
      r-current-bottom = calc.max(natural-y, r-current-bottom + eff-gap) + h
    }
  }

  let render-flow-container(note-list, margin-x, margin-width) = {
    if note-list.len() == 0 { return (content: none, height: 0pt, final-y: ()) }

    let fr-values = ()
    let total-notes-height = 0pt
    let current-y = top-bound

    for (i, obj) in note-list.enumerate() {
      let gap = if i == 0 { 0pt } else { obj.gap }
      let target-y = calc.min(obj.y, end-y)

      let min-y = current-y + gap
      let extra-wanted = target-y - min-y
      fr-values.push(calc.max(0pt, extra-wanted) / 1pt)

      total-notes-height += gap + obj.h
      current-y = calc.max(target-y, min-y) + obj.h
    }

    let end-dist = end-y - current-y
    fr-values.push(calc.max(0pt, end-dist) / 1pt)

    let total-fr = 0.0
    for val in fr-values { total-fr += val }
    if total-fr <= 1e-5 {
      fr-values.last() = 1.0
      total-fr = 1.0
    }

    let block-physical-height = end-y - top-bound
    let container-height = calc.max(block-physical-height, total-notes-height)
    let extra-space = calc.max(0pt, container-height - total-notes-height)

    let final-y = ()
    let exact-cur-y = top-bound
    for (i, obj) in note-list.enumerate() {
      let gap = if i == 0 { 0pt } else { obj.gap }
      exact-cur-y += gap

      let space = (fr-values.at(i) / total-fr) * extra-space
      exact-cur-y += space
      final-y.push(exact-cur-y)
      exact-cur-y += note-list.at(i).h
    }

    let container-content = place(
      dx: margin-x,
      dy: top-bound,
      block(width: margin-width, height: container-height, {
        for (i, obj) in note-list.enumerate() {
          let gap = if i == 0 { 0pt } else { obj.gap }

          if i > 0 { v(gap) }
          v(fr-values.at(i) * 1fr)
          obj.rendered
        }
        v(fr-values.last() * 1fr)
      }),
    )

    return (content: container-content, height: container-height, final-y: final-y)
  }

  let l-res = render-flow-container(
    left-notes,
    start-x - l-space-abs,
    l-space-abs,
  )
  let r-res = render-flow-container(
    right-notes,
    start-x + text-width,
    r-space-abs,
  )

  let text-bounds = (left: start-x, right: start-x + text-width)

  let all-notes-here = ()
  for i in range(left-notes.len()) {
    let mut-n = left-notes.at(i)
    mut-n.insert("final-y", l-res.final-y.at(i))
    mut-n.insert("is-incoming", mut-n.mark-page < current-page)
    mut-n.insert("is-outgoing", false)
    all-notes-here.push(mut-n)
  }
  for i in range(right-notes.len()) {
    let mut-n = right-notes.at(i)
    mut-n.insert("final-y", r-res.final-y.at(i))
    mut-n.insert("is-incoming", mut-n.mark-page < current-page)
    mut-n.insert("is-outgoing", false)
    all-notes-here.push(mut-n)
  }

  let formatted-pushed = pushed-notes.map(pn => {
    let note-data = pn.note-data
    (
      mark-page: pn.mark-page,
      mark-block: pn.at("mark-block", default: 0),
      block-idx: pn.at("block-idx", default: 0),
      mark-x: note-data.at("mark-x", default: 0pt),
      mark-y: note-data.at("mark-y", default: 0pt),
      marker-width: note-data.at("marker-width", default: 0pt),
      marker-str: note-data.at("marker-str", default: none),
      text-size: note-data.at("text-size", default: auto),
      has-inline-box: note-data.at("has-inline-box", default: false),
      mark-type: note-data.at("mark-type", default: "inline"),
      reg: note-data.at("reg", default: none),
      r-pins: note-data.at("r-pins", default: ()),
      side: if note-data.at("side", default: right) in ("left", left) { left } else { right },
      link: note-data.at("link", default: "none"),
      link-stroke: note-data.at("link-stroke", default: none),
      link-radius: note-data.at("link-radius", default: 0pt),
      link-waypoints: note-data.at("link-waypoints", default: auto),
      link-ports: note-data.at("link-ports", default: auto),
      link-marks: note-data.at("link-marks", default: "none"),
      attach-x: 0pt,
      final-y: 0pt,
      h: 0pt,
      w: 0pt,
      is-incoming: false,
      is-outgoing: true,
    )
  })

  let text-bounds = (left: start-x, right: start-x + text-width)

  place(top + left, {
    _deixis-render-margin-links(
      all-notes-here + formatted-pushed,
      current-page,
      text-bounds,
      top-bound,
      bottom-bound,
    )
    l-res.content
    r-res.content
  })
}

#let _deixis-predict-cascade(
  notes,
  blocks-info,
  pref-dir,
  margin-layout,
  min-margin-width: 1in,
  cascade-breaker: true,
  ..args,
) = {
  let block-buckets = ()
  for i in range(blocks-info.len()) { block-buckets.push(()) }

  let _resolve-rel-len(val, ref-len, def) = {
    if val == auto { return def }
    if type(val) == ratio { return (val / 100%) * ref-len }
    if type(val) == relative { return deixis-utils.resolve-signed-len(val.length) + ((val.ratio / 100%) * ref-len) }
    return deixis-utils.resolve-signed-len(val)
  }

  for n in notes {
    let note-data = n.note-data
    let mark-page = n.mark-page
    let mark-x = n.mark-x
    let mark-y = n.mark-y

    if note-data.at("depth", default: 0) >= 2 {
      // FIXME: hack
      mark-x += note-data.at("marker-width", default: 0pt)
    }

    let n-gap = deixis-utils.resolve-len(note-data.at("gap", default: 0.5em))

    let dy-abs = deixis-utils.resolve-signed-len(note-data.dy)
    let natural-y = mark-y + dy-abs

    let start-idx = 0
    while start-idx < blocks-info.len() - 1 {
      let cur-block = blocks-info.at(start-idx)
      let next-block = blocks-info.at(start-idx + 1)

      if (
        mark-page > next-block.page
          or (mark-page == next-block.page and (cur-block.page < next-block.page or natural-y >= next-block.top - 1pt))
      ) {
        start-idx += 1
      } else { break }
    }
    let cur-block = blocks-info.at(start-idx)

    let new-note-data = note-data
    new-note-data.insert("mark-x", mark-x)
    new-note-data.insert("mark-y", mark-y)
    new-note-data.insert("x", mark-x)
    new-note-data.insert("y", mark-y)
    new-note-data.insert("reg", n.at("reg", default: none))
    new-note-data.insert("r-pins", n.at("r-pins", default: ()))

    if mark-page < cur-block.page or (mark-page == cur-block.page and natural-y < cur-block.top) {
      new-note-data.insert("y", cur-block.top - dy-abs)
    } else if mark-page > cur-block.page or (mark-page == cur-block.page and natural-y > cur-block.bottom) {
      new-note-data.insert("y", cur-block.bottom - dy-abs)
    }
    block-buckets.at(start-idx).push((spoofed-data: new-note-data, mark-block: start-idx, mark-page: mark-page))
  }

  let final-results = ()
  let overflow-queue = ()

  for block-id in range(blocks-info.len()) {
    let current-block = blocks-info.at(block-id)
    let current-notes = overflow-queue + block-buckets.at(block-id)
    overflow-queue = ()

    if current-notes.len() == 0 { continue }

    let first-note = current-notes.first().spoofed-data
    let local-margin-layout = first-note.at("margin-layout", default: margin-layout)
    let local-min-width = first-note.at("min-margin-width", default: min-margin-width)

    let is-flow = local-margin-layout == "flow" or type(local-margin-layout) == function
    let req-space = deixis-utils.resolve-len(local-min-width)

    let l-space-abs = current-block.l-space
    let r-space-abs = current-block.r-space
    let l-current-bottom = current-block.top
    let r-current-bottom = current-block.top

    let l-notes = ()
    let r-notes = ()

    let pref-side = if pref-dir == rtl { left } else { right }
    let overflowed-l = false
    let overflowed-r = false

    for n-obj in current-notes {
      let note-data = n-obj.spoofed-data
      let c-page = current-block.page
      let dy-abs = deixis-utils.resolve-signed-len(note-data.dy)
      let natural-y = note-data.at("y", default: 0pt) + dy-abs


      let n-gap = deixis-utils.resolve-len(note-data.at("gap", default: 0.5em))

      let actual-side = note-data.side
      if actual-side in ("inside", "outside") {
        if note-data.at("target-id", default: "page") == "page" {
          let c-page = if "current-page" in dictionary(sys) { current-page } else { current-block.page }
          actual-side = if calc.odd(c-page) == (actual-side == "inside") { left } else { right }
        } else {
          let is-outside = (actual-side == "outside")
          if pref-dir == rtl {
            actual-side = if is-outside { left } else { right }
          } else {
            actual-side = if is-outside { right } else { left }
          }
        }
      } else if actual-side == "left" { actual-side = left } else if actual-side == "right" { actual-side = right }

      // min-margin-width safety catch
      if actual-side != auto and note-data.at("mark-align-strictness", default: "none") != "strict" {
        let margin-width = if actual-side == left { l-space-abs } else { r-space-abs }
        if margin-width < req-space {
          let opposite-width = if actual-side == left { r-space-abs } else { l-space-abs }
          if opposite-width > margin-width {
            actual-side = if actual-side == left { right } else { left }
          }
        }
      }

      if actual-side == auto {
        actual-side = _deixis-resolve-side(
          natural-y,
          l-current-bottom,
          r-current-bottom,
          current-block.bottom,
          l-space-abs,
          r-space-abs,
          req-space,
          pref-side,
          overflowed-l: overflowed-l,
          overflowed-r: overflowed-r,
          strategy: note-data.at("side-strategy", default: auto),
        )
      }

      let margin-width = if actual-side == left { l-space-abs } else { r-space-abs }
      let n-width = calc.max(0pt, _resolve-rel-len(note-data.width, margin-width, margin-width))
      let dx-val = _resolve-rel-len(note-data.dx, margin-width, (margin-width - n-width) / 2.0)

      let pad-left = if actual-side == left { margin-width - n-width - dx-val } else { dx-val }

      let render-single = note-data.at("render-single", default: deixis-native-render-single)
      let raw-rendered = render-single(note-data, inner-width: 100%, ..args.named())

      let final-rendered = box(width: margin-width, align(left, pad(left: pad-left, block(
        width: n-width,
        raw-rendered,
      ))))
      let h = measure(final-rendered).height

      let n-mark-align = note-data.at("mark-align", default: "top")
      let n-mark-align-strict = note-data.at("mark-align-strictness", default: "none")

      let body-align = if type(n-mark-align) == dictionary and "body" in n-mark-align { n-mark-align.body } else if (
        type(n-mark-align) in (str, alignment)
      ) { n-mark-align } else { "top" }
      let body-align-str = if type(body-align) == alignment { repr(body-align.y) } else { str(body-align) }

      let shifted-y = natural-y
      if body-align-str == "bottom" { shifted-y -= h } else if body-align-str == "horizon" { shifted-y -= h / 2 }

      let side-notes = if actual-side == left { l-notes } else { r-notes }
      let test-notes = (
        side-notes + ((mark-y: natural-y, y: shifted-y, h: h, gap: n-gap, mark-align-strictness: n-mark-align-strict),)
      )
      let physical-overflow = false

      if is-flow {
        let total-h = 0pt
        for (i, n) in test-notes.enumerate() {
          if i > 0 { total-h += n.gap }
          total-h += n.h
        }
        if current-block.top + total-h > current-block.bottom + 0.1pt {
          physical-overflow = true
        }
      } else {
        let final-y-list = _deixis-rubber-band(
          test-notes,
          current-block.top,
          current-block.bottom,
        )

        let final-bottom = if final-y-list.len() > 0 { final-y-list.last() + test-notes.last().h } else {
          current-block.top
        }

        if final-bottom > current-block.bottom + 0.1pt {
          physical-overflow = true
        }
      }

      if cascade-breaker {
        let block-avail-height = current-block.bottom - current-block.top
        if physical-overflow and side-notes.len() == 0 and h > block-avail-height - 1pt {
          physical-overflow = false
        }
      }

      let n-spillover = note-data.at("spillover", default: true)
      if physical-overflow and not n-spillover {
        physical-overflow = false
      }

      let forced-overflow = false
      if actual-side == left and overflowed-l { forced-overflow = true }
      if actual-side == right and overflowed-r { forced-overflow = true }

      if (forced-overflow or physical-overflow) and block-id < blocks-info.len() - 1 {
        if actual-side == left { overflowed-l = true } else { overflowed-r = true }
        let pushed-note-data = note-data
        pushed-note-data.insert("y", blocks-info.at(block-id + 1).top - dy-abs)
        overflow-queue.push((spoofed-data: pushed-note-data, mark-block: n-obj.mark-block, mark-page: n-obj.mark-page))
      } else {
        let accepted-note-data = note-data
        accepted-note-data.insert("side", if actual-side == left { "left" } else { "right" })
        final-results.push((
          block-idx: block-id,
          mark-block: n-obj.mark-block,
          note-data: accepted-note-data,
          mark-page: n-obj.mark-page,
        ))

        if actual-side == left {
          let eff-gap = if l-notes.len() == 0 { 0pt } else { n-gap }
          l-notes.push((mark-y: natural-y, y: shifted-y, h: h, gap: n-gap, mark-align-strictness: n-mark-align-strict))
          l-current-bottom = calc.max(shifted-y, l-current-bottom + eff-gap) + h
        } else {
          let eff-gap = if r-notes.len() == 0 { 0pt } else { n-gap }
          r-notes.push((mark-y: natural-y, y: shifted-y, h: h, gap: n-gap, mark-align-strictness: n-mark-align-strict))
          r-current-bottom = calc.max(shifted-y, r-current-bottom + eff-gap) + h
        }
      }
    }
  }
  return final-results
}

/// --------------------
/// Other Utilities
/// --------------------

/// Places content relative to a specific anchor mark given its `internal-id` or a pin given its name.
#let deixis-place-anchored(
  body,
  dx: 0pt,
  dy: 0pt,
  anchor: bottom + right,
  internal-id: none,
  pin: none,
) = context {
  let cur-pos = here().position()
  let target-x = cur-pos.x
  let target-y = cur-pos.y

  let a-target = if type(anchor) == dictionary {
    anchor.at("target", default: anchor.at("mark", default: bottom + right))
  } else { anchor }
  let a-body = if type(anchor) == dictionary { anchor.at("body", default: a-target) } else { anchor }

  let in-left = a-target in (left, top + left, horizon + left, bottom + left)
  let in-center = a-target in (center, top + center, horizon + center, bottom + center)
  let in-top = a-target in (top, top + left, top + center, top + right)
  let in-horizon = a-target in (horizon, horizon + left, horizon + center, horizon + right)

  let b-right = a-body in (right, top + right, horizon + right, bottom + right)
  let b-center = a-body in (center, top + center, horizon + center, bottom + center)
  let b-bottom = a-body in (bottom, bottom + left, bottom + center, bottom + right)
  let b-horizon = a-body in (horizon, horizon + left, horizon + center, horizon + right)

  let r-pins = ()
  let reg-val = none
  let all-pins = query(<deixis-pin>)

  if pin != none {
    let pin-arr = if type(pin) == array { pin } else { (pin,) }
    for pin-name in pin-arr {
      for p in all-pins.filter(x => x.value.name == pin-name) { r-pins.push(p) }
    }
  } else if internal-id != none {
    let region-elems = query(<deixis-region-mark>).filter(r => (
      r.value.internal-id != none and str(r.value.internal-id) == str(internal-id)
    ))
    if region-elems.len() > 0 {
      reg-val = region-elems.first().value
      for pin-name in reg-val.pins {
        for p in all-pins.filter(x => x.value.name == pin-name) { r-pins.push(p) }
      }
    }
  }

  if r-pins.len() > 0 {
    let sorted-pins = r-pins.sorted(key: p => (p.location().page(), p.location().position().y))
    let first-page = sorted-pins.first().location().page()
    let last-page = sorted-pins.last().location().page()
    let current-page = here().page()

    let min-x = 1e10pt
    let max-x = -1e10pt
    let min-y = 1e10pt
    let max-y = -1e10pt

    for p in r-pins {
      let px = p.location().position().x
      let p-pad = p.value.at("padding", default: (left: 0pt, right: 0pt, top: 0pt, bottom: 0pt))
      let px-l = px - p-pad.left
      let px-r = px + p-pad.right
      if px-l < min-x { min-x = px-l }
      if px-r > max-x { max-x = px-r }
    }

    let p-margins = deixis-utils.get-page-margins(current-page)
    let page-h = deixis-utils.resolve-len(if type(page.height) == length { page.height } else { 29.7cm })
    let top-bound = deixis-utils.resolve-len(p-margins.top)
    let bottom-bound = page-h - deixis-utils.resolve-len(p-margins.bottom)

    min-y = top-bound
    max-y = bottom-bound

    let page-pins = r-pins.filter(p => p.location().page() == current-page)
    if page-pins.len() > 0 {
      let local-min-y = 1e10pt
      let local-max-y = -1e10pt
      for p in page-pins {
        let py = p.location().position().y
        let p-pad = p.value.at("padding", default: (left: 0pt, right: 0pt, top: 0pt, bottom: 0pt))
        let py-t = py - p-pad.top
        let py-b = py + p-pad.bottom
        if py-t < local-min-y { local-min-y = py-t }
        if py-b > local-max-y { local-max-y = py-b }
      }
      if current-page == first-page { min-y = local-min-y }
      if current-page == last-page { max-y = local-max-y }
    } else {
      if last-page < current-page {
        min-y = top-bound
        max-y = top-bound
      } else if first-page > current-page {
        min-y = bottom-bound
        max-y = bottom-bound
      }
    }

    let reg-pad = if reg-val != none { deixis-utils.get-margins(reg-val.styles.at("padding", default: 0pt)) } else {
      (left: 0pt, right: 0pt, top: 0pt, bottom: 0pt)
    }
    min-x -= deixis-utils.resolve-len(reg-pad.left)
    max-x += deixis-utils.resolve-len(reg-pad.right)

    if current-page == first-page { min-y -= deixis-utils.resolve-len(reg-pad.top) }
    if current-page == last-page { max-y += deixis-utils.resolve-len(reg-pad.bottom) }

    target-x = max-x
    if in-left { target-x = min-x } else if in-center { target-x = (min-x + max-x) / 2.0 }

    target-y = max-y
    if in-top { target-y = min-y } else if in-horizon { target-y = (min-y + max-y) / 2.0 }
  } else if internal-id != none {
    let mark-lbl = std.label("deixis-mark-" + str(internal-id))
    let elems = query(selector(mark-lbl))
    if elems.len() > 0 {
      let el = elems.first()
      let ex = el.location().position().x
      let ey = el.location().position().y

      let marker-width = 0pt
      let marker-height = 11pt
      let mm-elems = query(selector(metadata).and(selector(<deixis-inline-mark>).or(<deixis-phantom-mark>))).filter(
        m => (
          type(m.value) == dictionary
            and m.value.at("internal-id", default: none) != none
            and str(m.value.internal-id) == str(internal-id)
        ),
      )
      if mm-elems.len() > 0 {
        let mm-val = mm-elems.first().value
        marker-width = mm-val.at("marker-width", default: 0pt)
        let ts = mm-val.at("text-size", default: 11pt)
        marker-height = if type(ts) == length { ts } else { 11pt }
      }

      let min-x = ex
      let max-x = ex + marker-width
      let min-y = ey - (marker-height * 0.8)
      let max-y = ey + (marker-height * 0.2)

      target-x = max-x
      if in-left { target-x = min-x } else if in-center { target-x = (min-x + max-x) / 2.0 }

      target-y = max-y
      if in-top { target-y = min-y } else if in-horizon { target-y = (min-y + max-y) / 2.0 }
    }
  }

  let offset-x = target-x - cur-pos.x + dx
  let offset-y = target-y - cur-pos.y + dy

  let size = measure(body)
  if b-right { offset-x -= size.width } else if b-center { offset-x -= size.width / 2.0 }

  if b-bottom { offset-y -= size.height } else if b-horizon { offset-y -= size.height / 2.0 }

  place(box(place(top + left, dx: offset-x, dy: offset-y, body)))
}

/// Places content at a specific exact absolute coordinate on the page ignoring page margins.
#let deixis-absolute-place(..args) = {
  let pos-args = args.pos()
  let align-val = none
  let content = none

  if pos-args.len() == 1 {
    content = pos-args.first()
  } else if pos-args.len() == 2 {
    align-val = pos-args.first()
    content = pos-args.last()
  } else {
    panic("deixis: deixis-absolute-place expects 1 or 2 positional arguments: [alignment], content.")
  }

  let dx = args.named().at("dx", default: 0pt)
  let dy = args.named().at("dy", default: 0pt)

  // double place trick to avoid infinite layout loop
  place(top + left, context {
    let page-pos = here().position()

    let p-w = if type(page.width) == length { page.width } else { 21cm }
    let p-h = if type(page.height) == length { page.height } else { 29.7cm }

    place(
      top + left,
      dx: -page-pos.x,
      dy: -page-pos.y,
      box(
        width: p-w,
        height: p-h,
        if align-val == none {
          place(dx: dx, dy: dy, content)
        } else {
          place(align-val, dx: dx, dy: dy, content)
        },
      ),
    )
  })
}
