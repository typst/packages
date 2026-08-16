// Copyright (C) 2026 Eito Yoneyama
// SPDX-License-Identifier: GPL-2.0

#import "palette.typ": _default-logo-colors, _functional-presets, _logo-color-presets
#import "parser.typ": _upper

#let _log2(value) = calc.log(value) / calc.log(2)
#let _logo-max-bits(seq-type) = if seq-type == "N" { 2.0 } else { _log2(20.0) }

#let _resolve-sequence(alignment, sequence) = {
  if type(sequence) == int {
    return calc.max(0, sequence - 1)
  }
  let ref = str(sequence)
  for (idx, seq) in alignment.at("sequences").enumerate() {
    if seq.at("name") == ref {
      return idx
    }
  }
  0
}

#let _functional-style(residue, mode) = {
  if not _functional-presets.keys().contains(mode) {
    return none
  }
  for group in _functional-presets.at(mode) {
    if group.at("residues").contains(residue) {
      return group
    }
  }
  none
}

#let _logo-preset(seq-type, colorset) = {
  if colorset == none {
    return if seq-type == "N" { "nucleotide" } else { "rasmol" }
  }
  let key = str(colorset)
  if key == "standard" {
    return if seq-type == "N" { "nucleotide" } else { "rasmol" }
  }
  key
}

#let _logo-frequencies(alignment, col, subset: none, subfamily: false) = {
  let counts = (:)
  let rest = (:)
  let total = 0
  let total-rest = 0
  let use-all = subset == none or subset.len() == 0
  for (idx, seq) in alignment.at("sequences").enumerate() {
    let char = _upper(seq.at("aligned").slice(col, col + 1))
    if char == "." or char == "-" or char == "" {
      continue
    }
    let in-subset = use-all or subset.contains(seq.at("name")) or subset.contains(idx + 1)
    if not subfamily {
      if in-subset {
        counts.insert(char, counts.at(char, default: 0) + 1)
        total += 1
      }
    } else if in-subset {
      counts.insert(char, counts.at(char, default: 0) + 1)
      total += 1
    } else {
      rest.insert(char, rest.at(char, default: 0) + 1)
      total-rest += 1
    }
  }
  if not subfamily {
    return (counts: counts, total: total)
  }
  let diffs = (:)
  for key in counts.keys() {
    let left = if total == 0 { 0.0 } else { counts.at(key) / total }
    let right = if total-rest == 0 { 0.0 } else { rest.at(key, default: 0) / total-rest }
    diffs.insert(key, left - right)
  }
  for key in rest.keys() {
    if not diffs.keys().contains(key) {
      let right = if total-rest == 0 { 0.0 } else { rest.at(key) / total-rest }
      diffs.insert(key, -right)
    }
  }
  (counts: diffs, total: 1)
}

#let _logo-color(seq-type, colorset, residue) = {
  let key = _upper(residue)
  if type(colorset) == dictionary and colorset.keys().contains(key) {
    return colorset.at(key)
  }
  let preset = _logo-preset(seq-type, colorset)
  if _logo-color-presets.keys().contains(preset) {
    for entry in _logo-color-presets.at(preset) {
      if entry.at("residues").contains(key) {
        return entry.at("color")
      }
    }
  }
  if colorset != none and _functional-presets.keys().contains(colorset) {
    let group = _functional-style(key, colorset)
    if group != none {
      return group.at("bg")
    }
  }
  _default-logo-colors.at(seq-type).at(key, default: "Black")
}

#let _logo-colorset(config, residue, subfamily: false) = {
  let custom = config.at("logo-colors").at("map")
  let key = _upper(residue)
  if custom.keys().contains(key) or config.at("logo-colors").at("default") != none {
    return custom + (default: config.at("logo-colors").at("default"))
  }
  if subfamily {
    return config.at("subfamily-logo").at("colorset")
  }
  config.at("sequence-logo").at("colorset")
}

#let _logo-residue-color(config, seq-type, residue, subfamily: false) = {
  _logo-color(seq-type, _logo-colorset(config, residue, subfamily: subfamily), residue)
}

#let _logo-column-items(alignment, config, col, subfamily: false) = {
  let subset = if subfamily { config.at("subfamily") } else { none }
  let data = _logo-frequencies(alignment, col, subset: subset, subfamily: subfamily)
  let counts = data.at("counts")
  if counts.keys().len() == 0 {
    return ()
  }
  let seq-type = alignment.at("seq-type")
  let heights = ()
  if not subfamily {
    let total = data.at("total")
    let entropy = 0.0
    for key in counts.keys() {
      let p = counts.at(key) / total
      if p > 0 {
        entropy += -p * _log2(p)
      }
    }
    let correction = if config.at("frequency-correction") and total > 0 {
      (counts.keys().len() - 1) / (2.0 * calc.log(2) * total)
    } else {
      0.0
    }
    let info = calc.max(0.0, _logo-max-bits(seq-type) - entropy - correction)
    for key in counts.keys() {
      let p = counts.at(key) / total
      heights.push((residue: key, value: p * info))
    }
  } else {
    for key in counts.keys() {
      heights.push((residue: key, value: counts.at(key) * _logo-max-bits(seq-type)))
    }
  }
  heights.sorted(key: it => calc.abs(it.at("value"))).filter(it => calc.abs(it.at("value")) > 0)
}
