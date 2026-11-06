#import "@preview/cetz:0.2.2": canvas, draw

#import "range.typ" as rng
#import "structure.typ"
#import "vec.typ"

#let draw-rect(color, x, y, width, height, thickness: 0) = {
  let fill = none
  let stroke = color + thickness * 1pt
  if thickness == 0 {
    fill = color
    stroke = none
  }
  draw.rect((x, -y), (x + width, -y - height), fill: fill, stroke: stroke)
}

#let draw-text(
  txt,
  color,
  x,
  y,
  anchor: "center",
  font: none,
  italic: false,
  size: 1em,
  fill: none
) = {
  let text-params = (:)
  if font != none {
    text-params.insert("font", font)
  }
  if italic {
    text-params.insert("style", "italic")
  }

  draw.content(
    (x, -y),
    text(txt, fill: color, size: size, ..text-params),
    anchor: anchor,
    stroke: none
  )
}

#let draw-line(color, a, b) = {
  let (x0, y0) = a
  let (x1, y1) = b
  draw.line((x0, -y0), (x1, -y1), stroke: color)
}

#let draw-lines(color, ..pts) = {
  let pts = pts.pos().map(pt => (pt.at(0), -pt.at(1)))
  draw.line(..pts, stroke: color)
}

#let draw-poly(color, ..pts, thickness: 0) = {
  let pts = pts.pos().map(pt => (pt.at(0), -pt.at(1)))
  let params = (
    stroke: (paint: color, thickness: thickness),
    fill: none
  )
  if thickness == 0 {
    params = (
      stroke: none,
      fill: color
    )
  }
  draw.line(..pts, ..params)
}

#let draw-underbracket(config, start, end, bits-y) = {
  let bit-w = config.bit-width
  let bit-h = config.bit-height

  let x0 = start + bit-w / 2
  let x1 = end - bit-w / 2
  let y0 = bits-y + bit-h * 1.25
  let y1 = bits-y + bit-h * 1.5

  let col = config.link-color
  draw-lines(col, (x0, y0), (x0, y1), (x1, y1), (x1, y0))
}

#let draw-link(
  config,
  start-x,
  start-y,
  end-x,
  end-y
) = {
  let bit-h = config.bit-height
  let arrow-margin = config.arrow-margin

  if end-x > start-x {
    end-x -= arrow-margin
  } else {
    end-x += arrow-margin
  }

  draw-lines(
    config.link-color,
    (start-x, start-y + bit-h * 1.5),
    (start-x, end-y + bit-h / 2),
    (end-x, end-y + bit-h / 2),
  )
}

#let draw-values(config, values, desc-x, desc-y) = {
  let shapes = ()
  let txt-col = config.text-color
  let bit-w = config.bit-height  // Why ? I don't remember
  let gap = config.values-gap

  for (val, desc) in values.pairs().sorted(key: p => p.first()) {
    desc-y += gap
    let txt = val + " = " + desc
    shapes += draw-text(
      txt, txt-col, desc-x + bit-w / 2, desc-y,
      anchor: "north-west",
      font: config.italic-font-family,
      italic: true,
      size: config.italic-font-size
    )

    desc-y += config.italic-font-size / 1.2pt
  }

  return (shapes, desc-x, desc-y)
}

#let draw-description(
  config,
  range_,
  start-x,
  start-y,
  width,
  desc-x,
  desc-y
) = {
  let shapes = ()
  let bit-w = config.bit-width
  let bit-h = config.bit-height

  if config.left-labels {
    desc-x = calc.min(desc-x, start-x + width / 2 - bit-w)
  } else {
    desc-x = calc.max(desc-x, start-x + width / 2 + bit-w)
  }

  shapes += draw-underbracket(config, start-x, start-x + width, start-y)

  let mid-x = start-x + width / 2
  shapes += draw-link(config, mid-x, start-y, desc-x, desc-y)

  let txt-x = desc-x

  if config.left-labels {
    txt-x -= range_.description.len() * config.default-font-size / 2pt
  }

  shapes += draw-text(
    range_.description,
    config.text-color,
    txt-x, desc-y + bit-h / 2,
    anchor: "west"
  )

  desc-y += config.default-font-size / 0.75pt

  if range_.values != none and range_.depends-on == none {
    let shapes_
    (shapes_, _, desc-y) = draw-values(config, range_.values, txt-x, desc-y)
    shapes += shapes_
  }

  desc-y += config.description-margin

  return (shapes, desc-x, desc-y)
}

