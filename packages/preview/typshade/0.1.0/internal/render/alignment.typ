// Copyright (C) 2026 Eito Yoneyama
// SPDX-License-Identifier: GPL-2.0

#import "../engine/config.typ": _apply-command, _default-config
#import "features.typ": _bottom-feature-slots, _feature-rows, _ruler-rows, _top-feature-slots
#import "../engine/layout.typ": _empty-cell, _selection-columns, _sorted-unique
#import "../model/logo.typ": _resolve-sequence
#import "logos.typ": _legend-block, _logo-block
#import "../model/palette.typ": resolve-color, scale-color
#import "../model/parser.typ": _array-fill, _chars, _lower, _upper, read-alignment
#import "../model/text-style.typ": _text-params, _text-string

#let _display-columns(alignment, config) = {
  let selected = ()
  for command in config.at("sequence-windows") {
    let seq = alignment.at("sequences").at(_resolve-sequence(alignment, command.at("sequence")))
    for col in _selection-columns(seq, command.at("selection")) {
      selected.push(col)
    }
  }
  if selected.len() == 0 {
    selected = range(0, alignment.at("columns"))
  }
  let columns = _sorted-unique(selected)
  if not config.at("hide-allmatch-positions") {
    return columns
  }
  let out = ()
  for col in columns {
    let info = _style-for-column(alignment, config, col)
    if info.at("consensus-score") < config.at("allmatch-threshold") {
      out.push(col)
    }
  }
  out
}

#let _residue-group(char, seq-type, config) = {
  let groups = if seq-type == "N" { config.at("dna-groups") } else { config.at("pep-groups") }
  for (idx, group) in groups.enumerate() {
    if group.contains(char) {
      return idx
    }
  }
  none
}

#let _is-similar(residue, consensus, seq-type, config) = {
  if residue == consensus {
    return true
  }
  let sims = if seq-type == "N" { config.at("dna-sims") } else { config.at("pep-sims") }
  if sims.keys().contains(consensus) {
    return sims.at(consensus).contains(residue)
  }
  false
}

#let _weight-order = ("C", "S", "T", "P", "A", "G", "N", "D", "E", "Q", "H", "R", "K", "M", "I", "L", "V", "F", "Y", "W")

#let _structural-rows = (
  C: (10, 6, 3, 3, 3, 5, 3, 1, 0, 1, 3, 3, 0, 3, 3, 3, 3, 5, 5, 5),
  S: (6, 10, 8, 6, 8, 8, 8, 6, 5, 5, 5, 5, 5, 3, 3, 3, 6, 5, 5, 3),
  T: (3, 8, 10, 6, 8, 6, 6, 5, 5, 5, 3, 5, 6, 5, 5, 3, 6, 3, 3, 1),
  P: (3, 6, 6, 10, 8, 6, 3, 5, 5, 5, 5, 5, 3, 3, 3, 5, 6, 5, 3, 3),
  A: (3, 8, 8, 8, 10, 8, 5, 6, 6, 5, 3, 3, 5, 5, 3, 3, 8, 5, 3, 3),
  G: (5, 8, 6, 6, 8, 10, 5, 6, 6, 3, 1, 5, 3, 1, 3, 3, 6, 3, 3, 5),
  N: (3, 8, 6, 3, 5, 5, 10, 8, 6, 5, 6, 5, 6, 1, 3, 1, 3, 3, 5, 0),
  D: (1, 6, 5, 5, 6, 6, 8, 10, 8, 6, 5, 3, 5, 3, 1, 1, 5, 1, 3, 0),
  E: (0, 5, 5, 5, 6, 6, 6, 8, 10, 6, 3, 5, 6, 3, 1, 1, 6, 3, 1, 1),
  Q: (1, 5, 5, 5, 5, 3, 5, 6, 6, 10, 6, 5, 6, 3, 1, 3, 3, 1, 3, 1),
  H: (3, 5, 3, 5, 3, 1, 6, 5, 3, 6, 10, 6, 5, 3, 3, 5, 1, 3, 5, 1),
  R: (3, 5, 5, 5, 3, 5, 5, 3, 5, 5, 6, 10, 8, 3, 3, 3, 3, 1, 1, 3),
  K: (0, 5, 6, 3, 5, 3, 6, 5, 6, 6, 5, 8, 10, 3, 3, 3, 5, 1, 1, 1),
  M: (3, 5, 5, 3, 5, 1, 1, 3, 3, 3, 3, 3, 3, 10, 6, 8, 6, 5, 3, 5),
  I: (3, 3, 5, 3, 3, 3, 3, 1, 1, 1, 3, 3, 3, 6, 10, 8, 3, 6, 5, 5),
  L: (3, 3, 3, 5, 3, 3, 1, 1, 1, 3, 5, 3, 3, 8, 8, 10, 3, 6, 5, 6),
  V: (3, 6, 6, 6, 8, 6, 3, 5, 6, 3, 1, 3, 5, 6, 3, 3, 10, 6, 5, 5),
  F: (5, 5, 3, 5, 5, 3, 3, 1, 3, 1, 3, 1, 1, 5, 6, 6, 6, 10, 8, 5),
  Y: (5, 5, 3, 3, 3, 3, 5, 3, 1, 3, 5, 1, 1, 3, 5, 5, 5, 8, 10, 5),
  W: (5, 3, 1, 3, 3, 5, 0, 0, 1, 1, 1, 3, 1, 5, 5, 6, 5, 5, 5, 10),
)

