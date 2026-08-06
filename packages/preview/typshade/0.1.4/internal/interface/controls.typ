// Copyright (C) 2026 Eito Yoneyama
// SPDX-License-Identifier: GPL-2.0

/// Public command constructors for detailed alignment control.

#import "../engine/config.typ" as _config

/// Configure sequence type.
///
/// - value (any): Value for this setting.
/// -> dictionary
#let sequence-type(value) = _config.sequence-type(value)
/// Configure color scheme.
///
/// - name (str, none): Name used by the generated command or rendered element.
/// -> dictionary
#let color-scheme(name) = _config.color-scheme(name)
/// Configure scoring mode.
///
/// - name (str, none): Name used by the generated command or rendered element.
/// - option (any): Optional mode-specific value.
/// -> dictionary
#let scoring-mode(name, option: none) = _config.scoring-mode(name, option: option)
/// Configure tcoffee scores.
///
/// - source (any): Input data, text, bytes, or a path accepted by the selected parser.
/// -> dictionary
#let tcoffee-scores(source) = scoring-mode("T-Coffee", option: source)
/// Configure sequence window.
///
/// - sequence (int, str): Sequence name, one-based index, or supported sequence selector.
/// - selection (str, dictionary): Residue range or Selection DSL expression to resolve.
/// - start (int, str, none): Inclusive start position or replacement starting number.
/// -> dictionary
#let sequence-window(sequence, selection, start: none) = _config.sequence-window(sequence, selection, start: start)
/// Configure residues per line.
///
/// - value (any): Value for this setting.
/// -> dictionary
#let residues-per-line(value) = _config.residues-per-line(value)
/// Configure auto layout.
///
/// - fit (str, bool, dictionary, none): Container-fitting strategy used by automatic layout.
/// - min (int, float, none): Minimum permitted value.
/// - max (int, float, none): Maximum permitted value, or `none` for no explicit maximum.
/// -> dictionary
#let auto-layout(fit: "container", min: 1, max: none) = _config.auto-layout(fit: fit, min: min, max: max)
/// Configure auto page.
///
/// - blocks (int, auto): Alignment blocks per page, or `auto` to calculate the count.
/// - repeat-legend (bool): Whether each automatic page repeats the legend.
/// -> dictionary
#let auto-page(blocks: auto, repeat-legend: true) = _config.auto-page(blocks: blocks, repeat-legend: repeat-legend)
/// Configure threshold.
///
/// - value (any): Value for this setting.
/// -> dictionary
#let threshold(value) = _config.threshold(value)
/// Configure shade all residues.
/// -> dictionary
#let shade-all-residues() = _config.shade-all-residues()
/// Configure all match threshold.
///
/// - value (any): Value for this setting.
/// -> dictionary
#let all-match-threshold(value: 100) = _config.all-match-threshold(value: value)
/// Configure disable all match threshold.
/// -> dictionary
#let disable-all-match-threshold() = _config.disable-all-match-threshold()
/// Hide all match positions.
/// -> dictionary
#let hide-all-match-positions() = _config.hide-all-match-positions()
/// Show all match positions.
/// -> dictionary
#let show-all-match-positions() = _config.show-all-match-positions()

/// Configure weight table.
///
/// - name (str, none): Name used by the generated command or rendered element.
/// -> dictionary
#let weight-table(name) = _config.weight-table(name)
/// Configure set weight.
///
/// - residue-a (int, str): First residue symbol or number.
/// - residue-b (int, str): Second residue symbol or number.
/// - value (any): Value for this setting.
/// -> dictionary
#let set-weight(residue-a, residue-b, value) = _config.set-weight(residue-a, residue-b, value)
/// Configure gap penalty.
///
/// - value (any): Value for this setting.
/// -> dictionary
#let gap-penalty(value) = _config.gap-penalty(value)

