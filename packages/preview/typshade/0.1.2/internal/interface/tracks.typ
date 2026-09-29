// Copyright (C) 2026 Eito Yoneyama
// SPDX-License-Identifier: GPL-2.0

#import "../engine/config.typ" as _config

#let consensus-track(position: "bottom", scale: none, name: none) = _config.consensus-track(position: position, scale: scale, name: name)
#let no-consensus() = _config.no-consensus-track()

#let ruler-track(position: "top", sequence: 1, steps: none, color: none, name: none, name-color: none, space: none) = {
  let out = (_config.ruler-track(position: position, sequence: sequence, steps: steps, color: color),)
  if name != none {
    out.push(_config.ruler-name(name, position: position))
  }
  if color != none {
    out.push(_config.ruler-color(color, position: position))
  }
  if name-color != none {
    out.push(_config.ruler-name-color(name-color, position: position))
  }
  if space != none {
    out.push(_config.ruler-space(space, position: position))
  }
  out
}

#let ruler-marker(number, text, position: "top", color: none) = _config.ruler-marker(number, text, position: position, color: color)
#let no-ruler(position: none) = _config.no-ruler-track(position: position)

#let sequence-logo(position: "top", colors: none, name: none, scale: "leftright", relevance-marker: none, stretch: none) = {
  let out = (_config.sequence-logo-track(position: position, colorset: colors),)
  if name != none {
    out.push(_config.sequence-logo-name(name))
  }
  if scale == false {
    out.push(_config.no-logo-scale())
  } else if scale != none {
    out.push(_config.logo-scale(position: scale))
  }
  if relevance-marker != none {
    out.push(_config.relevance-marker(char: relevance-marker.at("char", default: "*"), color: relevance-marker.at("color", default: "Black")))
    if relevance-marker.at("threshold", default: none) != none {
      out.push(_config.relevance-threshold(relevance-marker.at("threshold")))
    }
  }
  if stretch != none {
    out.push(_config.logo-stretch(stretch))
  }
  out
}

#let no-sequence-logo() = _config.no-sequence-logo-track()

#let subfamily-logo(sequences, position: "bottom", colors: none, name: none, negative-name: none) = {
  let out = (_config.subfamily(sequences), _config.subfamily-logo-track(position: position, colorset: colors))
  if name != none or negative-name != none {
    out.push(_config.subfamily-logo-name(if name == none { "subfamily" } else { name }, negative-name: negative-name))
  }
  out
}

#let no-subfamily-logo() = _config.no-subfamily-logo-track()

#let legend-track(color: "Black") = _config.legend-track(color: color)

#let structure-tracks(sequence, hmmtop: none, topology: none, secondary: none, hmmtop-sequence: none) = {
  let out = ()
  if hmmtop != none {
    out.push(_config.hmmtop-track(sequence, hmmtop, source-sequence: hmmtop-sequence))
  }
  if topology != none {
    out.push(_config.phd-topology-track(sequence, topology))
  }
  if secondary != none {
    out.push(_config.phd-secondary-track(sequence, secondary))
  }
  out
}
