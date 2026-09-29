/// Render chemical structures from Molfile, SDF, and SMILES inputs.
///
/// The public API provides molecule renderers, annotation builders, and anchor
/// helpers for publication-oriented chemical figures.
#import "@preview/alchemist:0.2.0": *

#let mol-plugin = plugin("molchemist_plugin.wasm")
#let smiles-plugin = plugin("molchemist_smiles_plugin.wasm")
#let _structure-name = "molchemist-structure"

#let get-b-func(b-type) = {
  if b-type == "double" { double }
  else if b-type == "triple" { triple }
  else if b-type == "cram-filled-right" { cram-filled-right }
  else if b-type == "cram-filled-left" { cram-filled-left }
  else if b-type == "cram-dashed-right" { cram-dashed-right }
  else if b-type == "cram-dashed-left" { cram-dashed-left }
  else { single }
}

#let _render-ast(cmds, base-sep, config: (:)) = {
  for cmd in cmds {
    if cmd.type == "fragment" {
      let f-args = (:)

      if cmd.name != "" {
        f-args.insert("name", cmd.name)
      }

      let l-dict = (:)
      if cmd.links.len() > 0 {
        for l in cmd.links {
          let b-func = get-b-func(l.bondType)
          let l-args = (
            absolute: l.angle * 1deg,
            atom-sep: base-sep * l.lengthScale
          )
          if "offset" in l and l.offset != none {
            l-args.insert("offset", l.offset)
          }
          if "name" in l and l.name != "" {
            l-args.insert("name", l.name)
          }
          l-dict.insert(l.target, b-func(..l-args))
        }
      }

      if cmd.element != "" {
        if l-dict.len() > 0 {
          f-args.insert("links", l-dict)
        }
        fragment(cmd.element, ..f-args)
      } else {
        if cmd.name != "" {
          hook(cmd.name)
        }
        if l-dict.len() > 0 {
          branch({
            single(absolute: 0deg, atom-sep: 0pt, stroke: none, name: cmd.name + "-links", links: l-dict)
          })
        }
      }

    } else if cmd.type == "bond" {
      let b-func = get-b-func(cmd.bondType)
      let args = (
        absolute: cmd.angle * 1deg,
        atom-sep: base-sep * cmd.lengthScale
      )
      if "offset" in cmd and cmd.offset != none {
        args.insert("offset", cmd.offset)
      }
      if "name" in cmd and cmd.name != "" {
        args.insert("name", cmd.name)
      }
      b-func(..args)
    } else if cmd.type == "branch" {
      branch(_render-ast(cmd.body, base-sep, config: config))
    }
  }
}

#let _collect-annotations(cmds) = {
  let notes = ()
  for cmd in cmds {
    if cmd.type == "fragment" and "annotation" in cmd and cmd.annotation != none {
      let label = if cmd.element != "" { cmd.element } else { cmd.name }
      notes.push(label + " " + cmd.annotation + " (" + cmd.name + ")")
    } else if cmd.type == "branch" {
      for note in _collect-annotations(cmd.body) {
        notes.push(note)
      }
    }
  }
  notes
}

