#import "geometry.typ": _deixis-region-bounds, _deixis-inline-bounds
#import "../core/state.typ": *
#import "../core/query.typ": _deixis-pin-index, _deixis-pins-for
#import "../core/utils.typ" as deixis-utils
#import "../core/native.typ": *

// Capture the declaration's stable location, then resolve anchors and the real
// native place origin together. Capturing provisional numeric coordinates in
// the inner context changes its identity and delays downstream route evidence.
#let _deixis-place-anchored(
  body,
  dx: 0pt,
  dy: 0pt,
  anchor: bottom + right,
  internal-id: none,
  pin: none,
  pin-page: none,
  body-size: auto,
) = {
  let declaration = here()
  place(top + left, context {
    let cur-pos = declaration.position()
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

    let r-pins = ()
    let reg-val = none
    let pin-index = _deixis-pin-index()

    if pin != none {
      let pin-arr = if type(pin) == array { pin } else { (pin,) }
      r-pins = _deixis-pins-for(pin-index, pin-arr, page: pin-page)
    } else if internal-id != none {
      let region-elems = query(<deixis-region-mark>).filter(r => (
        r.value.internal-id != none and str(r.value.internal-id) == str(internal-id)
      ))
      if region-elems.len() > 0 {
        reg-val = region-elems.first().value
        r-pins = _deixis-pins-for(pin-index, reg-val.pins)
      }
    }

    if r-pins.len() > 0 {
      let bounds = _deixis-region-bounds(r-pins, declaration.page(),
        padding: if reg-val == none { 0pt } else { reg-val.styles.at("padding", default: 0pt) })
      let min-x = bounds.left
      let max-x = bounds.right
      let min-y = bounds.top
      let max-y = bounds.bottom

      target-x = max-x
      if in-left { target-x = min-x } else if in-center { target-x = (min-x + max-x) / 2.0 }

      target-y = max-y
      if in-top { target-y = min-y } else if in-horizon { target-y = (min-y + max-y) / 2.0 }
    } else if internal-id != none {
      let mark-lbl = _std-label("deixis-mark-" + str(internal-id))
      let elems = query(selector(mark-lbl))
      if elems.len() > 0 {
        let el = elems.first()
        let ex = el.location().position().x
        let ey = el.location().position().y

        let marker-width = 0pt
        let marker-height = 11pt
        let has-inline-box = false
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
          has-inline-box = mm-val.at("has-inline-box", default: false)
          let ts = mm-val.at("text-size", default: 11pt)
          marker-height = if type(ts) == length { ts } else { 11pt }
        }

        let bounds = _deixis-inline-bounds(ex, ey, marker-width, marker-height, has-inline-box: has-inline-box)
        let min-x = bounds.left
        let max-x = bounds.right
        let min-y = bounds.top
        let max-y = bounds.bottom

        target-x = max-x
        if in-left { target-x = min-x } else if in-center { target-x = (min-x + max-x) / 2.0 }

        target-y = max-y
        if in-top { target-y = min-y } else if in-horizon { target-y = (min-y + max-y) / 2.0 }
      }
    }

    let size = if body-size == auto { measure(body) } else { body-size }
    let b-right = a-body in (right, top + right, horizon + right, bottom + right)
    let b-center = a-body in (center, top + center, horizon + center, bottom + center)
    let b-bottom = a-body in (bottom, bottom + left, bottom + center, bottom + right)
    let b-horizon = a-body in (horizon, horizon + left, horizon + center, horizon + right)
    let body-x = if b-right { size.width } else if b-center { size.width / 2 } else { 0pt }
    let body-y = if b-bottom { size.height } else if b-horizon { size.height / 2 } else { 0pt }
    // Native place aligns to the containing block, which can start above the call
    // site. Read that actual origin inside place before converting page coordinates.
    let origin = here().position()
    place(top + left, dx: target-x - origin.x + dx - body-x,
      dy: target-y - origin.y + dy - body-y, body)
  })
}

/// Places content relative to selected pin bounds, or the call site when no pin
/// matches. Pin accepts a name, a `(name:, scope:, select:, page:)` target, or an
/// array of either. Names combine all matches; records default to unique.
/// `anchor` selects the same point on the bounds and body, or accepts separate
/// `(target:, body:)` alignments. Offsets apply after alignment, on the call's page.
#let deixis-place-anchored(
  body, dx: 0pt, dy: 0pt, anchor: bottom + right, pin: none, body-size: auto,
) = context _deixis-place-anchored(body, dx: dx, dy: dy, anchor: anchor,
  pin: pin, body-size: body-size)

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

    let size = deixis-utils.get-page-size(here().page())
    let p-w = size.width
    let p-h = size.height

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
