// Hasse diagram visualization for OT constraint rankings
// Part of phonokit package

#import "@preview/cetz:0.4.2"
#import "_config.typ": phonokit-font

/// Create a Hasse diagram for Optimality Theory constraint rankings
///
/// A Hasse diagram represents the partial order of constraint rankings,
/// showing only minimal domination relationships (transitive reduction).
/// Constraints higher in the diagram dominate those lower.
///
/// Features:
/// - Supports partial orders (not all constraints need to be ranked)
/// - Handles floating constraints with no ranking relationships
/// - Automatically computes transitive reduction
/// - Auto-scales for complex hierarchies
///
/// Arguments:
/// - rankings (array): Array of tuples representing rankings:
///   - Three-element tuple `(A, B, level)` means A dominates B, and A is at stratum `level` (REQUIRED)
///   - Four-element tuple `(A, B, level, style)` means A dominates B, A at stratum `level`, with line `style`
///   - Single-element tuple `(A,)` means A is floating (no ranking)
///   - Line styles: "solid" (default), "dashed", "dotted"
///   - Note: Level specification is REQUIRED for all edges to ensure proper stratification
/// - scale (number or auto): Scale factor for diagram (default: auto-scales based on complexity)
/// - node-spacing (number): Horizontal spacing between nodes (default: 2.5)
/// - level-spacing (number): Vertical spacing between levels (default: 1.5)
///
/// Returns: A Hasse diagram showing the constraint hierarchy
///
/// Example:
/// ```
/// #hasse(
///   (
///     ("Onset", "NoCoda", 0),
///     ("Onset", "Dep", 0),
///     ("Max", "Dep", 0),
///     ("Max", "NoCoda", 0),
///     ("Faith",)  // floating constraint
///   )
/// )
///
/// // With line styles
/// #hasse(
///   (
///     ("Ident[F]", "Agree[place]", 0, "dashed"),  // Level 0, dashed line
///     ("Dep", "Agree[vce]", 0),                   // Level 0, solid line (default)
///     ("Max", "Dep", 1, "dotted"),                // Level 1, dotted line
///   )
/// )
/// ```
#let hasse(
  rankings,
  scale: auto,
  node-spacing: 2.5,
  level-spacing: 1.5,
) = {
  // Validate input
  assert(type(rankings) == array, message: "rankings must be an array of tuples")
  assert(rankings.len() > 0, message: "rankings array cannot be empty")

  // Extract all constraints and build graph structure
  let all-constraints = ()
  let edges = () // (from, to) pairs
  let floating = ()
  let user-specified-levels = (:) // Track user-specified levels
  let edge-styles = (:) // Track line styles for edges

  for ranking in rankings {
    assert(type(ranking) == array, message: "Each ranking must be a tuple (array)")

    if ranking.len() == 1 {
      // Floating constraint
      let constraint = ranking.at(0)
      if constraint not in floating {
        floating.push(constraint)
      }
      if constraint not in all-constraints {
        all-constraints.push(constraint)
      }
    } else if ranking.len() >= 3 and ranking.len() <= 4 {
      // Domination relationship (level specification is REQUIRED)
      let from = ranking.at(0)
      let to = ranking.at(1)
      let level = ranking.at(2)
      let style = "solid"

      // Validate that level is a number
      assert(type(level) == int or type(level) == float, message: "Third element must be a level (number). Use (A, B, level) or (A, B, level, style)")

      if ranking.len() == 4 {
        // Fourth element is style
        style = ranking.at(3)
        assert(type(style) == str, message: "Fourth element must be a line style string")
        // Validate style
        assert(style in ("solid", "dashed", "dotted"), message: "Line style must be 'solid', 'dashed', or 'dotted'")
      }

      if (from, to) not in edges {
        edges.push((from, to))
      }
      if from not in all-constraints {
        all-constraints.push(from)
      }
      if to not in all-constraints {
        all-constraints.push(to)
      }

      // Store user-specified level
      user-specified-levels.insert(from, level)

      // Store edge style
      edge-styles.insert(from + "->" + to, style)
    } else {
      assert(false, message: "Each ranking tuple must have 1 (floating), 3 (with level), or 4 (with level and style) elements")
    }
  }

  // Compute transitive reduction (remove redundant edges)
  // For each edge (A, C), check if there's a path A -> B -> C
  let reduced-edges = ()
  for edge in edges {
    let (from, to) = edge
    let is-redundant = false

    // Check if there's an intermediate node B such that (from, B) and (B, to) exist
    for potential-middle in all-constraints {
      if potential-middle != from and potential-middle != to {
        let has-first = (from, potential-middle) in edges
        let has-second = (potential-middle, to) in edges
        if has-first and has-second {
          is-redundant = true
          break
        }
      }
    }

    if not is-redundant {
      reduced-edges.push(edge)
    }
  }

  // Compute levels using topological sort
  // Start with user-specified levels
  let constraint-levels = user-specified-levels

  // Level 0 = constraints with no incoming edges (top-ranked)
  // Level k = constraints whose dominators are all at level < k
  let unassigned = all-constraints.filter(c => c not in constraint-levels.keys())
  let current-level = 0

  while unassigned.len() > 0 {
    let assigned-this-round = ()

    for constraint in unassigned {
      // Check if all dominators (if any) are already assigned
      let dominators = reduced-edges.filter(e => e.at(1) == constraint).map(e => e.at(0))

      if dominators.len() == 0 {
        // No dominators, can be assigned to current level
        constraint-levels.insert(constraint, current-level)
        assigned-this-round.push(constraint)
      } else {
        // Check if all dominators are assigned
        let all-assigned = dominators.all(d => d in constraint-levels.keys())
        if all-assigned {
          // Assign to one level below the maximum dominator level
          let max-dom-level = calc.max(..dominators.map(d => constraint-levels.at(d)))
          constraint-levels.insert(constraint, max-dom-level + 1)
          assigned-this-round.push(constraint)
        }
      }
    }

    // Remove assigned constraints
    unassigned = unassigned.filter(c => c not in assigned-this-round)
    current-level += 1

    // Safety check to prevent infinite loop
    if current-level > all-constraints.len() {
      break
    }
  }

  // Assign floating constraints to the bottom
  if floating.len() > 0 {
    let max-level = if constraint-levels.len() > 0 {
      calc.max(..constraint-levels.values())
    } else {
      -1
    }
    for fc in floating {
      constraint-levels.insert(fc, max-level + 1)
    }
  }

  // Group constraints by level
  let max-level-num = if constraint-levels.len() > 0 {
    calc.max(..constraint-levels.values())
  } else {
    0
  }

  let levels = range(max-level-num + 1).map(i => ())
  for (constraint, level) in constraint-levels {
    levels.at(level).push(constraint)
  }

  // Minimize edge crossings using barycenter heuristic
  // This reorders constraints at each level to reduce visual clutter
  for iteration in range(3) {
    // Multiple passes improve layout
    // Top-down pass: order by average position of parents
    for level-idx in range(1, levels.len()) {
      let level-constraints = levels.at(level-idx)

      // Calculate barycenter (average parent position) for each constraint
      let constraint-barycenters = ()
      for constraint in level-constraints {
        let parents = reduced-edges.filter(e => e.at(1) == constraint).map(e => e.at(0))

        if parents.len() > 0 {
          // Find parent indices in previous level
          let parent-indices = parents.map(p => {
            let idx = levels.at(level-idx - 1).position(c => c == p)
            if idx == none { 0 } else { idx }
          })
          let barycenter = parent-indices.sum() / parents.len()
          constraint-barycenters.push((constraint, barycenter))
        } else {
          // No parents, keep original position
          let original-idx = level-constraints.position(c => c == constraint)
          constraint-barycenters.push((constraint, original-idx))
        }
      }

      // Sort by barycenter
      constraint-barycenters = constraint-barycenters.sorted(key: item => item.at(1))
      levels.at(level-idx) = constraint-barycenters.map(item => item.at(0))
    }

    // Bottom-up pass: order by average position of children
    for level-idx in range(levels.len() - 1).rev() {
      let level-constraints = levels.at(level-idx)

      // Calculate barycenter (average child position) for each constraint
      let constraint-barycenters = ()
      for constraint in level-constraints {
        let children = reduced-edges.filter(e => e.at(0) == constraint).map(e => e.at(1))

        if children.len() > 0 {
          // Find child indices in next level
          let child-indices = children.map(c => {
            let idx = levels.at(level-idx + 1).position(ch => ch == c)
            if idx == none { 0 } else { idx }
          })
          let barycenter = child-indices.sum() / children.len()
          constraint-barycenters.push((constraint, barycenter))
        } else {
          // No children, keep original position
          let original-idx = level-constraints.position(c => c == constraint)
          constraint-barycenters.push((constraint, original-idx))
        }
      }

      // Sort by barycenter
      constraint-barycenters = constraint-barycenters.sorted(key: item => item.at(1))
      levels.at(level-idx) = constraint-barycenters.map(item => item.at(0))
    }
  }

  // Determine scale
  let scale-factor = if scale == auto {
    if all-constraints.len() > 8 {
      0.7
    } else if all-constraints.len() > 5 {
      0.85
    } else {
      1.0
    }
  } else {
    scale
  }

  // Adjust node spacing based on constraint name lengths to prevent overlap
  // Estimate text width: roughly 0.12 units per character in smallcaps at 10pt
  let max-constraint-length = calc.max(..all-constraints.map(c => c.len()))
  let estimated-width = max-constraint-length * 0.12 * scale-factor
  let min-spacing = estimated-width + 0.4 // Add padding
  let adjusted-node-spacing = calc.max(node-spacing, min-spacing)

  // Calculate layout positions for ranked constraints
  let positions = (:)
  for (level-idx, level-constraints) in levels.enumerate() {
    let n = level-constraints.len()
    let total-width = (n - 1) * adjusted-node-spacing
    let start-x = -total-width / 2

    for (i, constraint) in level-constraints.enumerate() {
      let x = start-x + i * adjusted-node-spacing
      let y = -level-idx * level-spacing
      positions.insert(constraint, (x, y))
    }
  }

  // Align one-to-one chains vertically for straight lines
  // If a constraint has exactly one parent and that parent has exactly one child,
  // align them vertically
  for (constraint, pos) in positions {
    let parents = reduced-edges.filter(e => e.at(1) == constraint).map(e => e.at(0))

    if parents.len() == 1 {
      let parent = parents.at(0)
      let parent-children = reduced-edges.filter(e => e.at(0) == parent).map(e => e.at(1))

      if parent-children.len() == 1 and parent in positions {
        // One-to-one relationship: align x-coordinates
        let parent-pos = positions.at(parent)
        let (parent-x, parent-y) = parent-pos
        let (child-x, child-y) = pos

        // Update child's x to match parent's x
        positions.insert(constraint, (parent-x, child-y))
      }
    }
    // Note: For constraints with multiple parents, the barycenter heuristic
    // already positioned them optimally to minimize crossings. Don't override.
  }

  // Re-center the diagram for symmetry
  // Calculate the average x position and shift to center at 0
  if positions.len() > 0 {
    let all-x = positions.values().map(pos => pos.at(0))
    let min-x = calc.min(..all-x)
    let max-x = calc.max(..all-x)
    let center-offset = -(min-x + max-x) / 2

    // Apply centering offset
    let centered-positions = (:)
    for (constraint, pos) in positions {
      let (x, y) = pos
      centered-positions.insert(constraint, (x + center-offset, y))
    }
    positions = centered-positions
  }

  // Draw the diagram
  box(inset: 1.2em, baseline: 40%, cetz.canvas(length: scale-factor * 1cm, {
    import cetz.draw: *

    // Draw edges first (so they appear behind nodes)
    for edge in reduced-edges {
      let (from, to) = edge
      if from in positions and to in positions {
        let (x1, y1) = positions.at(from)
        let (x2, y2) = positions.at(to)

        // Get line style for this edge
        let edge-key = from + "->" + to
        let line-style = if edge-key in edge-styles {
          edge-styles.at(edge-key)
        } else {
          "solid"
        }

        // Scale stroke width with scale factor
        let stroke-width = 0.8pt * scale-factor

        // Create stroke based on style
        let stroke-style = if line-style == "dashed" {
          (paint: black, thickness: stroke-width, dash: "dashed")
        } else if line-style == "dotted" {
          (paint: black, thickness: stroke-width, dash: "dotted")
        } else {
          stroke-width + black
        }

        // Draw line
        line((x1, y1), (x2, y2), stroke: stroke-style)

        // Draw arrow head (also scaled)
        let arrow-size = 0.15 * scale-factor
        let dx = x2 - x1
        let dy = y2 - y1
        let length = calc.sqrt(dx * dx + dy * dy)
        let ux = dx / length
        let uy = dy / length

        // Arrow at destination (always solid)
        let arrow-x = x2 - uy * arrow-size
        let arrow-y = y2 + ux * arrow-size
        line((x2, y2), (arrow-x, arrow-y), stroke: stroke-width + black)

        arrow-x = x2 + uy * arrow-size
        arrow-y = y2 - ux * arrow-size
        line((x2, y2), (arrow-x, arrow-y), stroke: stroke-width + black)
      }
    }

    // Draw white rectangles behind constraint names (to create whitespace)
    for (constraint, pos) in positions {
      let (x, y) = pos
      // Estimate text dimensions based on constraint name length
      let name-length = constraint.len()
      // Width: roughly 0.22 units per character (generous to ensure full coverage)
      let text-width = name-length * 0.22 * scale-factor
      // Height: based on font size (increased to cover actual rendered height)
      let text-height = 0.5 * scale-factor
      // Add padding
      let padding = 0.50
      let rect-width = text-width + padding
      let rect-height = text-height + padding

      // Draw rounded rectangle centered at constraint position
      rect(
        (x - rect-width / 2, y - rect-height / 2),
        (x + rect-width / 2, y + rect-height / 2),
        fill: white,
        stroke: none,
        radius: 0.6,
      )
    }

    // Draw constraint names in smallcaps (but not text inside brackets)
    for (constraint, pos) in positions {
      let (x, y) = pos

      // Parse constraint name to apply smallcaps only outside brackets
      let formatted-name = {
        // Match pattern: text before bracket, bracket content, text after
        let bracket-match = constraint.match(regex("^([^\[]*)\[([^\]]*)\](.*)$"))

        if bracket-match != none {
          // Has brackets: smallcaps before, regular inside brackets, smallcaps after
          let before = bracket-match.captures.at(0)
          let inside = bracket-match.captures.at(1)
          let after = bracket-match.captures.at(2)

          // Compose the parts using content block
          [#smallcaps(before)\[#inside\]#if after != "" { smallcaps(after) }]
        } else {
          // No brackets: all smallcaps
          smallcaps(constraint)
        }
      }

      content(
        (x, y),
        padding: 0.1,
        anchor: "center",
        context text(
          font: phonokit-font.get(),
          size: 10pt * scale-factor,
          formatted-name,
        ),
      )
    }
  }))
}