#let _pam250-rows = (
  C: (4, 0, -2, -3, -2, -3, -4, 2, -5, -5, -3, -4, -5, -5, -2, -6, -2, -4, 0, -8),
  S: (0, 3, 1, 1, 1, 1, 1, 0, 0, -1, -1, 0, 0, -2, -1, -3, -1, -3, -3, -2),
  T: (-2, 1, 3, 0, 1, 0, 0, 0, 0, -1, -1, -1, 0, -1, 0, -2, 0, -2, -3, -5),
  P: (-3, 1, 0, 6, 1, -1, -1, -1, -1, 0, 0, 0, -1, -2, -2, -3, -1, -5, -5, -6),
  A: (-2, 1, 1, 1, 2, 1, 0, 0, 0, 0, -1, -2, -1, -1, -1, -2, 0, -4, -3, -6),
  G: (-3, 1, 0, -1, 1, 5, 0, 1, 0, -1, -2, -3, -2, -3, -3, -4, -1, -5, -5, -7),
  N: (-4, 1, 0, -1, 0, 0, 2, 2, 1, 1, 2, 0, 1, -2, -2, -3, -2, -4, -2, -4),
  D: (-5, 0, 0, -1, 0, 1, 2, 4, 3, 2, 1, -1, 0, -3, -2, -4, -2, -6, -4, -7),
  E: (-5, 0, 0, -1, 0, 0, 1, 3, 4, 2, 1, -1, 0, -2, -2, -3, -2, -5, -4, -7),
  Q: (-5, -1, -1, 0, 0, -1, 1, 2, 2, 4, 3, 1, 1, -1, -2, -2, -2, -5, -4, -5),
  H: (-3, -1, -1, 0, -1, -2, 2, 1, 1, 3, 6, 2, 0, -2, -2, -2, -2, -2, -5, -7),
  R: (-4, 0, -1, 0, -2, -3, 0, -1, -1, 1, 2, 6, 3, 0, -2, -3, -2, -4, -4, 2),
  K: (-5, 0, 0, -1, -1, -2, 1, 0, 0, 1, 0, 3, 5, 0, -2, -3, -2, -5, -4, -3),
  M: (-5, -2, -1, -2, -1, -3, -2, -3, -2, -1, -2, 0, 0, 6, 2, 4, 2, 0, -2, -4),
  I: (-2, -1, 0, -2, -1, -3, -2, -2, -2, -2, -2, -2, -2, 2, 5, 2, 4, 1, -1, -5),
  L: (-6, -3, -2, -3, -2, -4, -3, -4, -3, -2, -2, -3, -3, 4, 2, 6, 2, 2, -1, -2),
  V: (-2, -1, 0, -1, 0, -1, -2, -2, -2, -2, -2, -2, -2, 2, 4, 2, 4, -1, -2, -6),
  F: (-4, -3, -2, -5, -4, -5, -4, -6, -5, -5, -2, -4, -5, 0, 1, 2, -1, 9, 7, 0),
  Y: (0, -3, -3, -5, -3, -5, -2, -4, -4, -4, 0, -4, -4, -2, -1, -1, -2, 7, 10, 0),
  W: (-8, -2, -5, -6, -6, -7, -4, -7, -7, -5, -3, 2, -3, -4, -5, -2, -6, 0, 0, 17),
)

#let _pam100-rows = (
  C: (14, -1, -5, -6, -5, -8, -8, -11, -11, -11, -6, -6, -11, -11, -5, -12, -4, -10, -2, -13),
  S: (-1, 6, 2, 1, 2, 1, 2, -1, -2, -3, -4, -1, -2, -4, -4, -7, -4, -5, -6, -4),
  T: (-5, 2, 7, -1, 2, -3, 0, -2, -3, -3, -5, -4, -1, -2, -1, -5, -1, -6, -6, -10),
  P: (-6, 1, -1, 10, 1, -3, -3, -4, -3, -1, -2, -2, -4, -6, -6, -5, -4, -9, -11, -11),
  A: (-5, 2, 2, 1, 6, 1, -1, -1, 0, -2, -5, -5, -4, -3, -3, -5, 0, -7, -6, -11),
  G: (-8, 1, -3, -3, 1, 8, -1, -1, -2, -5, -7, -8, -5, -8, -7, -8, -4, -8, -11, -13),
  N: (-8, 2, 0, -3, -1, -1, 7, 4, 1, -1, 2, -3, 1, -5, -4, -6, -5, -6, -3, -8),
  D: (-11, -1, -2, -4, -1, -1, 4, 8, 5, 1, -1, -6, -2, -8, -6, -9, -6, -11, -9, -13),
  E: (-11, -2, -3, -3, 0, -2, 1, 5, 8, 4, -2, -5, -2, -6, -5, -7, -5, -11, -7, -14),
  Q: (-11, -3, -3, -1, -2, -5, -1, 1, 4, 9, 4, 1, -1, -2, -5, -3, -5, -10, -9, -11),
  H: (-6, -4, -5, -2, -5, -7, 2, -1, -2, 4, 11, 1, -3, -7, -7, -5, -6, -4, -1, -7),
  R: (-6, -1, -4, -2, -5, -8, -3, -6, -5, 1, 1, 10, 3, -2, -4, -7, -6, -7, -10, 1),
  K: (-11, -2, -1, -4, -4, -5, 1, -2, -2, -1, -3, 3, 8, 1, -4, -6, -6, -11, -10, -9),
  M: (-11, -4, -2, -6, -3, -8, -5, -8, -6, -2, -7, -2, 1, 13, 2, 4, 1, -2, -8, -11),
  I: (-5, -4, -1, -6, -3, -7, -4, -6, -5, -5, -7, -4, -4, 2, 9, 2, 5, 0, -4, -12),
  L: (-12, -7, -5, -5, -5, -8, -6, -9, -7, -3, -5, -7, -6, 4, 2, 9, 1, 0, -5, -7),
  V: (-4, -4, -1, -4, 0, -4, -5, -6, -5, -5, -6, -6, -6, 1, 5, 1, 8, -5, -6, -14),
  F: (-10, -5, -6, -9, -7, -8, -6, -11, -11, -10, -4, -7, -11, -2, 0, 0, -5, 12, 6, -2),
  Y: (-2, -6, -6, -11, -6, -11, -3, -9, -7, -9, -1, -10, -10, -8, -4, -5, -6, 6, 13, -2),
  W: (-13, -4, -10, -11, -11, -13, -8, -13, -14, -11, -7, 1, -9, -11, -12, -7, -14, -2, -2, 19),
)

