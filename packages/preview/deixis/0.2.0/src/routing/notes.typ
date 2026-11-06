#import "../layout/geometry.typ": _deixis-region-bounds, _deixis-inline-bounds, _deixis-box-bounds
#import "path.typ": *
#import "spec.typ": _deixis-route-name
#import "connections.typ": *
#import "../core/query.typ": _deixis-pins-for, _deixis-pin-index
#import "../render/body.typ": _deixis-inherited-content
#import "../core/utils.typ" as deixis-utils
#import "pins.typ": _deixis-resolve-edge-pins, _deixis-has-routing-pins
#import "../core/visibility.typ": _deixis-is-hidden

/// --------------------

#let _deixis-margin-connections(
  all-notes,
  current-page,
  text-bounds,
  top-bound,
  bottom-bound,
  spill-frame: none,
) = {
  let connections = ()

  let track-drops = (:)
  let track-verticals = (:)

  let left-body-notes = all-notes.filter(n => n.side in (left, "left") and not n.at("is-outgoing", default: false))
  let min-gap-l = 20.0
  if left-body-notes.len() > 0 {
    min-gap-l = calc.min(..left-body-notes.map(n => {
      let nx = n.at("attach-x", default: 0pt)
      return calc.max(0.0, (text-bounds.left - nx) / 1pt)
    }))
  }
  let max-v-lines-l = calc.max(1, calc.floor((min-gap-l - 4.0) / 2.5))

  let right-body-notes = all-notes.filter(n => n.side not in (left, "left") and not n.at("is-outgoing", default: false))
  let min-gap-r = 20.0
  if right-body-notes.len() > 0 {
    min-gap-r = calc.min(..right-body-notes.map(n => {
      let nx = n.at("attach-x", default: 0pt)
      return calc.max(0.0, (nx - text-bounds.right) / 1pt)
    }))
  }
  let max-v-lines-r = calc.max(1, calc.floor((min-gap-r - 4.0) / 2.5))

  for n in all-notes.sorted(key: x => x.at("mark-x", default: 0pt)) {
    let is-incoming = n.at("is-incoming", default: false)
    let is-outgoing = n.at("is-outgoing", default: false)

    if not is-incoming and n.at("mark-page", default: current-page) != current-page { continue }

    let link = n.at("link", default: "none")
    if link in (none, false, "none") { continue }

    let link-waypoints = n.at("link-waypoints", default: auto)

    let is-left = n.side in (left, "left")
    let bound-x = if is-left { text-bounds.left } else { text-bounds.right }

    let marker-width = n.at("marker-width", default: 0pt)
    let mark-x = n.at("mark-x", default: 0pt)
    let mark-y = n.at("mark-y", default: 0pt)
    let mark-center-x = mark-x + (marker-width / 2)

    let text-size = n.at("text-size", default: auto)
    let t-val = deixis-utils.resolve-len(if text-size != auto and type(text-size) == length { text-size } else { 11pt })

    let has-inline-box = n.at("has-inline-box", default: false)

    let mark-bounds = _deixis-inline-bounds(mark-x, mark-y, marker-width, t-val, has-inline-box: has-inline-box)
    let box-top = mark-bounds.top
    let box-bottom = mark-bounds.bottom

    let n-top = n.at("final-y", default: 0pt)
    let n-h = n.at("h", default: 0pt)
    let n-w = n.at("w", default: 0pt)
    let n-bottom = n-top + n-h
    let n-x = n.at("attach-x", default: 0pt)

    let safe-pad = calc.min(4.0, (n-h / 1pt) / 2.0)
    let clamp-min = (n-top + (safe-pad * 1pt)) / 1pt
    let clamp-max = (n-bottom - (safe-pad * 1pt)) / 1pt

    clamp-max = calc.max(clamp-min, clamp-max)

    let safe-wps = if link-waypoints != none and type(link-waypoints) == array {
      link-waypoints.filter(x => type(x) == array and x.len() >= 2)
    } else { () }

    let m-y-attach = 0pt
    let n-attach-y = 0pt
    let ideal-y = calc.clamp(mark-y / 1pt, clamp-min, clamp-max) * 1pt

    if is-incoming {
      n-attach-y = clamp-min * 1pt
      m-y-attach = top-bound
    } else if is-outgoing {
      m-y-attach = box-bottom
      n-attach-y = bottom-bound
    } else {
      let resolve-peek-y(y-spec, base-y, target-abs-y) = {
        if type(y-spec) == length { return base-y + y-spec }
        if type(y-spec) == relative { return base-y + y-spec.length }
        if type(y-spec) == ratio { return base-y } // Ignored for pre-flight
        if type(y-spec) == str {
          if "body" in y-spec or "target" in y-spec or "end" in y-spec { return target-abs-y }
          if "mark" in y-spec or "source" in y-spec or "start" in y-spec { return base-y }
        }
        return base-y
      }

      let goes-up = ideal-y < mark-y
      if safe-wps.len() > 0 {
        let first-y = safe-wps.first().at(1)
        if type(first-y) == length { goes-up = first-y < 0pt } else if type(first-y) == relative {
          goes-up = first-y.length < 0pt
        }
      }

      m-y-attach = if goes-up { box-top } else { box-bottom }

      let last-source-y = m-y-attach
      if safe-wps.len() > 0 {
        last-source-y = resolve-peek-y(safe-wps.last().at(1), m-y-attach, ideal-y)
      }

      n-attach-y = calc.clamp(last-source-y / 1pt, clamp-min, clamp-max) * 1pt
    }

    // --- HORIZONTAL ANTI-OVERLAP ---

    let route-down = false
    if is-outgoing {
      route-down = true
    } else if is-incoming {
      route-down = false
    } else {
      route-down = (m-y-attach > mark-y)
    }

    let dir-str = if route-down { "d" } else { "u" }
    let line-key = str(calc.round(mark-y / 1pt)) + "-" + dir-str
    let h-count = track-drops.at(line-key, default: 0)
    track-drops.insert(line-key, h-count + 1)

    let h-cycle = calc.rem(h-count, 4)
    let step-size = t-val * 0.04
    let drop-mag = 0pt

    let base-drop = t-val * 0.05
    let max-drop = t-val * 0.25
    drop-mag = base-drop + (h-cycle * step-size)
    drop-mag = calc.min(drop-mag / 1pt, max-drop / 1pt) * 1pt

    let drop-y = m-y-attach + (if route-down { drop-mag } else { -drop-mag })

    // --- VERTICAL ANTI-OVERLAP ---
    let side-key = if is-left { "l" } else { "r" }
    let v-count = track-verticals.at(side-key, default: 0)
    track-verticals.insert(side-key, v-count + 1)

    let max-v = if is-left { max-v-lines-l } else { max-v-lines-r }
    let v-cycle = calc.rem(v-count, max-v)
    let turn-shift = 2.0 + (v-cycle * 2.5)

    let turn-x = if is-left {
      bound-x - turn-shift * 1pt
    } else {
      bound-x + turn-shift * 1pt
    }

    // Marker decoration is painted separately from the connection's geometry.
    let highlight = if is-incoming { none } else { (
      x: mark-x, y: mark-y, width: marker-width, marker: n.marker-str,
      text-size: t-val,
      has-inline-box: has-inline-box,
      mark-type: n.at("mark-type", default: "inline"),
    ) }

    // anchors & synthetic waypoints
    let mark-type = n.at("mark-type", default: "inline")
    let S-candidates = ()
    let synth-wps = ()

    let c-ports = n.at("link-ports", default: auto)
    let override-mark = if type(c-ports) == dictionary and "mark" in c-ports { c-ports.mark } else { auto }
    if type(override-mark) == dictionary { override-mark = override-mark.at("side", default: auto) }

    if mark-type == "region" and n.r-pins.len() > 0 {
      let r-pins = n.r-pins
      let reg = n.reg
      let bounds = _deixis-region-bounds(r-pins, current-page, padding: reg.styles.at("padding", default: 0pt))
      mark-bounds = bounds
      let min-x = bounds.left
      let max-x = bounds.right
      let min-y = bounds.top
      let max-y = bounds.bottom

      let sliding-y = calc.clamp(n-attach-y / 1pt, min-y / 1pt, max-y / 1pt) * 1pt
      if sliding-y < min-y { sliding-y = (min-y + max-y) / 2.0 }

      let r-cx = (min-x + max-x) / 2.0
      let r-cy = (min-y + max-y) / 2.0

      // user-provided ports
      if override-mark == "top" {
        S-candidates = ((x: r-cx, y: min-y, dir: "vertical", id: "top"),)
      } else if override-mark == "bottom" {
        S-candidates = ((x: r-cx, y: max-y, dir: "vertical", id: "bottom"),)
      } else if override-mark == "left" {
        S-candidates = ((x: min-x, y: r-cy, dir: "horizontal", id: "left"),)
      } else if override-mark == "right" {
        S-candidates = ((x: max-x, y: r-cy, dir: "horizontal", id: "right"),)
      } else {
        // Fallback to distance-minimizing sliding port
        let out-x = if is-left { min-x } else { max-x }
        let out-id = if is-left { "left" } else { "right" }
        S-candidates = ((x: out-x, y: sliding-y, dir: "horizontal", id: out-id,
          scene-range: (axis: 1, min: min-y, max: max-y)),)
      }

      let S-pt = S-candidates.first()
      let out-x = S-pt.x
      let out-y = S-pt.y

      // prevent backwards folding if user forces a port that points across the text bounds
      if S-pt.id == "left" and min-x < turn-x {
        turn-x = min-x - turn-shift * 1pt
      } else if S-pt.id == "right" and max-x > turn-x {
        turn-x = max-x + turn-shift * 1pt
      }

      if link-waypoints == auto and _deixis-route-name(link) in ("straight-line", "right-angle", "chamfer", "curve", "ccr", "ucr", "hobby") {
        if S-pt.dir == "vertical" {
          // if port is top/bottom, it must exit vertically into the drop channel first
          if is-outgoing {
            synth-wps = (
              (0pt, drop-y - out-y),
              (turn-x - out-x, 0pt),
              (0pt, bottom-bound - drop-y),
              deixis-waypoint-split,
            )
          } else if is-incoming {
            synth-wps = (deixis-waypoint-split, (0pt, n-attach-y - top-bound))
          } else {
            synth-wps = ((0pt, drop-y - out-y), (turn-x - out-x, 0pt), (0pt, n-attach-y - drop-y))
          }
        } else {
          // horizontal exit
          synth-wps = (
            (turn-x - out-x, 0pt),
            (0pt, n-attach-y - out-y),
          )
        }
      } else {
        if is-outgoing or is-incoming { synth-wps = (deixis-waypoint-split,) }
      }
    } else {
      // inline & phantom mark
      let use-bottom = if override-mark == "bottom" { true } else if override-mark == "top" { false } else {
        route-down
      }
      let out-id = if use-bottom { "bottom" } else { "top" }
      let out-y = if use-bottom { box-bottom } else { box-top }

      S-candidates = (
        (x: mark-center-x, y: out-y, dir: "vertical", id: out-id),
      )

      if link-waypoints == auto and _deixis-route-name(link) in ("straight-line", "right-angle", "chamfer", "curve", "ccr", "ucr", "hobby") {
        if is-outgoing {
          synth-wps = (
            (0pt, drop-y - out-y),
            (turn-x - mark-center-x, 0pt),
            (0pt, bottom-bound - drop-y),
            deixis-waypoint-split,
          )
        } else if is-incoming {
          synth-wps = (deixis-waypoint-split, (0pt, n-attach-y - top-bound))
        } else {
          synth-wps = ((0pt, drop-y - out-y), (turn-x - mark-center-x, 0pt), (0pt, n-attach-y - drop-y))
        }
      } else {
        if is-outgoing or is-incoming { synth-wps = (deixis-waypoint-split,) }
      }
    }

    let D-candidates = (
      (x: n-x, y: n-attach-y, dir: "horizontal", id: if is-left { "right" } else { "left" },
        scene-range: (axis: 1, min: clamp-min * 1pt, max: clamp-max * 1pt)),
    )

    let S-page = current-page
    let E-page = current-page
    if is-outgoing { E-page = current-page + 1 } else if is-incoming { S-page = current-page - 1 }

    let extra = (
      bound-dx: bound-x - mark-center-x,
      turn-dx: turn-x - mark-center-x,
      drop-y: drop-y - m-y-attach,
      side: n.side, accent: n.at("accent", default: none),
    )

    let identity = n.at("internal-id", default: none)
    let edge = _deixis-prepared-connection(
      _deixis-connection-node("mark", S-page, S-candidates, bounds: mark-bounds,
        identity: identity, virtual: is-incoming),
      _deixis-connection-node("body", E-page, D-candidates,
        bounds: _deixis-box-bounds(if is-left { n-x - n-w } else { n-x }, n-top,
          if is-left { n-x } else { n-x + n-w }, n-bottom),
        identity: identity, virtual: is-outgoing) + (margin-context: (side: n.side, scope: none)
          + if spill-frame == none { (:) } else { (frame: spill-frame) }),
      _deixis-connection-options(n),
      adapter: "margin", layer: n.at("link-layer", default: "foreground"),
      identity: if identity == none { none } else { (kind: "note", annotation: str(identity)) },
      split-default: "target",
      turn-x: turn-x,
      synthetic-waypoints: if n.at("routing", default: none) == none { synth-wps } else { none },
      routing-context: extra,
    )
    connections.push((edge: edge, highlight: highlight, render-context: n.at("render-context", default: none),
      identity: identity, routing: n.at("routing", default: none)))
  }
  connections
}

