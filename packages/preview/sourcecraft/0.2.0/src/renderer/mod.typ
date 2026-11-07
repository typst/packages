// =============================================================================
// sourcecraft — Renderer Orchestrator
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
/// - spacing (dict or number): gap between box edges in CeTZ units (x: horizontal, y: vertical)
#let render(ir, theme: auto, spacing: (x: 2.0, y: 2.0)) = {
  let the-theme = if theme == auto { themes.default-theme } else { theme }

  // Skip rendering if no classes
  if ir.classes.len() == 0 {
    return []
  }

  // Measure the real box sizes so `spacing` is the actual gap between edges
  context {
    let sizes = (:)
    for cls in ir.classes {
      let m = measure(class-box.build-class-content(cls, the-theme))
      // CeTZ default unit is 1cm
      sizes.insert(cls.name, (w: m.width / 1cm, h: m.height / 1cm))
    }

    // 1. Compute layout positions
    let positions = layout.compute(ir, spacing: spacing, sizes: sizes)

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
          relations.draw-relation(rel, from-pos, to-pos, the-theme, positions, all-relations: ir.relations, sizes: sizes)
        }
      }
    })
  }
}
