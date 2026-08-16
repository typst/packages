// Copyright (C) 2026 Eito Yoneyama
// SPDX-License-Identifier: GPL-2.0

#import "../engine/config.typ" as _config
#import "annotations.typ": highlight, tint, emphasize, mark, motif, graph
#import "tracks.typ": consensus-track, ruler-track, sequence-logo, legend-track, structure-tracks

#let _scoring(
  mode,
  colors: none,
  threshold: none,
  option: none,
  all-match-threshold: none,
  weight-table: none,
  gap-penalty: none,
) = {
  let out = (_config.scoring-mode(mode, option: option),)
  if colors != none {
    out.push(_config.color-scheme(colors))
  }
  if threshold != none {
    out.push(_config.threshold(threshold))
  }
  if all-match-threshold != none {
    out.push(_config.all-match-threshold(value: all-match-threshold))
  }
  if weight-table != none {
    out.push(_config.weight-table(weight-table))
  }
  if gap-penalty != none {
    out.push(_config.gap-penalty(gap-penalty))
  }
  out
}

#let identical(colors: none, threshold: none, option: none, ..rest) = _scoring(
  "identical",
  colors: colors,
  threshold: threshold,
  option: option,
  ..rest,
)

#let similar(colors: none, threshold: none, option: none, ..rest) = _scoring(
  "similar",
  colors: colors,
  threshold: threshold,
  option: option,
  ..rest,
)

#let diverse(colors: none, threshold: none, option: none, ..rest) = _scoring(
  "diverse",
  colors: colors,
  threshold: threshold,
  option: option,
  ..rest,
)

#let functional(kind, colors: none, threshold: none, ..rest) = _scoring(
  "functional",
  colors: colors,
  threshold: threshold,
  option: kind,
  ..rest,
)

#let single-sequence(colors: none, threshold: none, sequence: none, ..rest) = _scoring(
  "singleseq",
  colors: colors,
  threshold: threshold,
  option: sequence,
  ..rest,
)

#let tcoffee(source) = _config.scoring-mode("T-Coffee", option: source)

#let lines(count) = _config.residues-per-line(count)

#let window(sequence, selection, start: none) = _config.sequence-window(sequence, selection, start: start)

#let names(position: "left", color: none) = _config.names-track(position: position, color: color)

#let no-names() = _config.no-names-track()

#let numbers(position: "right", color: none) = _config.numbering-track(position: position, color: color)

#let no-numbers() = _config.no-numbering-track()

#let consensus(position, scale: none, name: none) = consensus-track(position: position, scale: scale, name: name)

#let no-consensus() = _config.no-consensus-track()

#let ruler(position, sequence: 1, every: none, steps: none, color: none, name: none, name-color: none, space: none) = {
  ruler-track(
    position: position,
    sequence: sequence,
    steps: if steps == none { every } else { steps },
    color: color,
    name: name,
    name-color: name-color,
    space: space,
  )
}

#let no-ruler(position: none) = _config.no-ruler-track(position: position)

#let logo(position, colors: none, name: none, scale: "leftright", relevance-marker: none, stretch: none) = {
  sequence-logo(
    position: position,
    colors: colors,
    name: name,
    scale: scale,
    relevance-marker: relevance-marker,
    stretch: stretch,
  )
}

#let no-logo() = _config.no-sequence-logo-track()

#let legend(color: "Black") = legend-track(color: color)

#let no-legend() = _config.no-legend-track()

#let structures(sequence, hmmtop: none, topology: none, secondary: none, hmmtop-sequence: none) = {
  structure-tracks(
    sequence,
    hmmtop: hmmtop,
    topology: topology,
    secondary: secondary,
    hmmtop-sequence: hmmtop-sequence,
  )
}

#let gap-style(foreground: none, background: none, rule: none) = {
  let out = ()
  if foreground != none or background != none {
    out.push(_config.gap-colors(
      if foreground == none { "Black" } else { foreground },
      if background == none { "White" } else { background },
    ))
  }
  if rule != none {
    out.push(_config.gap-rule(rule))
  }
  out
}

#let typography(target: "all", family: none, weight: none, posture: none, size: none) = {
  let out = ()
  if family != none {
    out.push(_config.text-family(target, family))
  }
  if weight != none {
    out.push(_config.text-weight(target, weight))
  }
  if posture != none {
    out.push(_config.text-posture(target, posture))
  }
  if size != none {
    out.push(_config.text-size(target, size))
  }
  out
}