/// Configure residue style.
///
/// - target (str): Alignment element or residue class to configure.
/// - fg (color, str, none): Foreground color.
/// - bg (color, str, none): Background color.
/// - case (str): Letter case applied to rendered residues.
/// - style (str, dictionary, none): Visual or typographic style.
/// -> dictionary
#let residue-style(target, fg, bg, case: "upper", style: "normal") = _config.residue-style(target, fg, bg, case: case, style: style)
/// Configure cell style.
///
/// - callback (function): Function called with cell context to return style overrides.
/// -> dictionary
#let cell-style(callback) = _config.cell-style(callback)
/// Configure peptide groups.
///
/// - groups (array, dictionary, none): Optional residue-group definitions.
/// -> dictionary
#let peptide-groups(groups) = _config.peptide-groups(groups)
/// Configure dna groups.
///
/// - groups (array, dictionary, none): Optional residue-group definitions.
/// -> dictionary
#let dna-groups(groups) = _config.dna-groups(groups)
/// Configure peptide similarities.
///
/// - residue (int, str): Residue symbol or one-based residue number, as appropriate.
/// - similars (str, array): Residues treated as similar to the target residue.
/// -> dictionary
#let peptide-similarities(residue, similars) = _config.peptide-similarities(residue, similars)
/// Configure dna similarities.
///
/// - residue (int, str): Residue symbol or one-based residue number, as appropriate.
/// - similars (str, array): Residues treated as similar to the target residue.
/// -> dictionary
#let dna-similarities(residue, similars) = _config.dna-similarities(residue, similars)
/// Clear functional groups.
/// -> dictionary
#let clear-functional-groups() = _config.clear-functional-groups()
/// Configure functional group.
///
/// - name (str, none): Name used by the generated command or rendered element.
/// - residues (str, array, arguments): Residue symbols or positions to target.
/// - fg (color, str, none): Foreground color.
/// - bg (color, str, none): Background color.
/// - case (str): Letter case applied to rendered residues.
/// - style (str, dictionary, none): Visual or typographic style.
/// -> dictionary
#let functional-group(name, residues, fg, bg, case: "upper", style: "normal") = _config.functional-group(name, residues, fg, bg, case: case, style: style)
/// Configure functional style.
///
/// - residue (int, str): Residue symbol or one-based residue number, as appropriate.
/// - fg (color, str, none): Foreground color.
/// - bg (color, str, none): Background color.
/// - case (str): Letter case applied to rendered residues.
/// - style (str, dictionary, none): Visual or typographic style.
/// -> dictionary
#let functional-style(residue, fg, bg, case: "upper", style: "normal") = _config.functional-style(residue, fg, bg, case: case, style: style)

/// Create a names track command.
///
/// - position (str, none): Track side or alignment position to target.
/// - color (color, str, none): Color accepted by Typst or Typshade's named-color resolver.
/// -> dictionary
#let names-track(position: "left", color: none) = _config.names-track(position: position, color: color)
/// Disable names.
/// -> dictionary
#let no-names() = _config.no-names-track()
/// Create a numbering track command.
///
/// - position (str, none): Track side or alignment position to target.
/// - color (color, str, none): Color accepted by Typst or Typshade's named-color resolver.
/// -> dictionary
#let numbering-track(position: "right", color: none) = _config.numbering-track(position: position, color: color)
/// Disable numbering.
/// -> dictionary
#let no-numbering() = _config.no-numbering-track()
/// Configure sequence name.
///
/// - sequence (int, str): Sequence name, one-based index, or supported sequence selector.
/// - name (str, none): Name used by the generated command or rendered element.
/// -> dictionary
#let sequence-name(sequence, name) = _config.sequence-name(sequence, name)
/// Configure names color.
///
/// - color (color, str, none): Color accepted by Typst or Typshade's named-color resolver.
/// -> dictionary
#let names-color(color) = _config.names-color(color)
/// Configure sequence name color.
///
/// - sequences (int, str, array): Sequence names, indices, or selectors to target.
/// - color (color, str, none): Color accepted by Typst or Typshade's named-color resolver.
/// -> dictionary
#let sequence-name-color(sequences, color) = _config.sequence-name-color(sequences, color)
/// Hide sequence name.
///
/// - sequences (int, str, array): Sequence names, indices, or selectors to target.
/// -> dictionary
#let hide-sequence-name(sequences) = _config.hide-sequence-name(sequences)
/// Configure numbering color.
///
/// - color (color, str, none): Color accepted by Typst or Typshade's named-color resolver.
/// -> dictionary
#let numbering-color(color) = _config.numbering-color(color)
/// Configure sequence number color.
///
/// - sequences (int, str, array): Sequence names, indices, or selectors to target.
/// - color (color, str, none): Color accepted by Typst or Typshade's named-color resolver.
/// -> dictionary
#let sequence-number-color(sequences, color) = _config.sequence-number-color(sequences, color)
/// Hide sequence number.
///
/// - sequences (int, str, array): Sequence names, indices, or selectors to target.
/// -> dictionary
#let hide-sequence-number(sequences) = _config.hide-sequence-number(sequences)