#let draw-arrow(config, start-x, start-y, end-x, end-y, label: "") = {
  let shapes = ()
  let dash-len = config.dash-length
  let dash-space = config.dash-space
  let arrow-size = config.arrow-size
  let link-col = config.link-color
  let txt-col = config.text-color
  let arrow-label-dist = config.arrow-label-distance

  let start = vec.vec(start-x, start-y)
  let end = vec.vec(end-x, end-y)
  let start-end = vec.sub(end, start)
  let d = vec.normalize(start-end)

  let dashes = int(vec.mag(start-end) / (dash-len + dash-space))

  for i in range(dashes) {
    let a = vec.add(
      start,
      vec.mul(d, i * (dash-len + dash-space))
    )
    let b = vec.add(
      a,
      vec.mul(d, dash-len)
    )

    shapes += draw-line(link-col, (a.x, a.y), (b.x, b.y))
  }

  let n = vec.vec(d.y, -d.x)
  let width = arrow-size / 1.5
  let p1 = vec.sub(
    end,
    vec.sub(
      vec.mul(d, arrow-size),
      vec.mul(n, width)
    )
  )
  let p2 = vec.sub(
    end,
    vec.add(
      vec.mul(d, arrow-size),
      vec.mul(n, width)
    )
  )

  shapes += draw-poly(
    link-col,
    (end.x, end.y),
    (p1.x, p1.y),
    (p2.x, p2.y)
  )

  if label != "" {
    shapes += draw-text(
      label,
      txt-col,
      (start.x + end.x) / 2,
      (start.y + end.y) / 2 + arrow-label-dist,
      anchor: "north"
    )
  }

  return shapes
}

#let draw-dependency(
  draw-struct, config,
  struct, schema, bits-x, bits-y, range_, desc-x, desc-y
) = {
  let shapes = ()

  let bit-w = config.bit-width
  let bit-h = config.bit-height
  let arrow-margin = config.arrow-margin

  let start-i = struct.bits - range_.end - 1
  let start-x = bits-x + start-i * bit-w
  let width = rng.bits(range_) * bit-w

  shapes += draw-underbracket(config, start-x, start-x + width, bits-y)
  let depend-key = rng.key(..range_.depends-on)
  let depend-range = struct.ranges.at(depend-key)
  let prev-range-y = bits-y + bit-h * 1.5

  let prev-depend-y = if depend-range.last-value-y == -1 {
    bits-y + bit-h * 1.5
  } else {
    depend-range.last-value-y
  }

  let depend-start-i = struct.bits - depend-range.end - 1
  let depend-start-x = bits-x + depend-start-i * bit-w
  let depend-width = rng.bits(depend-range) * bit-w
  let depend-mid = depend-start-x + depend-width / 2
  shapes += draw-underbracket(config, depend-start-x, depend-start-x + depend-width, bits-y)

  for (val, data) in range_.values.pairs().sorted(key: p => p.first()) {
    shapes += draw-arrow(config, depend-mid, prev-depend-y, depend-mid, desc-y - arrow-margin)

    let val-ranges = (:)
    for i in range(rng.bits(depend-range)) {
      val-ranges.insert(
        str(depend-range.end - i),
        (name: val.at(i))
      )
    }

    let val-struct = (
      bits: rng.bits(depend-range),
      start: depend-range.start,
      ranges: val-ranges
    )
    val-struct = structure.load("", val-struct)

    let shapes_
    (shapes_, ..) = draw-struct(config, val-struct, schema, ox: depend-start-x, oy: desc-y)
    shapes += shapes_

    let y = desc-y + bit-h * 1.5

    let x1
    let x2

    // Arrow from left to right
    if depend-range.end > range_.start {
      x1 = depend-start-x + depend-width + arrow-margin
      x2 = start-x - arrow-margin
    
    // Arrow from right to left
    } else {
      x1 = depend-start-x - arrow-margin
      x2 = start-x + width + arrow-margin
    }

    shapes += draw-arrow(config, x1, y, x2, y, label: data.description)
    shapes += draw-arrow(config,
      start-x + width - bit-w,
      prev-range-y,
      start-x + width - bit-w,
      desc-y + bit-h - arrow-margin
    )

    prev-depend-y = desc-y + bit-h * 2 + arrow-margin
    prev-range-y = prev-depend-y
    depend-range.last-value-y = prev-depend-y

    (shapes_, desc-y) = draw-struct(config, schema.structures.at(data.structure), schema, ox: start-x, oy: desc-y)
    shapes += shapes_
  }

  struct.ranges.at(depend-key) = depend-range

  return (shapes, desc-x, desc-y, struct)
}

