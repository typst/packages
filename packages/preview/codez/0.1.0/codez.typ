#import "./codly.typ": codly-init, local, codly-mark-range, codly-bbox-info
#import "@preview/cetz:0.3.4" as cetz

#let init = codly-init

#let mark(
  ..args,
  name: none,
  start: none,
  end: none,
  start-col: none,
  end-col: none,
  trim-left: false,
) = {
  let pos = args.pos()
  if name == none and pos.len() > 0 { name = pos.at(0) }
  if start == none and pos.len() > 1 { start = pos.at(1) }
  if end == none and pos.len() > 2 { end = pos.at(2) }

  assert(name != none, message: "codez.mark: name is required")
  assert(start != none and end != none, message: "codez.mark: start/end are required")
  let out = (
    name: name,
    start: start,
    end: end,
  )
  if start-col != none { out.insert("start-col", start-col) }
  if end-col != none { out.insert("end-col", end-col) }
  if trim-left { out.insert("trim-left", trim-left) }
  out
}

// Alias for range/bbox marks.
#let bbox-mark(..args) = mark(..args)

// Mark a single character position externally (line + column).
#let mark-char(name, line, col, side: "after") = {
  let start-col = if side == "before" { col - 1 } else { col }
  let end-col = if side == "before" { col } else { col + 1 }
  mark(name, line, line, start-col: calc.max(start-col, 0), end-col: calc.max(end-col, 0))
}

#let _block-prefix(block) = "codez-" + block
#let _mark-prefix(block, m) = _block-prefix(block) + "-" + m.name

#let _parse_inline_marks(code) = {
  let i = 0
  let n = code.len()
  let line = 1
  let col = 0
  let out = ()
  let spans = ()

  while i < n {
    let sub = code.slice(i, n)

    if sub.starts-with("[[mark:") {
      let rel = sub.position("]]")
      if rel == none {
        panic("codez: unterminated mark tag")
      }
      let name = sub.slice(7, rel)
      spans.push((
        name: name,
        start: line,
        end: line,
        "start-col": col,
        "end-col": col + 1,
      ))
      i += rel + 2
      continue
    }

    if sub.starts-with("[[/mark]]") {
      i += 9
      continue
    }

    let ch = code.slice(i, i + 1)
    out.push(ch)
    if ch == "\n" {
      line += 1
      col = 0
    } else {
      col += 1
    }
    i += 1
  }

  (code: out.join(), spans: spans)
}

#let _first_nonblank_col(line) = {
  for i in range(0, line.len()) {
    let ch = line.slice(i, i + 1)
    if ch != " " and ch != "\t" { return i }
  }
  line.len()
}

#let _expand_mark(prefix, m, raw_lines: none) = {
  let out = ()
  let line_start = m.start
  let line_end = m.end
  let col_start = m.at("start-col", default: 0)
  let col_end = m.at("end-col", default: 999999)
  let trim_left = m.at("trim-left", default: false)
  let has_start_col = m.at("start-col", default: none) != none

  for l in range(line_start, line_end + 1) {
    let base_start = if l == line_start { col_start } else { 0 }
    let s = if trim_left and not has_start_col and raw_lines != none {
      let line = raw_lines.at(l - 1, default: "")
      let first = _first_nonblank_col(line)
      if first > base_start { first } else { base_start }
    } else {
      base_start
    }
    let e = if l == line_end { col_end } else { 999999 }
    out.push((line: l, start: s, label: label(prefix + "-l" + str(l) + "-s")))
    out.push((line: l, start: e, label: label(prefix + "-l" + str(l) + "-e")))
  }

  out
}

#let parse(code) = {
  let parsed = _parse_inline_marks(code)
  (code: parsed.code, marks: parsed.spans)
}

#let pick(marks, name) = {
  for m in marks {
    if m.name == name { return m }
  }
  none
}

