#import "constants.typ": *
#import "grid.typ": _slot-position
#import "validate.typ": *

#let _normalize-marks(marks) = {
  if marks == true {
    _default-marks
  } else if marks == false or marks == none {
    _disabled-marks
  } else if type(marks) == dictionary {
    _merge(_default-marks, marks)
  } else {
    panic("sheetwise: `marks` must be a boolean, `none`, or a dictionary.")
  }
}

#let _normalize-mark-style(mark-style) = {
  if type(mark-style) == dictionary {
    _merge(_default-mark-style, mark-style)
  } else {
    panic("sheetwise: `mark-style` must be a dictionary.")
  }
}

#let _bleed-only-double-gap(plan, bleed) = {
  if bleed <= 0pt {
    return false
  }
  let tight-horizontal-gap = plan.columns > 1 and plan.gap.width <= bleed * 2
  let tight-vertical-gap = plan.rows > 1 and plan.gap.height <= bleed * 2
  tight-horizontal-gap or tight-vertical-gap
}

#let _crop-mode(marks, plan, cut-mode, bleed) = {
  let mode = _get(marks, "crop-mode", _default-marks.at("crop-mode"))
  if mode == "auto" {
    if cut-mode == "single" and plan.gap.width == 0pt and plan.gap.height == 0pt {
      "grid"
    } else if cut-mode == "double" and _bleed-only-double-gap(plan, bleed) {
      "grid"
    } else {
      "per-item"
    }
  } else if mode == "per-item" or mode == "grid" {
    mode
  } else {
    panic("sheetwise: `marks.crop-mode` must be `auto`, `per-item`, or `grid`.")
  }
}

#let _validate-cut-mode(cut-mode, plan, bleed) = {
  let cut-mode = _one-of(cut-mode, ("single", "double"), "sheetwise: `cut-mode` must be `single` or `double`.")
  if cut-mode == "single" {
    return
  }

  if plan.columns > 1 {
    if plan.gap.width <= 0pt {
      panic("sheetwise: `cut-mode: \"double\"` needs a horizontal gap for the removable strip.")
    }
    if bleed > 0pt and plan.gap.width < bleed * 2 {
      panic("sheetwise: `cut-mode: \"double\"` needs horizontal `gap >= 2 * bleed`.")
    }
  }

  if plan.rows > 1 {
    if plan.gap.height <= 0pt {
      panic("sheetwise: `cut-mode: \"double\"` needs a vertical gap for the removable strip.")
    }
    if bleed > 0pt and plan.gap.height < bleed * 2 {
      panic("sheetwise: `cut-mode: \"double\"` needs vertical `gap >= 2 * bleed`.")
    }
  }
}

#let _validate-safe(plan, safe) = {
  if safe > 0pt and (safe * 2 >= plan.item.width or safe * 2 >= plan.item.height) {
    panic("sheetwise: `safe` must be smaller than half the item size.")
  }
  safe
}

#let _hline(x, y, width, color, thickness) = {
  place(top + left, dx: x, dy: y)[
    #rect(width: width, height: thickness, fill: color)
  ]
}

#let _vline(x, y, height, color, thickness) = {
  place(top + left, dx: x, dy: y)[
    #rect(width: thickness, height: height, fill: color)
  ]
}

#let _outline(x, y, width, height, color, thickness: 0.25pt) = {
  _hline(x, y, width, color, thickness)
  _hline(x, y + height, width, color, thickness)
  _vline(x, y, height, color, thickness)
  _vline(x + width, y, height, color, thickness)
}

#let _crop-mark-offset(bleed, style) = {
  let explicit = style.offset
  if explicit != auto {
    return _non-negative(explicit, "mark-style.offset")
  }

  if bleed > 0pt {
    bleed + _non-negative(style.at("bleed-offset"), "mark-style.bleed-offset")
  } else {
    _non-negative(style.at("no-bleed-offset"), "mark-style.no-bleed-offset")
  }
}

#let _crop-mark-params(bleed, style) = (
  length: _positive(style.length, "mark-style.length"),
  color: style.color,
  thickness: _positive(style.thickness, "mark-style.thickness"),
  offset: _crop-mark-offset(bleed, style),
)

#let _mark-backing(style) = {
  if style.knockout {
    (
      padding: _non-negative(style.at("knockout-padding"), "mark-style.knockout-padding"),
      color: style.at("knockout-color"),
    )
  } else {
    none
  }
}

