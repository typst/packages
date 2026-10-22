#import "../core/visibility.typ": _deixis-metadata, _deixis-body-visibility, _deixis-is-hidden
#import "../render/body.typ": *
#import "../routing/notes.typ": *
#import "../core/utils.typ" as deixis-utils
#import "../core/state.typ": deixis-setup-state
#import "../routing/frames.typ": _deixis-frame-node
#import "geometry.typ": _deixis-box-bounds
#import "../render/commands.typ": _deixis-paint-command, _deixis-emit-paint-commands
#import "../core/order.typ": _deixis-group-z-index
#import "../core/native.typ": *

#let text-padding = (top: 0.9em, bottom: 0.2em, x: 0.1em)

/// --------------------
/// Group layout
/// --------------------

/// The common layout for grouped notes (footnotes and endnotes).
/// - separator (auto, content): The separator override. If `auto`, uses the separator of the first note.
/// - clearance (auto, length): The clearance override. If `auto`, uses the clearance of the first note.
/// - gap (auto, length): The gap override. If `auto`, uses the local gap of each note.
/// - render-group (auto, function): The group render function. If `auto`, uses the first note's renderer in each series.
///
/// -> content
#let _deixis-group-layout(
  notes-data,
  separator: auto,
  clearance: auto,
  gap: auto,
  render-group: auto,
) = {
  if notes-data.len() == 0 { return }

  let c-clearance = if clearance == auto {
    _deixis-note-length(notes-data.first(), notes-data.first().at("clearance", default: 1em))
  } else { clearance }
  let html = _std-target() == "html"
  let c-separator = if separator == auto { notes-data.first().at("separator", default: none) } else { separator }
  for (i, series-notes) in _deixis-series-groups(notes-data).enumerate() {
    let c-render-group = if render-group == auto {
      series-notes.first().at("render-group", default: deixis-aligned-render-group)
    } else { render-group }

    // HTML lists carry their own spacing; drawn separators have no HTML form.
    if html {
    } else if i == 0 {
      v(c-clearance, weak: true)
      c-separator
    } else {
      v(c-clearance / 1.5, weak: true)
    }

    for data in series-notes { _deixis-body-visibility(data) }
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
      let min-y = calc.max(top-bound, n.at("anchor-y", default: n.at("mark-y", default: n.y)) - n.h)
      if y < min-y { y = min-y }
    }

    // Collected bottom-up; reversed once below (front insertion is quadratic).
    final-y.push(y)
    let gap = if i == 0 { 0pt } else { n.at("gap", default: 0pt) }
    next-allowed-bottom = y - gap
  }
  final-y = final-y.rev()

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

// A placement plan contains geometry only. In particular, measuring a candidate
// must never capture live body identities, nested note state, or destination probes.
#let _deixis-margin-frame(top-bound, bottom-bound, end-y, left-space, right-space, current-page, binding) = (
  top: top-bound, bottom: bottom-bound, end: end-y,
  l-space: deixis-utils.resolve-len(left-space), r-space: deixis-utils.resolve-len(right-space),
  page: current-page, binding: binding,
)

#let _deixis-margin-rel-len(val, ref-len, def) = {
  if val == auto { return def }
  if type(val) == ratio { return (val / 100%) * ref-len }
  if type(val) == relative { return deixis-utils.resolve-signed-len(val.length) + (val.ratio / 100%) * ref-len }
  deixis-utils.resolve-signed-len(val)
}

#let _deixis-margin-side(data, frame, pref-dir, layout, min-width, l-bottom, r-bottom,
  overflowed-l: false, overflowed-r: false,
) = {
  let side = deixis-utils.resolve-margin-side(
    data.side, data.at("target-id", default: "page"), frame.page, pref-dir, frame.binding,
  )
  if side != auto and data.at("mark-align-strictness", default: "none") != "strict" {
    let width = if side == left { frame.l-space } else { frame.r-space }
    let opposite = if side == left { frame.r-space } else { frame.l-space }
    if width < min-width and opposite > width { side = if side == left { right } else { left } }
  }
  if side != auto { return side }
  let natural-y = data.at("y", default: 0pt) + deixis-utils.resolve-signed-len(data.at("dy", default: 0pt))
  _deixis-resolve-side(
    natural-y,
    if layout == "exact" { natural-y } else { l-bottom },
    if layout == "exact" { natural-y } else { r-bottom },
    frame.bottom, frame.l-space, frame.r-space, min-width,
    if pref-dir == rtl { left } else { right },
    overflowed-l: overflowed-l, overflowed-r: overflowed-r,
    strategy: data.at("side-strategy", default: auto),
  )
}