#let block(
  ..args,
  name: none,
  code: none,
  lang: none,
  marks: (),
  inline-marks: true,
  width: auto,
  inset: 8pt,
  radius: 6pt,
  fill: rgb("#f7f7f2"),
  stroke: rgb("#1d154d"),
  zebra-fill: rgb("#f2f2f2"),
  number-format: (n) => [],
  display-name: false,
  display-icon: false,
  line-leading: none,
  line-gap: 0pt,
) = {
  let pos = args.pos()
  if name == none and pos.len() > 0 { name = pos.at(0) }
  if code == none and pos.len() > 1 { code = pos.at(1) }

  assert(name != none, message: "codez.block: name is required")
  assert(code != none, message: "codez.block: code is required")

  let parsed = if type(code) == str and inline-marks {
    _parse_inline_marks(code)
  } else {
    (code: code, spans: ())
  }

  let mark-list = ()
  for m in marks {
    if m != none {
      m.insert("prefix", _mark-prefix(name, m))
      mark-list.push(m)
    }
  }
  for m in parsed.spans {
    if m != none {
      m.insert("prefix", _mark-prefix(name, m))
      mark-list.push(m)
    }
  }

  let raw_lines = if type(parsed.code) == str { parsed.code.split("\n") } else { () }
  let codly-marks = ()
  for m in mark-list {
    codly-marks += _expand_mark(m.prefix, m, raw_lines: raw_lines)
  }

  local(
    enabled: true,
    marks: codly-marks,
    zebra-fill: zebra-fill,
    fill: none,
    stroke: none,
    radius: 0pt,
    inset: 0pt,
    number-format: number-format,
    display-name: display-name,
    display-icon: display-icon,
    line-leading: line-leading,
    line-gap: line-gap,
  )[
    #if width == auto {
      box(inset: inset, radius: radius, fill: fill, stroke: stroke)[
        #if type(parsed.code) == str {
          raw(parsed.code, lang: lang, block: true)
        } else {
          parsed.code
        }
      ]
    } else {
      box(width: width, inset: inset, radius: radius, fill: fill, stroke: stroke)[
        #if type(parsed.code) == str {
          raw(parsed.code, lang: lang, block: true)
        } else {
          parsed.code
        }
      ]
    }
  ]
}

#let _line_content(line, lang, text-size) = {
  if lang == none {
    if text-size != none {
      [
        #set text(size: text-size)
        #text(line)
      ]
    } else {
      text(line)
    }
  } else {
    if text-size != none {
      [
        #set text(size: text-size)
        #raw(line, lang: lang, block: false)
      ]
    } else {
      raw(line, lang: lang, block: false)
    }
  }
}

#let _slice_cols(line, col) = {
  let c = if col < 0 { 0 } else { col }
  let n = line.len()
  let end = if c > n { n } else { c }
  line.slice(0, end)
}

#let _measure_line(ctx, line, lang, text-size) = {
  let cnt = _line_content(line, lang, text-size)
  cetz.util.measure(ctx, cnt).at(0)
}

#let _badge_anchor_offset(anchor, w, h) = {
  if anchor == "south-west" { (0pt, 0pt) }
  else if anchor == "south" { (-w / 2, 0pt) }
  else if anchor == "south-east" { (-w, 0pt) }
  else if anchor == "west" { (0pt, -h / 2) }
  else if anchor == "center" { (-w / 2, -h / 2) }
  else if anchor == "east" { (-w, -h / 2) }
  else if anchor == "north-west" { (0pt, -h) }
  else if anchor == "north" { (-w / 2, -h) }
  else if anchor == "north-east" { (-w, -h) }
  else { (0pt, 0pt) }
}

#let _wrap_line_segments(line, maxw, ctx, lang, text-size, start: 0) = {
  if line.len() == 0 { return ((text: "", start: 0, end: 0),) }
  if start == 0 and _measure_line(ctx, line, lang, text-size) <= maxw {
    return ((text: line, start: 0, end: line.len()),)
  }
  if start >= line.len() { return () }

  let last = start
  for i in range(start + 1, line.len() + 1) {
    let seg = line.slice(start, i)
    if _measure_line(ctx, seg, lang, text-size) <= maxw {
      last = i
    }
  }

  if last == start { last = start + 1 }
  let out = ((text: line.slice(start, last), start: start, end: last),)
  for seg in _wrap_line_segments(line, maxw, ctx, lang, text-size, start: last) {
    out.push(seg)
  }
  out
}

