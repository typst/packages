#import "/src/cetz.typ" as cetz: draw, coordinate, util.resolve-number, vector

/// Possible chevron caps: #cetz.smartart.process.CHEVRON-CAPS
/// ```cexample
/// for cap in smartart.process.CHEVRON-CAPS {
///   smartart.process.chevron(
///     ([Step 1], [Step 2]), spacing: 0,
///     start-cap: cap, middle-cap: cap, end-cap: cap)
///   translate(y: -1)
/// }
/// ```
#let CHEVRON-CAPS = (
  "(", "<", "|", ">", ")"
)

#let _draw-arrow(
  start,
  end,
  height,
  fill,
  stroke,
  double: false,
  name: none
) = {
  let h2 = height / 2
  let h4 = height / 4
  draw.group(name: name, ctx => {
    let (ctx, p1) = coordinate.resolve(ctx, start)
    let (ctx, p2) = coordinate.resolve(ctx, end)
    let (x1, y1, _) = p1
    let (x2, y2, _) = p2
    let v = vector.sub(p2, p1)
    let d = vector.norm(v)
    let n = (-d.at(1), d.at(0))
    let len = vector.len(v)
    let head-len = h2
    /*
        c
    a---b\
    p1    p2
    g---f/
        e
    */
    /*
      i   c
     /a---b\
    p1      p2
     \g---f/
      h   e
    */
    let a = vector.add(p1, vector.scale(n, h4))
    if double {
      a = vector.add(
        a,
        vector.scale(d, head-len)
      )
    }
    let b = vector.add(
      a,
      vector.scale(
        d,
        len - if double {2 * head-len} else {head-len}
      )
    )
    let c = vector.add(b, vector.scale(n, h4))
    let e = vector.add(c, vector.scale(n, -height))
    let f = vector.add(e, vector.scale(n, h4))
    let g = vector.sub(a, vector.scale(n, h2))
    let pts = (
      a, b, c, p2, e, f, g
    )
    if double {
      let h = vector.sub(g, vector.scale(n, h4))
      let i = vector.add(a, vector.scale(n, h4))
      pts += (h, p1, i)
    }
    
    draw.line(
      ..pts,
      stroke: stroke,
      fill: fill,
      close: true
    )
    draw.anchor("start", p1)
    draw.anchor("end", p2)
    draw.anchor("center", (p1, 50%, p2))
    draw.anchor("default", (p1, 50%, p2))
  })
}

#let _draw-chevron(
  start,
  end,
  thickness,
  fill,
  stroke,
  start-cap,
  end-cap,
  cap-ratio,
  offset-start,
  offset-end,
  name: none
) = {
  let h2 = thickness / 2
  let h4 = thickness / 4
  draw.group(name: name, ctx => {
    let (ctx, p1) = coordinate.resolve(ctx, start)
    let (ctx, p2) = coordinate.resolve(ctx, end)


    draw.anchor("center", (p1, 50%, p2))
    draw.anchor("default", (p1, 50%, p2))
    
    let v = vector.sub(p2, p1)
    let d = vector.norm(v)
    let n = (d.at(1), d.at(0))

    /*
     >    |     <    )
    sa    sa   sa   sa,
     \    |    /       \
      sb  |   sb       |sb
     /    |    \       /
    sz    sz   sz   sz´
    */

    let cap-width = thickness * cap-ratio / 100%

    if offset-start and start-cap in ("(", "<") {
      p1 = vector.add(p1, vector.scale(d, cap-width))
    }

    if offset-end and end-cap in (")", ">") {
      p2 = vector.sub(p2, vector.scale(d, cap-width))
    }

    // Start cap
    let sb = if start-cap in ("(", "<") {
      vector.sub(p1, vector.scale(d, cap-width))
    } else {
      p1
    }
    let sa = vector.add(p1, vector.scale(n, h2))
    if start-cap in (")", ">") {
      sa = vector.sub(sa, vector.scale(d, cap-width))
    }
    let sz = vector.sub(sa, vector.scale(n, thickness))
    
    // End cap
    let eb = if end-cap in (")", ">") {
      vector.add(p2, vector.scale(d, cap-width))
    } else {
      p2
    }
    let ea = vector.add(p2, vector.scale(n, h2))
    if end-cap in ("(", "<") {
      ea = vector.add(ea, vector.scale(d, cap-width))
    }
    let ez = vector.sub(ea, vector.scale(n, thickness))
    
    draw.merge-path(
      {
        // Start cap
        if start-cap in ("(", ")") {
          draw.arc-through(sa, sb, sz)
        } else if start-cap == "|" {
          draw.line(sa, sz)
        } else {
          draw.line(sa, sb, sz)
        }
        
        // End cap
        if end-cap in ("(", ")") {
          draw.arc-through(ez, eb, ea)
        } else if end-cap == "|" {
          draw.line(ez, ea)
        } else {
          draw.line(ez, eb, ea)
        }
      },
      stroke: stroke,
      fill: fill,
      close: true
    )
    draw.anchor("start", p1)
    draw.anchor("end", p2)
  })
}

