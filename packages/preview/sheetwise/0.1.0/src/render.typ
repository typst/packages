#import "constants.typ": _default-mark-style, _disabled-marks, registration-color
#import "grid.typ": *
#import "marks.typ": *
#import "validate.typ": *

#let _normalize-slug(slug, meta: (:)) = {
  if slug == none or slug == false {
    none
  } else if type(slug) == str {
    slug
  } else if type(slug) == dictionary {
    if _has-key(slug, "enabled") and not slug.enabled {
      return none
    }

    let parts = ()
    if _has-key(slug, "job") { parts.push(slug.job) }
    if _has-key(slug, "date") and slug.date != false {
      let date = if slug.date == auto { datetime.today() } else { slug.date }
      parts.push(repr(date))
    }
    if _get(slug, "sheet", false) and _has-key(meta, "sheet-number") {
      parts.push("sheet " + str(meta.at("sheet-number")) + "/" + str(meta.at("sheet-count")))
    }
    if _has-key(meta, "side") { parts.push(str(meta.side)) }
    if _get(slug, "grid", false) and _has-key(meta, "plan") {
      let plan = meta.plan
      parts.push(str(plan.columns) + " x " + str(plan.rows))
    }
    if _get(slug, "bleed", false) and _has-key(meta, "bleed") {
      parts.push("bleed " + repr(meta.bleed))
    }
    if _get(slug, "cut-mode", false) and _has-key(meta, "cut-mode") {
      parts.push("cut " + meta.at("cut-mode"))
    }
    if _has-key(slug, "text") { parts.push(slug.text) }

    if parts.len() == 0 { none } else { parts.join(" | ") }
  } else {
    panic("sheetwise: `slug` must be `none`, a string, or a dictionary.")
  }
}

#let _slug(sheet, message) = {
  if message != none {
    place(top + left, dx: 4mm, dy: sheet.height - 7mm)[
      #text(size: 6pt, fill: cmyk(0%, 0%, 0%, 70%))[#message]
    ]
  }
}

#let _sheet(sheet, body, slug: none, meta: (:), marks: _disabled-marks, mark-style: _default-mark-style, fold-x: auto, fold-y: auto) = {
  block(width: sheet.width, height: sheet.height)[
    #body
    #_sheet-marks(sheet, marks, mark-style, fold-x: fold-x, fold-y: fold-y)
    #_slug(sheet, _normalize-slug(slug, meta: meta))
  ]
}

#let _sheet-meta(sheet-number, sheet-count, side, plan: none, bleed: none, cut-mode: none) = {
  let meta = (sheet-number: sheet-number, sheet-count: sheet-count, side: side)
  if plan != none { meta.insert("plan", plan) }
  if bleed != none { meta.insert("bleed", bleed) }
  if cut-mode != none { meta.insert("cut-mode", cut-mode) }
  meta
}

#let _draw-context(sheet, plan, bleed, safe, marks, mark-style, crop-mode) = (
  sheet: sheet,
  plan: plan,
  bleed: bleed,
  safe: safe,
  marks: marks,
  mark-style: mark-style,
  crop-mode: crop-mode,
)

#let _imposition-context(
  paper,
  orientation,
  trim-size,
  item-size,
  item-orientation,
  margin,
  gap,
  rows,
  columns,
  cut-mode,
  bleed,
  safe,
  marks,
  mark-style,
) = {
  let sheet = paper-size(paper, orientation: orientation)
  let trim = _resolve-trim-size(trim-size, item-size: item-size)
  let bleed = _non-negative(bleed, "bleed")
  let safe = _non-negative(safe, "safe")
  let plan = _grid-plan(sheet, trim, margin, gap, rows, columns, item-orientation: item-orientation)
  _validate-cut-mode(cut-mode, plan, bleed)
  let safe = _validate-safe(plan, safe)
  let marks = _normalize-marks(marks)
  let mark-style = _normalize-mark-style(mark-style)
  _draw-context(sheet, plan, bleed, safe, marks, mark-style, _crop-mode(marks, plan, cut-mode, bleed))
}