// Cetz-native code block rendering (usable inside a cetz.canvas).
#let cetz-block(
  ..args,
  name: none,
  code: none,
  lang: none,
  marks: (),
  inline-marks: true,
  at: (0, 0),
  width: auto,
  wrap: false,
  badge: none,
  badge-tag: none,
  badge-lang: none,
  badge-offset: (0pt, 0pt),
  badge-anchor: "south-west",
  badge-size: 16pt,
  badge-tag-fill: rgb("#1d154d"),
  badge-tag-text: white,
  badge-lang-fill: rgb("#f7f7f2"),
  badge-lang-text: rgb("#1d154d"),
  badge-stroke: none,
  badge-radius: 7pt,
  badge-pad-x: 8pt,
  badge-pad-y: 5pt,
  padding: (x: 8pt, y: 6pt),
  radius: 6pt,
  fill: rgb("#f7f7f2"),
  stroke: rgb("#1d154d"),
  zebra-fill: rgb("#f2f2f2"),
  line-height: auto,
  line-gap: 2pt,
  text-size: none,
  mark-stroke: 1pt + rgb("#8fc2ff"),
  mark-fill: none,
  mark-radius: 2pt,
  mark-inset: 0pt,
) = {
  let pos = args.pos()
  if name == none and pos.len() > 0 { name = pos.at(0) }
  if code == none and pos.len() > 1 { code = pos.at(1) }

  assert(name != none, message: "codez.cetz-block: name is required")
  assert(code != none and type(code) == str, message: "codez.cetz-block: code must be a string")

  let parsed = if inline-marks { _parse_inline_marks(code) } else { (code: code, spans: ()) }
  let raw_lines = parsed.code.split("\n")

  let mark-list = ()
  for m in marks {
    if m != none { mark-list.push(m) }
  }
  for m in parsed.spans {
    if m != none { mark-list.push(m) }
  }

  cetz.draw.scope(
    cetz.draw.translate(at) +
    cetz.draw.group(name: name, {
      ctx => {
        let pad = cetz.util.as-padding-dict(padding)
        pad = pad.pairs().map(((k, v)) => ((k): cetz.util.resolve-number(ctx, v))).join()

        let base-sample = _line_content("X", lang, text-size)
        let base-h = cetz.util.measure(ctx, base-sample).at(1)
        let lh = if line-height == auto { base-h } else { cetz.util.resolve-number(ctx, line-height) }
        let lg = cetz.util.resolve-number(ctx, line-gap)
        let step = lh + lg

        let wrap_on = wrap and width != auto
        let max_inner = if wrap_on {
          let resolved = cetz.util.resolve-number(ctx, width)
          calc.max(0, resolved - pad.left - pad.right)
        } else {
          0
        }

        let line_chunks = ()
        if wrap_on {
          for i in range(0, raw_lines.len()) {
            let line = raw_lines.at(i)
            let segs = _wrap_line_segments(line, max_inner, ctx, lang, text-size)
            for s in segs {
              line_chunks.push((text: s.text, orig: i + 1, start: s.start, end: s.end))
            }
          }
        } else {
          for i in range(0, raw_lines.len()) {
            let line = raw_lines.at(i)
            line_chunks.push((text: line, orig: i + 1, start: 0, end: line.len()))
          }
        }

        let line_content = line_chunks.map(lc => {
          let cnt = _line_content(lc.text, lang, text-size)
          let size = cetz.util.measure(ctx, cnt)
          (text: cnt, width: size.at(0), height: size.at(1))
        })

        let maxw = if line_content.len() == 0 {
          0
        } else {
          line_content.map(l => l.width).fold(line_content.at(0).width, (a, b) => calc.max(a, b))
        }

        let w = if width == auto {
          maxw + pad.left + pad.right
        } else {
          cetz.util.resolve-number(ctx, width)
        }

        let h = pad.top + pad.bottom + (line_chunks.len() * lh) + (if line_chunks.len() > 0 { (line_chunks.len() - 1) * lg } else { 0 })

        let elements = ()
        elements += cetz.draw.rect((0, 0), (w, -h), radius: radius, fill: fill, stroke: stroke)

        if zebra-fill != none {
          for i in range(0, line_chunks.len()) {
            if calc.rem(i, 2) == 1 {
              let y_top = -pad.top - i * step
              let y_bot = y_top - lh
              elements += cetz.draw.rect((pad.left, y_top), (w - pad.right, y_bot), fill: zebra-fill, stroke: none)
            }
          }
        }

        for i in range(0, line_chunks.len()) {
          let y_top = -pad.top - i * step
          let y_mid = y_top - lh / 2
          let cnt = line_content.at(i).text
          elements += cetz.draw.content((pad.left, y_mid), cnt, anchor: "mid-west")
        }

        let mark_pad = cetz.util.as-padding-dict(mark-inset)
        mark_pad = mark_pad.pairs().map(((k, v)) => ((k): cetz.util.resolve-number(ctx, v))).join()

        for m in mark-list {
          if m != none {
            let x-min = none
            let x-max = none
            let y-top-m = none
            let y-bot-m = none
            for i in range(0, line_chunks.len()) {
              let chunk = line_chunks.at(i)
              let l = chunk.orig
              if l < m.start or l > m.end { continue }
              let line = raw_lines.at(l - 1)
              let line-len = line.len()
              let base-start = if l == m.start { m.at("start-col", default: 0) } else { 0 }
              let trim-left = m.at("trim-left", default: false)
              let has-start-col = m.at("start-col", default: none) != none
              let line-start = if trim-left and not has-start-col {
                let first = _first_nonblank_col(line)
                if first > base-start { first } else { base-start }
              } else {
                base-start
              }
              let line-end = if l == m.end { m.at("end-col", default: line-len) } else { line-len }
              let seg-start = calc.max(line-start, chunk.start)
              let seg-end = calc.min(line-end, chunk.end)
              if seg-end < seg-start { continue }
              let rel-start = seg-start - chunk.start
              let rel-end = seg-end - chunk.start
              let w1 = cetz.util.measure(ctx, _line_content(_slice_cols(chunk.text, rel-start), lang, text-size)).at(0)
              let w2 = cetz.util.measure(ctx, _line_content(_slice_cols(chunk.text, rel-end), lang, text-size)).at(0)
              let x1 = pad.left + w1
              let x2 = pad.left + w2
              let y_top = -pad.top - i * step
              let y_bot = y_top - lh
              x-min = if x-min == none { calc.min(x1, x2) } else { calc.min(x-min, x1, x2) }
              x-max = if x-max == none { calc.max(x1, x2) } else { calc.max(x-max, x1, x2) }
              y-top-m = if y-top-m == none { y_top } else { calc.max(y-top-m, y_top) }
              y-bot-m = if y-bot-m == none { y_bot } else { calc.min(y-bot-m, y_bot) }
            }
            if x-min != none and x-max != none and y-top-m != none and y-bot-m != none {
              let x1 = x-min - mark_pad.left
              let x2 = x-max + mark_pad.right
              let y1 = y-top-m + mark_pad.top
              let y2 = y-bot-m - mark_pad.bottom
              elements += cetz.draw.rect(
                (x1, y1),
                (x2, y2),
                name: m.name,
                radius: mark-radius,
                fill: mark-fill,
                stroke: mark-stroke,
              )
            }
          }
        }

        let btag = badge-tag
        let blang = badge-lang
        if badge != none and type(badge) == dictionary {
          if btag == none and badge.has("tag") { btag = badge.tag }
          if blang == none and badge.has("lang") { blang = badge.lang }
        }
        if btag != none and blang != none {
          let boff = if type(badge-offset) == array and badge-offset.len() >= 2 {
            (badge-offset.at(0), badge-offset.at(1))
          } else if type(badge-offset) == length {
            (badge-offset, 0pt)
          } else {
            (8pt, 0pt)
          }
          let bx = cetz.util.resolve-number(ctx, boff.at(0))
          let by = cetz.util.resolve-number(ctx, boff.at(1))
          let bstroke = if badge-stroke == none { stroke } else { badge-stroke }
          let pad_x = cetz.util.resolve-number(ctx, badge-pad-x)
          let pad_y = cetz.util.resolve-number(ctx, badge-pad-y)

          let tag_cnt = text(btag, size: badge-size, fill: badge-tag-text)
          let lang_cnt = text(blang, size: badge-size, fill: badge-lang-text)
          let tag_size = cetz.util.measure(ctx, tag_cnt)
          let lang_size = cetz.util.measure(ctx, lang_cnt)
          let tag_w = tag_size.at(0)
          let tag_h = tag_size.at(1)
          let lang_w = lang_size.at(0)
          let lang_h = lang_size.at(1)
          let badge_h = calc.max(tag_h, lang_h) + 2 * pad_y
          let tag_box_w = tag_w + 2 * pad_x
          let lang_box_w = lang_w + 2 * pad_x
          let badge_w = tag_box_w + lang_box_w

          let off = _badge_anchor_offset(badge-anchor, badge_w, badge_h)
          let off_x = cetz.util.resolve-number(ctx, off.at(0))
          let off_y = cetz.util.resolve-number(ctx, off.at(1))
          let x0 = bx + off_x
          let y0 = by + off_y

          elements += cetz.draw.rect(
            (x0, y0),
            (x0 + tag_box_w, y0 + badge_h),
            fill: badge-tag-fill,
            stroke: none,
            radius: (top-left: badge-radius, top-right: 0pt, bottom-left: 0pt, bottom-right: 0pt),
          )
          elements += cetz.draw.rect(
            (x0 + tag_box_w, y0),
            (x0 + badge_w, y0 + badge_h),
            fill: badge-lang-fill,
            stroke: none,
            radius: (top-left: 0pt, top-right: badge-radius, bottom-left: 0pt, bottom-right: 0pt),
          )
          elements += cetz.draw.rect(
            (x0, y0),
            (x0 + badge_w, y0 + badge_h),
            fill: none,
            stroke: bstroke,
            radius: (top-left: badge-radius, top-right: badge-radius, bottom-left: 0pt, bottom-right: 0pt),
          )

          elements += cetz.draw.content(
            (x0 + tag_box_w / 2, y0 + badge_h / 2),
            tag_cnt,
            anchor: "center",
          )
          elements += cetz.draw.content(
            (x0 + tag_box_w + lang_box_w / 2, y0 + badge_h / 2),
            lang_cnt,
            anchor: "center",
          )
        }

        elements
      }
    })
  )
}