/// Configure consensus name.
///
/// - name (str, none): Name used by the generated command or rendered element.
/// -> dictionary
#let consensus-name(name) = _config.consensus-name(name)
/// Configure consensus language.
///
/// - name (str, none): Name used by the generated command or rendered element.
/// -> dictionary
#let consensus-language(name) = _config.language(name)
/// Configure consensus symbols.
///
/// - none-symbol (str): Consensus symbol used for non-conserved columns.
/// - conserved-symbol (str): Consensus symbol used for conserved columns.
/// - allmatch-symbol (str): Consensus symbol used for fully conserved columns.
/// -> dictionary
#let consensus-symbols(none-symbol, conserved-symbol, allmatch-symbol) = _config.consensus-symbols(none-symbol, conserved-symbol, allmatch-symbol)
/// Configure consensus colors.
///
/// - none-fg (color, str): Foreground color for non-conserved consensus symbols.
/// - none-bg (color, str): Background color for non-conserved consensus symbols.
/// - conserved-fg (color, str): Foreground color for conserved consensus symbols.
/// - conserved-bg (color, str): Background color for conserved consensus symbols.
/// - allmatch-fg (color, str): Foreground color for fully conserved consensus symbols.
/// - allmatch-bg (color, str): Background color for fully conserved consensus symbols.
/// -> dictionary
#let consensus-colors(none-fg: "Black", none-bg: "White", conserved-fg: "Black", conserved-bg: "White", allmatch-fg: "Black", allmatch-bg: "White") = _config.consensus-colors(
  none-fg: none-fg,
  none-bg: none-bg,
  conserved-fg: conserved-fg,
  conserved-bg: conserved-bg,
  allmatch-fg: allmatch-fg,
  allmatch-bg: allmatch-bg,
)
/// Configure consensus from sequence.
///
/// - sequence (int, str): Sequence name, one-based index, or supported sequence selector.
/// -> dictionary
#let consensus-from-sequence(sequence) = _config.consensus-from-sequence(sequence)
/// Configure consensus from all sequences.
/// -> dictionary
#let consensus-from-all-sequences() = _config.consensus-from-all-sequences()

/// Configure ruler steps.
///
/// - value (any): Value for this setting.
/// - position (str, none): Track side or alignment position to target.
/// -> dictionary
#let ruler-steps(value, position: none) = _config.ruler-steps(value, position: position)
/// Configure ruler color.
///
/// - color (color, str, none): Color accepted by Typst or Typshade's named-color resolver.
/// - position (str, none): Track side or alignment position to target.
/// -> dictionary
#let ruler-color(color, position: none) = _config.ruler-color(color, position: position)
/// Configure ruler name.
///
/// - name (str, none): Name used by the generated command or rendered element.
/// - position (str, none): Track side or alignment position to target.
/// -> dictionary
#let ruler-name(name, position: none) = _config.ruler-name(name, position: position)
/// Configure ruler name color.
///
/// - color (color, str, none): Color accepted by Typst or Typshade's named-color resolver.
/// - position (str, none): Track side or alignment position to target.
/// -> dictionary
#let ruler-name-color(color, position: none) = _config.ruler-name-color(color, position: position)
/// Configure ruler space.
///
/// - value (any): Value for this setting.
/// - position (str, none): Track side or alignment position to target.
/// -> dictionary
#let ruler-space(value, position: none) = _config.ruler-space(value, position: position)
/// Configure rotate ruler.
///
/// - position (str, none): Track side or alignment position to target.
/// -> dictionary
#let rotate-ruler(position: none) = _config.rotate-ruler(position)
/// Configure unrotate ruler.
///
/// - position (str, none): Track side or alignment position to target.
/// -> dictionary
#let unrotate-ruler(position: none) = _config.unrotate-ruler(position)