#let _deixis-margin-box(data, placement, ..args) = {
  box(width: placement.margin-width, align(left, pad(left: placement.pad-left,
    block(width: placement.w, above: 0pt, below: 0pt,
      _deixis-render-single(data, inner-width: 100%, ..args.named())),
  )))
}

// Typst keys a measurement by its context location. Each page overlay plans
// the preceding pages again, so measuring there repeated identical body layout
// once per later page. A show rule on the note's own located metadata runs at
// that one location for every page, so Typst can reuse the same measurement.
// The overlay's styles still apply. Only the height leaves the rule, as fixed
// spacing that set/show rules for visible containers cannot resize.
#let _deixis-measure-margin-height(body, anchor) = {
  if anchor == none { return measure(body).height }
  let target = anchor.location()
  measure({
    show metadata.where(label: <deixis-margin-note>): it => {
      if it.location() != target { return it }
      v(measure(body).height)
    }
    anchor
  }).height
}

#let _deixis-prepare-margin(data, side, frame, layout, measure-anchor: none, ..args) = {
  let margin-width = if side == left { frame.l-space } else { frame.r-space }
  let w = calc.max(0pt, _deixis-margin-rel-len(data.at("width", default: auto), margin-width, margin-width))
  let dx = _deixis-margin-rel-len(data.at("dx", default: auto), margin-width, (margin-width - w) / 2)
  let geometry = (
    margin-width: margin-width, w: w, dx: dx,
    pad-left: if side == left { margin-width - w - dx } else { dx },
  )
  let h = _deixis-measure-margin-height(
    _deixis-margin-box(data + (disable-links: true), geometry, ..args.named()), measure-anchor)
  let anchor-y = data.at("y", default: 0pt) + deixis-utils.resolve-signed-len(data.at("dy", default: 0pt))
  let alignment = data.at("mark-align", default: "top")
  let body-align = if type(alignment) == dictionary { alignment.at("body", default: "top") } else { alignment }
  let body-align = if type(body-align) == _std-alignment { repr(body-align.y) } else { str(body-align) }
  let y = anchor-y - if body-align == "bottom" { h } else if body-align == "horizon" { h / 2 } else { 0pt }
  geometry + (
    frame: frame, layout: if type(layout) == function { "custom" } else { layout },
    side: side, h: h, y: y, anchor-y: anchor-y,
    gap: deixis-utils.resolve-len(data.at("gap", default: 0.5em)),
    mark-align-strictness: data.at("mark-align-strictness", default: "none"),
  )
}

// All three policies produce explicit body tops. The flow policy distributes
// free space by the same weights as a fractional column, without laying it out
// again in a native column whose paragraph spacing could move connector targets.
#let _deixis-pack-margin(notes, frame, layout) = {
  if notes.len() == 0 { return () }
  if layout == "exact" { return notes.map(n => n.y) }
  if layout != "flow" and type(layout) != function {
    return _deixis-rubber-band(notes, frame.top, frame.bottom)
  }
  let weights = ()
  let total-height = 0pt
  let current-y = frame.top
  for (i, n) in notes.enumerate() {
    let gap = if i == 0 { 0pt } else { n.gap }
    let target-y = calc.min(n.y, frame.end)
    let min-y = current-y + gap
    weights.push(calc.max(0pt, target-y - min-y) / 1pt)
    total-height += gap + n.h
    current-y = calc.max(target-y, min-y) + n.h
  }
  weights.push(calc.max(0pt, frame.end - current-y) / 1pt)
  let total-weight = weights.sum()
  if total-weight <= 1e-5 {
    weights.last() = 1.0
    total-weight = 1.0
  }
  let extra-space = calc.max(0pt, frame.end - frame.top - total-height)
  let positions = ()
  current-y = frame.top
  for (i, n) in notes.enumerate() {
    current-y += if i == 0 { 0pt } else { n.gap }
    current-y += weights.at(i) / total-weight * extra-space
    positions.push(current-y)
    current-y += n.h
  }
  positions
}