/// Create a free arrow overlay drawn after the molecule.
///
/// - from (any): Source anchor or CeTZ coordinate.
/// - to (any): Destination anchor or CeTZ coordinate.
/// - label (content, none): Optional content placed near the arrow midpoint.
/// - from-anchor (str): Anchor used when `from` is a named object.
/// - to-anchor (str): Anchor used when `to` is a named object.
/// - label-anchor (str): CeTZ anchor used to place the label.
/// - label-offset (array): Relative label offset from the arrow midpoint.
/// - mark (any): CeTZ line mark configuration.
/// - stroke (any): CeTZ stroke configuration.
/// - boxed (bool): Whether to draw a background box around the label.
/// - label-size (length): Label text size.
/// - label-fill (any): Label box fill.
/// - label-stroke (any): Label box stroke.
/// - label-inset (any): Label box inset.
/// - label-radius (length): Label box corner radius.
/// - name (str, none): Optional CeTZ object name.
/// -> dictionary
#let arrow-annotation(
  from,
  to,
  label: none,
  from-anchor: "mid",
  to-anchor: "mid",
  label-anchor: "south",
  label-offset: (0, 0.45),
  mark: (end: ">>", fill: black),
  stroke: black,
  boxed: false,
  label-size: 0.85em,
  label-fill: white,
  label-stroke: 0.35pt + luma(72%),
  label-inset: 2pt,
  label-radius: 2pt,
  name: none,
) = (
  type: "arrow",
  from: from,
  to: to,
  label: label,
  from-anchor: from-anchor,
  to-anchor: to-anchor,
  label-anchor: label-anchor,
  label-offset: label-offset,
  mark: mark,
  stroke: stroke,
  boxed: boxed,
  label-size: label-size,
  label-fill: label-fill,
  label-stroke: label-stroke,
  label-inset: label-inset,
  label-radius: label-radius,
  name: name,
)

/// Create a free text label without a leader line.
///
/// - at (any): Target anchor or CeTZ coordinate.
/// - label (content): Label content.
/// - anchor (str): Anchor used to resolve `at`.
/// - label-anchor (str): CeTZ anchor used to place the label.
/// - offset (array): Relative offset from the target.
/// - boxed (bool): Whether to draw a background box around the label.
/// - label-size (length): Label text size.
/// - label-fill (any): Label box fill.
/// - label-stroke (any): Label box stroke.
/// - label-inset (any): Label box inset.
/// - label-radius (length): Label box corner radius.
/// - name (str, none): Optional CeTZ object name.
/// -> dictionary
#let label-annotation(
  at,
  label,
  anchor: "mid",
  label-anchor: "south",
  offset: (0, 0.45),
  boxed: false,
  label-size: 0.85em,
  label-fill: white,
  label-stroke: 0.35pt + luma(72%),
  label-inset: 2pt,
  label-radius: 2pt,
  name: none,
) = (
  type: "label",
  at: at,
  label: label,
  anchor: anchor,
  label-anchor: label-anchor,
  offset: offset,
  boxed: boxed,
  label-size: label-size,
  label-fill: label-fill,
  label-stroke: label-stroke,
  label-inset: label-inset,
  label-radius: label-radius,
  name: name,
)

