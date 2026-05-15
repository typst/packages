// Copyright (C) 2026 Eito Yoneyama
// SPDX-License-Identifier: GPL-2.0

#import "../engine/config.typ" as _config
#import "../engine/commands.typ" as _commands
#import "../engine/layout.typ": _selection-columns
#import "../model/parser.typ": read-alignment
#import "annotations.typ" as _annotations
#import "tracks.typ": sequence-logo, structure-tracks
#import "presets.typ": shade-preset, shade-theme

#let _recipe(name, options) = (kind: "typshade-recipe", name: name, options: options)

#let _is-recipe(value) = type(value) == dictionary and value.at("kind", default: none) == "typshade-recipe"

#let _add(out, value) = _commands._add-command(out, value)

#let _value(value, key, default) = if type(value) == dictionary {
  value.at(key, default: default)
} else {
  default
}

#let _track-position(value, default) = if value == true {
  default
} else if type(value) == dictionary {
  value.at("position", default: default)
} else {
  value
}

#let _sequence-index(alignment, sequence) = {
  if type(sequence) == int {
    return calc.max(0, sequence - 1)
  }
  for (idx, item) in alignment.at("sequences").enumerate() {
    if item.at("name") == sequence {
      return idx
    }
  }
  0
}

#let _sequence(alignment, sequence) = alignment.at("sequences").at(_sequence-index(alignment, sequence))

#let _clamp(value, low, high) = {
  if value < low {
    low
  } else if value > high {
    high
  } else {
    value
  }
}

#let _selection-span(alignment, sequence, selection, padding: 0) = {
  let seq = _sequence(alignment, sequence)
  let columns = _selection-columns(seq, selection)
  let first = none
  let last = none
  for col in columns {
    let pos = seq.at("positions").at(col)
    if pos != none {
      if first == none or pos < first {
        first = pos
      }
      if last == none or pos > last {
        last = pos
      }
    }
  }
  if first == none or last == none {
    none
  } else {
    let start = _clamp(first - padding, 1, seq.at("length"))
    let stop = _clamp(last + padding, 1, seq.at("length"))
    str(start) + ".." + str(stop)
  }
}

#let _motif-patterns(motifs) = {
  if motifs == none {
    return ()
  }
  if type(motifs) == dictionary {
    motifs.keys()
  } else if type(motifs) == array {
    let out = ()
    for item in motifs {
      if type(item) == str {
        out.push(item)
      } else if type(item) == dictionary {
        out.push(_annotation-selection(item, "all"))
      }
    }
    out
  } else {
    ()
  }
}

#let _auto-region(alignment, sequence, motifs, padding: 8) = {
  let seq = _sequence(alignment, sequence)
  let first = none
  let last = none
  for pattern in _motif-patterns(motifs) {
    let span = _selection-span(alignment, sequence, pattern)
    if span != none {
      let bounds = span.split("..")
      let start = int(bounds.first())
      let stop = int(bounds.last())
      if first == none or start < first {
        first = start
      }
      if last == none or stop > last {
        last = stop
      }
    }
  }
  if first == none or last == none {
    none
  } else {
    str(_clamp(first - padding, 1, seq.at("length"))) + ".." + str(_clamp(last + padding, 1, seq.at("length")))
  }
}

#let _has-selection(alignment, sequence, selection) = _selection-span(alignment, sequence, selection) != none

#let _auto-motifs(alignment, sequence) = {
  let candidates = if alignment.at("seq-type") == "N" {
    (
      (pattern: "ATG", text: "start"),
      (pattern: "TATA", text: "TATA box"),
    )
  } else {
    (
      (pattern: "NPA", text: "NPA"),
      (pattern: "NXX[ST]N", text: "glycosylation"),
      (pattern: "CXXC", text: "CXXC"),
      (pattern: "HXXH", text: "HXXH"),
    )
  }
  let out = (:)
  for item in candidates {
    if _has-selection(alignment, sequence, item.at("pattern")) {
      out.insert(item.at("pattern"), item.at("text"))
    }
  }
  out
}