#let _blosum62-rows = (
  C: (9, -1, -1, -3, 0, -3, -3, -3, -4, -3, -3, -3, -3, -1, -1, -1, -1, -2, -2, -2),
  S: (-1, 4, 1, -1, 1, 0, 1, 0, 0, 0, -1, -1, 0, -1, -2, -2, -2, -2, -2, -3),
  T: (-1, 1, 4, 1, -1, 1, 0, 1, 0, 0, 0, -1, 0, -1, -2, -2, -2, -2, -2, -3),
  P: (-3, -1, 1, 7, -1, -2, -1, -1, -1, -1, -2, -2, -1, -2, -3, -3, -2, -4, -3, -4),
  A: (0, 1, -1, -1, 4, 0, -1, -2, -1, -1, -2, -1, -1, -1, -1, -1, -2, -2, -2, -3),
  G: (-3, 0, 1, -2, 0, 6, -2, -1, -2, -2, -2, -2, -2, -3, -4, -4, 0, -3, -3, -2),
  N: (-3, 1, 0, -2, -2, 0, 6, 1, 0, 0, -1, 0, 0, -2, -3, -3, -3, -3, -2, -4),
  D: (-3, 0, 1, -1, -2, -1, 1, 6, 2, 0, -1, -2, -1, -3, -3, -4, -3, -3, -3, -4),
  E: (-4, 0, 0, -1, -1, -2, 0, 2, 5, 2, 0, 0, 1, -2, -3, -3, -3, -3, -2, -3),
  Q: (-3, 0, 0, -1, -1, -2, 0, 0, 2, 5, 0, 1, 1, 0, -3, -2, -2, -3, -1, -2),
  H: (-3, -1, 0, -2, -2, -2, 1, 1, 0, 0, 8, 0, -1, -2, -3, -3, -2, -1, 2, -2),
  R: (-3, -1, -1, -2, -1, -2, 0, -2, 0, 1, 0, 5, 2, -1, -3, -2, -3, -3, -2, -3),
  K: (-3, 0, 0, -1, -1, -2, 0, -1, 1, 1, -1, 2, 5, -1, -3, -2, -3, -3, -2, -3),
  M: (-1, -1, -1, -2, -1, -3, -2, -3, -2, 0, -2, -1, -1, 5, 1, 2, -2, 0, -1, -1),
  I: (-1, -2, -2, -3, -1, -4, -3, -3, -3, -3, -3, -3, -3, 1, 4, 2, 1, 0, -1, -3),
  L: (-1, -2, -2, -3, -1, -4, -3, -4, -3, -2, -3, -2, -2, 2, 2, 4, 3, 0, -1, -2),
  V: (-1, -2, -2, -2, 0, -3, -3, -3, -2, -2, -3, -3, -2, 1, 3, 1, 4, -1, -1, -3),
  F: (-2, -2, -2, -4, -2, -3, -3, -3, -3, -3, -1, -3, -3, 0, 0, 0, -1, 6, 3, 1),
  Y: (-2, -2, -2, -3, -2, -3, -2, -3, -2, -1, 2, -2, -2, -1, -1, -1, -1, 3, 7, 2),
  W: (-2, -3, -3, -4, -3, -2, -4, -4, -3, -2, -2, -3, -3, -1, -3, -2, -3, 1, 2, 11),
)

#let _matrix-score(rows, a, b) = {
  let row = rows.at(a, default: none)
  let index = _weight-order.position(b)
  if row == none or index == none {
    none
  } else {
    row.at(index)
  }
}

#let _residue-weight(candidate, residue, seq-type, config) = {
  let pair = _upper(candidate) + ":" + _upper(residue)
  let custom = config.at("custom-weights")
  if custom.keys().contains(pair) {
    return custom.at(pair)
  }
  if str(config.at("weight-table")) == "structural" {
    let score = _matrix-score(_structural-rows, _upper(candidate), _upper(residue))
    if score != none {
      return score
    }
  }
  if str(config.at("weight-table")) == "BLOSUM62" {
    let score = _matrix-score(_blosum62-rows, _upper(candidate), _upper(residue))
    if score != none {
      return score
    }
  }
  if str(config.at("weight-table")) == "PAM250" {
    let score = _matrix-score(_pam250-rows, _upper(candidate), _upper(residue))
    if score != none {
      return score
    }
  }
  if str(config.at("weight-table")) == "PAM100" {
    let score = _matrix-score(_pam100-rows, _upper(candidate), _upper(residue))
    if score != none {
      return score
    }
  }
  if candidate == residue {
    return 10
  }
  let table = str(config.at("weight-table"))
  if table == "identity" {
    return 0
  }
  if _is-similar(candidate, residue, seq-type, config) {
    return if table == "structural" { 6 } else { 4 }
  }
  if _residue-group(candidate, seq-type, config) == _residue-group(residue, seq-type, config) {
    return if table == "structural" { 3 } else { 1 }
  }
  if table == "PAM250" or table == "PAM100" or table == "BLOSUM62" {
    return -2
  }
  0
}

#let _weighted-consensus(counts, residues, seq-type, config) = {
  if counts.keys().len() == 0 {
    return (consensus: none, score: 0)
  }
  let best = counts.keys().first()
  let best-score = none
  let best-count = 0
  for candidate in counts.keys() {
    let score = 0
    for residue in residues {
      let key = _upper(residue)
      if key == "." or key == "-" or key == "" {
        score += config.at("gap-penalty")
      } else {
        score += _residue-weight(candidate, key, seq-type, config)
      }
    }
    if best-score == none or score > best-score or (score == best-score and counts.at(candidate) > best-count) {
      best = candidate
      best-score = score
      best-count = counts.at(candidate)
    }
  }
  let max-self = calc.max(1, _residue-weight(best, best, seq-type, config))
  let normalized = calc.max(0, calc.min(100, best-score / (max-self * residues.len()) * 100))
  (consensus: best, score: normalized)
}