#let _rotated(body, angle) = {
  if angle == 0deg { body } else { rotate(angle)[#body] }
}

#let _copy-count(copies, plan) = {
  let copies = if copies == auto { plan.slots } else { _non-negative-int(copies, "copies") }
  if copies > plan.slots {
    panic("sheetwise: `copies` cannot exceed the selected grid slots.")
  }
  copies
}

#let _occupied-slots-from-count(plan, count) = {
  let slots = ()
  for slot in range(plan.slots) {
    if slot < count { slots.push(slot) }
  }
  slots
}

#let _draw-imposed-slot(ctx, slot, body, proof: false, label: none, file-header: none) = {
  _draw-region(
    _slot-region(ctx.plan, slot, label: label),
    body: body,
    bleed: ctx.bleed,
    safe: ctx.safe,
    marks: ctx.marks,
    proof: proof,
    mark-style: ctx.mark-style,
    label: label,
    file-header: file-header,
    crop-mode: ctx.crop-mode,
  )
}

#let _draw-imposed-grid-marks(ctx, occupied-slots) = _draw-grid-crop-marks(ctx.plan, ctx.bleed, ctx.mark-style, ctx.marks, ctx.crop-mode, occupied-slots)

#let _imposed-sheet(ctx, body, slug: none, meta: (:), fold-x: auto, fold-y: auto) = _sheet(ctx.sheet, body, slug: slug, meta: meta, marks: ctx.marks, mark-style: ctx.mark-style, fold-x: fold-x, fold-y: fold-y)

#let _render-repeat(job, ctx, cut-mode, proof, slug) = {
  let plan = ctx.plan
  let copies = _copy-count(_get(job, "copies", auto), plan)
  let duplex = _get(job, "duplex", false)
  let back = _get(job, "back", none)
  _validate-duplex-back(duplex, back, "back", "repeat")
  let flip = if duplex { _validate-flip(_get(job, "flip", "long-edge")) } else { _get(job, "flip", "long-edge") }
  let back-rotation = _get(job, "back-rotation", 180deg)

  set page(width: ctx.sheet.width, height: ctx.sheet.height, margin: 0pt)
  _imposed-sheet(ctx, slug: slug, meta: _sheet-meta(1, if duplex { 2 } else { 1 }, "front", plan: plan, bleed: ctx.bleed, cut-mode: cut-mode))[
    #let occupied-slots = _occupied-slots-from-count(plan, copies)
    #for slot in range(plan.slots) {
      if slot < copies {
          _draw-imposed-slot(ctx, slot, job.body, proof: proof, label: str(slot + 1), file-header: _get(job, "file-header", none))
      }
    }
    #_draw-imposed-grid-marks(ctx, occupied-slots)
  ]

  if duplex {
    pagebreak()
    _imposed-sheet(ctx, slug: slug, meta: _sheet-meta(2, 2, "back", plan: plan, bleed: ctx.bleed, cut-mode: cut-mode))[
      #let occupied-slots = ()
      #for slot in range(plan.slots) {
        if slot < copies {
          let back-slot = _duplex-slot(plan, slot, flip)
          occupied-slots.push(back-slot)
          _draw-imposed-slot(ctx, back-slot, _rotated(back, back-rotation), proof: proof, label: str(slot + 1) + " back", file-header: _get(job, "back-file-header", none))
        }
      }
      #_draw-imposed-grid-marks(ctx, occupied-slots)
    ]
  }
}

#let _pdf-image(source, page, width, height, fit: "stretch", alt: none, name: "page") = {
  let page = _positive-int(page, name)
  image(source, page: page, width: width, height: height, fit: fit, alt: alt)
}

#let _source-label(source-name, page, source-page-count: auto) = if source-name == none or (source-page-count != auto and page > source-page-count) { none } else { str(source-name) + ":" + str(page) }

