/// Fitch-style proof environment.
///
/// This module implements Fitch-style natural deduction proofs using a grid-based layout.
/// It supports premises, assumptions, derivation steps, and nested subproofs.

/// Creates a premise line in a Fitch proof.
///
/// Premises are the starting assumptions of a proof and must appear at the beginning
/// of the proof before any other lines.
///
/// = Arguments:
/// - `num`: Line number (integer)
/// - `content`: The logical formula or statement
/// - `rule`: Optional justification for the premise (defaults to "Premise")
///
/// = Returns:
/// A premise item with structure `(type: "premise", num, content, rule?)`
///
/// = Example:
/// ```typst
/// premise(1, $A$)
/// premise(2, $A -> B$, rule: "Hypothesis")
/// ```
#let fitch-premise(num, content, rule: none) = (
  type: "premise",
  num: num,
  content: content,
  rule: rule,
)

/// Creates an assumption line in a Fitch proof (starts a subproof).
///
/// Assumptions must be the first line(s) within a subproof.
/// They introduce a temporary hypothesis that will be withdrawn at the end of the subproof.
///
/// = Arguments:
/// - `num`: Line number (integer)
/// - `content`: The assumed formula or statement
/// - `rule`: Optional justification (defaults to "Assumption")
///
/// = Returns:
/// An assumption item with structure `(type: "assume", num, content, rule?)`
///
/// = Example:
/// ```typst
/// subproof(
///   assume(2, $A$),
///   step(3, $B$, rule: "from 1"),
/// )
/// ```
#let fitch-assume(num, content, rule: none) = (
  type: "assume",
  num: num,
  content: content,
  rule: rule,
)

/// Creates a derivation step in a Fitch proof.
///
/// Steps represent logical conclusions derived from previous lines.
/// They can appear at any depth within the proof structure.
///
/// = Arguments:
/// - `num`: Line number (integer)
/// - `content`: The derived formula or statement
/// - `rule`: Optional justification for the derivation (e.g., "Modus Ponens 1,2")
///
/// = Returns:
/// A step item with structure `(type: "step", num, content, rule?)`
///
/// = Example:
/// ```typst
/// step(3, $B$, rule: "MP 1, 2")
/// step(5, $not A$, rule: [DNE 4])
/// ```
#let fitch-step(num, content, rule: none) = (
  type: "step",
  num: num,
  content: content,
  rule: rule,
)

/// Creates a subproof block in a Fitch proof.
///
/// Subproofs are indented scopes used for conditional proofs, proof by contradiction,
/// or any situation requiring temporary assumptions. They must start with one or more
/// assumptions and can contain steps and nested subproofs.
///
/// = Arguments:
/// - `..lines`: Variable number of items (assumptions, steps, or nested subproofs)
///
/// = Returns:
/// A subproof item with structure `(type: "subproof", lines: [Item])`
///
/// = Example:
/// ```typst
/// subproof(
///   assume(2, $A$),
///   step(3, $B$, rule: "1"),
///   step(4, $B and A$, rule: "3, 2"),
/// )
/// ```
#let fitch-subproof(
  ..lines,
) = (
  type: "subproof",
  lines: lines.pos(),
)


/// Internal: Renders a line number cell in the proof grid.
///
/// This function creates the left column containing the line number.
/// It's part of the internal grid-based layout system.
///
/// = Arguments:
/// - `num`: The line number to display
/// - `_style`: Styling configuration (unused, included for consistency)
///
/// = Returns:
/// Aligned right text containing the line number
#let _fitch-num-cell(num, _style) = {
  align(right)[#num]
}

/// Internal: Renders the content cell with scope bars and underlines.
///
/// This function handles the middle column of the grid, rendering:
/// - The logical content
/// - Vertical scope bars (left borders) for nested subproofs
/// - Horizontal underlines (bottom borders) for assumptions
///
/// The nesting depth determines how many scope bars appear on the left.
///
/// = Arguments:
/// - `item`: The proof line item
/// - `depth`: Current nesting depth (0 = top level, increases for subproofs)
/// - `is-first`: Whether this is the first item at this depth
/// - `is-last`: Whether this is the last item at this depth (triggers underline)
/// - `style`: Styling configuration with stroke, indent, padding, etc.
///
/// = Returns:
/// Boxed content with appropriate borders and indentation
#let _fitch-line-cell(item, depth, is-first, is-last, style) = {
  let out = item.content

  if is-last {
    out = box(
      out,
      stroke: (bottom: style.stroke),
      outset: style.pad,
    )
  }

  for level in range(0, depth) {
    let top-out = if level == 0 and is-first {
      style.pad
    } else {
      style.pad + style.row-gutter
    }
    out = box(
      inset: (left: style.indent, rest: 0pt),
      box(
        out,
        stroke: (left: style.stroke),
        outset: (top: top-out, rest: style.pad),
      ),
    )
  }

  out
}

