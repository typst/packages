// Copyright (C) 2026 Eito Yoneyama
// SPDX-License-Identifier: GPL-2.0

#let _translate-case(text, from, to) = {
  let out = ""
  for ch in text.clusters() {
    let idx = from.position(ch)
    out += if idx == none { ch } else { to.slice(idx, idx + 1) }
  }
  out
}

#let _upper(text) = {
  let lower = "abcdefghijklmnopqrstuvwxyz"
  let upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  _translate-case(str(text), lower, upper)
}

#let _lower(text) = {
  let lower = "abcdefghijklmnopqrstuvwxyz"
  let upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  _translate-case(str(text), upper, lower)
}

#let _split-lines(text) = text.replace("\r\n", "\n").replace("\r", "\n").split("\n")

#let _looks-like-source-text(source) = {
  let text = str(source)
  let trimmed = text.trim()
  text.contains("\n") or trimmed.starts-with(">") or trimmed.starts-with("CLUSTAL") or trimmed.starts-with("MUSCLE") or trimmed.starts-with("ATOM") or trimmed.starts-with("HETATM") or text.contains(" MSF: ") or text.contains("!!AA_MULTIPLE_ALIGNMENT") or text.contains("!!NA_MULTIPLE_ALIGNMENT") or trimmed.matches(regex("^\\S+\\s+[A-Za-z\\-\\.]+$")).len() > 0
}

#let _source-text(source) = {
  if type(source) == bytes {
    str(source)
  } else {
    assert(type(source) == str and _looks-like-source-text(source))
    source
  }
}

#let _strip-empty(lines) = {
  let out = ()
  for line in lines {
    if line != "" {
      out.push(line)
    }
  }
  out
}

#let _chars(text) = {
  let out = ()
  for ch in str(text).clusters() {
    out.push(ch)
  }
  out
}

#let _repeat(value, times) = {
  let out = ()
  for _ in range(0, times) {
    out.push(value)
  }
  out
}

#let _array-fill(length, value) = {
  let out = ()
  for _ in range(0, length) {
    out.push(if type(value) == dictionary { value + (:) } else { value })
  }
  out
}

#let _clone-array(items) = {
  let out = ()
  for item in items {
    out.push(item)
  }
  out
}

#let _guess-seq-type(sequences) = {
  let dna = "ACGTUNRYKMWSBDHV.-"
  let protein = "ABCDEFGHIKLMNPQRSTVWXYZOUJ.-"
  let dna-only = 0
  let protein-only = 0
  for seq in sequences {
    for ch in _chars(_upper(seq.at("aligned"))) {
      if protein.contains(ch) {
        protein-only += 1
      }
      if dna.contains(ch) {
        dna-only += 1
      }
    }
  }
  if sequences.len() == 0 or (dna-only > 0 and protein-only == dna-only) {
    "N"
  } else {
    "P"
  }
}

#let _build-sequence(name, aligned, metadata) = {
  let positions = ()
  let raw = ""
  let pos = 0
  for ch in _chars(aligned) {
    if ch == "." or ch == "-" {
      positions.push(none)
    } else {
      pos += 1
      raw += ch
      positions.push(pos)
    }
  }
  (
    name: name,
    aligned: aligned,
    raw: raw,
    positions: positions,
    length: pos,
    metadata: metadata,
  )
}

#let parse-msf(text) = {
  let lines = _split-lines(text)
  let body = false
  let blocks = (:)
  let ignored = ()
  let declared-type = none
  for line in lines {
    let trimmed = line.trim()
    if trimmed == "//" {
      body = true
      continue
    }
    if not body {
      let ignored-hit = trimmed.matches(regex("^!Name:\\s+(\\S+)"))
      if ignored-hit.len() > 0 {
        ignored.push(ignored-hit.first().captures.at(0))
      }
      let type-hit = trimmed.matches(regex("Type:\\s*([PN])"))
      if type-hit.len() > 0 {
        declared-type = type-hit.first().captures.at(0)
      }
      continue
    }
    if trimmed == "" {
      continue
    }
    let hit = trimmed.matches(regex("^(\\S+)\\s+(.+)$"))
    if hit.len() == 0 {
      continue
    }
    let name = hit.first().captures.at(0)
    if name.matches(regex("^\\d+$")).len() > 0 {
      continue
    }
    let fragment = hit.first().captures.at(1).replace(" ", "")
    if not blocks.keys().contains(name) {
      blocks.insert(name, "")
    }
    blocks.insert(name, blocks.at(name) + fragment)
  }
  let sequences = ()
  for name in blocks.keys() {
    if not ignored.contains(name) {
      sequences.push(_build-sequence(name, blocks.at(name), (:)))
    }
  }
  (
    format: "MSF",
    name: "alignment",
    seq-type: if declared-type == none { _guess-seq-type(sequences) } else { declared-type },
    columns: if sequences.len() > 0 { sequences.first().at("aligned").len() } else { 0 },
    sequences: sequences,
  )
}

