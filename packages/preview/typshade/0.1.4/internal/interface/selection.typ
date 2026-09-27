// Copyright (C) 2026 Eito Yoneyama
// SPDX-License-Identifier: GPL-2.0

/// Composable Selection DSL constructors.

#let _selection(op, fields) = {
  let out = fields
  out.insert("kind", "typshade-selection")
  out.insert("op", op)
  out
}

/// Combine selections with boolean logic and optional padding.
///
/// - items (arguments): Child selections combined by the selected boolean mode.
/// - mode (str): Combination or scoring mode.
/// - padding (int): Number of neighboring residues added around matches.
/// -> dictionary
#let select(..items, mode: "or", padding: 0) = _selection(mode, (
  items: items.pos(),
  padding: padding,
))

/// Select columns matched by any child selection.
///
/// - items (arguments): Child selections whose matched columns are combined.
/// - padding (int): Number of neighboring residues added around matches.
/// -> dictionary
#let select-or(..items, padding: 0) = select(..items.pos(), mode: "or", padding: padding)

/// Select columns matched by every child selection.
///
/// - items (arguments): Child selections whose shared matched columns are retained.
/// - padding (int): Number of neighboring residues added around matches.
/// -> dictionary
#let select-and(..items, padding: 0) = select(..items.pos(), mode: "and", padding: padding)

/// Invert a selection.
///
/// - selection (str, dictionary): Residue range or Selection DSL expression to resolve.
/// -> dictionary
#let select-not(selection) = _selection("not", (selection: selection))

/// Expand a selection by neighboring residues.
///
/// - selection (str, dictionary): Residue range or Selection DSL expression to resolve.
/// - before (int): Number of residues to include before each match.
/// - after (int, none): Number of residues to include after each match.
/// -> dictionary
#let select-pad(selection, before, after: none) = _selection("pad", (
  selection: selection,
  before: before,
  after: if after == none { before } else { after },
))

/// Select every alignment column.
/// -> dictionary
#let select-all() = _selection("all", (:))

/// Select an inclusive residue range.
///
/// - start (int, str, none): Inclusive start position, or a string range such as `"10..25"`.
/// - args (arguments): Optional end position, supplied positionally or as `stop`.
/// -> dictionary
#let select-range(start, ..args) = {
  let positional = args.pos()
  let stop = if positional.len() > 0 { positional.first() } else { args.named().at("stop", default: none) }
  if stop == none and type(start) == str {
    _selection("range", (range: start))
  } else {
    _selection("range", (start: start, stop: if stop == none { start } else { stop }))
  }
}

/// Select explicit residue positions.
///
/// - positions (arguments): Explicit one-based residue positions.
/// -> dictionary
#let select-residues(..positions) = _selection("positions", (positions: positions.pos()))

/// Select residues matching a motif pattern.
///
/// - pattern (str): Motif pattern to match.
/// -> dictionary
#let select-motif(pattern) = _selection("motif", (pattern: pattern))

/// Select columns by an alignment metric threshold.
///
/// - metric (str): Alignment metric used for selection or graph values.
/// - above (int, float, none): Exclusive lower metric bound.
/// - below (int, float, none): Exclusive upper metric bound.
/// - at-least (int, float, none): Inclusive lower metric bound.
/// - at-most (int, float, none): Inclusive upper metric bound.
/// - min (int, float, none): Minimum permitted value.
/// - max (int, float, none): Maximum permitted value, or `none` for no explicit maximum.
/// - equals (int, float, none): Exact metric value to select.
/// - selection (str, dictionary): Residue range or Selection DSL expression to resolve.
/// -> dictionary
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