#let _deixis-finalize-margin(notes, frame, layout) = {
  let result = notes
  for side in (left, right) {
    let indices = range(notes.len()).filter(i => notes.at(i)._margin-placement.side == side)
    let positions = _deixis-pack-margin(indices.map(i => notes.at(i)._margin-placement), frame, layout)
    for (i, y) in indices.zip(positions) {
      result.at(i)._margin-placement.insert("final-y", y)
    }
  }
  result
}

// Only the overflow decision needs a prefix plan. Adaptive packing can move a
// non-strict body upward as far as the frame/preceding body permits; loose
// alignment adds a lower bound and strict alignment keeps its forward top.
// Accumulate that earliest feasible bottom instead of repacking every prefix.
// Final positions still come from the complete, unchanged packing algorithm.
#let _deixis-margin-prefix-bottom(p, frame, layout, forward-bottom, compact-bottom, count) = {
  let gap = if count == 0 { 0pt } else { p.gap }
  let floor = frame.top
  if layout == "adaptive" {
    if p.mark-align-strictness == "strict" {
      floor = calc.max(p.y, forward-bottom + gap)
    } else if p.mark-align-strictness == "loose" {
      floor = calc.max(frame.top, p.anchor-y - p.h)
    }
  }
  calc.max(floor, compact-bottom + gap) + p.h
}

// Routing metadata is assembled once for both placed and outgoing bodies.
#let _deixis-margin-link-data(n) = {
  let data = n.note-data
  let result = (
    mark-page: n.mark-page, mark-block: n.at("mark-block", default: 0), block-idx: n.at("block-idx", default: 0),
    internal-id: data.at("internal-id", default: none), accent: data.at("accent", default: none), layer: data.at("layer", default: "foreground"),
    render-context: data.at("render-context", default: none),
  )
  for (key, fallback) in (
    mark-x: 0pt, mark-y: 0pt, marker-width: 0pt, marker-str: none, text-size: auto,
    has-inline-box: false, mark-type: "inline", reg: none, r-pins: (),
    link: "none", link-stroke: none, link-radius: 0pt, link-marks: "none", link-heads: auto,
    link-render: none, link-gap-marks: none, link-cuts: (), link-crossings: none, link-continuation: auto, link-spill: auto, link-scene: none, link-waypoints: auto, link-ports: auto,
    link-layer: "foreground", link-z-index: 0, routing: none, routing-options: (:),
  ) { result.insert(key, data.at(key, default: fallback)) }
  result
}

// Validate accepted placement, never provisional spill candidates. Reporting is
// metadata-only so the final validator cannot suppress the body being measured.
#let _deixis-margin-overflow-evidence(data, p, frame) = {
  let policy = data.at("overflow", default: "allow")
  assert(policy in ("allow", "error"), message: "deixis: Margin overflow must be allow or error.")
  if policy == "allow" { return [] }
  let horizontal = calc.max(0pt, -p.dx, p.dx + p.w - p.margin-width)
  let vertical = calc.max(0pt, frame.top - p.final-y, p.final-y + p.h - frame.bottom)
  _deixis-metadata((id: data.at("id", default: none), internal-id: data.at("internal-id", default: none),
    page: frame.page, horizontal: horizontal, vertical: vertical, unsupported: false), <deixis-margin-overflow>)
}

#let _deixis-validate-margin-overflow() = {
  for item in query(<deixis-margin-overflow>) {
    let data = item.value
    if _deixis-is-hidden(data) { continue }
    assert(not data.unsupported,
      message: "deixis: overflow: error requires a built-in margin layout. A custom layout owns its output bounds.")
    assert(data.horizontal <= 0.1pt and data.vertical <= 0.1pt,
      message: "deixis: Margin note " + repr(if data.id != none { data.id } else { data.internal-id }) +
        " exceeds its margin frame on physical page " + str(data.page) + ". Horizontal excess: " +
        repr(data.horizontal) + "; vertical excess: " + repr(data.vertical) +
        ". Shorten the body, adjust width/offset, or provide another spillover frame; overflow: allow preserves placement.")
  }
}