#let parse-aln(text) = {
  let lines = _split-lines(text)
  let pieces = (:)
  for line in lines {
    if line.trim() == "" or line.starts-with("CLUSTAL") or line.starts-with("MUSCLE") or line.starts-with(" ") {
      continue
    }
    let matches = line.matches(regex("^(\\S+)\\s+([A-Za-z\\-\\.]+)"))
    if matches.len() == 0 {
      continue
    }
    let hit = matches.first()
    let name = hit.captures.at(0)
    let fragment = hit.captures.at(1)
    if not pieces.keys().contains(name) {
      pieces.insert(name, "")
    }
    pieces.insert(name, pieces.at(name) + fragment)
  }
  let sequences = ()
  for name in pieces.keys() {
    sequences.push(_build-sequence(name, pieces.at(name), (:)))
  }
  (
    format: "ALN",
    name: "alignment",
    seq-type: _guess-seq-type(sequences),
    columns: if sequences.len() > 0 { sequences.first().at("aligned").len() } else { 0 },
    sequences: sequences,
  )
}

#let parse-fasta(text) = {
  let lines = _split-lines(text)
  let sequences = ()
  let current-name = none
  let current-seq = ""
  for line in lines {
    if line.starts-with(">") {
      if current-name != none {
        sequences.push(_build-sequence(current-name, current-seq, (:)))
      }
      let label = line.slice(1).trim()
      current-name = if label == "" { "seq" + str(sequences.len() + 1) } else { label.split(" ").first() }
      current-seq = ""
    } else if line.trim() != "" {
      current-seq += line.trim()
    }
  }
  if current-name != none {
    sequences.push(_build-sequence(current-name, current-seq, (:)))
  }
  (
    format: "FASTA",
    name: "alignment",
    seq-type: _guess-seq-type(sequences),
    columns: if sequences.len() > 0 { sequences.first().at("aligned").len() } else { 0 },
    sequences: sequences,
  )
}

#let read-alignment(source, format: auto) = {
  let text = _source-text(source)
  let detected = if format != auto {
    _upper(str(format))
  } else if text.trim().starts-with(">") {
    "FASTA"
  } else if text.contains(" MSF: ") {
    "MSF"
  } else {
    "ALN"
  }
  if detected == "MSF" {
    parse-msf(text)
  } else if detected == "FASTA" {
    parse-fasta(text)
  } else {
    parse-aln(text)
  }
}

#let read-tcoffee(source) = {
  let data = (:)
  let lines = _split-lines(_source-text(source))
  for line in lines {
    let trimmed = line.trim()
    let matches = trimmed.matches(regex("^(\\S+)\\s+\\d+\\s+([A-Za-z0-9\\-]+)\\s+\\d+$"))
    if matches.len() == 0 {
      continue
    }
    let name = matches.first().captures.at(0)
    let fragment = matches.first().captures.at(1)
    let scores = if data.keys().contains(name) { data.at(name) } else { () }
    for ch in _chars(fragment) {
      if ch == "-" {
        scores.push(none)
      } else if ch.matches(regex("\\d")).len() > 0 {
        scores.push(int(ch) * 10)
      } else {
        scores.push(0)
      }
    }
    data.insert(name, scores)
  }
  data
}

#let _run-lengths(chars, allowed) = {
  let regions = ()
  let active = false
  let start = 0
  for idx in range(0, chars.len()) {
    let hit = allowed.contains(chars.at(idx))
    if hit and not active {
      active = true
      start = idx + 1
    }
    if active and (not hit or idx == chars.len() - 1) {
      let stop = if hit and idx == chars.len() - 1 { idx + 1 } else { idx }
      regions.push((start, stop))
      active = false
    }
  }
  regions
}

#let read-hmmtop(source, sequence: none) = {
  let text = _source-text(source)
  if text.contains("Transmembrane helices:") {
    let name = text.matches(regex("Protein:\\s*(\\S+)")).first().captures.at(0)
    let orientation = text.matches(regex("N-terminus:\\s*(\\S+)")).first().captures.at(0)
    let spans-line = text.matches(regex("Transmembrane helices:\\s*([0-9\\- ]+)")).first().captures.at(0)
    let spans = ()
    for token in spans-line.split(" ") {
      if token.trim() == "" {
        continue
      }
      let hit = token.matches(regex("^(\\d+)-(\\d+)$")).first()
      spans.push((int(hit.captures.at(0)), int(hit.captures.at(1))))
    }
    return (name: name, orientation: orientation, spans: spans)
  }
  let lines = _split-lines(text)
  for line in lines {
    let trimmed = line.trim()
    if not trimmed.starts-with(">HP:") {
      continue
    }
    let hit = trimmed.matches(regex("^>HP:\\s*(\\d+)\\s+(\\S+)\\s+(\\S+)\\s+(\\d+)\\s+(.+)$")).first()
    let name = hit.captures.at(1)
    if sequence != none and name != str(sequence) {
      continue
    }
    let orientation = hit.captures.at(2)
    let values = _strip-empty(hit.captures.at(4).split(" "))
    let spans = ()
    let idx = 0
    while idx + 1 < values.len() {
      spans.push((int(values.at(idx)), int(values.at(idx + 1))))
      idx += 2
    }
    return (name: name, orientation: orientation, spans: spans)
  }
  (name: "", orientation: "IN", spans: ())
}

