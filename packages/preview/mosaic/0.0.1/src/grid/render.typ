// Rendering of validated grid trees for one incremental step.
#import "../shared.typ": array-max, fail, tag
#import "../incremental/core.typ": range-last, status
#import "content.typ": body-cell-ids
#import "traversal.typ": resolved-tracks, fold-grid
#import "../incremental/analysis.typ": max-step
#import "../incremental/heading.typ": contains-heading, apply-state
#import "../incremental/transform.typ": transform
// Aliased: `fit` is the local variable name for a cell's fit mode throughout
// this module, and the helper must not shadow it.
#import "../fit.typ": fit as fit-helper
#import "../settings.typ": default-spacing
#import "../deck-state.typ": deck-settings

// Records one queryable warning per overflowing cell.
//
// This runs inside `layout`, before introspection has converged: the logical
// slide counter still reads its pre-layout value here, and the recorded number
// only becomes correct once Typst re-runs the pass. So this function never
// fails the compile even in "error" mode, because the message it could build
// would name the wrong slide. `overflow-report` raises the failure afterwards,
// from a context where the numbers are final.
// The measurement rides a zero-footprint `place` so observation never
// participates in layout. Wrapping the body in the `layout` element instead
// would collapse the region to the content's natural height, which pins
// horizon- and bottom-aligned cell content to the top of the cell.
#let observe-overflow(body, cell, slide, step) = {
  place(top, layout(region => {
    let natural = measure(body, width: region.width)
    if natural.height > region.height {
      [#metadata((
        mosaic: tag,
        kind: "overflow-warning",
        logical-slide: slide,
        frame: step,
        cell: cell,
        available-height: region.height,
        measured-height: natural.height,
        message: "mosaic: content overflows cell " + repr(cell),
      ))<mosaic-overflow-warning>]
    }
  }))
  body
}

// Fails the compile when any cell overflowed, naming every offender. Placed at
// the end of the document by `setup`, so `query` sees converged introspection
// and reports the slide numbers an author can actually navigate to.
#let overflow-report() = context {
  let records = query(<mosaic-overflow-warning>).map(it => it.value)
  if records.len() == 0 {
    return
  }
  let describe(record) = (
    "cell " + repr(record.cell) + " on slide " + str(record.logical-slide)
      + " frame " + str(record.frame) + " by "
      + repr(record.measured-height - record.available-height)
  )
  fail(
    "content overflows "
      + records.map(describe).join("; ")
      + " (set overflow: \"record\" to report these without failing)",
  )
}

#let fixed-content-has-heading(node) = fold-grid(
  node,
  cell => cell.content != none and contains-heading(cell.content),
  (node, child) => child,
  (node, children) => children.any(value => value),
)

// A heading inside an incremental grid node would be added and removed with the
// node, so its outline entry would come and go between frames. Structural, and
// therefore asked once per slide rather than once per rendered frame.
#let require-stable-grid-headings(node, contents) = {
  let offending = fold-grid(
    node,
    cell => false,
    (node, child) => (
      child
        or body-cell-ids(node.child).map(id => contents.at(id, default: none)).any(contains-heading)
        or fixed-content-has-heading(node.child)
    ),
    (node, children) => children.any(value => value),
  )
  if offending {
    fail(
      "headings cannot be placed in incremental grid nodes; "
        + "keep semantic headings structurally stable across frames",
    )
  }
}

#let max-node(node) = fold-grid(
  node,
  cell => {
    if cell.content == none {
      1
    } else {
      max-step(cell.content)
    }
  },
  (node, child) => calc.max(range-last(node.range), child),
  (node, children) => array-max(children),
)

// Resolve em components of an inset against a captured base text size, so
// label-targeted typography rules cannot scale cell geometry.
#let resolve-inset-part(value, base) = if type(value) == length {
  value.abs + value.em * base
} else if type(value) == relative {
  value.ratio + resolve-inset-part(value.length, base)
} else {
  value
}