/// Create an external publication-style label with a leader line.
///
/// Automatic placement uses `side`; explicit CeTZ coordinates can override the
/// label and either end of the leader for final figure adjustments.
///
/// - at (any): Target anchor or CeTZ coordinate.
/// - label (content): Label content.
/// - anchor (str): Anchor used to resolve `at`.
/// - side (str): Placement preset: `"east"`, `"west"`, `"north"`, `"south"`, or a diagonal combination.
/// - label-at (auto, dictionary, str, array): Explicit label coordinate, or `auto`.
/// - label-offset (auto, array): Relative label offset used by automatic placement.
/// - target-offset (auto, array): Relative endpoint offset from the target.
/// - target-gap (int, float): Automatic clearance between the leader and target.
/// - label-anchor (auto, str): CeTZ anchor for the label content.
/// - leader (str): Leader style: `"curve"`, `"straight"`, or `"elbow"`.
/// - leader-start (auto, dictionary, str, array): Explicit leader start coordinate.
/// - leader-end (auto, dictionary, str, array): Explicit leader end coordinate.
/// - leader-points (array): Intermediate CeTZ coordinates for routing the leader.
/// - leader-start-offset (array): Fine adjustment applied to the leader start.
/// - leader-end-offset (array): Fine adjustment applied to the leader end.
/// - mark (any): Optional CeTZ line mark configuration.
/// - stroke (any): CeTZ stroke configuration for the leader.
/// - label-size (length): Label text size.
/// - label-gap (int, float): Clearance between an unboxed label and its leader.
/// - label-inset (any): Label box inset.
/// - label-radius (length): Label box corner radius.
/// - label-fill (any): Label box fill.
/// - label-stroke (any): Label box stroke.
/// - boxed (bool): Whether to draw a background box around the label.
/// - name (str, none): Optional CeTZ object name.
/// -> dictionary
#let callout-annotation(
  at,
  label,
  anchor: "mid",
  side: "north-east",
  label-at: auto,
  label-offset: auto,
  target-offset: auto,
  target-gap: 0.2,
  label-anchor: auto,
  leader: "curve",
  leader-start: auto,
  leader-end: auto,
  leader-points: (),
  leader-start-offset: (0, 0),
  leader-end-offset: (0, 0),
  mark: none,
  stroke: luma(40%) + 0.35pt,
  label-size: 0.82em,
  label-gap: 0.14,
  label-inset: 2.2pt,
  label-radius: 3pt,
  label-fill: white,
  label-stroke: 0.35pt + luma(70%),
  boxed: false,
  name: none,
) = (
  type: "callout",
  at: at,
  label: label,
  anchor: anchor,
  side: side,
  label-at: label-at,
  label-offset: label-offset,
  target-offset: target-offset,
  target-gap: target-gap,
  label-anchor: label-anchor,
  leader: leader,
  leader-start: leader-start,
  leader-end: leader-end,
  leader-points: leader-points,
  leader-start-offset: leader-start-offset,
  leader-end-offset: leader-end-offset,
  mark: mark,
  stroke: stroke,
  label-size: label-size,
  label-gap: label-gap,
  label-inset: label-inset,
  label-radius: label-radius,
  label-fill: label-fill,
  label-stroke: label-stroke,
  boxed: boxed,
  name: name,
)

/// Create an annotation that runs custom CeTZ drawing code.
///
/// - body (function): Function receiving the generated molecule group name.
/// - name (str, none): Optional annotation name retained in the descriptor.
/// -> dictionary
#let cetz-annotation(body, name: none) = (
  type: "cetz",
  body: body,
  name: name,
)

/// Return the internal CeTZ object name for an atom.
///
/// - index (int): Atom index shown by `show-indices`.
/// -> str
#let atom-ref(index) = _structure-name + ".a" + str(index)

/// Select an anchor on a rendered atom.
///
/// - index (int): Atom index shown by `show-indices`.
/// - anchor (str): CeTZ anchor such as `"mid"`, `"north"`, or `"east"`.
/// -> dictionary
#let atom-anchor(index, anchor: "mid") = (kind: "atom", index: index, anchor: anchor)

/// Return the internal CeTZ object name for a bond.
///
/// - index (int): Bond index shown by `show-indices`.
/// -> str
#let bond-ref(index) = _structure-name + ".b" + str(index)

/// Select an anchor on a rendered bond.
///
/// - index (int): Bond index shown by `show-indices`.
/// - anchor (str): CeTZ path anchor, such as `"50%"`.
/// -> dictionary
#let bond-anchor(index, anchor: "50%") = (kind: "bond", index: index, anchor: anchor)

/// Select an anchor on the complete rendered molecule.
///
/// - anchor (str): CeTZ group anchor such as `"center"`, `"north"`, or `"east"`.
/// -> dictionary
#let molecule-anchor(anchor: "center") = (kind: "molecule", anchor: anchor)

#let _normalized-annotations(annotations) = {
  if annotations == none {
    ()
  } else if type(annotations) == array {
    annotations
  } else {
    (annotations,)
  }
}