#let _pick(info, which) = {
  let left = info.at("left")
  let right = info.at("right")
  let top = info.at("top")
  let bottom = info.at("bottom")
  let cx = (left + right) / 2
  let cy = (top + bottom) / 2

  if which == "west" { (left, cy) }
  else if which == "east" { (right, cy) }
  else if which == "north" { (cx, top) }
  else if which == "south" { (cx, bottom) }
  else if which == "north-east" { (right, top) }
  else if which == "north-west" { (left, top) }
  else if which == "south-east" { (right, bottom) }
  else if which == "south-west" { (left, bottom) }
  else { (cx, cy) }
}

#let bbox-info(block, mark, pad-x: 2pt, pad-y: 1pt) = {
  assert(type(mark) == dictionary, message: "codez.bbox-info: mark must be a mark() object")
  let prefix = _mark-prefix(block, mark)
  codly-bbox-info(prefix, mark.start, mark.end, pad-x: pad-x, pad-y: pad-y)
}

#let anchor(
  block,
  mark,
  anchor: "east",
  origin: "here",
  pad-x: 2pt,
  pad-y: 1pt,
) = {
  let info = bbox-info(block, mark, pad-x: pad-x, pad-y: pad-y)
  if info == none { return none }

  let pt = _pick(info, anchor)
  if origin == "page" {
    pt
  } else {
    let here-pos = here().position()
    if here-pos.page != info.at("page") { return none }
    (pt.at(0) - here-pos.x, pt.at(1) - here-pos.y)
  }
}

