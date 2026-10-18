// Copyright (C) 2026 Eito Yoneyama
// SPDX-License-Identifier: GPL-2.0

#let _selection(op, fields) = {
  let out = fields
  out.insert("kind", "typshade-selection")
  out.insert("op", op)
  out
}

#let select(..items, mode: "or", padding: 0) = _selection(mode, (
  items: items.pos(),
  padding: padding,
))

#let select-or(..items, padding: 0) = select(..items.pos(), mode: "or", padding: padding)

#let select-and(..items, padding: 0) = select(..items.pos(), mode: "and", padding: padding)

#let select-not(selection) = _selection("not", (selection: selection))

#let select-pad(selection, before, after: none) = _selection("pad", (
  selection: selection,
  before: before,
  after: if after == none { before } else { after },
))

#let select-all() = _selection("all", (:))

#let select-range(start, ..args) = {
  let positional = args.pos()
  let stop = if positional.len() > 0 { positional.first() } else { args.named().at("stop", default: none) }
  if stop == none and type(start) == str {
    _selection("range", (range: start))
  } else {
    _selection("range", (start: start, stop: if stop == none { start } else { stop }))
  }
}

#let select-residues(..positions) = _selection("positions", (positions: positions.pos()))

#let select-motif(pattern) = _selection("motif", (pattern: pattern))

#let select-metric(
  metric,
  above: none,
  below: none,
  at-least: none,
  at-most: none,
  min: none,
  max: none,
  equals: none,
  selection: "all",
) = _selection("metric", (
  metric: metric,
  above: above,
  below: below,
  at-least: at-least,
  at-most: at-most,
  min: min,
  max: max,
  equals: equals,
  selection: selection,
))