#let _render-pdf(job, ctx, cut-mode, proof, slug) = {
  let duplex = _get(job, "duplex", false)
  let back-source = _get(job, "back-source", none)
  _validate-duplex-back(duplex, back-source, "back-source", "pdf")
  let page = _positive-int(_get(job, "page", 1), "page")
  let back-page = if duplex { _positive-int(_get(job, "back-page", 1), "back-page") } else { _get(job, "back-page", 1) }
  let back-source-name = if _get(job, "back-source-name", auto) == auto { _get(job, "source-name", none) } else { _get(job, "back-source-name", none) }
  let front = _pdf-image(job.source, page, 100%, 100%, fit: _get(job, "fit", "stretch"), alt: _get(job, "alt", none))
  let back = if duplex {
    let back-fit = if _get(job, "back-fit", auto) == auto { _get(job, "fit", "stretch") } else { _get(job, "back-fit", auto) }
    _pdf-image(back-source, back-page, 100%, 100%, fit: back-fit, alt: _get(job, "back-alt", none), name: "back-page")
  } else {
    none
  }

  let repeat-job = (
    kind: "repeat",
    copies: _get(job, "copies", auto),
    duplex: duplex,
    back: back,
    back-rotation: _get(job, "back-rotation", 180deg),
    flip: _get(job, "flip", "long-edge"),
    file-header: _source-label(_get(job, "source-name", none), page),
    back-file-header: _source-label(back-source-name, back-page),
    body: front,
  )
  _render-repeat(repeat-job, ctx, cut-mode, proof, slug)
}

#let _expanded-items(items) = {
  if type(items) != array {
    panic("sheetwise: `items` must be an array of dictionaries.")
  }

  let records = ()
  for item in items {
    if type(item) != dictionary {
      panic("sheetwise: every `items` entry must be a dictionary.")
    }
    if not _has-key(item, "body") {
      panic("sheetwise: every `items` entry must include `body`.")
    }
    let copies = _non-negative-int(_get(item, "copies", 1), "items.copies")
    for copy in range(copies) {
      records.push(item)
    }
  }

  if records.len() == 0 {
    panic("sheetwise: `items` must include at least one copy.")
  }
  records
}

#let _render-variants(job, ctx, cut-mode, proof, slug) = {
  if _get(job, "items", auto) == auto {
    panic("sheetwise: `items` is required.")
  }

  let plan = ctx.plan
  let order = _validate-order(_get(job, "order", "forward"))
  let duplex = _get(job, "duplex", false)
  let flip = if duplex { _validate-flip(_get(job, "flip", "long-edge")) } else { _get(job, "flip", "long-edge") }
  let records = _expanded-items(job.items)
  let total = records.len()
  let sheet-count = calc.ceil(total / plan.slots)

  set page(width: ctx.sheet.width, height: ctx.sheet.height, margin: 0pt)
  for sheet-index in range(sheet-count) {
    if sheet-index > 0 { pagebreak() }
    _imposed-sheet(ctx, slug: slug, meta: _sheet-meta(sheet-index + 1, sheet-count, "front", plan: plan, bleed: ctx.bleed, cut-mode: cut-mode))[
      #let occupied-slots = ()
      #for slot in range(plan.slots) {
        let index = sheet-index * plan.slots + slot
        let source-index = _order-index(order, index, total)
        let item = if source-index >= 0 and source-index < total { records.at(source-index) } else { none }
        if item != none {
          occupied-slots.push(slot)
          _draw-imposed-slot(ctx, slot, item.body, proof: proof, label: _get(item, "label", str(source-index + 1)))
        }
      }
      #_draw-imposed-grid-marks(ctx, occupied-slots)
    ]

    if duplex {
      pagebreak()
      _imposed-sheet(ctx, slug: slug, meta: _sheet-meta(sheet-index + 1, sheet-count, "back", plan: plan, bleed: ctx.bleed, cut-mode: cut-mode))[
        #let occupied-slots = ()
        #for slot in range(plan.slots) {
          let index = sheet-index * plan.slots + slot
          let source-index = _order-index(order, index, total)
          let item = if source-index >= 0 and source-index < total { records.at(source-index) } else { none }
          if item != none and _has-key(item, "back") {
            let back-slot = _duplex-slot(plan, slot, flip)
            occupied-slots.push(back-slot)
            let label = _get(item, "label", str(source-index + 1))
            _draw-imposed-slot(ctx, back-slot, _rotated(item.back, _get(job, "back-rotation", 180deg)), proof: proof, label: label + " back")
          }
        }
        #_draw-imposed-grid-marks(ctx, occupied-slots)
      ]
    }
  }
}