/// Configure gap char.
///
/// - symbol (str): Character used for the configured residue class.
/// -> dictionary
#let gap-char(symbol) = _config.gap-char(symbol)
/// Configure gap rule.
///
/// - thickness (length): Line or rule thickness.
/// -> dictionary
#let gap-rule(thickness) = _config.gap-rule(thickness)
/// Configure gap colors.
///
/// - foreground (color, str, none): Foreground color.
/// - background (color, str, none): Background color.
/// -> dictionary
#let gap-colors(foreground, background) = _config.gap-colors(foreground, background)
/// Configure stop char.
///
/// - symbol (str): Character used for the configured residue class.
/// -> dictionary
#let stop-char(symbol) = _config.stop-char(symbol)
/// Show leading gaps.
/// -> dictionary
#let show-leading-gaps() = _config.show-leading-gaps()
/// Hide leading gaps.
/// -> dictionary
#let hide-leading-gaps() = _config.hide-leading-gaps()

/// Configure start number.
///
/// - sequence (int, str): Sequence name, one-based index, or supported sequence selector.
/// - start (int, str, none): Inclusive start position or replacement starting number.
/// - selection (str, dictionary, none): Residue range or Selection DSL expression to resolve.
/// -> dictionary
#let start-number(sequence, start, selection: none) = _config.start-number(sequence, start, selection: selection)
/// Allow zero numbering.
/// -> dictionary
#let allow-zero-numbering() = _config.allow-zero-numbering()
/// Disallow zero numbering.
/// -> dictionary
#let disallow-zero-numbering() = _config.disallow-zero-numbering()
/// Configure sequence length.
///
/// - sequence (int, str): Sequence name, one-based index, or supported sequence selector.
/// - length (int): Declared sequence length or output extent.
/// -> dictionary
#let sequence-length(sequence, length) = _config.sequence-length(sequence, length)
/// Configure domain.
///
/// - sequence (int, str): Sequence name, one-based index, or supported sequence selector.
/// - selection (str, dictionary): Residue range or Selection DSL expression to resolve.
/// -> dictionary
#let domain(sequence, selection) = _config.domain(sequence, selection)
/// Configure domain gap rule.
///
/// - thickness (length): Line or rule thickness.
/// -> dictionary
#let domain-gap-rule(thickness) = _config.domain-gap-rule(thickness)
/// Configure domain gap colors.
///
/// - foreground (color, str, none): Foreground color.
/// - background (color, str, none): Background color.
/// -> dictionary
#let domain-gap-colors(foreground, background) = _config.domain-gap-colors(foreground, background)

/// Configure highlight block.
///
/// - sequence (int, str): Sequence name, one-based index, or supported sequence selector.
/// - selection (str, dictionary): Residue range or Selection DSL expression to resolve.
/// - args (arguments): Additional positional or named options forwarded to the command.
/// -> dictionary
#let highlight-block(sequence, selection, ..args) = _config.highlight-block(sequence, selection, ..args)
/// Configure region color scheme.
///
/// - sequence (int, str): Sequence name, one-based index, or supported sequence selector.
/// - selection (str, dictionary): Residue range or Selection DSL expression to resolve.
/// - scheme (str, dictionary): Named color scheme.
/// -> dictionary
#let region-color-scheme(sequence, selection, scheme) = _config.region-color-scheme(sequence, selection, scheme)
/// Configure lower.
///
/// - sequence (int, str): Sequence name, one-based index, or supported sequence selector.
/// - selection (str, dictionary): Residue range or Selection DSL expression to resolve.
/// -> dictionary
#let lower(sequence, selection) = _config.region-lower(sequence, selection)
/// Configure lower block.
///
/// - sequence (int, str): Sequence name, one-based index, or supported sequence selector.
/// - selection (str, dictionary): Residue range or Selection DSL expression to resolve.
/// -> dictionary
#let lower-block(sequence, selection) = _config.lower-block(sequence, selection)
/// Configure emphasis block.
///
/// - sequence (int, str): Sequence name, one-based index, or supported sequence selector.
/// - selection (str, dictionary): Residue range or Selection DSL expression to resolve.
/// - style (str, dictionary, none): Visual or typographic style.
/// -> dictionary
#let emphasis-block(sequence, selection, style: "italic") = _config.emphasis-block(sequence, selection, style: style)
/// Configure tint block.
///
/// - sequence (int, str): Sequence name, one-based index, or supported sequence selector.
/// - selection (str, dictionary): Residue range or Selection DSL expression to resolve.
/// - intensity (str, int, float): Tint strength.
/// -> dictionary
#let tint-block(sequence, selection, intensity: "medium") = _config.tint-block(sequence, selection, intensity: intensity)
/// Configure tint default.
///
/// - effect (str): Named default tint effect.
/// -> dictionary
#let tint-default(effect) = _config.tint-default(effect)
/// Configure emphasis default.
///
/// - style (str, dictionary, none): Visual or typographic style.
/// -> dictionary
#let emphasis-default(style) = _config.emphasis-default(style)
/// Configure frame.
///
/// - sequence (int, str): Sequence name, one-based index, or supported sequence selector.
/// - selection (str, dictionary): Residue range or Selection DSL expression to resolve.
/// - color (color, str, none): Color accepted by Typst or Typshade's named-color resolver.
/// -> dictionary
#let frame(sequence, selection, color: "Red") = _config.frame-block(sequence, selection, color: color)

