// Copyright (C) 2026 Eito Yoneyama
// SPDX-License-Identifier: GPL-2.0

#import "../engine/layout.typ" as _layout
#import "../engine/commands.typ" as _commands
#import "../engine/config.typ" as _config
#import "../model/logo.typ" as _logo
#import "../model/parser.typ" as _parser
#import "../render/alignment.typ" as _render

#let _prepared-alignment(source, format, commands) = {
  let config = _config._default-config()
  let flat = ()
  flat = _commands._add-command(flat, commands)
  for command in flat {
    config = _config._apply-command(config, command)
  }
  let alignment = _parser.read-alignment(source, format: format)
  if config.at("seq-type") != none {
    alignment.insert("seq-type", config.at("seq-type"))
  }
  let _ = _render._validate-config-sequence-refs(alignment, config)
  _render._apply-single-sequence-options(alignment, config)
  _render._apply-numbering-overrides(alignment, config)
  (alignment: alignment, config: config)
}

#let _debug-value(value) = if value == auto { "auto" } else { str(value) }

#let _selection-label(selection) = if type(selection) == dictionary and selection.at("kind", default: none) == "typshade-selection" {
  selection.at("op", default: "select")
} else {
  str(selection)
}

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
  for col in _layout._selection-columns(resolved-sequence, selection, alignment: alignment) {
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
    let selection = if type(item) == dictionary { item.at("selection") } else { item }
    let name = if type(item) == dictionary and item.keys().contains("name") { item.at("name") } else { _selection-label(selection) }
    let item-sequence = if type(item) == dictionary { item.at("sequence", default: sequence) } else { sequence }
    let positions = selection-preview(source, item-sequence, selection, format: format)
    let count = if positions == "" { 0 } else { positions.split(",").len() }
    rows.push([#name])
    rows.push([#_selection-label(selection)])
    rows.push([#positions])
    rows.push([#str(count)])
  }
  table(columns: (auto, auto, 1fr, auto), inset: (x: 5pt, y: 3pt), ..rows)
}

#let alignment-debug(source, format: auto, commands: ()) = {
  let prepared = _prepared-alignment(source, format, commands)
  let alignment = prepared.at("alignment")
  let config = prepared.at("config")
  let visible = _render._visible-sequences(alignment, config).map(seq => seq.at("name")).join(", ")
  let display-columns = _render._display-columns(alignment, config)
  table(
    columns: (auto, 1fr),
    inset: (x: 6pt, y: 3pt),
    stroke: (x, y) => if y == 0 { (bottom: 0.6pt) } else { none },
    [Field], [Value],
    [Format], [#alignment.at("format")],
    [Type], [#alignment.at("seq-type")],
    [Sequences], [#str(alignment.at("sequences").len())],
    [Visible sequences], [#visible],
    [Columns], [#str(alignment.at("columns"))],
    [Displayed columns], [#str(display-columns.len())],
    [Residues per line], [#_debug-value(config.at("residues-per-line"))],
    [Scoring mode], [#str(config.at("shading").at("mode"))],
    [Consensus source], [#str(config.at("consensus").at("source", default: "all"))],
  )
}

#let cell-inspect(source, sequence, column, format: auto, commands: ()) = {
  let prepared = _prepared-alignment(source, format, commands)
  let alignment = prepared.at("alignment")
  let config = prepared.at("config")
  let seq-index = _logo._resolve-sequence(alignment, sequence)
  let sequence-data = alignment.at("sequences").at(seq-index)
  let col = int(column) - 1
  assert(col >= 0 and col < alignment.at("columns"), message: "typshade: column `" + str(column) + "` is out of range")
  let info = _render._style-for-column(alignment, config, col)
  let style-info = info.at("styles").at(seq-index)
  let cell = (
    char: style-info.at("char"),
    fg: style-info.at("fg"),
    bg: style-info.at("bg"),
    emph: style-info.at("emph", default: false),
    frame: none,
    rule: style-info.at("rule", default: false),
  )
  cell = _render._apply-cell-styles(alignment, config, sequence-data, seq-index, col, info, style-info, cell)
  cell = _render._apply-regions(alignment, config, seq-index, col, cell)
  table(
    columns: (auto, 1fr),
    inset: (x: 6pt, y: 3pt),
    stroke: (x, y) => if y == 0 { (bottom: 0.6pt) } else { none },
    [Field], [Value],
    [Sequence], [#sequence-data.at("name")],
    [Column], [#str(column)],
    [Position], [#str(sequence-data.at("positions").at(col))],
    [Residue], [#sequence-data.at("aligned").slice(col, col + 1)],
    [Kind], [#style-info.at("kind", default: "custom")],
    [Rendered char], [#cell.at("char")],
    [Foreground], [#str(cell.at("fg"))],
    [Background], [#str(cell.at("bg"))],
    [Consensus], [#str(info.at("consensus"))],
    [Consensus score], [#str(calc.round(info.at("consensus-score") * 10) / 10)],
  )
}