#let bbox(
  block,
  mark,
  stroke: 1.2pt + rgb("#1d154d"),
  pad-x: 2pt,
  pad-y: 1pt,
) = context {
  let stroke_style = stroke
  let info = bbox-info(block, mark, pad-x: pad-x, pad-y: pad-y)
  if info == none { return none }
  let here-pos = here().position()
  if here-pos.page != info.at("page") { return none }
  let dx = info.at("left") - here-pos.x
  let dy = info.at("top") - here-pos.y
  let w = info.at("right") - info.at("left")
  let h = info.at("bottom") - info.at("top")

  move(dx: dx, dy: dy)[
    #cetz.canvas(length: 1pt, {
      import cetz.draw: *
      rect((0pt, 0pt), (w, h), stroke: stroke_style)
    })
  ]
}

#let canvas(draw) = place(top + left, float: true, dx: 0pt, dy: 0pt)[
  #cetz.canvas(length: 1pt, {
    import cetz.draw: *
    draw()
  })
]

#let overlay(
  anchors: (),
  draw,
  length: 1pt,
  origin: "here",
) = context {
  let here-pos = here().position()
  let pts = (:)
  for (name, spec) in anchors {
    if type(spec) != array or spec.len() < 2 {
      panic("codez.overlay: anchor spec must be (block, mark[, anchor])")
    }
    let block = spec.at(0)
    let mark = spec.at(1)
    let which = spec.at(2, default: "center")
    let p = anchor(block, mark, anchor: which, origin: origin)
    if p != none {
      let x = p.at(0) / length
      let y = p.at(1) / length
      pts.insert(name, (x, y))
    }
  }

  if pts.len() == 0 { return none }

  let vals = pts.values()
  let minx = vals.map(p => p.at(0)).fold(vals.at(0).at(0), (a, b) => calc.min(a, b))
  let miny = vals.map(p => p.at(1)).fold(vals.at(0).at(1), (a, b) => calc.min(a, b))

  let base-dx = minx * length
  let base-dy = miny * length
  let dx = if origin == "page" { -here-pos.x + base-dx } else { base-dx }
  let dy = if origin == "page" { -here-pos.y + base-dy } else { base-dy }

  place(top + left, float: true, dx: dx, dy: dy)[
    #context {
      cetz.canvas(length: length, {
        import cetz.draw: *
        set-transform(none)
        let at = (name) => pts.at(name)
        let shift = (p, dx, dy) => (p.at(0) + dx, p.at(1) + dy)
        let d = (
          line: line,
          circle: circle,
          rect: rect,
          bezier: bezier,
          bezier-through: bezier-through,
          text: text,
        )
        draw(at, shift, pts, d)
      })
    }
  ]
}