#let _annotation-anchor(name, anchor: "mid") = {
  if type(name) == dictionary {
    let kind = name.at("kind", default: none)
    if kind == "atom" {
      (
        name: _structure-name,
        anchor: "a" + str(name.at("index")) + "." + name.at("anchor", default: anchor),
      )
    } else if kind == "bond" {
      (
        name: _structure-name,
        anchor: "b" + str(name.at("index")) + "." + name.at("anchor", default: anchor),
      )
    } else if kind == "molecule" {
      let resolved-anchor = name.at("anchor", default: anchor)
      if resolved-anchor == "default" {
        resolved-anchor = "center"
      }
      (name: _structure-name, anchor: resolved-anchor)
    } else if "to" in name {
      let coord = name
      coord.insert("to", _annotation-anchor(coord.to, anchor: anchor))
      coord
    } else {
      name
    }
  } else if type(name) == str {
    if anchor == "default" or anchor == "mid" {
      name
    } else {
      name + "." + anchor
    }
  } else {
    (name: str(name), anchor: anchor)
  }
}

#let _annotation-label-body(annotation, label) = {
  let body = text(
    size: annotation.at("label-size", default: 0.85em),
    fill: annotation.at("label-text-fill", default: black),
  )[#label]

  if annotation.at("boxed", default: false) {
    box(
      inset: annotation.at("label-inset", default: 2pt),
      radius: annotation.at("label-radius", default: 2pt),
      fill: annotation.at("label-fill", default: white),
      stroke: annotation.at("label-stroke", default: 0.35pt + luma(72%)),
      body,
    )
  } else {
    body
  }
}

#let _sign(value) = {
  if value > 0 { 1 } else if value < 0 { -1 } else { 0 }
}

#let _callout-placement(side) = {
  if side == "east" {
    (offset: (1.65, 0), anchor: "west")
  } else if side == "west" {
    (offset: (-1.65, 0), anchor: "east")
  } else if side == "north" {
    (offset: (0, 1.35), anchor: "south")
  } else if side == "south" {
    (offset: (0, -1.35), anchor: "north")
  } else if side == "north-east" {
    (offset: (1.45, 1.15), anchor: "west")
  } else if side == "north-west" {
    (offset: (-1.45, 1.15), anchor: "east")
  } else if side == "south-east" {
    (offset: (1.45, -1.15), anchor: "west")
  } else if side == "south-west" {
    (offset: (-1.45, -1.15), anchor: "east")
  } else {
    panic("callout side must be east, west, north, south, north-east, north-west, south-east, or south-west")
  }
}

#let _callout-target-offset(label-offset, mark, gap: 0.2) = {
  if mark != none {
    (0, 0)
  } else {
    // Stop leader lines just short of atom labels/bonds so callouts read as
    // annotations rather than extra chemical bonds.
    (_sign(label-offset.at(0)) * gap, _sign(label-offset.at(1)) * gap)
  }
}

#let _callout-label-offset(label-offset, label-gap) = {
  // Keep leader lines visually separate from unboxed label text.
  (-_sign(label-offset.at(0)) * label-gap, -_sign(label-offset.at(1)) * label-gap)
}

#let _normalize-cetz-coordinate(coord) = {
  if type(coord) == dictionary or type(coord) == str {
    _annotation-anchor(coord)
  } else {
    coord
  }
}

#let _offset-coordinate(coord, offset) = {
  if offset == none or offset == (0, 0) {
    coord
  } else {
    (to: coord, rel: offset)
  }
}

#let _normalized-leader-points(points) = {
  if points == none {
    ()
  } else if type(points) == array {
    points
  } else {
    (points,)
  }
}

#let _callout-leader-points(start, via, end) = {
  let points = (_normalize-cetz-coordinate(start),)
  for point in _normalized-leader-points(via) {
    points.push(_normalize-cetz-coordinate(point))
  }
  points.push(_normalize-cetz-coordinate(end))
  points
}

#let _index-label-body(label) = {
  box(
    inset: 1.4pt,
    radius: 2pt,
    fill: white,
    stroke: 0.3pt + luma(70%),
    text(size: 0.55em, fill: luma(35%))[#label],
  )
}