/// Hide sequence.
///
/// - sequence (int, str): Sequence name, one-based index, or supported sequence selector.
/// -> dictionary
#let hide-sequence(sequence) = _config.hide-sequence(sequence)
/// Hide all sequences.
/// -> dictionary
#let hide-all-sequences() = _config.hide-all-sequences()
/// Show all sequences.
/// -> dictionary
#let show-all-sequences() = _config.show-all-sequences()
/// Configure remove sequence.
///
/// - sequence (int, str): Sequence name, one-based index, or supported sequence selector.
/// -> dictionary
#let remove-sequence(sequence) = _config.remove-sequence(sequence)
/// Disable shade.
///
/// - sequences (int, str, array): Sequence names, indices, or selectors to target.
/// -> dictionary
#let no-shade(sequences) = _config.no-shade(sequences)
/// Configure separation line.
///
/// - sequence (int, str): Sequence name, one-based index, or supported sequence selector.
/// -> dictionary
#let separation-line(sequence) = _config.separation-line(sequence)
/// Configure sequence order.
///
/// - order (array): Sequence order expressed as names or one-based indices.
/// -> dictionary
#let sequence-order(order) = _config.sequence-order(order)

/// Configure feature rule.
///
/// - thickness (length): Line or rule thickness.
/// -> dictionary
#let feature-rule(thickness) = _config.feature-rule(thickness)
/// Configure codon.
///
/// - residue (int, str): Residue symbol or one-based residue number, as appropriate.
/// - triplets (str, array): Comma-separated codons assigned to the residue.
/// -> dictionary
#let codon(residue, triplets) = _config.codon(residue, triplets)
/// Configure genetic code.
///
/// - name (str, none): Name used by the generated command or rendered element.
/// -> dictionary
#let genetic-code(name) = _config.genetic-code(name)
/// Configure backtranslation label.
///
/// - args (arguments): Additional positional or named options forwarded to the command.
/// -> dictionary
#let backtranslation-label(..args) = _config.backtranslation-label(..args)
/// Configure backtranslation text.
///
/// - args (arguments): Additional positional or named options forwarded to the command.
/// -> dictionary
#let backtranslation-text(..args) = _config.backtranslation-text(..args)
/// Configure feature text label.
///
/// - position (str, none): Track side or alignment position to target.
/// - name (str, none): Name used by the generated command or rendered element.
/// -> dictionary
#let feature-text-label(position, name) = _config.feature-text-label(position, name)
/// Configure feature style label.
///
/// - position (str, none): Track side or alignment position to target.
/// - name (str, none): Name used by the generated command or rendered element.
/// -> dictionary
#let feature-style-label(position, name) = _config.feature-style-label(position, name)
/// Hide feature text label.
///
/// - position (str, none): Track side or alignment position to target.
/// -> dictionary
#let hide-feature-text-label(position) = _config.hide-feature-text-label(position)
/// Hide feature style label.
///
/// - position (str, none): Track side or alignment position to target.
/// -> dictionary
#let hide-feature-style-label(position) = _config.hide-feature-style-label(position)
/// Hide feature text labels.
/// -> dictionary
#let hide-feature-text-labels() = _config.hide-feature-text-labels()
/// Hide feature style labels.
/// -> dictionary
#let hide-feature-style-labels() = _config.hide-feature-style-labels()
/// Configure feature text label color.
///
/// - color (color, str, none): Color accepted by Typst or Typshade's named-color resolver.
/// -> dictionary
#let feature-text-label-color(color) = _config.feature-text-label-color(color)
/// Configure feature style label color.
///
/// - color (color, str, none): Color accepted by Typst or Typshade's named-color resolver.
/// -> dictionary
#let feature-style-label-color(color) = _config.feature-style-label-color(color)
/// Configure feature text label color at.
///
/// - position (str, none): Track side or alignment position to target.
/// - color (color, str, none): Color accepted by Typst or Typshade's named-color resolver.
/// -> dictionary
#let feature-text-label-color-at(position, color) = _config.feature-text-label-color-at(position, color)
/// Configure feature style label color at.
///
/// - position (str, none): Track side or alignment position to target.
/// - color (color, str, none): Color accepted by Typst or Typshade's named-color resolver.
/// -> dictionary
#let feature-style-label-color-at(position, color) = _config.feature-style-label-color-at(position, color)

