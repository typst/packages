// Copyright (C) 2026 Eito Yoneyama
// SPDX-License-Identifier: GPL-2.0

#import "../engine/config.typ" as _config

#let pdb-point(source, residue, distance: 1, atom: "side") = (
  kind: "pdb-selection",
  shape: "point",
  source: source,
  distance: distance,
  anchors: ((residue: residue, atom: atom),),
)

#let pdb-line(source, residue-a, residue-b, distance: 1, atom-a: "side", atom-b: "side") = (
  kind: "pdb-selection",
  shape: "line",
  source: source,
  distance: distance,
  anchors: ((residue: residue-a, atom: atom-a), (residue: residue-b, atom: atom-b)),
)

#let pdb-plane(source, residue-a, residue-b, residue-c, distance: 1, atom-a: "side", atom-b: "side", atom-c: "side") = (
  kind: "pdb-selection",
  shape: "plane",
  source: source,
  distance: distance,
  anchors: ((residue: residue-a, atom: atom-a), (residue: residue-b, atom: atom-b), (residue: residue-c, atom: atom-c)),
)

#let highlight(sequence, selection, fg: "White", bg: "RoyalBlue", all: false) = _config.region-highlight(sequence, selection, fg, bg, apply-to-all: all)
#let tint(sequence, selection, intensity: "medium") = _config.region-tint(sequence, selection, intensity: intensity)
#let emphasize(sequence, selection, style: "italic") = _config.region-emphasis(sequence, selection, style: style)

#let mark(position, sequence, selection, fill: "Yellow", text: "", style: none) = {
  let resolved-style = if style == none { "box[" + str(fill) + "]" } else { style }
  _config.feature(position, sequence, selection, style: resolved-style, text: text)
}

#let motif(sequence, selection, text: "motif", position: "top", fg: "White", bg: "RoyalBlue", fill: "Yellow", all: false) = (
  highlight(sequence, selection, fg: fg, bg: bg, all: all),
  mark(position, sequence, selection, fill: fill, text: text),
)

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
