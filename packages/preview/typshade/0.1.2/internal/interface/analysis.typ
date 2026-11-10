// Copyright (C) 2026 Eito Yoneyama
// SPDX-License-Identifier: GPL-2.0

#import "../engine/layout.typ" as _layout
#import "../model/logo.typ" as _logo
#import "../model/palette.typ" as _palette
#import "../model/parser.typ" as _parser

#let _upper(text) = {
  let lower = "abcdefghijklmnopqrstuvwxyz"
  let upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  let out = ""
  for ch in str(text).clusters() {
    let idx = lower.position(ch)
    out += if idx == none { ch } else { upper.slice(idx, idx + 1) }
  }
  out
}

#let _is-gap(value) = {
  let ch = str(value)
  ch == "" or ch == "." or ch == "-"
}

#let _sequence-index(alignment, sequence) = _logo._resolve-sequence(alignment, sequence)

#let _selected-columns(alignment, reference, selection) = {
  if selection == none or selection == "all" {
    return range(0, alignment.at("columns"))
  }
  let ref-index = _sequence-index(alignment, reference)
  _layout._selection-columns(alignment.at("sequences").at(ref-index), selection)
}

#let _similar-residue(a, b, seq-type, similarities: none, groups: none) = {
  let left = _upper(a)
  let right = _upper(b)
  if left == right {
    return true
  }
  let resolved-sims = if similarities != none {
    similarities
  } else if seq-type == "N" {
    _palette._dna-sims
  } else {
    _palette._pep-sims
  }
  let left-sims = resolved-sims.at(left, default: "")
  let right-sims = resolved-sims.at(right, default: "")
  if str(left-sims).contains(right) or str(right-sims).contains(left) {
    return true
  }
  let resolved-groups = if groups != none {
    groups
  } else if seq-type == "N" {
    _palette._dna-groups
  } else {
    _palette._pep-groups
  }
  for group in resolved-groups {
    let text = _upper(group)
    if text.contains(left) and text.contains(right) {
      return true
    }
  }
  false
}

#let _percent-score(
  alignment,
  sequence-a,
  sequence-b,
  kind,
  selection: "all",
  reference: auto,
  seq-type: auto,
  similarities: none,
  groups: none,
) = {
  let left-index = _sequence-index(alignment, sequence-a)
  let right-index = _sequence-index(alignment, sequence-b)
  let left = alignment.at("sequences").at(left-index)
  let right = alignment.at("sequences").at(right-index)
  let resolved-reference = if reference == auto { sequence-a } else { reference }
  let resolved-type = if seq-type == auto { alignment.at("seq-type") } else { _upper(seq-type) }
  let total = 0
  let hits = 0
  for col in _selected-columns(alignment, resolved-reference, selection) {
    let a = left.at("aligned").slice(col, col + 1)
    let b = right.at("aligned").slice(col, col + 1)
    if not _is-gap(a) and not _is-gap(b) {
      total += 1
      if _upper(a) == _upper(b) {
        hits += 1
      } else if kind == "similarity" and _similar-residue(a, b, resolved-type, similarities: similarities, groups: groups) {
        hits += 1
      }
    }
  }
  if total == 0 {
    0.0
  } else {
    calc.round(hits / total * 1000) / 10
  }
}

#let percent-identity(
  source,
  sequence-a,
  sequence-b,
  format: auto,
  selection: "all",
  reference: auto,
  seq-type: auto,
) = {
  let alignment = _parser.read-alignment(source, format: format)
  _percent-score(alignment, sequence-a, sequence-b, "identity", selection: selection, reference: reference, seq-type: seq-type)
}

#let percent-similarity(
  source,
  sequence-a,
  sequence-b,
  format: auto,
  selection: "all",
  reference: auto,
  seq-type: auto,
  similarities: none,
  groups: none,
) = {
  let alignment = _parser.read-alignment(source, format: format)
  _percent-score(
    alignment,
    sequence-a,
    sequence-b,
    "similarity",
    selection: selection,
    reference: reference,
    seq-type: seq-type,
    similarities: similarities,
    groups: groups,
  )
}

#let similarity-table(
  source,
  format: auto,
  selection: "all",
  reference: auto,
  seq-type: auto,
  similarities: none,
  groups: none,
) = {
  let alignment = _parser.read-alignment(source, format: format)
  let sequences = alignment.at("sequences")
  let columns = (auto,)
  let rows = ([],)
  for seq in sequences {
    columns.push(auto)
    rows.push([#seq.at("name")])
  }
  for (row-index, row-seq) in sequences.enumerate() {
    rows.push([#row-seq.at("name")])
    for (col-index, col-seq) in sequences.enumerate() {
      if row-index == col-index {
        rows.push([-])
      } else {
        let kind = if col-index > row-index { "similarity" } else { "identity" }
        let value = _percent-score(
          alignment,
          row-index + 1,
          col-index + 1,
          kind,
          selection: selection,
          reference: if reference == auto { row-index + 1 } else { reference },
          seq-type: seq-type,
          similarities: similarities,
          groups: groups,
        )
        rows.push([#str(value)])
      }
    }
  }
  table(columns: columns, inset: (x: 5pt, y: 3pt), ..rows)
}