/// Configure frequency correction.
/// -> dictionary
#let frequency-correction() = _config.frequency-correction()
/// Disable frequency correction.
/// -> dictionary
#let no-frequency-correction() = _config.no-frequency-correction()
/// Configure subfamily.
///
/// - sequences (int, str, array): Sequence names, indices, or selectors to target.
/// -> dictionary
#let subfamily(sequences) = _config.subfamily(sequences)
/// Configure sequence logo name.
///
/// - name (str, none): Name used by the generated command or rendered element.
/// -> dictionary
#let sequence-logo-name(name) = _config.sequence-logo-name(name)
/// Configure subfamily logo name.
///
/// - name (str, none): Name used by the generated command or rendered element.
/// - negative-name (str, none): Optional label for the negative subfamily logo.
/// -> dictionary
#let subfamily-logo-name(name, negative-name: none) = _config.subfamily-logo-name(name, negative-name: negative-name)
/// Configure logo scale.
///
/// - position (str, none): Track side or alignment position to target.
/// - color (color, str, none): Color accepted by Typst or Typshade's named-color resolver.
/// -> dictionary
#let logo-scale(position: "leftright", color: "Black") = _config.logo-scale(position: position, color: color)
/// Disable logo scale.
/// -> dictionary
#let no-logo-scale() = _config.no-logo-scale()
/// Configure logo stretch.
///
/// - value (any): Value for this setting.
/// -> dictionary
#let logo-stretch(value) = _config.logo-stretch(value)
/// Configure negative logo values.
/// -> dictionary
#let negative-logo-values() = _config.negative-logo-values()
/// Disable negative logo values.
/// -> dictionary
#let no-negative-logo-values() = _config.no-negative-logo-values()
/// Configure relevance threshold.
///
/// - value (any): Value for this setting.
/// -> dictionary
#let relevance-threshold(value) = _config.relevance-threshold(value)
/// Configure relevance marker.
///
/// - char (str): Character used by the marker.
/// - color (color, str, none): Color accepted by Typst or Typshade's named-color resolver.
/// -> dictionary
#let relevance-marker(char: "*", color: "Black") = _config.relevance-marker(char: char, color: color)
/// Disable relevance marker.
/// -> dictionary
#let no-relevance-marker() = _config.no-relevance-marker()
/// Configure logo color.
///
/// - residues (str, array, arguments): Residue symbols or positions to target.
/// - color (color, str, none): Color accepted by Typst or Typshade's named-color resolver.
/// -> dictionary
#let logo-color(residues, color) = _config.logo-color(residues, color)
/// Clear logo colors.
///
/// - default (any): Default value used when no explicit override matches.
/// -> dictionary
#let clear-logo-colors(default: "Black") = _config.clear-logo-colors(default: default)

/// Disable legend.
/// -> dictionary
#let no-legend() = _config.no-legend-track()
/// Configure legend color.
///
/// - color (color, str, none): Color accepted by Typst or Typshade's named-color resolver.
/// -> dictionary
#let legend-color(color) = _config.legend-color(color)
/// Configure legend offset.
///
/// - dx (length): Horizontal legend offset.
/// - dy (length): Vertical legend offset.
/// -> dictionary
#let legend-offset(dx, dy) = _config.legend-offset(dx, dy)
/// Configure color swatch.
///
/// - color (color, str, none): Color accepted by Typst or Typshade's named-color resolver.
/// -> content
#let color-swatch(color) = _config.color-swatch(color)

