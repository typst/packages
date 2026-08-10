// Public incremental constructors and canonical deferred records.
#import "../shared.typ": tag, fail, typst-sequence
#import "core.typ": (
  status,
  validate-positive-int,
  validate-range,
  validate-states,
)
#import "../grid/model.typ": is-node
#let wrapper(kind, ..fields) = metadata((
  mosaic: tag,
  kind: kind,
  ..fields.named(),
))

#let record-field-keys = (
  "command-on": ("after", "before", "body", "kind", "mosaic", "range"),
  "temporal-drawing": (
    "args",
    "dim",
    "hide",
    "kind",
    "kwargs",
    "mosaic",
    "render",
  ),
  "temporal-on": ("after", "before", "body", "kind", "mosaic", "range"),
  "temporal-replace": ("align", "bodies", "kind", "mosaic", "start"),
  "temporal-reveal": (
    "after",
    "before",
    "count",
    "items",
    "kind",
    "mosaic",
    "start",
  ),
)

#let temporal-kinds = (
  "temporal-on",
  "temporal-reveal",
  "temporal-replace",
  "temporal-drawing",
)

// Returns the kind of a raw incremental record, or none when the value is not
// one of the requested kinds. Records are canonical: a Mosaic-tagged record of
// a known kind must carry exactly the fields its constructor wrote.
#let record-kind(value, kinds) = {
  if (
    type(value) != dictionary
      or value.at("mosaic", default: none) != tag
      or value.at("kind", default: none) not in kinds
  ) {
    return none
  }
  if value.keys().sorted() != record-field-keys.at(value.kind) {
    fail("invalid " + value.kind + " record")
  }
  value.kind
}

#let is-command-on(value) = record-kind(value, ("command-on",)) != none

#let is-temporal(value, kind: none) = {
  if type(value) != content or value.func() != metadata {
    return false
  }
  let actual = record-kind(value.value, temporal-kinds)
  actual != none and (kind == none or actual == kind)
}

/// Shows a grid node or content only over a step range.
///
/// This is the explicit form of incremental control: the range says exactly
/// which frames the body appears on, independent of source order.
///
/// ```typ
/// #mosaic.slide[
///   == Findings
///   #mosaic.steps.on(1)[First, in isolation.]
///   #mosaic.steps.on("2-")[Then, for the rest of the slide.]
///   #mosaic.steps.on("2-3", after: "dimmed")[A passing remark.]
/// ]
/// ```
///
/// *Ranges*
///
/// - `2`: the single step 2.
/// - `"2-"`: step 2 onward, to the end of the slide.
/// - `"2-4"`: steps 2 through 4 inclusive.
///
/// *States*
///
/// `before` and `after` say what happens outside the range:
///
/// - `"hidden"`: the body reserves its space but is not drawn.
/// - `"visible"`: the body is drawn normally.
/// - `"dimmed"`: the body is drawn muted, which is how a point stays legible
///   after the discussion has moved on.
///
/// The body may be content or a Mosaic grid node, so whole regions of a layout
/// can appear and disappear, not just text.
///
/// -> content | dictionary
#let on(
  /// Which steps show the body: an integer, `"N-"` for open-ended, or `"N-M"`
  /// for a closed range.
  /// -> int | str
  range,
  /// How the body renders before the range: `"hidden"`, `"visible"`, or
  /// `"dimmed"`.
  /// -> str
  before: "hidden",
  /// How the body renders after the range: `"hidden"`, `"visible"`, or
  /// `"dimmed"`.
  /// -> str
  after: "hidden",
  /// Content or Mosaic grid node controlled by the range.
  /// -> content | dictionary
  body,
) = {
  _ = validate-range(range)
  _ = validate-states(before, after)
  if is-node(body) {
    (
      mosaic: tag,
      kind: "on",
      range: range,
      before: before,
      after: after,
      child: body,
    )
  } else if type(body) == content {
    wrapper(
      "temporal-on",
      range: range,
      before: before,
      after: after,
      body: body,
    )
  } else {
    (
      mosaic: tag,
      kind: "command-on",
      range: range,
      before: before,
      after: after,
      body: body,
    )
  }
}

