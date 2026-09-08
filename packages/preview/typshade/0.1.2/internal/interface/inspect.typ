// Copyright (C) 2026 Eito Yoneyama
// SPDX-License-Identifier: GPL-2.0

#import "../engine/layout.typ" as _layout
#import "../model/logo.typ" as _logo
#import "../model/parser.typ" as _parser

#let alignment-summary(source, format: auto) = {
  let alignment = _parser.read-alignment(source, format: format)
  let names = alignment.at("sequences").map(seq => seq.at("name")).join(", ")
  table(
    columns: (auto, 1fr),
    inset: (x: 6pt, y: 3pt),
    stroke: (x, y) => if y == 0 { (bottom: 0.6pt) } else { none },
    [Format], [#alignment.at("format")],
    [Type], [#alignment.at("seq-type")],
    [Sequences], [#str(alignment.at("sequences").len())],
    [Columns], [#str(alignment.at("columns"))],
    [Names], [#names],
  )
}

#let selection-preview(source, sequence, selection, format: auto) = {
  let alignment = _parser.read-alignment(source, format: format)
  let resolved-sequence = alignment.at("sequences").at(_logo._resolve-sequence(alignment, sequence))
  let positions = ()
  for col in _layout._selection-columns(resolved-sequence, selection) {
    let pos = resolved-sequence.at("positions").at(col)
    if pos != none {
      positions.push(str(pos))
    }
  }
  if positions.len() == 0 { "" } else { positions.join(",") }
}

#let sequence-list(source, format: auto) = {
  let alignment = _parser.read-alignment(source, format: format)
  let rows = ([Name], [Length], [Non-gap residues])
  for sequence in alignment.at("sequences") {
    let count = sequence.at("positions").filter(pos => pos != none).len()
    rows.push([#sequence.at("name")])
    rows.push([#str(sequence.at("aligned").len())])
    rows.push([#str(count)])
  }
  table(columns: (1fr, auto, auto), inset: (x: 5pt, y: 3pt), ..rows)
}

#let selection-table(source, ..items, format: auto, sequence: 1) = {
  let rows = ([Name], [Selection], [Positions], [Count])
  for item in items.pos() {
    let name = if type(item) == dictionary { item.at("name", default: str(item.at("selection"))) } else { str(item) }
    let selection = if type(item) == dictionary { item.at("selection") } else { item }
    let item-sequence = if type(item) == dictionary { item.at("sequence", default: sequence) } else { sequence }
    let positions = selection-preview(source, item-sequence, selection, format: format)
    let count = if positions == "" { 0 } else { positions.split(",").len() }
    rows.push([#name])
    rows.push([#str(selection)])
    rows.push([#positions])
    rows.push([#str(count)])
  }
  table(columns: (auto, auto, 1fr, auto), inset: (x: 5pt, y: 3pt), ..rows)
}