#let _auto-line-length(alignment, purpose: "publication", region: none, sequence: 1) = {
  if region != none and region != auto {
    let span = _selection-span(alignment, sequence, region)
    if span != none {
      let bounds = span.split("..")
      return _clamp(int(bounds.last()) - int(bounds.first()) + 1, 35, 90)
    }
  }
  let columns = alignment.at("columns")
  let count = alignment.at("sequences").len()
  if purpose == "overview" {
    if columns <= 120 { columns } else { 120 }
  } else if columns <= 55 {
    columns
  } else if count >= 20 {
    80
  } else if count >= 10 {
    70
  } else {
    60
  }
}

#let _auto-threshold(alignment, threshold) = {
  if threshold != auto {
    return threshold
  }
  if alignment.at("seq-type") == "N" {
    60
  } else {
    45
  }
}

#let _auto-logo(alignment, logo, region: none) = {
  if logo != auto {
    return logo
  }
  let count = alignment.at("sequences").len()
  let columns = alignment.at("columns")
  let compact = if region == none or region == auto {
    columns <= 140
  } else {
    true
  }
  if count >= 4 and compact {
    if alignment.at("seq-type") == "N" { "nucleotide" } else { "charge" }
  } else {
    false
  }
}

#let _auto-conservation(alignment, value) = {
  if value == auto {
    alignment.at("sequences").len() >= 2
  } else {
    value
  }
}

#let _apply-scoring(out, mode, colors, threshold, option: none) = {
  if mode != none {
    out.push(_config.scoring-mode(mode, option: option))
  }
  if colors != none {
    out.push(_config.color-scheme(colors))
  }
  if threshold != none {
    out.push(_config.threshold(threshold))
  }
}

#let _apply-window(out, region, sequence, start: none) = {
  if region != none {
    if type(region) == dictionary {
      out.push(_config.sequence-window(
        region.at("sequence", default: sequence),
        region.at("selection", default: region.at("range", default: "all")),
        start: region.at("start", default: start),
      ))
    } else {
      out.push(_config.sequence-window(sequence, region, start: start))
    }
  }
}

#let _apply-ruler(out, value, sequence, every) = {
  if value == false or value == none {
    return
  }
  let position = _track-position(value, "top")
  let steps = _value(value, "every", _value(value, "steps", every))
  out.push(_config.ruler-track(
    position: position,
    sequence: _value(value, "sequence", sequence),
    steps: steps,
    color: _value(value, "color", none),
  ))
  if _value(value, "name", none) != none {
    out.push(_config.ruler-name(_value(value, "name", none), position: position))
  }
}

#let _apply-consensus(out, value) = {
  if value == false or value == none {
    return
  }
  out.push(_config.consensus-track(
    position: _track-position(value, "bottom"),
    scale: _value(value, "scale", none),
    name: _value(value, "name", none),
  ))
}

#let _apply-logo(out, value) = {
  if value == false or value == none {
    return
  }
  if value == true or type(value) == str {
    _add(out, sequence-logo(position: "top", colors: if value == true { none } else { value }))
  } else if type(value) == dictionary {
    _add(out, sequence-logo(
      position: value.at("position", default: "top"),
      colors: value.at("colors", default: value.at("colorset", default: none)),
      name: value.at("name", default: none),
      scale: value.at("scale", default: "leftright"),
      relevance-marker: value.at("relevance-marker", default: none),
      stretch: value.at("stretch", default: none),
    ))
  }
}

#let _annotation-selection(item, default) = item.at("selection", default: item.at("range", default: item.at("pattern", default: default)))

#let _add-motif(out, pattern, settings, sequence, position) = {
  if type(settings) == str {
    _add(out, _annotations.motif(sequence, pattern, text: settings, position: position))
  } else if type(settings) == dictionary {
    _add(out, _annotations.motif(
      settings.at("sequence", default: sequence),
      pattern,
      text: settings.at("text", default: settings.at("label", default: "motif")),
      position: settings.at("position", default: position),
      fg: settings.at("fg", default: "White"),
      bg: settings.at("bg", default: "RoyalBlue"),
      fill: settings.at("fill", default: "Yellow"),
      all: settings.at("all", default: false),
    ))
  } else if settings == true {
    _add(out, _annotations.motif(sequence, pattern, position: position))
  }
}

