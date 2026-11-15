// Compose the molecular scene, CTfile overlays and user annotations.
#import "@preview/alchemist:0.2.0": cetz, fragment
#import "anchors.typ": _structure-name, _ctfile-atom-index
#import "bonds.typ": get-b-func
#import "labels.typ": _structured-atom-label
#import "layout.typ": coordinate-plan, draw-coordinate-plan, place-callouts
#import "ctfile.typ": _render-ctfile-overlays
#import "indices.typ": _render-index-labels
#import "annotation-renderer.typ": _normalized-annotations, _annotation-label-body, _render-overlay-annotations

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

#let _render-with-stereo-annotations(ast, rendered) = {
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

#let _render-graphic(ast, base-sep, config: (:), overlay-annotations: none, show-indices: false) = context {
  let label(cmd) = {
    if "attachment" in cmd {
      (body: math.equation(math.attach([∗], tr: [#cmd.attachment], br: std.hide([#cmd.attachment]))), offset: (0pt, 0pt))
    } else if "atom" in cmd {
      _structured-atom-label(cmd.atom, left: cmd.at("label-left", default: false), font: config.at("fragment-font", default: none))
    } else {
      let body = {
        set text(font: config.fragment-font) if config.at("fragment-font", default: none) != none
        show math.equation: math.upright
        for (part, _) in fragment(cmd.element).first().atoms { part }
      }
      (body: body, offset: (0pt, 0pt))
    }
  }
  let plan = coordinate-plan(ast, base-sep, label, config: config)
  let callouts = if config.at("auto-annotations", default: true) {
    place-callouts(_normalized-annotations(overlay-annotations), plan, base-sep, _annotation-label-body)
  } else { (annotations: _normalized-annotations(overlay-annotations), failures: ()) }
  if config.at("collision-policy", default: "report") == "error" {
    assert(callouts.failures.len() == 0, message: "Unable to place callout annotations: " + repr(callouts.failures))
  }
  let centers = (:)
  let labels = (:)
  for atom in plan.atoms {
    if "attachment" in atom.command { continue }
    let key = str(_ctfile-atom-index(atom.name))
    centers.insert(key, atom.name + ".mid")
    labels.insert(key, if atom.command.element == "" { none } else { atom.body })
  }
  metadata((kind: "molchemist-layout", scale: plan.scale, collisions: plan.collisions, unplaced-callouts: callouts.failures))
  cetz.canvas(baseline: (0pt, plan.baseline * base-sep), {
    draw-coordinate-plan(plan, base-sep, get-b-func, config: config, name: _structure-name)
    _render-ctfile-overlays(ast, base-sep * plan.scale, centers, labels, config: config)
    _render-index-labels(ast, show-indices)
    _render-overlay-annotations(callouts.annotations)
  })
}
