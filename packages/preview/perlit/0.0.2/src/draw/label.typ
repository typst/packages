#import "../utils/paths.typ": bezier_at, line_at
#import "../utils/helpers.typ": get_color
#import "../utils/components.typ": label

#let draw_labels(edges, curve: false, ..args) = {
  for (id, edge) in edges {
    if "label" in edge {
      let (start, target, ctrl_points) = edge

      let pos = if curve {
        bezier_at(
          start,
          ctrl_points.start,
          ctrl_points.target,
          target,
          0.5,
        )
      } else {
        line_at((start, ..ctrl_points.values()), 0.5)
      }

      label(
        pos,
        edge.label,
        get_color(edge),
      )
    }
  }
}
