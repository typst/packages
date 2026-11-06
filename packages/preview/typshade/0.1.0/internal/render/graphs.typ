// Copyright (C) 2026 Eito Yoneyama
// SPDX-License-Identifier: GPL-2.0

#import "../engine/layout.typ": _empty-cell
#import "../model/palette.typ": resolve-color, scale-color
#import "../model/parser.typ": _source-text, _split-lines, _upper

#let _hydropathy-scale = (
  A: 1.8, C: 2.5, D: -3.5, E: -3.5, F: 2.8, G: -0.4, H: -3.2, I: 4.5,
  K: -3.9, L: 3.8, M: 1.9, N: -3.5, P: -1.6, Q: -3.5, R: -4.5, S: -0.8,
  T: -0.7, V: 4.2, W: -0.9, Y: -1.3,
)

#let _molweight-scale = (
  A: 89.1, C: 121.2, D: 133.1, E: 147.1, F: 165.2, G: 75.1, H: 155.2, I: 131.2,
  K: 146.2, L: 131.2, M: 149.2, N: 132.1, P: 115.1, Q: 146.1, R: 174.2, S: 105.1,
  T: 119.1, V: 117.1, W: 204.2, Y: 181.2,
)

#let _charge-scale = (
  D: -1.0, E: -1.0, K: 1.0, R: 1.0, H: 0.5,
)

#let _graph-scales = ("BlackWhite", "WhiteBlack", "BlueRed", "RedBlue", "GreenRed", "RedGreen", "ColdHot", "HotCold", "TCoffee")
#let _builtin-graph-metrics = ("hydrophobicity", "molweight", "charge", "conservation")

#let _parse-number(value) = {
  let text = str(value).trim()
  if text == "" or text == "NaN" or text == "nan" {
    none
  } else {
    float(text)
  }
}

#let _graph-style(style) = {
  if type(style) == dictionary {
    if not style.keys().contains("kind") or not style.keys().contains("metric") {
      return none
    }
    return (
      kind: style.at("kind"),
      metric: style.at("metric"),
      min: style.at("min", default: none),
      max: style.at("max", default: none),
      options: style.at("options", default: ()),
    )
  }
  let text = str(style).trim()
  let hit = text.matches(regex("^(bar|color|stackedbars|frustratometer)(?:\\[([^\\]]*)\\])?:(.+?)(?:\\[([^\\]]*)\\])?$"))
  if hit.len() == 0 {
    return none
  }
  let captures = hit.first().captures
  let kind = captures.at(0)
  let range-text = captures.at(1, default: "")
  let metric = captures.at(2).trim()
  let option-text = captures.at(3, default: "")
  let min = none
  let max = none
  if range-text != "" {
    let parts = range-text.split(",")
    if parts.len() >= 2 {
      min = _parse-number(parts.at(0))
      max = _parse-number(parts.at(1))
    }
  }
  let options = if option-text == "" { () } else { option-text.split(",").map(part => part.trim()) }
  (kind: kind, metric: metric, min: min, max: max, options: options)
}

#let _graph-range(metric) = if metric == "hydrophobicity" {
  (-4.5, 4.5)
} else if metric == "molweight" {
  (75.1, 204.2)
} else if metric == "charge" {
  (-1.0, 1.0)
} else {
  (0.0, 100.0)
}

#let _graph-range-from-style(parsed, series: none) = {
  if parsed.at("min") != none and parsed.at("max") != none {
    return (parsed.at("min"), parsed.at("max"))
  }
  if parsed.at("kind") == "frustratometer" {
    return (0.0, 1.0)
  }
  if _builtin-graph-metrics.contains(parsed.at("metric")) {
    return _graph-range(parsed.at("metric"))
  }
  let min = none
  let max = none
  for item in series {
    let values = if type(item) == array or type(item) == content { item } else { (item,) }
    for value in values {
      if value == none {
        continue
      }
      if min == none or value < min {
        min = value
      }
      if max == none or value > max {
        max = value
      }
    }
  }
  if min == none or max == none {
    (0.0, 1.0)
  } else if min == max {
    (min, max + 1.0)
  } else {
    (min, max)
  }
}

#let _graph-conservation(alignment, col) = {
  let counts = (:)
  let total = 0
  for seq in alignment.at("sequences") {
    let residue = _upper(seq.at("aligned").slice(col, col + 1))
    if residue == "." or residue == "-" or residue == "" {
      continue
    }
    counts.insert(residue, counts.at(residue, default: 0) + 1)
    total += 1
  }
  if total == 0 {
    return 0.0
  }
  let top = 0
  for key in counts.keys() {
    if counts.at(key) > top {
      top = counts.at(key)
    }
  }
  top / total * 100.0
}