#let _show-index-kind(show-indices, kind) = {
  if show-indices == false or show-indices == none {
    false
  } else if show-indices == true {
    true
  } else if type(show-indices) == str {
    if show-indices == "all" or show-indices == "atoms" or show-indices == "bonds" {
      show-indices == "all" or show-indices == kind
    } else {
      panic("show-indices must be false, true, \"atoms\", \"bonds\", or \"all\"")
    }
  } else {
    panic("show-indices must be false, true, \"atoms\", \"bonds\", or \"all\"")
  }
}

#let _collect-visible-atom-names(cmds) = {
  let names = ()
  for cmd in cmds {
    if cmd.type == "fragment" {
      if cmd.element != "" and cmd.name != "" {
        names.push(cmd.name)
      }
    } else if cmd.type == "branch" {
      for name in _collect-visible-atom-names(cmd.body) {
        names.push(name)
      }
    }
  }
  names
}

#let _render-index-labels(cmds, show-indices) = {
  if not _show-index-kind(show-indices, "atoms") and not _show-index-kind(show-indices, "bonds") {
    return
  }

  let visible-atoms = _collect-visible-atom-names(cmds)

  for cmd in cmds {
    if cmd.type == "fragment" {
      if _show-index-kind(show-indices, "atoms") and cmd.element != "" and cmd.name != "" {
        cetz.draw.content(
          (name: _structure-name, anchor: cmd.name + ".mid"),
          _index-label-body(cmd.name),
          anchor: "south-east",
        )
      }
      if _show-index-kind(show-indices, "bonds") and cmd.links.len() > 0 {
        for l in cmd.links {
          if cmd.element != "" and l.target in visible-atoms and "name" in l and l.name != "" {
            cetz.draw.content(
              (name: _structure-name, anchor: l.name + ".50%"),
              _index-label-body(l.name),
              anchor: "center",
            )
          }
        }
      }
    } else if cmd.type == "bond" {
      if _show-index-kind(show-indices, "bonds") and "name" in cmd and cmd.name != "" {
        cetz.draw.content(
          (name: _structure-name, anchor: cmd.name + ".50%"),
          _index-label-body(cmd.name),
          anchor: "center",
        )
      }
    } else if cmd.type == "branch" {
      _render-index-labels(cmd.body, show-indices)
    }
  }
}

