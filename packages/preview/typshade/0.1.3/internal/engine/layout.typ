// Copyright (C) 2026 Eito Yoneyama
// SPDX-License-Identifier: GPL-2.0

#import "../model/pdb.typ": _pdb-selection-positions
#import "../model/parser.typ": _chars, _lower, _upper

#let _motif-pattern(selection) = {
  let text = str(selection).trim()
  if text == "" or text == "all" or text.contains("..") or text.contains(":") or text.matches(regex("^\\d+(?:\\s*,\\s*\\d+)*$")).len() > 0 {
    return none
  }
  let pattern = ()
  let idx = 0
  while idx < text.len() {
    let ch = text.slice(idx, idx + 1)
    if ch == "[" {
      let rest = text.slice(idx + 1)
      let close = rest.position("]")
      if close == none {
        return none
      }
      pattern.push(_upper(rest.slice(0, close)))
      idx += close + 2
    } else if ch == "X" or ch == "x" {
      pattern.push(none)
      idx += 1
    } else if ch.matches(regex("[A-Za-z]")).len() > 0 {
      pattern.push(_upper(ch))
      idx += 1
    } else {
      return none
    }
  }
  pattern
}

#let _motif-columns(seq, selection) = {
  let pattern = _motif-pattern(selection)
  if pattern == none {
    return none
  }
  let residues = ()
  let columns = ()
  for (idx, ch) in _chars(seq.at("aligned")).enumerate() {
    if ch == "." or ch == "-" {
      continue
    }
    residues.push(_upper(ch))
    columns.push(idx)
  }
  let out = ()
  if pattern.len() == 0 or residues.len() < pattern.len() {
    return out
  }
  for start in range(0, residues.len() - pattern.len() + 1) {
    let matched = true
    for offset in range(0, pattern.len()) {
      let allowed = pattern.at(offset)
      if allowed != none and not allowed.contains(residues.at(start + offset)) {
        matched = false
      }
    }
    if matched {
      for offset in range(0, pattern.len()) {
        out.push(columns.at(start + offset))
      }
    }
  }
  out
}

#let _selection-fail(selection, reason) = {
  assert(false, message: "typshade: invalid selection `" + str(selection) + "`: " + reason)
}

#let _is-gap(char) = char == "." or char == "-"

#let _all-columns(seq) = {
  let out = ()
  for idx in range(0, seq.at("aligned").len()) {
    out.push(idx)
  }
  out
}

#let _set-key(item) = str(item)

#let _contains-column(items, column) = {
  let key = _set-key(column)
  for item in items {
    if _set-key(item) == key {
      return true
    }
  }
  false
}

#let _union-columns(groups) = {
  let out = ()
  let seen = (:)
  for group in groups {
    for column in group {
      let key = _set-key(column)
      if not seen.keys().contains(key) {
        seen.insert(key, true)
        out.push(column)
      }
    }
  }
  out.sorted()
}

#let _intersection-columns(groups) = {
  if groups.len() == 0 {
    return ()
  }
  let out = ()
  for column in groups.first() {
    let present = true
    for group in groups.slice(1) {
      if not _contains-column(group, column) {
        present = false
      }
    }
    if present and not _contains-column(out, column) {
      out.push(column)
    }
  }
  out.sorted()
}

#let _difference-columns(base, remove) = base.filter(column => not _contains-column(remove, column))

#let _selection-columns-from-positions(seq, positions) = {
  let wanted = if type(positions) == array { positions } else { (positions,) }
  let out = ()
  for (idx, mapped) in seq.at("positions").enumerate() {
    if mapped != none and wanted.contains(mapped) {
      out.push(idx)
    }
  }
  out
}

#let _selection-columns-from-range(seq, start, stop) = {
  let out = ()
  let low = calc.min(start, stop)
  let high = calc.max(start, stop)
  for (idx, pos) in seq.at("positions").enumerate() {
    if pos != none and pos >= low and pos <= high {
      out.push(idx)
    }
  }
  out
}

#let _column-residues(alignment, column) = {
  let residues = ()
  for sequence in alignment.at("sequences") {
    let ch = _upper(sequence.at("aligned").slice(column, column + 1))
    if not _is-gap(ch) {
      residues.push(ch)
    }
  }
  residues
}

#let _column-metric(alignment, column, metric) = {
  let name = _lower(str(metric))
  let count = alignment.at("sequences").len()
  let residues = _column-residues(alignment, column)
  let covered = residues.len()
  if name == "coverage" {
    if count == 0 { 0.0 } else { covered * 100.0 / count }
  } else if name == "gap-fraction" or name == "gaps" {
    if count == 0 { 0.0 } else { (count - covered) * 100.0 / count }
  } else if name == "entropy" {
    if covered == 0 {
      0.0
    } else {
      let counts = (:)
      for residue in residues {
        counts.insert(residue, counts.at(residue, default: 0) + 1)
      }
      let total = 0.0
      for value in counts.values() {
        let p = value / covered
        total -= p * calc.log(p) / calc.log(2)
      }
      total
    }
  } else if name == "conservation" or name == "identity" {
    if covered == 0 {
      0.0
    } else {
      let counts = (:)
      for residue in residues {
        counts.insert(residue, counts.at(residue, default: 0) + 1)
      }
      let max-count = 0
      for value in counts.values() {
        if value > max-count {
          max-count = value
        }
      }
      max-count * 100.0 / covered
    }
  } else {
    _selection-fail((kind: "typshade-selection", op: "metric", metric: metric), "unknown metric `" + str(metric) + "`")
  }
}

