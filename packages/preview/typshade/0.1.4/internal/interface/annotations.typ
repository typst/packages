// Copyright (C) 2026 Eito Yoneyama
// SPDX-License-Identifier: GPL-2.0

/// Selection annotations, motif marks, metric graphs, and PDB geometry helpers.

#import "../engine/config.typ" as _config

/// Select residues near a point defined by one PDB residue.
///
/// - source (any): Input data, text, bytes, or a path accepted by the selected parser.
/// - residue (int, str): Residue symbol or one-based residue number, as appropriate.
/// - distance (int, float): Maximum distance in angstroms from the geometric primitive.
/// - atom (str): Atom selector used to locate a residue point.
/// -> any
#let pdb-point(source, residue, distance: 1, atom: "side") = (
  kind: "pdb-selection",
  shape: "point",
  source: source,
  distance: distance,
  anchors: ((residue: residue, atom: atom),),
)

/// Select residues near a line defined by two PDB residues.
///
/// - source (any): Input data, text, bytes, or a path accepted by the selected parser.
/// - residue-a (int, str): First residue symbol or number.
/// - residue-b (int, str): Second residue symbol or number.
/// - distance (int, float): Maximum distance in angstroms from the geometric primitive.
/// - atom-a (str): Atom selector for the first residue.
/// - atom-b (str): Atom selector for the second residue.
/// -> any
#let pdb-line(source, residue-a, residue-b, distance: 1, atom-a: "side", atom-b: "side") = (
  kind: "pdb-selection",
  shape: "line",
  source: source,
  distance: distance,
  anchors: ((residue: residue-a, atom: atom-a), (residue: residue-b, atom: atom-b)),
)

/// Select residues near a plane defined by three PDB residues.
///
/// - source (any): Input data, text, bytes, or a path accepted by the selected parser.
/// - residue-a (int, str): First residue symbol or number.
/// - residue-b (int, str): Second residue symbol or number.
/// - residue-c (int): Third residue number.
/// - distance (int, float): Maximum distance in angstroms from the geometric primitive.
/// - atom-a (str): Atom selector for the first residue.
/// - atom-b (str): Atom selector for the second residue.
/// - atom-c (str): Atom selector for the third residue.
/// -> any
#let pdb-plane(source, residue-a, residue-b, residue-c, distance: 1, atom-a: "side", atom-b: "side", atom-c: "side") = (
  kind: "pdb-selection",
  shape: "plane",
  source: source,
  distance: distance,
  anchors: ((residue: residue-a, atom: atom-a), (residue: residue-b, atom: atom-b), (residue: residue-c, atom: atom-c)),
)

/// Highlight a sequence selection with foreground and background colors.
///
/// - sequence (int, str): Sequence name, one-based index, or supported sequence selector.
/// - selection (str, dictionary): Residue range or Selection DSL expression to resolve.
/// - fg (color, str, none): Foreground color.
/// - bg (color, str, none): Background color.
/// - all (bool): Whether the operation applies across all sequences.
/// -> any
#let highlight(sequence, selection, fg: "White", bg: "RoyalBlue", all: false) = _config.region-highlight(sequence, selection, fg, bg, apply-to-all: all)
/// Tint a sequence selection while preserving residue shading.
///
/// - sequence (int, str): Sequence name, one-based index, or supported sequence selector.
/// - selection (str, dictionary): Residue range or Selection DSL expression to resolve.
/// - intensity (str, int, float): Tint strength.
/// -> any
#let tint(sequence, selection, intensity: "medium") = _config.region-tint(sequence, selection, intensity: intensity)
/// Apply typographic emphasis to a sequence selection.
///
/// - sequence (int, str): Sequence name, one-based index, or supported sequence selector.
/// - selection (str, dictionary): Residue range or Selection DSL expression to resolve.
/// - style (str, dictionary, none): Visual or typographic style.
/// -> any
#let emphasize(sequence, selection, style: "italic") = _config.region-emphasis(sequence, selection, style: style)

/// Add a labeled mark above or below a sequence selection.
///
/// - position (str, none): Track side or alignment position to target.
/// - sequence (int, str): Sequence name, one-based index, or supported sequence selector.
/// - selection (str, dictionary): Residue range or Selection DSL expression to resolve.
/// - fill (color, str, none): Fill color.
/// - text (str, content): Text displayed by the generated annotation or label.
/// - style (str, dictionary, none): Visual or typographic style.
/// -> any
#let mark(position, sequence, selection, fill: "Yellow", text: "", style: none) = {
  let resolved-style = if style == none { "box[" + str(fill) + "]" } else { style }
  _config.feature(position, sequence, selection, style: resolved-style, text: text)
}

/// Highlight and label a motif selection.
///
/// - sequence (int, str): Sequence name, one-based index, or supported sequence selector.
/// - selection (str, dictionary): Residue range or Selection DSL expression to resolve.
/// - text (str, content): Text displayed by the generated annotation or label.
/// - position (str, none): Track side or alignment position to target.
/// - fg (color, str, none): Foreground color.
/// - bg (color, str, none): Background color.
/// - fill (color, str, none): Fill color.
/// - all (bool): Whether the operation applies across all sequences.
/// -> any
#let motif(sequence, selection, text: "motif", position: "top", fg: "White", bg: "RoyalBlue", fill: "Yellow", all: false) = (
  highlight(sequence, selection, fg: fg, bg: bg, all: all),
  mark(position, sequence, selection, fill: fill, text: text),
)

/// Add a metric graph or color scale for a sequence selection.
///
/// - position (str, none): Track side or alignment position to target.
/// - sequence (int, str): Sequence name, one-based index, or supported sequence selector.
/// - selection (str, dictionary): Residue range or Selection DSL expression to resolve.
/// - metric (str): Alignment metric used for selection or graph values.
/// - kind (str): Rendering or measurement variant.
/// - range (array, str, none): Explicit value range, or `none` to infer it.
/// - options (array, dictionary, none): Optional settings for the generated object.
/// - text (str, content): Text displayed by the generated annotation or label.
/// -> any
#let graph(position, sequence, selection, metric, kind: "bar", range: none, options: none, text: "") = {
  let style = (
    kind: str(kind),
    metric: metric,
    min: if range == none { none } else { range.at(0) },
    max: if range == none { none } else { range.at(1) },
    options: if options == none { () } else { options },
  )
  _config.feature(position, sequence, selection, style: style, text: text)
}