#let _get-steps-sizes(steps, ctx, style, step-style-at) = {
  let sizes = steps.enumerate().map(p => {
    let (i, step) = p
    let step-style = style.steps + step-style-at(i)
    let padding = resolve-number(ctx, step-style.padding)
    let max-width = resolve-number(ctx, step-style.max-width)
    max-width -= 2 * padding
    let m = measure(step, width: max-width * ctx.length)
    let w = resolve-number(ctx, m.width)
    let h = resolve-number(ctx, m.height)
    return (w, h)
  })

  let largest-width = calc.max(..sizes.map(s => s.first()))
  let highest-height = calc.max(..sizes.map(s => s.last()))

  return (sizes, largest-width, highest-height)
}

#let _get-style-at-func(style, n-steps) = {
  if type(style) == function {
    style
  } else if type(style) == array {
    i => {
      let s = style.at(calc.rem(i, style.len()))
      if type(s) == color or type(s) == gradient {
        (fill: s)
      } else {
        s
      }
    }
  } else if type(style) == gradient {
    i => (fill: style.sample(i / (n-steps - 1) * 100%))
  } else {
    i => (:)
  }
}

#let _pos-to-anchor(pos) = {
  if pos == left {return "west"}
  if pos == right {return "east"}
  if pos == top {return "north"}
  if pos == bottom {return "south"}
  panic("Cannot convert alignment " + repr(pos) + " to cardinal anchor")
}

#let _dir-to-anchors(dir) = {
  return (
    _pos-to-anchor(dir.start()),
    _pos-to-anchor(dir.end())
  )
}

#let _dir-to-str(dir) = {
  if dir == ttb {return "ttb"}
  if dir == btt {return "btt"}
  if dir == ltr {return "ltr"}
  if dir == rtl {return "rtl"}
  panic("Invalid direction " + repr(dir))
}

#let _draw-step-content(step, name, width) = {
  draw.content(
    name + ".center",
    box(
      width: width,
      align(center)[
        #set text(bottom-edge: "baseline")
        #step
      ]
    ),
    anchor: "center"
  )
}

#let _draw-step-frame(ctx, center, style, name, w, h) = {
  let padding = resolve-number(ctx, style.padding)
  let radius = resolve-number(ctx, style.radius)

  if style.shape == "rect" {
    let tl = (
      rel: (-w / 2 - padding, h / 2 + padding),
      to: center
    )
    let br = (
      rel: (w / 2 + padding, -h / 2 - padding),
      to: center
    )

    draw.rect(
      tl, br,
      name: name,
      stroke: style.stroke,
      fill: style.fill,
      radius: radius
    )
  } else if style.shape == "circle" {
    let w2 = w + padding * 2
    let h2 = h + padding * 2
    draw.circle(
      center,
      name: name,
      radius: calc.sqrt(w2 * w2 + h2 * h2) / 2,
      stroke: style.stroke,
      fill: style.fill
    )
  } else if style.shape == none {
    let tl = (
      rel: (-w / 2 - padding, h / 2 + padding),
      to: center
    )
    let br = (
      rel: (w / 2 + padding, -h / 2 - padding),
      to: center
    )
    draw.hide(draw.rect(
      tl, br,
      name: name,
      stroke: none,
      fill: none
    ))
  }
}

