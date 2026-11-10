// Copyright (C) 2026 Eito Yoneyama
// SPDX-License-Identifier: GPL-2.0

#import "graphs.typ": _graph-rows, _graph-style
#import "../engine/layout.typ": _empty-cell, _ordinal-label, _selection-columns, _selection-string
#import "../model/logo.typ": _resolve-sequence
#import "../model/parser.typ": _array-fill, _chars, _lower, _upper

#let _top-feature-slots = ("ttttop", "tttop", "ttop", "top")
#let _bottom-feature-slots = ("bottom", "bbottom", "bbbottom", "bbbbottom")

#let _feature-label(config, position, text: false) = {
  let labels = if text { config.at("feature-text-names") } else { config.at("feature-style-names") }
  let colors = if text { config.at("feature-text-name-colors") } else { config.at("feature-style-name-colors") }
  (
    text: labels.at(position, default: ""),
    color: colors.at(position, default: colors.at("default")),
  )
}

#let _roman(index, upper: false) = {
  let pairs = ((1000, "m"), (900, "cm"), (500, "d"), (400, "cd"), (100, "c"), (90, "xc"), (50, "l"), (40, "xl"), (10, "x"), (9, "ix"), (5, "v"), (4, "iv"), (1, "i"))
  let value = index
  let out = ""
  for pair in pairs {
    while value >= pair.at(0) {
      out += pair.at(1)
      value -= pair.at(0)
    }
  }
  if upper { _upper(out) } else { out }
}

#let _structure-template(text, number, letter) = {
  let lower-letter = _lower(letter)
  str(text)
    .replace("\\numcount", str(number))
    .replace("\\alphacount", lower-letter)
    .replace("\\Alphacount", letter)
    .replace("\\romancount", _roman(number))
    .replace("\\Romancount", _roman(number, upper: true))
    .replace("$\\alpha$", "α")
    .replace("$\\beta$", "β")
    .replace("$\\pi$", "π")
    .replace("$\\circ$", "○")
    .replace("$\\uparrow$", "↑")
    .replace("$\\diamond$", "◇")
    .replace("$_{10}$", "10")
    .replace("$", "")
}

#let _structure-items(alignment, config) = {
  let items = ()
  for entry in config.at("structure-data") {
    let prefix = entry.at("kind")
    let sequence = entry.at("sequence")
    let shown = config.at("structure-show").at(prefix, default: ())
    let data = entry.at("data")
    if prefix == "HMMTOP" or prefix == "PHDtopo" {
      for (idx, range) in data.at("internal", default: ()).enumerate() {
        if shown.contains("internal") {
          let appearance = config.at("structure-appearance").at(prefix + ":internal")
          let letter = _ordinal-label(idx + 1)
          items.push((position: appearance.at("position"), sequence: sequence, selection: _selection-string(range), style: _structure-template(appearance.at("style"), idx + 1, letter), text: _structure-template(appearance.at("text"), idx + 1, letter)))
        }
      }
      for (idx, range) in data.at("external", default: ()).enumerate() {
        if shown.contains("external") {
          let appearance = config.at("structure-appearance").at(prefix + ":external")
          let letter = _ordinal-label(idx + 1)
          items.push((position: appearance.at("position"), sequence: sequence, selection: _selection-string(range), style: _structure-template(appearance.at("style"), idx + 1, letter), text: _structure-template(appearance.at("text"), idx + 1, letter)))
        }
      }
      for (idx, range) in data.at("spans", default: data.at("tm", default: ())).enumerate() {
        if shown.contains("TM") {
          let appearance = config.at("structure-appearance").at(prefix + ":TM")
          let letter = _ordinal-label(idx + 1)
          items.push((position: appearance.at("position"), sequence: sequence, selection: _selection-string(range), style: _structure-template(appearance.at("style"), idx + 1, letter), text: _structure-template(appearance.at("text"), idx + 1, letter)))
        }
      }
    } else if prefix == "PHDsec" {
      for (idx, range) in data.at("alpha", default: ()).enumerate() {
        if shown.contains("alpha") {
          let appearance = config.at("structure-appearance").at("PHDsec:alpha")
          let letter = _ordinal-label(idx + 1)
          items.push((position: appearance.at("position"), sequence: sequence, selection: _selection-string(range), style: _structure-template(appearance.at("style"), idx + 1, letter), text: _structure-template(appearance.at("text"), idx + 1, letter)))
        }
      }
      for (idx, range) in data.at("beta", default: ()).enumerate() {
        if shown.contains("beta") {
          let appearance = config.at("structure-appearance").at("PHDsec:beta")
          let letter = _ordinal-label(idx + 1)
          items.push((position: appearance.at("position"), sequence: sequence, selection: _selection-string(range), style: _structure-template(appearance.at("style"), idx + 1, letter), text: _structure-template(appearance.at("text"), idx + 1, letter)))
        }
      }
    } else if prefix == "STRIDE" or prefix == "DSSP" {
      for key in shown {
        for (idx, range) in data.at(key, default: ()).enumerate() {
          let appearance = config.at("structure-appearance").at(prefix + ":" + key)
          let letter = _ordinal-label(idx + 1)
          items.push((position: appearance.at("position"), sequence: sequence, selection: _selection-string(range), style: _structure-template(appearance.at("style"), idx + 1, letter), text: _structure-template(appearance.at("text"), idx + 1, letter)))
        }
      }
    }
  }
  items
}

