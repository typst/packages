// drawio — render draw.io / diagrams.net files in Typst.
//
// The default "plugin" engine runs draw.io's own code (mxGraph, Graph.js,
// Shapes.js and the stencil libraries) in a WebAssembly plugin and replays
// its drawing commands with Typst primitives: shapes and edges become
// `curve`s, labels become real Typst text, images stay images. The "native"
// engine (native.typ) is a pure-Typst approximation kept as a fallback.
//
// Usage:
//   #import "@local/drawio:0.1.0": drawio
//   #drawio(read("diagram.drawio", encoding: none))

#import "native.typ" as native

#let _plugin = plugin("drawio.wasm")

// ───────────────────────── Paint ─────────────────────────

#let _stroke(it, s) = {
  if it.at("stroke", default: none) == none { return none }
  let dash = it.at("dash", default: none)
  stroke(
    paint: rgb(it.stroke),
    thickness: it.sw * s,
    dash: if dash == none { none } else { dash.map(d => d * s) },
    cap: it.at("cap", default: "butt"),
    join: it.at("join", default: "miter"),
    miter-limit: it.at("miter", default: 10),
  )
}

#let _fill(it) = {
  let g = it.at("grad", default: none)
  if g != none {
    if g.radial { gradient.radial(rgb(g.a), rgb(g.b)) } else {
      gradient.linear(rgb(g.a), rgb(g.b), angle: g.ang * 1deg)
    }
  } else if it.at("fill", default: none) != none { rgb(it.fill) } else { none }
}

#let _segments(d, s, dx: 0, dy: 0) = d.map(seg => {
  let op = seg.at(0)
  let p(i) = ((seg.at(i) + dx) * s, (seg.at(i + 1) + dy) * s)
  if op == "m" { curve.move(p(1)) } else if op == "l" { curve.line(p(1)) } else if op == "c" {
    curve.cubic(p(1), p(3), p(5))
  } else if op == "q" { curve.quad(p(1), p(3)) } else { curve.close(mode: "straight") }
})

// A shape's shadow (see endShape in glue.js): the filled parts as one curve,
// so overlapping parts form one outline and don't darken each other, plus
// shadows of stroke-only parts. Typst has no blur: it is approximated with
// four fainter copies spread over the blur radius.
#let _shadow(it, s) = {
  let c = rgb(it.c)
  let b = it.at("blur", default: 0) * s / 2
  let copies = if b > 0pt { ((-b, -b), (b, -b), (-b, b), (b, b)) } else { ((0pt, 0pt),) }
  let col = if copies.len() > 1 { c.transparentize(100% - (100% - c.components().at(3, default: 100%)) / 2) } else { c }
  for (ox, oy) in copies {
    let dx = it.dx + ox / s
    let dy = it.dy + oy / s
    if it.fills.len() > 0 {
      place(top + left, curve(fill: col, stroke: none, ..it.fills.map(d => _segments(d, s, dx: dx, dy: dy)).flatten()))
    }
    for st in it.strokes {
      let dash = st.at("dash", default: none)
      place(top + left, curve(stroke: stroke(paint: col, thickness: st.sw * s,
        dash: if dash == none { none } else { dash.map(v => v * s) },
        cap: st.at("cap", default: "butt"), join: st.at("join", default: "miter")),
        .._segments(st.d, s, dx: dx, dy: dy)))
    }
  }
}

#let _path(it, s) = {
  let fill = _fill(it)
  let sk = _stroke(it, s)
  let sh = it.at("shadow", default: none)
  if sh != none {
    let c = rgb(sh.c)
    place(top + left, curve(
      fill: if fill != none { c } else { none },
      stroke: if sk != none { stroke(paint: c, thickness: sk.thickness, dash: sk.dash, cap: sk.cap, join: sk.join) } else { none },
      .._segments(it.d, s, dx: sh.dx, dy: sh.dy),
    ))
  }
  place(top + left, curve(fill: fill, stroke: sk, .._segments(it.d, s)))
}

// ───────────────────────── Images ─────────────────────────

#let _image(it, s) = {
  if it.at("data", default: none) == none { return }
  let w = it.w * s
  let h = it.h * s
  let img = image(it.data, format: it.fmt, width: w, height: h, fit: it.fit)
  let fh = it.at("fh", default: false)
  let fv = it.at("fv", default: false)
  if fh or fv { img = scale(x: if fh { -100% } else { 100% }, y: if fv { -100% } else { 100% }, img) }
  if it.rot != 0 { img = rotate(it.rot * 1deg, img) }
  place(top + left, dx: it.cx * s - w / 2, dy: it.cy * s - h / 2, img)
}