#let _matches-sequence(alignment, refs, index) = {
  let seq = alignment.at("sequences").at(index)
  for ref in refs {
    if ref == index + 1 or str(ref) == str(index + 1) or str(ref) == seq.at("name") {
      return true
    }
  }
  false
}

#let _sequence-label(alignment, config, sequence, sequence-index) = {
  let by-index = config.at("sequence-names").at(str(sequence-index + 1), default: none)
  if by-index != none {
    return by-index
  }
  config.at("sequence-names").at(sequence.at("name"), default: sequence.at("name"))
}

#let _sequence-color(config, sequence, sequence-index, key, default-color) = {
  let colors = config.at(key)
  let by-index = colors.at(str(sequence-index + 1), default: none)
  if by-index != none {
    return by-index
  }
  colors.at(sequence.at("name"), default: default-color)
}

#let _config-ref-value(map, sequence, sequence-index, default: none) = {
  let by-index = map.at(str(sequence-index + 1), default: none)
  if by-index != none {
    return by-index
  }
  map.at(sequence.at("name"), default: default)
}

#let _renumber-position(raw-pos, start, allow-zero) = {
  if raw-pos == none {
    return none
  }
  let shifted = start + raw-pos - 1
  if not allow-zero and start < 1 and shifted >= 0 {
    shifted + 1
  } else {
    shifted
  }
}

#let _rebuild-sequence(sequence, aligned) = {
  let positions = ()
  let raw = ""
  let pos = 0
  for ch in _chars(aligned) {
    if ch == "." or ch == "-" {
      positions.push(none)
    } else {
      pos += 1
      raw += ch
      positions.push(pos)
    }
  }
  sequence.insert("aligned", aligned)
  sequence.insert("raw", raw)
  sequence.insert("positions", positions)
  sequence.insert("length", pos)
}

#let _apply-single-sequence-options(alignment, config) = {
  if alignment.at("sequences").len() != 1 or config.at("single-seq-shift") == none {
    return
  }
  let sequence = alignment.at("sequences").first()
  let aligned = sequence.at("aligned")
  if not config.at("keep-single-seq-gaps") {
    while aligned.starts-with(".") or aligned.starts-with("-") {
      aligned = aligned.slice(1)
      if aligned.len() == 0 {
        break
      }
    }
  }
  let shift = int(config.at("single-seq-shift"))
  if shift > 0 {
    aligned = "." * shift + aligned
  } else if shift < 0 {
    let remove = calc.min(-shift, aligned.len())
    aligned = aligned.slice(remove)
  }
  _rebuild-sequence(sequence, aligned)
  alignment.insert("columns", aligned.len())
}

#let _apply-numbering-overrides(alignment, config) = {
  for (idx, sequence) in alignment.at("sequences").enumerate() {
    let start = _config-ref-value(config.at("start-numbers"), sequence, idx, default: 1)
    if start != 1 {
      let positions = ()
      for pos in sequence.at("positions") {
        positions.push(_renumber-position(pos, start, config.at("allow-zero")))
      }
      sequence.insert("positions", positions)
    }
    let length = _config-ref-value(config.at("sequence-lengths"), sequence, idx, default: none)
    if length != none {
      sequence.insert("length", length)
    }
  }
}

#let _functional-mode(config) = {
  let option = config.at("shading").at("option", default: none)
  if option == none { config.at("functional-default") } else { option }
}

#let _functional-style(config, residue) = {
  let overrides = config.at("functional-style-overrides")
  if overrides.keys().contains(residue) {
    return overrides.at(residue)
  }
  let mode = _functional-mode(config)
  let groups = config.at("functional-groups")
  if not groups.keys().contains(mode) {
    return none
  }
  for group in groups.at(mode) {
    if group.at("residues").contains(residue) {
      return group
    }
  }
  none
}

#let _tint-color(effect) = {
  if effect == "weak" {
    "Gray10"
  } else if effect == "strong" {
    "Gray30"
  } else {
    "LightGray"
  }
}

#let _column-tcoffee-score(alignment, config, col) = {
  let total = 0
  let count = 0
  for seq in alignment.at("sequences") {
    let scores = config.at("tcoffee").at("scores").at(seq.at("name"), default: ())
    if col < scores.len() and scores.at(col) != none {
      total += scores.at(col)
      count += 1
    }
  }
  if count == 0 { 0 } else { total / count }
}