#let _base-matches(pattern, base) = {
  let map = (
    A: "A", C: "C", G: "G", T: "TU", U: "TU",
    R: "AG", Y: "CTU", K: "GTU", M: "AC", S: "CG", W: "ATU",
    B: "CGTU", D: "AGTU", H: "ACTU", V: "ACG", N: "ACGTU",
  )
  map.at(_upper(pattern), default: _upper(pattern)).contains(_upper(base))
}

#let _codon-matches(pattern, codon) = {
  if pattern.len() != 3 or codon.len() != 3 {
    return false
  }
  for idx in range(0, 3) {
    if not _base-matches(pattern.slice(idx, idx + 1), codon.slice(idx, idx + 1)) {
      return false
    }
  }
  true
}

#let _translate-codon(config, codon) = {
  let cleaned = _upper(str(codon)).replace("U", "T")
  for residue in config.at("genetic-code").keys() {
    if _codon-matches(config.at("genetic-code").at(residue).replace("U", "T"), cleaned) {
      return residue
    }
  }
  "X"
}

#let _complement-base(base) = {
  let pairs = (A: "T", T: "A", U: "A", G: "C", C: "G", R: "Y", Y: "R", K: "M", M: "K", S: "S", W: "W", B: "V", V: "B", D: "H", H: "D", N: "N")
  pairs.at(_upper(base), default: _upper(base))
}

#let _style-colors(style, default-fg: "Black", default-bg: none) = {
  let hit = str(style).matches(regex("\\[([^\\]]+)\\]"))
  if hit.len() == 0 {
    return (fg: default-fg, bg: default-bg)
  }
  let parts = hit.first().captures.at(0).split(",").map(part => part.trim())
  (fg: if parts.len() > 0 and parts.first() != "" { parts.first() } else { default-fg }, bg: if parts.len() > 1 and parts.at(1) != "" { parts.at(1) } else { default-bg })
}

#let _backtranslation-label(config, triplet, index) = {
  let style = config.at("backtranslation").at("label-style")
  if style == "vertical" {
    triplet.slice(0, 1) + "\n" + triplet.slice(1, 2) + "\n" + triplet.slice(2, 3)
  } else if style == "oblique" {
    triplet.slice(0, 1) + "/" + triplet.slice(1, 2) + "/" + triplet.slice(2, 3)
  } else if style == "zigzag" {
    if calc.rem(index, 2) == 0 { triplet } else { triplet.slice(2, 3) + triplet.slice(1, 2) + triplet.slice(0, 1) }
  } else {
    triplet
  }
}