#let _apply-motifs(out, motifs, sequence, position: "top") = {
  if motifs == none {
    return
  }
  if type(motifs) == dictionary {
    for pattern in motifs.keys() {
      _add-motif(out, pattern, motifs.at(pattern), sequence, position)
    }
  } else if type(motifs) == array {
    for item in motifs {
      if type(item) == str {
        _add(out, _annotations.motif(sequence, item, position: position))
      } else if type(item) == dictionary {
        _add-motif(
          out,
          _annotation-selection(item, "all"),
          item,
          item.at("sequence", default: sequence),
          item.at("position", default: position),
        )
      } else {
        _add(out, item)
      }
    }
  }
}

#let _add-highlight(out, selection, settings, sequence) = {
  if type(settings) == dictionary {
    _add(out, _annotations.highlight(
      settings.at("sequence", default: sequence),
      selection,
      fg: settings.at("fg", default: "White"),
      bg: settings.at("bg", default: settings.at("fill", default: "RoyalBlue")),
      all: settings.at("all", default: false),
    ))
  } else if settings == true {
    _add(out, _annotations.highlight(sequence, selection))
  } else if type(settings) == str {
    _add(out, _annotations.highlight(sequence, selection, bg: settings))
  }
}

#let _apply-highlights(out, highlights, sequence) = {
  if highlights == none {
    return
  }
  if type(highlights) == dictionary {
    for selection in highlights.keys() {
      _add-highlight(out, selection, highlights.at(selection), sequence)
    }
  } else if type(highlights) == array {
    for item in highlights {
      if type(item) == str {
        _add(out, _annotations.highlight(sequence, item))
      } else if type(item) == dictionary {
        _add-highlight(out, _annotation-selection(item, "all"), item, sequence)
      } else {
        _add(out, item)
      }
    }
  }
}

#let publication(
  mode: "similar",
  similarity: "blues",
  threshold: auto,
  sequence: 1,
  region: auto,
  line-length: auto,
  ruler: true,
  every: 10,
  conservation: true,
  logo: none,
  motifs: (:),
  highlights: (),
  theme: none,
  annotations: (),
  commands: (),
) = _recipe("publication", (
  mode: mode,
  similarity: similarity,
  threshold: threshold,
  sequence: sequence,
  region: region,
  line-length: line-length,
  ruler: ruler,
  every: every,
  conservation: conservation,
  logo: logo,
  motifs: motifs,
  highlights: highlights,
  theme: theme,
  annotations: annotations,
  commands: commands,
))

#let _build-publication(alignment, options) = {
  let mode = options.at("mode")
  let similarity = options.at("similarity")
  let threshold = _auto-threshold(alignment, options.at("threshold"))
  let sequence = options.at("sequence")
  let motifs = if options.at("motifs") == auto { _auto-motifs(alignment, sequence) } else { options.at("motifs") }
  let region = if options.at("region") == auto { _auto-region(alignment, sequence, motifs) } else { options.at("region") }
  let line-length = if options.at("line-length") == auto {
    _auto-line-length(alignment, purpose: "publication", region: region, sequence: sequence)
  } else {
    options.at("line-length")
  }
  let conservation = _auto-conservation(alignment, options.at("conservation"))
  let logo = _auto-logo(alignment, options.at("logo"), region: region)
  let out = ()
  _add(out, shade-preset("publication"))
  _add(out, shade-theme(options.at("theme")))
  _apply-scoring(out, mode, similarity, threshold)
  if line-length != none {
    out.push(_config.residues-per-line(line-length))
  }
  _apply-window(out, region, sequence)
  _apply-ruler(out, options.at("ruler"), sequence, options.at("every"))
  _apply-consensus(out, conservation)
  _apply-logo(out, logo)
  _apply-highlights(out, options.at("highlights"), sequence)
  _apply-motifs(out, motifs, sequence)
  _add(out, options.at("annotations"))
  _add(out, options.at("commands"))
  out
}

#let motif-map(
  motifs,
  sequence: 1,
  region: auto,
  line-length: auto,
  similarity: "blues",
  threshold: auto,
  logo: auto,
  conservation: auto,
  graph: auto,
  theme: none,
  highlights: (),
  commands: (),
) = _recipe("motif-map", (
  motifs: motifs,
  sequence: sequence,
  region: region,
  line-length: line-length,
  similarity: similarity,
  threshold: threshold,
  logo: logo,
  conservation: conservation,
  graph: graph,
  theme: theme,
  highlights: highlights,
  commands: commands,
))

