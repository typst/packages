// Copyright (C) 2026 Eito Yoneyama
// SPDX-License-Identifier: GPL-2.0

/// Pairwise identity and similarity analysis helpers.

#import "../engine/layout.typ" as _layout
#import "../model/logo.typ" as _logo
#import "../model/palette.typ" as _palette
#import "../model/parser.typ" as _parser
#import "html.typ" as _html

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
  _layout._selection-columns(alignment.at("sequences").at(ref-index), selection, alignment: alignment)
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

/// Calculate pairwise sequence identity over a selection.
///
/// - source (any): Input data, text, bytes, or a path accepted by the selected parser.
/// - sequence-a (int, str): First sequence name or one-based index.
/// - sequence-b (int, str): Second sequence name or one-based index.
/// - format (str, auto): Input format, or `auto` to detect it.
/// - selection (str, dictionary): Residue range or Selection DSL expression to resolve.
/// - reference (int, str, auto): Reference sequence used to map residue positions.
/// - seq-type (str, auto): Sequence type, or `auto` to use the parsed alignment type.
/// -> float
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

/// Calculate pairwise sequence similarity over a selection.
///
/// - source (any): Input data, text, bytes, or a path accepted by the selected parser.
/// - sequence-a (int, str): First sequence name or one-based index.
/// - sequence-b (int, str): Second sequence name or one-based index.
/// - format (str, auto): Input format, or `auto` to detect it.
/// - selection (str, dictionary): Residue range or Selection DSL expression to resolve.
/// - reference (int, str, auto): Reference sequence used to map residue positions.
/// - seq-type (str, auto): Sequence type, or `auto` to use the parsed alignment type.
/// - similarities (dictionary, none): Optional residue-similarity mapping.
/// - groups (array, dictionary, none): Optional residue-group definitions.
/// -> float
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

/// Render a pairwise identity and similarity matrix.
///
/// - source (any): Input data, text, bytes, or a path accepted by the selected parser.
/// - format (str, auto): Input format, or `auto` to detect it.
/// - selection (str, dictionary): Residue range or Selection DSL expression to resolve.
/// - reference (int, str, auto): Reference sequence used to map residue positions.
/// - seq-type (str, auto): Sequence type, or `auto` to use the parsed alignment type.
/// - similarities (dictionary, none): Optional residue-similarity mapping.
/// - groups (array, dictionary, none): Optional residue-group definitions.
/// -> content
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
  let headers = ([],)
  let flat = ([],)
  for seq in sequences {
    columns.push(auto)
    headers.push([#seq.at("name")])
    flat.push([#seq.at("name")])
  }
  let rows = ()
  for (row-index, row-seq) in sequences.enumerate() {
    let row = ([#row-seq.at("name")],)
    flat.push([#row-seq.at("name")])
    for (col-index, col-seq) in sequences.enumerate() {
      if row-index == col-index {
        row.push([-])
        flat.push([-])
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
        row.push([#str(value)])
        flat.push([#str(value)])
      }
    }
    rows.push(row)
  }
  _html.target-table(
    table(columns: columns, inset: (x: 5pt, y: 3pt), ..flat),
    headers,
    rows,
  )
}
