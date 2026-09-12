#import "util.typ": _merge

// --- Layout and spacing options ---------------------------------------------

#let _layouts = ("both", "right", "left", "down", "up", "radial", "star", "fishbone")

/// Every field a layout can have, with its default: `kind` is one of `both`,
/// `right`, `left`, `down`, `up`, `radial`, `star`, `fishbone`; `start` the
/// angle of the first branch in `radial` and `star`; `align-levels` puts
/// every level on one line in the tree layouts.
///
/// -> dictionary
#let layout-defaults = (kind: "both", start: 60deg, align-levels: false)

/// Every distance a map has, with its default. Along the direction of
/// growth: `level` between parent and child, `root` between the root and
/// its branches (the first ring in `radial` and `star`). Across it:
/// `sibling` between siblings, `branch` between the first-level branches.
/// `max-width` wraps longer labels. `brace` and `summary` size a summary
/// brace and its gaps, `cloud` pads a cloud, `label` is the gap between an edge
/// label and its edge, `padding` frames a coloured background. Lengths in `em` follow the font size around the map.
///
/// -> dictionary
#let spacing-defaults = (
  level: 3.5em, root: 6em, sibling: 0.7em, branch: 2em, max-width: 14em,
  brace: 0.6em, summary: 0.5em, cloud: 0.6em, label: 0.25em, padding: 1em,
)

#let _layout(l) = {
  let d = if type(l) == str { (kind: l) } else if type(l) == dictionary { l }
    else { panic("brainroot: layout must be a name or a dictionary") }
  let d = _merge(layout-defaults, d, "layout")
  assert(d.kind in _layouts, message: "brainroot: layout must be one of " + _layouts.join(", "))
  d
}

#let _spacing(sp) = _merge(spacing-defaults, sp, "spacing")
