// CTfile display metadata: SGroups, highlights, queries and attachment sites.
#import "@preview/alchemist:0.2.0": cetz, utils
#import "anchors.typ": _structure-name
#import "bonds.typ": _molchemist-dashed-stroke

#let _ctfile-atom-center(atom-index, atom-centers) = {
  let key = str(atom-index)
  (
    name: _structure-name,
    anchor: atom-centers.at(key, default: "a" + key + ".0.mid"),
  )
}

#let _ctfile-point(point, base-sep, atom-centers) = (
  rel: (
    base-sep * point.offset.at(0),
    base-sep * point.offset.at(1),
  ),
  to: _ctfile-atom-center(point.atomIndex, atom-centers),
)

#let _ctfile-highlight-path(
  highlights,
  base-sep,
  atom-centers,
  atom-labels,
  paint,
  atom-radius,
  bond-thickness,
  label-padding,
) = {
  cetz.draw.get-ctx(cetz-ctx => {
    let atom-radius = utils.convert-length(cetz-ctx, base-sep * atom-radius)
    let bond-radius = utils.convert-length(cetz-ctx, base-sep * bond-thickness) / 2
    let label-padding = utils.convert-length(cetz-ctx, base-sep * label-padding)
    cetz.draw.compound-path(
      fill: paint,
      stroke: none,
      fill-rule: "non-zero",
      {
        for highlight in highlights {
          for bond in highlight.bonds {
            let (_, start) = cetz.coordinate.resolve(
              cetz-ctx,
              _ctfile-atom-center(bond.atom1Index, atom-centers),
            )
            let (_, end) = cetz.coordinate.resolve(
              cetz-ctx,
              _ctfile-atom-center(bond.atom2Index, atom-centers),
            )
            let dx = end.at(0) - start.at(0)
            let dy = end.at(1) - start.at(1)
            let length = calc.sqrt(dx * dx + dy * dy)
            if length > 0 {
              let nx = -dy / length * bond-radius
              let ny = dx / length * bond-radius
              // CeTZ circle and rounded-rect paths wind counter-clockwise.
              // Keep the bond polygon in the same direction so overlaps add
              // instead of cancelling under the non-zero fill rule.
              cetz.draw.line(
                (start.at(0) + nx, start.at(1) + ny),
                (start.at(0) - nx, start.at(1) - ny),
                (end.at(0) - nx, end.at(1) - ny),
                (end.at(0) + nx, end.at(1) + ny),
                close: true,
              )
              cetz.draw.circle(start, radius: bond-radius)
              cetz.draw.circle(end, radius: bond-radius)
            }
          }
          for atom-index in highlight.atomIndexes {
            let (_, center) = cetz.coordinate.resolve(
              cetz-ctx,
              _ctfile-atom-center(atom-index, atom-centers),
            )
            let label = atom-labels.at(str(atom-index), default: none)
            if label == none {
              cetz.draw.circle(center, radius: atom-radius)
            } else {
              let prefix = "a" + str(atom-index) + ".0."
              let (_, west) = cetz.coordinate.resolve(
                cetz-ctx,
                (name: _structure-name, anchor: prefix + "west"),
              )
              let (_, east) = cetz.coordinate.resolve(
                cetz-ctx,
                (name: _structure-name, anchor: prefix + "east"),
              )
              let (_, north) = cetz.coordinate.resolve(
                cetz-ctx,
                (name: _structure-name, anchor: prefix + "north"),
              )
              let (_, south) = cetz.coordinate.resolve(
                cetz-ctx,
                (name: _structure-name, anchor: prefix + "south"),
              )
              let width = east.at(0) - west.at(0)
              let height = north.at(1) - south.at(1)
              if width <= atom-radius and height <= atom-radius {
                cetz.draw.circle(center, radius: atom-radius)
              } else {
                cetz.draw.rect(
                  (
                    west.at(0) - label-padding,
                    south.at(1) - label-padding,
                  ),
                  (
                    east.at(0) + label-padding,
                    north.at(1) + label-padding,
                  ),
                  radius: label-padding,
                )
              }
            }
          }
        }
      },
    )
  })
}

