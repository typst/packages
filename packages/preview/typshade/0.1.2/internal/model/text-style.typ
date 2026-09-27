// Copyright (C) 2026 Eito Yoneyama
// SPDX-License-Identifier: GPL-2.0

#import "parser.typ": _upper

#let _text-style-targets = (
  "residues",
  "numbering",
  "names",
  "feature-text-labels",
  "feature-style-labels",
  "features",
  "feature-styles",
  "legend",
  "ruler",
  "ruler-label",
)

#let _default-text-styles = (
  "residues": (family: "mono", weight: "regular", style: "normal", size: "normal"),
  "numbering": (family: "mono", weight: "regular", style: "normal", size: "normal"),
  "names": (family: "mono", weight: "regular", style: "normal", size: "normal"),
  "feature-text-labels": (family: "mono", weight: "regular", style: "normal", size: "normal"),
  "feature-style-labels": (family: "mono", weight: "regular", style: "normal", size: "normal"),
  "features": (family: "serif", weight: "regular", style: "italic", size: "normal"),
  "feature-styles": (family: "mono", weight: "regular", style: "normal", size: "normal"),
  "legend": (family: "mono", weight: "regular", style: "normal", size: "normal"),
  "ruler": (family: "sans", weight: "regular", style: "normal", size: "normal"),
  "ruler-label": (family: "sans", weight: "regular", style: "normal", size: "normal"),
)

#let _font-family(config, family) = {
  if family == "mono" {
    return config.at("font")
  }
  if family == "sans" {
    return config.at("font-families").at("sans")
  }
  if family == "serif" {
    return config.at("font-families").at("serif")
  }
  family
}

#let _size-factor(size) = {
  if type(size) != str {
    return size
  }
  if size == "tiny" {
    0.55
  } else if size == "x-small" {
    0.7
  } else if size == "smaller" {
    0.8
  } else if size == "small" {
    0.9
  } else if size == "normal" {
    1.0
  } else if size == "large" {
    1.2
  } else if size == "x-large" {
    1.44
  } else if size == "xx-large" {
    1.72
  } else if size == "huge" {
    2.05
  } else if size == "x-huge" {
    2.45
  } else {
    1.0
  }
}

#let _font-size(config, size) = {
  if type(size) == str {
    config.at("font-size") * _size-factor(size)
  } else {
    size
  }
}

#let _target-list(target) = if target == "all" {
  _text-style-targets
} else if type(target) == str {
  (target,)
} else {
  target
}

#let _set-text-style(config, target, key, value) = {
  for name in _target-list(target) {
    if config.at("text-styles").keys().contains(name) {
      config.at("text-styles").at(name).insert(key, value)
    }
  }
}

#let _text-style(config, target) = {
  let base = _default-text-styles.at(target, default: _default-text-styles.at("residues"))
  let overrides = config.at("text-styles").at(target, default: (:))
  let family = overrides.at("family", default: base.at("family"))
  let weight = overrides.at("weight", default: base.at("weight"))
  let style = overrides.at("style", default: base.at("style"))
  let size = overrides.at("size", default: base.at("size"))
  (
    font: _font-family(config, family),
    size: _font-size(config, size),
    weight: if weight == "bold" { "bold" } else { "regular" },
    style: if style == "italic" or style == "oblique" { "italic" } else { "normal" },
    smallcaps: style == "small-caps",
  )
}

#let _text-params(config, target, fill: black, style: auto, size: auto) = {
  let resolved = _text-style(config, target)
  (
    font: resolved.at("font"),
    size: if size == auto { resolved.at("size") } else { size },
    weight: resolved.at("weight"),
    style: if style == auto { resolved.at("style") } else { style },
    fill: fill,
  )
}

#let _text-string(config, target, value) = {
  let text = str(value)
  if _text-style(config, target).at("smallcaps") {
    _upper(text)
  } else {
    text
  }
}