#let _draw-step(ctx, step, pos, style, name, w, h, dir: none) = {
  /*
  let padding = resolve-number(ctx, style.padding)
  let radius = resolve-number(ctx, style.radius)

  let tl = (
    rel: (
      ltr: (0, h / 2 + padding),
      rtl: (-w - padding * 2, h / 2 + padding),
      btt: (-w / 2 - padding, h + 2 * padding),
      ttb: (-w / 2 - padding, 0),
    ).at(_dir-to-str(dir)),
    to: pos
  )
  let br = (
    rel: (w + padding * 2, -h - padding * 2),
    to: tl
  )

  draw.rect(
    tl, br,
    name: name,
    stroke: style.stroke,
    fill: style.fill,
    radius: radius
  )*/
  if dir != none {
    let padding = resolve-number(ctx, style.padding)
    pos = (
      rel: (
        ltr: (w / 2 + padding, 0),
        rtl: (-w / 2 - padding, 0),
        btt: (0, h / 2 + padding),
        ttb: (0, -h / 2 - padding),
      ).at(_dir-to-str(dir)),
      to: pos
    )
  }
  _draw-step-frame(ctx, pos, style, name, w, h)
  _draw-step-content(step, name, w * ctx.length)
}

#let _draw-arc-arrow(
  start-angle,
  end-angle,
  radius,
  height,
  fill,
  stroke,
  double: false,
  name: none
) = {
  let h2 = height / 2
  let h4 = height / 4
  let angle-range = end-angle - start-angle
  // Angle for a length of h/2
  let arrow-angle = (h2 / radius) * (180deg / calc.pi)
  if angle-range < 0deg {
    arrow-angle *= -1
  }
  draw.group(name: name, ctx => {
    let pre-end-angle = end-angle - arrow-angle
    let mid-angle = start-angle + angle-range / 2
    let radius-int = radius - h4
    let radius-ext = radius + h4
    let radius-int2 = radius - h2
    let radius-ext2 = radius + h2
    let post-start-angle = start-angle + arrow-angle

    /*
         c     re2
    a-m1-b\    re
    p1     p2  r
    g-m2-f/    ri
         e     ri2
    */

    /*
      i    c     re2
     /a-m1-b\    re
    p1     p2  r
     \g-m2-f/    ri
      h    e     ri2
    */
    let p1 = (start-angle, radius)
    let a = (
      if double {post-start-angle} else {start-angle},
      radius-ext
    )
    let m1 = (mid-angle, radius-ext)
    let b = (pre-end-angle, radius-ext)
    let p2 = (end-angle, radius)
    let f = (pre-end-angle, radius-int)
    let m2 = (mid-angle, radius-int)
    let g = (
      if double {post-start-angle} else {start-angle},
      radius-int
    )
    
    let c = (pre-end-angle, radius-ext2)
    let e = (pre-end-angle, radius-int2)
    
    draw.merge-path(
      {
        draw.arc-through(a, m1, b)
        draw.line((), c, p2, e, f)
        draw.arc-through((), m2, g)
        if double {
          let h = (post-start-angle, radius-int2)
          let i = (post-start-angle, radius-ext2)
          draw.line((), h, p1, i)
        }
      },
      stroke: stroke,
      fill: fill,
      close: true
    )

    let center = (mid-angle, radius)
    draw.anchor("start", p1)
    draw.anchor("end", p2)
    draw.anchor("center", center)
    draw.anchor("center-ext", (mid-angle, radius-ext))
    draw.anchor("center-int", (mid-angle, radius-int))
    draw.anchor("default", center)
  })
}