#let _render-ctfile-overlays(cmds, base-sep, atom-centers, atom-labels, config: (:)) = {
  let ctfile-config = config.at("ctfile", default: (:))
  let highlight-paint = ctfile-config.at(
    "highlight-paint",
    default: rgb("#ffd43b").transparentize(45%),
  )
  let highlight-radius = ctfile-config.at("highlight-radius", default: 0.28)
  let highlight-thickness = ctfile-config.at("highlight-thickness", default: 0.16)
  let highlight-label-padding = ctfile-config.at(
    "highlight-label-padding",
    default: highlight-thickness / 2,
  )
  let sgroup-stroke = ctfile-config.at("sgroup-stroke", default: black)
  let sgroup-label-size = ctfile-config.at("sgroup-label-size", default: 0.8em)
  let link-node-size = ctfile-config.at("link-node-size", default: 0.82em)
  let variable-attachment-stroke = ctfile-config.at(
    "variable-attachment-stroke",
    default: 0.7pt + luma(8%),
  )

  for cmd in cmds {
    if cmd.type != "ctfile" {
      continue
    }
    if cmd.highlights.len() > 0 {
      cetz.draw.on-layer(-1, {
        _ctfile-highlight-path(
          cmd.highlights,
          base-sep,
          atom-centers,
          atom-labels,
          highlight-paint,
          highlight-radius,
          highlight-thickness,
          highlight-label-padding,
        )
      })
    }
    for group in cmd.sgroups {
      let name = "molchemist-sgroup-" + str(group.id)
      let left-top = _ctfile-point(group.leftTop, base-sep, atom-centers)
      let left-bottom = _ctfile-point(group.leftBottom, base-sep, atom-centers)
      let right-top = _ctfile-point(group.rightTop, base-sep, atom-centers)
      let right-bottom = _ctfile-point(group.rightBottom, base-sep, atom-centers)
      cetz.draw.line(left-top, left-bottom, name: name + "-left", stroke: sgroup-stroke)
      cetz.draw.line(
        left-top,
        (rel: (base-sep * 0.18, 0pt), to: left-top),
        stroke: sgroup-stroke,
      )
      cetz.draw.line(
        left-bottom,
        (rel: (base-sep * 0.18, 0pt), to: left-bottom),
        stroke: sgroup-stroke,
      )
      cetz.draw.line(right-top, right-bottom, name: name + "-right", stroke: sgroup-stroke)
      cetz.draw.line(
        right-top,
        (rel: (base-sep * -0.18, 0pt), to: right-top),
        stroke: sgroup-stroke,
      )
      cetz.draw.line(
        right-bottom,
        (rel: (base-sep * -0.18, 0pt), to: right-bottom),
        stroke: sgroup-stroke,
      )
      if "label" in group and group.label != none {
        cetz.draw.content(
          (rel: (base-sep * 0.01, base-sep * 0.035), to: right-bottom),
          text(size: sgroup-label-size)[#group.label],
          anchor: "north-west",
        )
      }
    }
    for query in cmd.atomQueries {
      if query.label != "" {
        if ctfile-config.at("query-details", default: false) {
          let constraint-lines = query.at("constraintLines", default: (query.label,))
          let constraint-content = constraint-lines.map(line =>
            text(size: 0.43em, fill: luma(25%))[#line]
          )
          cetz.draw.content(
            (
              rel: (0pt, base-sep * -0.36),
              to: _ctfile-atom-center(query.atomIndex, atom-centers),
            ),
            box(
              inset: (x: 2pt, y: 1pt),
              radius: 1.5pt,
              fill: white,
              stroke: 0.25pt + luma(78%),
              stack(dir: ttb, spacing: 0.04em, ..constraint-content),
            ),
            anchor: "north",
          )
        } else if query.at("compactLabel", default: "") != "" {
          cetz.draw.content(
            (
              rel: (0pt, base-sep * -0.36),
              to: _ctfile-atom-center(query.atomIndex, atom-centers),
            ),
            text(size: 0.44em, fill: luma(38%))[#query.compactLabel],
            anchor: "north",
          )
        }
      }
    }
    for query in cmd.bondQueries {
      cetz.draw.content(
        (
          rel: (0pt, base-sep * 0.2),
          to: (name: _structure-name, anchor: "b" + str(query.bondIndex) + ".50%"),
        ),
        text(size: 0.56em, fill: luma(32%))[#query.label],
        anchor: "center",
      )
    }
    for attachment in cmd.at("variableAttachments", default: ()) {
      let stroke = if attachment.mode == "ANY" {
        _molchemist-dashed-stroke(variable-attachment-stroke, "dotted")
      } else {
        variable-attachment-stroke
      }
      for atom-index in attachment.endpointAtomIndexes {
        cetz.draw.line(
          (name: _structure-name, anchor: "b" + str(attachment.bondIndex) + ".50%"),
          _ctfile-atom-center(atom-index, atom-centers),
          stroke: stroke,
        )
      }
    }
    for annotation in cmd.at("atomAnnotations", default: ()) {
      cetz.draw.content(
        (
          rel: (0pt, base-sep * 0.3),
          to: _ctfile-atom-center(annotation.atomIndex, atom-centers),
        ),
        text(
          size: link-node-size,
          fill: luma(18%),
        )[#annotation.label],
        anchor: "center",
      )
    }
  }
}
