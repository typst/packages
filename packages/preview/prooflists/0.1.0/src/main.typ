#import "@preview/curryst:0.6.0": prooftree, rule

/// Lays out a proof tree from a Typst-native list structure.
#let prooflist(
  /// The list to transform into a tree structure.
  ///
  /// A proof list is a list consisting of three node types: `+`, `-`, and `/`.
  /// The `+ premise` node is a terminal rule. It returns its content directly as a (single) premise.
  ///   Any sublists are interpreted as lists directly, not proof lists.
  /// The `- conclusion` node is a non-terminal rule. Any sublists are interpreted as premises.
  /// The `/ name: conclusion` node is a _named_ non-terminal rule. Any sublists are premises.
  content,
  /// The minimum amount of space between two premises.
  min-premise-spacing: 1.5em,
  /// The amount to extend the horizontal bar beyond the content. Also
  /// determines how far from the bar labels and names are displayed.
  title-inset: 0.2em,
  /// The stroke to use for the horizontal bars.
  stroke: stroke(0.05em),
  /// The minimum height of the box containing the horizontal bar.
  ///
  /// The height of this box is normally determined by the height of the rule
  /// name because it is the biggest element of the box. This setting lets you
  /// set a minimum height. The default is 0.8em, is higher than a single line
  /// of content, meaning all parts of the tree will align properly by default,
  /// even if some rules have no name (unless a rule is higher than a single
  /// line).
  min-bar-height: 0.8em,
  /// The orientation of the proof tree.
  ///
  /// If set to ttb, the conclusion will be at the top, and the premises will
  /// be at the bottom. Defaults to btt, the conclusion being at the bottom
  /// and the premises at the top.
  dir: btt,
  /// The side of an inference rule any labels should appear on.
  ///
  /// Applies to all labels (given by `/ label: conclusion`) in the proof list.
  /// The two possible values here are `right` (default) and `left`.
  label-dir: right,
  /// The label to appear on the left-hand side of an inference rule when unspecified.
  ///
  /// Defaults to `none`.
  /// When `label-dir: left` is set, `/ label: conclusion` will overrule this.
  label-lhs: none,
  /// The label to appear on the left-hand side of an inference rule when unspecified.
  ///
  /// Defaults to `none`.
  /// When `label-dir: right` is set, `/ label: conclusion` will overrule this.
  label-rhs: none,
) = {
  // We don't want excess blank space in our rendered tree.
  let filter-item(item) = item not in ([], [ ], parbreak())

  // Providing a default lets us support calls like `#prooflist[+ example]`.
  let roots = content.at("children", default: (content,)).filter(filter-item)
  assert(roots.len() == 1, message: "exactly one root node must be provided")

  let build-prooflist(item) = {
    if item.func() == std.enum.item {
      // The `+` enum item marks a terminal node, so we return its content directly.
      item.body
    } else if item.func() == std.list.item {
      let premises = ()
      let conclusion = none
      if item.body.has("children") {
        // Typst does a lot of auto-conversion in its AST: it is not very regular. :c
        // One such irregularity is that multiple children means the first is the list item body.
        // No children means that the *whole* expression is the list item.
        if item.body.children.len() > 1 {
          conclusion = item.body.children.first()
          premises = item.body.children.slice(1).filter(filter-item)
        }
      } else {
        conclusion = item.body
      }
      rule(label: label-lhs, name: label-rhs, ..premises.map(build-prooflist), conclusion)
    } else if item.func() == std.terms.item {
      // The syntax of term lists is a little restrictive.
      // We can't provide both a "label" (LHS) and a name (RHS).at the same time.
      let premises = ()
      let conclusion = none
      if item.description.has("children") {
        // Another such irregularity is that multiple children means that the first is the term description.
        // No children means the *whole* expression is the term description.
        if item.description.children.len() > 1 {
          conclusion = item.description.children.first()
          premises = item.description.children.slice(1).filter(filter-item)
        }
      } else {
        conclusion = item.description
      }
      if label-dir == right {
        rule(label: label-lhs, name: item.term, ..premises.map(build-prooflist), conclusion)
      } else if label-dir == left {
        rule(label: item.term, name: label-rhs, ..premises.map(build-prooflist), conclusion)
      } else {
        panic("`label-dir` must be either `left` or `right`")
      }
    } else {
      // If not a list item, return the item with no changes.
      // This allows for composition with `#prooflist` and `#prooftree`.
      item
    }
  }
  prooftree(
    min-premise-spacing: min-premise-spacing,
    title-inset: title-inset,
    stroke: stroke,
    min-bar-height: min-bar-height,
    dir: dir,
    build-prooflist(roots.first())
  )
}