#let _flow-from-name(flow) = {
  if flow == "cut-stack" or flow == "deep-right-down" {
    ("deep", "right", "down")
  } else if flow == "n-up" or flow == "right-down-deep" {
    ("right", "down", "deep")
  } else if flow == "down-right-deep" {
    ("down", "right", "deep")
  } else if flow == "deep-down-right" {
    ("deep", "down", "right")
  } else {
    panic("sheetwise: unknown `flow`.")
  }
}

#let _validate-stack-flow(stack-flow) = {
  if type(stack-flow) != array or stack-flow.len() != 3 {
    panic("sheetwise: `stack-flow` must be an array like `(\"deep\", \"right\", \"down\")`.")
  }
  for key in ("deep", "right", "down") {
    if not stack-flow.contains(key) {
      panic("sheetwise: `stack-flow` must contain `deep`, `right`, and `down` exactly once.")
    }
  }
  stack-flow
}

#let _resolve-stack-flow(flow, stack-flow) = {
  let stack-flow = if stack-flow == auto { _flow-from-name(flow) } else { stack-flow }
  _validate-stack-flow(stack-flow)
}

#let _record-index(sheet-index, slot, sheet-count, plan, stack-flow) = {
  let col = calc.rem(slot, plan.columns)
  let row = calc.floor(slot / plan.columns)
  let record = 0
  let stride = 1
  for key in stack-flow {
    let coordinate = if key == "deep" { sheet-index } else if key == "right" { col } else { row }
    record += coordinate * stride
    stride *= if key == "deep" { sheet-count } else if key == "right" { plan.columns } else { plan.rows }
  }
  record
}

#let _render-sequence(job, ctx, cut-mode, proof, slug) = {
  if _get(job, "count", auto) == auto { panic("sheetwise: `count` is required.") }
  if _get(job, "item", auto) == auto { panic("sheetwise: `item` is required.") }
  let count = _positive-int(job.count, "count")
  let plan = ctx.plan
  let order = _validate-order(_get(job, "order", "forward"))
  let flow = _get(job, "flow", "cut-stack")
  let resolved-stack-flow = _resolve-stack-flow(flow, _get(job, "stack-flow", auto))
  let minimum-sheet-count = calc.ceil(count / plan.slots)
  let sheet-count = if _get(job, "stack-size", auto) == auto {
    minimum-sheet-count
  } else {
    let stack-size = _positive-int(job.at("stack-size"), "stack-size")
    if stack-size < minimum-sheet-count {
      panic("sheetwise: `stack-size` is too small for `count` and the selected grid.")
    }
    stack-size
  }

  set page(width: ctx.sheet.width, height: ctx.sheet.height, margin: 0pt)
  for sheet-index in range(sheet-count) {
    if sheet-index > 0 { pagebreak() }
    _imposed-sheet(ctx, slug: slug, meta: _sheet-meta(sheet-index + 1, sheet-count, flow, plan: plan, bleed: ctx.bleed, cut-mode: cut-mode))[
      #let occupied-slots = ()
      #for slot in range(plan.slots) {
        let record = _record-index(sheet-index, slot, sheet-count, plan, resolved-stack-flow)
        let record = _order-index(order, record, count)
        if record >= 0 and record < count {
          occupied-slots.push(slot)
          _draw-imposed-slot(ctx, slot, (job.item)(record + 1), proof: proof, label: str(record + 1))
        }
      }
      #_draw-imposed-grid-marks(ctx, occupied-slots)
    ]
  }
}

