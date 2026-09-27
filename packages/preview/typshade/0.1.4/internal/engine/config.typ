// Copyright (C) 2026 Eito Yoneyama
// SPDX-License-Identifier: GPL-2.0

/// Low-level configuration model and command constructors used by the public API.

#import "../model/parser.typ": _chars, _lower, _upper, read-dssp, read-hmmtop, read-phd-secondary, read-phd-topology, read-stride, read-tcoffee
#import "../model/palette.typ": _dna-groups, _dna-sims, _functional-presets, _pep-groups, _pep-sims, resolve-color
#import "../model/pdb.typ": pdb-selection-list
#import "../model/text-style.typ": _default-text-styles, _set-text-style

#let _default-style(kind) = if kind == "identical" {
  (
    nomatch: (fg: "Black", bg: "White", case: "upper"),
    similar: (fg: "Black", bg: "Magenta", case: "upper"),
    conserved: (fg: "White", bg: "RoyalBlue", case: "upper"),
    allmatch: (fg: "Goldenrod", bg: "RoyalPurple", case: "upper"),
  )
} else { (
  nomatch: (fg: "Black", bg: "White", case: "upper"),
  similar: (fg: "Black", bg: "Magenta", case: "upper"),
  conserved: (fg: "White", bg: "RoyalBlue", case: "upper"),
  allmatch: (fg: "Goldenrod", bg: "RoyalPurple", case: "upper"),
) }

#let _apply-shading-colors(config, name) = {
  let style = config.at("residue-style")
  if name == "blues" {
    style.insert("similar", (fg: "Black", bg: "Magenta", case: "upper"))
    style.insert("conserved", (fg: "White", bg: "RoyalBlue", case: "upper"))
    style.insert("allmatch", (fg: "Goldenrod", bg: "RoyalPurple", case: "upper"))
  } else if name == "greens" {
    style.insert("similar", (fg: "Black", bg: "GreenYellow", case: "upper"))
    style.insert("conserved", (fg: "White", bg: "PineGreen", case: "upper"))
    style.insert("allmatch", (fg: "YellowOrange", bg: "OliveGreen", case: "upper"))
  } else if name == "reds" {
    style.insert("similar", (fg: "Black", bg: "YellowOrange", case: "upper"))
    style.insert("conserved", (fg: "White", bg: "BrickRed", case: "upper"))
    style.insert("allmatch", (fg: "YellowGreen", bg: "Mahagony", case: "upper"))
  } else if name == "grays" {
    style.insert("similar", (fg: "Black", bg: "LightGray", case: "upper"))
    style.insert("conserved", (fg: "White", bg: "DarkGray", case: "upper"))
    style.insert("allmatch", (fg: "White", bg: "Black", case: "upper"))
  } else if name == "black" {
    style.insert("similar", (fg: "Black", bg: "White", case: "upper"))
    style.insert("conserved", (fg: "White", bg: "Black", case: "upper"))
    style.insert("allmatch", (fg: "White", bg: "Black", case: "upper"))
  } else if config.at("shading-schemes").keys().contains(name) {
    let saved = config.at("shading-schemes").at(name)
    for key in saved.at("residue-style").keys() {
      style.insert(key, saved.at("residue-style").at(key))
    }
    for key in saved.at("gaps").keys() {
      config.at("gaps").insert(key, saved.at("gaps").at(key))
    }
  }
}

#let _style-record(fg, bg, case, style) = (fg: fg, bg: bg, case: case, style: style)
#let _func-style-record(name, residues, fg, bg, case, style) = (name: name, residues: _upper(str(residues)), fg: fg, bg: bg, case: case, style: style)

#let _residue-masses = (
  A: 89.1, C: 121.2, D: 133.1, E: 147.1, F: 165.2, G: 75.1, H: 155.2, I: 131.2,
  K: 146.2, L: 131.2, M: 149.2, N: 132.1, P: 115.1, Q: 146.1, R: 174.2, S: 105.1,
  T: 119.1, V: 117.1, W: 204.2, Y: 181.2,
)

#let _peptide-charges = (
  C: -0.03, D: -1.0, E: -1.0, H: 0.165, K: 1.0, R: 1.0,
)

#let _standard-genetic-code = (
  A: "GCN", C: "TGY", D: "GAY", E: "GAR", F: "TTY", G: "GGN", H: "CAY", I: "ATH",
  K: "AAR", L: "YTN", M: "ATG", N: "AAY", P: "CCN", Q: "CAR", R: "MGN", S: "WSN",
  T: "ACN", V: "GTN", W: "TGG", Y: "TAY", ".": "TRR",
)

#let _clean-residue-string(sequence) = _upper(str(sequence)).replace(".", "").replace("-", "").replace(" ", "").replace("\n", "")

/// Calculate the molecular weight of a protein sequence.
///
/// - sequence (int, str): Sequence name, one-based index, or supported sequence selector.
/// - unit (str): Unit used for the returned molecular weight.
/// -> str
#let molweight(sequence, unit: "Da") = {
  let total = 0.0
  for residue in _chars(_clean-residue-string(sequence)) {
    total += _residue-masses.at(residue, default: 0.0)
  }
  if unit == "kDa" or unit == "kda" {
    str(calc.round(total / 10.0) / 100.0)
  } else {
    str(calc.round(total))
  }
}

/// Calculate the approximate net charge of a protein sequence.
///
/// - sequence (int, str): Sequence name, one-based index, or supported sequence selector.
/// - termini (str): Terminal charge convention.
/// -> str
#let charge(sequence, termini: "o") = {
  let total = 0.0
  for residue in _chars(_clean-residue-string(sequence)) {
    total += _peptide-charges.at(residue, default: 0.0)
  }
  let mode = _lower(str(termini))
  if mode == "o" or mode == "n" {
    total += 0.91
  }
  if mode == "o" or mode == "c" {
    total -= 1.0
  }
  str(calc.round(total * 100.0) / 100.0)
}

#let _style-snapshot(config) = {
  let styles = (:)
  for key in config.at("residue-style").keys() {
    let value = config.at("residue-style").at(key)
    styles.insert(key, (
      fg: value.at("fg"),
      bg: value.at("bg"),
      case: value.at("case", default: "upper"),
      style: value.at("style", default: "normal"),
    ))
  }
  let gaps = (:)
  for key in config.at("gaps").keys() {
    gaps.insert(key, config.at("gaps").at(key))
  }
  (residue-style: styles, gaps: gaps)
}

#let _group-list(value) = {
  if type(value) == str {
    return value.split(",").map(group => _upper(group.trim())).filter(group => group != "")
  }
  value.map(group => _upper(str(group).trim())).filter(group => group != "")
}

#let _ref-list(value) = {
  if type(value) == str {
    let out = ()
    for item in value.split(",") {
      let trimmed = item.trim()
      if trimmed == "" {
        continue
      }
      let range-hit = trimmed.matches(regex("^(\\d+)\\-(\\d+)$"))
      if range-hit.len() > 0 {
        let start = int(range-hit.first().captures.at(0))
        let stop = int(range-hit.first().captures.at(1))
        let step = if start <= stop { 1 } else { -1 }
        let current = start
        while current != stop + step {
          out.push(current)
          current += step
        }
      } else {
        out.push(trimmed)
      }
    }
    return out
  }
  if type(value) == array {
    return value
  }
  (value,)
}

#let _type-list(value) = if type(value) == str { value.split(",").map(v => v.trim()).filter(v => v != "") } else { value }

#let _hide-structure-types(config, filetype, types) = {
  let remove = _type-list(types)
  let kept = ()
  for item in config.at("structure-show").at(filetype, default: ()) {
    if not remove.contains(item) {
      kept.push(item)
    }
  }
  config.at("structure-show").insert(filetype, kept)
}