/// --------------------
/// Inset endpoint adapter
/// --------------------

#let _deixis-inset-connection(data, anchors, options) = {
  let uid = str(data.internal-id)
  let mark = anchors.regions.at(uid, default: anchors.marks.at(uid, default: none))
  if _deixis-is-hidden(data) or (mark != none and _deixis-is-hidden(mark.value)) { return none }
  let start-elems = query(selector(data.mark-lbl))
  let d-top-elems = query(selector(data.at("dest-top-lbl", default: data.body-lbl)))
  // Destination probes may be absent in an intermediate layout pass. Do not
  // measure/replay the body or manufacture geometry from a PDF backlink origin.
  if start-elems.len() == 0 or d-top-elems.len() == 0 { return none }

  let internal-id = data.internal-id
  let mark-type = data.at("mark-type", default: "inline")
  let S-page = start-elems.last().location().page()
  let E-page = d-top-elems.last().location().page()
  let S = start-elems.last().location().position()
  let D-top = d-top-elems.last().location().position()
  let region = anchors.regions.at(str(internal-id), default: none)
  let reg = if region == none { none } else { region.value }
  let r-pins = if region == none { () } else { _deixis-pins-for(anchors.pin-index, reg.pins) }
  if r-pins.len() > 0 {
    let first-page = calc.min(..r-pins.map(p => p.location().page()))
    let last-page = calc.max(..r-pins.map(p => p.location().page()))
    S-page = calc.clamp(E-page, first-page, last-page)
  }

  let highlight = none
  let source-candidates = ()
  let mark-bounds = auto
  let m-cx = S.x
  let mark-y = S.y

  // cross-page bounding boxes
  if mark-type == "region" and r-pins.len() > 0 {
    let bounds = _deixis-region-bounds(r-pins, S-page, padding: reg.styles.at("padding", default: 0pt))
    mark-bounds = bounds
    let min-x = bounds.left
    let max-x = bounds.right
    let min-y = bounds.top
    let max-y = bounds.bottom

    m-cx = (min-x + max-x) / 2.0
    mark-y = min-y

    source-candidates = (
      (x: m-cx, y: min-y, dir: "vertical", id: "top"),
      (x: m-cx, y: max-y, dir: "vertical", id: "bottom"),
      (x: min-x, y: (min-y + max-y) / 2.0, dir: "horizontal", id: "left"),
      (x: max-x, y: (min-y + max-y) / 2.0, dir: "horizontal", id: "right"),
    )
  }

  // inline marker fallback
  if source-candidates.len() == 0 {
    let mark = anchors.marks.at(str(internal-id), default: none)

    let marker-width = data.at("marker-width", default: 0pt)
    let text-size = data.at("text-size", default: 11pt)

    if mark != none {
      let mm-val = mark.value
      marker-width = mm-val.at("marker-width", default: marker-width)
      text-size = mm-val.at("text-size", default: text-size)
    }

    let t-val = if type(text-size) == length { text-size } else { 11pt }
    let has-inline-box = data.at("has-inline-box", default: false)

    let mark-x = S.x
    mark-y = S.y
    m-cx = S.x + (marker-width / 2)

    if mark-type != "region" {
      highlight = (
        x: mark-x, y: mark-y, width: marker-width, marker: data.marker-str,
        text-size: t-val,
        has-inline-box: has-inline-box,
        mark-type: mark-type,
      )
    }

    mark-bounds = _deixis-inline-bounds(mark-x, mark-y, marker-width, t-val, has-inline-box: has-inline-box)
    let box-top = mark-bounds.top
    let box-bottom = mark-bounds.bottom
    let box-horizon = mark-bounds.center-y

    source-candidates = (
      (x: m-cx, y: box-top, dir: "vertical", id: "top"),
      (x: m-cx, y: box-bottom, dir: "vertical", id: "bottom"),
    )
    if data.at("marker-width", default: 0pt) == 0pt {
      source-candidates.push(
        (x: mark-x + marker-width + 1.5pt, y: box-horizon, dir: "horizontal", id: "right"),
      )
      source-candidates.push(
        (x: mark-x - 1.5pt, y: box-horizon, dir: "horizontal", id: "left"),
      )
    } else if data.at("marker-position", default: none) in (right, "right") {
      source-candidates.push(
        (x: mark-x + marker-width + 1.5pt, y: box-horizon, dir: "horizontal", id: "right"),
      )
    } else if data.at("marker-position", default: none) in (left, "left") {
      source-candidates.push(
        (x: mark-x - 1.5pt, y: box-horizon, dir: "horizontal", id: "left"),
      )
    }
  }

  let d-bot-elems = query(selector(data.at("dest-bot-lbl", default: data.body-lbl)))
  let d-left-elems = query(selector(data.at("dest-left-lbl", default: data.body-lbl)))
  let d-right-elems = query(selector(data.at("dest-right-lbl", default: data.body-lbl)))

  let D-bot = if d-bot-elems.len() > 0 { d-bot-elems.last().location().position() } else { D-top }
  let D-left = if d-left-elems.len() > 0 { d-left-elems.last().location().position() } else { D-top }
  let D-right = if d-right-elems.len() > 0 { d-right-elems.last().location().position() } else { D-top }

  let dest-candidates = (
    (x: D-top.x, y: D-top.y, dir: "vertical", id: "top"),
    (x: D-bot.x, y: D-bot.y, dir: "vertical", id: "bottom"),
    (x: D-left.x, y: D-left.y, dir: "horizontal", id: "left"),
    (x: D-right.x, y: D-right.y, dir: "horizontal", id: "right"),
  )

  let edge = _deixis-prepared-connection(
    _deixis-connection-node("mark", S-page, source-candidates, bounds: mark-bounds, identity: internal-id),
    _deixis-connection-node("body", E-page, dest-candidates, identity: internal-id),
    options, routing-context: (accent: data.at("accent", default: none)),
    layer: data.at("link-layer", default: "foreground"),
    identity: (kind: "note", annotation: str(internal-id)),
  )
  (edge: edge, highlight: highlight, render-context: data.at("render-context", default: none),
    identity: internal-id, routing: data.at("routing", default: none))
}