/// Show structure types.
///
/// - format (str, auto): Input format, or `auto` to detect it.
/// - types (str, array): Structural annotation types to show or hide.
/// -> dictionary
#let show-structure-types(format, types) = _config.show-structure-types(format, types)
/// Hide structure types.
///
/// - format (str, auto): Input format, or `auto` to detect it.
/// - types (str, array): Structural annotation types to show or hide.
/// -> dictionary
#let hide-structure-types(format, types) = _config.hide-structure-types(format, types)
/// Configure structure appearance.
///
/// - format (str, auto): Input format, or `auto` to detect it.
/// - structure-type (str): Structural annotation type to configure.
/// - position (str, none): Track side or alignment position to target.
/// - style (str, dictionary, none): Visual or typographic style.
/// - text (str, content): Text displayed by the generated annotation or label.
/// -> dictionary
#let structure-appearance(format, structure-type, position, style, text) = _config.structure-appearance(format, structure-type, position, style, text)
/// Use the first dssp column.
/// -> dictionary
#let use-first-dssp-column() = _config.use-first-dssp-column()
/// Use the second dssp column.
/// -> dictionary
#let use-second-dssp-column() = _config.use-second-dssp-column()
/// Create a stride track command.
///
/// - sequence (int, str): Sequence name, one-based index, or supported sequence selector.
/// - source (any): Input data, text, bytes, or a path accepted by the selected parser.
/// -> dictionary
#let stride-track(sequence, source) = _config.stride-track(sequence, source)
/// Create a dssp track command.
///
/// - sequence (int, str): Sequence name, one-based index, or supported sequence selector.
/// - source (any): Input data, text, bytes, or a path accepted by the selected parser.
/// -> dictionary
#let dssp-track(sequence, source) = _config.dssp-track(sequence, source)
/// Create a hmmtop track command.
///
/// - sequence (int, str): Sequence name, one-based index, or supported sequence selector.
/// - source (any): Input data, text, bytes, or a path accepted by the selected parser.
/// - source-sequence (str, none): Sequence identifier represented by the annotation source.
/// -> dictionary
#let hmmtop-track(sequence, source, source-sequence: none) = _config.hmmtop-track(sequence, source, source-sequence: source-sequence)
/// Create a phd topology track command.
///
/// - sequence (int, str): Sequence name, one-based index, or supported sequence selector.
/// - source (any): Input data, text, bytes, or a path accepted by the selected parser.
/// -> dictionary
#let phd-topology-track(sequence, source) = _config.phd-topology-track(sequence, source)
/// Create a phd secondary track command.
///
/// - sequence (int, str): Sequence name, one-based index, or supported sequence selector.
/// - source (any): Input data, text, bytes, or a path accepted by the selected parser.
/// -> dictionary
#let phd-secondary-track(sequence, source) = _config.phd-secondary-track(sequence, source)

/// Configure keep single sequence gaps.
/// -> dictionary
#let keep-single-sequence-gaps() = _config.keep-single-sequence-gaps()
/// Configure shift single sequence.
///
/// - value (any): Value for this setting.
/// -> dictionary
#let shift-single-sequence(value: -1) = _config.shift-single-sequence(value)
/// Hide residues.
/// -> dictionary
#let hide-residues() = _config.hide-residues()
/// Show residues.
/// -> dictionary
#let show-residues() = _config.show-residues()
/// Configure bar graph stretch.
///
/// - value (any): Value for this setting.
/// - position (str, none): Track side or alignment position to target.
/// -> dictionary
#let bar-graph-stretch(value, position: none) = _config.bar-graph-stretch(value, position: position)
/// Configure color scale stretch.
///
/// - value (any): Value for this setting.
/// - position (str, none): Track side or alignment position to target.
/// -> dictionary
#let color-scale-stretch(value, position: none) = _config.color-scale-stretch(value, position: position)
/// Configure alignment position.
///
/// - position (str, none): Track side or alignment position to target.
/// -> dictionary
#let alignment-position(position) = _config.alignment(position)
/// Configure character stretch.
///
/// - value (any): Value for this setting.
/// -> dictionary
#let character-stretch(value) = _config.character-stretch(value)
/// Configure line stretch.
///
/// - value (any): Value for this setting.
/// -> dictionary
#let line-stretch(value) = _config.line-stretch(value)
/// Configure numbering width.
///
/// - digits (int): Reserved width in decimal digits.
/// -> dictionary
#let numbering-width(digits) = _config.numbering-width(digits)
/// Configure fingerprint.
///
/// - value (any): Value for this setting.
/// -> dictionary
#let fingerprint(value) = _config.fingerprint(value)
/// Configure align right labels.
/// -> dictionary
#let align-right-labels() = _config.align-right-labels()
/// Configure align left labels.
/// -> dictionary
#let align-left-labels() = _config.align-left-labels()