#let _default-config() = {
  let config = (
    threshold: 50,
    allmatch-threshold: 100,
    weight-table: "identity",
    custom-weights: (:),
    gap-penalty: 0,
    residues-per-line: 60,
    auto-layout: (
      fit: none,
      min: 1,
      max: none,
    ),
    auto-page: (
      enabled: false,
      blocks: none,
      repeat-legend: false,
    ),
    font: "DejaVu Sans Mono",
    font-families: (
      serif: "Times New Roman",
      sans: "Arial",
    ),
    font-size: 9pt,
    line-gap: 2pt,
    block-gap: 8pt,
    fixed-block-space: false,
    char-stretch: 1.0,
    numbering-width-digits: 4,
    text-styles: _default-text-styles,
    alignment: "left",
    align-right-labels: false,
    seq-type: none,
    show-leading-gaps: true,
    single-seq-shift: none,
    keep-single-seq-gaps: false,
    hide-residues: false,
    hide-allmatch-positions: false,
    hide-seqs: false,
    no-shade: (),
    sequence-names: (:),
    hidden-names: (),
    hidden-numbers: (),
    sequence-name-colors: (:),
    sequence-number-colors: (:),
    names-color: "Black",
    numbering-color: "Black",
    start-numbers: (:),
    sequence-lengths: (:),
    allow-zero: false,
    stop-char: "*",
    names: ("show": true, "position": "left"),
    numbering: ("show": true, "left": false, "right": true),
    consensus: (
      "show": true,
      "position": "bottom",
      "scale": none,
      "name": "consensus",
      "source": "all",
      "symbols": ("none": "", "conserved": "*", "allmatch": "!"),
      "colors": (
        "none": (fg: "Black", bg: "White"),
        "conserved": (fg: "Black", bg: "White"),
        "allmatch": (fg: "Black", bg: "White"),
      ),
    ),
    ruler: ("show": false, "position": "top", "sequence": 1, "steps": 10, "color": "Black"),
    ruler-colors: ("top": "Black", "bottom": "Black"),
    ruler-names: ("top": "", "bottom": ""),
    ruler-name-colors: ("top": "Black", "bottom": "Black"),
    ruler-labels: ("top": (:), "bottom": (:)),
    ruler-spacing: ("top": 0pt, "bottom": 0pt),
    ruler-rotation: ("top": false, "bottom": false),
    gaps: ("char": ".", "fg": "Black", "bg": "White", "rule-thickness": 0.3pt),
    shading: ("mode": "identical", "option": none, "scheme": "blues", "reference": none),
    shading-schemes: (:),
    tcoffee: ("source": none, "scores": (:)),
    pep-groups: _pep-groups,
    dna-groups: _dna-groups,
    pep-sims: _pep-sims,
    dna-sims: _dna-sims,
    functional-groups: _functional-presets,
    functional-style-overrides: (:),
    functional-default: "charge",
    residue-style: _default-style("identical"),
    cell-styles: (),
    sequence-logo: ("show": false, "position": "top", "colorset": none, "name": "logo", "scale": "leftright", "stretch": 1),
    subfamily-logo: ("show": false, "position": "top", "colorset": none, "name": "subfamily", "negative-name": "remaining", "show-negatives": true),
    logo-scale: ("show": true, "position": "leftright", "color": "Black"),
    logo-colors: ("default": none, "map": (:)),
    relevance: ("show": true, "color": "Black", "char": "*", "threshold": 0.1),
    frequency-correction: false,
    legend: ("show": false, "color": "Black", "dx": 0pt, "dy": 0pt),
    captions: ("top": none, "bottom": none, "short": none),
    separation-lines: (),
    separation-space: 6pt,
    bar-graph-stretch: ("default": 1.0),
    color-scale-stretch: ("default": 1.0),
    feature-style-names: (:),
    feature-text-names: (:),
    feature-style-name-colors: ("default": "Black"),
    feature-text-name-colors: ("default": "Black"),
    feature-slot-spacing: (
      ttttop: 0pt,
      tttop: 0pt,
      ttop: 0pt,
      top: 0pt,
      bottom: 0pt,
      bbottom: 0pt,
      bbbottom: 0pt,
      bbbbottom: 0pt,
    ),
    subfamily: (),
    structure-show: (
      "DSSP": ("alpha", "3-10", "pi", "beta"),
      "STRIDE": ("alpha", "3-10", "pi", "beta"),
      "PHDsec": ("alpha", "beta"),
      "PHDtopo": ("internal", "external", "TM"),
      "HMMTOP": ("TM"),
    ),
    structure-appearance: (
      "PHDtopo:internal": ("position": "bottom", "style": "-", "text": "int."),
      "PHDtopo:external": ("position": "top", "style": ",-,", "text": "ext."),
      "PHDtopo:TM": ("position": "top", "style": "box", "text": "TM"),
      "HMMTOP:internal": ("position": "bottom", "style": "-", "text": "int."),
      "HMMTOP:external": ("position": "top", "style": ",-,", "text": "ext."),
      "HMMTOP:TM": ("position": "top", "style": "helix", "text": "TM"),
      "PHDsec:alpha": ("position": "top", "style": "box", "text": "α\\numcount"),
      "PHDsec:beta": ("position": "top", "style": "-->", "text": "β\\numcount"),
      "STRIDE:alpha": ("position": "top", "style": "box:$\\alpha$\\numcount", "text": ""),
      "STRIDE:3-10": ("position": "top", "style": "fill:$\\circ$", "text": "3-10"),
      "STRIDE:pi": ("position": "top", "style": "---", "text": "π"),
      "STRIDE:beta": ("position": "top", "style": "-->", "text": "β\\numcount"),
      "STRIDE:bridge": ("position": "top", "style": "fill:$\\uparrow$", "text": ""),
      "STRIDE:turn": ("position": "top", "style": ",-,", "text": "turn"),
      "DSSP:alpha": ("position": "top", "style": "box:$\\alpha$\\numcount", "text": ""),
      "DSSP:3-10": ("position": "top", "style": "fill:$\\circ$", "text": "3-10"),
      "DSSP:pi": ("position": "top", "style": "---", "text": "π"),
      "DSSP:beta": ("position": "top", "style": "-->", "text": "β\\numcount"),
      "DSSP:bridge": ("position": "top", "style": "fill:$\\uparrow$", "text": ""),
      "DSSP:turn": ("position": "top", "style": ",-,", "text": "turn"),
      "DSSP:bend": ("position": "top", "style": "fill:$\\diamond$", "text": ""),
    ),
    dssp-second-column: true,
    structure-data: (),
    sequence-windows: (),
    emph-default: "italic",
    tint-default: "normal",
    shade-regions: (),
    tint-regions: (),
    lower-regions: (),
    emph-regions: (),
    frame-regions: (),
    hidden: (),
    killed: (),
    order: none,
    features: (),
    feature-rule: 0.5pt,
    genetic-code: _standard-genetic-code,
    backtranslation: (
      label-style: "alternating",
      label-size: "tiny",
      text-style: "horizontal",
      text-size: "tiny",
    ),
    exported-consensus: none,
  )
  _apply-shading-colors(config, "blues")
  config
}

#let _command(kind, fields) = {
  let out = fields
  out.insert("kind", kind)
  out
}