#let _builtin-graph-value(alignment, sequence, col, metric) = {
  let residue = _upper(sequence.at("aligned").slice(col, col + 1))
  if residue == "." or residue == "-" or residue == "" {
    return none
  }
  if metric == "hydrophobicity" {
    return _hydropathy-scale.at(residue, default: 0.0)
  }
  if metric == "molweight" {
    return _molweight-scale.at(residue, default: 100.0)
  }
  if metric == "charge" {
    return _charge-scale.at(residue, default: 0.0)
  }
  if metric == "conservation" {
    return _graph-conservation(alignment, col)
  }
  none
}

#let _parse-inline-graph-data(text, stacked: false) = {
  let source = str(text).trim()
  if stacked {
    let rows = ()
    for hit in source.matches(regex("\\(([^\\)]*)\\)")) {
      let values = ()
      for part in hit.captures.at(0).split(",") {
        values.push(_parse-number(part))
      }
      rows.push((position: none, values: values))
    }
    return rows
  }
  let values = ()
  for part in source.split(",") {
    values.push(_parse-number(part))
  }
  values.map(value => (position: none, values: (value,)))
}

#let _parse-graph-line(line, stacked: false) = {
  let trimmed = str(line).trim()
  if trimmed == "" {
    return none
  }
  let first = trimmed.slice(0, 1)
  if first.matches(regex("[A-Za-z]")).len() > 0 and not trimmed.starts-with("NaN") and not trimmed.starts-with("nan") {
    return none
  }
  let position = none
  let body = trimmed
  let numbered = trimmed.matches(regex("^(-?\\d+)\\s*:\\s*(.+)$"))
  if numbered.len() > 0 {
    position = int(numbered.first().captures.at(0))
    body = numbered.first().captures.at(1)
  }
  let values = ()
  for part in body.split(",") {
    values.push(_parse-number(part))
  }
  if not stacked and values.len() > 1 {
    values = (values.first(),)
  }
  (position: position, values: values)
}

#let _read-graph-data(source, stacked: false) = {
  let rows = ()
  for line in _split-lines(_source-text(source)) {
    let parsed = _parse-graph-line(line, stacked: stacked)
    if parsed != none {
      rows.push(parsed)
    }
  }
  rows
}

#let _read-frustr-data(source) = {
  let rows = ()
  for line in _split-lines(_source-text(source)) {
    let trimmed = str(line).trim()
    if trimmed == "" or trimmed.starts-with("#") {
      continue
    }
    let parts = trimmed.split().filter(part => part != "")
    if parts.len() < 9 {
      continue
    }
    let residue = _parse-number(parts.at(0))
    if residue == none {
      continue
    }
    let rel-high = _parse-number(parts.at(6))
    let rel-neutral = _parse-number(parts.at(7))
    let rel-min = _parse-number(parts.at(8))
    rows.push((position: int(residue), values: (rel-min, rel-neutral, rel-high)))
  }
  rows
}

#let _graph-data-source(parsed) = {
  let metric = parsed.at("metric")
  if _builtin-graph-metrics.contains(metric) {
    return "builtin"
  }
  if type(metric) == bytes {
    return if parsed.at("kind") == "frustratometer" { "frustr" } else { "source" }
  }
  if parsed.at("kind") == "frustratometer" {
    return "frustr"
  }
  if type(metric) == str and metric.contains("\n") {
    return "source"
  }
  if parsed.at("kind") == "stackedbars" and metric.contains("(") {
    return "inline"
  }
  if parsed.at("kind") != "stackedbars" and metric.contains(",") {
    return "inline"
  }
  "source"
}

#let _graph-series(parsed, alignment, sequence, selected) = {
  let source = _graph-data-source(parsed)
  if source == "builtin" {
    let out = ()
    for col in selected {
      if parsed.at("kind") == "stackedbars" {
        out.push((_builtin-graph-value(alignment, sequence, col, parsed.at("metric")),))
      } else {
        out.push(_builtin-graph-value(alignment, sequence, col, parsed.at("metric")))
      }
    }
    return out
  }
  let rows = if source == "inline" {
    _parse-inline-graph-data(parsed.at("metric"), stacked: parsed.at("kind") == "stackedbars")
  } else if source == "frustr" {
    _read-frustr-data(parsed.at("metric"))
  } else {
    _read-graph-data(parsed.at("metric"), stacked: parsed.at("kind") == "stackedbars")
  }
  let numbered = rows.any(row => row.at("position") != none)
  let out = ()
  if numbered {
    let lookup = (:)
    for row in rows {
      if row.at("position") != none {
        lookup.insert(str(row.at("position")), row.at("values"))
      }
    }
    for col in selected {
      let pos = sequence.at("positions").at(col)
      let values = if pos == none or not lookup.keys().contains(str(pos)) { () } else { lookup.at(str(pos)) }
      if parsed.at("kind") == "stackedbars" {
        out.push(values)
      } else {
        out.push(if values.len() > 0 { values.first() } else { none })
      }
    }
  } else {
    for idx in range(0, selected.len()) {
      if idx < rows.len() {
        let values = rows.at(idx).at("values")
        out.push(if parsed.at("kind") == "stackedbars" { values } else { if values.len() > 0 { values.first() } else { none } })
      } else {
        out.push(if parsed.at("kind") == "stackedbars" { () } else { none })
      }
    }
  }
  out
}