// ───────────────────────── Text ─────────────────────────

// Font of a draw.io family name (e.g. "Helvetica" or "Verdana, sans-serif"),
// for `font: "drawio"` or a substitution map: each family goes through `map`
// (keys compared case-insensitively; values are a family or a list), CSS
// generic names are dropped unless mapped, and `fallback` (the document font)
// comes last. Returns none for no usable family.
#let _family(name, map, fallback) = {
  if name == none { return none }
  let generic = ("serif", "sans-serif", "monospace", "cursive", "fantasy", "system-ui", "inherit", "initial")
  let out = ()
  for n in str(name).split(",") {
    let n = n.trim().trim("\"").trim("'").trim()
    if n == "" { continue }
    let m = map.at(lower(n), default: none)
    // code (<code>, <pre>) uses the CSS generic "monospace": Typst's bundled mono font
    if m == none and lower(n) == "monospace" { m = "DejaVu Sans Mono" }
    if m != none { out += if type(m) == array { m } else { (m,) } } else if lower(n) not in generic { out.push(n) }
  }
  if out.len() == 0 { return none }
  out + if type(fallback) == array { fallback } else { (fallback,) }
}

// `shadow`: none, or a colour that replaces all text colours (for text shadows)
#let _run(r, base, s, family, shadow: none) = {
  let body = [#r.t]
  if r.at("sup", default: 0) == 1 { body = super(body) }
  if r.at("sub", default: 0) == 1 { body = sub(body) }
  if r.at("u", default: base.at("u", default: 0)) == 1 { body = underline(body) }
  if r.at("s", default: base.at("s", default: 0)) == 1 { body = strike(body) }
  if r.at("bg", default: none) != none and shadow == none { body = highlight(fill: rgb(r.bg), body) }
  if r.at("href", default: none) != none { body = link(r.href, body) }
  let f = if family != none { family(r.at("f", default: none)) } else { none }
  if f != none { body = text(font: f, body) }
  text(
    size: r.at("sz", default: base.sz) * s,
    weight: if r.at("b", default: base.at("b", default: 0)) == 1 { "bold" } else { "regular" },
    style: if r.at("i", default: base.at("i", default: 0)) == 1 { "italic" } else { "normal" },
    fill: if shadow != none { shadow } else { rgb(r.at("c", default: base.c)) },
    body,
  )
}

#let _halign = (left: left, center: center, right: right, justify: left)