#let _translation-cells(alignment, config, sequence, style, segment, selected) = {
  let cells = _array-fill(segment.len(), _empty-cell())
  let colors = _style-colors(style)
  if alignment.at("seq-type") == "P" {
    for (idx, col) in segment.enumerate() {
      if selected.contains(col) {
        let residue = _upper(sequence.at("aligned").slice(col, col + 1))
        if residue != "." and residue != "-" {
          cells.at(idx).insert("char", _backtranslation-label(config, config.at("genetic-code").at(residue, default: "NNN"), idx))
          cells.at(idx).insert("fg", colors.at("fg"))
          cells.at(idx).insert("bg", colors.at("bg"))
          cells.at(idx).insert("size", config.at("backtranslation").at("label-size"))
        }
      }
    }
    return cells
  }
  let codon = ""
  let codon-cols = ()
  for col in selected {
    let residue = sequence.at("aligned").slice(col, col + 1)
    if residue == "." or residue == "-" {
      continue
    }
    codon += residue
    codon-cols.push(col)
    if codon.len() == 3 {
      let center-col = codon-cols.at(1)
      let target = segment.position(center-col)
      if target != none {
        cells.at(target).insert("char", _translate-codon(config, codon))
        cells.at(target).insert("fg", colors.at("fg"))
        cells.at(target).insert("bg", colors.at("bg"))
        cells.at(target).insert("size", config.at("backtranslation").at("text-size"))
      }
      codon = ""
      codon-cols = ()
    }
  }
  cells
}

#let _complement-cells(config, sequence, style, segment, selected) = {
  let cells = _array-fill(segment.len(), _empty-cell())
  let colors = _style-colors(style)
  let lower = str(style).contains("[lower]")
  for (idx, col) in segment.enumerate() {
    if selected.contains(col) {
      let residue = sequence.at("aligned").slice(col, col + 1)
      if residue != "." and residue != "-" {
        let base = _complement-base(residue)
        cells.at(idx).insert("char", if lower { _lower(base) } else { base })
        cells.at(idx).insert("fg", colors.at("fg"))
        cells.at(idx).insert("bg", colors.at("bg"))
      }
    }
  }
  cells
}

#let _feature-cell(config, style, col, selected) = {
  if not selected.contains(col) {
    return _empty-cell()
  }
  if style == "" {
    return (char: "•", fg: "Black", bg: "LightGray", emph: false, frame: none)
  }
  if style.starts-with("box") {
    let fill = "LightGray"
    let hit = style.matches(regex("^box\\[([^\\]]+)\\]"))
    if hit.len() > 0 {
      fill = hit.first().captures.at(0)
    }
    return (char: "", fg: "Black", bg: fill, emph: false, frame: "Black", frame-thickness: config.at("feature-rule"))
  }
  if style == "helix" {
    return (char: "≋", fg: "Black", bg: none, emph: false, frame: none)
  }
  if style.starts-with("fill:") {
    let symbol = style.split(":").last()
    return (char: if symbol.len() > 0 { symbol.slice(0, 1) } else { "•" }, fg: "Black", bg: none, emph: false, frame: none)
  }
  if style.starts-with("brace") {
    return (char: "⌒", fg: "Black", bg: none, emph: false, frame: none)
  }
  if style.contains("=") {
    return (char: "━", fg: "Black", bg: none, emph: false, frame: none)
  }
  if style.contains("-") or style.contains(">") or style.contains("<") or style.contains(",") {
    return (char: "─", fg: "Black", bg: none, emph: false, frame: none)
  }
  (char: style.slice(0, 1), fg: "Black", bg: "LightGray", emph: false, frame: none)
}

