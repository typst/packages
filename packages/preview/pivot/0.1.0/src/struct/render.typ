#import "@preview/cetz:0.5.2" as cetz
#import "../theme.typ" as theme-mod
#import "../field/model.typ": model
#import "layout.typ": layout

// Hex string for a non-negative integer (no "0x" prefix). Typst markup has no
// built-in int -> hex, so build it.
#let _hex(n) = {
  if n == 0 {
    return "0"
  }
  let digits = "0123456789ABCDEF"
  let s = ""
  let v = n
  while v > 0 {
    s = digits.at(calc.rem(v, 16)) + s
    v = calc.quo(v, 16)
  }
  s
}

// struct: the byte-region cluster's vertical "memory map" view. Fields stack
// top-down with box height proportional to byte size (see struct/layout); byte
// offsets run down the left edge, sizes down the right. Same element vocabulary
// as packet (`bytes`/`bits`/`gap`/`reserved`); no row-wrapping. Returns content.
#let struct(..args, theme: theme-mod.default) = context {
  let fields = model(args.pos())

  // Capture tokens into renamed locals BEFORE `import cetz.draw: *` shadows them.
  let cell-stroke = theme.stroke
  let cell-fill = theme.fill
  let gap-stroke = theme.gap-stroke
  let gap-fill = theme.gap-fill
  let label-size = theme.label-size
  let meta-size = theme.bit-size
  let meta-fill = theme.bit-color
  let meta-font = theme.bit-font
  let box-w = theme.struct-width / 1cm
  let scale = theme.struct-byte-height / 1cm
  let min-h = theme.struct-min-height / 1cm
  let max-h = theme.struct-max-height / 1cm
  let side-gap = theme.struct-offset-gap / 1cm
  let row-gap = theme.row-gap / 1cm
  let col-gap = theme.col-gap / 1cm
  let break-amp = theme.struct-break-amp / 1cm
  let break-pitch = theme.struct-break-pitch / 1cm
  let label-pad = theme.label-pad / 1cm
  let leader-stroke = theme.leader-stroke
  let callout-drop = theme.callout-drop / 1cm
  let callout-line-h = theme.callout-line-height / 1cm
  let callout-bottom = theme.callout-bottom / 1cm

  let entries = layout(
    fields,
    scale: scale,
    min-height: min-h,
    max-height: max-h,
    gap: row-gap,
  )
  // Pad offsets to the width of the largest (the struct's end) so they read as
  // aligned addresses: 0x00, 0x04, ... 0x10.
  let pad-width = if entries.len() > 0 {
    _hex(calc.quo(entries.last().start + entries.last().size, 8)).len()
  } else {
    1
  }

  cetz.canvas({
    import cetz.draw: *
    let x0 = 0.0
    let x1 = box-w

    // a byte offset, formatted hex with a `:bit` suffix for sub-byte starts
    let off-label = bitpos => {
      let byte = calc.quo(bitpos, 8)
      let bit = calc.rem(bitpos, 8)
      let h = _hex(byte)
      while h.len() < pad-width { h = "0" + h }
      "0x" + h + if bit != 0 { ":" + str(bit) } else { "" }
    }

    let extra = 0.0
    for (i, e) in entries.enumerate() {
      let top = -(e.top + extra)
      let bot = -(e.top + e.height + extra)

      if e.type == "box" {
        let is-gap = e.kind == "gap"
        let box-stroke = if is-gap { gap-stroke } else { cell-stroke }
        let box-fill = if is-gap {
          gap-fill
        } else if e.fill != none {
          e.fill
        } else {
          cell-fill
        }
        // A clamped (oversized) field is capped below its true size, so its
        // bottom edge becomes a torn zigzag "break mark" — the height is drawn
        // short on purpose, and this says so. The size label still shows true size.
        if e.clamped {
          let n = 2 * int(calc.max(2, calc.round((x1 - x0) / break-pitch)))
          let step = (x1 - x0) / n
          let zig = range(0, n + 1).map(k => (
            x1 - k * step,
            if calc.rem(k, 2) == 0 { bot } else { bot + break-amp },
          ))
          line(
            (x0, top),
            (x1, top),
            ..zig,
            close: true,
            stroke: box-stroke,
            fill: box-fill,
          )
        } else {
          rect((x0, bot), (x1, top), stroke: box-stroke, fill: box-fill)
        }
        // Label placement, in order of preference: centred on one line if it
        // fits; wrapped to at most two lines inside the box if it doesn't; and
        // only when even two lines won't fit (too long, or too tall for the box)
        // does it move to a leader callout centred BELOW the box. The callout
        // label is centred on its leader, so the diagram itself stays centred and
        // the offset column stays put on the left.
        if e.label != none {
          let cx = (x0 + x1) / 2
          let mid-y = (top + bot) / 2
          let avail-w = (x1 - x0) - 2 * label-pad
          let nat-w = measure(text(size: label-size, e.label)).width / 1cm
          if nat-w <= avail-w {
            content((cx, mid-y), text(size: label-size, e.label))
          } else {
            // wrap to the box width and see if it lands within two lines and the
            // box height; a reference two-line block sets the line-count ceiling.
            // Disable justification: a wrapped label must not inherit the
            // document's `par(justify: true)`, which would stretch a line with
            // few break points into huge inter-word gaps.
            let wrapped = box(width: avail-w * 1cm, {
              set par(justify: false)
              align(center, text(size: label-size, e.label))
            })
            let wh = measure(wrapped).height / 1cm
            let two-line = (
              measure(box(
                width: avail-w * 1cm,
                text(size: label-size)[A\ A],
              )).height
                / 1cm
            )
            let avail-h = (top - bot) - 2 * label-pad
            if wh <= two-line + 0.01 and wh <= avail-h {
              content((cx, mid-y), wrapped)
            } else {
              // too long even for two lines: drop a leader and hang the same
              // wrapped block (centred, box width) below the box, so the callout
              // stays contained and centred rather than sprawling as one line.
              let ly = bot - callout-drop
              line((cx, bot), (cx, ly), stroke: leader-stroke)
              content((cx, ly), wrapped, anchor: "north")
              extra += callout-drop + wh + callout-bottom
            }
          }
        }
      } else {
        // a bit-carved byte-run: one strip subdivided horizontally into cells.
        // A cell shows its name inline if it fits, else its bit number and a
        // leader callout below (a 1-bit cell can't hold a name).
        let callouts = ()
        let last-j = e.cells.len() - 1
        for (j, c) in e.cells.enumerate() {
          let fcx0 = x0 + (c.start - e.start) / e.size * (x1 - x0)
          let fcx1 = x0 + (c.start + c.size - e.start) / e.size * (x1 - x0)
          // float the cells by `col-gap`, but keep the strip's outer edges flush
          // with the boxes above/below (only inset the internal boundaries).
          let cx0 = fcx0 + if j == 0 { 0.0 } else { col-gap / 2 }
          let cx1 = fcx1 - if j == last-j { 0.0 } else { col-gap / 2 }
          let cgap = c.kind == "gap"
          rect(
            (cx0, bot),
            (cx1, top),
            stroke: if cgap { gap-stroke } else { cell-stroke },
            fill: if cgap { gap-fill } else if c.fill != none { c.fill } else {
              cell-fill
            },
          )
          let mid = ((cx0 + cx1) / 2, (top + bot) / 2)
          let fits = (
            c.label != none
              and measure(text(size: label-size, c.label)).width / 1cm
                <= (cx1 - cx0) - 2 * label-pad
          )
          if fits {
            content(mid, text(size: label-size, c.label))
          } else {
            content(
              mid,
              text(size: meta-size, font: meta-font, fill: meta-fill, str(
                c.start - e.start,
              )),
            )
            if c.label != none {
              callouts.push((cx: (cx0 + cx1) / 2, label: c.label))
            }
          }
        }
        // names that did not fit: stacked in a band below the strip, ordered
        // left-to-right so the orthogonal drop-then-turn leaders never cross.
        let m = callouts.len()
        if m > 0 {
          // labels live OUTSIDE the frame (left of x0, right-aligned at the same
          // gutter as the offsets); leaders drop inside the frame then turn out
          // to them. Drops stay at x >= x0, labels at x < x0, so a drop can never
          // cut through a label's text.
          let gutter = x0 - side-gap
          for (k, c) in callouts.sorted(key: it => it.cx).enumerate() {
            let ly = bot - callout-drop - k * callout-line-h
            line((c.cx, bot), (c.cx, ly), (gutter, ly), stroke: leader-stroke)
            content(
              (gutter, ly),
              text(size: label-size, c.label),
              anchor: "east",
            )
          }
          extra += callout-drop + (m - 1) * callout-line-h + callout-bottom
        }
      }

      // offset at the boundary it marks (left column): centred in the gap above
      // each entry, except the first, which has no gap and sits at its top edge.
      let off-y = if i == 0 { top } else { top + row-gap / 2 }
      content(
        (x0 - side-gap, off-y),
        text(size: meta-size, font: meta-font, fill: meta-fill, off-label(
          e.start,
        )),
        anchor: "east",
      )

      // size, centred on the box (right column)
      let size-str = if calc.rem(e.size, 8) == 0 {
        str(calc.quo(e.size, 8)) + " B"
      } else {
        str(e.size) + " b"
      }
      content(
        (x1 + side-gap, (top + bot) / 2),
        text(size: meta-size, font: meta-font, fill: meta-fill, size-str),
        anchor: "west",
      )
    }

    // closing offset: the byte just past the last field (the struct's end)
    if entries.len() > 0 {
      let last = entries.last()
      content(
        (x0 - side-gap, -(last.top + last.height + extra)),
        text(
          size: meta-size,
          font: meta-font,
          fill: meta-fill,
          off-label(last.start + last.size),
        ),
        anchor: "east",
      )
    }
  })
}