#let _saddle-pair(page-count, sheet-index, side) = {
  if calc.rem(page-count, 4) != 0 {
    panic("sheetwise: saddle-stitch page count must be a multiple of 4.")
  }
  if side == "front" {
    (left: page-count - 2 * sheet-index, right: 1 + 2 * sheet-index)
  } else if side == "back" {
    (left: 2 + 2 * sheet-index, right: page-count - 1 - 2 * sheet-index)
  } else {
    panic("sheetwise: booklet side must be `front` or `back`.")
  }
}

#let _padded-page-count(page-count, blank-policy) = {
  let page-count = _positive-int(page-count, "page-count")
  let blank-policy = _one-of(blank-policy, ("error", "end"), "sheetwise: `blank-policy` must be `error` or `end`.")
  let remainder = calc.rem(page-count, 4)
  if remainder == 0 {
    page-count
  } else if blank-policy == "end" {
    page-count + (4 - remainder)
  } else {
    panic("sheetwise: saddle-stitch page count must be a multiple of 4.")
  }
}

#let _mirror-booklet(binding, reading-direction) = {
  let binding = _one-of(binding, ("left", "right"), "sheetwise: `binding` must be `left` or `right`.")
  let reading-direction = _one-of(reading-direction, ("ltr", "rtl"), "sheetwise: `reading-direction` must be `ltr` or `rtl`.")
  binding == "right" or reading-direction == "rtl"
}

#let _creep-max(creep, sheets) = {
  let value = if type(creep) == dictionary {
    if _has-key(creep, "paper-thickness") { creep.at("paper-thickness") * (sheets - 1) } else { _get(creep, "amount", 0pt) }
  } else {
    creep
  }
  _non-negative(value, "creep")
}

#let _creep-amount(max-creep, sheet-index, sheets) = {
  if sheets <= 1 { return 0pt }
  max-creep * sheet-index / (sheets - 1)
}

#let _blank-page(width, height) = box(width: width, height: height)[]

#let _pdf-page(source, number, width, height, dx: 0pt, source-page-count: auto, fit: "stretch", alt: none) = {
  let number = _positive-int(number, "page")
  if source-page-count != auto and number > source-page-count {
    return _blank-page(width, height)
  }
  box(width: width, height: height)[
    #move(dx: dx)[#_pdf-image(source, number, width, height, fit: fit, alt: alt)]
  ]
}

#let booklet-plan(page-count, blank-policy: "error", binding: "left", reading-direction: "ltr") = {
  let padded-count = _padded-page-count(page-count, blank-policy)
  let mirror = _mirror-booklet(binding, reading-direction)
  let sheets = calc.floor(padded-count / 4)
  let result = ()
  for i in range(sheets) {
    let front = _saddle-pair(padded-count, i, "front")
    let back = _saddle-pair(padded-count, i, "back")
    if mirror {
      front = (left: front.right, right: front.left)
      back = (left: back.right, right: back.left)
    }
    result.push((sheet: i + 1, front: front, back: back))
  }
  result
}

#let booklet-report(page-count, blank-policy: "error", binding: "left", reading-direction: "ltr") = {
  let plan = booklet-plan(page-count, blank-policy: blank-policy, binding: binding, reading-direction: reading-direction)
  block[
    #text(weight: "bold")[Saddle-stitch imposition plan]
    #v(4pt)
    #for entry in plan {
      [Sheet #entry.sheet front: #entry.front.left | #entry.front.right]
      linebreak()
      [Sheet #entry.sheet back: #entry.back.left | #entry.back.right]
      linebreak()
    }
  ]
}