#let _deixis-margin-plan-output(layout, prepared, frame, start-x, text-width, current-page, pushed-notes: (), ..args) = {
  let spill-frame = (left: start-x, right: start-x + text-width, top: frame.top, bottom: frame.bottom,
    left-space: frame.l-space, right-space: frame.r-space)
  let formatted = prepared.map(n => {
    let p = n._margin-placement
    _deixis-margin-link-data(n) + (
      side: p.side, attach-x: if p.side == left { start-x - p.dx } else { start-x + text-width + p.dx },
      final-y: p.final-y, h: p.h, w: p.w,
      is-incoming: n.mark-page < current-page, is-outgoing: false,
    )
  })
  let outgoing = if layout == "exact" { () } else { pushed-notes.map(n => {
    _deixis-margin-link-data(n) + (
      side: if n.note-data.at("side", default: right) in ("left", left) { left } else { right },
      attach-x: 0pt, final-y: 0pt, h: 0pt, w: 0pt, is-incoming: false, is-outgoing: true,
    )
  }) }
  let evidence = {
    let connections = _deixis-margin-connections(formatted + outgoing, current-page,
      (left: start-x, right: start-x + text-width), frame.top, frame.bottom,
      spill-frame: spill-frame)
    if deixis-setup-state.get() {
      // Placement publishes numeric geometry; page layers own connection paint.
      for connection in connections {
        [#_deixis-metadata((page: current-page, prepared: connection), <deixis-margin-connection>)]
      }
    } else {
      // Direct layout hooks can still be used without the Deixis page system.
      _deixis-paint-note-connections(connections, current-page).join()
    }
    for n in prepared {
      let p = n._margin-placement
      _deixis-margin-overflow-evidence(n.note-data, p, frame)
      let x = if p.side == left { start-x - p.dx - p.w } else { start-x + text-width + p.dx }
      let identity = n.note-data.at("internal-id", default: none)
      if identity != none {
        let node = _deixis-frame-node("body", current-page,
          _deixis-box-bounds(x, p.final-y, x + p.w, p.final-y + p.h), str(identity)) + (margin-context: (
            side: p.side, page: current-page, frame: spill-frame, scope: if n.note-data.target-id == "page" { none } else { n.note-data.inst-id },
          ))
        [#metadata((identity: str(identity), node: node))<deixis-body-frame>]
      }
    }
  }
  let commands = prepared.map(n => {
    let p = n._margin-placement
    let margin-x = if p.side == left { start-x - frame.l-space } else { start-x + text-width }
    let data = n.note-data
    let geometry = (margin-width: p.margin-width, w: p.w, pad-left: p.pad-left)
    _deixis-paint-command("margin", n.note-data.at("internal-id", default: none),
      () => _deixis-margin-box(data, geometry, ..args.named()), offset: (margin-x, p.final-y),
      priority: data.at("z-index", default: 0))
  })
  (evidence: evidence, commands: commands)
}

#let _deixis-emit-margin-output(output) = {
  place(top + left, output.evidence)
  // Immediate/direct calls keep native order, outside page priority bands.
  _deixis-emit-paint-commands(output.commands.map(c => c + (priority: 0,)), deferred: false)
}

// Immediate bodies and direct public layout calls retain their own compositor.
#let _deixis-paint-margin(..args) = _deixis-emit-margin-output(_deixis-margin-plan-output(..args))

#let _deixis-margin-batch-output(layout, notes, top-bound, bottom-bound, start-x, text-width,
  end-y, left-space, right-space, current-page, min-margin-width: 1in, pushed-notes: (), ..args,
) = {
  if type(layout) == function {
    // Arbitrary callbacks can wrap/decorate/interleave their members. Call once,
    // at real paint time, and retain the whole output as one atomic command.
    let evidence = {
      // Keep the default empty-content contract even when every policy allows.
      []
      for n in notes {
        if n.note-data.at("overflow", default: "allow") == "error" {
          _deixis-metadata((unsupported: true), <deixis-margin-overflow>)
        }
      }
    }
    return (evidence: evidence, commands: (_deixis-paint-command("margin-batch",
      (page: current-page, x: start-x, y: top-bound),
      () => layout(notes, top-bound, bottom-bound, start-x, text-width, end-y,
        left-space, right-space, current-page,
        min-margin-width: min-margin-width, pushed-notes: pushed-notes, ..args.named()),
      members: notes.map(n => n.note-data.at("internal-id", default: none)),
      priority: _deixis-group-z-index("custom margin batch", notes.map(n => n.note-data))),))
  }
  assert(layout in ("exact", "flow", "adaptive"),
    message: "deixis: margin-layout='" + repr(layout) + "' not supported.")
  let frame = _deixis-margin-frame(top-bound, bottom-bound, end-y, left-space, right-space,
    current-page, deixis-utils.get-page-binding())
  let planned = notes.all(n => {
    let p = n.at("_margin-placement", default: none)
    p != none and p.layout == layout and p.frame == frame
  })
  let prepared = notes
  // Direct public calls and custom callbacks can still request any built-in
  // layout. Only plans for this policy and physical frame can be reused.
  if not planned {
    prepared = ()
    let l-bottom = frame.top
    let r-bottom = frame.top
    let l-count = 0
    let r-count = 0
    let pref-dir = deixis-utils.text-direction(text.dir, text.lang)
    for n in notes {
      let side = _deixis-margin-side(n.note-data, frame, pref-dir, layout,
        deixis-utils.resolve-len(min-margin-width), l-bottom, r-bottom)
      let p = _deixis-prepare-margin(n.note-data, side, frame, layout, ..args.named())
      prepared.push(n + (_margin-placement: p))
      if side == left {
        l-bottom = calc.max(p.y, l-bottom + if l-count == 0 { 0pt } else { p.gap }) + p.h
        l-count += 1
      } else {
        r-bottom = calc.max(p.y, r-bottom + if r-count == 0 { 0pt } else { p.gap }) + p.h
        r-count += 1
      }
    }
    prepared = _deixis-finalize-margin(prepared, frame, layout)
  }

  _deixis-margin-plan-output(layout, prepared, frame, start-x, text-width, current-page,
    pushed-notes: pushed-notes, ..args.named())
}

