// Copyright (C) 2026 Eito Yoneyama
// SPDX-License-Identifier: GPL-2.0

/// Concise convenience commands for common shading workflows.

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

/// Shade columns by residue identity.
///
/// - colors (str, array, dictionary, none, auto): Color scheme or explicit color configuration.
/// - threshold (int, float, none, auto): Percentage or score threshold used by the operation.
/// - option (any): Optional mode-specific value.
/// - rest (arguments): Additional named scoring options forwarded to the low-level command.
/// -> any
#let identical(colors: none, threshold: none, option: none, ..rest) = _scoring(
  "identical",
  colors: colors,
  threshold: threshold,
  option: option,
  ..rest,
)

/// Shade columns by biochemical similarity.
///
/// - colors (str, array, dictionary, none, auto): Color scheme or explicit color configuration.
/// - threshold (int, float, none, auto): Percentage or score threshold used by the operation.
/// - option (any): Optional mode-specific value.
/// - rest (arguments): Additional named scoring options forwarded to the low-level command.
/// -> any
#let similar(colors: none, threshold: none, option: none, ..rest) = _scoring(
  "similar",
  colors: colors,
  threshold: threshold,
  option: option,
  ..rest,
)

/// Shade columns by residue diversity.
///
/// - colors (str, array, dictionary, none, auto): Color scheme or explicit color configuration.
/// - threshold (int, float, none, auto): Percentage or score threshold used by the operation.
/// - option (any): Optional mode-specific value.
/// - rest (arguments): Additional named scoring options forwarded to the low-level command.
/// -> any
#let diverse(colors: none, threshold: none, option: none, ..rest) = _scoring(
  "diverse",
  colors: colors,
  threshold: threshold,
  option: option,
  ..rest,
)

/// Shade residues using a functional-group preset.
///
/// - kind (str): Rendering or measurement variant.
/// - colors (str, array, dictionary, none, auto): Color scheme or explicit color configuration.
/// - threshold (int, float, none, auto): Percentage or score threshold used by the operation.
/// - rest (arguments): Additional named scoring options forwarded to the low-level command.
/// -> any
#let functional(kind, colors: none, threshold: none, ..rest) = _scoring(
  "functional",
  colors: colors,
  threshold: threshold,
  option: kind,
  ..rest,
)

/// Shade relative to one reference sequence.
///
/// - colors (str, array, dictionary, none, auto): Color scheme or explicit color configuration.
/// - threshold (int, float, none, auto): Percentage or score threshold used by the operation.
/// - sequence (int, str, none): Sequence name, one-based index, or supported sequence selector.
/// - rest (arguments): Additional named scoring options forwarded to the low-level command.
/// -> any
#let single-sequence(colors: none, threshold: none, sequence: none, ..rest) = _scoring(
  "singleseq",
  colors: colors,
  threshold: threshold,
  option: sequence,
  ..rest,
)

/// Shade an alignment from T-Coffee confidence scores.
///
/// - source (any): Input data, text, bytes, or a path accepted by the selected parser.
/// -> any
#let tcoffee(source) = _config.scoring-mode("T-Coffee", option: source)

/// Set the number of residues rendered per line.
///
/// - count (int): Number of residues rendered per line.
/// -> any
#let lines(count) = _config.residues-per-line(count)

/// Display a selected sequence window.
///
/// - sequence (int, str): Sequence name, one-based index, or supported sequence selector.
/// - selection (str, dictionary): Residue range or Selection DSL expression to resolve.
/// - start (int, str, none): Inclusive start position or replacement starting number.
/// -> any
#let window(sequence, selection, start: none) = _config.sequence-window(sequence, selection, start: start)

/// Show and configure sequence names.
///
/// - position (str, none): Track side or alignment position to target.
/// - color (color, str, none): Color accepted by Typst or Typshade's named-color resolver.
/// -> any
#let names(position: "left", color: none) = _config.names-track(position: position, color: color)

/// Disable names.
/// -> any
#let no-names() = _config.no-names-track()

/// Show and configure sequence numbering.
///
/// - position (str, none): Track side or alignment position to target.
/// - color (color, str, none): Color accepted by Typst or Typshade's named-color resolver.
/// -> any
#let numbers(position: "right", color: none) = _config.numbering-track(position: position, color: color)

/// Disable numbers.
/// -> any
#let no-numbers() = _config.no-numbering-track()

/// Show and configure the consensus track.
///
/// - position (str, none): Track side or alignment position to target.
/// - scale (str, dictionary, none): Scale placement or scale configuration.
/// - name (str, none): Name used by the generated command or rendered element.
/// -> any
#let consensus(position, scale: none, name: none) = consensus-track(position: position, scale: scale, name: name)

/// Disable consensus.
/// -> any
#let no-consensus() = _config.no-consensus-track()

/// Show and configure a ruler track.
///
/// - position (str, none): Track side or alignment position to target.
/// - sequence (int, str): Sequence name, one-based index, or supported sequence selector.
/// - every (int, none): Interval between generated ruler labels.
/// - steps (int, none): Interval between ruler labels.
/// - color (color, str, none): Color accepted by Typst or Typshade's named-color resolver.
/// - name (str, none): Name used by the generated command or rendered element.
/// - name-color (color, str, none): Color of the track name.
/// - space (length, none): Additional space reserved for the track.
/// -> any
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

/// Disable ruler.
///
/// - position (str, none): Track side or alignment position to target.
/// -> any
#let no-ruler(position: none) = _config.no-ruler-track(position: position)

/// Show and configure a sequence-logo track.
///
/// - position (str, none): Track side or alignment position to target.
/// - colors (str, array, dictionary, none, auto): Color scheme or explicit color configuration.
/// - name (str, none): Name used by the generated command or rendered element.
/// - scale (str, dictionary, none): Scale placement or scale configuration.
/// - relevance-marker (str, dictionary, none): Relevance-marker configuration or disablement value.
/// - stretch (int, float, none): Scale factor applied to the rendered element.
/// -> any
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

/// Disable logo.
/// -> any
#let no-logo() = _config.no-sequence-logo-track()

/// Show and configure the shading legend.
///
/// - color (color, str, none): Color accepted by Typst or Typshade's named-color resolver.
/// -> any
#let legend(color: "Black") = legend-track(color: color)

/// Disable legend.
/// -> any
#let no-legend() = _config.no-legend-track()

/// Add available structural annotation tracks for a sequence.
///
/// - sequence (int, str): Sequence name, one-based index, or supported sequence selector.
/// - hmmtop (any): HMMTOP annotation source.
/// - topology (any): Topology annotation source.
/// - secondary (any): Secondary-structure annotation source.
/// - hmmtop-sequence (str, none): Source sequence identifier used by HMMTOP data.
/// -> any
#let structures(sequence, hmmtop: none, topology: none, secondary: none, hmmtop-sequence: none) = {
  structure-tracks(
    sequence,
    hmmtop: hmmtop,
    topology: topology,
    secondary: secondary,
    hmmtop-sequence: hmmtop-sequence,
  )
}

/// Configure gap glyphs, rules, and colors.
///
/// - foreground (color, str, none): Foreground color.
/// - background (color, str, none): Background color.
/// - rule (length, none): Gap-rule thickness, or `none` to leave it unchanged.
/// -> any
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

/// Configure typography for alignment elements.
///
/// - target (str): Alignment element or residue class to configure.
/// - family (str, array, none): Font family.
/// - weight (str, int, none): Font weight.
/// - posture (str, none): Font posture.
/// - size (length, none): Text size.
/// -> any
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