#let _style-for-column(alignment, config, col) = {
  let mode = config.at("shading").at("mode")
  let seq-type = alignment.at("seq-type")
  let residues = ()
  let counts = (:)
  for seq in alignment.at("sequences") {
    let char = seq.at("aligned").slice(col, col + 1)
    residues.push(char)
    if char != "." and char != "-" {
      let key = _upper(char)
      counts.insert(key, counts.at(key, default: 0) + 1)
    }
  }
  let styles = ()
  let consensus = none
  let consensus-score = 0
  if counts.keys().len() > 0 {
    let max-key = counts.keys().first()
    let max-count = counts.at(max-key)
    for key in counts.keys() {
      if counts.at(key) > max-count {
        max-key = key
        max-count = counts.at(key)
      }
    }
    consensus = max-key
    consensus-score = max-count / alignment.at("sequences").len() * 100
  }
  if config.at("weight-table") != "identity" or config.at("custom-weights").keys().len() > 0 or config.at("gap-penalty") != 0 {
    let weighted = _weighted-consensus(counts, residues, seq-type, config)
    consensus = weighted.at("consensus")
    consensus-score = weighted.at("score")
  }
  let group-majority = none
  let group-counts = (:)
  for key in counts.keys() {
    let group = _residue-group(key, seq-type, config)
    if group != none {
      let group-key = str(group)
      group-counts.insert(group-key, group-counts.at(group-key, default: 0) + counts.at(key))
    }
  }
  let max-group-count = 0
  for key in group-counts.keys() {
    if group-counts.at(key) > max-group-count {
      max-group-count = group-counts.at(key)
      group-majority = int(key)
    }
  }
  let reference-index = if config.at("shading").at("reference") != none { _resolve-sequence(alignment, config.at("shading").at("reference")) } else { 0 }
  let reference-char = alignment.at("sequences").at(reference-index).at("aligned").slice(col, col + 1)
  let styled = (kind, char) => {
    let style = config.at("residue-style").at(kind)
    let token = style.at("case", default: "upper")
    let source-char = if char == "*" { config.at("stop-char") } else { char }
    let out-char = if token == "upper" {
      _upper(source-char)
    } else if token == "lower" {
      _lower(source-char)
    } else if token == "" or token == "normal" {
      source-char
    } else {
      token
    }
    (
      kind: kind,
      char: out-char,
      fg: style.at("fg"),
      bg: style.at("bg"),
      emph: style.at("style", default: "normal") == "italic" or style.at("style", default: "normal") == "oblique",
    )
  }
  for (res-index, char) in residues.enumerate() {
    if char == "." or char == "-" {
      styles.push((kind: "gap", char: config.at("gaps").at("char"), fg: config.at("gaps").at("fg"), bg: config.at("gaps").at("bg"), rule: config.at("gaps").at("char") == "rule"))
    } else if mode == "T-Coffee" {
      let seq-name = alignment.at("sequences").at(res-index).at("name")
      let seq-scores = config.at("tcoffee").at("scores").at(seq-name, default: ())
      let score = if col < seq-scores.len() and seq-scores.at(col) != none { seq-scores.at(col) } else { 0 }
      styles.push((kind: "tcoffee", char: char, fg: "Black", bg: scale-color("TCoffee", score), score: score))
    } else if mode == "functional" {
      let group = _functional-style(config, _upper(char))
      if group == none {
        styles.push(styled("nomatch", char))
      } else {
        let styled-char = styled("nomatch", char).at("char")
        let token = group.at("case", default: "upper")
        let out-char = if token == "upper" {
          _upper(char)
        } else if token == "lower" {
          _lower(char)
        } else if token == "" or token == "normal" {
          char
        } else {
          token
        }
        styles.push((
          kind: "functional",
          char: if group.keys().contains("case") { out-char } else { styled-char },
          fg: group.at("fg"),
          bg: group.at("bg"),
          emph: group.at("style", default: "normal") == "italic" or group.at("style", default: "normal") == "oblique",
        ))
      }
    } else if mode == "diverse" {
      if char == reference-char {
        styles.push((kind: "allmatch", char: ".", fg: "Black", bg: "White"))
      } else if _is-similar(_upper(char), _upper(reference-char), seq-type, config) {
        styles.push((kind: "conserved", char: ".", fg: "Black", bg: "White"))
      } else {
        styles.push((kind: "nomatch", char: _lower(char), fg: "Black", bg: "White"))
      }
    } else if mode == "similar" {
      if consensus != none and consensus-score >= config.at("allmatch-threshold") {
        styles.push(styled("allmatch", char))
      } else if consensus != none and consensus-score >= config.at("threshold") and char == consensus {
        styles.push(styled("conserved", char))
      } else if group-majority != none and max-group-count / alignment.at("sequences").len() * 100 >= config.at("threshold") and _residue-group(_upper(char), seq-type, config) == group-majority {
        styles.push(styled("similar", char))
      } else {
        styles.push(styled("nomatch", char))
      }
    } else if mode == "singleseq" {
      styles.push(styled("nomatch", char))
    } else {
      if consensus != none and consensus-score >= config.at("allmatch-threshold") {
        styles.push(styled("allmatch", char))
      } else if consensus != none and consensus-score >= config.at("threshold") and char == consensus {
        styles.push(styled("conserved", char))
      } else {
        styles.push(styled("nomatch", char))
      }
    }
  }
  (styles: styles, consensus: consensus, consensus-score: consensus-score)
}

#let _base-cell(char, fg: "Black", bg: "White", lower: false, emph: false, frame: none) = (
  char: if lower { _lower(char) } else { char },
  fg: fg,
  bg: bg,
  emph: emph,
  frame: frame,
)


#let _apply-regions(alignment, config, sequence-index, column, cell) = {
  let updated = cell
  for region in config.at("shade-regions") {
    let target = _resolve-sequence(alignment, region.at("sequence"))
    if target == sequence-index or region.at("all") {
      let seq = alignment.at("sequences").at(target)
      if _selection-columns(seq, region.at("selection")).contains(column) {
        let explicit-bg = region.at("bg", default: none)
        let scheme = region.at("scheme", default: config.at("shading").at("scheme"))
        let fill = if explicit-bg != none { explicit-bg } else if scheme == "reds" { "BrickRed" } else if scheme == "greens" { "PineGreen" } else if scheme == "grays" { "DarkGray" } else { "RoyalBlue" }
        updated.insert("bg", fill)
        updated.insert("fg", if region.at("fg", default: none) != none { region.at("fg") } else if fill == "DarkGray" or fill == "PineGreen" or fill == "RoyalBlue" { "White" } else { updated.at("fg") })
      }
    }
  }
  for region in config.at("tint-regions") {
    let target = _resolve-sequence(alignment, region.at("sequence"))
    if target == sequence-index {
      let seq = alignment.at("sequences").at(target)
      if _selection-columns(seq, region.at("selection")).contains(column) {
        let effect = if region.at("intensity", default: "medium") == "medium" { config.at("tint-default") } else { region.at("intensity") }
        updated.insert("bg", _tint-color(effect))
      }
    }
  }
  for region in config.at("lower-regions") {
    let target = _resolve-sequence(alignment, region.at("sequence"))
    if target == sequence-index {
      let seq = alignment.at("sequences").at(target)
      if _selection-columns(seq, region.at("selection")).contains(column) {
        updated.insert("char", _lower(updated.at("char")))
      }
    }
  }
  for region in config.at("emph-regions") {
    let target = _resolve-sequence(alignment, region.at("sequence"))
    if target == sequence-index {
      let seq = alignment.at("sequences").at(target)
      if _selection-columns(seq, region.at("selection")).contains(column) {
        let style = if region.at("style", default: "italic") == "italic" { config.at("emph-default") } else { region.at("style") }
        updated.insert("emph", style != "normal")
      }
    }
  }
  for region in config.at("frame-regions") {
    let target = _resolve-sequence(alignment, region.at("sequence"))
    if target == sequence-index {
      let seq = alignment.at("sequences").at(target)
      if _selection-columns(seq, region.at("selection")).contains(column) {
        updated.insert("frame", region.at("color"))
      }
    }
  }
  updated
}

