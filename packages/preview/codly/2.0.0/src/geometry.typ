#import "wrap.typ" as wrap

// Record cell bounds without measuring or duplicating their contents.
#let cell(body, origin, role: "body") = {
  let fields = if body.func() == grid.cell { body.fields() } else { (body: body) }
  let body = fields.remove("body")
  let fill = fields.remove("fill", default: auto)
  [#grid.cell(fill: none, ..fields, [#metadata((
      fill: fill,
      role: role,
      origin: origin,
    ))#body])<__codly-painted-cell>]
}

#let mark(it, fill, origin, code-column: 1, outside: true, guides: none) = {
  let first = if it.body.func() == metadata { it.body } else { it.body.children.first() }
  if first.value.origin != origin { return it }
  let paint = if first.value.fill == auto { fill(it.x, it.y - 1) } else { first.value.fill }
  if not outside or it.x >= code-column or it.colspan > 1 or paint != none {
    let marks = ()
    if guides != none and it.x == code-column and first.value.role == "body" {
      let depth = guides.depths.at(it.y - 1, default: 0)
      let inset = (
        guides.inset
          + guides.x-offset
          + guides.at("offsets", default: ()).at(it.y - 1, default: 0pt)
      ).to-absolute()
      for level in range(depth) {
        marks.push((
          x: inset + guides.step * level,
          color: guides.palette.at(calc.rem(level + guides.depth-offset, guides.palette.len())),
          thickness: guides.thickness,
          max-height: guides.max-height,
        ))
      }
    }
    place(top + left)[#metadata((
      kind: "cell-start",
      origin: origin,
      x: it.x,
      y: it.y,
      rowspan: it.rowspan,
      fill: paint,
      role: first.value.role,
      guides: marks,
    ))<__codly-geometry>]
    place(bottom + right)[#metadata((kind: "cell-end", origin: origin))<__codly-geometry>]
  }
  it
}

#let region-key(pos) = repr((pos.page, pos.x, pos.y))

#let pages(origin, code-column: 1, outside: true, wraps: none) = {
  let end = query(metadata.where(value: (kind: "paint-end", origin: origin)))
  if end.len() == 0 { return (:) }
  let starts = ()
  let ends = ()
  let tops = ()
  let bottoms = ()
  // Location equality also separates nested blocks at identical page positions.
  for mark in query(selector(<__codly-geometry>).after(origin).before(end.first().location())) {
    if mark.value.origin != origin { continue }
    if mark.value.kind == "cell-start" { starts.push(mark) } else if mark.value.kind == "cell-end" {
      ends.push(mark)
    } else if mark.value.kind == "region-start" { tops.push(mark) } else { bottoms.push(mark) }
  }
  if tops.len() != bottoms.len() { return (:) }
  let regions = ()
  let by-page = (:)
  for (i, top) in tops.enumerate() {
    let at = top.location().position()
    let bottom = bottoms.at(i).location().position().y
    let page = str(at.page)
    if page not in by-page { by-page.insert(page, ()) }
    by-page.at(page).push(i)
    regions.push((
      at: at,
      bottom: bottom,
      width: top.value.width,
      body-top: at.y,
      body-bottom: bottom,
      cells: (),
      numbers: (),
    ))
  }
  let spans = ()
  let rows = (:)
  let gutter = 0pt
  for (i, start) in starts.enumerate() {
    let a = start.location().position()
    let b = ends.at(i).location().position()
    let region = none
    for index in by-page.at(str(a.page), default: ()) {
      let r = regions.at(index)
      if a.x >= r.at.x and a.x < r.at.x + r.width and a.y >= r.at.y and a.y <= r.bottom {
        region = index
        break
      }
    }
    if region == none { continue }
    let value = start.value
    if value.role == "body" {
      spans.push((value: value, a: a, b: b, region: region))
      if value.x == code-column {
        rows.insert(str(value.y), (a: a, region: region))
        if outside { gutter = a.x - regions.at(region).at.x }
      }
    } else {
      regions.at(region).cells.push((a: a, b: b, fill: value.fill, guides: ()))
      if value.role == "header" {
        regions.at(region).body-top = calc.max(regions.at(region).body-top, b.y)
      }
      if value.role == "footer" {
        regions.at(region).body-bottom = calc.min(regions.at(region).body-bottom, a.y)
      }
    }
  }
  // A cell owns its fill until the next logical row, including continuation regions.
  for span in spans {
    let next = rows.at(str(span.value.y + span.value.rowspan), default: none)
    let last = if next == none { regions.len() - 1 } else { next.region }
    let index = span.region
    while index <= last {
      let r = regions.at(index)
      let top = if index == span.region { span.a.y } else { r.body-top }
      let bottom = if next != none and index == last { next.a.y } else { r.body-bottom }
      let dx = r.at.x - regions.at(span.region).at.x
      if bottom > top {
        let a = (x: span.a.x + dx, y: top)
        let b = (x: span.b.x + dx, y: bottom)
        if outside and span.value.x < code-column {
          regions.at(index).numbers.push((a: a, b: b, fill: span.value.fill))
        } else {
          let guides = if index == span.region { span.value.guides } else {
            span.value.guides.filter(g => g.max-height == none)
          }
          regions
            .at(index)
            .cells
            .push((
              a: a,
              b: b,
              fill: span.value.fill,
              guides: guides,
            ))
        }
      }
      index += 1
    }
  }
  let pages = (:)
  let markers = if wraps == none { () } else {
    wrap.marks(wraps.owner, end.first().location(), regions)
  }
  for r in regions {
    let local-markers = ()
    for marker in markers {
      let p = marker.at
      if (
        p.page != r.at.page
          or p.x < r.at.x
          or p.x > r.at.x + r.width
          or p.y < r.body-top
          or p.y >= r.body-bottom
      ) { continue }
      local-markers.push(marker)
    }
    pages.insert(region-key(r.at), (
      origin: r.at,
      left: r.at.x + gutter,
      top: r.at.y,
      bottom: r.bottom,
      cells: r.cells,
      numbers: r.numbers,
      wraps: local-markers,
    ))
  }
  pages
}