#let content-children(body) = if (
  type(body) == content and body.func() == typst-sequence
) {
  body.children
} else {
  (body,)
}

#let is-list-item(body) = (
  type(body) == content
    and body.func() in (list.item, enum.item, terms.item)
)

// Splits revealed items into slots. A single body holding list items reveals
// one item per step, so its untimed siblings ride along with `index: none`;
// every other shape reveals one whole entry per step. `list` reports which
// shape was found, because only the first can render as a marker grid.
#let reveal-slots(items) = {
  if items.len() == 1 and type(items.first()) == content {
    let children = content-children(items.first())
    if children.any(is-list-item) {
      let index = 0
      let slots = ()
      for child in children {
        if is-list-item(child) {
          slots.push((index: index, body: child))
          index += 1
        } else {
          slots.push((index: none, body: child))
        }
      }
      return (list: true, slots: slots)
    }
  }
  (
    list: false,
    slots: items.enumerate().map(((index, item)) => (
      index: index,
      body: item,
    )),
  )
}

#let reveal-item-count(items) = (
  reveal-slots(items).slots.filter(slot => slot.index != none).len()
)

// Resolves one reveal slot's state at a step. An untimed slot rides along with
// the revealed items and is always visible.
#let slot-status(temporal, slot, step) = {
  if slot.index == none {
    return "visible"
  }
  status(
    temporal.start + slot.index,
    temporal.before,
    temporal.after,
    step,
  )
}

// Index of the replace body shown at a step, or none before the first one.
// Steps past the last body keep showing it.
#let replace-index(temporal, step) = {
  if step < temporal.start {
    return none
  }
  calc.min(step - temporal.start, temporal.bodies.len() - 1)
}

/// Reveals content or grid nodes one step at a time.
///
/// Where `on` sets one range by hand, `reveal` assigns consecutive steps for
/// you, which is what a bulleted build usually wants.
///
/// ```typ
/// #mosaic.steps.reveal[
///   - Collect the data
///   - Fit the model
///   - Report the interval
/// ]
/// ```
///
/// *What counts as an item*
///
/// - A single content block holding list items reveals one list item per step.
///   Any non-item siblings inside that block ride along and stay visible
///   throughout.
/// - Otherwise each positional argument is one item, revealed whole.
/// - Grid nodes may be revealed too, but content and nodes cannot be mixed in
///   one call.
///
/// ```typ
/// #mosaic.steps.reveal(start: 2, after: "dimmed",
///   [First claim], [Second claim], [Third claim],
/// )
/// ```
///
/// -> content | array
#let reveal(
  /// Step on which the first item appears. Later items follow one step apart.
  /// -> int
  start: 1,
  /// How an item renders before its own step: `"hidden"`, `"visible"`, or
  /// `"dimmed"`.
  /// -> str
  before: "hidden",
  /// How an item renders after its own step: `"visible"` keeps it on screen,
  /// `"dimmed"` mutes it as the build moves on, and `"hidden"` removes it.
  /// -> str
  after: "visible",
  /// The items: content blocks or Mosaic grid nodes, but not both. At least one
  /// is required.
  /// -> arguments
  ..items,
) = {
  start = validate-positive-int(start)
  _ = validate-states(before, after)
  let items = items.pos()
  if items.len() == 0 {
    fail("reveal expects content or at least one grid node")
  }
  let node-count = items.filter(is-node).len()
  if node-count > 0 {
    if node-count != items.len() {
      fail("reveal cannot mix content and grid nodes")
    }
    return items.enumerate().map(((index, node)) => on(
      start + index,
      before: before,
      after: after,
      node,
    ))
  }
  if not items.all(item => type(item) == content) {
    fail("reveal expects content or Mosaic grid nodes")
  }
  wrapper(
    "temporal-reveal",
    start: start,
    before: before,
    after: after,
    count: reveal-item-count(items),
    items: items,
  )
}