// `family`: none, or a function from a draw.io family name to a Typst font
// list (or none), used with `font: "drawio"` or a substitution map.
#let _label-body(it, s, font, family, shadow: none) = {
  let label-font = if family != none { family(it.at("f", default: none)) } else { none }
  // Label text styles, applied to the result and to the measurements below
  // (`measure` doesn't see set rules of the enclosing function).
  let styled(body) = {
    // HTML labels use line-height 1.2 with the glyphs centred in the line box.
    set text(top-edge: 0.95em, bottom-edge: -0.25em, size: it.sz * s, hyphenate: false)
    set text(font: font) if font != auto and family == none
    set text(font: label-font) if label-font != none
    set par(leading: 0pt, spacing: 0pt, justify: false, first-line-indent: 0pt, hanging-indent: 0pt)
    set text(dir: rtl) if it.at("dir", default: none) == "rtl"
    body
  }
  let run-body(l) = if l.runs.len() == 0 {
    // empty line: keeps the height of one line
    text(size: it.sz * s, hide[x])
  } else { l.runs.map(r => _run(r, it, s, family, shadow: shadow)).join() }
  let indent(l, body) = {
    let (li, ri) = (l.at("ind", default: 0), l.at("indr", default: 0))
    if li > 0 or ri > 0 { pad(left: li * s, right: ri * s, body) } else { body }
  }
  // Length from a draw.io/HTML size: px number, "N%" of `avail`, or none
  let size-of(v, avail) = if v == none { none } else if type(v) == str and v.ends-with("%") {
    if avail == none { none } else { avail * float(v.trim("%")) / 100 }
  } else { v * s }

  // A list of lines (a label, or a table cell) as content. `al`: default
  // alignment; `maxw`: wrapping width (none: unbounded); `fill`: no own box
  // (table cells, which take their column's width); `boxh`: available height;
  // `table-of`: the table renderer below (passed in, as it calls back here).
  let block-of(lines, al, maxw, fill, boxh, table-of) = {
    let ta = _halign.at(al, default: center)
    let line-body(l, width) = {
      if l.at("tbl", default: none) != none { return table-of(l.tbl, al, width, boxh) }
      if l.at("hr", default: 0) == 1 {
        // <hr>: a grey rule across the block
        return indent(l, line(length: 100%, stroke: s + rgb("#9a9a9a")))
      }
      let a = l.at("align", default: al)
      let b = indent(l, run-body(l))
      // justified lines: spread when wrapped (the last line stays left, like CSS)
      if a == "justify" and (it.wrap or fill) { b = par(justify: true, b) }
      // a block's background (e.g. <div style="background: ...">) spans the line
      let bg = l.at("bg", default: none)
      let p = l.at("pad", default: 0) * s
      if bg != none or p > 0pt {
        block(width: 100%, fill: if bg != none { rgb(bg) } else { none }, inset: p, spacing: 0pt,
          align(_halign.at(if a == none { al } else { a }, default: left), b))
      } else { b }
    }
    let natural(l) = if l.at("tbl", default: none) != none {
      let w = size-of(l.tbl.at("w", default: none), maxw)
      if w != none { w } else { measure(styled(table-of(l.tbl, al, none, none))).width }
    } else {
      measure(styled(line-body(l, none))).width + (l.at("ind", default: 0) + l.at("indr", default: 0)) * s
    }
    // Like draw.io's label block (an inline-block): as wide as its widest line,
    // at most the wrapping width; lines are aligned within it.
    // (+0.01pt so that rounding never wraps a line that fits)
    let width = if fill { none } else {
      let widest = calc.max(..lines.map(natural)) + 0.01pt
      if maxw != none and (it.wrap or lines.any(l => l.at("tbl", default: none) != none)) {
        calc.min(widest, maxw)
      } else { widest }
    }
    let items = ()
    for l in lines {
      if l.at("mt", default: 0) > 0 { items.push(l.mt * s) }
      let a = l.at("align", default: al)
      items.push(align(_halign.at(if a == none { al } else { a }, default: ta), line-body(l, width)))
      if l.at("mb", default: 0) > 0 { items.push(l.mb * s) }
    }
    if fill { stack(..items) } else { box(width: width, stack(..items)) }
  }

  // HTML <table> (see table() in glue.js) as a Typst table
  let table-of(t, al, avail, boxh) = {
    let rows = t.rows.filter(r => r.cells.len() > 0)
    if rows.len() == 0 { return none }
    let ncols = calc.max(..rows.map(r => r.cells.map(c => c.at("cs", default: 1)).sum()))
    let border = t.at("border", default: 0)
    let default-stroke = if border > 0 { border * s + black } else { none }
    let stroke-of(b) = if b == none { auto } else if b.w == 0 { none } else { b.w * s + rgb(b.c) }
    let collapse = t.at("collapse", default: false)
    let cell-al(c) = c.at("al", default: al)
    let cell-content(c) = block-of(c.lines, cell-al(c), none, true, none, table-of)
    let tw = size-of(t.at("w", default: none), avail)
    let th = size-of(t.at("h", default: none), boxh)
    // column widths: like a browser's automatic layout, wider content gets
    // more of the table width
    let columns = if tw == none { (auto,) * ncols } else {
      let widths = (0pt,) * ncols
      for r in rows {
        let col = 0
        for c in r.cells {
          let n = c.at("cs", default: 1)
          if n == 1 and col < ncols {
            let w = measure(styled(cell-content(c))).width + 2 * t.pad * s
            if w > widths.at(col) { widths.at(col) = w }
          }
          col += n
        }
      }
      widths.map(w => calc.max(w / 1pt, 1) * 1fr)
    }
    let cells = ()
    for r in rows {
      for c in r.cells {
        let va = c.at("va", default: "middle")
        let v = if va == "top" { top } else if va == "bottom" { bottom } else { horizon }
        let fillc = c.at("bg", default: r.at("bg", default: none))
        let pad = c.at("pad", default: t.pad) * s
        let st = stroke-of(c.at("bd", default: r.at("bd", default: none)))
        cells.push(table.cell(
          ..if st != auto { (stroke: st) } else { (:) },
          colspan: c.at("cs", default: 1),
          rowspan: c.at("rs", default: 1),
          fill: if fillc != none { rgb(fillc) } else { none },
          align: _halign.at(cell-al(c), default: center) + v,
          inset: pad,
          cell-content(c),
        ))
      }
    }
    let gutter = if collapse or border == 0 { 0pt } else { t.at("spacing", default: 2) * s }
    let tbl = table(
      columns: columns,
      rows: if th != none { (1fr,) * rows.len() } else { auto },
      stroke: default-stroke,
      column-gutter: gutter,
      row-gutter: gutter,
      ..cells,
    )
    let frame = stroke-of(t.at("bd", default: none))
    box(
      width: if tw != none { tw } else { auto },
      height: if th != none { th } else { auto },
      fill: if t.at("bg", default: none) != none { rgb(t.bg) } else { none },
      stroke: if frame != auto { frame } else if not collapse and border > 0 { default-stroke } else { none },
      inset: if not collapse and border > 0 { gutter } else { 0pt },
      tbl,
    )
  }

  let maxw = if it.wrap { it.ww } else if it.lines.any(l => l.at("tbl", default: none) != none) { it.w } else { none }
  let boxh = if it.h > 2 { it.h * s } else { none }
  styled(block-of(it.lines, it.al, maxw, false, boxh, table-of))
}