#let read-phd-topology(source) = {
  let runs = ""
  for line in _split-lines(_source-text(source)) {
    let matches = line.matches(regex("^\\s*PHDThtm\\s*\\|([^|]+)\\|"))
    if matches.len() > 0 {
      runs += matches.first().captures.at(0).replace(" ", "")
    }
  }
  (
    topology: runs,
    spans: _run-lengths(_chars(runs), "T"),
    internal: _run-lengths(_chars(runs), "iI"),
    external: _run-lengths(_chars(runs), "oO"),
  )
}

#let read-phd-secondary(source) = {
  let runs = ""
  for line in _split-lines(_source-text(source)) {
    let matches = line.matches(regex("^\\s*PHD sec\\s*\\|([^|]+)\\|"))
    if matches.len() > 0 {
      runs += matches.first().captures.at(0)
    }
  }
  (
    sequence: runs,
    alpha: _run-lengths(_chars(runs), "H"),
    beta: _run-lengths(_chars(runs), "E"),
    turn: _run-lengths(_chars(runs), "T"),
  )
}

#let _runs-from-entries(entries, allowed) = {
  let regions = ()
  let active = false
  let start = 0
  let last = 0
  for entry in entries {
    let pos = entry.at("pos")
    let code = entry.at("code")
    let hit = allowed.contains(code)
    let contiguous = active and pos == last + 1
    if hit and (not active or not contiguous) {
      if active {
        regions.push((start, last))
      }
      active = true
      start = pos
    } else if not hit and active {
      regions.push((start, last))
      active = false
    }
    last = pos
  }
  if active {
    regions.push((start, last))
  }
  regions
}

#let read-dssp(source, use-second-column: true) = {
  let entries = ()
  let started = false
  for line in _split-lines(_source-text(source)) {
    if not started {
      if line.contains("RESIDUE AA STRUCTURE") {
        started = true
      }
      continue
    }
    if line.trim() == "" or line.len() < 17 {
      continue
    }
    let first-field = line.slice(0, calc.min(5, line.len())).trim()
    let second-field = line.slice(calc.min(5, line.len()), calc.min(10, line.len())).trim()
    let aa = line.slice(calc.min(13, line.len()), calc.min(14, line.len())).trim()
    if aa == "" or aa == "!" {
      continue
    }
    let code = line.slice(calc.min(16, line.len()), calc.min(17, line.len())).trim()
    let pos = if use-second-column and second-field != "" {
      int(second-field)
    } else if first-field != "" {
      int(first-field)
    } else {
      entries.len() + 1
    }
    entries.push((pos: pos, code: if code == "" { "C" } else { code }))
  }
  (
    sequence: entries.map(entry => entry.at("code")).join(""),
    alpha: _runs-from-entries(entries, "H"),
    "3-10": _runs-from-entries(entries, "G"),
    pi: _runs-from-entries(entries, "I"),
    beta: _runs-from-entries(entries, "E"),
    bridge: _runs-from-entries(entries, "B"),
    turn: _runs-from-entries(entries, "T"),
    bend: _runs-from-entries(entries, "S"),
  )
}

#let read-stride(source) = {
  let entries = ()
  for line in _split-lines(_source-text(source)) {
    let trimmed = line.trim()
    if not trimmed.starts-with("ASG") {
      continue
    }
    let hit = trimmed.matches(regex("^ASG\\s+\\S+\\s+\\S+\\s+(-?\\d+)\\s+(-?\\d+)\\s+([A-Z])"))
    if hit.len() > 0 {
      let captures = hit.first().captures
      entries.push((pos: int(captures.at(1)), code: captures.at(2)))
      continue
    }
    let fields = _strip-empty(trimmed.split(" "))
    if fields.len() >= 6 {
      let pos = int(fields.at(4))
      let code = fields.at(5)
      entries.push((pos: pos, code: code))
    }
  }
  (
    sequence: entries.map(entry => entry.at("code")).join(""),
    alpha: _runs-from-entries(entries, "H"),
    "3-10": _runs-from-entries(entries, "G"),
    pi: _runs-from-entries(entries, "I"),
    beta: _runs-from-entries(entries, "E"),
    bridge: _runs-from-entries(entries, "B"),
    turn: _runs-from-entries(entries, "T"),
  )
}