/// Replaces one content block with the next on successive steps.
///
/// Exactly one body is on screen at a time, and every body occupies the same
/// space, so surrounding content does not shift as the slide advances. That
/// makes it the tool for an equation that rewrites itself or a diagram that
/// gains an annotation.
///
/// ```typ
/// #mosaic.steps.replace(
///   align: center + horizon,
///   $ a^2 + b^2 $,
///   $ a^2 + b^2 = c^2 $,
/// )
/// ```
///
/// This accepts content only. To swap structure, keep the grid stable and
/// replace the content inside a cell.
///
/// -> content
#let replace(
  /// Step on which the first body appears. Each later body replaces it one step
  /// further on.
  /// -> int
  start: 1,
  /// Alignment applied to every body inside the shared area they occupy.
  /// -> alignment
  align: top + left,
  /// The content blocks, shown one per step in order. At least one is required.
  /// -> arguments
  ..bodies,
) = {
  start = validate-positive-int(start)
  let bodies = bodies.pos()
  if bodies.len() == 0 {
    fail("replace expects at least one content block")
  }
  if not bodies.all(body => type(body) == content) {
    fail(
      "replace accepts content only; replace content inside a stable "
        + "cell rather than replacing grid trees",
    )
  }
  wrapper(
    "temporal-replace",
    start: start,
    align: align,
    bodies: bodies,
  )
}

/// Teaches Mosaic to step through a drawing library's own command values.
///
/// `on` and `reveal` work on content, which a drawing package such as CETZ or
/// Fletcher does not produce: its nodes and edges are opaque command values
/// that only mean something to its own renderer. `drawing` bridges the two.
/// Mosaic resolves the step ranges, drops what this frame does not show, passes
/// what remains through `hide` or `dim`, and hands the surviving array to
/// `render`.
///
/// The usual shape is to bind the three functions once, then call the result
/// like the library's own renderer.
///
/// ```typ
/// #import "@preview/fletcher:0.5.8" as fletcher
///
/// #let diagram = mosaic.steps.drawing.with(
///   render: fletcher.diagram,
///   hide: fletcher.hide,
/// )
///
/// #diagram(
///   spacing: 4em,
///   fletcher.node((0, 0), `reading`),
///   mosaic.steps.on("2-", (
///     fletcher.edge(`read()`, "-|>"),
///     fletcher.node((1, 0), `eof`),
///   )),
/// )
/// ```
///
/// Positional arguments are the commands, each of which may be wrapped in `on`
/// or `reveal`, alone or as an array. Named arguments are forwarded untouched to
/// `render`, which is how `spacing:` above reaches `fletcher.diagram`.
///
/// -> content
#let drawing(
  /// Draws the frame. Called as `render(..named, commands)` with the named
  /// arguments given here and the array of commands this frame keeps. Usually
  /// the library's own top-level renderer.
  /// -> function
  render: none,
  /// Turns one command into its invisible counterpart, so it still reserves
  /// space and the drawing does not shift between frames. Usually the library's
  /// own `hide`.
  /// -> function
  hide: none,
  /// Turns one command into its muted counterpart. Required only if some step
  /// range uses the `"dimmed"` state; omitting it makes that an error.
  /// -> function | none
  dim: none,
  /// Positionally, the drawing commands, optionally wrapped in `on` or
  /// `reveal`. By name, arguments forwarded unchanged to `render`.
  /// -> arguments
  ..args,
) = {
  if type(render) != function {
    fail("drawing render must be a function")
  }
  if type(hide) != function {
    fail("drawing hide must be a function")
  }
  if dim != none and type(dim) != function {
    fail("drawing dim must be none or a function")
  }
  wrapper(
    "temporal-drawing",
    render: render,
    hide: hide,
    dim: dim,
    kwargs: args.named(),
    args: args.pos(),
  )
}
