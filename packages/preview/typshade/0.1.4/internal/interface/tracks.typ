// Copyright (C) 2026 Eito Yoneyama
// SPDX-License-Identifier: GPL-2.0

/// High-level constructors for consensus, ruler, logo, legend, and structure tracks.

#import "../engine/config.typ" as _config

/// Create a consensus track command.
///
/// - position (str, none): Track side or alignment position to target.
/// - scale (str, dictionary, none): Scale placement or scale configuration.
/// - name (str, none): Name used by the generated command or rendered element.
/// -> any
#let consensus-track(position: "bottom", scale: none, name: none) = _config.consensus-track(position: position, scale: scale, name: name)
/// Disable consensus.
/// -> any
#let no-consensus() = _config.no-consensus-track()

/// Create a ruler track command.
///
/// - position (str, none): Track side or alignment position to target.
/// - sequence (int, str): Sequence name, one-based index, or supported sequence selector.
/// - steps (int, none): Interval between ruler labels.
/// - color (color, str, none): Color accepted by Typst or Typshade's named-color resolver.
/// - name (str, none): Name used by the generated command or rendered element.
/// - name-color (color, str, none): Color of the track name.
/// - space (length, none): Additional space reserved for the track.
/// -> any
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

/// Add a labeled marker at a ruler position.
///
/// - number (int): Residue number at which to place the marker.
/// - text (str, content): Text displayed by the generated annotation or label.
/// - position (str, none): Track side or alignment position to target.
/// - color (color, str, none): Color accepted by Typst or Typshade's named-color resolver.
/// -> any
#let ruler-marker(number, text, position: "top", color: none) = _config.ruler-marker(number, text, position: position, color: color)
/// Disable ruler.
///
/// - position (str, none): Track side or alignment position to target.
/// -> any
#let no-ruler(position: none) = _config.no-ruler-track(position: position)

/// Create a configurable sequence-logo track.
///
/// - position (str, none): Track side or alignment position to target.
/// - colors (str, array, dictionary, none, auto): Color scheme or explicit color configuration.
/// - name (str, none): Name used by the generated command or rendered element.
/// - scale (str, dictionary, none): Scale placement or scale configuration.
/// - relevance-marker (str, dictionary, none): Relevance-marker configuration or disablement value.
/// - stretch (int, float, none): Scale factor applied to the rendered element.
/// -> any
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

/// Disable sequence logo.
/// -> any
#let no-sequence-logo() = _config.no-sequence-logo-track()

/// Create a logo contrasting a sequence subfamily with its complement.
///
/// - sequences (int, str, array): Sequence names, indices, or selectors to target.
/// - position (str, none): Track side or alignment position to target.
/// - colors (str, array, dictionary, none, auto): Color scheme or explicit color configuration.
/// - name (str, none): Name used by the generated command or rendered element.
/// - negative-name (str, none): Optional label for the negative subfamily logo.
/// -> any
#let subfamily-logo(sequences, position: "bottom", colors: none, name: none, negative-name: none) = {
  let out = (_config.subfamily(sequences), _config.subfamily-logo-track(position: position, colorset: colors))
  if name != none or negative-name != none {
    out.push(_config.subfamily-logo-name(if name == none { "subfamily" } else { name }, negative-name: negative-name))
  }
  out
}

/// Disable subfamily logo.
/// -> any
#let no-subfamily-logo() = _config.no-subfamily-logo-track()

/// Create a legend track command.
///
/// - color (color, str, none): Color accepted by Typst or Typshade's named-color resolver.
/// -> any
#let legend-track(color: "Black") = _config.legend-track(color: color)

/// Create all requested structural annotation tracks for a sequence.
///
/// - sequence (int, str): Sequence name, one-based index, or supported sequence selector.
/// - hmmtop (any): HMMTOP annotation source.
/// - topology (any): Topology annotation source.
/// - secondary (any): Secondary-structure annotation source.
/// - hmmtop-sequence (str, none): Source sequence identifier used by HMMTOP data.
/// -> any
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