/// Create the low-level `sequence-type` configuration command.
///
/// - value (any): Value for this setting.
/// -> dictionary
#let sequence-type(value) = _command("sequence-type", (value: value))
/// Create the low-level `scoring-mode` configuration command.
///
/// - mode (str): Combination or scoring mode.
/// - option (any): Optional mode-specific value.
/// -> dictionary
#let scoring-mode(mode, option: none) = _command("scoring-mode", (mode: mode, option: option))
/// Create the low-level `color-scheme` configuration command.
///
/// - name (str, none): Name used by the generated command or rendered element.
/// -> dictionary
#let color-scheme(name) = _command("color-scheme", (name: name))
/// Create the low-level `define-color-scheme` configuration command.
///
/// - name (str, none): Name used by the generated command or rendered element.
/// -> dictionary
#let define-color-scheme(name) = _command("define-color-scheme", (name: name))
/// Create the low-level `threshold` configuration command.
///
/// - value (any): Value for this setting.
/// -> dictionary
#let threshold(value) = _command("threshold", (value: value))
/// Create the low-level `shade-all-residues` configuration command.
/// -> dictionary
#let shade-all-residues() = _command("shade-all-residues", (:))
/// Create the low-level `all-match-threshold` configuration command.
///
/// - value (any): Value for this setting.
/// -> dictionary
#let all-match-threshold(value: 100) = _command("all-match-threshold", (value: value))
/// Create the low-level `disable-all-match-threshold` configuration command.
/// -> dictionary
#let disable-all-match-threshold() = _command("disable-all-match-threshold", (:))
/// Hide all match positions.
/// -> dictionary
#let hide-all-match-positions() = _command("hide-all-match-positions", (:))
/// Show all match positions.
/// -> dictionary
#let show-all-match-positions() = _command("show-all-match-positions", (:))
/// Create the low-level `weight-table` configuration command.
///
/// - name (str, none): Name used by the generated command or rendered element.
/// -> dictionary
#let weight-table(name) = _command("weight-table", (name: name))
/// Create the low-level `set-weight` configuration command.
///
/// - residue-a (int, str): First residue symbol or number.
/// - residue-b (int, str): Second residue symbol or number.
/// - value (any): Value for this setting.
/// -> dictionary
#let set-weight(residue-a, residue-b, value) = _command("set-weight", (residue-a: residue-a, residue-b: residue-b, value: value))
/// Create the low-level `gap-penalty` configuration command.
///
/// - value (any): Value for this setting.
/// -> dictionary
#let gap-penalty(value) = _command("gap-penalty", (value: value))
/// Create the low-level `residues-per-line` configuration command.
///
/// - value (any): Value for this setting.
/// -> dictionary
#let residues-per-line(value) = _command("residues-per-line", (value: value))
/// Create the low-level `auto-layout` configuration command.
///
/// - fit (str, bool, dictionary, none): Container-fitting strategy used by automatic layout.
/// - min (int, float, none): Minimum permitted value.
/// - max (int, float, none): Maximum permitted value, or `none` for no explicit maximum.
/// -> dictionary
#let auto-layout(fit: "container", min: 1, max: none) = _command("auto-layout", (fit: fit, min: min, max: max))
/// Create the low-level `auto-page` configuration command.
///
/// - blocks (int, auto): Alignment blocks per page, or `auto` to calculate the count.
/// - repeat-legend (bool): Whether each automatic page repeats the legend.
/// -> dictionary
#let auto-page(blocks: auto, repeat-legend: true) = _command("auto-page", (blocks: blocks, repeat-legend: repeat-legend))
/// Create a numbering track command.
///
/// - position (str, none): Track side or alignment position to target.
/// - color (color, str, none): Color accepted by Typst or Typshade's named-color resolver.
/// -> dictionary
#let numbering-track(position: "right", color: none) = _command("numbering-track", (position: position, color: color))
/// Disable numbering track.
/// -> dictionary
#let no-numbering-track() = _command("no-numbering-track", (:))
/// Create a names track command.
///
/// - position (str, none): Track side or alignment position to target.
/// - color (color, str, none): Color accepted by Typst or Typshade's named-color resolver.
/// -> dictionary
#let names-track(position: "left", color: none) = _command("names-track", (position: position, color: color))
/// Disable names track.
/// -> dictionary
#let no-names-track() = _command("no-names-track", (:))
/// Create the low-level `sequence-name` configuration command.
///
/// - sequence (int, str): Sequence name, one-based index, or supported sequence selector.
/// - name (str, none): Name used by the generated command or rendered element.
/// -> dictionary
#let sequence-name(sequence, name) = _command("sequence-name", (sequence: sequence, name: name))
/// Create the low-level `names-color` configuration command.
///
/// - color (color, str, none): Color accepted by Typst or Typshade's named-color resolver.
/// -> dictionary
#let names-color(color) = _command("names-color", (color: color))
/// Create the low-level `sequence-name-color` configuration command.
///
/// - sequences (int, str, array): Sequence names, indices, or selectors to target.
/// - color (color, str, none): Color accepted by Typst or Typshade's named-color resolver.
/// -> dictionary
#let sequence-name-color(sequences, color) = _command("sequence-name-color", (sequences: sequences, color: color))
/// Hide sequence name.
///
/// - sequences (int, str, array): Sequence names, indices, or selectors to target.
/// -> dictionary
#let hide-sequence-name(sequences) = _command("hide-sequence-name", (sequences: sequences))
/// Create the low-level `numbering-color` configuration command.
///
/// - color (color, str, none): Color accepted by Typst or Typshade's named-color resolver.
/// -> dictionary
#let numbering-color(color) = _command("numbering-color", (color: color))
/// Create the low-level `sequence-number-color` configuration command.
///
/// - sequences (int, str, array): Sequence names, indices, or selectors to target.
/// - color (color, str, none): Color accepted by Typst or Typshade's named-color resolver.
/// -> dictionary
#let sequence-number-color(sequences, color) = _command("sequence-number-color", (sequences: sequences, color: color))
/// Hide sequence number.
///
/// - sequences (int, str, array): Sequence names, indices, or selectors to target.
/// -> dictionary
#let hide-sequence-number(sequences) = _command("hide-sequence-number", (sequences: sequences))
/// Create a consensus track command.
///
/// - position (str, none): Track side or alignment position to target.
/// - scale (str, dictionary, none): Scale placement or scale configuration.
/// - name (str, none): Name used by the generated command or rendered element.
/// -> dictionary
#let consensus-track(position: "bottom", scale: none, name: none) = _command("consensus-track", (position: position, scale: scale, name: name))
/// Disable consensus track.
/// -> dictionary
#let no-consensus-track() = _command("no-consensus-track", (:))
/// Create the low-level `consensus-name` configuration command.
///
/// - name (str, none): Name used by the generated command or rendered element.
/// -> dictionary
#let consensus-name(name) = _command("consensus-name", (name: name))
/// Create the low-level `language` configuration command.
///
/// - name (str, none): Name used by the generated command or rendered element.
/// -> dictionary
#let language(name) = _command("language", (name: name))
/// Create the low-level `consensus-symbols` configuration command.
///
/// - none-symbol (str): Consensus symbol used for non-conserved columns.
/// - conserved-symbol (str): Consensus symbol used for conserved columns.
/// - allmatch-symbol (str): Consensus symbol used for fully conserved columns.
/// -> dictionary
#let consensus-symbols(none-symbol, conserved-symbol, allmatch-symbol) = _command("consensus-symbols", ("none": none-symbol, conserved: conserved-symbol, allmatch: allmatch-symbol))
/// Create the low-level `consensus-colors` configuration command.
///
/// - none-fg (color, str): Foreground color for non-conserved consensus symbols.
/// - none-bg (color, str): Background color for non-conserved consensus symbols.
/// - conserved-fg (color, str): Foreground color for conserved consensus symbols.
/// - conserved-bg (color, str): Background color for conserved consensus symbols.
/// - allmatch-fg (color, str): Foreground color for fully conserved consensus symbols.
/// - allmatch-bg (color, str): Background color for fully conserved consensus symbols.
/// -> dictionary
#let consensus-colors(none-fg: "Black", none-bg: "White", conserved-fg: "Black", conserved-bg: "White", allmatch-fg: "Black", allmatch-bg: "White") = _command("consensus-colors", (none-fg: none-fg, none-bg: none-bg, conserved-fg: conserved-fg, conserved-bg: conserved-bg, allmatch-fg: allmatch-fg, allmatch-bg: allmatch-bg))
/// Create the low-level `residue-style` configuration command.
///
/// - target (str): Alignment element or residue class to configure.
/// - fg (color, str, none): Foreground color.
/// - bg (color, str, none): Background color.
/// - case (str): Letter case applied to rendered residues.
/// - style (str, dictionary, none): Visual or typographic style.
/// -> dictionary
#let residue-style(target, fg, bg, case: "upper", style: "normal") = _command("residue-style", (target: target, fg: fg, bg: bg, case: case, style: style))
/// Create the low-level `cell-style` configuration command.
///
/// - callback (function): Function called with cell context to return style overrides.
/// -> dictionary
#let cell-style(callback) = _command("cell-style", (callback: callback))
/// Clear functional groups.
/// -> dictionary
#let clear-functional-groups() = _command("clear-functional-groups", (:))
/// Create the low-level `functional-group` configuration command.
///
/// - name (str, none): Name used by the generated command or rendered element.
/// - residues (str, array, arguments): Residue symbols or positions to target.
/// - fg (color, str, none): Foreground color.
/// - bg (color, str, none): Background color.
/// - case (str): Letter case applied to rendered residues.
/// - style (str, dictionary, none): Visual or typographic style.
/// -> dictionary
#let functional-group(name, residues, fg, bg, case: "upper", style: "normal") = _command("functional-group", (name: name, residues: residues, fg: fg, bg: bg, case: case, style: style))
/// Create the low-level `functional-style` configuration command.
///
/// - residue (int, str): Residue symbol or one-based residue number, as appropriate.
/// - fg (color, str, none): Foreground color.
/// - bg (color, str, none): Background color.
/// - case (str): Letter case applied to rendered residues.
/// - style (str, dictionary, none): Visual or typographic style.
/// -> dictionary
#let functional-style(residue, fg, bg, case: "upper", style: "normal") = _command("functional-style", (residue: residue, fg: fg, bg: bg, case: case, style: style))
/// Create a ruler track command.
///
/// - position (str, none): Track side or alignment position to target.
/// - sequence (int, str): Sequence name, one-based index, or supported sequence selector.
/// - steps (int, none): Interval between ruler labels.
/// - color (color, str, none): Color accepted by Typst or Typshade's named-color resolver.
/// -> dictionary
#let ruler-track(position: "top", sequence: 1, steps: none, color: none) = _command("ruler-track", (position: position, sequence: sequence, steps: steps, color: color))
/// Disable ruler track.
///
/// - position (str, none): Track side or alignment position to target.
/// -> dictionary
#let no-ruler-track(position: none) = _command("no-ruler-track", (position: position))
/// Create the low-level `ruler-steps` configuration command.
///
/// - value (any): Value for this setting.
/// - position (str, none): Track side or alignment position to target.
/// -> dictionary
#let ruler-steps(value, position: none) = _command("ruler-steps", (value: value, position: position))
/// Create the low-level `ruler-color` configuration command.
///
/// - color (color, str, none): Color accepted by Typst or Typshade's named-color resolver.
/// - position (str, none): Track side or alignment position to target.
/// -> dictionary
#let ruler-color(color, position: none) = _command("ruler-color", (color: color, position: position))
/// Create the low-level `ruler-name` configuration command.
///
/// - name (str, none): Name used by the generated command or rendered element.
/// - position (str, none): Track side or alignment position to target.
/// -> dictionary
#let ruler-name(name, position: none) = _command("ruler-name", (name: name, position: position))
/// Create the low-level `ruler-name-color` configuration command.
///
/// - color (color, str, none): Color accepted by Typst or Typshade's named-color resolver.
/// - position (str, none): Track side or alignment position to target.
/// -> dictionary
#let ruler-name-color(color, position: none) = _command("ruler-name-color", (color: color, position: position))
/// Create the low-level `ruler-marker` configuration command.
///
/// - number (int): Residue number at which to place the marker.
/// - text (str, content): Text displayed by the generated annotation or label.
/// - position (str, none): Track side or alignment position to target.
/// - color (color, str, none): Color accepted by Typst or Typshade's named-color resolver.
/// -> dictionary
#let ruler-marker(number, text, position: none, color: none) = _command("ruler-marker", (number: number, text: text, position: position, color: color))
/// Create the low-level `ruler-space` configuration command.
///
/// - value (any): Value for this setting.
/// - position (str, none): Track side or alignment position to target.
/// -> dictionary
#let ruler-space(value, position: none) = _command("ruler-space", (value: value, position: position))
/// Create the low-level `rotate-ruler` configuration command.
///
/// - args (arguments): Additional positional or named options forwarded to the command.
/// -> dictionary
#let rotate-ruler(..args) = {
  let positional = args.pos()
  let position = if positional.len() > 0 { positional.first() } else { args.named().at("position", default: none) }
  _command("rotate-ruler", (position: position))
}
/// Create the low-level `unrotate-ruler` configuration command.
///
/// - args (arguments): Additional positional or named options forwarded to the command.
/// -> dictionary
#let unrotate-ruler(..args) = {
  let positional = args.pos()
  let position = if positional.len() > 0 { positional.first() } else { args.named().at("position", default: none) }
  _command("unrotate-ruler", (position: position))
}
/// Create the low-level `gap-char` configuration command.
///
/// - symbol (str): Character used for the configured residue class.
/// -> dictionary
#let gap-char(symbol) = _command("gap-char", (symbol: symbol))
/// Create the low-level `gap-rule` configuration command.
///
/// - thickness (length): Line or rule thickness.
/// -> dictionary
#let gap-rule(thickness) = _command("gap-rule", (thickness: thickness))
/// Create the low-level `gap-colors` configuration command.
///
/// - foreground (color, str, none): Foreground color.
/// - background (color, str, none): Background color.
/// -> dictionary
#let gap-colors(foreground, background) = _command("gap-colors", (foreground: foreground, background: background))
/// Create the low-level `stop-char` configuration command.
///
/// - symbol (str): Character used for the configured residue class.
/// -> dictionary
#let stop-char(symbol) = _command("stop-char", (symbol: symbol))
/// Create the low-level `peptide-groups` configuration command.
///
/// - groups (array, dictionary, none): Optional residue-group definitions.
/// -> dictionary
#let peptide-groups(groups) = _command("peptide-groups", (groups: groups))
/// Create the low-level `dna-groups` configuration command.
///
/// - groups (array, dictionary, none): Optional residue-group definitions.
/// -> dictionary
#let dna-groups(groups) = _command("dna-groups", (groups: groups))
/// Create the low-level `peptide-similarities` configuration command.
///
/// - residue (int, str): Residue symbol or one-based residue number, as appropriate.
/// - similars (str, array): Residues treated as similar to the target residue.
/// -> dictionary
#let peptide-similarities(residue, similars) = _command("peptide-similarities", (residue: residue, similars: similars))
/// Create the low-level `dna-similarities` configuration command.
///
/// - residue (int, str): Residue symbol or one-based residue number, as appropriate.
/// - similars (str, array): Residues treated as similar to the target residue.
/// -> dictionary
#let dna-similarities(residue, similars) = _command("dna-similarities", (residue: residue, similars: similars))
/// Create the low-level `start-number` configuration command.
///
/// - sequence (int, str): Sequence name, one-based index, or supported sequence selector.
/// - start (int, str, none): Inclusive start position or replacement starting number.
/// - selection (str, dictionary, none): Residue range or Selection DSL expression to resolve.
/// -> dictionary
#let start-number(sequence, start, selection: none) = _command("start-number", (sequence: sequence, start: start, selection: selection))
/// Allow zero numbering.
/// -> dictionary
#let allow-zero-numbering() = _command("allow-zero-numbering", (:))
/// Disallow zero numbering.
/// -> dictionary
#let disallow-zero-numbering() = _command("disallow-zero-numbering", (:))
/// Create the low-level `sequence-length` configuration command.
///
/// - sequence (int, str): Sequence name, one-based index, or supported sequence selector.
/// - length (int): Declared sequence length or output extent.
/// -> dictionary
#let sequence-length(sequence, length) = _command("sequence-length", (sequence: sequence, length: length))
/// Create the low-level `sequence-window` configuration command.
///
/// - sequence (int, str): Sequence name, one-based index, or supported sequence selector.
/// - selection (str, dictionary): Residue range or Selection DSL expression to resolve.
/// - start (int, str, none): Inclusive start position or replacement starting number.
/// -> dictionary
#let sequence-window(sequence, selection, start: none) = _command("sequence-window", (sequence: sequence, selection: selection, start: start))
/// Create the low-level `domain` configuration command.
///
/// - sequence (int, str): Sequence name, one-based index, or supported sequence selector.
/// - selection (str, dictionary): Residue range or Selection DSL expression to resolve.
/// -> dictionary
#let domain(sequence, selection) = sequence-window(sequence, selection)
/// Create the low-level `domain-gap-rule` configuration command.
///
/// - thickness (length): Line or rule thickness.
/// -> dictionary
#let domain-gap-rule(thickness) = gap-rule(thickness)
/// Create the low-level `domain-gap-colors` configuration command.
///
/// - foreground (color, str, none): Foreground color.
/// - background (color, str, none): Background color.
/// -> dictionary
#let domain-gap-colors(foreground, background) = gap-colors(foreground, background)
/// Create the low-level `region-highlight` configuration command.
///
/// - sequence (int, str): Sequence name, one-based index, or supported sequence selector.
/// - selection (str, dictionary): Residue range or Selection DSL expression to resolve.
/// - args (arguments): Additional positional or named options forwarded to the command.
/// -> dictionary
#let region-highlight(sequence, selection, ..args) = {
  let positional = args.pos()
  let named = args.named()
  let bg = if positional.len() >= 2 { positional.at(1) } else { named.at("bg", default: none) }
  let fg-or-scheme = if positional.len() >= 1 { positional.at(0) } else { named.at("fg-or-scheme", default: none) }
  let scheme = named.at("scheme", default: none)
  let resolved-scheme = if scheme != none { scheme } else if bg == none { fg-or-scheme } else { none }
  let fg = if bg == none { named.at("fg", default: none) } else { fg-or-scheme }
  _command("region-highlight", (sequence: sequence, selection: selection, scheme: resolved-scheme, fg: fg, bg: bg, all: named.at("apply-to-all", default: false)))
}
/// Create the low-level `highlight-block` configuration command.
///
/// - sequence (int, str): Sequence name, one-based index, or supported sequence selector.
/// - selection (str, dictionary): Residue range or Selection DSL expression to resolve.
/// - args (arguments): Additional positional or named options forwarded to the command.
/// -> dictionary
#let highlight-block(sequence, selection, ..args) = {
  let command = region-highlight(sequence, selection, ..args)
  command.insert("all", args.named().at("apply-to-all", default: true))
  command
}
/// Create the low-level `region-color-scheme` configuration command.
///
/// - sequence (int, str): Sequence name, one-based index, or supported sequence selector.
/// - selection (str, dictionary): Residue range or Selection DSL expression to resolve.
/// - scheme (str, dictionary): Named color scheme.
/// -> dictionary
#let region-color-scheme(sequence, selection, scheme) = region-highlight(sequence, selection, scheme: scheme, apply-to-all: true)
/// Create the low-level `region-tint` configuration command.
///
/// - sequence (int, str): Sequence name, one-based index, or supported sequence selector.
/// - selection (str, dictionary): Residue range or Selection DSL expression to resolve.
/// - intensity (str, int, float): Tint strength.
/// -> dictionary
#let region-tint(sequence, selection, intensity: "medium") = _command("region-tint", (sequence: sequence, selection: selection, intensity: intensity))
/// Create the low-level `tint-block` configuration command.
///
/// - sequence (int, str): Sequence name, one-based index, or supported sequence selector.
/// - selection (str, dictionary): Residue range or Selection DSL expression to resolve.
/// - intensity (str, int, float): Tint strength.
/// -> dictionary
#let tint-block(sequence, selection, intensity: "medium") = region-tint(sequence, selection, intensity: intensity)
/// Create the low-level `tint-default` configuration command.
///
/// - effect (str): Named default tint effect.
/// -> dictionary
#let tint-default(effect) = _command("tint-default", (effect: effect))
/// Create the low-level `region-lower` configuration command.
///
/// - sequence (int, str): Sequence name, one-based index, or supported sequence selector.
/// - selection (str, dictionary): Residue range or Selection DSL expression to resolve.
/// -> dictionary
#let region-lower(sequence, selection) = _command("region-lower", (sequence: sequence, selection: selection))
/// Create the low-level `lower-block` configuration command.
///
/// - sequence (int, str): Sequence name, one-based index, or supported sequence selector.
/// - selection (str, dictionary): Residue range or Selection DSL expression to resolve.
/// -> dictionary
#let lower-block(sequence, selection) = region-lower(sequence, selection)
/// Create the low-level `region-emphasis` configuration command.
///
/// - sequence (int, str): Sequence name, one-based index, or supported sequence selector.
/// - selection (str, dictionary): Residue range or Selection DSL expression to resolve.
/// - style (str, dictionary, none): Visual or typographic style.
/// -> dictionary
#let region-emphasis(sequence, selection, style: "italic") = _command("region-emphasis", (sequence: sequence, selection: selection, style: style))
/// Create the low-level `emphasis-block` configuration command.
///
/// - sequence (int, str): Sequence name, one-based index, or supported sequence selector.
/// - selection (str, dictionary): Residue range or Selection DSL expression to resolve.
/// - style (str, dictionary, none): Visual or typographic style.
/// -> dictionary
#let emphasis-block(sequence, selection, style: "italic") = region-emphasis(sequence, selection, style: style)
/// Create the low-level `emphasis-default` configuration command.
///
/// - style (str, dictionary, none): Visual or typographic style.
/// -> dictionary
#let emphasis-default(style) = _command("emphasis-default", (style: style))
/// Create the low-level `frame-block` configuration command.
///
/// - sequence (int, str): Sequence name, one-based index, or supported sequence selector.
/// - selection (str, dictionary): Residue range or Selection DSL expression to resolve.
/// - color (color, str, none): Color accepted by Typst or Typshade's named-color resolver.
/// -> dictionary
#let frame-block(sequence, selection, color: "Red") = _command("frame-block", (sequence: sequence, selection: selection, color: color))
/// Hide sequence.
///
/// - sequence (int, str): Sequence name, one-based index, or supported sequence selector.
/// -> dictionary
#let hide-sequence(sequence) = _command("hide-sequence", (sequence: sequence))
/// Hide all sequences.
/// -> dictionary
#let hide-all-sequences() = _command("hide-all-sequences", (:))
/// Show all sequences.
/// -> dictionary
#let show-all-sequences() = _command("show-all-sequences", (:))
/// Create the low-level `remove-sequence` configuration command.
///
/// - sequence (int, str): Sequence name, one-based index, or supported sequence selector.
/// -> dictionary
#let remove-sequence(sequence) = _command("remove-sequence", (sequence: sequence))
/// Disable shade.
///
/// - sequences (int, str, array): Sequence names, indices, or selectors to target.
/// -> dictionary
#let no-shade(sequences) = _command("no-shade", (sequences: sequences))
/// Create the low-level `separation-line` configuration command.
///
/// - sequence (int, str): Sequence name, one-based index, or supported sequence selector.
/// -> dictionary
#let separation-line(sequence) = _command("separation-line", (sequence: sequence))
/// Create the low-level `sequence-order` configuration command.
///
/// - order (array): Sequence order expressed as names or one-based indices.
/// -> dictionary
#let sequence-order(order) = _command("sequence-order", (order: order))
/// Create the low-level `feature` configuration command.
///
/// - position (str, none): Track side or alignment position to target.
/// - sequence (int, str): Sequence name, one-based index, or supported sequence selector.
/// - selection (str, dictionary): Residue range or Selection DSL expression to resolve.
/// - style (str, dictionary, none): Visual or typographic style.
/// - text (str, content): Text displayed by the generated annotation or label.
/// -> dictionary
#let feature(position, sequence, selection, style: "", text: "") = _command("feature", (position: position, sequence: sequence, selection: selection, style: style, text: text))
/// Create the low-level `feature-rule` configuration command.
///
/// - thickness (length): Line or rule thickness.
/// -> dictionary
#let feature-rule(thickness) = _command("feature-rule", (thickness: thickness))
/// Create the low-level `codon` configuration command.
///
/// - residue (int, str): Residue symbol or one-based residue number, as appropriate.
/// - triplets (str, array): Comma-separated codons assigned to the residue.
/// -> dictionary
#let codon(residue, triplets) = _command("codon", (residue: residue, triplets: triplets))
/// Create the low-level `genetic-code` configuration command.
///
/// - name (str, none): Name used by the generated command or rendered element.
/// -> dictionary
#let genetic-code(name) = _command("genetic-code", (name: name))
/// Create the low-level `backtranslation-label` configuration command.
///
/// - args (arguments): Additional positional or named options forwarded to the command.
/// -> dictionary
#let backtranslation-label(..args) = {
  let positional = args.pos()
  let style = if positional.len() > 0 { positional.last() } else { args.named().at("style", default: "alternating") }
  let size = args.named().at("size", default: "tiny")
  _command("backtranslation-label", (style: style, size: size))
}
/// Create the low-level `backtranslation-text` configuration command.
///
/// - args (arguments): Additional positional or named options forwarded to the command.
/// -> dictionary
#let backtranslation-text(..args) = {
  let positional = args.pos()
  let style = if positional.len() > 0 { positional.last() } else { args.named().at("style", default: "horizontal") }
  let size = args.named().at("size", default: "tiny")
  _command("backtranslation-text", (style: style, size: size))
}
/// Create the low-level `feature-text-label` configuration command.
///
/// - position (str, none): Track side or alignment position to target.
/// - name (str, none): Name used by the generated command or rendered element.
/// -> dictionary
#let feature-text-label(position, name) = _command("feature-text-label", (position: position, name: name))
/// Create the low-level `feature-style-label` configuration command.
///
/// - position (str, none): Track side or alignment position to target.
/// - name (str, none): Name used by the generated command or rendered element.
/// -> dictionary
#let feature-style-label(position, name) = _command("feature-style-label", (position: position, name: name))
/// Hide feature text label.
///
/// - position (str, none): Track side or alignment position to target.
/// -> dictionary
#let hide-feature-text-label(position) = _command("hide-feature-text-label", (position: position))
/// Hide feature style label.
///
/// - position (str, none): Track side or alignment position to target.
/// -> dictionary
#let hide-feature-style-label(position) = _command("hide-feature-style-label", (position: position))
/// Hide feature text labels.
/// -> dictionary
#let hide-feature-text-labels() = _command("hide-feature-text-labels", (:))
/// Hide feature style labels.
/// -> dictionary
#let hide-feature-style-labels() = _command("hide-feature-style-labels", (:))
/// Create the low-level `feature-text-label-color` configuration command.
///
/// - color (color, str, none): Color accepted by Typst or Typshade's named-color resolver.
/// -> dictionary
#let feature-text-label-color(color) = _command("feature-text-label-color", (color: color))
/// Create the low-level `feature-style-label-color` configuration command.
///
/// - color (color, str, none): Color accepted by Typst or Typshade's named-color resolver.
/// -> dictionary
#let feature-style-label-color(color) = _command("feature-style-label-color", (color: color))
/// Create the low-level `feature-text-label-color-at` configuration command.
///
/// - position (str, none): Track side or alignment position to target.
/// - color (color, str, none): Color accepted by Typst or Typshade's named-color resolver.
/// -> dictionary
#let feature-text-label-color-at(position, color) = _command("feature-text-label-color-at", (position: position, color: color))
/// Create the low-level `feature-style-label-color-at` configuration command.
///
/// - position (str, none): Track side or alignment position to target.
/// - color (color, str, none): Color accepted by Typst or Typshade's named-color resolver.
/// -> dictionary
#let feature-style-label-color-at(position, color) = _command("feature-style-label-color-at", (position: position, color: color))
/// Create the low-level `tcoffee-scores` configuration command.
///
/// - source (any): Input data, text, bytes, or a path accepted by the selected parser.
/// -> dictionary
#let tcoffee-scores(source) = _command("tcoffee-scores", (source: source))
/// Create a sequence logo track command.
///
/// - position (str, none): Track side or alignment position to target.
/// - colorset (str, array, dictionary, none): Named or explicit residue color set.
/// -> dictionary
#let sequence-logo-track(position: "top", colorset: none) = _command("sequence-logo-track", (position: position, colorset: colorset))
/// Disable sequence logo track.
/// -> dictionary
#let no-sequence-logo-track() = _command("no-sequence-logo-track", (:))
/// Create the low-level `frequency-correction` configuration command.
/// -> dictionary
#let frequency-correction() = _command("frequency-correction", (:))
/// Disable frequency correction.
/// -> dictionary
#let no-frequency-correction() = _command("no-frequency-correction", (:))
/// Create the low-level `subfamily` configuration command.
///
/// - sequences (int, str, array): Sequence names, indices, or selectors to target.
/// -> dictionary
#let subfamily(sequences) = _command("subfamily", (sequences: sequences))
/// Create a subfamily logo track command.
///
/// - position (str, none): Track side or alignment position to target.
/// - colorset (str, array, dictionary, none): Named or explicit residue color set.
/// -> dictionary
#let subfamily-logo-track(position: "top", colorset: none) = _command("subfamily-logo-track", (position: position, colorset: colorset))
/// Disable subfamily logo track.
/// -> dictionary
#let no-subfamily-logo-track() = _command("no-subfamily-logo-track", (:))
/// Create the low-level `sequence-logo-name` configuration command.
///
/// - name (str, none): Name used by the generated command or rendered element.
/// -> dictionary
#let sequence-logo-name(name) = _command("sequence-logo-name", (name: name))
/// Create the low-level `subfamily-logo-name` configuration command.
///
/// - name (str, none): Name used by the generated command or rendered element.
/// - negative-name (str, none): Optional label for the negative subfamily logo.
/// -> dictionary
#let subfamily-logo-name(name, negative-name: none) = _command("subfamily-logo-name", (name: name, negative-name: negative-name))
/// Create the low-level `logo-scale` configuration command.
///
/// - position (str, none): Track side or alignment position to target.
/// - color (color, str, none): Color accepted by Typst or Typshade's named-color resolver.
/// -> dictionary
#let logo-scale(position: "leftright", color: "Black") = _command("logo-scale", (position: position, color: color))
/// Disable logo scale.
/// -> dictionary
#let no-logo-scale() = _command("no-logo-scale", (:))
/// Create the low-level `logo-stretch` configuration command.
///
/// - value (any): Value for this setting.
/// -> dictionary
#let logo-stretch(value) = _command("logo-stretch", (value: value))
/// Create the low-level `negative-logo-values` configuration command.
/// -> dictionary
#let negative-logo-values() = _command("negative-logo-values", (:))
/// Disable negative logo values.
/// -> dictionary
#let no-negative-logo-values() = _command("no-negative-logo-values", (:))
/// Create the low-level `relevance-threshold` configuration command.
///
/// - value (any): Value for this setting.
/// -> dictionary
#let relevance-threshold(value) = _command("relevance-threshold", (value: value))
/// Create the low-level `relevance-marker` configuration command.
///
/// - char (str): Character used by the marker.
/// - color (color, str, none): Color accepted by Typst or Typshade's named-color resolver.
/// -> dictionary
#let relevance-marker(char: "*", color: "Black") = _command("relevance-marker", (char: char, color: color))
/// Disable relevance marker.
/// -> dictionary
#let no-relevance-marker() = _command("no-relevance-marker", (:))
/// Create the low-level `logo-color` configuration command.
///
/// - residues (str, array, arguments): Residue symbols or positions to target.
/// - color (color, str, none): Color accepted by Typst or Typshade's named-color resolver.
/// -> dictionary
#let logo-color(residues, color) = _command("logo-color", (residues: residues, color: color))
/// Clear logo colors.
///
/// - default (any): Default value used when no explicit override matches.
/// -> dictionary
#let clear-logo-colors(default: "Black") = _command("clear-logo-colors", (default: default))
/// Create a legend track command.
///
/// - color (color, str, none): Color accepted by Typst or Typshade's named-color resolver.
/// -> dictionary
#let legend-track(color: "Black") = _command("legend-track", (color: color))
/// Disable legend track.
/// -> dictionary
#let no-legend-track() = _command("no-legend-track", (:))
/// Create the low-level `legend-color` configuration command.
///
/// - color (color, str, none): Color accepted by Typst or Typshade's named-color resolver.
/// -> dictionary
#let legend-color(color) = _command("legend-color", (color: color))
/// Create the low-level `legend-offset` configuration command.
///
/// - dx (length): Horizontal legend offset.
/// - dy (length): Vertical legend offset.
/// -> dictionary
#let legend-offset(dx, dy) = _command("legend-offset", (dx: dx, dy: dy))
/// Create the low-level `color-swatch` configuration command.
///
/// - color (color, str, none): Color accepted by Typst or Typshade's named-color resolver.
/// -> content
#let color-swatch(color) = box(width: 10pt, height: 10pt, fill: resolve-color(color), stroke: none)[]
/// Show structure types.
///
/// - format (str, auto): Input format, or `auto` to detect it.
/// - types (str, array): Structural annotation types to show or hide.
/// -> dictionary
#let show-structure-types(format, types) = _command("show-structure-types", (format: format, types: types))
/// Hide structure types.
///
/// - format (str, auto): Input format, or `auto` to detect it.
/// - types (str, array): Structural annotation types to show or hide.
/// -> dictionary
#let hide-structure-types(format, types) = _command("hide-structure-types", (format: format, types: types))
/// Create the low-level `structure-appearance` configuration command.
///
/// - format (str, auto): Input format, or `auto` to detect it.
/// - structure-type (str): Structural annotation type to configure.
/// - position (str, none): Track side or alignment position to target.
/// - style (str, dictionary, none): Visual or typographic style.
/// - text (str, content): Text displayed by the generated annotation or label.
/// -> dictionary
#let structure-appearance(format, structure-type, position, style, text) = _command("structure-appearance", (format: format, structure-type: structure-type, position: position, style: style, text: text))
/// Use the first dssp column.
/// -> dictionary
#let use-first-dssp-column() = _command("use-first-dssp-column", (:))
/// Use the second dssp column.
/// -> dictionary
#let use-second-dssp-column() = _command("use-second-dssp-column", (:))
/// Create a stride track command.
///
/// - sequence (int, str): Sequence name, one-based index, or supported sequence selector.
/// - source (any): Input data, text, bytes, or a path accepted by the selected parser.
/// -> dictionary
#let stride-track(sequence, source) = _command("stride-track", (sequence: sequence, source: source))
/// Create a dssp track command.
///
/// - sequence (int, str): Sequence name, one-based index, or supported sequence selector.
/// - source (any): Input data, text, bytes, or a path accepted by the selected parser.
/// -> dictionary
#let dssp-track(sequence, source) = _command("dssp-track", (sequence: sequence, source: source))
/// Create a hmmtop track command.
///
/// - sequence (int, str): Sequence name, one-based index, or supported sequence selector.
/// - source (any): Input data, text, bytes, or a path accepted by the selected parser.
/// - source-sequence (str, none): Sequence identifier represented by the annotation source.
/// -> dictionary
#let hmmtop-track(sequence, source, source-sequence: none) = _command("hmmtop-track", (sequence: sequence, source: source, source-sequence: source-sequence))
/// Create a phd topology track command.
///
/// - sequence (int, str): Sequence name, one-based index, or supported sequence selector.
/// - source (any): Input data, text, bytes, or a path accepted by the selected parser.
/// -> dictionary
#let phd-topology-track(sequence, source) = _command("phd-topology-track", (sequence: sequence, source: source))
/// Create a phd secondary track command.
///
/// - sequence (int, str): Sequence name, one-based index, or supported sequence selector.
/// - source (any): Input data, text, bytes, or a path accepted by the selected parser.
/// -> dictionary
#let phd-secondary-track(sequence, source) = _command("phd-secondary-track", (sequence: sequence, source: source))
/// Create the low-level `consensus-from-sequence` configuration command.
///
/// - sequence (int, str): Sequence name, one-based index, or supported sequence selector.
/// -> dictionary
#let consensus-from-sequence(sequence) = _command("consensus-from-sequence", (sequence: sequence))
/// Create the low-level `consensus-from-all-sequences` configuration command.
/// -> dictionary
#let consensus-from-all-sequences() = _command("consensus-from-all-sequences", (:))
/// Show leading gaps.
/// -> dictionary
#let show-leading-gaps() = _command("show-leading-gaps", (:))
/// Hide leading gaps.
/// -> dictionary
#let hide-leading-gaps() = _command("hide-leading-gaps", (:))
/// Create the low-level `shift-single-sequence` configuration command.
///
/// - args (arguments): Additional positional or named options forwarded to the command.
/// -> dictionary
#let shift-single-sequence(..args) = {
  let positional = args.pos()
  let value = if positional.len() > 0 { positional.first() } else { args.named().at("value", default: -1) }
  _command("shift-single-sequence", (value: value))
}
/// Create the low-level `keep-single-sequence-gaps` configuration command.
/// -> dictionary
#let keep-single-sequence-gaps() = _command("keep-single-sequence-gaps", (:))
/// Hide residues.
/// -> dictionary
#let hide-residues() = _command("hide-residues", (:))
/// Show residues.
/// -> dictionary
#let show-residues() = _command("show-residues", (:))
/// Create the low-level `bar-graph-stretch` configuration command.
///
/// - value (any): Value for this setting.
/// - position (str, none): Track side or alignment position to target.
/// -> dictionary
#let bar-graph-stretch(value, position: none) = _command("bar-graph-stretch", (value: value, position: position))
/// Create the low-level `color-scale-stretch` configuration command.
///
/// - value (any): Value for this setting.
/// - position (str, none): Track side or alignment position to target.
/// -> dictionary
#let color-scale-stretch(value, position: none) = _command("color-scale-stretch", (value: value, position: position))
/// Create the low-level `alignment` configuration command.
///
/// - position (str, none): Track side or alignment position to target.
/// -> dictionary
#let alignment(position) = _command("alignment", (position: position))
/// Create the low-level `character-stretch` configuration command.
///
/// - value (any): Value for this setting.
/// -> dictionary
#let character-stretch(value) = _command("character-stretch", (value: value))
/// Create the low-level `line-stretch` configuration command.
///
/// - value (any): Value for this setting.
/// -> dictionary
#let line-stretch(value) = _command("line-stretch", (value: value))
/// Create the low-level `numbering-width` configuration command.
///
/// - digits (int): Reserved width in decimal digits.
/// -> dictionary
#let numbering-width(digits) = _command("numbering-width", (digits: digits))
/// Create the low-level `fingerprint` configuration command.
///
/// - value (any): Value for this setting.
/// -> dictionary
#let fingerprint(value) = _command("fingerprint", (value: value))
/// Create the low-level `align-right-labels` configuration command.
/// -> dictionary
#let align-right-labels() = _command("align-right-labels", (:))
/// Create the low-level `align-left-labels` configuration command.
/// -> dictionary
#let align-left-labels() = _command("align-left-labels", (:))
/// Create the low-level `text-family` configuration command.
///
/// - target (str): Alignment element or residue class to configure.
/// - family (str, array): Font family.
/// -> dictionary
#let text-family(target, family) = _command("text-family", (target: target, value: family))
/// Create the low-level `text-weight` configuration command.
///
/// - target (str): Alignment element or residue class to configure.
/// - weight (str, int): Font weight.
/// -> dictionary
#let text-weight(target, weight) = _command("text-weight", (target: target, value: weight))
/// Create the low-level `text-posture` configuration command.
///
/// - target (str): Alignment element or residue class to configure.
/// - posture (str): Font posture.
/// -> dictionary
#let text-posture(target, posture) = _command("text-posture", (target: target, value: posture))
/// Create the low-level `text-size` configuration command.
///
/// - target (str): Alignment element or residue class to configure.
/// - size (length): Text size.
/// -> dictionary
#let text-size(target, size) = _command("text-size", (target: target, value: size))
/// Create the low-level `text-style` configuration command.
///
/// - target (str): Alignment element or residue class to configure.
/// - family (str, array): Font family.
/// - weight (str, int): Font weight.
/// - posture (str): Font posture.
/// - size (length): Text size.
/// -> dictionary
#let text-style(target, family, weight, posture, size) = _command("text-style", (target: target, family: family, weight: weight, posture: posture, size: size))
/// Create the low-level `caption` configuration command.
///
/// - text (str, content): Text displayed by the generated annotation or label.
/// - position (str, none): Track side or alignment position to target.
/// -> dictionary
#let caption(text, position: "bottom") = _command("caption", (text: text, position: position))
/// Create the low-level `short-caption` configuration command.
///
/// - text (str, content): Text displayed by the generated annotation or label.
/// -> dictionary
#let short-caption(text) = _command("short-caption", (text: text))
/// Create the low-level `small-separator` configuration command.
/// -> dictionary
#let small-separator() = _command("separator-space", (value: 3pt))
/// Create the low-level `medium-separator` configuration command.
/// -> dictionary
#let medium-separator() = _command("separator-space", (value: 6pt))
/// Create the low-level `large-separator` configuration command.
/// -> dictionary
#let large-separator() = _command("separator-space", (value: 12pt))
/// Create the low-level `export-consensus` configuration command.
///
/// - sequence (int, str): Sequence name, one-based index, or supported sequence selector.
/// - filename (str): Path used to write the exported consensus.
/// - format (str, auto): Input format, or `auto` to detect it.
/// -> dictionary
#let export-consensus(sequence, filename, format: "chimera") = _command("export-consensus", (sequence: sequence, filename: filename, format: format))
/// Create a command from a PDB geometry selection.
///
/// - selection (str, dictionary): Residue range or Selection DSL expression to resolve.
/// -> dictionary
#let pdb-selection(selection) = pdb-selection-list(selection)
/// Disable block gap.
/// -> dictionary
#let no-block-gap() = _command("block-gap", (value: 0pt))
/// Create the low-level `small-block-gap` configuration command.
/// -> dictionary
#let small-block-gap() = _command("block-gap-factor", (value: 1.0))
/// Create the low-level `medium-block-gap` configuration command.
/// -> dictionary
#let medium-block-gap() = _command("block-gap-factor", (value: 1.5))
/// Create the low-level `large-block-gap` configuration command.
/// -> dictionary
#let large-block-gap() = _command("block-gap-factor", (value: 2.0))
/// Create the low-level `block-gap` configuration command.
///
/// - value (any): Value for this setting.
/// -> dictionary
#let block-gap(value) = _command("block-gap", (value: value))
/// Create the low-level `flexible-block-gap` configuration command.
/// -> dictionary
#let flexible-block-gap() = _command("block-space-mode", (fixed: false))
/// Create the low-level `fixed-block-gap` configuration command.
/// -> dictionary
#let fixed-block-gap() = _command("block-space-mode", (fixed: true))
/// Disable line gap.
/// -> dictionary
#let no-line-gap() = _command("line-gap", (value: 0pt))
/// Create the low-level `small-line-gap` configuration command.
/// -> dictionary
#let small-line-gap() = _command("line-gap", (value: 3pt))
/// Create the low-level `medium-line-gap` configuration command.
/// -> dictionary
#let medium-line-gap() = _command("line-gap", (value: 6pt))
/// Create the low-level `large-line-gap` configuration command.
/// -> dictionary
#let large-line-gap() = _command("line-gap", (value: 12pt))
/// Create the low-level `line-gap` configuration command.
///
/// - value (any): Value for this setting.
/// -> dictionary
#let line-gap(value) = _command("line-gap", (value: value))
/// Create the low-level `feature-slot-space` configuration command.
///
/// - position (str, none): Track side or alignment position to target.
/// - value (any): Value for this setting.
/// -> dictionary
#let feature-slot-space(position, value) = _command("feature-slot-space", (position: position, value: value))

