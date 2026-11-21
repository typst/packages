// Reusable process / cycle diagram: a central ring joined to icon cards on both sides.
// Import with:  #import "process.typ": process
//
// Requires the "Font Awesome 7 Free" font installed for the icons.
//
//   #process(
//     (
//       ("\u{f02d}", "1. Review and selection of existing methods."),  // book
//       ("\u{f51e}", "2. Data collection."),                          // coins
//       ("\u{f83e}", "3. Analysis of signal patterns."),              // wave-square
//       ("\u{f023}", "4. Development of the authentication model."),   // lock
//       ("\u{f46c}", "5. Evaluation and validation of the system."),   // clipboard-check
//       ("\u{f080}", "6. Documentation and dissemination of results."),// chart-bar
//     ),
//   )
//
// Items: up to 6 tuples (icon, label[, color]). The first three render on the left, the
// rest on the right (mirrored). The icon is any Font Awesome codepoint, or content.
#import "common.typ": _canvas, _card, _disc, _dot, _items, _lens, _on, _put, _tallest, _theme, _txt
#import "helpers.typ": icon

#let process(
  items,
  core: auto,          // content inside the ring; auto: a heartbeat icon in the ring's colour
  item-width: 12em,
  item-height: 4.4em,  // minimum card height; the icon badge is as tall as the card
  core-radius: 4.4em,
  ring: auto,          // ring colour; auto: the palette's red
  text-size: 1em,
  width: auto,
  theme: (:),
  ..style,
) = layout(area => {
  let t = _theme("process", theme, style)
  // an item without a colour takes the accent: tab, connector and ring dot use it, the badge a lighter tint
  let items = _items("process", items, (t.accent,), fields: ("icon", "label"), max: 6, cycle: false)
  let (box-w, box-h, r, size, em) = _lens("process", item-width: item-width, item-height: item-height,
    core-radius: core-radius, text-size: text-size, em: 1em).values()
  let ring = if ring == auto { t.palette.at(3) } else { ring }
  let ink = _on(t, t.panel)
  let labels = items.map(it => _txt(it.label, ink, size, weight: auto))
  // every card takes the tallest label's height (item-height is the minimum) and the badge
  // is as tall as the card.  A taller badge leaves the label less width, which may wrap it
  // further, so the height is settled in a few rounds.
  let card-h = box-h
  for _ in range(4) { card-h = calc.max(card-h, 1.6 * em + _tallest(labels, box-w - card-h / 2 - 1.5 * em)) }
  let pad-icon = card-h / 2 + 0.5 * em   // clear the half of the badge that sits inside
  let (lefts, rights) = (items.slice(0, calc.min(3, items.len())), items.slice(calc.min(3, items.len())))
  let pitch = card-h + 1.2 * em
  // the rows of a side are centred on the ring; y points up from it
  let row-y(i, count) = ((count - 1) / 2 - i) * pitch
  let inner = r + 3.2 * em     // box inner edge (where the tab + line start)
  let elbow-x = r + 2 * em
  let bx = inner + box-w / 2   // box centre x
  let ring-thickness = 0.45 * em

  // one item: label card with a tab on its inner edge + the overlapping icon badge
  let node(it, label, mirror) = {
    let badge = color.mix((it.fill, 55%), (t.surface, 45%))
    let glyph = if type(it.icon) == str { icon(it.icon, fill: _on(t, badge), size: card-h * 0.42) } else { it.icon }
    box(width: box-w, height: card-h, {
      _card(t, width: box-w, height: card-h, fill: t.panel, radius: t.corner-radius, clip: true, {
        place(horizon, box(width: 100%, inset: (left: if mirror { em } else { pad-icon },
          right: if mirror { pad-icon } else { em }), label))
        place((if mirror { left } else { right }) + horizon, box(width: 0.5 * em, height: 100%, fill: it.fill))
      })
      // icon badge: as tall as the card, centred on the card's outer edge
      place((if mirror { right } else { left }) + horizon, dx: if mirror { card-h / 2 } else { -card-h / 2 },
        _disc(t, radius: card-h / 2, fill: badge, align(center + horizon, glyph)))
    })
  }

  let half-w = bx + box-w / 2 + card-h / 2
  let x0 = half-w
  let y0 = calc.max(row-y(0, lefts.len()) + card-h / 2, r + ring-thickness / 2)
  let natural-w = x0 + if rights.len() > 0 { half-w } else { r + ring-thickness / 2 }
  let sides = ((-1, lefts, labels.slice(0, lefts.len())), (1, rights, labels.slice(lefts.len())))
  _canvas("process", t, width, area, natural-w, 2 * y0, {
    // connectors first (behind ring + boxes): short horizontal stub off the box,
    // then a diagonal to the ring.
    let ring-dots = ()
    for (side, group, _) in sides {
      for (i, it) in group.enumerate() {
        let by = row-y(i, group.len())
        let d = calc.norm(elbow-x / 1pt, by / 1pt) * 1pt
        let rp = (x0 + side * elbow-x / d * r, y0 - by / d * r)   // point on the ring
        // single polyline so the elbow has a clean rounded join (no notch)
        place(top + left, curve(stroke: (paint: it.fill, thickness: t.thick, join: "round", cap: "round"),
          curve.move((x0 + side * inner, y0 - by)), curve.line((x0 + side * elbow-x, y0 - by)), curve.line(rp)))
        ring-dots.push((rp, it.fill))
      }
    }
    _dot(x0, y0, r, fill: t.surface, stroke: ring-thickness + ring)
    _put(x0, y0, if core == auto { icon("\u{f21e}", size: r * 0.75, fill: ring) } else { core })
    // hollow ring-edge dots on top of the ring
    for ((x, y), col) in ring-dots { _dot(x, y, 0.28 * em, fill: t.surface, stroke: 0.75 * t.thick + col) }
    for (side, group, group-labels) in sides {
      for (i, it) in group.enumerate() {
        place(top + left, dx: x0 + side * bx - box-w / 2, dy: y0 - row-y(i, group.len()) - card-h / 2,
          node(it, group-labels.at(i), side > 0))
      }
    }
  })
})