/// Configure text family.
///
/// - target (str): Alignment element or residue class to configure.
/// - family (str, array): Font family.
/// -> dictionary
#let text-family(target, family) = _config.text-family(target, family)
/// Configure text weight.
///
/// - target (str): Alignment element or residue class to configure.
/// - weight (str, int): Font weight.
/// -> dictionary
#let text-weight(target, weight) = _config.text-weight(target, weight)
/// Configure text posture.
///
/// - target (str): Alignment element or residue class to configure.
/// - posture (str): Font posture.
/// -> dictionary
#let text-posture(target, posture) = _config.text-posture(target, posture)
/// Configure text size.
///
/// - target (str): Alignment element or residue class to configure.
/// - size (length): Text size.
/// -> dictionary
#let text-size(target, size) = _config.text-size(target, size)
/// Configure text style.
///
/// - target (str): Alignment element or residue class to configure.
/// - family (str, array): Font family.
/// - weight (str, int): Font weight.
/// - posture (str): Font posture.
/// - size (length): Text size.
/// -> dictionary
#let text-style(target, family, weight, posture, size) = _config.text-style(target, family, weight, posture, size)

/// Configure caption.
///
/// - text (str, content): Text displayed by the generated annotation or label.
/// - position (str, none): Track side or alignment position to target.
/// -> dictionary
#let caption(text, position: "bottom") = _config.caption(text, position: position)
/// Configure short caption.
///
/// - text (str, content): Text displayed by the generated annotation or label.
/// -> dictionary
#let short-caption(text) = _config.short-caption(text)
/// Configure small separator.
/// -> dictionary
#let small-separator() = _config.small-separator()
/// Configure medium separator.
/// -> dictionary
#let medium-separator() = _config.medium-separator()
/// Configure large separator.
/// -> dictionary
#let large-separator() = _config.large-separator()
/// Disable block gap.
/// -> dictionary
#let no-block-gap() = _config.no-block-gap()
/// Configure small block gap.
/// -> dictionary
#let small-block-gap() = _config.small-block-gap()
/// Configure medium block gap.
/// -> dictionary
#let medium-block-gap() = _config.medium-block-gap()
/// Configure large block gap.
/// -> dictionary
#let large-block-gap() = _config.large-block-gap()
/// Configure block gap.
///
/// - value (any): Value for this setting.
/// -> dictionary
#let block-gap(value) = _config.block-gap(value)
/// Configure flexible block gap.
/// -> dictionary
#let flexible-block-gap() = _config.flexible-block-gap()
/// Configure fixed block gap.
/// -> dictionary
#let fixed-block-gap() = _config.fixed-block-gap()
/// Disable line gap.
/// -> dictionary
#let no-line-gap() = _config.no-line-gap()
/// Configure small line gap.
/// -> dictionary
#let small-line-gap() = _config.small-line-gap()
/// Configure medium line gap.
/// -> dictionary
#let medium-line-gap() = _config.medium-line-gap()
/// Configure large line gap.
/// -> dictionary
#let large-line-gap() = _config.large-line-gap()
/// Configure line gap.
///
/// - value (any): Value for this setting.
/// -> dictionary
#let line-gap(value) = _config.line-gap(value)
/// Configure feature slot space.
///
/// - position (str, none): Track side or alignment position to target.
/// - value (any): Value for this setting.
/// -> dictionary
#let feature-slot-space(position, value) = _config.feature-slot-space(position, value)

/// Calculate the molecular weight of a protein sequence.
///
/// - sequence (int, str): Sequence name, one-based index, or supported sequence selector.
/// - unit (str): Unit used for the returned molecular weight.
/// -> str
#let molecular-weight(sequence, unit: "Da") = _config.molweight(sequence, unit: unit)
/// Calculate the approximate net charge of a protein sequence.
///
/// - sequence (int, str): Sequence name, one-based index, or supported sequence selector.
/// - termini (str): Terminal charge convention.
/// -> str
#let net-charge(sequence, termini: "o") = _config.charge(sequence, termini: termini)
/// Create a command from a PDB geometry selection.
///
/// - selection (str, dictionary): Residue range or Selection DSL expression to resolve.
/// -> dictionary
#let pdb-selection(selection) = _config.pdb-selection(selection)