#let _apply-command(config, command) = {
  let kind = command.at("kind")
  if kind == "sequence-type" {
    config.insert("seq-type", _upper(str(command.at("value"))))
  } else if kind == "scoring-mode" {
    config.at("shading").insert("mode", command.at("mode"))
    config.at("shading").insert("option", command.at("option"))
    if command.at("mode") == "diverse" or command.at("mode") == "singleseq" {
      let reference = command.at("option", default: none)
      config.at("shading").insert("reference", if reference == none { 1 } else { reference })
    } else if command.at("mode") == "T-Coffee" and command.at("option") != none {
      config.at("tcoffee").insert("source", command.at("option"))
      config.at("tcoffee").insert("scores", read-tcoffee(command.at("option")))
    }
  } else if kind == "color-scheme" {
    config.at("shading").insert("scheme", command.at("name"))
    _apply-shading-colors(config, command.at("name"))
  } else if kind == "define-color-scheme" {
    config.at("shading-schemes").insert(command.at("name"), _style-snapshot(config))
  } else if kind == "tcoffee-scores" {
    config.at("tcoffee").insert("source", command.at("source"))
    config.at("tcoffee").insert("scores", read-tcoffee(command.at("source")))
  } else if kind == "sequence-logo-track" {
    config.at("sequence-logo").insert("show", true)
    config.at("sequence-logo").insert("position", command.at("position"))
    config.at("sequence-logo").insert("colorset", command.at("colorset"))
  } else if kind == "no-sequence-logo-track" {
    config.at("sequence-logo").insert("show", false)
  } else if kind == "frequency-correction" {
    config.insert("frequency-correction", true)
  } else if kind == "no-frequency-correction" {
    config.insert("frequency-correction", false)
  } else if kind == "subfamily" {
    config.insert("subfamily", command.at("sequences"))
  } else if kind == "subfamily-logo-track" {
    config.at("subfamily-logo").insert("show", true)
    config.at("subfamily-logo").insert("position", command.at("position"))
    config.at("subfamily-logo").insert("colorset", command.at("colorset"))
  } else if kind == "no-subfamily-logo-track" {
    config.at("subfamily-logo").insert("show", false)
  } else if kind == "sequence-logo-name" {
    config.at("sequence-logo").insert("name", command.at("name"))
  } else if kind == "subfamily-logo-name" {
    config.at("subfamily-logo").insert("name", command.at("name"))
    if command.at("negative-name") != none {
      config.at("subfamily-logo").insert("negative-name", command.at("negative-name"))
    }
  } else if kind == "logo-scale" {
    config.at("logo-scale").insert("show", true)
    config.at("logo-scale").insert("position", command.at("position"))
    config.at("logo-scale").insert("color", command.at("color"))
  } else if kind == "no-logo-scale" {
    config.at("logo-scale").insert("show", false)
  } else if kind == "logo-stretch" {
    config.at("sequence-logo").insert("stretch", command.at("value"))
  } else if kind == "negative-logo-values" {
    config.at("subfamily-logo").insert("show-negatives", true)
  } else if kind == "no-negative-logo-values" {
    config.at("subfamily-logo").insert("show-negatives", false)
  } else if kind == "relevance-threshold" {
    config.at("relevance").insert("threshold", command.at("value"))
  } else if kind == "relevance-marker" {
    config.at("relevance").insert("show", true)
    config.at("relevance").insert("char", command.at("char"))
    config.at("relevance").insert("color", command.at("color"))
  } else if kind == "no-relevance-marker" {
    config.at("relevance").insert("show", false)
  } else if kind == "logo-color" {
    for residue in _chars(command.at("residues")) {
      config.at("logo-colors").at("map").insert(_upper(residue), command.at("color"))
    }
  } else if kind == "clear-logo-colors" {
    config.at("logo-colors").insert("default", command.at("default"))
    config.at("logo-colors").insert("map", (:))
  } else if kind == "legend-track" {
    config.at("legend").insert("show", true)
    config.at("legend").insert("color", command.at("color"))
  } else if kind == "no-legend-track" {
    config.at("legend").insert("show", false)
  } else if kind == "legend-color" {
    config.at("legend").insert("color", command.at("color"))
  } else if kind == "legend-offset" {
    config.at("legend").insert("dx", command.at("dx"))
    config.at("legend").insert("dy", command.at("dy"))
  } else if kind == "show-structure-types" {
    config.at("structure-show").insert(command.at("format"), _type-list(command.at("types")))
  } else if kind == "hide-structure-types" {
    _hide-structure-types(config, command.at("format"), command.at("types"))
  } else if kind == "structure-appearance" {
    config.at("structure-appearance").insert(command.at("format") + ":" + command.at("structure-type"), ("position": command.at("position"), "style": command.at("style"), "text": command.at("text")))
  } else if kind == "use-first-dssp-column" {
    config.insert("dssp-second-column", false)
  } else if kind == "use-second-dssp-column" {
    config.insert("dssp-second-column", true)
  } else if kind == "stride-track" {
    config.at("structure-data").push(("kind": "STRIDE", "sequence": command.at("sequence"), "data": read-stride(command.at("source"))))
  } else if kind == "dssp-track" {
    config.at("structure-data").push(("kind": "DSSP", "sequence": command.at("sequence"), "data": read-dssp(command.at("source"), use-second-column: config.at("dssp-second-column"))))
  } else if kind == "hmmtop-track" {
    config.at("structure-data").push(("kind": "HMMTOP", "sequence": command.at("sequence"), "data": read-hmmtop(command.at("source"), sequence: command.at("source-sequence", default: none))))
  } else if kind == "phd-topology-track" {
    config.at("structure-data").push(("kind": "PHDtopo", "sequence": command.at("sequence"), "data": read-phd-topology(command.at("source"))))
  } else if kind == "phd-secondary-track" {
    config.at("structure-data").push(("kind": "PHDsec", "sequence": command.at("sequence"), "data": read-phd-secondary(command.at("source"))))
  } else if kind == "threshold" {
    config.insert("threshold", command.at("value"))
  } else if kind == "shade-all-residues" {
    config.insert("threshold", 0)
  } else if kind == "all-match-threshold" {
    config.insert("allmatch-threshold", command.at("value"))
  } else if kind == "disable-all-match-threshold" {
    config.insert("allmatch-threshold", 101)
  } else if kind == "hide-all-match-positions" {
    config.insert("hide-allmatch-positions", true)
  } else if kind == "show-all-match-positions" {
    config.insert("hide-allmatch-positions", false)
  } else if kind == "weight-table" {
    let name = str(command.at("name"))
    config.insert("weight-table", name)
    if name == "PAM250" {
      config.insert("gap-penalty", -8)
    } else if name == "PAM100" {
      config.insert("gap-penalty", -9)
    } else {
      config.insert("gap-penalty", 0)
    }
  } else if kind == "set-weight" {
    let a = _upper(str(command.at("residue-a")))
    let b = _upper(str(command.at("residue-b")))
    config.at("custom-weights").insert(a + ":" + b, command.at("value"))
    config.at("custom-weights").insert(b + ":" + a, command.at("value"))
  } else if kind == "gap-penalty" {
    config.insert("gap-penalty", command.at("value"))
  } else if kind == "residues-per-line" {
    config.insert("residues-per-line", command.at("value"))
  } else if kind == "auto-layout" {
    config.at("auto-layout").insert("fit", command.at("fit"))
    config.at("auto-layout").insert("min", command.at("min"))
    config.at("auto-layout").insert("max", command.at("max"))
    if command.at("fit") != none and command.at("fit") != false {
      config.insert("residues-per-line", auto)
    }
  } else if kind == "auto-page" {
    config.at("auto-page").insert("enabled", true)
    config.at("auto-page").insert("blocks", command.at("blocks"))
    config.at("auto-page").insert("repeat-legend", command.at("repeat-legend"))
  } else if kind == "numbering-track" {
    let pos = command.at("position")
    config.at("numbering").insert("show", true)
    config.at("numbering").insert("left", pos == "left" or pos == "leftright")
    config.at("numbering").insert("right", pos == "right" or pos == "leftright")
    if command.at("color") != none {
      config.insert("numbering-color", command.at("color"))
    }
  } else if kind == "no-numbering-track" {
    config.at("numbering").insert("show", false)
  } else if kind == "names-track" {
    config.at("names").insert("show", true)
    config.at("names").insert("position", command.at("position"))
    if command.at("color") != none {
      config.insert("names-color", command.at("color"))
    }
  } else if kind == "no-names-track" {
    config.at("names").insert("show", false)
  } else if kind == "sequence-name" {
    config.at("sequence-names").insert(str(command.at("sequence")), command.at("name"))
  } else if kind == "names-color" {
    config.insert("names-color", command.at("color"))
  } else if kind == "sequence-name-color" {
    for ref in _ref-list(command.at("sequences")) {
      config.at("sequence-name-colors").insert(str(ref), command.at("color"))
    }
  } else if kind == "hide-sequence-name" {
    for ref in _ref-list(command.at("sequences")) {
      config.at("hidden-names").push(ref)
    }
  } else if kind == "numbering-color" {
    config.insert("numbering-color", command.at("color"))
  } else if kind == "sequence-number-color" {
    for ref in _ref-list(command.at("sequences")) {
      config.at("sequence-number-colors").insert(str(ref), command.at("color"))
    }
  } else if kind == "hide-sequence-number" {
    for ref in _ref-list(command.at("sequences")) {
      config.at("hidden-numbers").push(ref)
    }
  } else if kind == "consensus-track" {
    config.at("consensus").insert("show", true)
    config.at("consensus").insert("position", command.at("position"))
    config.at("consensus").insert("scale", command.at("scale"))
    if command.at("name") != none {
      config.at("consensus").insert("name", command.at("name"))
    }
  } else if kind == "no-consensus-track" {
    config.at("consensus").insert("show", false)
  } else if kind == "consensus-name" {
    config.at("consensus").insert("name", command.at("name"))
  } else if kind == "language" {
    let name = command.at("name")
    config.at("consensus").insert("name", if name == "german" { "Konsensus" } else if name == "spanish" { "consenso" } else { "consensus" })
  } else if kind == "consensus-symbols" {
    config.at("consensus").insert("symbols", ("none": command.at("none"), "conserved": command.at("conserved"), "allmatch": command.at("allmatch")))
  } else if kind == "consensus-colors" {
    config.at("consensus").insert("colors", (
      "none": (fg: command.at("none-fg"), bg: command.at("none-bg")),
      "conserved": (fg: command.at("conserved-fg"), bg: command.at("conserved-bg")),
      "allmatch": (fg: command.at("allmatch-fg"), bg: command.at("allmatch-bg")),
    ))
  } else if kind == "ruler-track" {
    config.at("ruler").insert("show", true)
    config.at("ruler").insert("position", command.at("position"))
    config.at("ruler").insert("sequence", command.at("sequence"))
    if command.at("steps") != none {
      config.at("ruler").insert("steps", command.at("steps"))
    }
    if command.at("color") != none {
      config.at("ruler").insert("color", command.at("color"))
      config.at("ruler-colors").insert("top", command.at("color"))
      config.at("ruler-colors").insert("bottom", command.at("color"))
    }
  } else if kind == "no-ruler-track" {
    let pos = command.at("position")
    if pos == none or pos == config.at("ruler").at("position") {
      config.at("ruler").insert("show", false)
    }
  } else if kind == "ruler-steps" {
    let pos = command.at("position")
    if pos == none or pos == config.at("ruler").at("position") {
      config.at("ruler").insert("steps", command.at("value"))
    }
  } else if kind == "ruler-color" {
    let pos = command.at("position")
    if pos == none {
      config.at("ruler").insert("color", command.at("color"))
      config.at("ruler-colors").insert("top", command.at("color"))
      config.at("ruler-colors").insert("bottom", command.at("color"))
    } else {
      config.at("ruler-colors").insert(pos, command.at("color"))
    }
  } else if kind == "ruler-name" {
    let pos = command.at("position")
    if pos == none {
      config.at("ruler-names").insert("top", command.at("name"))
      config.at("ruler-names").insert("bottom", command.at("name"))
    } else {
      config.at("ruler-names").insert(pos, command.at("name"))
    }
  } else if kind == "ruler-name-color" {
    let pos = command.at("position")
    if pos == none {
      config.at("ruler-name-colors").insert("top", command.at("color"))
      config.at("ruler-name-colors").insert("bottom", command.at("color"))
    } else {
      config.at("ruler-name-colors").insert(pos, command.at("color"))
    }
  } else if kind == "ruler-marker" {
    let pos = command.at("position")
    let entry = (text: command.at("text"), color: command.at("color"))
    if pos == none {
      config.at("ruler-labels").at("top").insert(str(command.at("number")), entry)
      config.at("ruler-labels").at("bottom").insert(str(command.at("number")), entry)
    } else {
      config.at("ruler-labels").at(pos).insert(str(command.at("number")), entry)
    }
  } else if kind == "ruler-space" {
    let pos = command.at("position")
    if pos == none {
      config.at("ruler-spacing").insert("top", command.at("value"))
      config.at("ruler-spacing").insert("bottom", command.at("value"))
    } else {
      config.at("ruler-spacing").insert(pos, command.at("value"))
    }
  } else if kind == "rotate-ruler" {
    let pos = command.at("position")
    if pos == none or pos == "n" {
      config.at("ruler-rotation").insert("top", true)
      config.at("ruler-rotation").insert("bottom", true)
    } else {
      config.at("ruler-rotation").insert(pos, true)
    }
  } else if kind == "unrotate-ruler" {
    let pos = command.at("position")
    if pos == none or pos == "n" {
      config.at("ruler-rotation").insert("top", false)
      config.at("ruler-rotation").insert("bottom", false)
    } else {
      config.at("ruler-rotation").insert(pos, false)
    }
  } else if kind == "start-number" {
    config.at("start-numbers").insert(str(command.at("sequence")), command.at("start"))
    if command.at("selection") != none {
      config.at("sequence-windows").push((kind: "sequence-window", sequence: command.at("sequence"), selection: command.at("selection"), start: none))
    }
  } else if kind == "allow-zero-numbering" {
    config.insert("allow-zero", true)
  } else if kind == "disallow-zero-numbering" {
    config.insert("allow-zero", false)
  } else if kind == "sequence-length" {
    config.at("sequence-lengths").insert(str(command.at("sequence")), command.at("length"))
  } else if kind == "sequence-window" {
    if command.at("start") != none {
      config.at("start-numbers").insert(str(command.at("sequence")), command.at("start"))
    }
    config.at("sequence-windows").push(command)
  } else if kind == "region-highlight" {
    config.at("shade-regions").push(command)
  } else if kind == "region-tint" {
    config.at("tint-regions").push(command)
  } else if kind == "tint-default" {
    config.insert("tint-default", command.at("effect"))
  } else if kind == "region-lower" {
    config.at("lower-regions").push(command)
  } else if kind == "region-emphasis" {
    config.at("emph-regions").push(command)
  } else if kind == "emphasis-default" {
    config.insert("emph-default", command.at("style"))
  } else if kind == "frame-block" {
    config.at("frame-regions").push(command)
  } else if kind == "hide-sequence" {
    for ref in _ref-list(command.at("sequence")) {
      config.at("hidden").push(ref)
    }
  } else if kind == "hide-all-sequences" {
    config.insert("hide-seqs", true)
  } else if kind == "show-all-sequences" {
    config.insert("hide-seqs", false)
  } else if kind == "remove-sequence" {
    for ref in _ref-list(command.at("sequence")) {
      config.at("killed").push(ref)
    }
  } else if kind == "no-shade" {
    for ref in _ref-list(command.at("sequences")) {
      config.at("no-shade").push(ref)
    }
  } else if kind == "separation-line" {
    for ref in _ref-list(command.at("sequence")) {
      config.at("separation-lines").push(ref)
    }
  } else if kind == "sequence-order" {
    config.insert("order", _ref-list(command.at("order")))
  } else if kind == "feature" {
    config.at("features").push(command)
  } else if kind == "feature-rule" {
    config.insert("feature-rule", command.at("thickness"))
  } else if kind == "codon" {
    let residue = _upper(str(command.at("residue")))
    let choices = str(command.at("triplets")).split(",").map(item => item.trim()).filter(item => item != "")
    if choices.len() > 0 {
      config.at("genetic-code").insert(residue, choices.last())
    }
  } else if kind == "genetic-code" {
    let name = str(command.at("name"))
    config.insert("genetic-code", _standard-genetic-code + if name == "ciliate" { (Q: "YAR") } else { (:) })
  } else if kind == "backtranslation-label" {
    config.at("backtranslation").insert("label-style", command.at("style"))
    config.at("backtranslation").insert("label-size", command.at("size"))
  } else if kind == "backtranslation-text" {
    config.at("backtranslation").insert("text-style", command.at("style"))
    config.at("backtranslation").insert("text-size", command.at("size"))
  } else if kind == "feature-text-label" {
    config.at("feature-text-names").insert(command.at("position"), command.at("name"))
  } else if kind == "feature-style-label" {
    config.at("feature-style-names").insert(command.at("position"), command.at("name"))
  } else if kind == "hide-feature-text-label" {
    config.at("feature-text-names").insert(command.at("position"), "")
  } else if kind == "hide-feature-style-label" {
    config.at("feature-style-names").insert(command.at("position"), "")
  } else if kind == "hide-feature-text-labels" {
    config.insert("feature-text-names", (:))
  } else if kind == "hide-feature-style-labels" {
    config.insert("feature-style-names", (:))
  } else if kind == "feature-text-label-color" {
    config.at("feature-text-name-colors").insert("default", command.at("color"))
  } else if kind == "feature-style-label-color" {
    config.at("feature-style-name-colors").insert("default", command.at("color"))
  } else if kind == "feature-text-label-color-at" {
    config.at("feature-text-name-colors").insert(command.at("position"), command.at("color"))
  } else if kind == "feature-style-label-color-at" {
    config.at("feature-style-name-colors").insert(command.at("position"), command.at("color"))
  } else if kind == "consensus-from-sequence" {
    config.at("consensus").insert("source", command.at("sequence"))
  } else if kind == "consensus-from-all-sequences" {
    config.at("consensus").insert("source", "all")
  } else if kind == "show-leading-gaps" {
    config.insert("show-leading-gaps", true)
  } else if kind == "hide-leading-gaps" {
    config.insert("show-leading-gaps", false)
  } else if kind == "shift-single-sequence" {
    config.insert("single-seq-shift", command.at("value"))
  } else if kind == "keep-single-sequence-gaps" {
    config.insert("keep-single-seq-gaps", true)
  } else if kind == "hide-residues" {
    config.insert("hide-residues", true)
  } else if kind == "show-residues" {
    config.insert("hide-residues", false)
  } else if kind == "gap-char" {
    config.at("gaps").insert("char", command.at("symbol"))
  } else if kind == "gap-rule" {
    config.at("gaps").insert("rule-thickness", command.at("thickness"))
  } else if kind == "gap-colors" {
    config.at("gaps").insert("fg", command.at("foreground"))
    config.at("gaps").insert("bg", command.at("background"))
  } else if kind == "stop-char" {
    config.insert("stop-char", command.at("symbol"))
  } else if kind == "peptide-groups" {
    config.insert("pep-groups", _group-list(command.at("groups")))
  } else if kind == "dna-groups" {
    config.insert("dna-groups", _group-list(command.at("groups")))
  } else if kind == "peptide-similarities" {
    config.at("pep-sims").insert(_upper(str(command.at("residue"))), _upper(str(command.at("similars"))))
  } else if kind == "dna-similarities" {
    config.at("dna-sims").insert(_upper(str(command.at("residue"))), _upper(str(command.at("similars"))))
  } else if kind == "residue-style" {
    config.at("residue-style").insert(command.at("target"), _style-record(command.at("fg"), command.at("bg"), command.at("case"), command.at("style")))
  } else if kind == "cell-style" {
    config.at("cell-styles").push(command.at("callback"))
  } else if kind == "clear-functional-groups" {
    config.at("functional-groups").insert("custom", ())
    config.insert("functional-default", "custom")
  } else if kind == "functional-group" {
    let groups = config.at("functional-groups").at("custom", default: ())
    groups.push(_func-style-record(command.at("name"), command.at("residues"), command.at("fg"), command.at("bg"), command.at("case"), command.at("style")))
    config.at("functional-groups").insert("custom", groups)
    config.insert("functional-default", "custom")
  } else if kind == "functional-style" {
    config.at("functional-style-overrides").insert(_upper(str(command.at("residue"))), _style-record(command.at("fg"), command.at("bg"), command.at("case"), command.at("style")))
  } else if kind == "bar-graph-stretch" {
    let key = if command.at("position") == none { "default" } else { command.at("position") }
    config.at("bar-graph-stretch").insert(key, command.at("value"))
  } else if kind == "color-scale-stretch" {
    let key = if command.at("position") == none { "default" } else { command.at("position") }
    config.at("color-scale-stretch").insert(key, command.at("value"))
  } else if kind == "alignment" {
    config.insert("alignment", command.at("position"))
  } else if kind == "character-stretch" {
    config.insert("char-stretch", command.at("value"))
  } else if kind == "line-stretch" {
    config.insert("line-gap", config.at("font-size") * command.at("value"))
  } else if kind == "numbering-width" {
    config.insert("numbering-width-digits", command.at("digits"))
  } else if kind == "fingerprint" {
    config.insert("residues-per-line", command.at("value"))
    config.at("names").insert("show", true)
    config.at("names").insert("position", "left")
    config.at("numbering").insert("show", false)
    config.at("ruler").insert("steps", 100)
    config.at("residue-style").insert("nomatch", _style-record("Black", "Gray10", "upper", "normal"))
  } else if kind == "align-right-labels" {
    config.insert("align-right-labels", true)
  } else if kind == "align-left-labels" {
    config.insert("align-right-labels", false)
  } else if kind == "text-family" {
    _set-text-style(config, command.at("target"), "family", command.at("value"))
  } else if kind == "text-weight" {
    _set-text-style(config, command.at("target"), "weight", command.at("value"))
  } else if kind == "text-posture" {
    _set-text-style(config, command.at("target"), "style", command.at("value"))
  } else if kind == "text-size" {
    _set-text-style(config, command.at("target"), "size", command.at("value"))
  } else if kind == "text-style" {
    _set-text-style(config, command.at("target"), "family", command.at("family"))
    _set-text-style(config, command.at("target"), "weight", command.at("weight"))
    _set-text-style(config, command.at("target"), "style", command.at("posture"))
    _set-text-style(config, command.at("target"), "size", command.at("size"))
  } else if kind == "caption" {
    config.at("captions").insert(command.at("position"), command.at("text"))
  } else if kind == "short-caption" {
    config.at("captions").insert("short", command.at("text"))
  } else if kind == "separator-space" {
    config.insert("separation-space", command.at("value"))
  } else if kind == "export-consensus" {
    config.insert("exported-consensus", command)
  } else if kind == "block-gap" {
    config.insert("block-gap", command.at("value"))
  } else if kind == "block-gap-factor" {
    config.insert("block-gap", config.at("font-size") * command.at("value"))
  } else if kind == "block-space-mode" {
    config.insert("fixed-block-space", command.at("fixed"))
  } else if kind == "line-gap" {
    config.insert("line-gap", command.at("value"))
  } else if kind == "feature-slot-space" {
    config.at("feature-slot-spacing").insert(command.at("position"), command.at("value"))
  }
  config
}