#let _graph-normalized(bounds, value) = {
  if value == none {
    return none
  }
  let lo = bounds.at(0)
  let hi = bounds.at(1)
  if hi == lo {
    return 0.0
  }
  calc.max(0.0, calc.min(1.0, (value - lo) / (hi - lo)))
}

#let _graph-stretch(config, kind, position) = {
  let table = if kind == "color" { config.at("color-scale-stretch") } else { config.at("bar-graph-stretch") }
  table.at(position, default: table.at("default"))
}

#let _graph-bar-colors(parsed, value) = {
  let options = parsed.at("options")
  let fg = if options.len() >= 1 and options.at(0) != "" {
    options.at(0)
  } else if parsed.at("metric") == "charge" and value < 0 {
    "BrickRed"
  } else if parsed.at("metric") == "charge" and value > 0 {
    "RoyalBlue"
  } else {
    "Gray60"
  }
  let bg = if options.len() >= 2 and options.at(1) != "" { options.at(1) } else { none }
  (fg: fg, bg: bg)
}

#let _graph-color-scale(parsed) = {
  let options = parsed.at("options")
  if options.len() >= 1 and options.at(0) != "" {
    options.at(0)
  } else if parsed.at("metric") == "charge" {
    "RedBlue"
  } else if parsed.at("metric") == "conservation" {
    "ColdHot"
  } else {
    "WhiteBlack"
  }
}

#let _stack-colors(parsed, count) = {
  let options = parsed.at("options")
  if parsed.at("kind") == "frustratometer" {
    if options.len() >= 3 {
      return (colors: (resolve-color(options.at(0)), resolve-color(options.at(1)), resolve-color(options.at(2))), background: none)
    }
    return (colors: (resolve-color("PineGreen"), resolve-color("Gray60"), resolve-color("BrickRed")), background: none)
  }
  if options.len() == 0 {
    let out = ()
    for idx in range(0, count) {
      let level = if count <= 1 { 50 } else { calc.round(idx * 100 / (count - 1)) }
      out.push(scale-color("BlueRed", level))
    }
    return (colors: out, background: none)
  }
  if _graph-scales.contains(options.first()) {
    let out = ()
    for idx in range(0, count) {
      let level = if count <= 1 { 50 } else { calc.round(idx * 100 / (count - 1)) }
      out.push(scale-color(options.first(), level))
    }
    let background = if options.len() >= 2 and options.at(1) != "" { options.at(1) } else { none }
    return (colors: out, background: background)
  }
  let out = ()
  for idx in range(0, count) {
    out.push(resolve-color(options.at(calc.min(idx, options.len() - 1))))
  }
  (colors: out, background: none)
}

#let _graph-resolution(parsed, config, position) = if parsed.at("kind") == "color" {
  calc.max(1, int(calc.ceil(_graph-stretch(config, "color", position))))
} else {
  calc.max(1, int(calc.ceil(8 * _graph-stretch(config, "bar", position))))
}

#let _graph-fill-cell(fill, background: none, frame: none) = (
  char: "",
  fg: "Black",
  bg: fill,
  emph: false,
  frame: frame,
)

#let _graph-color-rows(parsed, config, series, selected, segment, position) = {
  let rows = ()
  let levels = ()
  let bounds = _graph-range-from-style(parsed, series: series)
  for value in series {
    levels.push(_graph-normalized(bounds, value))
  }
  let repeat = _graph-resolution(parsed, config, position)
  for _ in range(0, repeat) {
    let cells = ()
    for col in segment {
      let idx = selected.position(col)
      if idx == none {
        cells.push(_empty-cell())
      } else {
        let level = levels.at(idx)
        if level == none {
          cells.push(_empty-cell())
        } else {
          cells.push(_graph-fill-cell(scale-color(_graph-color-scale(parsed), calc.round(level * 100)), frame: if parsed.at("metric") == "conservation" { resolve-color("Gray40") } else { none }))
        }
      }
    }
    rows.push(cells)
  }
  rows
}