#let _render-overlay-annotations(annotations) = {
  for (idx, annotation) in _normalized-annotations(annotations).enumerate() {
    let kind = annotation.at("type", default: "arrow")
    let name = annotation.at("name", default: none)
    if name == none {
      name = "molchemist-annotation-" + str(idx)
    }

    if kind == "arrow" {
      let from = _annotation-anchor(
        annotation.at("from"),
        anchor: annotation.at("from-anchor", default: "mid"),
      )
      let to = _annotation-anchor(
        annotation.at("to"),
        anchor: annotation.at("to-anchor", default: "mid"),
      )
      cetz.draw.line(
        from,
        to,
        name: name,
        stroke: annotation.at("stroke", default: black),
        mark: annotation.at("mark", default: (end: ">>", fill: black)),
      )
      let label = annotation.at("label", default: none)
      if label != none {
        cetz.draw.content(
          (
            rel: annotation.at("label-offset", default: (0, 0)),
            to: name + ".50%",
          ),
          _annotation-label-body(annotation, label),
          anchor: annotation.at("label-anchor", default: "south"),
        )
      }
    } else if kind == "label" {
      cetz.draw.content(
        (
          rel: annotation.at("offset", default: (0, 0)),
          to: _annotation-anchor(
            annotation.at("at"),
            anchor: annotation.at("anchor", default: "mid"),
          ),
        ),
        _annotation-label-body(annotation, annotation.at("label")),
        name: name,
        anchor: annotation.at("label-anchor", default: "south"),
      )
    } else if kind == "callout" {
      let target = _annotation-anchor(
        annotation.at("at"),
        anchor: annotation.at("anchor", default: "mid"),
      )
      let placement = _callout-placement(annotation.at("side", default: "north-east"))
      let label-offset = annotation.at("label-offset", default: auto)
      if label-offset == auto {
        label-offset = placement.offset
      }
      let label-anchor = annotation.at("label-anchor", default: auto)
      if label-anchor == auto {
        label-anchor = placement.anchor
      }
      let label-position = annotation.at("label-at", default: auto)
      if label-position == auto {
        label-position = (
          rel: label-offset,
          to: target,
        )
      } else {
        label-position = _normalize-cetz-coordinate(label-position)
      }
      let label-gap = annotation.at("label-gap", default: 0.14)
      let label-start = annotation.at("leader-start", default: auto)
      if label-start == auto {
        label-start = (
          rel: _callout-label-offset(label-offset, label-gap),
          to: label-position,
        )
      } else {
        label-start = _normalize-cetz-coordinate(label-start)
      }
      label-start = _offset-coordinate(
        label-start,
        annotation.at("leader-start-offset", default: (0, 0)),
      )
      let target-offset = annotation.at("target-offset", default: auto)
      if target-offset == auto {
        target-offset = _callout-target-offset(
          label-offset,
          annotation.at("mark", default: none),
          gap: annotation.at("target-gap", default: 0.2),
        )
      }
      let target-end = annotation.at("leader-end", default: auto)
      if target-end == auto {
        target-end = (
          rel: target-offset,
          to: target,
        )
      } else {
        target-end = _normalize-cetz-coordinate(target-end)
      }
      target-end = _offset-coordinate(
        target-end,
        annotation.at("leader-end-offset", default: (0, 0)),
      )
      let leader = annotation.at("leader", default: "curve")
      let leader-points = annotation.at("leader-points", default: ())
      let path-points = _callout-leader-points(label-start, leader-points, target-end)
      if leader == "curve" {
        cetz.draw.hobby(
          ..path-points,
          name: name + "-leader",
          stroke: annotation.at("stroke", default: luma(40%) + 0.35pt),
          mark: annotation.at("mark", default: none),
        )
      } else if leader == "straight" {
        cetz.draw.line(
          ..path-points,
          name: name + "-leader",
          stroke: annotation.at("stroke", default: luma(40%) + 0.35pt),
          mark: annotation.at("mark", default: none),
        )
      } else if leader == "elbow" {
        if _normalized-leader-points(leader-points).len() > 0 {
          cetz.draw.line(
            ..path-points,
            name: name + "-leader",
            stroke: annotation.at("stroke", default: luma(40%) + 0.35pt),
            mark: annotation.at("mark", default: none),
          )
        } else {
          let elbow = (
            rel: (0, label-offset.at(1)),
            to: target,
          )
          cetz.draw.line(
            label-start,
            elbow,
            target-end,
            name: name + "-leader",
            stroke: annotation.at("stroke", default: luma(40%) + 0.35pt),
            mark: annotation.at("mark", default: none),
          )
        }
      } else {
        panic("callout leader must be \"curve\", \"elbow\", or \"straight\"")
      }
      cetz.draw.content(
        label-position,
        _annotation-label-body(annotation, annotation.at("label")),
        name: name,
        anchor: label-anchor,
      )
    } else if kind == "cetz" {
      let body = annotation.at("body")
      body(_structure-name)
    } else {
      panic("Unknown molchemist annotation type: " + repr(kind))
    }
  }
}

#let _render-graphic(ast, base-sep, config: (:), overlay-annotations: none, show-indices: false) = {
  cetz.canvas({
    draw-skeleton(config: config, name: _structure-name, {
      _render-ast(ast, base-sep, config: config)
    })
    _render-index-labels(ast, show-indices)
    _render-overlay-annotations(overlay-annotations)
  })
}

#let _v15-or-later() = {
  sys.version >= version(0, 15, 0)
}

