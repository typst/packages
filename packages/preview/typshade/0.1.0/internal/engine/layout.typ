// Copyright (C) 2026 Eito Yoneyama
// SPDX-License-Identifier: GPL-2.0

#import "../model/pdb.typ": _pdb-selection-positions
#import "../model/parser.typ": _chars, _upper

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

#let _selection-columns(seq, selection) = {
  if selection == none {
    return ()
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
  let text = str(selection)
  if text.trim() == "all" {
    let out = ()
    for idx in range(0, seq.at("aligned").len()) {
      out.push(idx)
    }
    return out
  }
  let values = ()
  for part in text.split(",") {
    let trimmed = part.trim()
    if trimmed == "" {
      continue
    }
    if trimmed.contains("..") {
      let bounds = trimmed.split("..")
      let start = int(bounds.first())
      let stop = int(bounds.last())
      for (idx, pos) in seq.at("positions").enumerate() {
        if pos != none and pos >= start and pos <= stop {
          values.push(idx)
        }
      }
    } else {
      let pos = int(trimmed)
      for (idx, mapped) in seq.at("positions").enumerate() {
        if mapped == pos {
          values.push(idx)
        }
      }
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