#let background(
  origin,
  width,
  radius,
  stroke,
  code-column: 1,
  outside: true,
  wraps: none,
  padding: (top: 0pt, right: 0pt, bottom: 0pt, left: 0pt),
  padding-fill: none,
) = context {
  let at = here().position()
  let page = pages(origin, code-column: code-column, outside: outside, wraps: wraps).at(
    region-key(at),
    default: none,
  )
  if page != none {
    for cell in page.numbers {
      if cell.fill != none {
        place(top + left, dx: cell.a.x - at.x, dy: cell.a.y - page.top, rect(
          width: cell.b.x - cell.a.x,
          height: cell.b.y - cell.a.y,
          fill: cell.fill,
          stroke: none,
        ))
      }
    }
    let code-left = (
      (if page.left == none { at.x } else { page.left }) - if outside { 0pt } else { padding.left }
    )
    let frame-top = page.top - padding.top
    place(top + left, dx: code-left - at.x, dy: frame-top - at.y, block(
      width: at.x + width - code-left + padding.right,
      height: page.bottom - page.top + padding.top + padding.bottom,
      radius: radius,
      stroke: stroke,
      clip: true,
      {
        // Paint only the new edge space: a block-wide fill would repaint
        // intentionally transparent rows, headers, and footers as well.
        if padding-fill != none {
          let frame-width = at.x + width - code-left + padding.right
          let frame-height = page.bottom - page.top + padding.top + padding.bottom
          for (x, y, w, h) in (
            (0pt, 0pt, frame-width, padding.top),
            (0pt, frame-height - padding.bottom, frame-width, padding.bottom),
            (
              0pt,
              padding.top,
              if outside { 0pt } else { padding.left },
              frame-height - padding.top - padding.bottom,
            ),
            (
              frame-width - padding.right,
              padding.top,
              padding.right,
              frame-height - padding.top - padding.bottom,
            ),
          ) {
            if w > 0pt and h > 0pt {
              place(top + left, dx: x, dy: y, rect(
                width: w,
                height: h,
                fill: padding-fill,
                stroke: none,
              ))
            }
          }
        }
        for cell in page.cells {
          if cell.fill != none {
            let x = calc.max(code-left, cell.a.x)
            place(top + left, dx: x - code-left, dy: cell.a.y - frame-top, rect(
              width: cell.b.x - x,
              height: cell.b.y - cell.a.y,
              fill: cell.fill,
              stroke: none,
            ))
          }
          for guide in cell.guides {
            let x = cell.a.x + guide.x
            if cell.a.x <= x and x < cell.b.x {
              place(top + left, dx: x - code-left, dy: cell.a.y - frame-top, pdf.artifact(line(
                end: (
                  0pt,
                  if guide.max-height == none { cell.b.y - cell.a.y } else {
                    calc.min(guide.max-height, cell.b.y - cell.a.y)
                  },
                ),
                stroke: guide.color + guide.thickness,
              )))
            }
          }
        }
      },
    ))
  }
}