#let _mol-data-to-bytes(data) = {
  if _v15-or-later() and repr(type(data)) == "path" {
    read(data, encoding: none)
  } else if type(data) == bytes {
    data
  } else {
    bytes(data)
  }
}

/// Render a molecule from Molfile or SDF data.
///
/// Input coordinates are preserved. On Typst 0.15.0 and later, `data` may be a
/// `path`; earlier versions should pass the result of `read`.
///
/// - data (any): Molfile/SDF text, bytes, or a Typst 0.15.0+ path.
/// - abbreviate (bool): Fold common hydrogens and terminal groups into labels.
/// - skeletal (bool): Draw a skeletal formula; overrides `abbreviate`.
/// - dump (bool): Show generated Alchemist source instead of rendering.
/// - config (dictionary): Visual configuration passed to Alchemist.
/// - annotations (dictionary, array, none): Overlay annotation or annotation array.
/// - show-indices (bool, str): Show `"atoms"`, `"bonds"`, or `"all"` indices for authoring.
/// -> content
#let render-mol(data, abbreviate: false, skeletal: false, dump: false, config: (:), annotations: none, show-indices: false) = {
  let mode = "full"
  if skeletal {
    mode = "skeletal"
  } else if abbreviate {
    mode = "abbreviate"
  }

  let base-sep = config.at("atom-sep", default: 3em)
  let mol-data = _mol-data-to-bytes(data)

  if dump {
    let code = str(mol-plugin.sdf_to_code(mol-data, bytes(mode), bytes(repr(base-sep)), bytes("2")))
    return raw(code, block: true, lang: "typst")
  } else {
    let ast = cbor(mol-plugin.sdf_to_ast(mol-data, bytes(mode)))
    _render-graphic(ast, base-sep, config: config, overlay-annotations: annotations, show-indices: show-indices)
  }
}

/// Parse, lay out, and render a molecule from a SMILES string.
///
/// The generated 2D coordinates are passed through the same Alchemist rendering
/// pipeline as Molfile/SDF input.
///
/// - smiles (str): SMILES notation for one molecule.
/// - abbreviate (bool): Fold common hydrogens and terminal groups into labels.
/// - skeletal (bool): Draw a skeletal formula; overrides `abbreviate`.
/// - dump (bool): Show generated Alchemist source instead of rendering.
/// - config (dictionary): Visual configuration passed to Alchemist.
/// - annotations (dictionary, array, none): Overlay annotation or annotation array.
/// - show-indices (bool, str): Show `"atoms"`, `"bonds"`, or `"all"` indices for authoring.
/// -> content
#let render-smiles(smiles, abbreviate: false, skeletal: false, dump: false, config: (:), annotations: none, show-indices: false) = {
  let mode = "full"
  if skeletal {
    mode = "skeletal"
  } else if abbreviate {
    mode = "abbreviate"
  }

  let base-sep = config.at("atom-sep", default: 3em)
  let layout-input = if mode == "full" {
    mol-plugin.smiles_to_full_layout_input(bytes(smiles))
  } else {
    mol-plugin.smiles_to_layout_input(bytes(smiles))
  }
  let coords = smiles-plugin.layout_coordinates(layout-input)

  if dump {
    let code = str(mol-plugin.smiles_to_code(bytes(smiles), coords, bytes(mode), bytes(repr(base-sep)), bytes("2")))
    raw(code, block: true, lang: "typst")
  } else {
    let ast = cbor(mol-plugin.smiles_to_ast(bytes(smiles), coords, bytes(mode)))
    let rendered = _render-graphic(ast, base-sep, config: config, overlay-annotations: annotations, show-indices: show-indices)
    let annotations = _collect-annotations(ast)
    if annotations.len() == 0 {
      rendered
    } else {
      stack(
        dir: ttb,
        spacing: 0.45em,
        rendered,
        text(size: 0.8em, fill: luma(80%))[
          Stereo annotations: #annotations.join(", ")
        ],
      )
    }
  }
}
