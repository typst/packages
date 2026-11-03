// =====================================================
// TREES VISUALIZATIONS - Object-Oriented
// =====================================================
// Creates geometry objects for tree visualizations

// =====================================================
// TREE NODE OBJECT
// =====================================================

/// Create a tree node
///
/// Parameters:
/// - value: Content to display in the node
/// - children: Array of child nodes
/// - name: Unique identifier for the node (auto-generated if none)
/// - style: Optional style overrides for this specific node
#let tree-node(
  value,
  children: (),
  name: auto,
  style: (:),
) = (
  type: "tree-node",
  value: value,
  children: children,
  name: name,
  style: style,
)

// =====================================================
// TREE OBJECT
// =====================================================

/// Create a tree visualization object
///
/// Parameters:
/// - root: The root tree-node
/// - direction: "vertical" (top-down) or "horizontal" (left-right)
/// - highlight-items: Array of node names to highlight
/// - highlight-path: Array of node names forming a path to highlight
/// - origin: Position to place the root
/// - style: Optional style overrides
#let tree(
  root,
  direction: "vertical",
  highlight-items: (),
  highlight-path: (),
  origin: (0, 0),
  style: auto,
) = (
  type: "tree",
  root: root,
  direction: direction,
  highlight-items: highlight-items,
  highlight-path: highlight-path,
  origin: origin,
  style: style,
)

// =====================================================
// TYPE CHECKERS
// =====================================================

#let is-tree-node(obj) = type(obj) == dictionary and obj.at("type", default: none) == "tree-node"
#let is-tree(obj) = type(obj) == dictionary and obj.at("type", default: none) == "tree"