// Outline text (see plugin/js/outline.js): glyph outlines drawn as shapes,
// and an invisible text layer on top so that the text stays selectable and
// searchable. `glyphs`: font -> (upem, g: glyph id -> path segments in font
// units); `shadow`: none, or a colour replacing all colours.
// One glyph as a curve at the origin (`k`: length per font unit). Every
// occurrence of a glyph at a size and colour is the same content, placed with
// an offset: Typst memoizes this function, and the identical drawing commands
// compress to almost nothing in the PDF. none for glyphs without outline.
#let _glyph-curve(segs, k, color) = {
  if segs.len() == 0 { return none }
  let p(seg, j) = (seg.at(j) * k, seg.at(j + 1) * k)
  curve(fill: color, stroke: none, ..segs.map(seg => {
    let op = seg.at(0)
    if op == "m" { curve.move(p(seg, 1)) } else if op == "l" { curve.line(p(seg, 1)) } else if op == "q" {
      curve.quad(p(seg, 1), p(seg, 3))
    } else if op == "c" { curve.cubic(p(seg, 1), p(seg, 3), p(seg, 5)) } else { curve.close(mode: "straight") }
  }))
}

#let _outline-body(ol, s, glyphs, shadow: none) = box(width: ol.w * s, height: ol.h * s, {
  for it in ol.items {
    if it.k == "g" {
      let gt = glyphs.at(it.f)
      let k = it.sz / gt.upem * s
      let g = it.g
      let color = if shadow != none { shadow } else { rgb(it.c) }
      for i in range(0, g.len(), step: 3) {
        let c = _glyph-curve(gt.g.at(str(g.at(i))), k, color)
        if c != none { place(top + left, dx: (it.x + g.at(i + 1)) * s, dy: (it.y + g.at(i + 2)) * s, c) }
      }
    } else if it.k == "r" {
      let fill = if shadow != none { shadow } else { rgb(it.c) }
      place(top + left, dx: it.x * s, dy: it.y * s, rect(width: it.w * s, height: it.h * s, fill: fill, stroke: none))
    } else if it.k == "s" and shadow == none {
      // invisible text, stretched to the width of the drawn line
      let t = text(size: it.sz * s, fill: rgb(0, 0, 0, 0), top-edge: "ascender", bottom-edge: "descender", it.t)
      let natural = measure(t).width
      if natural > 0pt {
        place(top + left, dx: it.x * s, dy: it.y * s, box(width: it.w * s, height: it.h * s, align(left + horizon,
          scale(x: it.w * s / natural * 100%, origin: left, reflow: true, t))))
      }
    } else if it.k == "a" and shadow == none {
      place(top + left, dx: it.x * s, dy: it.y * s, link(it.href, box(width: it.w * s, height: it.h * s)))
    }
  }
})