#let _build-motif-map(alignment, options) = {
  let sequence = options.at("sequence")
  let motifs = if options.at("motifs") == auto { _auto-motifs(alignment, sequence) } else { options.at("motifs") }
  let region = if options.at("region") == auto { _auto-region(alignment, sequence, motifs) } else { options.at("region") }
  let out = _build-publication(alignment, (
    mode: "similar",
    similarity: options.at("similarity"),
    threshold: options.at("threshold"),
    sequence: sequence,
    region: region,
    line-length: options.at("line-length"),
    ruler: true,
    every: 10,
    conservation: options.at("conservation"),
    logo: options.at("logo"),
    motifs: motifs,
    highlights: options.at("highlights"),
    theme: options.at("theme"),
    annotations: (),
    commands: (),
  ))
  let graph = if options.at("graph") == auto { alignment.at("sequences").len() >= 3 } else { options.at("graph") }
  if graph != false {
    if type(graph) == dictionary {
      _add(out, _annotations.graph(
        graph.at("position", default: "bottom"),
        graph.at("sequence", default: sequence),
        graph.at("selection", default: graph.at("range", default: "all")),
        graph.at("metric", default: "conservation"),
        kind: graph.at("kind", default: "color"),
        options: graph.at("options", default: ("ColdHot",)),
      ))
    } else {
      _add(out, _annotations.graph("bottom", sequence, "all", "conservation", kind: "color", options: ("ColdHot",)))
    }
  }
  _add(out, options.at("commands"))
  out
}

#let structure-map(
  sequence,
  topology: none,
  secondary: none,
  hmmtop: none,
  hmmtop-sequence: none,
  region: none,
  line-length: auto,
  similarity: "grays",
  threshold: auto,
  ruler: true,
  conservation: auto,
  theme: none,
  commands: (),
) = _recipe("structure-map", (
  sequence: sequence,
  topology: topology,
  secondary: secondary,
  hmmtop: hmmtop,
  hmmtop-sequence: hmmtop-sequence,
  region: region,
  line-length: line-length,
  similarity: similarity,
  threshold: threshold,
  ruler: ruler,
  conservation: conservation,
  theme: theme,
  commands: commands,
))

#let _build-structure-map(alignment, options) = {
  let sequence = options.at("sequence")
  let region = options.at("region")
  let line-length = if options.at("line-length") == auto {
    _auto-line-length(alignment, purpose: "structure", region: region, sequence: sequence)
  } else {
    options.at("line-length")
  }
  let threshold = if options.at("threshold") == auto { none } else { options.at("threshold") }
  let conservation = _auto-conservation(alignment, options.at("conservation"))
  let out = ()
  _add(out, shade-preset("structure"))
  _add(out, shade-theme(options.at("theme")))
  _apply-scoring(out, "similar", options.at("similarity"), threshold)
  if line-length != none {
    out.push(_config.residues-per-line(line-length))
  }
  _apply-window(out, region, sequence)
  _apply-ruler(out, options.at("ruler"), sequence, 10)
  _apply-consensus(out, conservation)
  _add(out, structure-tracks(
    sequence,
    hmmtop: options.at("hmmtop"),
    topology: options.at("topology"),
    secondary: options.at("secondary"),
    hmmtop-sequence: options.at("hmmtop-sequence"),
  ))
  _add(out, options.at("commands"))
  out
}

#let logo-analysis(
  sequence: 1,
  region: none,
  line-length: auto,
  colors: auto,
  subfamily: none,
  negative: auto,
  relevance: auto,
  conservation: auto,
  theme: none,
  commands: (),
) = _recipe("logo-analysis", (
  sequence: sequence,
  region: region,
  line-length: line-length,
  colors: colors,
  subfamily: subfamily,
  negative: negative,
  relevance: relevance,
  conservation: conservation,
  theme: theme,
  commands: commands,
))

