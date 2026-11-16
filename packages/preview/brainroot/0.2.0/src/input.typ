// Input: branches, connections and Typst lists.

// brainroot -- two-sided mind maps with coloured branches.
//
// The root sits in the middle, the branches spread to the right and left,
// and every branch carries its own colour down to its leaves. The layout is
// a simple "tidy tree": every subtree gets as much room as its children
// need and is centred on its parent.


/// A branch of the mind map. Children may be further `branch(...)` calls or
/// plain content, which then counts as a leaf without children of its own.
///
/// -> dictionary
#let branch(
  /// Label of the node.
  /// -> content | str
  label,
  /// Children: `branch(...)` calls or content (leaves).
  /// -> content | dictionary
  ..kids,
  /// Colour of the branch. Only read on the first level; below it every node
  /// inherits the colour of its parent. `none` takes the next colour from
  /// the palette.
  /// -> color | none
  color: none,
  /// `left` or `right` forces the side in the two-sided layout; `auto` lets
  /// brainroot balance. Only read on the first level.
  /// -> alignment | auto
  side: auto,
  /// An icon, emoji or image set beside the label.
  /// -> content | none
  icon: none,
  /// Where the icon goes: `"left"` of the label or `"top"`, above it.
  /// -> str
  icon-at: "left",
  /// Fill of this node's box; `auto` follows the theme, `none` leaves the
  /// box unfilled with a border in the branch colour (a ring).
  /// -> auto | color | none
  fill: auto,
  /// Text colour of this node; `auto` follows the fill.
  /// -> auto | color
  ink: auto,
  /// Highlights the node: bold text and a strong border in the branch
  /// colour, for key terms.
  /// -> bool
  mark: false,
  /// Draws the box empty, at its full size, unless the map is set with
  /// `solution: true` -- a gap to fill in.
  /// -> bool
  blank: false,
  /// A small label on the edge that leads to this node, for decision trees
  /// and probability trees.
  /// -> content | none
  edge-label: none,
  /// A name for `connect(...)` to address this node by. The root is `"root"`.
  /// -> str | none
  id: none,
  /// A brace beyond this node's children with a label, summarising them.
  /// Not drawn in the `radial` and `star` layouts.
  /// -> content | none
  summary: none,
  /// A soft cloud behind this node's whole subtree: `true` for a light
  /// tint of the branch colour, or a colour. Not drawn in the `radial` and
  /// `star` layouts.
  /// -> bool | color | none
  cloud: none,
  /// Points this node is worth when a map is graded; `brainroot-points()`
  /// adds them up and `show-points: true` shows them as a badge.
  /// -> int | float | none
  points: none,
  /// Makes this node's children the same size: `true` in width and height,
  /// `"width"` or `"height"` in one of them. Every child grows to the
  /// largest sibling, so a row of leaves lines up.
  /// -> bool | str
  equal: false,
) = (
  brainroot-node: true,
  label: label,
  kids: kids.pos(),
  color: color,
  side: side,
  icon: icon,
  icon-at: icon-at,
  fill: fill,
  ink: ink,
  mark: mark,
  blank: blank,
  edge-label: edge-label,
  id: id,
  summary: summary,
  cloud: cloud,
  points: points,
  equal: equal,
)

/// A connection between two nodes that are not parent and child, drawn over
/// the map as a curve: a cross-link. Give the nodes an `id` and pass the
/// connections to `brainroot(links: (...))`.
///
/// -> dictionary
#let connect(
  /// `id` of the node the curve starts at; `"root"` is the root.
  /// -> str
  from,
  /// `id` of the node the curve ends at.
  /// -> str
  to,
  /// A label at the middle of the curve.
  /// -> content | none
  label: none,
  /// An arrowhead at the end; `"both"` puts one at each end.
  /// -> bool | str
  arrow: true,
  /// Dash pattern of the curve.
  /// -> str
  dash: "dashed",
  /// How far the curve bows out, as a share of the distance: `auto` bows
  /// away from the root, a ratio bows to the left of the direction of
  /// travel, negative to the right, `0%` is a straight line.
  /// -> auto | ratio
  bend: auto,
  /// Colour of the curve; `auto` is a dark grey.
  /// -> color | auto
  color: auto,
  /// Line width.
  /// -> length
  thickness: 0.09em,
) = (
  brainroot-link: true,
  from: from, to: to, label: label, arrow: arrow, dash: dash,
  bend: bend, color: color, thickness: thickness,
)

// Anything that is not a branch becomes a leaf.
#let _norm(k) = if type(k) == dictionary and k.at("brainroot-node", default: false) { k } else { branch(k) }

// --- Lists as input --------------------------------------------------------
//
// In markup a list is a sequence of `list.item` elements; only when laid
// out do they become a `list`. Both forms are understood here.

#let _is-item(c) = type(c) == content and c.func() in (list.item, enum.item)

#let _is-list(c) = type(c) == content and c.func() in (list, enum)

#let _is-blank(c) = type(c) == content and c.func() in (parbreak, [ ].func())

// Splits the body of a list item into label and nested items: whatever is
// not a list item stays label; every nested item becomes a child. Three
// marks in the label carry node options: a Typst label `<name>` at the end
// gives the node its `id`, a label that is nothing but `*bold*` marks the
// node, one that is nothing but `_emphasised_` makes it a gap.
#let _from-item(item) = {
  let body = item.body
  let parts = if body.func() == [].func() { body.children } else { (body,) }
  let label = ()
  let kids = ()
  for p in parts {
    if _is-item(p) {
      kids.push(_from-item(p))
    } else if _is-list(p) {
      kids += p.children.map(_from-item)
    } else if kids.len() == 0 {
      label.push(p)
    }
  }
  // Whitespace at the edges of the label only gets in the way.
  while label.len() > 0 and _is-blank(label.first()) { label = label.slice(1) }
  while label.len() > 0 and _is-blank(label.last()) { label = label.slice(0, -1) }
  let id = none
  if label.len() > 0 and type(label.last()) == content {
    let tag = label.last().at("label", default: none)
    if tag != none { id = str(tag) }
  }
  let mark = false
  let blank = false
  if label.len() == 1 and type(label.first()) == content {
    if label.first().func() == strong { mark = true; label = (label.first().body,) }
    else if label.first().func() == emph { blank = true; label = (label.first().body,) }
  }
  branch(label.join(), ..kids, id: id, mark: mark, blank: blank)
}

// If the argument is a list or a sequence of list items, yields its items
// as branches; otherwise the argument itself as a single branch.
#let _expand(arg) = {
  if _is-list(arg) {
    arg.children.map(_from-item)
  } else if _is-item(arg) {
    (_from-item(arg),)
  } else if type(arg) == content and arg.func() == [].func() and arg.children.any(_is-item) and arg.children.all(c => _is-item(c) or _is-list(c) or _is-blank(c)) {
    arg.children.filter(c => not _is-blank(c)).map(_expand).flatten()
  } else {
    (arg,)
  }
}