#let _text(it, s, font, glyphs) = context {
  let it = it
  it.w = it.w * s
  it.ww = it.at("ww", default: it.w / s) * s
  // font: "drawio" or a substitution map -> the diagram's own fonts
  let fallback = text.font
  let family = if font == "drawio" or type(font) == dictionary {
    let map = (:)
    if type(font) == dictionary { for (k, v) in font { map.insert(lower(k), v) } }
    name => _family(name, map, fallback)
  } else if font == auto {
    // document font, except code keeps a monospace font
    name => if name != none and lower(str(name)) == "monospace" { ("DejaVu Sans Mono",) + if type(fallback) == array { fallback } else { (fallback,) } } else { none }
  } else { none }
  let ol = it.at("ol", default: none)
  let body = if ol != none { _outline-body(ol, s, glyphs) } else { _label-body(it, s, font, family) }
  // text shadow: the same label in the shadow colour, offset, drawn underneath
  let sh = it.at("shadow", default: none)
  if sh != none {
    // Typst has no blur: approximate draw.io's blurred drop-shadow with four
    // fainter copies spread over the blur radius
    let c = rgb(sh.c)
    let b = sh.at("blur", default: 0) * s / 2
    let copies = if b > 0pt { ((-b, -b), (b, -b), (-b, b), (b, b)) } else { ((0pt, 0pt),) }
    let faint = c.transparentize(100% - (100% - c.components().at(3, default: 100%)) / copies.len())
    let shadow-color = if copies.len() > 1 { faint } else { c }
    let shadow-body = if ol != none { _outline-body(ol, s, glyphs, shadow: shadow-color) } else {
      _label-body(it, s, font, family, shadow: shadow-color)
    }
    body = box({
      for (ox, oy) in copies { place(top + left, dx: sh.dx * s + ox, dy: sh.dy * s + oy, shadow-body) }
      body
    })
  }
  let m = measure(body)
  let cw = m.width
  let ch = m.height
  let clip = it.at("clip", default: none)
  if clip != none and ch > clip * s {
    body = box(width: cw, height: clip * s, clip: true, body)
    ch = clip * s
  }
  let bg = it.at("bg", default: none)
  let bd = it.at("bd", default: none)
  if bg != none or bd != none {
    let pad = it.at("pad", default: (0, 0, 0, 0)).map(v => v * s)
    body = box(
      fill: if bg != none { rgb(bg) } else { none },
      stroke: if bd != none { rgb(bd) + it.bw * s } else { none },
      outset: (top: pad.at(0), right: pad.at(1), bottom: pad.at(2), left: pad.at(3)),
      body,
    )
  }
  let bw = it.w
  let bh = it.h * s
  let x = it.x * s + if it.al == "left" { 0pt } else if it.al == "right" { bw - cw } else { (bw - cw) / 2 }
  let y = it.y * s + if it.va == "top" { 0pt } else if it.va == "bottom" { bh - ch } else { (bh - ch) / 2 }
  let rot = it.at("rot", default: 0)
  if rot == 0 {
    place(top + left, dx: x, dy: y, body)
  } else {
    // rotate about the label anchor, like mxSvgCanvas2D
    let ax = it.ax * s
    let ay = it.ay * s
    place(top + left, dx: ax, dy: ay, rotate(rot * 1deg, origin: top + left, reflow: false,
      box(width: 0pt, height: 0pt, place(top + left, dx: x - ax, dy: y - ay, body))))
  }
}

// ───────────────────────── Public API ─────────────────────────

#let _render-plugin(data, page, padding, theme: "light", text: "native", list-only: false) = {
  let opts = json.encode((page: page, border: padding, theme: theme, text: text, listOnly: list-only), pretty: false)
  cbor(_plugin.render(data, bytes(opts)))
}

#let _draw(r, s, font, background) = {
  let glyphs = r.at("glyphs", default: (:))
  let items = r.items.map(it => {
    if it.k == "p" { _path(it, s) } else if it.k == "sh" { _shadow(it, s) } else if it.k == "t" { _text(it, s, font, glyphs) } else if it.k == "i" {
      _image(it, s)
    }
  })
  box(
    width: r.w * s,
    height: r.h * s,
    fill: if background == auto { if r.bg != none { rgb(r.bg) } else { none } } else { background },
    items.join(),
  )
}

// Accepts a `path(...)` (resolved relative to the calling file, Typst ≥ 0.15),
// file contents as bytes, or XML text; returns the bytes.
#let _source(source) = {
  if type(source) == path { return read(source, encoding: none) }
  if type(source) == bytes { return source }
  if type(source) == str {
    if source.trim().starts-with("<") { return bytes(source) }
    panic(
      "drawio: pass the file as a path: drawio(path(" + repr(source) + ")). "
        + "A plain string would be looked up inside the package, not in your project.",
    )
  }
  panic("drawio: expected path(...), bytes or XML text, found " + str(type(source)))
}

