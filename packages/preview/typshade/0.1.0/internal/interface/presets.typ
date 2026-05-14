// Copyright (C) 2026 Eito Yoneyama
// SPDX-License-Identifier: GPL-2.0

#import "../engine/config.typ" as _config
#import "../engine/commands.typ" as _commands

#let visual-theme(
  colors: none,
  mode: none,
  option: none,
  gap: none,
  names: none,
  numbering: none,
  ruler: none,
  legend: none,
  commands: (),
) = (
  colors: colors,
  mode: mode,
  option: option,
  gap: gap,
  names: names,
  numbering: numbering,
  ruler: ruler,
  legend: legend,
  commands: commands,
)

#let _theme-commands(settings) = {
  let out = ()
  if settings.at("mode", default: none) != none {
      out.push(_config.scoring-mode(settings.at("mode"), option: settings.at("option", default: none)))
  }
  if settings.at("colors", default: none) != none {
    out.push(_config.color-scheme(settings.at("colors")))
  }
  let gap = settings.at("gap", default: none)
  if type(gap) == dictionary {
    if gap.at("foreground", default: none) != none or gap.at("background", default: none) != none {
      out.push(_config.gap-colors(gap.at("foreground", default: "Black"), gap.at("background", default: "White")))
    }
    if gap.at("rule", default: none) != none {
      out.push(_config.gap-rule(gap.at("rule")))
    }
  }
  if settings.at("names", default: none) != none {
    out.push(_config.names-color(settings.at("names")))
  }
  if settings.at("numbering", default: none) != none {
    out.push(_config.numbering-color(settings.at("numbering")))
  }
  if settings.at("ruler", default: none) != none {
    out.push(_config.ruler-color(settings.at("ruler")))
  }
  if settings.at("legend", default: none) != none {
    out.push(_config.legend-color(settings.at("legend")))
  }
  _commands._add-command(out, settings.at("commands", default: ()))
  out
}

#let shade-theme(name) = {
  if name == none or name == "classic" {
    ()
  } else if type(name) == dictionary {
    _theme-commands(name)
  } else if name == "print" or name == "grayscale" {
    (
      _config.color-scheme("grays"),
      _config.gap-colors("Gray60", "White"),
      _config.names-color("Black"),
      _config.numbering-color("Gray60"),
    )
  } else if name == "screen" or name == "blue" {
    (
      _config.color-scheme("blues"),
      _config.names-color("RoyalBlue"),
      _config.numbering-color("DarkGray"),
    )
  } else if name == "warm" {
    (
      _config.color-scheme("reds"),
      _config.names-color("BrickRed"),
      _config.numbering-color("DarkGray"),
    )
  } else if name == "nature" or name == "green" {
    (
      _config.color-scheme("greens"),
      _config.names-color("PineGreen"),
      _config.numbering-color("DarkGray"),
    )
  } else if type(name) == array {
    name
  } else {
    ()
  }
}

#let shade-preset(name) = {
  if name == none {
    ()
  } else if name == "publication" {
    (
      shade-theme("print"),
      _config.names-track(position: "left"),
      _config.numbering-track(position: "right"),
      _config.consensus-track(position: "bottom"),
      _config.residues-per-line(60),
    )
  } else if name == "overview" {
    (
      _config.fingerprint(1000),
      _config.no-numbering-track(),
      _config.no-consensus-track(),
      _config.align-left-labels(),
    )
  } else if name == "logo" {
    (
      _config.sequence-logo-track(position: "top"),
      _config.logo-scale(position: "leftright"),
      _config.consensus-track(position: "bottom"),
    )
  } else if name == "functional" {
    (
      _config.scoring-mode("functional", option: "charge"),
      _config.legend-track(),
    )
  } else if name == "structure" {
    (
      _config.numbering-track(position: "leftright"),
      _config.ruler-track(position: "top", steps: 10),
      _config.ruler-color("DarkGray"),
      _config.consensus-track(position: "bottom"),
    )
  } else if type(name) == array {
    name
  } else {
    ()
  }
}