#let dot(
  block,
  mark,
  which: "east",
  color: red,
  radius: 2.5,
  pad-x: 2pt,
  pad-y: 1pt,
) = context {
  let p = anchor(block, mark, anchor: which, origin: "here", pad-x: pad-x, pad-y: pad-y)
  if p == none { return none }
  let r = if type(radius) == length { radius / 1pt } else { radius }
  move(dx: p.at(0), dy: p.at(1))[
    #cetz.canvas(length: 1pt, {
      import cetz.draw: *
      circle((0pt, 0pt), radius: r, fill: color, stroke: none)
    })
  ]
}

#let _offset_for(anchor, offset) = {
  if anchor == "west" or anchor == "north-west" or anchor == "south-west" {
    -offset
  } else if anchor == "center" or anchor == "north" or anchor == "south" {
    0pt
  } else {
    offset
  }
}

#let arc(
  block,
  from,
  to,
  block-to: none,
  from-anchor: "east",
  to-anchor: "east",
  bend: 40pt,
  offset: 6pt,
  stroke: 1.2pt + rgb("#1d154d"),
) = context {
  let arc-stroke = stroke
  assert(type(from) == dictionary, message: "codez.arc: from must be a mark() object")
  assert(type(to) == dictionary, message: "codez.arc: to must be a mark() object")

  let block-a = block
  let block-b = if block-to == none { block } else { block-to }

  let prefix-a = _mark-prefix(block-a, from)
  let prefix-b = _mark-prefix(block-b, to)

  let b1 = codly-bbox-info(prefix-a, from.start, from.end)
  let b2 = codly-bbox-info(prefix-b, to.start, to.end)
  if b1 == none or b2 == none { return none }
  if b1.at("page") != b2.at("page") { return none }

  let a = _pick(b1, from-anchor)
  let b = _pick(b2, to-anchor)

  let here-pos = here().position()
  if here-pos.page != b1.at("page") { return none }

  let ax = a.at(0) - here-pos.x + _offset_for(from-anchor, offset)
  let ay = a.at(1) - here-pos.y
  let bx = b.at(0) - here-pos.x + _offset_for(to-anchor, offset)
  let by = b.at(1) - here-pos.y
  let relx = bx - ax
  let rely = by - ay
  let arc-bend = if relx < 0pt { -bend } else { bend }

  move(dx: ax, dy: ay)[
    #cetz.canvas(length: 1pt, {
      import cetz.draw: *
      bezier(
        (0pt, 0pt),
        (relx, rely),
        (arc-bend, 0pt),
        (relx + arc-bend, rely),
        stroke: arc-stroke,
      )
    })
  ]
}