// Length (or ratio/relative to `available`) -> absolute length.
#let _resolve(v, available) = {
  if type(v) == ratio { available * (v / 100%) } else if type(v) == relative {
    available * (v.ratio / 100%) + v.length
  } else { v }
}

/// Renders a draw.io diagram.
///
/// ```typ
/// #drawio(path("diagrams/arch.drawio"), width: 100%)
/// ```
///
/// - source (path, bytes, str): the file, as `path("diagram.drawio")` (relative to
///   your file, like `image`), or its contents (`read(..., encoding: none)`).
///   Plain and compressed `.drawio` / `.xml` files and `.drawio.svg` exports work.
/// - page (int, str): page index (0-based) or page name.
/// - width (auto, length, ratio): width of the diagram; the height follows.
/// - height (auto, length, ratio): height of the diagram; the width follows. With
///   both, the diagram is scaled to fit inside the box, keeping its proportions.
/// - scale (float): with no width or height, multiplier on the natural size
///   (1 draw.io px = 0.75pt).
/// - padding (int, float): empty margin around the diagram, in draw.io px.
/// - font (str, auto, array, dictionary): font for native text (`text:
///   "native"`, and labels outline text can't draw). `"drawio"` (default)
///   uses the fonts set in the diagram, falling back to the document's font
///   (with a warning) when Typst doesn't have them; a dictionary also uses the
///   diagram's fonts, through substitutions, e.g.
///   `("Helvetica": "Nimbus Sans", "Verdana": "DejaVu Sans")`; `auto` uses the
///   document's font; a font name or list uses that font.
/// - theme (str): `"light"` or `"dark"`: which colour of draw.io's `light-dark()`
///   pairs to use, like draw.io's light/dark appearance.
/// - background (none, auto, color, gradient): fill behind the diagram. `none`
///   (default) is transparent; `auto` uses the diagram's background colour (or
///   draw.io's dark page colour with `theme: "dark"`); or give any fill.
/// - text (str): `"outline"` (default): labels are laid out in the plugin
///   with bundled fonts that have the metrics of draw.io's fonts
///   (Helvetica/Arial, Times New Roman, Courier New) and drawn as shapes, so
///   they look like draw.io everywhere without installing fonts; an invisible
///   text layer keeps them selectable and searchable. Labels with other
///   scripts or right-to-left text are drawn as native text. `"native"`:
///   labels are Typst text, laid out by Typst in the fonts given by `font`.
/// - engine (str): `"plugin"` (draw.io's own renderer) or `"native"` (pure Typst approximation).
#let drawio(
  source,
  page: 0,
  width: auto,
  height: auto,
  scale: 1.0,
  padding: 0,
  font: "drawio",
  theme: "light",
  background: none,
  text: "outline",
  engine: "plugin",
) = {
  assert(theme in ("light", "dark"), message: "drawio: theme must be \"light\" or \"dark\"")
  assert(text in ("native", "outline"), message: "drawio: text must be \"native\" or \"outline\"")
  let data = _source(source)
  if engine == "native" {
    assert(height == auto, message: "drawio: height is not supported by the native engine; use width or scale")
    return native.drawio(data, page: page, scale: scale, width: width, padding: padding)
  }
  assert(engine == "plugin", message: "drawio: engine must be \"plugin\" or \"native\"")
  let r = _render-plugin(data, page, padding, theme: theme, text: text)
  // labels that outline text can't draw (other scripts, right-to-left) use
  // the document font unless a font was given: draw.io's Helvetica would
  // rarely cover them and only warn
  let font = if text == "outline" and font == "drawio" { auto } else { font }
  if r.w == 0 or r.h == 0 { return box() }
  if width == auto and height == auto {
    _draw(r, 0.75pt * scale, font, background)
  } else {
    layout(size => {
      let sw = if width == auto { none } else { _resolve(width, size.width) / r.w }
      let sh = if height == auto { none } else { _resolve(height, size.height) / r.h }
      let s = if sw == none { sh } else if sh == none { sw } else { calc.min(sw, sh) }
      _draw(r, s, font, background)
    })
  }
}

/// Returns the names of all pages in a draw.io file (unnamed pages are
/// reported as "Page-1", "Page-2", … like draw.io does).
///
/// - source (path, bytes, str): as for `drawio`.
#let drawio-pages(source) = _render-plugin(_source(source), 0, 0, list-only: true).pages