// The slide a render starts from when no deck supplies one: slide zero,
// nothing numbered yet. Named once so the entry points cannot drift from
// each other.
#let initial-slide = 0

// A cell that states no inset of its own takes the deck's configured token.
// Read inside the render context, where the deck record is live; a component
// rendered outside `setup` falls back to the library default.
#let configured-inset() = {
  let settings = deck-settings()
  if settings == none {
    default-spacing.inset
  } else {
    settings.spacing.inset
  }
}

#let resolve-inset(inset, base) = if type(inset) == dictionary {
  let resolved = (:)
  for (side, value) in inset {
    resolved.insert(side, resolve-inset-part(value, base))
  }
  resolved
} else {
  resolve-inset-part(inset, base)
}

#let render-cell(
  content,
  style,
  step,
  path: "grid",
  overflow: "off",
  slide: initial-slide,
  track: none,
  vertical: false,
) = {
  // A styleless cell is a container the tree produced, not one an author named.
  // Its content is measured again by every cell inside it, so observing it too
  // re-measures each subtree once per level of nesting, and the path it would
  // report ("grid.0") names nothing an author can act on. The offending cell
  // reports itself.
  if style == none {
    return content
  }
  let surface = style
  let id = surface.remove("_id", default: none)
  let before = surface.remove("before", default: [])
  let after = surface.remove("after", default: [])
  let inset = surface.remove("inset")
  let fill = surface.remove("fill", default: none)
  let stroke = surface.remove("stroke", default: none)
  let radius = surface.remove("radius", default: 0pt)
  let background = surface.remove("background", default: none)
  let content-sized = surface.remove("content-sized", default: false)
  let fit = surface.remove("fit", default: none)
  let map = surface.remove("map", default: none)
  let anchor = surface.remove("align", default: none)
  // A cell in an `auto` row track sizes to its content, so its sibling `1fr`
  // tracks receive the remaining height and can align content on the horizon.
  // (`auto` on the horizontal axis is a column width and must not collapse the
  // cell height, so only the vertical axis opts in here.)
  let auto-height = vertical and track == auto
  let region-height = if content-sized or auto-height { auto } else { 100% }
  // `map` is the layout's transform of the slide body alone: variants that
  // recompose user-supplied content (small caps, recoloring, a title/number
  // grid) apply it here, before the affixes join, so `before` and `after`
  // keep their own typography.
  let content = if map == none { content } else { map(content) }
  let content = before + content + after
  // Cell fit modes are the public `fit` helper under two fixed settings, so a
  // layout that shrinks a cell and a deck that shrinks a block go through the
  // same code and cannot drift apart.
  let content = if fit == "width" {
    fit-helper(content, width: 1fr, grow: false)
  } else if fit == "contain" {
    fit-helper(content, grow: false, shrink: true)
  } else {
    content
  }
  // A variant-owned anchor, applied as an explicit element inside the labeled
  // block. Like the title layout's inline anchor, it is variant semantics
  // rather than a styling default: pick another variant to change it.
  let content = if anchor == none { content } else { align(anchor, content) }
  // A fitted cell is never observed. Its content is scaled into the allocation
  // by construction, so there is nothing to report, and observation measures in
  // a region where the fitters have no allocation to solve against (see
  // `unsolvable`) and therefore hand back the unfitted body, which would read
  // as an overflow that the rendered slide does not have.
  if overflow != "off" and fit == none {
    content = observe-overflow(
      content,
      if id == none { path } else { id },
      slide,
      step,
    )
  }
  // One block carries the whole cell, including its internal paint, and is
  // labeled <mosaic-cell-ID>. Native rules target it directly:
  //   show label("mosaic-cell-" + id): set text(...)
  //   show label("mosaic-cell-" + id): set align(horizon)
  //   show label("mosaic-cell-" + id): it => block(fill: ..., it)
  // The inset lives inside the label so wrapping rules paint edge to edge,
  // but em insets are resolved against the text size just outside the label,
  // so cell typography rules do not scale cell geometry.
  grid.cell(inset: 0pt, context {
    let base = text.size
    let inset = if inset == auto { configured-inset() } else { inset }
    let body = block(
      width: 100%,
      height: region-height,
      fill: fill,
      stroke: stroke,
      radius: radius,
      clip: background != none,
    )[
      #if background != none {
        place(top + left, block(width: 100%, height: 100%, background))
      }
      #if id != none {
        for (name, alignment) in (
          center: center + horizon,
          top: top + center,
          right: right + horizon,
          bottom: bottom + center,
          left: left + horizon,
          "top-left": top + left,
          "top-right": top + right,
          "bottom-left": bottom + left,
          "bottom-right": bottom + right,
        ) {
          place(alignment)[
            #metadata(none)#label("mosaic-cell-" + id + "-" + name)
          ]
        }
      }
      #block(
        width: 100%,
        height: region-height,
        inset: resolve-inset(inset, base),
        content,
      )
    ]
    if id == none {
      body
    } else {
      [#body#label("mosaic-cell-" + id)]
    }
  })
}

