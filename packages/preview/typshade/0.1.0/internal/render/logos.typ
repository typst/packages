// Copyright (C) 2026 Eito Yoneyama
// SPDX-License-Identifier: GPL-2.0

#import "../model/logo.typ": _logo-column-items, _logo-max-bits, _logo-residue-color
#import "../model/palette.typ": resolve-color
#import "../model/parser.typ": _lower
#import "../model/text-style.typ": _text-params, _text-string

#let _logo-height(config) = 28pt * config.at("sequence-logo").at("stretch")

#let _logo-residue(item, config, seq-type, subfamily) = {
  let value = item.at("value")
  let size = 5pt + 18pt * (calc.abs(value) / _logo-max-bits(seq-type))
  let residue = if subfamily and value < 0 { _lower(item.at("residue")) } else { item.at("residue") }
  text(.._text-params(config, "residues", fill: resolve-color(_logo-residue-color(config, seq-type, item.at("residue"), subfamily: subfamily)), size: size))[#_text-string(config, "residues", residue)]
}

#let _logo-stack(items, config, seq-type, subfamily, height, edge) = {
  box(height: height, inset: 0pt)[#align(edge + center, stack(spacing: -1pt, ..items.map(item => _logo-residue(item, config, seq-type, subfamily))))]
}

#let _logo-scale-content(config, seq-type, subfamily: false) = {
  let max-bits = calc.round(_logo-max-bits(seq-type) * 10) / 10
  let logo-scale-color = resolve-color(config.at("logo-scale").at("color"))
  let height = _logo-height(config)
  let negative = subfamily and config.at("subfamily-logo").at("show-negatives")
  if not negative {
    return box(height: height, inset: 0pt)[#align(center + horizon, stack(
      spacing: 1pt,
      text(.._text-params(config, "ruler", fill: logo-scale-color, size: 6pt))[#str(max-bits)],
      rect(width: 0.6pt, height: height - 14pt, fill: logo-scale-color),
      text(.._text-params(config, "ruler", fill: logo-scale-color, size: 6pt))[0],
    ))]
  }
  box(height: height + 12pt, inset: 0pt)[#align(center + horizon, stack(
    spacing: 1pt,
    text(.._text-params(config, "ruler", fill: logo-scale-color, size: 6pt))[#str(max-bits)],
    rect(width: 0.6pt, height: height / 2 - 5pt, fill: logo-scale-color),
    text(.._text-params(config, "ruler", fill: logo-scale-color, size: 6pt))[0],
    rect(width: 0.6pt, height: height / 2 - 5pt, fill: logo-scale-color),
    text(.._text-params(config, "ruler", fill: logo-scale-color, size: 6pt))[-#str(max-bits)],
  ))]
}

#let _logo-name-cell(config, subfamily: false) = {
  let height = _logo-height(config)
  let label-color = resolve-color(config.at("legend").at("color"))
  if subfamily and config.at("subfamily-logo").at("show-negatives") {
    return box(height: height + 12pt, inset: 0pt)[#align(left + horizon, stack(
      spacing: 1pt,
      box(height: 6pt, inset: 0pt)[],
      box(height: height / 2, inset: 0pt)[#align(left + bottom, text(.._text-params(config, "names", fill: label-color))[#_text-string(config, "names", config.at("subfamily-logo").at("name"))])],
      box(height: 0pt, inset: 0pt)[],
      box(height: height / 2, inset: 0pt)[#align(left + top, text(.._text-params(config, "names", fill: label-color))[#_text-string(config, "names", config.at("subfamily-logo").at("negative-name"))])],
      box(height: 6pt, inset: 0pt)[],
    ))]
  }
  let label = if subfamily { config.at("subfamily-logo").at("name") } else { config.at("sequence-logo").at("name") }
  box(height: height, inset: 0pt)[#align(left + horizon, text(.._text-params(config, "names", fill: label-color))[#_text-string(config, "names", label)])]
}