#let _build-logo-analysis(alignment, options) = {
  let sequence = options.at("sequence")
  let region = options.at("region")
  let line-length = if options.at("line-length") == auto {
    _auto-line-length(alignment, purpose: "logo", region: region, sequence: sequence)
  } else {
    options.at("line-length")
  }
  let colors = if options.at("colors") == auto {
    if alignment.at("seq-type") == "N" { "nucleotide" } else { "charge" }
  } else {
    options.at("colors")
  }
  let conservation = _auto-conservation(alignment, options.at("conservation"))
  let out = ()
  _add(out, shade-preset("logo"))
  _add(out, shade-theme(options.at("theme")))
  if line-length != none {
    out.push(_config.residues-per-line(line-length))
  }
  _apply-window(out, region, sequence)
  _add(out, sequence-logo(position: "top", colors: colors))
  if options.at("subfamily") != none {
    out.push(_config.subfamily(options.at("subfamily")))
    out.push(_config.subfamily-logo-track(position: "bottom", colorset: colors))
  }
  let negative = if options.at("negative") == auto { options.at("subfamily") != none } else { options.at("negative") }
  if negative {
    out.push(_config.negative-logo-values())
  }
  let relevance = if options.at("relevance") == auto and options.at("subfamily") != none { 1.0 } else { options.at("relevance") }
  if relevance != none and relevance != auto {
    if type(relevance) == dictionary {
      out.push(_config.relevance-marker(
        char: relevance.at("char", default: "*"),
        color: relevance.at("color", default: "Black"),
      ))
      if relevance.at("threshold", default: none) != none {
        out.push(_config.relevance-threshold(relevance.at("threshold")))
      }
    } else {
      out.push(_config.relevance-threshold(relevance))
    }
  }
  _apply-consensus(out, conservation)
  _add(out, options.at("commands"))
  out
}

#let overview(
  mode: "similar",
  colors: none,
  line-length: auto,
  names: true,
  numbers: false,
  conservation: false,
  ruler: false,
  theme: none,
  commands: (),
) = _recipe("overview", (
  mode: mode,
  colors: colors,
  line-length: line-length,
  names: names,
  numbers: numbers,
  conservation: conservation,
  ruler: ruler,
  theme: theme,
  commands: commands,
))

#let _build-overview(alignment, options) = {
  let line-length = if options.at("line-length") == auto {
    _auto-line-length(alignment, purpose: "overview")
  } else {
    options.at("line-length")
  }
  let out = ()
  _add(out, shade-preset("overview"))
  _add(out, shade-theme(options.at("theme")))
  _apply-scoring(out, options.at("mode"), options.at("colors"), none)
  if line-length != none {
    out.push(_config.residues-per-line(line-length))
  }
  let names = options.at("names")
  if names == false {
    out.push(_config.no-names-track())
  } else if names != true {
    out.push(_config.names-track(position: _track-position(names, "left"), color: _value(names, "color", none)))
  }
  let numbers = options.at("numbers")
  if numbers == true or type(numbers) == dictionary or type(numbers) == str {
    out.push(_config.numbering-track(position: _track-position(numbers, "right"), color: _value(numbers, "color", none)))
  }
  _apply-consensus(out, options.at("conservation"))
  _apply-ruler(out, options.at("ruler"), 1, 10)
  _add(out, options.at("commands"))
  out
}

#let _build-recipe(alignment, item) = {
  let name = item.at("name")
  let options = item.at("options")
  if name == "publication" {
    _build-publication(alignment, options)
  } else if name == "motif-map" {
    _build-motif-map(alignment, options)
  } else if name == "structure-map" {
    _build-structure-map(alignment, options)
  } else if name == "logo-analysis" {
    _build-logo-analysis(alignment, options)
  } else if name == "overview" {
    _build-overview(alignment, options)
  } else {
    ()
  }
}

#let resolve-figure(source, format, figure) = {
  let out = ()
  let items = if type(figure) == array { figure } else { (figure,) }
  let needs-alignment = false
  for item in items {
    if _is-recipe(item) {
      needs-alignment = true
    }
  }
  let alignment = if needs-alignment { read-alignment(source, format: format) } else { none }
  for item in items {
    if _is-recipe(item) {
      _add(out, _build-recipe(alignment, item))
    } else {
      _add(out, item)
    }
  }
  out
}