#let _render-booklet(job, paper, orientation, trim-size, item-size, margin, gap, bleed, safe, marks, mark-style, proof, slug) = {
  if _get(job, "page-count", auto) == auto { panic("sheetwise: `page-count` is required.") }
  let trim = _resolve-trim-size(trim-size, item-size: item-size)
  let padded-count = _padded-page-count(job.at("page-count"), _get(job, "blank-policy", "error"))
  let mirror = _mirror-booklet(_get(job, "binding", "left"), _get(job, "reading-direction", "ltr"))
  let sheet = paper-size(paper, orientation: orientation)
  let gap = _pair(gap, "gap")
  let plan = _grid-plan(sheet, trim, margin, (width: gap.width, height: 0pt), 1, 2)
  let bleed = _non-negative(bleed, "bleed")
  let safe = _validate-safe(plan, _non-negative(safe, "safe"))
  let sheets = calc.floor(padded-count / 4)
  let sheet-marks = _normalize-marks(marks)
  let mark-style = _normalize-mark-style(mark-style)
  let ctx = _draw-context(sheet, plan, bleed, safe, sheet-marks, mark-style, _crop-mode(sheet-marks, plan, "booklet", bleed))
  let order = _validate-order(_get(job, "order", "forward"))
  let max-creep = _creep-max(_get(job, "creep", 0pt), sheets)
  let sides = ("front", "back")

  set page(width: sheet.width, height: sheet.height, margin: 0pt)
  for output-index in range(sheets * 2) {
    if output-index > 0 { pagebreak() }
    let sheet-index-raw = calc.floor(output-index / 2)
    let sheet-index = _order-index(order, sheet-index-raw, sheets)
    let side = sides.at(calc.rem(output-index, 2))
    let pair = _saddle-pair(padded-count, sheet-index, side)
    if mirror {
      pair = (left: pair.right, right: pair.left)
    }
    let creep-offset = _creep-amount(max-creep, sheet-index, sheets)
    _imposed-sheet(ctx, slug: slug, fold-x: sheet.width / 2, meta: _sheet-meta(sheet-index + 1, sheets, side, plan: plan, bleed: ctx.bleed, cut-mode: "booklet"))[
      #_draw-imposed-slot(ctx, 0, _pdf-page(job.source, pair.left, trim.width, trim.height, dx: creep-offset, source-page-count: job.at("page-count"), fit: _get(job, "fit", "stretch"), alt: _get(job, "alt", none)), proof: proof, label: str(pair.left), file-header: _source-label(_get(job, "source-name", none), pair.left, source-page-count: job.at("page-count")))
      #_draw-imposed-slot(ctx, 1, _pdf-page(job.source, pair.right, trim.width, trim.height, dx: -creep-offset, source-page-count: job.at("page-count"), fit: _get(job, "fit", "stretch"), alt: _get(job, "alt", none)), proof: proof, label: str(pair.right), file-header: _source-label(_get(job, "source-name", none), pair.right, source-page-count: job.at("page-count")))
      #_draw-imposed-grid-marks(ctx, (0, 1))
    ]
  }
}

#let _render-marks-only(job, paper, orientation, bleed, safe, marks, mark-style, proof, slug) = {
  if _get(job, "regions", auto) == auto { panic("sheetwise: `regions` is required.") }
  let sheet = paper-size(paper, orientation: orientation)
  let bleed = _non-negative(bleed, "bleed")
  let regions = _normalize-regions(job.regions)
  let sheet-marks = _normalize-marks(marks)
  let mark-style = _normalize-mark-style(mark-style)

  set page(width: sheet.width, height: sheet.height, margin: 0pt)
  _sheet(sheet, slug: slug, marks: sheet-marks, mark-style: mark-style, meta: _sheet-meta(1, 1, "marks"))[
    #for region in regions {
      _draw-region(region, bleed: bleed, safe: _non-negative(safe, "safe"), marks: sheet-marks, proof: proof, mark-style: mark-style, crop-mode: "per-item")
    }
  ]
}