#let _backed-hline(x, y, width, color, thickness, style) = {
  let backing = _mark-backing(style)
  if backing != none {
    _hline(x - backing.padding, y - backing.padding, width + backing.padding * 2, backing.color, thickness + backing.padding * 2)
  }
  _hline(x, y, width, color, thickness)
}

#let _backed-vline(x, y, height, color, thickness, style) = {
  let backing = _mark-backing(style)
  if backing != none {
    _vline(x - backing.padding, y - backing.padding, height + backing.padding * 2, backing.color, thickness + backing.padding * 2)
  }
  _vline(x, y, height, color, thickness)
}

#let _crop-marks(region, bleed, style) = {
  let mark = _crop-mark-params(bleed, style)
  let x = region.x
  let y = region.y
  let width = region.width
  let height = region.height

  _backed-hline(x - mark.offset - mark.length, y, mark.length, mark.color, mark.thickness, style)
  _backed-hline(x + width + mark.offset, y, mark.length, mark.color, mark.thickness, style)
  _backed-hline(x - mark.offset - mark.length, y + height, mark.length, mark.color, mark.thickness, style)
  _backed-hline(x + width + mark.offset, y + height, mark.length, mark.color, mark.thickness, style)

  _backed-vline(x, y - mark.offset - mark.length, mark.length, mark.color, mark.thickness, style)
  _backed-vline(x + width, y - mark.offset - mark.length, mark.length, mark.color, mark.thickness, style)
  _backed-vline(x, y + height + mark.offset, mark.length, mark.color, mark.thickness, style)
  _backed-vline(x + width, y + height + mark.offset, mark.length, mark.color, mark.thickness, style)
}

#let _push-unique(values, value) = {
  if not values.contains(value) {
    values.push(value)
  }
  values
}

#let _grid-crop-marks(plan, bleed, style, slots: auto) = {
  let mark = _crop-mark-params(bleed, style)
  let slots = if slots == auto { range(plan.slots) } else { slots }
  if slots.len() == 0 {
    return
  }

  let x-lines = ()
  let y-lines = ()
  let grid-left = none
  let grid-top = none
  let grid-right = none
  let grid-bottom = none

  for slot in slots {
    if slot >= 0 and slot < plan.slots {
      let pos = _slot-position(plan, slot)
      let right = pos.x + plan.item.width
      let bottom = pos.y + plan.item.height

      x-lines = _push-unique(x-lines, pos.x)
      x-lines = _push-unique(x-lines, right)
      y-lines = _push-unique(y-lines, pos.y)
      y-lines = _push-unique(y-lines, bottom)

      if grid-left == none or pos.x < grid-left { grid-left = pos.x }
      if grid-top == none or pos.y < grid-top { grid-top = pos.y }
      if grid-right == none or right > grid-right { grid-right = right }
      if grid-bottom == none or bottom > grid-bottom { grid-bottom = bottom }
    }
  }

  if grid-left == none {
    return
  }

  for x in x-lines {
    _backed-vline(x, grid-top - mark.offset - mark.length, mark.length, mark.color, mark.thickness, style)
    _backed-vline(x, grid-bottom + mark.offset, mark.length, mark.color, mark.thickness, style)
  }

  for y in y-lines {
    _backed-hline(grid-left - mark.offset - mark.length, y, mark.length, mark.color, mark.thickness, style)
    _backed-hline(grid-right + mark.offset, y, mark.length, mark.color, mark.thickness, style)
  }
}

#let _normalize-region(region, name) = {
  if type(region) == dictionary and _has-key(region, "x") and _has-key(region, "y") and _has-key(region, "width") and _has-key(region, "height") {
    return (
      x: _non-negative(region.x, name + ".x"),
      y: _non-negative(region.y, name + ".y"),
      width: _positive(region.width, name + ".width"),
      height: _positive(region.height, name + ".height"),
      label: _get(region, "label", none),
    )
  }

  if type(region) == array and region.len() == 4 {
    return (
      x: _non-negative(region.at(0), name + ".x"),
      y: _non-negative(region.at(1), name + ".y"),
      width: _positive(region.at(2), name + ".width"),
      height: _positive(region.at(3), name + ".height"),
      label: none,
    )
  }

  panic("sheetwise: `" + name + "` must be `(x:, y:, width:, height:)` or `(x, y, width, height)`.")
}

#let _normalize-regions(regions) = {
  if type(regions) != array {
    panic("sheetwise: `regions` must be an array.")
  }

  let result = ()
  for index in range(regions.len()) {
    result.push(_normalize-region(regions.at(index), "regions." + str(index)))
  }
  result
}

