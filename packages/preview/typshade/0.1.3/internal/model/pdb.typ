// Copyright (C) 2026 Eito Yoneyama
// SPDX-License-Identifier: GPL-2.0

#import "parser.typ": _source-text, _split-lines, _upper

#let _field(line, start, stop) = if line.len() >= stop {
  line.slice(start, stop).trim()
} else {
  ""
}

#let _vec-sub(a, b) = (
  x: a.at("x") - b.at("x"),
  y: a.at("y") - b.at("y"),
  z: a.at("z") - b.at("z"),
)

#let _vec-dot(a, b) = a.at("x") * b.at("x") + a.at("y") * b.at("y") + a.at("z") * b.at("z")
#let _vec-len2(a) = _vec-dot(a, a)

#let _vec-cross(a, b) = (
  x: a.at("y") * b.at("z") - a.at("z") * b.at("y"),
  y: a.at("z") * b.at("x") - a.at("x") * b.at("z"),
  z: a.at("x") * b.at("y") - a.at("y") * b.at("x"),
)

#let _read-pdb-atoms(source) = {
  let atoms = ()
  for line in _split-lines(_source-text(source)) {
    if not (line.starts-with("ATOM") or line.starts-with("HETATM")) or line.len() < 54 {
      continue
    }
    let res = _field(line, 22, 26)
    let x = _field(line, 30, 38)
    let y = _field(line, 38, 46)
    let z = _field(line, 46, 54)
    if res == "" or x == "" or y == "" or z == "" {
      continue
    }
    atoms.push((
      atom: _upper(_field(line, 12, 16)),
      residue: int(res),
      x: float(x),
      y: float(y),
      z: float(z),
    ))
  }
  atoms
}

#let _atoms-for-residue(atoms, residue) = {
  let out = ()
  for atom in atoms {
    if atom.at("residue") == residue {
      out.push(atom)
    }
  }
  out
}

#let _atom-point(atom) = (x: atom.at("x"), y: atom.at("y"), z: atom.at("z"))

#let _anchor-point(atoms, residue, atom-kind) = {
  let residue-atoms = _atoms-for-residue(atoms, residue)
  if residue-atoms.len() == 0 {
    return none
  }
  let ca = none
  for atom in residue-atoms {
    if atom.at("atom") == "CA" {
      ca = atom
    }
  }
  if _upper(str(atom-kind)) == "CA" and ca != none {
    return _atom-point(ca)
  }
  let backbone = ("N", "CA", "C", "O")
  let best = none
  let best-distance = -1.0
  let origin = if ca == none { residue-atoms.first() } else { ca }
  for atom in residue-atoms {
    if backbone.contains(atom.at("atom")) and residue-atoms.len() > backbone.len() {
      continue
    }
    let distance = _vec-len2(_vec-sub(_atom-point(atom), _atom-point(origin)))
    if distance > best-distance {
      best = atom
      best-distance = distance
    }
  }
  if best == none { _atom-point(residue-atoms.first()) } else { _atom-point(best) }
}

#let _parse-anchor(text) = {
  let hit = str(text).trim().matches(regex("^(-?\\d+)(?:\\[([^\\]]+)\\])?$"))
  if hit.len() == 0 {
    return none
  }
  let captures = hit.first().captures
  (residue: int(captures.at(0)), atom: captures.at(1, default: "side"))
}

#let _parse-pdb-selection(selection) = {
  if type(selection) == dictionary and selection.at("kind", default: none) == "pdb-selection" {
    return selection
  }
  let hit = str(selection).trim().matches(regex("^(point|line|plane)(?:\\[([^\\]]+)\\])?:(.+)$"))
  if hit.len() == 0 {
    return none
  }
  let captures = hit.first().captures
  let kind = captures.at(0)
  let distance = if captures.at(1, default: "") == "" { 1.0 } else { float(captures.at(1)) }
  let parts = captures.at(2).split(",").map(part => part.trim()).filter(part => part != "")
  if parts.len() < 2 {
    return none
  }
  let anchors = ()
  for part in parts.slice(1) {
    let anchor = _parse-anchor(part)
    if anchor != none {
      anchors.push(anchor)
    }
  }
  (kind: "pdb-selection", shape: kind, distance: distance, source: parts.first(), anchors: anchors)
}

#let _distance2-to-segment(point, a, b) = {
  let ab = _vec-sub(b, a)
  let denom = _vec-len2(ab)
  if denom == 0 {
    return _vec-len2(_vec-sub(point, a))
  }
  let t = calc.max(0.0, calc.min(1.0, _vec-dot(_vec-sub(point, a), ab) / denom))
  let projected = (x: a.at("x") + ab.at("x") * t, y: a.at("y") + ab.at("y") * t, z: a.at("z") + ab.at("z") * t)
  _vec-len2(_vec-sub(point, projected))
}

#let _distance2-to-plane(point, a, b, c) = {
  let normal = _vec-cross(_vec-sub(b, a), _vec-sub(c, a))
  let denom = _vec-len2(normal)
  if denom == 0 {
    return _distance2-to-segment(point, a, b)
  }
  let numerator = _vec-dot(_vec-sub(point, a), normal)
  numerator * numerator / denom
}

#let _residue-numbers(atoms) = {
  let seen = (:)
  let out = ()
  for atom in atoms {
    let key = str(atom.at("residue"))
    if not seen.keys().contains(key) {
      seen.insert(key, true)
      out.push(atom.at("residue"))
    }
  }
  out.sorted()
}

#let _pdb-selection-positions(selection) = {
  let parsed = _parse-pdb-selection(selection)
  if parsed == none {
    return none
  }
  let atoms = _read-pdb-atoms(parsed.at("source"))
  let anchors = ()
  for anchor in parsed.at("anchors") {
    let point = _anchor-point(atoms, anchor.at("residue"), anchor.at("atom"))
    if point != none {
      anchors.push(point)
    }
  }
  let shape = parsed.at("shape", default: parsed.at("kind"))
  let required = if shape == "point" { 1 } else if shape == "line" { 2 } else { 3 }
  if anchors.len() < required {
    return ()
  }
  let max-distance2 = parsed.at("distance") * parsed.at("distance")
  let out = ()
  for residue in _residue-numbers(atoms) {
    let selected = false
    for atom in _atoms-for-residue(atoms, residue) {
      let point = _atom-point(atom)
      let distance2 = if shape == "point" {
        _vec-len2(_vec-sub(point, anchors.at(0)))
      } else if shape == "line" {
        _distance2-to-segment(point, anchors.at(0), anchors.at(1))
      } else {
        _distance2-to-plane(point, anchors.at(0), anchors.at(1), anchors.at(2))
      }
      if distance2 <= max-distance2 {
        selected = true
      }
    }
    if selected {
      out.push(residue)
    }
  }
  out
}

#let pdb-selection-list(selection) = {
  let positions = _pdb-selection-positions(selection)
  if positions == none {
    return str(selection)
  }
  positions.map(pos => str(pos)).join(",")
}