#let _calibration-face(title, subtitle, sheet, color) = {
  block(width: sheet.width, height: sheet.height)[
    #place(top + left, dx: 12mm, dy: 12mm)[
      #rect(width: sheet.width - 24mm, height: sheet.height - 24mm, stroke: 1pt + color)[
        #align(center + horizon)[
          #text(size: 28pt, weight: "bold", fill: color)[#title]
          #v(5mm)
          #text(size: 12pt)[#subtitle]
          #v(10mm)
          #text(size: 9pt)[Top edge must stay readable after duplex printing.]
        ]
      ]
    ]
    #place(top + center, dy: 5mm)[#text(size: 10pt, weight: "bold")[TOP]]
    #place(bottom + center, dy: -5mm)[#text(size: 10pt, weight: "bold")[BOTTOM]]
    #place(left + horizon, dx: 5mm)[#rotate(-90deg)[#text(size: 10pt, weight: "bold")[LEFT]]]
    #place(right + horizon, dx: -5mm)[#rotate(90deg)[#text(size: 10pt, weight: "bold")[RIGHT]]]
  ]
}

#let _render-calibration(job, paper, orientation, marks, mark-style, slug) = {
  let flip = _validate-flip(_get(job, "flip", "long-edge"))
  let sheet = paper-size(paper, orientation: orientation)
  let sheet-marks = _normalize-marks(marks)
  let mark-style = _normalize-mark-style(mark-style)
  set page(width: sheet.width, height: sheet.height, margin: 0pt)
  _sheet(sheet, slug: slug, marks: sheet-marks, mark-style: mark-style, meta: _sheet-meta(1, 2, "front"))[
    #_calibration-face("FRONT", "Print this side first. Flip mode: " + flip, sheet, rgb("#105ea8"))
  ]
  pagebreak()
  _sheet(sheet, slug: slug, marks: sheet-marks, mark-style: mark-style, meta: _sheet-meta(2, 2, "back"))[
    #_rotated(_calibration-face("BACK", "If this is upside down, change flip or back-rotation.", sheet, rgb("#a83a10")), _get(job, "back-rotation", 180deg))
  ]
}

#let impose(
  job,
  paper: "a4",
  orientation: "portrait",
  trim-size: auto,
  item-size: auto,
  item-orientation: "original",
  margin: 10mm,
  gap: 3mm,
  rows: auto,
  columns: auto,
  cut-mode: "single",
  bleed: 0pt,
  safe: 0pt,
  marks: true,
  mark-style: _default-mark-style,
  proof: false,
  slug: none,
) = {
  if type(job) != dictionary or not _has-key(job, "kind") {
    panic("sheetwise: `job` must be created with `repeat`, `variants`, `sequence`, `pdf`, `booklet`, `marks-only`, or `calibration`.")
  }

  if job.kind == "booklet" {
    return _render-booklet(job, paper, orientation, trim-size, item-size, margin, gap, bleed, safe, marks, mark-style, proof, slug)
  }

  if job.kind == "marks-only" {
    return _render-marks-only(job, paper, orientation, bleed, safe, marks, mark-style, proof, slug)
  }

  if job.kind == "calibration" {
    return _render-calibration(job, paper, orientation, marks, mark-style, slug)
  }

  let ctx = _imposition-context(paper, orientation, trim-size, item-size, item-orientation, margin, gap, rows, columns, cut-mode, bleed, safe, marks, mark-style)
  if job.kind == "repeat" {
    _render-repeat(job, ctx, cut-mode, proof, slug)
  } else if job.kind == "pdf" {
    _render-pdf(job, ctx, cut-mode, proof, slug)
  } else if job.kind == "variants" {
    _render-variants(job, ctx, cut-mode, proof, slug)
  } else if job.kind == "sequence" {
    _render-sequence(job, ctx, cut-mode, proof, slug)
  } else {
    panic("sheetwise: unknown job kind `" + str(job.kind) + "`.")
  }
}