#let draw-structure(config, struct, schema, ox: 0, oy: 0) = {
  let shapes
  let colors = schema.at("colors", default: (:))
  let bg-col = config.background
  let txt-col = config.text-color
  let border-col = config.border-color
  let bit-w = config.bit-width
  let bit-h = config.bit-height

  let (bits-x, bits-y) = (ox, oy + bit-h)
  let bits-width = struct.bits * bit-w
  let start-bit = struct.start
  let bit-colors = (:)
  for i in range(struct.bits) {
    bit-colors.insert(str(i), bg-col)
  }
  if struct.name in colors {
    for (s, col) in colors.at(struct.name) {
      let (start, end) = rng.parse-span(s)
      for i in range(start, end + 1) {
        let real-i = struct.bits - i - 1 + start-bit
        bit-colors.insert(str(real-i), col)
      }
    }
  }
  let range-boundaries = ()
  for r in struct.ranges.values() {
    let i = struct.bits - r.end - 1 + start-bit
    range-boundaries.push(i)
  }

  // Draw colors
  for i in range(struct.bits) {
    let bit-x = ox + i * bit-w
    shapes += draw-rect(bit-colors.at(str(i)), bit-x, bits-y, bit-w+1, bit-h)
  }

  // Draw rectangle around structure
  shapes += draw-rect(border-col, bits-x, bits-y, bits-width, bit-h, thickness: 2)

  let indices = range(struct.bits)
  if not config.all-bit-i {
    indices = ()
    for r in struct.ranges.values() {
      indices.push(r.start)
      indices.push(r.end)
    }
  }

  for i in range(struct.bits) {
    let bit-x = ox + i * bit-w
    let real-i = struct.bits - i - 1 + start-bit

    if real-i in indices {
      shapes += draw-text(
        str(real-i),
        txt-col,
        bit-x + bit-w / 2,
        oy + bit-h / 2 
      )
    }

    // Draw separator
    if i != 0 and not i in range-boundaries {
      shapes += draw-line(border-col, (bit-x, bits-y), (bit-x, bits-y + bit-h * 0.2))
      shapes += draw-line(border-col, (bit-x, bits-y + bit-h * 0.8), (bit-x, bits-y + bit-h))
    }
  }

  let ranges = structure.get-sorted-ranges(struct)
  if config.left-labels {
    ranges = ranges.rev()
  }

  let desc-x
  if config.force-descs-on-side {
    desc-x = config.margins.at(3) + structures.main.bits * bit-w
    if config.left-labels {
      desc-x = config.width - desc-x
    }
  } else {
    desc-x = ox
    if config.left-labels {
      desc-x += struct.bits * bit-w
    }
  }

  let desc-y = bits-y + bit-h * 2

  // Names + simple descriptions
  for range_ in ranges {
    let start-i = struct.bits - range_.end + start-bit - 1
    let start-x = bits-x + start-i * bit-w
    let width = rng.bits(range_) * bit-w

    let name-x = start-x + width / 2
    let name-y = bits-y + bit-h / 2
    
    shapes += draw-line(border-col, (start-x, bits-y), (start-x, bits-y + bit-h))
    shapes += draw-text(range_.name, txt-col, name-x, name-y, fill: bg-col)
    
    if range_.description != "" {
      let shapes_
      (shapes_, desc-x, desc-y) = draw-description(
        config, range_, start-x, bits-y, width, desc-x, desc-y
      )
      shapes += shapes_
    }
  }

  // Dependencies
  for range_ in ranges {
    if range_.values() != none and range_.depends-on != none {
      let shapes_
      (shapes_, desc-x, desc-y, struct) = draw-dependency(
        draw-structure, config,
        struct, schema, bits-x, bits-y, range_, desc-x, desc-y,
      )
      shapes += shapes_
    }
  }

  return (shapes, desc-y)
}

#let render(config, schema, width: 100%) = {
  set text(
    font: config.default-font-family,
    size: config.default-font-size
  )

  let main = schema.structures.main
  let ox = config.margins.at(3)
  if config.left-labels {
    ox = config.width - ox - main.bits * config.bit-width
  }

  let params = if config.full-page {
    (
      width: auto,
      height: auto,
      fill: config.background,
      margin: 0cm
    )
  } else {
    (:)
  }

  set page(..params)

  let cnvs = canvas(length: 1pt, background: config.background, {
    let (shapes, _) = draw-structure(
      config, main, schema,
      ox: ox,
      oy: config.margins.at(0)
    )
    // Workaround for margins
    draw.group(name: "g", padding: config.margins, shapes)
    draw.line(
      "g.north-west",
      "g.north-east",
      "g.south-east",
      "g.south-west",
      stroke: none,
      fill: none
    )
  })

  if config.full-page {
    cnvs
  } else {
    layout(size => {
      let m = measure(cnvs)
      let w = m.width
      let h = m.height
      let base-w = if type(width) == ratio {
        size.width * width
      } else {
        width
      }
      let r = if w == 0 {
        0
      } else {
        base-w / w
      }

      let new-w = w * r
      let new-h = h * r
      r *= 100%

      box(
        width: new-w,
        height: new-h,
        scale(x: r, y: r, cnvs, reflow: true)
      )
    })
  }
}

#let make(config) = {
  return (
    config: config,
    render: render.with(config)
  )
}