#let _visible-sequences(alignment, config) = {
  if config.at("hide-seqs") {
    return ()
  }
  let out = ()
  for seq in alignment.at("sequences") {
    let idx = _resolve-sequence(alignment, seq.at("name")) + 1
    let hidden = config.at("hidden").contains(idx) or config.at("hidden").contains(seq.at("name"))
    let killed = config.at("killed").contains(idx) or config.at("killed").contains(seq.at("name"))
    if not hidden and not killed {
      out.push(seq)
    }
  }
  if config.at("shading").at("mode") == "singleseq" {
    let ref = config.at("shading").at("reference", default: 1)
    return (alignment.at("sequences").at(_resolve-sequence(alignment, ref)))
  }
  if config.at("order") == none {
    return out
  }
  let ordered = ()
  for ref in config.at("order") {
    let idx = _resolve-sequence(alignment, ref)
    ordered.push(alignment.at("sequences").at(idx))
  }
  ordered
}

#let _consensus-row(alignment, config, columns, segment) = {
  let cells = ()
  for col in segment {
    let info = _style-for-column(alignment, config, col)
    let score = info.at("consensus-score")
    let level = if info.at("consensus") == none {
      "none"
    } else if score >= config.at("allmatch-threshold") {
      "allmatch"
    } else if score >= config.at("threshold") {
      "conserved"
    } else {
      "none"
    }
    let char = if level == "none" {
      config.at("consensus").at("symbols").at("none")
    } else if level == "allmatch" {
      let token = config.at("consensus").at("symbols").at("allmatch")
      if token == "upper" {
        _upper(info.at("consensus"))
      } else if token == "lower" {
        _lower(info.at("consensus"))
      } else {
        token
      }
    } else if level == "conserved" {
      let token = config.at("consensus").at("symbols").at("conserved")
      if token == "upper" {
        _upper(info.at("consensus"))
      } else if token == "lower" {
        _lower(info.at("consensus"))
      } else {
        token
      }
    } else {
      config.at("consensus").at("symbols").at("none")
    }
    let color-style = config.at("consensus").at("colors").at(level)
    let bg = if config.at("consensus").at("scale") == none {
      color-style.at("bg")
    } else {
      let scale-score = if config.at("consensus").at("scale") == "T-Coffee" { _column-tcoffee-score(alignment, config, col) } else { score }
      scale-color(config.at("consensus").at("scale"), scale-score)
    }
    cells.push((char: char, fg: color-style.at("fg"), bg: bg, emph: false, frame: none))
  }
  (label: config.at("consensus").at("name"), left: "", right: "", cells: cells, row-kind: "consensus")
}


#let _row-for-sequence(alignment, config, sequence, sequence-index, segment) = {
  let cells = ()
  let no-shade = _matches-sequence(alignment, config.at("no-shade"), sequence-index)
  for col in segment {
    let style-info = _style-for-column(alignment, config, col).at("styles").at(sequence-index)
    if no-shade {
      let raw-char = sequence.at("aligned").slice(col, col + 1)
      if raw-char == "." or raw-char == "-" {
        style-info = (char: config.at("gaps").at("char"), fg: config.at("gaps").at("fg"), bg: config.at("gaps").at("bg"), emph: false, rule: config.at("gaps").at("char") == "rule")
      } else {
        style-info = (char: if raw-char == "*" { config.at("stop-char") } else { raw-char }, fg: "Black", bg: "White", emph: false)
      }
    }
    let cell = (char: style-info.at("char"), fg: style-info.at("fg"), bg: style-info.at("bg"), emph: style-info.at("emph", default: false), frame: none, rule: style-info.at("rule", default: false))
    cells.push(_apply-regions(alignment, config, sequence-index, col, cell))
  }
  let hide-number = _matches-sequence(alignment, config.at("hidden-numbers"), sequence-index)
  let left-num = if config.at("numbering").at("show") and config.at("numbering").at("left") {
    let pos = none
    for col in segment {
      if sequence.at("positions").at(col) != none {
        pos = sequence.at("positions").at(col)
        break
      }
    }
    if pos == none or hide-number { "" } else { str(pos) }
  } else { "" }
  let right-num = if config.at("numbering").at("show") and config.at("numbering").at("right") {
    let pos = none
    let pos-col = none
    for col in segment.rev() {
      if sequence.at("positions").at(col) != none {
        pos = sequence.at("positions").at(col)
        pos-col = col
        break
      }
    }
    if pos != none and sequence.at("length", default: none) != none {
      let last-col = none
      for (idx, mapped) in sequence.at("positions").enumerate() {
        if mapped != none {
          last-col = idx
        }
      }
      if pos-col == last-col {
        pos = sequence.at("length")
      }
    }
    if pos == none or hide-number { "" } else { str(pos) }
  } else { "" }
  let label = if _matches-sequence(alignment, config.at("hidden-names"), sequence-index) { "" } else { _sequence-label(alignment, config, sequence, sequence-index) }
  (
    label: label,
    label-color: _sequence-color(config, sequence, sequence-index, "sequence-name-colors", config.at("names-color")),
    number-color: _sequence-color(config, sequence, sequence-index, "sequence-number-colors", config.at("numbering-color")),
    left: left-num,
    right: right-num,
    cells: cells,
    row-kind: "sequence",
  )
}

#let _separation-row(config, segment) = (
  label: "",
  left: "",
  right: "",
  cells: _array-fill(segment.len(), _empty-cell()),
  row-kind: "separation",
  height: config.at("separation-space"),
)

