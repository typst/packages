// =============================================================================
// source-to-class-diagram — Renderer Orchestrator
// =============================================================================
// Takes an IR and produces a CeTZ canvas with the class diagram.

#import "../deps.typ": cetz
#import "theme.typ" as themes
#import "class-box.typ"
#import "relations.typ"
#import "layout.typ"

/// Render a complete class diagram from IR.
///
/// - ir (dict): A uml-diagram IR dictionary
/// - theme (dict): Theme configuration (default: themes.default-theme)
/// - spacing (dict): (x, y) spacing between classes in CeTZ units
#let render(ir, theme: auto, spacing: (x: 4.0, y: 3.5)) = {
  let the-theme = if theme == auto { themes.default-theme } else { theme }

  // Skip rendering if no classes
  if ir.classes.len() == 0 {
    return []
  }

  // 1. Compute layout positions
  let positions = layout.compute(ir, spacing: spacing)

  // 2. Render canvas
  cetz.canvas({
    import cetz.draw: *

    // Draw class boxes
    for cls in ir.classes {
      let pos = positions.at(cls.name, default: (0, 0))
      class-box.draw-class(cls, pos, the-theme)
    }

    // Draw relations
    for rel in ir.relations {
      if rel.from in positions and rel.to in positions {
        let from-pos = positions.at(rel.from)
        let to-pos = positions.at(rel.to)
        relations.draw-relation(rel, from-pos, to-pos, the-theme, positions, all-relations: ir.relations)
      }
    }
  })
}