#let _bar-segment(level, lo, hi) = level >= lo and level < hi

#let _graph-bar-rows(parsed, config, series, selected, segment, position) = {
  let rows = ()
  let bounds = _graph-range-from-style(parsed, series: series)
  let baseline = if bounds.at(0) < 0 and bounds.at(1) > 0 { _graph-normalized(bounds, 0.0) } else if bounds.at(1) <= 0 { 1.0 } else { 0.0 }
  let repeat = _graph-resolution(parsed, config, position)
  let bg = if parsed.at("options").len() >= 2 and parsed.at("options").at(1) != "" { parsed.at("options").at(1) } else { none }
  for row in range(0, repeat) {
    let level = 1.0 - row / repeat
    let cells = ()
    for col in segment {
      let idx = selected.position(col)
      if idx == none {
        cells.push(_empty-cell())
      } else {
        let value = series.at(idx)
        let normalized = _graph-normalized(bounds, value)
        if normalized == none {
          cells.push(_empty-cell())
        } else {
          let start = calc.min(normalized, baseline)
          let stop = calc.max(normalized, baseline)
          if _bar-segment(level, start, stop + 1.0 / repeat) {
            let colors = _graph-bar-colors(parsed, value)
            cells.push(_graph-fill-cell(resolve-color(colors.at("fg")), background: colors.at("bg")))
          } else if bg != none {
            cells.push(_graph-fill-cell(resolve-color(bg)))
          } else {
            cells.push(_empty-cell())
          }
        }
      }
    }
    rows.push(cells)
  }
  rows
}

#let _graph-stacked-rows(parsed, config, series, selected, segment, position) = {
  let rows = ()
  let bounds = _graph-range-from-style(parsed, series: series)
  let baseline = if bounds.at(0) < 0 and bounds.at(1) > 0 { _graph-normalized(bounds, 0.0) } else if bounds.at(1) <= 0 { 1.0 } else { 0.0 }
  let max-count = 0
  for values in series {
    if values.len() > max-count {
      max-count = values.len()
    }
  }
  let palette = _stack-colors(parsed, max-count)
  let repeat = _graph-resolution(parsed, config, position)
  for row in range(0, repeat) {
    let level = 1.0 - row / repeat
    let cells = ()
    for col in segment {
      let idx = selected.position(col)
      if idx == none {
        cells.push(_empty-cell())
      } else {
        let values = series.at(idx)
        let segments = ()
        let pos-cum = 0.0
        let neg-cum = 0.0
        for (value-index, value) in values.enumerate() {
          if value == none {
            continue
          }
          if value >= 0 {
            let start = _graph-normalized(bounds, pos-cum)
            pos-cum += value
            let stop = _graph-normalized(bounds, pos-cum)
            segments.push((lo: start, hi: stop, color: palette.at("colors").at(calc.min(value-index, palette.at("colors").len() - 1))))
          } else {
            let start = _graph-normalized(bounds, neg-cum)
            neg-cum += value
            let stop = _graph-normalized(bounds, neg-cum)
            segments.push((lo: stop, hi: start, color: palette.at("colors").at(calc.min(value-index, palette.at("colors").len() - 1))))
          }
        }
        let fill = none
        for segment-data in segments {
          if _bar-segment(level, segment-data.at("lo"), segment-data.at("hi") + 1.0 / repeat) {
            fill = segment-data.at("color")
          }
        }
        if fill != none {
          cells.push(_graph-fill-cell(fill))
        } else if palette.at("background") != none {
          cells.push(_graph-fill-cell(resolve-color(palette.at("background"))))
        } else if baseline != none and calc.abs(level - baseline) <= 1.0 / repeat {
          cells.push(_graph-fill-cell(resolve-color("Gray30")))
        } else {
          cells.push(_empty-cell())
        }
      }
    }
    rows.push(cells)
  }
  rows
}

#let _graph-rows(alignment, config, sequence, selected, segment, style, position: none) = {
  let parsed = _graph-style(style)
  if parsed == none {
    return ()
  }
  let series = _graph-series(parsed, alignment, sequence, selected)
  if parsed.at("kind") == "color" {
    return _graph-color-rows(parsed, config, series, selected, segment, position)
  } else if parsed.at("kind") == "stackedbars" or parsed.at("kind") == "frustratometer" {
    return _graph-stacked-rows(parsed, config, series, selected, segment, position)
  } else {
    return _graph-bar-rows(parsed, config, series, selected, segment, position)
  }
}