#let _deixis-margin-layout(..args) = context {
  _deixis-emit-margin-output(_deixis-margin-batch-output(..args))
}

/// A lightweight margin layout engine that places each note exactly aligned with its marker.
/// It intentionally ignores collisions, gaps, and spillovers.
#let deixis-margin-note-exact-layout(
  notes, top-bound, bottom-bound, start-x, text-width, end-y, left-space, right-space, current-page,
  min-margin-width: 1in, pushed-notes: (), ..args,
) = _deixis-margin-layout("exact", notes, top-bound, bottom-bound, start-x, text-width, end-y,
  left-space, right-space, current-page, min-margin-width: min-margin-width, pushed-notes: pushed-notes, ..args.named())

/// A placement-based margin layout engine that uses the rubber band algorithm under the hood.
#let deixis-margin-note-adaptive-layout(
  notes, top-bound, bottom-bound, start-x, text-width, end-y, left-space, right-space, current-page,
  min-margin-width: 1in, pushed-notes: (), ..args,
) = _deixis-margin-layout("adaptive", notes, top-bound, bottom-bound, start-x, text-width, end-y,
  left-space, right-space, current-page, min-margin-width: min-margin-width, pushed-notes: pushed-notes, ..args.named())

/// A flow-based margin layout engine that distributes free space toward marker positions.
#let deixis-margin-note-flow-layout(
  notes, top-bound, bottom-bound, start-x, text-width, end-y, left-space, right-space, current-page,
  min-margin-width: 1in, pushed-notes: (), ..args,
) = _deixis-margin-layout("flow", notes, top-bound, bottom-bound, start-x, text-width, end-y,
  left-space, right-space, current-page, min-margin-width: min-margin-width, pushed-notes: pushed-notes, ..args.named())

// Frames are in physical-page/top order. Find the last frame whose start
// precedes the anchor, treating the first block of a page as owning its top
// margin too. Index zero also owns anchors before the first available frame.
#let _deixis-margin-start-block(mark-page, natural-y, blocks-info) = {
  let low = 1
  let high = blocks-info.len()
  while low < high {
    let mid = calc.floor((low + high) / 2)
    let current = blocks-info.at(mid)
    let previous = blocks-info.at(mid - 1)
    if mark-page > current.page or (mark-page == current.page
      and (previous.page < current.page or natural-y >= current.top - 1pt)) {
      low = mid + 1
    } else {
      high = mid
    }
  }
  low - 1
}

