// Copyright (C) 2026 Eito Yoneyama
// SPDX-License-Identifier: GPL-2.0

#import "../engine/config.typ" as _config
#import "../engine/commands.typ" as _commands
#import "recipes.typ" as _recipes
#import "presets.typ": shade-preset, shade-theme
#import "../render/alignment.typ" as _render

#let _position-value(value, default) = if value == true {
  default
} else {
  value
}

#let _value-or-default(value, key, default) = if type(value) == dictionary {
  value.at(key, default: default)
} else {
  default
}

#let shade(
  source,
  format: auto,
  figure: (),
  preset: none,
  theme: none,
  mode: none,
  option: none,
  seq-type: auto,
  residues-per-line: none,
  names: none,
  numbering: none,
  consensus: none,
  ruler: none,
  logo: none,
  subfamily-logo: none,
  legend: none,
  regions: (),
  features: (),
  commands: (),
  font: none,
  font-size: none,
) = {
  let out = ()
  _commands._add-command(out, _recipes.resolve-figure(source, format, figure))
  _commands._add-command(out, shade-preset(preset))
  _commands._add-command(out, shade-theme(theme))
  if seq-type != auto and seq-type != none {
    out.push(_config.sequence-type(seq-type))
  }
  if mode != none {
    out.push(_config.scoring-mode(mode, option: option))
  }
  if residues-per-line != none {
    out.push(_config.residues-per-line(residues-per-line))
  }
  if names != none {
    if names == false {
      out.push(_config.no-names-track())
    } else {
      out.push(_config.names-track(position: _position-value(names, "left")))
    }
  }
  if numbering != none {
    if numbering == false {
      out.push(_config.no-numbering-track())
    } else {
      out.push(_config.numbering-track(position: _position-value(numbering, "right")))
    }
  }
  if consensus != none {
    if consensus == false {
      out.push(_config.no-consensus-track())
    } else {
      out.push(_config.consensus-track(position: _position-value(consensus, "bottom")))
    }
  }
  if ruler != none {
    if ruler == false {
      out.push(_config.no-ruler-track())
    } else if type(ruler) == dictionary {
      out.push(_config.ruler-track(
        position: ruler.at("position", default: "top"),
        sequence: ruler.at("sequence", default: 1),
        steps: ruler.at("steps", default: none),
        color: ruler.at("color", default: none),
      ))
    } else {
      out.push(_config.ruler-track(position: _position-value(ruler, "top")))
    }
  }
  if logo != none {
    if logo == false {
      out.push(_config.no-sequence-logo-track())
    } else if type(logo) == dictionary {
      out.push(_config.sequence-logo-track(position: logo.at("position", default: "top"), colorset: logo.at("colorset", default: none)))
    } else {
      out.push(_config.sequence-logo-track(position: _position-value(logo, "top")))
    }
  }
  if subfamily-logo != none {
    if subfamily-logo == false {
      out.push(_config.no-subfamily-logo-track())
    } else if type(subfamily-logo) == dictionary {
      if subfamily-logo.keys().contains("sequences") {
        out.push(_config.subfamily(subfamily-logo.at("sequences")))
      }
      out.push(_config.subfamily-logo-track(position: subfamily-logo.at("position", default: "top"), colorset: subfamily-logo.at("colorset", default: none)))
    } else {
      out.push(_config.subfamily-logo-track(position: _position-value(subfamily-logo, "top")))
    }
  }
  if legend != none {
    if legend == false {
      out.push(_config.no-legend-track())
    } else if type(legend) == dictionary {
      out.push(_config.legend-track(color: legend.at("color", default: "Black")))
    } else {
      out.push(_config.legend-track())
    }
  }
  _commands._add-command(out, regions)
  _commands._add-command(out, features)
  _commands._add-command(out, commands)
  _render.render-alignment(source, format: format, commands: out, font: font, font-size: font-size)
}