#let wrap-foreground(origin, wraps) = context {
  let at = here().position()
  let start = none
  for record in query(selector(<__codly-geometry>).after(origin).before(here())) {
    if record.value.origin != origin or record.value.kind != "region-start" { continue }
    let position = record.location().position()
    if position.page == at.page and position.x == at.x { start = record }
  }
  if start == none { return }
  let position = start.location().position()
  let region = (
    page: at.page,
    x: position.x,
    top: position.y,
    bottom: at.y,
    width: start.value.width,
  )
  for marker in wrap.marks-region(wraps.owner, here(), region) {
    place(top + left, dx: marker.at.x - at.x, dy: marker.at.y - at.y, pdf.artifact(text(
      top-edge: "baseline",
      bottom-edge: "baseline",
      marker.body,
    )))
  }
}

#let outside(
  columns,
  inset,
  align,
  fill,
  stroke,
  radius,
  header,
  items,
  footer,
  code-column: 1,
  outside: true,
  guides: none,
  wraps: none,
  padding: (top: 0pt, right: 0pt, bottom: 0pt, left: 0pt),
  padding-fill: none,
  gutter: none,
  column-gutter: none,
  row-gutter: none,
) = context {
  let origin = here()
  let cells = ()
  for item in items { cells.push(cell(item, origin)) }
  let headers = ()
  if header.len() > 0 {
    let h = header.first()
    let fields = h.children.first().fields()
    fields.y = 1
    let body = fields.remove("body")
    headers.push(grid.header(repeat: h.repeat, level: 2, cell(
      grid.cell(..fields, body),
      origin,
      role: "header",
    )))
  }
  let footers = ()
  let end = grid.cell(colspan: columns.len(), inset: 0pt, [
    #metadata((kind: "region-end", origin: origin))<__codly-geometry>
    #if wraps != none { wrap-foreground(origin, wraps) }
  ])
  if footer.len() > 0 {
    let f = footer.first()
    let content = cell(f.children.first(), origin, role: "footer")
    if f.repeat {
      footers.push(grid.footer(repeat: true, content, end))
    } else {
      cells.push(content)
      footers.push(grid.footer(repeat: true, end))
    }
  } else {
    footers.push(grid.footer(repeat: true, end))
  }
  show <__codly-painted-cell>: it => mark(
    it,
    fill,
    origin,
    code-column: code-column,
    outside: outside,
    guides: guides,
  )
  let gutters = (:)
  if gutter != none { gutters.insert("gutter", gutter) }
  if column-gutter != none { gutters.insert("column-gutter", column-gutter) }
  if row-gutter != none { gutters.insert("row-gutter", row-gutter) }
  grid(
    columns: columns, inset: inset, align: align, stroke: none, fill: none,
    ..gutters,
    grid.header(repeat: true, level: 1, grid.cell(
      colspan: columns.len(),
      inset: 0pt,
      layout(size => {
        [#metadata((kind: "region-start", origin: origin, width: size.width))<__codly-geometry>]
        background(
          origin,
          size.width,
          radius,
          stroke,
          code-column: code-column,
          outside: outside,
          wraps: none,
          padding: padding,
          padding-fill: padding-fill,
        )
      }),
    )),
    ..headers, ..cells, ..footers,
  )
  metadata((kind: "paint-end", origin: origin))
}