#let _deixis-paint-connection-highlight(h, stroke) = {
  if h != none {
    let highlight = _deixis-draw-marker-highlight(h.x, h.y, h.width, h.marker,
      stroke: stroke, text-size: h.text-size,
      has-inline-box: h.has-inline-box, mark-type: h.mark-type)
    if highlight != none { highlight }
  }
}

#let _deixis-paint-note-connection(prepared, current-page) = {
  let edge = prepared.edge
  let paths = if current-page == edge.source.page {
    (_deixis-paint-connection-highlight(prepared.highlight, edge.options.stroke),)
  } else { () }
  paths + _deixis-route-connection(edge, current-page)
}

// Shared painting boundary. Adapter preparation never renders a live note body;
// decorations and routes are realized only here, in the adapter's active layer.
#let _deixis-paint-note-connections(connections, current-page, pin-index: auto) = {
  let paths = ()
  if pin-index == auto and connections.any(c => _deixis-has-routing-pins(c.edge.options)) {
    pin-index = _deixis-pin-index()
  }
  for prepared in connections {
    let edge = prepared.edge
    if current-page != edge.source.page and current-page != edge.target.page { continue }
    if edge.options.route in (none, false, "none") { continue }
    if prepared.at("render-context", default: none) != none {
      paths.push(_deixis-inherited-content(prepared,
        context {
          let resolved = _deixis-resolve-edge-pins(edge, index: pin-index)
          if resolved != none { _deixis-paint-note-connection(prepared + (edge: resolved), current-page).join() }
        }))
    } else {
      let resolved = _deixis-resolve-edge-pins(edge, index: pin-index)
      if resolved != none { paths += _deixis-paint-note-connection(prepared + (edge: resolved), current-page) }
    }
  }
  paths
}