#let _metric-passes(value, spec) = {
  if spec.at("above", default: none) != none and not (value > spec.at("above")) {
    return false
  }
  if spec.at("below", default: none) != none and not (value < spec.at("below")) {
    return false
  }
  if spec.at("at-least", default: spec.at("min", default: none)) != none and value < spec.at("at-least", default: spec.at("min", default: none)) {
    return false
  }
  if spec.at("at-most", default: spec.at("max", default: none)) != none and value > spec.at("at-most", default: spec.at("max", default: none)) {
    return false
  }
  if spec.at("equals", default: none) != none and value != spec.at("equals") {
    return false
  }
  true
}

#let _selection-columns-from-metric(seq, selection, alignment, resolve) = {
  assert(alignment != none, message: "typshade: metric selections require alignment context")
  let base = resolve(selection.at("selection", default: "all"))
  let out = ()
  for column in base {
    let value = _column-metric(alignment, column, selection.at("metric", default: selection.at("name", default: "conservation")))
    if _metric-passes(value, selection) {
      out.push(column)
    }
  }
  out
}

#let _pad-selection-columns(seq, columns, before, after) = {
  if columns.len() == 0 {
    return ()
  }
  let first = none
  let last = none
  for column in columns {
    let pos = seq.at("positions").at(column)
    if pos != none {
      if first == none or pos < first {
        first = pos
      }
      if last == none or pos > last {
        last = pos
      }
    }
  }
  if first == none or last == none {
    return columns
  }
  _selection-columns-from-range(seq, calc.max(1, first - before), last + after)
}

#let _selection-dsl-columns(seq, selection, alignment: none, resolve: none) = {
  let op = selection.at("op", default: "or")
  if op == "all" {
    return _all-columns(seq)
  }
  if op == "range" {
    let range-value = selection.at("range", default: none)
    if range-value != none {
      return resolve(range-value)
    }
    return _selection-columns-from-range(seq, int(selection.at("start")), int(selection.at("stop", default: selection.at("start"))))
  }
  if op == "positions" {
    return _selection-columns-from-positions(seq, selection.at("positions"))
  }
  if op == "motif" {
    let columns = _motif-columns(seq, selection.at("pattern"))
    return if columns == none { () } else { columns }
  }
  if op == "metric" {
    return _selection-columns-from-metric(seq, selection, alignment, resolve)
  }
  if op == "not" {
    return _difference-columns(_all-columns(seq), resolve(selection.at("selection")))
  }
  if op == "pad" {
    let before = int(selection.at("before", default: selection.at("padding", default: 0)))
    let after = int(selection.at("after", default: before))
    return _pad-selection-columns(seq, resolve(selection.at("selection")), before, after)
  }
  let items = selection.at("items", default: ())
  let groups = items.map(item => resolve(item))
  let columns = if op == "and" {
    _intersection-columns(groups)
  } else if op == "or" or op == "select" {
    _union-columns(groups)
  } else {
    _selection-fail(selection, "unknown selection operation `" + str(op) + "`")
  }
  let padding = int(selection.at("padding", default: 0))
  if padding != 0 {
    _pad-selection-columns(seq, columns, padding, padding)
  } else {
    columns
  }
}

#let _selection-columns(seq, selection, alignment: none) = {
  if selection == none {
    return ()
  }
  if type(selection) == dictionary and selection.at("kind", default: none) == "typshade-selection" {
    return _selection-dsl-columns(seq, selection, alignment: alignment, resolve: item => _selection-columns(seq, item, alignment: alignment))
  }
  let pdb-positions = _pdb-selection-positions(selection)
  if pdb-positions != none {
    let values = ()
    for (idx, mapped) in seq.at("positions").enumerate() {
      if mapped != none and pdb-positions.contains(mapped) {
        values.push(idx)
      }
    }
    return values
  }
  let motif-columns = _motif-columns(seq, selection)
  if motif-columns != none {
    return motif-columns
  }
  let text = str(selection).trim()
  if text.trim() == "all" {
    return _all-columns(seq)
  }
  if text.contains(":") {
    _selection-fail(selection, "expected a valid PDB selection such as point[1]:source,1[CA]")
  }
  if text.matches(regex("[A-Za-z\\[]")).len() > 0 {
    _selection-fail(selection, "expected a residue range/list or a valid motif pattern")
  }
  let values = ()
  for part in text.split(",") {
    let trimmed = part.trim()
    if trimmed == "" {
      continue
    }
    if trimmed.contains("..") {
      let bounds = trimmed.split("..")
      assert(
        bounds.len() == 2 and bounds.first().matches(regex("^\\d+$")).len() > 0 and bounds.last().matches(regex("^\\d+$")).len() > 0,
        message: "typshade: invalid selection `" + str(selection) + "`: ranges must look like 1..10",
      )
      values += _selection-columns-from-range(seq, int(bounds.first()), int(bounds.last()))
    } else {
      assert(
        trimmed.matches(regex("^\\d+$")).len() > 0,
        message: "typshade: invalid selection `" + str(selection) + "`: entries must be residue numbers, ranges, motifs, or all",
      )
      values += _selection-columns-from-positions(seq, int(trimmed))
    }
  }
  values
}

#let _sorted-unique(items) = {
  let seen = (:)
  let out = ()
  for item in items {
    let key = str(item)
    if not seen.keys().contains(key) {
      seen.insert(key, true)
      out.push(item)
    }
  }
  out.sorted()
}

#let _empty-cell() = (char: "", fg: "Black", bg: none, emph: false, frame: none)

#let _ordinal-label(index) = {
  let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  if index <= letters.len() {
    letters.slice(index - 1, index)
  } else {
    str(index)
  }
}

#let _selection-string(range) = str(range.at(0)) + ".." + str(range.at(1))