// `contents` is the id -> content map. Each content-bearing cell looks up its
// own content by id, so there is no positional cursor to thread or keep aligned
// across branches and removed incremental nodes. Returns (content, removed,
// style).
#let render-node(
  node,
  contents,
  step,
  path: "grid",
  overflow: "off",
  slide: initial-slide,
) = {
  if node.kind == "on" {
    let state = status(
      node.range,
      node.before,
      node.after,
      step,
    )
    if state == "removed" {
      return ([], true, none)
    }
    let (child-content, removed, style) = render-node(
      node.child,
      contents,
      step,
      path: path + ".on",
      overflow: overflow,
      slide: slide,
    )
    return (apply-state(state, child-content), removed, style)
  }
  if node.kind == "cell" {
    let style = node.style
    if node.id != none {
      style.insert("_id", node.id)
    }
    let style = if style.len() == 0 { none } else { style }
    let body = if node.content == none { contents.at(node.id) } else { node.content }
    (transform(body, step, heading-scope: path), false, style)
  } else {
    let rendered = ()
    let tracks = ()
    let resolved = resolved-tracks(node)
    for (index, child) in node.children.enumerate() {
      let (child-content, removed, style) = render-node(
        child,
        contents,
        step,
        path: path + "." + str(index),
        overflow: overflow,
        slide: slide,
      )
      if not removed {
        let content = render-cell(
          child-content,
          style,
          step,
          path: path + "." + str(index),
          overflow: overflow,
          slide: slide,
          track: resolved.at(index),
          vertical: node.axis != "width",
        )
        rendered.push(content)
        tracks.push(resolved.at(index))
      }
    }
    if rendered.len() == 0 {
      return ([], true, none)
    }
    // Interior boundaries between the tracks that survived this step; native
    // grid lines are drawn centered in the gutter.
    let stroke = node.at("stroke", default: none)
    let rules = if stroke == none {
      ()
    } else if node.axis == "width" {
      range(1, rendered.len()).map(x => grid.vline(x: x, stroke: stroke))
    } else {
      range(1, rendered.len()).map(y => grid.hline(y: y, stroke: stroke))
    }
    let content = block(
      width: 100%,
      height: 100%,
      if node.axis == "width" {
        grid(
          columns: tracks,
          rows: (1fr,),
          column-gutter: node.gutter,
          ..rules,
          ..rendered,
        )
      } else {
        grid(
          columns: (1fr,),
          rows: tracks,
          row-gutter: node.gutter,
          ..rules,
          ..rendered,
        )
      },
    )
    (content, false, none)
  }
}

#let render(node, contents, step, overflow: "off", slide: initial-slide) = {
  let (body, removed, style) = render-node(
    node,
    contents,
    step,
    path: "grid",
    overflow: overflow,
    slide: slide,
  )
  if style == none or removed {
    body
  } else {
    grid(
      columns: (1fr,),
      rows: (1fr,),
      render-cell(
        body,
        style,
        step,
        path: "grid",
        overflow: overflow,
        slide: slide,
      ),
    )
  }
}
