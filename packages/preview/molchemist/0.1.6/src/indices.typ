// Authoring labels identify the same atoms and bonds used by public anchors.
#import "@preview/alchemist:0.2.0": cetz
#import "anchors.typ": _structure-name

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