/// Internal: Renders the justification/rule cell.
///
/// This function creates the right column of the grid containing the rule
/// or justification for a line. It automatically applies default labels
/// for premises and assumptions if no explicit rule is provided.
///
/// = Arguments:
/// - `item`: The proof line item (with optional rule field)
/// - `style`: Styling configuration (includes rule-style for text formatting)
///
/// = Returns:
/// Styled text content for the justification, or empty if none
#let _fitch-rule-cell(item, style) = {
  let rule = if item.rule != none {
    item.rule
  } else if item.type == "premise" {
    "Premise"
  } else if item.type == "assume" {
    "Assumption"
  }
  if rule == none { [] } else { text(..style.rule-style)[#rule] }
}


/// Default styling configuration for Fitch proofs.
#let fitch-style-default = (
  /// Horizontal spacing between columns.
  col-gutter: 0.8em,
  /// Vertical spacing between rows.
  row-gutter: 0.3em,
  /// Scope bars and underlines.
  stroke: 1pt + blue,
  /// Horizontal spacing between nested bars.
  indent: 1em,
  /// Padding inside the cell.
  pad: 0.5em,
  /// Style for the rule cell.
  rule-style: (style: "italic"),
)

/// Renders a complete Fitch-style natural deduction proof.
///
/// This is the main function for creating proofs.
/// It combines premises, derivation steps, and subproofs into
/// a properly formatted proof using a grid-based layout
/// with scope bars and line numbers.
///
/// = Arguments:
/// - `..nodes`: Variable number of premises, steps, and/or subproofs
/// - `style`: Custom style configuration dict (merged with defaults)
///
/// = Returns:
/// A grid-based proof layout
///
/// = Example - Simple proof:
/// ```typst
/// #fitch-proof(
///   premise(1, $A$),
///   premise(2, $A -> B$),
///   step(3, $B$, rule: "MP 1, 2"),
/// )
/// ```
///
/// = Example - Proof with subproof (conditional proof):
/// ```typst
/// #fitch-proof(
///   premise(1, $A -> B$),
///   subproof(
///     assume(2, $A$),
///     step(3, $B$, rule: "MP 1, 2"),
///   ),
///   step(4, $A -> B$, rule: "Cond Proof 2-3"),
/// )
/// ```
#let fitch-proof(
  ..nodes,
  style: (:),
) = {
  style = fitch-style-default + style

  let premises = ()
  let body = ()
  for item in nodes.pos() {
    if item.type == "premise" {
      assert(body.len() == 0, message: "Premises must come before other lines in a proof.")
      premises.push(item)
    } else {
      body.push(item)
    }
  }

  let handle-premises(items, depth) = {
    let out = ()
    for (idx, item) in items.enumerate() {
      let is-first = idx == 0
      let is-last = idx == items.len() - 1
      out.push(_fitch-num-cell(item.num, style))
      out.push(_fitch-line-cell(item, depth, is-first, is-last, style))
      out.push(_fitch-rule-cell(item, style))
    }
    out
  }

  let parse-subproof(subproof) = {
    let assumptions = ()
    let subitems = ()
    for item in subproof.lines {
      if item.type == "assume" {
        assert(subitems.len() == 0, message: "Assumptions must come before other lines in a subproof.")
        assumptions.push(item)
      } else {
        subitems.push(item)
      }
    }
    (assumptions, subitems)
  }

  let process-items(items, depth) = {
    let out = ()
    for item in items {
      if item.type == "subproof" {
        let (assumptions, subitems) = parse-subproof(item)
        out += handle-premises(assumptions, depth + 1)
        out += process-items(subitems, depth + 1)
      } else {
        out.push(_fitch-num-cell(item.num, style))
        out.push(_fitch-line-cell(item, depth, false, false, style))
        out.push(_fitch-rule-cell(item, style))
      }
    }
    out
  }

  let cells = ()
  cells += handle-premises(premises, 0)
  cells += process-items(body, 0)

  grid(
    columns: 3,
    column-gutter: style.col-gutter,
    row-gutter: style.row-gutter,
    inset: style.pad,
    if premises.len() == 0 {
      // Add top line if there are no premises
      grid.hline(start: 1, end: 2, stroke: style.stroke)
    } else {
      // Otherwise, add "empty" line instead of "none"
      grid.hline(start: 1, end: 1)
    },
    grid.vline(x: 1, stroke: style.stroke),
    ..cells,
  )
}