#let _ruler-rows(alignment, config, segment, position) = {
  let seq = alignment.at("sequences").at(_resolve-sequence(alignment, config.at("ruler").at("sequence")))
  let steps = config.at("ruler").at("steps")
  let ruler-color = config.at("ruler-colors").at(position, default: config.at("ruler").at("color"))
  let ruler-name = config.at("ruler-names").at(position, default: "")
  let ruler-name-color = config.at("ruler-name-colors").at(position, default: ruler-color)
  let alt-labels = config.at("ruler-labels").at(position, default: (:))
  let rotated = config.at("ruler-rotation").at(position, default: false)
  let ticks = ()
  let labels = _array-fill(segment.len(), _empty-cell())
  for col in segment {
    let pos = seq.at("positions").at(col)
    if pos != none and calc.rem(pos, steps) == 0 {
      ticks.push((char: "|", fg: ruler-color, bg: none, emph: false, frame: none))
    } else {
      ticks.push(_empty-cell())
    }
  }
  for (idx, col) in segment.enumerate() {
    let pos = seq.at("positions").at(col)
    if pos != none and calc.rem(pos, steps) == 0 {
      let override = alt-labels.at(str(pos), default: none)
      let text = if override == none { str(pos) } else { override.at("text") }
      let color = if override == none or override.at("color") == none { ruler-color } else { override.at("color") }
      if rotated {
        labels.at(idx).insert("char", "")
        labels.at(idx).insert("rotated", text)
        labels.at(idx).insert("fg", color)
      } else {
        let start = calc.max(0, idx - text.len() + 1)
        for (offset, ch) in _chars(text).enumerate() {
          let target = start + offset
          if target < labels.len() {
            labels.at(target).insert("char", ch)
            labels.at(target).insert("fg", color)
          }
        }
      }
    }
  }
  let label-row = (label: ruler-name, label-color: ruler-name-color, left: "", right: "", cells: labels, row-kind: "ruler")
  let tick-row = (label: "", left: "", right: "", cells: ticks, row-kind: "ruler")
  if position == "bottom" {
    (tick-row, label-row)
  } else {
    (label-row, tick-row)
  }
}

#let _feature-rows(alignment, config, segment, position) = {
  let rows = ()
  let entries = ()
  for item in config.at("features") {
    entries.push(item)
  }
  for item in _structure-items(alignment, config) {
    entries.push(item)
  }
  for item in entries {
    if item.at("position") != position {
      continue
    }
    let seq = alignment.at("sequences").at(_resolve-sequence(alignment, item.at("sequence")))
    let selected = _selection-columns(seq, item.at("selection"))
    let graph = _graph-style(item.at("style"))
    let cells = if graph != none {
      none
    } else if str(item.at("style")).starts-with("translate") {
      _translation-cells(alignment, config, seq, item.at("style"), segment, selected)
    } else if str(item.at("style")).starts-with("complement") {
      _complement-cells(config, seq, item.at("style"), segment, selected)
    } else {
      let out = ()
      for col in segment {
        out.push(_feature-cell(config, item.at("style"), col, selected))
      }
      out
    }
    if graph != none {
      let style-label = _feature-label(config, position)
      for (row-index, graph-row) in _graph-rows(alignment, config, seq, selected, segment, item.at("style"), position: position).enumerate() {
        rows.push((
          label: if row-index == 0 { style-label.at("text") } else { "" },
          label-color: style-label.at("color"),
          left: "",
          right: "",
          cells: graph-row,
          row-kind: "feature",
        ))
      }
    } else {
      let style-label = _feature-label(config, position)
      rows.push((label: style-label.at("text"), label-color: style-label.at("color"), left: "", right: "", cells: cells, row-kind: "feature"))
    }
    let style-text = if type(item.at("style")) == str { item.at("style") } else { "" }
    let inline-text = if style-text.starts-with("box") and style-text.contains(":") {
      style-text.split(":").last()
    } else {
      ""
    }
    let label = if item.at("text") != "" { item.at("text") } else { inline-text }
    if label != "" {
      let text-label = _feature-label(config, position, text: true)
      let label-cells = _array-fill(segment.len(), _empty-cell())
      let in-segment = ()
      for (idx, col) in segment.enumerate() {
        if selected.contains(col) {
          in-segment.push(idx)
        }
      }
      if in-segment.len() > 0 {
        let start = calc.max(0, calc.min(in-segment.first(), in-segment.last()) - 1)
        for (offset, ch) in _chars(label).enumerate() {
          let target = start + offset
          if target < label-cells.len() {
            label-cells.at(target).insert("char", ch)
          }
        }
      }
      rows.push((label: text-label.at("text"), label-color: text-label.at("color"), left: "", right: "", cells: label-cells, row-kind: "feature-text"))
    }
  }
  rows
}