#let _logo-column(alignment, config, col, subfamily: false) = {
  let items = _logo-column-items(alignment, config, col, subfamily: subfamily)
  if items.len() == 0 {
    return box(height: if subfamily and config.at("subfamily-logo").at("show-negatives") { _logo-height(config) + 12pt } else { _logo-height(config) }, inset: 0pt)[]
  }
  let seq-type = alignment.at("seq-type")
  if not subfamily {
    return _logo-stack(items, config, seq-type, false, _logo-height(config), bottom)
  }
  let positive = items.filter(it => it.at("value") > 0)
  let negative = if config.at("subfamily-logo").at("show-negatives") { items.filter(it => it.at("value") < 0) } else { () }
  let pos-hit = config.at("relevance").at("show") and positive.any(it => it.at("value") >= config.at("relevance").at("threshold"))
  let neg-hit = config.at("relevance").at("show") and negative.any(it => -it.at("value") >= config.at("relevance").at("threshold"))
  box(height: _logo-height(config) + 12pt, inset: 0pt)[#align(center + horizon, stack(
    spacing: 0pt,
    box(height: 6pt, inset: 0pt)[#align(center + horizon, if pos-hit { text(.._text-params(config, "ruler", fill: resolve-color(config.at("relevance").at("color")), size: 6pt))[#_text-string(config, "ruler", config.at("relevance").at("char"))]} else { [] })],
    _logo-stack(positive, config, seq-type, true, _logo-height(config) / 2, bottom),
    rect(width: 80%, height: 0.35pt, fill: resolve-color(config.at("logo-scale").at("color"))),
    _logo-stack(negative, config, seq-type, true, _logo-height(config) / 2, top),
    box(height: 6pt, inset: 0pt)[#align(center + horizon, if neg-hit { text(.._text-params(config, "ruler", fill: resolve-color(config.at("relevance").at("color")), size: 6pt))[#_text-string(config, "ruler", config.at("relevance").at("char"))]} else { [] })],
  ))]
}

#let _logo-table(alignment, config, segment, name-width, num-width, cell-width, subfamily: false) = {
  let columns = ()
  let items = ()
  if config.at("names").at("show") and config.at("names").at("position") == "left" {
    columns.push(name-width)
    items.push(_logo-name-cell(config, subfamily: subfamily))
  }
  if config.at("numbering").at("show") and config.at("numbering").at("left") {
    columns.push(num-width)
    items.push([])
  }
  for col in segment {
    columns.push(cell-width)
    items.push(_logo-column(alignment, config, col, subfamily: subfamily))
  }
  if config.at("numbering").at("show") and config.at("numbering").at("right") {
    columns.push(num-width)
    items.push([])
  }
  if config.at("names").at("show") and config.at("names").at("position") == "right" {
    columns.push(name-width)
    items.push(_logo-name-cell(config, subfamily: subfamily))
  }
  table(columns: columns, inset: 0pt, stroke: none, align: center, column-gutter: 0pt, row-gutter: 0pt, ..items)
}

#let _logo-block(alignment, config, segment, name-width, num-width, cell-width, subfamily: false) = {
  let columns = ()
  let items = ()
  let show-left = config.at("logo-scale").at("show") and (config.at("logo-scale").at("position") == "left" or config.at("logo-scale").at("position") == "leftright")
  let show-right = config.at("logo-scale").at("show") and (config.at("logo-scale").at("position") == "right" or config.at("logo-scale").at("position") == "leftright")
  if show-left {
    columns.push(18pt)
    items.push(_logo-scale-content(config, alignment.at("seq-type"), subfamily: subfamily))
  }
  columns.push(auto)
  items.push(_logo-table(alignment, config, segment, name-width, num-width, cell-width, subfamily: subfamily))
  if show-right {
    columns.push(18pt)
    items.push(_logo-scale-content(config, alignment.at("seq-type"), subfamily: subfamily))
  }
  table(columns: columns, inset: 0pt, stroke: none, column-gutter: 2pt, row-gutter: 0pt, ..items)
}

#let _legend-block(config) = {
  if not config.at("legend").at("show") or config.at("shading").at("mode") != "functional" {
    return none
  }
  let option = config.at("shading").at("option", default: none)
  let mode = if option == none { config.at("functional-default") } else { option }
  if not config.at("functional-groups").keys().contains(mode) {
    return none
  }
  let items = ()
  for group in config.at("functional-groups").at(mode) {
    items.push(box(width: 10pt, height: 10pt, fill: resolve-color(group.at("bg")), stroke: none)[])
    items.push(text(.._text-params(config, "legend", fill: resolve-color(config.at("legend").at("color"))))[#_text-string(config, "legend", group.at("name"))])
  }
  move(dx: config.at("legend").at("dx"), dy: config.at("legend").at("dy"))[
    #table(columns: (10pt, auto), inset: (x: 2pt, y: 1pt), stroke: none, column-gutter: 4pt, row-gutter: 2pt, ..items)
  ]
}