#let _deixis-predict-cascade(notes, blocks-info, pref-dir, margin-layout,
  min-margin-width: 1in, cascade-breaker: true, measure-anchors: (:), ..args,
) = {
  if blocks-info.len() == 0 { return () }
  let buckets = range(blocks-info.len()).map(_ => ())
  let by-instance = (:)
  for (i, frame) in blocks-info.enumerate() {
    let id = frame.at("inst-id", default: none)
    if id == none { continue }
    if id not in by-instance { by-instance.insert(id, ()) }
    by-instance.at(id).push(frame + (cascade-index: i))
  }
  for n in notes {
    let data = n.note-data
    let dy = deixis-utils.resolve-signed-len(data.at("dy", default: 0pt))
    let natural-y = n.mark-y + dy
    let owned = by-instance.at(data.at("inst-id", default: ""), default: ())
    let start = if owned.len() > 0 {
      owned.at(_deixis-margin-start-block(n.mark-page, natural-y, owned)).cascade-index
    } else { _deixis-margin-start-block(n.mark-page, natural-y, blocks-info) }
    let block = blocks-info.at(start)
    data += (mark-x: n.mark-x, mark-y: n.mark-y, x: n.mark-x, y: n.mark-y,
      marker-width: n.at("marker-width", default: data.at("marker-width", default: 0pt)),
      reg: n.at("reg", default: none), r-pins: n.at("r-pins", default: ()))
    let exact = data.at("margin-layout", default: margin-layout) == "exact"
    if n.mark-page < block.page or (not exact and n.mark-page == block.page and natural-y < block.top) {
      data.y = block.top - dy
    } else if n.mark-page > block.page or (not exact and n.mark-page == block.page and natural-y > block.bottom) {
      data.y = block.bottom - dy
    }
    buckets.at(start).push((note-data: data, mark-block: start, mark-page: n.mark-page))
  }

  let result = ()
  let queue = ()
  for (block-id, block) in blocks-info.enumerate() {
    let current = queue + buckets.at(block-id)
    queue = ()
    if current.len() == 0 { continue }
    let first = current.first().note-data
    let layout = first.at("margin-layout", default: margin-layout)
    let req-space = deixis-utils.resolve-len(first.at("min-margin-width", default: min-margin-width))
    let frame = _deixis-margin-frame(block.top, block.bottom, block.at("end", default: block.bottom),
      block.l-space, block.r-space, block.page,
      block.at("binding", default: if pref-dir == rtl { right } else { left }))
    let l-bottom = frame.top
    let r-bottom = frame.top
    let left-notes = ()
    let right-notes = ()
    let l-compact = frame.top
    let r-compact = frame.top
    let overflowed-l = false
    let overflowed-r = false
    let accepted = ()
    for n in current {
      let data = n.note-data
      let side = _deixis-margin-side(data, frame, pref-dir, layout, req-space, l-bottom, r-bottom,
        overflowed-l: overflowed-l, overflowed-r: overflowed-r)
      let p = _deixis-prepare-margin(data, side, frame, layout, ..args.named(),
        measure-anchor: measure-anchors.at(str(data.at("internal-id", default: "")), default: none))
      let previous = if side == left { left-notes } else { right-notes }
      let compact = _deixis-margin-prefix-bottom(p, frame, layout,
        if side == left { l-bottom } else { r-bottom },
        if side == left { l-compact } else { r-compact }, previous.len())
      let physical-overflow = false
      if layout != "exact" {
        if layout == "adaptive" or (layout == "flow" and frame.end <= frame.bottom) {
          physical-overflow = compact > frame.bottom + 0.1pt
        } else {
          let positions = _deixis-pack-margin(previous + (p,), frame, layout)
          physical-overflow = positions.last() + p.h > frame.bottom + 0.1pt
        }
      }
      if cascade-breaker and physical-overflow and previous.len() == 0 and p.h > frame.bottom - frame.top - 1pt {
        physical-overflow = false
      }
      let spill = data.at("spillover", default: true)
      let forced-overflow = if side == left { overflowed-l } else { overflowed-r }
      if spill and (physical-overflow or forced-overflow) and block-id < blocks-info.len() - 1 {
        if side == left { overflowed-l = true } else { overflowed-r = true }
        data.y = blocks-info.at(block-id + 1).top - deixis-utils.resolve-signed-len(data.at("dy", default: 0pt))
        queue.push(n + (note-data: data))
      } else {
        data.side = if side == left { "left" } else { "right" }
        accepted.push(n + (note-data: data, block-idx: block-id, _margin-layout: layout, _margin-placement: p))
        let gap = if previous.len() == 0 { 0pt } else { p.gap }
        if side == left {
          left-notes.push(p)
          l-compact = compact
          l-bottom = calc.max(p.y, l-bottom + gap) + p.h
        } else {
          right-notes.push(p)
          r-compact = compact
          r-bottom = calc.max(p.y, r-bottom + gap) + p.h
        }
      }
    }
    result += _deixis-finalize-margin(accepted, frame, layout)
  }
  result
}