#let _row-label-target(row) = {
  let kind = row.at("row-kind")
  if kind == "feature-text" {
    "feature-text-labels"
  } else if kind == "feature" {
    "feature-style-labels"
  } else if kind == "ruler" {
    "ruler-label"
  } else {
    "names"
  }
}

#let _row-cell-target(row) = {
  let kind = row.at("row-kind")
  if kind == "feature-text" {
    "features"
  } else if kind == "feature" {
    "featurestyles"
  } else if kind == "ruler" {
    "ruler"
  } else {
    "residues"
  }
}

#let _name-width(alignment, config) = {
  if not config.at("names").at("show") {
    return 0pt
  }
  let widths = (0pt,)
  for seq in alignment.at("sequences") {
    let idx = _resolve-sequence(alignment, seq.at("name"))
    widths.push(measure(text(.._text-params(config, "names"))[#_text-string(config, "names", _sequence-label(alignment, config, seq, idx))]).width)
  }
  if config.at("consensus").at("show") and config.at("consensus").at("name") != "" {
    widths.push(measure(text(.._text-params(config, "names"))[#_text-string(config, "names", config.at("consensus").at("name"))]).width)
  }
  if config.at("sequence-logo").at("show") {
    widths.push(measure(text(.._text-params(config, "names"))[#_text-string(config, "names", config.at("sequence-logo").at("name"))]).width)
  }
  if config.at("subfamily-logo").at("show") {
    widths.push(measure(text(.._text-params(config, "names"))[#_text-string(config, "names", config.at("subfamily-logo").at("name"))]).width)
    widths.push(measure(text(.._text-params(config, "names"))[#_text-string(config, "names", config.at("subfamily-logo").at("negative-name"))]).width)
  }
  for label in config.at("feature-style-names").values() {
    widths.push(measure(text(.._text-params(config, "feature-style-labels"))[#_text-string(config, "feature-style-labels", label)]).width)
  }
  for label in config.at("feature-text-names").values() {
    widths.push(measure(text(.._text-params(config, "feature-text-labels"))[#_text-string(config, "feature-text-labels", label)]).width)
  }
  for label in config.at("ruler-names").values() {
    widths.push(measure(text(.._text-params(config, "ruler-label"))[#_text-string(config, "ruler-label", label)]).width)
  }
  calc.max(..widths) + 6pt
}

#let _render-table(rows, config, name-width, num-width, cell-width) = {
  let fills = ()
  let strokes = ()
  let items = ()
  let columns = ()
  if config.at("names").at("show") and config.at("names").at("position") == "left" {
    columns.push(name-width)
  }
  if config.at("numbering").at("show") and config.at("numbering").at("left") {
    columns.push(num-width)
  }
  let residue-cols = rows.first().at("cells").len()
  for _ in range(0, residue-cols) {
    columns.push(cell-width)
  }
  if config.at("numbering").at("show") and config.at("numbering").at("right") {
    columns.push(num-width)
  }
  if config.at("names").at("show") and config.at("names").at("position") == "right" {
    columns.push(name-width)
  }
  for row in rows {
    let row-fills = ()
    let row-strokes = ()
    let label-color = row.at("label-color", default: "Black")
    let number-color = row.at("number-color", default: config.at("numbering-color"))
    let label-target = _row-label-target(row)
    let cell-target = _row-cell-target(row)
    let hide-sequence-chars = config.at("hide-residues") and row.at("row-kind") == "sequence"
    if config.at("names").at("show") and config.at("names").at("position") == "left" {
      row-fills.push(none)
      row-strokes.push(none)
      items.push(align(if config.at("align-right-labels") { right } else { left }, text(.._text-params(config, label-target, fill: resolve-color(label-color)))[#_text-string(config, label-target, row.at("label"))]))
    }
    if config.at("numbering").at("show") and config.at("numbering").at("left") {
      row-fills.push(none)
      row-strokes.push(none)
      items.push(align(right, text(.._text-params(config, "numbering", fill: resolve-color(number-color)))[#_text-string(config, "numbering", row.at("left"))]))
    }
    for cell in row.at("cells") {
      row-fills.push(if cell.at("bg") == none { none } else { resolve-color(cell.at("bg")) })
      row-strokes.push(if cell.at("frame") == none { none } else { (paint: resolve-color(cell.at("frame")), thickness: cell.at("frame-thickness", default: 0.5pt)) })
      if cell.at("rule", default: false) {
        items.push(box(width: 100%, height: config.at("font-size"), inset: 0pt)[
          #align(horizon, rect(width: 100%, height: config.at("gaps").at("rule-thickness"), fill: resolve-color(cell.at("fg")), stroke: none))
        ])
      } else if row.at("row-kind") == "separation" {
        items.push(box(width: 100%, height: row.at("height"), inset: 0pt)[])
      } else if cell.keys().contains("rotated") {
        items.push(box(width: 100%, height: config.at("font-size") * 3, inset: 0pt)[
          #align(center + horizon, rotate(-90deg, reflow: false)[
            #text(.._text-params(config, cell-target, fill: resolve-color(cell.at("fg"))))[#_text-string(config, cell-target, cell.at("rotated"))]
          ])
        ])
      } else {
        items.push(text(.._text-params(config, cell-target, fill: resolve-color(cell.at("fg")), style: if cell.at("emph") { "italic" } else { auto }, size: cell.at("size", default: auto)))[#{
          if hide-sequence-chars or (cell.at("char") == "." and not config.at("show-leading-gaps")) { "" } else { _text-string(config, cell-target, cell.at("char")) }
        }])
      }
    }
    if config.at("numbering").at("show") and config.at("numbering").at("right") {
      row-fills.push(none)
      row-strokes.push(none)
      items.push(align(left, text(.._text-params(config, "numbering", fill: resolve-color(number-color)))[#_text-string(config, "numbering", row.at("right"))]))
    }
    if config.at("names").at("show") and config.at("names").at("position") == "right" {
      row-fills.push(none)
      row-strokes.push(none)
      items.push(align(if config.at("align-right-labels") { left } else { right }, text(.._text-params(config, label-target, fill: resolve-color(label-color)))[#_text-string(config, label-target, row.at("label"))]))
    }
    fills.push(row-fills)
    strokes.push(row-strokes)
  }
  table(columns: columns, inset: (x: 2pt, y: 1pt), stroke: (x, y) => strokes.at(y).at(x), fill: (x, y) => fills.at(y).at(x), align: center, column-gutter: 0pt, row-gutter: config.at("line-gap"), ..items)
}

#let _append-feature-blocks(rendered, alignment, config, segment, slots, name-width, num-width, cell-width) = {
  for slot in slots {
    let rows = _feature-rows(alignment, config, segment, slot)
    if rows.len() > 0 {
      rendered.push(_render-table(rows, config, name-width, num-width, cell-width))
      let spacing = config.at("feature-slot-spacing").at(slot)
      if spacing != 0pt {
        rendered.push(v(spacing, weak: false))
      }
    }
  }
}

#let render-alignment(source, format: auto, commands: (), font: none, font-size: none, residues-per-line: none) = {
  context {
    let config = _default-config()
    if font != none {
      config.insert("font", font)
    }
    if font-size != none {
      config.insert("font-size", font-size)
    }
    if residues-per-line != none {
      config.insert("residues-per-line", residues-per-line)
    }
    for command in commands {
      _apply-command(config, command)
    }
    let alignment = read-alignment(source, format: format)
    if config.at("seq-type") != none {
      alignment.insert("seq-type", config.at("seq-type"))
    }
    _apply-single-sequence-options(alignment, config)
    _apply-numbering-overrides(alignment, config)
    let sequences = _visible-sequences(alignment, config)
    let display-columns = _display-columns(alignment, config)
    let cell-width = (measure(text(.._text-params(config, "residues"))[M]).width + 1.5pt) * config.at("char-stretch")
    let name-width = _name-width(alignment, config)
    let num-sample = "9" * config.at("numbering-width-digits")
    let num-width = measure(text(.._text-params(config, "numbering"))[#num-sample]).width + 4pt
    let blocks = ()
    let step = config.at("residues-per-line")
    let start = 0
    while start < display-columns.len() {
      let stop = calc.min(start + step, display-columns.len())
      blocks.push(display-columns.slice(start, stop))
      start = stop
    }
    set align(if config.at("alignment") == "left" { left } else if config.at("alignment") == "right" { right } else { center })
    let rendered = ()
    if config.at("captions").at("top") != none {
      rendered.push(text(.._text-params(config, "legend"))[#config.at("captions").at("top")])
    }
    let legend = _legend-block(config)
    if legend != none {
      rendered.push(legend)
    }
    for segment in blocks {
      _append-feature-blocks(rendered, alignment, config, segment, _top-feature-slots, name-width, num-width, cell-width)
      let rows = ()
      if config.at("ruler").at("show") and config.at("ruler").at("position") == "top" {
        for row in _ruler-rows(alignment, config, segment, "top") {
          rows.push(row)
        }
        if config.at("ruler-spacing").at("top") != 0pt {
          rendered.push(_render-table(rows, config, name-width, num-width, cell-width))
          rendered.push(v(config.at("ruler-spacing").at("top"), weak: false))
          rows = ()
        }
      }
      if config.at("sequence-logo").at("show") and config.at("sequence-logo").at("position") == "top" {
        rendered.push(_logo-block(alignment, config, segment, name-width, num-width, cell-width))
      }
      if config.at("subfamily-logo").at("show") and config.at("subfamily-logo").at("position") == "top" and config.at("subfamily").len() > 0 {
        rendered.push(_logo-block(alignment, config, segment, name-width, num-width, cell-width, subfamily: true))
      }
      if config.at("consensus").at("show") and config.at("consensus").at("position") == "top" {
        rows.push(_consensus-row(alignment, config, display-columns, segment))
      }
      for seq in sequences {
        let seq-index = _resolve-sequence(alignment, seq.at("name"))
        rows.push(_row-for-sequence(alignment, config, seq, seq-index, segment))
        if _matches-sequence(alignment, config.at("separation-lines"), seq-index) {
          rows.push(_separation-row(config, segment))
        }
      }
      if config.at("consensus").at("show") and config.at("consensus").at("position") == "bottom" {
        rows.push(_consensus-row(alignment, config, display-columns, segment))
      }
      if config.at("sequence-logo").at("show") and config.at("sequence-logo").at("position") == "bottom" {
        rows.push((label: "", left: "", right: "", cells: _array-fill(segment.len(), _empty-cell()), row-kind: "spacer"))
        rendered.push(_render-table(rows, config, name-width, num-width, cell-width))
        rendered.push(_logo-block(alignment, config, segment, name-width, num-width, cell-width))
        rows = ()
      }
      if config.at("subfamily-logo").at("show") and config.at("subfamily-logo").at("position") == "bottom" and config.at("subfamily").len() > 0 {
        if rows.len() > 0 {
          rendered.push(_render-table(rows, config, name-width, num-width, cell-width))
          rows = ()
        }
        rendered.push(_logo-block(alignment, config, segment, name-width, num-width, cell-width, subfamily: true))
      }
      if config.at("ruler").at("show") and config.at("ruler").at("position") == "bottom" {
        if rows.len() > 0 and config.at("ruler-spacing").at("bottom") != 0pt {
          rendered.push(_render-table(rows, config, name-width, num-width, cell-width))
          rendered.push(v(config.at("ruler-spacing").at("bottom"), weak: false))
          rows = ()
        }
        for row in _ruler-rows(alignment, config, segment, "bottom") {
          rows.push(row)
        }
      }
      if rows.len() > 0 {
        rendered.push(_render-table(rows, config, name-width, num-width, cell-width))
      }
      _append-feature-blocks(rendered, alignment, config, segment, _bottom-feature-slots, name-width, num-width, cell-width)
    }
    if config.at("captions").at("bottom") != none {
      rendered.push(text(.._text-params(config, "legend"))[#config.at("captions").at("bottom")])
    }
    stack(spacing: config.at("block-gap"), ..rendered)
  }
}
