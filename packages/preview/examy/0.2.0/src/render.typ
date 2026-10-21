/// Phase E: turn plan instructions into actual layout.

#import "types.typ": *
#import "scan.typ": starts_inline
#import "tokenize.typ": apply_styles
#import "plan.typ": cumulative_indent
#import "refs.typ": LABELLING, display_number, division_anchor, update_current_address
#import "elements/solution.typ": solution

/// Half-em gap between a gutter label and the body text.
#let LABEL_GAP = .5em

/// "(3 points)" badge shown at the start of a division.
#let points_badge(points) = {
  if points == none { return none }
  let word = if points == 1 { "point" } else { "points" }
  [(#points #word)#h(.5em)]
}

/// The gutter label for a division, placed to the left of the body.
/// `indent` is the inset of the block the label is placed inside (placement
/// is relative to that block's content origin) and `width` is the gutter
/// width the label may occupy: the division's own indent for nested blocks,
/// its cumulative indent for top-level peer segments.
///
/// When the body starts with inline content, pass `inline: true`: the label
/// is emitted as a zero-width inline box that participates in the first
/// line's layout, so it stays on the baseline even when the line is taller
/// than usual (e.g. a boxed solution on the first line). When the body
/// starts with a block-level element (or is empty), the label is `place`d at
/// the block top instead, which is where the block's first content sits.
/// (The zero-width trick assumes LTR text.)
#let _gutter_label(items, d_idx, indent, width, inline: false) = {
  let d = items.at(d_idx)
  let disp = display_number(d.level, d.number)
  if disp == none { return none }
  if inline {
    box(width: 0pt, h(-indent) + box(width: width - LABEL_GAP, align(right, disp)))
  } else {
    // Anchor to the block region explicitly: since Typst 0.15 an
    // alignment-less `place` inside a paragraph anchors at the line's
    // baseline, which for a line containing a tall inline box is its bottom.
    place(top + left, dx: -indent, box(
      width: width - LABEL_GAP,
      align(right, disp),
    ))
  }
}

/// Whether a body (a list of item indices, in order) starts with
/// inline-level content. Divisions and breaks are block-level; invisible
/// chunks (whitespace, metadata) are skipped.
#let _body_starts_inline(items, idxs) = {
  for i in idxs {
    let it = items.at(i)
    if it.kind != "chunk" { return false }
    let r = starts_inline(it.body)
    if r != none { return r }
  }
  false
}

/// Anchor + points badge emitted at the start of a division's body.
#let _division_head(items, d_idx) = {
  let d = items.at(d_idx)
  let anchor = division_anchor(
    label_name: d.fields.label,
    full_address: d.address,
    label: d.fields.label,
  )
  if d.fields.label == none {
    // Realizes to pure invisible tags; safe to leave bare in the flow.
    anchor
  } else {
    // A *labeled* elembic element realizes inside a block-level wrapper,
    // which would break the division's first line; an inline box keeps it in
    // the paragraph (references still resolve to it).
    box(anchor)
  }
  points_badge(d.fields.points)
}

/// Join a run of chunk items back into content, re-applying recorded styles.
/// Consecutive chunks with the same style stack are joined first so spacing
/// is preserved, then wrapped once. `base` styles (already applied by an
/// enclosing block) are skipped.
#let render_chunks(items, idxs, base: 0) = {
  let groups = ()
  for i in idxs {
    let c = items.at(i)
    let styles = c.styles.slice(calc.min(base, c.styles.len()))
    if groups.len() > 0 and groups.at(-1).styles == styles {
      groups.at(-1).bodies.push(c.body)
    } else {
      groups.push((styles: styles, bodies: (c.body,)))
    }
  }
  groups.map(g => apply_styles(g.bodies.join(), g.styles)).join()
}

/// Render a division subtree as ordinary nested blocks (used when the
/// subtree contains no page breaks or fr heights).
#let render_nested(items, idx, base_styles: 0) = {
  let it = items.at(idx)
  let indent = it.fields.indent
  let own_styles = it.styles.slice(calc.min(base_styles, it.styles.len()))

  let inline_label = _body_starts_inline(items, it.children)
  let body = {
    _gutter_label(items, idx, indent, indent, inline: inline_label)
    _division_head(items, idx)
    // Children in document order: runs of chunks joined, child divisions
    // rendered recursively.
    let chunk_run = ()
    for c_idx in it.children {
      let child = items.at(c_idx)
      if child.kind == "chunk" {
        chunk_run.push(c_idx)
      } else {
        render_chunks(items, chunk_run, base: it.styles.len())
        chunk_run = ()
        render_nested(items, c_idx, base_styles: it.styles.len())
      }
    }
    render_chunks(items, chunk_run, base: it.styles.len())
    if it.fields.solution != none {
      solution(it.fields.solution)
    }
  }

  apply_styles(
    block(inset: (left: indent), {
      set enum(numbering: LABELLING.at(it.level, default: "(a)"))
      body
    }),
    own_styles,
  )
}

/// Render one peer segment (produced by splitting a subtree at breaks).
#let render_segment(items, seg) = {
  let owner = items.at(seg.division)
  let height = if seg.has_inner_break or seg.fr == none { auto } else { seg.fr }
  let own_styles = owner.styles

  let body = {
    // Gutter labels: possibly several divisions share this segment's first
    // line (e.g. a question whose body starts with a part).
    let inline_label = _body_starts_inline(items, seg.items)
    for d_idx in seg.label_divisions {
      _gutter_label(
        items,
        d_idx,
        seg.indent,
        cumulative_indent(items, d_idx),
        inline: inline_label,
      )
    }
    if seg.label_divisions.len() > 0 {
      for d_idx in seg.label_divisions {
        _division_head(items, d_idx)
      }
    } else {
      // Continuation: no label, but references inside still belong here.
      update_current_address(owner.address)
    }
    render_chunks(items, seg.items, base: owner.styles.len())
    if seg.tail != none {
      let d = items.at(seg.tail)
      if d.fields.solution != none {
        solution(d.fields.solution)
      }
    }
  }

  apply_styles(
    block(inset: (left: seg.indent), height: height, {
      // A pagebreak buried inside an opaque chunk cannot break out of this
      // block; degrade it to a column break like the old implementation.
      show pagebreak: it => colbreak(weak: it.weak)
      set enum(numbering: LABELLING.at(owner.level, default: "(a)"))
      body
    }),
    own_styles,
  )
}

/// Render a full instruction list.
#let render(items, instructions) = {
  for instr in instructions {
    if instr.kind == "verbatim" {
      let it = items.at(instr.item)
      apply_styles(it.body, it.styles)
    } else if instr.kind == "break" {
      if instr.target == "page" {
        pagebreak(weak: instr.weak)
      } else {
        colbreak(weak: instr.weak)
      }
    } else if instr.kind == "nested" {
      render_nested(items, instr.root)
    } else if instr.kind == "segment" {
      render_segment(items, instr)
    } else {
      panic("examy: unknown render instruction: " + repr(instr.kind))
    }
  }
}