#let _file-header(region, bleed, message, style) = {
  let inset = _non-negative(style.at("file-header-inset"), "mark-style.file-header-inset")
  let y = if bleed > 0pt { region.y - bleed + inset } else { region.y + inset }
  place(top + left, dx: region.x + inset, dy: y)[
    #text(size: _positive(style.at("file-header-size"), "mark-style.file-header-size"), fill: style.at("file-header-color"))[#message]
  ]
}

#let _draw-region(
  region,
  body: none,
  bleed: 0pt,
  safe: 0pt,
  marks: _default-marks,
  proof: false,
  mark-style: _default-mark-style,
  label: none,
  file-header: none,
  crop-mode: "per-item",
) = {
  if (proof or marks.bleed) and bleed > 0pt {
    _outline(region.x - bleed, region.y - bleed, region.width + bleed * 2, region.height + bleed * 2, _bleed-color)
  }

  if body != none {
    place(top + left, dx: region.x, dy: region.y)[
      #box(width: region.width, height: region.height)[#body]
    ]
  }

  if proof {
    _outline(region.x, region.y, region.width, region.height, _proof-color)
    let label = if label != none { label } else { region.label }
    if label != none {
      place(top + left, dx: region.x + 1.5mm, dy: region.y + 1.2mm)[
        #text(size: 5pt, fill: _label-color)[#label]
      ]
    }
  }

  if (proof or marks.safe) and safe > 0pt {
    _outline(region.x + safe, region.y + safe, region.width - safe * 2, region.height - safe * 2, _safe-color)
  }

  if _get(marks, "file-header", false) and file-header != none {
    _file-header(region, bleed, file-header, mark-style)
  }

  if marks.crop and crop-mode == "per-item" {
    _crop-marks(region, bleed, mark-style)
  }
}

#let _draw-grid-crop-marks(plan, bleed, mark-style, sheet-marks, crop-mode, slots) = {
  if sheet-marks.crop and crop-mode == "grid" {
    _grid-crop-marks(plan, bleed, mark-style, slots: slots)
  }
}

#let _registration-mark(x, y, size: 5mm, thickness: 0.25pt, color: registration-color) = {
  _hline(x - size / 2, y, size, color, thickness)
  _vline(x, y - size / 2, size, color, thickness)
  _outline(x - size / 4, y - size / 4, size / 2, size / 2, color, thickness: thickness)
}

#let _sheet-registration-marks(sheet, style, margin: 6mm) = {
  let color = style.at("registration-color")
  _registration-mark(margin, margin, color: color)
  _registration-mark(sheet.width - margin, margin, color: color)
  _registration-mark(margin, sheet.height - margin, color: color)
  _registration-mark(sheet.width - margin, sheet.height - margin, color: color)
}

#let _color-bar(x: 8mm, y: 4mm, width: 5mm, height: 3mm) = {
  let colors = (
    cmyk(100%, 0%, 0%, 0%),
    cmyk(0%, 100%, 0%, 0%),
    cmyk(0%, 0%, 100%, 0%),
    cmyk(0%, 0%, 0%, 100%),
    _paper-white,
    cmyk(0%, 0%, 0%, 50%),
  )

  for i in range(colors.len()) {
    place(top + left, dx: x + i * width, dy: y)[
      #rect(width: width, height: height, fill: colors.at(i), stroke: 0.2pt + _mark-black)
    ]
  }
}

#let _fold-mark(sheet, x: auto, y: auto, size: 6mm, color: registration-color, thickness: 0.25pt) = {
  if x != auto {
    _vline(x, 3mm, size, color, thickness)
    _vline(x, sheet.height - 3mm - size, size, color, thickness)
  }
  if y != auto {
    _hline(3mm, y, size, color, thickness)
    _hline(sheet.width - 3mm - size, y, size, color, thickness)
  }
}

#let _page-border(sheet, style) = {
  _outline(
    0pt,
    0pt,
    sheet.width,
    sheet.height,
    style.at("page-border-color"),
    thickness: _positive(style.at("page-border-thickness"), "mark-style.page-border-thickness"),
  )
}

#let _sheet-marks(sheet, marks, mark-style, fold-x: auto, fold-y: auto) = {
  if _get(marks, "page-border", false) {
    _page-border(sheet, mark-style)
  }
  if marks.registration {
    _sheet-registration-marks(sheet, mark-style)
  }
  if marks.color-bar {
    _color-bar()
  }
  if marks.fold {
    _fold-mark(sheet, x: fold-x, y: fold-y, color: mark-style.at("registration-color"))
  }
}
