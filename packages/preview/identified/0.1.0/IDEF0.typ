/// Module provides API to create IDEF0 diagrams.
///
/// Usage:
/// ```typ
/// #import IDEF0: *
/// ```

#import "deps.typ": cetz, fletcher, typsy

/// IDEF0 function/process/block.
#let node(
  position,
  width: 9em,
  height: 6em,
  cost-suffix: none,
  format-cost-number: auto,
  ..args,
) = {
  let size = (width: width, height: height)
  let blk(body) = block(..size, inset: 0.3em, body)
  let get-text(body) = {
    align(center + horizon, block(..size, inset: 0.5em, body))
  }
  let get-number(num) = place(bottom + right, text(0.8em, num))
  if format-cost-number == auto {
    format-cost-number = number => str(number)
      .clusters()
      .rev()
      .chunks(3)
      .map(c => c.rev().join())
      .rev()
      .join(" ")
  }
  let get-cost(cost) = {
    let cost = if type(cost) == content { cost.text } else { cost }
    place(bottom + left, text(0.8em, format-cost-number(cost) + cost-suffix))
  }
  let text
  let number
  let cost
  let content = []
  let pos = args.pos()
  if pos.len() == 1 {
    (text, ..pos) = pos
    content = blk(get-text(text))
  } else if pos.len() == 2 {
    (text, number, ..pos) = pos
    content = blk(get-text(text) + get-number(number))
  } else if pos.len() > 2 {
    (text, number, cost, ..pos) = pos
    content = blk(get-text(text) + get-number(number) + get-cost(cost))
  }
  fletcher.node(position, content, ..pos, ..size, ..args.named())
}

/// IDEF0 arrow/connection.
///
/// Since it's a wrapper for the `fletcher.edge` (with special handling of
/// `label-pos`), refer to its documentation / for a full list of available
/// arguments.
#let edge(..args) = {
  let named-args = args.named()
  if "label-pos" in named-args {
    named-args.label-pos = float(named-args.label-pos)
  }
  fletcher.edge(marks: "-|>", ..args.pos(), ..named-args)
}

/// IDEF0 arrow/connection, but tip is at the beginning.
///
/// Since it's a wrapper for the `fletcher.edge` (with special handling of
/// `label-pos` and `label-side`), refer to its documentation / for a full list
/// of available / arguments.
#let edge-rev(..args) = {
  let named-args = args.named()
  if "label-pos" in named-args {
    named-args.label-pos = 1 - float(named-args.label-pos)
  }
  if "label-side" in named-args {
    let side = named-args.label-side
    if side in (left, right) {
      named-args.label-side = if side == left { right } else { left }
    }
  }
  fletcher.edge(marks: "<|-", ..args.pos(), ..named-args)
}

// #let edge-cross-page(ref: [], ..args) = {
//   edge(marks: "O-|>", ..args)
// }

// #let edge-rev-cross-page(ref: [], ..args) = {
//   edge-rev(marks: "<|-O", ..args)
// }

/// A zig-zag line that connects "detached" label to the IDEF0 arrow/connection.
/// In simple cases the label is directly next to the IDEF0 arrow/connection
/// ("attached"), therefore the zig-zag line is not needed.
///
/// Since it's the wrapper for the `fletcher.edge`, refer to its documentation
/// for a full list of available arguments.
#let zigzag = fletcher.edge.with(
  decorations: cetz.decorations.zigzag.with(
    segments: 1,
    amplitude: -0.2,
    factor: 110%,
  ),
  label-pos: 1,
  layer: 1,
)

/// Get index of partition point
/// - func (function): Return true if less or equal, false if greater than partition point
/// based on rust libcore partition point
#let partition-point(range, func) = {
  let size = range.len()
  if size == 0 { panic("Empty range in partition-point") }
  let base = 0
  while size > 1 {
    let half = calc.div-euclid(size, 2)
    let mid = base + half
    let lte = func(range.at(mid))
    base = if lte { mid } else { base }
    size -= half
  }
  let lte = func(range.at(base))
  base + int(lte)
}

/// From https://forum.typst.app/t/4618/2. This generally saves only about
/// 20–40 ms for a single diagram example.
#let estimate-min-width(body) = {
  let nominal-length = measure(body).width
  let ceil = calc.ceil(nominal-length.pt())
  let widths = range(ceil, step: 1)
  let pp = partition-point(widths, w => {
    let max-width = w * 1pt
    let actual-width = measure(body, width: max-width).width
    not (actual-width < max-width)
  })
  let best-guess-max-width = widths.at(pp, default: ceil) * 1pt
  measure(body, width: best-guess-max-width).width
}

/// Force resolved auto stroke values.
///
/// Origin: `@preview/t4t:0.4.3`
#let stroke-dict(stroke, ..overrides) = {
  let dict = (
    paint: {
      let paint = std.stroke(stroke).paint
      if paint == auto { black } else { paint }
    },
    thickness: {
      let thickness = std.stroke(stroke).thickness
      if thickness == auto { 1pt } else { thickness }
    },
    dash: "solid",
    cap: "round",
    join: "round",
  )
  if type(stroke) == dictionary { dict = dict + stroke }
  return dict + overrides.named()
}

/// Make an array of size `size`. Return original data if already is an array.
#let make-array(data, size: 1) = {
  if type(data) != array { (data,) * size } else { data }
}

/// Top-level (context) IDEF0 diagram.
///
/// - input (array, str, content): A single input or an array of them. An input
///     can be `str` or `content`, or 1-element array of that with optional
///     second overrides `dictionary` element:
///     - `"input" | [input]`
///     - `("input" | [input],)`
///     - `("input" | [input], (:))`
/// - output (array, str, content): Same as `input`.
/// - control (array, str, content): Same as `input`.
/// - mechanism (array, str, content): Same as `input`.
/// - body (str, content): Name/content of the block/node.
/// - width (length): Used for block/node width, and therefore for all related
///     calculations.
/// - height (length): Used for block/node height, and therefore for all related
///     calculations.
/// - spacing (length, array): Value passed to `fletcher.diagram.spacing`.
/// - input-stroke (stroke): Stroke for `input` items.
/// - output-stroke (stroke): Stroke for `output` items.
/// - control-stroke (stroke): Stroke for `control` items.
/// - mechanism-stroke (stroke, array): Stroke for `mechanism` items. Can be
///     set per-mechanism defined (array).
/// - node-stroke (stroke, none): Value passed to
///     `fletcher.diagram.node-stroke`.
/// - edge-stroke (stroke, none): Value passed to
///     `fletcher.diagram.edge-stroke`.
/// - edge-corner-radius (length, none): Value passed to
///     `fletcher.diagram.edge-corner-radius`.
/// - label-sep (length): Value passed to `fletcher.diagram.debug` (with some
///     adjustments).
/// - debug (bool): Value passed to `fletcher.diagram.debug`.
/// - diagram (function): `fletcher.diagram` that is modified and used.
/// - node (function): `fletcher.node` that is modified (width/height) and used.
/// - node-styling (function): Styling to apply to the body of the block/node.
/// - edge (function): `fletcher.edge`.
/// - edge-rev (function): `fletcher.edge` that point the opposite direction.
#let context-diagram(
  input: (),
  output: (),
  control: (),
  mechanism: (),
  body,
  width: 6cm,
  height: 4cm,
  spacing: (2cm, 2cm),
  input-stroke: 1pt,
  output-stroke: 1pt,
  control-stroke: 1pt,
  mechanism-stroke: (),
  node-stroke: 1pt,
  edge-stroke: 1pt,
  edge-corner-radius: 5pt,
  label-sep: 0.2em,
  debug: false,
  diagram: fletcher.diagram,
  node: node,
  node-styling: body => text(1.2em, strong(body)),
  edge: edge,
  edge-rev: edge-rev,
) = {
  set text(top-edge: "bounds", bottom-edge: "bounds")
  input-stroke = stroke(stroke-dict(input-stroke))
  output-stroke = stroke(stroke-dict(output-stroke))
  control-stroke = stroke(stroke-dict(control-stroke))
  mechanism-stroke = make-array(mechanism-stroke, size: mechanism.len())
  mechanism-stroke = mechanism-stroke.map(x => stroke(stroke-dict(x)))
  edge-stroke = stroke(stroke-dict(edge-stroke))
  diagram = diagram.with(
    label-sep: label-sep - 0.2em + edge-stroke.thickness / 2,
    edge-stroke: edge-stroke,
    spacing: spacing,
    node-stroke: node-stroke,
    edge-corner-radius: edge-corner-radius,
    debug: debug,
  )

  let normalize(items) = {
    import typsy: *
    let SimplestItem = Union(Str, Content)
    let SimpleItem = Array(SimplestItem)
    let Overrides = Dictionary(..Any)
    let ItemWithOverrides = Array(SimplestItem, Overrides)
    let Item = Union(SimplestItem, SimpleItem, ItemWithOverrides)
    if matches(Item, items) {
      if matches(SimplestItem, items) {
        ((items, (:)),)
      } else if matches(SimpleItem, items) {
        ((..items, (:)),)
      } else {
        (items,)
      }
    } else if matches(Array(..Item), items) {
      items.map(item => {
        if matches(SimplestItem, item) {
          (item, (:))
        } else if matches(SimpleItem, item) {
          (..item, (:))
        } else {
          item
        }
      })
    } else { panic("Unable to parse arguments") }
  }

  input = normalize(input)
  output = normalize(output)
  control = normalize(control)
  mechanism = normalize(mechanism)

  let W = width
  let H = height

  let old-node = node
  let node(..args) = old-node(width: W, height: H, ..args)

  let will-fit(label-min-size-list, side) = {
    let total = label-min-size-list.len()
    assert(total != 0)
    if total == 1 { return true }
    let line-stroke-thickness = edge-stroke.thickness
    let label-padding = label-sep.to-absolute()
    let need-space = (
      label-min-size-list.slice(0, -1).sum()
        + line-stroke-thickness * total
        + label-padding * total
    )
    // Make sure each line + label are readable and don't overlap.
    let readable-space = label-padding * (total - 1)
    need-space + readable-space <= side
  }

  let inputs = state("inputs", (:))
  let outputs = state("outputs", (:))
  let controls = state("controls", (:))
  let mechanisms = state("mechanisms", (:))
  let states = (inputs, outputs, controls, mechanisms)
  for (data, state) in (input, output, control, mechanism).zip(states) {
    context for (entry, _) in data {
      let width = estimate-min-width(entry)
      let height = measure(entry, width: width).height
      let height-normal = measure(entry).height
      let width-normal = measure(entry).width
      state.update(
        x => (
          width: (..x.at("width", default: ()), width),
          height: (..x.at("height", default: ()), height),
          width-normal: (..x.at("width-normal", default: ()), width-normal),
          height-normal: (..x.at("height-normal", default: ()), height-normal),
        ),
      )
    }
  }

  let get-offset(label-min-size-list, side, i) = {
    assert(label-min-size-list.len() != 0)
    // let label-min-size-list = label-min-size-list.rev()
    let total = label-min-size-list.len()
    if total == 1 { return 0 }
    // -side / 2 + (i + 1) * side / 4
    let line-stroke-thickness = edge-stroke.thickness
    let label-padding = label-sep.to-absolute()
    let need-space = (
      label-min-size-list.slice(0, -1).sum()
        + line-stroke-thickness * total
        + label-padding * total
    )
    // Make sure each line + label are readable and don't overlap.
    let readable-space = label-padding * (total - 1)
    if will-fit(label-min-size-list, side) {
      // CSS's space-evenly
      let even-spacing = (side - need-space) / (total + 1)
      let left-start = -side / 2 // Start coordinates at left side.
      let offset = (
        (even-spacing + line-stroke-thickness + label-padding) * i
          + label-min-size-list.slice(0, i).sum(default: 0pt)
          + even-spacing
          + line-stroke-thickness / 2
      )
      left-start + offset
    } else {
      let need-space = (
        label-min-size-list.slice(1, -1).sum(default: 0pt)
          + line-stroke-thickness * total
          + label-padding * total
      )
      // CSS's space-evenly
      let even-spacing = (side - need-space) / (total + 1)
      let left-start = -side / 2 // Start coordinates at left side.
      let offset = (
        (even-spacing + line-stroke-thickness + label-padding) * i
          + label-min-size-list.slice(1, i).sum(default: 0pt)
          + even-spacing
          + line-stroke-thickness / 2
      )
      let value = left-start + offset
      value
    }
  }

  let get-label-side(label-min-size-list, side, i, input: false) = {
    assert(label-min-size-list.len() != 0)
    let total = label-min-size-list.len()
    if total == 1 { return if input { left } else { right } }
    let alignment = if will-fit(label-min-size-list, side) {
      ((right,) * total).at(i)
    } else {
      (left, ..(right,) * (total - 1)).at(i)
    }
    if input { alignment.inv() } else { alignment }
  }

  let get-start-label-pos(
    left,
    right,
    width,
    offset: 0pt,
    opposite: false,
  ) = {
    let (x1, y1) = left
    let (x2, y2) = right
    assert(x1 != none)
    assert(x2 != none)
    assert(y1 != none)
    // assert(y2 != none)
    let (x1, x2) = (x1, x2).map(x => (x * (W + spacing.first())).pt())
    let (y1, y2) = (y1, y2).map(x => (x * (H + spacing.first())).pt())
    let (x2, y2) = (x2 - W.pt() / 2, y2 - H.pt() / 2)
    let distance = (
      calc.sqrt(calc.pow((x1 - x2), 2) + calc.pow((y1 - y2), 2)) * 1pt
    )
    let length = (width + offset).to-absolute()
    if opposite { length = distance - length }
    length / (distance)
  }


  context diagram({
    let root = (0, 0)
    node(root, node-styling[#body])

    let side = H
    let side-opposite = W

    let dimentions = inputs.get()
    if dimentions.len() != 0 {
      let normal-heights = dimentions.height-normal.rev()
      let max-label-width = calc.max(..dimentions.width-normal)
      // Formula was developed through trial and error (half of side + arrow).
      let block-size-compensation = 1em + 0.5pt * side-opposite.pt()
      let width = max-label-width + block-size-compensation + 2em
      let other-coordinate = (rel: (-width, 0pt)) // Left coordinate
      for (i, (entry, overrides)) in input.rev().enumerate() {
        entry = {
          set text(input-stroke.paint)
          entry
        }
        let get(field) = overrides
          .pairs()
          .filter(((k, v)) => k == field)
          .map(((_, v)) => v)
          .first(default: none)
        // entry = block(height: dimentions.height-normal.rev().at(i), entry, stroke: 0.1pt)
        let settings = (
          stroke: input-stroke,
          shift: -get-offset(normal-heights, side, i),
          label-side: get-label-side(normal-heights, side, i, input: true),
          label-pos: get-start-label-pos(
            (-width.to-absolute() / side-opposite, 0),
            root,
            dimentions.width-normal.rev().at(i),
            offset: -1.5em,
          ),
        )
        edge-rev(root, other-coordinate, ..settings + overrides)[#entry]
      }
    }

    let dimentions = outputs.get()
    if dimentions.len() != 0 {
      let normal-heights = dimentions.height-normal.rev()
      let max-label-width = calc.max(..dimentions.width-normal.rev())
      let block-size-compensation = 1em + 0.5pt * side-opposite.pt()
      let width = max-label-width + block-size-compensation + 2em
      let other-coordinate = (rel: (width, 0pt)) // Right coordinate
      for (i, (entry, overrides)) in output.rev().enumerate() {
        entry = {
          set text(output-stroke.paint)
          entry
        }
        // entry = block(width: dimentions.width-normal.at(i), entry, stroke: 0.1pt)
        let settings = (
          stroke: output-stroke,
          shift: get-offset(normal-heights, side, i),
          label-side: get-label-side(normal-heights, side, i).inv(),
          label-pos: get-start-label-pos(
            root,
            (width.to-absolute() / side-opposite, 0),
            dimentions.width-normal.at(i),
            offset: 3em,
          ),
        )
        edge(root, other-coordinate, ..settings + overrides)[#entry]
      }
    }

    let side = W
    let side-opposite = H

    let dimentions = controls.get()
    if dimentions.len() != 0 {
      let max-label-height = calc.max(..dimentions.height)
      let block-size-compensation = 1em + 0.5pt * side-opposite.pt()
      let height = max-label-height + block-size-compensation + 2em
      let other-coordinate = (rel: (0pt, height)) // Top coordinate
      for (i, (entry, overrides)) in control.enumerate() {
        entry = {
          set text(control-stroke.paint)
          entry
        }
        // entry = block(width: dimentions.width.at(i), entry, stroke: 0.1pt)
        entry = block(width: dimentions.width.at(i), entry)
        let settings = (
          stroke: control-stroke,
          shift: -get-offset(dimentions.width, side, i),
          label-side: get-label-side(dimentions.width, side, i).inv(),
          label-pos: get-start-label-pos(
            (0, height.to-absolute() / side-opposite),
            root,
            dimentions.height.at(i),
            offset: 4em,
          ),
        )
        edge-rev(root, other-coordinate, ..settings + overrides)[#entry]
      }
    }

    let dimentions = mechanisms.get()
    if dimentions.len() != 0 {
      let max-label-height = calc.max(..dimentions.height)
      let block-size-compensation = 1em + 0.5pt * side-opposite.pt()
      let height = max-label-height + block-size-compensation + 2em
      let other-coordinate = (rel: (0pt, -height)) // Bottom coordinate
      for (i, (entry, overrides)) in mechanism.enumerate() {
        let stroke = mechanism-stroke.at(i, default: none)
        entry = {
          set text(fill: mechanism-stroke.at(i).paint) if stroke != none
          entry
        }
        // entry = block(width: dimentions.width.at(i), entry, stroke: 0.1pt)
        entry = block(width: dimentions.width.at(i), entry)
        stroke = if stroke != none { (stroke: stroke) } else { (:) }
        let settings = (
          ..stroke,
          shift: get-offset(dimentions.width, side, i),
          label-side: get-label-side(dimentions.width, side, i),
          label-pos: get-start-label-pos(
            root,
            (0, height.to-absolute() / side-opposite),
            dimentions.height.at(i),
            offset: 0.5em,
          ),
        )
        edge-rev(root, other-coordinate, ..settings + overrides)[#entry]
      }
    }
  })
}

/// Block attachment type. Can be used in `decomposition-diagram` definition.
#let TYPE = (
  INPUT: left,
  // OUTPUT: right,
  CONTROL: top,
  // MECHANISM: bottom,
)

/// IDEF0 decomposition diagram.
///
/// - input (dictionary): A dictionary of keys (used in `connections`) and
///     input names/labels (`str` or `content`).
/// - output (dictionary): A dictionary of keys (used in `connections`) and
///     output names/labels (`str` or `content`).
/// - control (dictionary): A dictionary of keys (used in `connections`) and
///     control names/labels (`str` or `content`).
/// - mechanism (dictionary): A dictionary of keys (used in `connections`) and
///     mechanism names/labels (`str` or `content`).
/// - blocks (dictionary):A dictionary of keys (used in `connections`) and
///     block/node names (`str` or `content`).
/// - connections (array): An array of connections, that consist of 2 keys
///     between which a connection/arrows must be created, and 3 optional
///     elements (connection type, label, overrides):
///     1. Between input/output/control/mechanism and block:
///        - `("key1", "key2")`
///        - `("key1", "key2", (:))`
///     2. Between blocks:
///        - `("key1", "key2", "label" | [label])`
///        - `("key1", "key2", "label" | [label], (:))`
///        - `("key1", "key2", TYPE.<any>, "label" | [label])`
///        - `("key1", "key2", TYPE.<any>, "label" | [label], (:))`
///        - `("key1", "key2", "label" | [label], TYPE.<any>)`
///        - `("key1", "key2", "label" | [label], TYPE.<any>, (:))`
///     - Default type between blocks is `TYPE.INPUT`.
///     - Default overrides for the first group: `(detached: false)`.
///     - Default overrides for the second group:
///       `(detached: true, min-width: true)`.
///     - Connections with the same label share not only their label (shown only
///       once), but also their overrides (can/should be defined for only one).
///     - Overrides are passed to `fletcher.edge`.
///     - `label-pos` override for `(detached: true)` in addition to default
///       types, can be `(coords, shift) => ()`. `coords` is array of
///       connection's coordinate points, `shift` is `fletcher.edge.shift`.
///     - `shift` override in addition to default types, can be
///       `old-shift => <new-shift>`. `old-shift` and `<new-shift>` are
///       `fletcher.edge.shift`.
/// - width (length): Used for block/node width, and therefore for all related
///     calculations.
/// - height (length): Used for block/node height, and therefore for all related
///     calculations.
/// - spacing (length, array): Value passed to `fletcher.diagram.spacing`.
/// - input-stroke (stroke): Stroke for `input` items.
/// - output-stroke (stroke): Stroke for `output` items.
/// - control-stroke (stroke): Stroke for `control` items.
/// - mechanism-stroke (stroke, array): Stroke for `mechanism` items. Can be
///     set per-mechanism defined (array).
/// - node-stroke (stroke, none): Value passed to
///     `fletcher.diagram.node-stroke`.
/// - edge-stroke (stroke, none): Value passed to
///     `fletcher.diagram.edge-stroke`.
/// - edge-corner-radius (length, none): Value passed to
///     `fletcher.diagram.edge-corner-radius`.
/// - label-sep (length): Value passed to `fletcher.diagram.debug` (with some
///     adjustments).
/// - debug (bool): Value passed to `fletcher.diagram.debug`.
/// - diagram (function): `fletcher.diagram` that is modified and used.
/// - node (function): `fletcher.node` that is modified (width/height) and used.
/// - node-styling (function): Styling to apply to the body of the block/node.
/// - edge (function): `fletcher.edge`.
/// - edge-rev (function): `fletcher.edge` that point the opposite direction.
#let decomposition-diagram(
  input: (:),
  output: (:),
  control: (:),
  mechanism: (:),
  blocks: (:),
  connections: (),
  height: 4cm,
  width: 6cm,
  spacing: (2cm, 1cm),
  input-stroke: 1pt,
  output-stroke: 1pt,
  control-stroke: 1pt,
  mechanism-stroke: (),
  node-stroke: 1pt,
  edge-stroke: 1pt,
  edge-corner-radius: 5pt,
  label-sep: 0.2em,
  debug: false,
  diagram: fletcher.diagram,
  node: node,
  node-styling: body => text(1.2em, strong(body)),
  edge: edge,
  edge-rev: edge-rev,
) = {
  set text(top-edge: "bounds", bottom-edge: "bounds")
  input-stroke = stroke(stroke-dict(input-stroke))
  output-stroke = stroke(stroke-dict(output-stroke))
  control-stroke = stroke(stroke-dict(control-stroke))
  mechanism-stroke = make-array(mechanism-stroke, size: mechanism.len())
  mechanism-stroke = mechanism-stroke.map(x => stroke(stroke-dict(x)))
  edge-stroke = stroke(stroke-dict(edge-stroke))
  diagram = diagram.with(
    label-sep: label-sep - 0.2em + edge-stroke.thickness / 2,
    edge-stroke: edge-stroke,
    spacing: spacing,
    node-stroke: node-stroke,
    edge-corner-radius: edge-corner-radius,
    debug: debug,
  )

  let W = width
  let H = height

  let old-node = node
  let node(..args) = old-node(width: W, height: H, ..args)

  let will-fit(label-min-size-list, side) = {
    let total = label-min-size-list.len()
    assert(total != 0)
    if total == 1 { return true }
    let line-stroke-thickness = edge-stroke.thickness
    let label-padding = label-sep.to-absolute()
    let need-space = (
      label-min-size-list.slice(0, -1).sum()
        + line-stroke-thickness * total
        + label-padding * total
    )
    // Make sure each line + label are readable and don't overlap.
    let readable-space = label-padding * (total - 1)
    need-space + readable-space <= side
  }

  let get-connections(what) = {
    let is-in(dict) = ((k, v, ..)) => k in dict.keys()
    let connections1 = connections.filter(is-in(what))
    let is-in(dict) = ((k, v, ..)) => v in dict.keys()
    let swap = ((k, v, ..rest)) => (v, k, ..rest)
    let connections2 = connections.filter(is-in(what)).map(swap)
    connections1 + connections2
  }

  let override-or(default, other) = {
    if default != none { default } else { other }
  }

  /// Returns extracted `(type, label, overrides)`.
  let extract-type-label-overrides(args) = {
    let default-type = TYPE.INPUT
    let default-label = none
    let default-overrides = (detached: true, min-width: true)
    let type-of(value, default) = type(value) == type(default)
    let is-type(value) = type-of(value, default-type)
    let is-overrides(value) = type-of(value, default-overrides)
    let is-label(value) = not is-type(value) and not is-overrides(value)
    if args.len() == 0 {
      (default-type, default-label, default-overrides)
    } else if args.len() == 1 {
      let a = args.first()
      if type(a) == type(default-type) {
        (a, default-label, default-overrides)
      } else if type(a) == type(default-overrides) {
        (default-type, default-label, default-overrides + a)
      } else {
        (default-type, a, default-overrides)
      }
    } else if args.len() == 2 {
      let (a, b) = args
      assert(not is-overrides(a), message: "Overrides must come last")
      if is-type(a) and is-label(b) {
        (a, b, default-overrides)
      } else if is-type(a) and is-overrides(b) {
        (a, default-label, default-overrides + b)
      } else if is-label(a) and is-overrides(b) {
        (default-type, a, default-overrides + b)
      } else if is-label(a) and is-type(b) {
        (b, a, default-overrides)
      } else if is-label(a) and is-overrides(b) {
        (default-type, a, default-overrides + b)
      } else { panic("Unreachable") }
    } else if args.len() == 3 {
      let (a, b, c) = args
      assert(
        not (is-overrides(a) or is-overrides(b)),
        message: "Overrides must come last",
      )
      if is-type(a) and is-label(b) {
        (a, b, default-overrides + c)
      } else if is-label(a) and is-type(b) {
        (b, a, default-overrides + c)
      } else { panic("Unreachable") }
    } else { panic("Too many arguments. At most 5 is accepted.") }
  }

  let normalize(args) = {
    assert(args.len() in range(2, 3 + 1))
    let normalize-overrides(overrides) = {
      // TODO: make a proper (deep) fold/merge.
      let default-overrides = (detached: false)
      default-overrides + overrides
    }
    if args.len() == 2 {
      args + (normalize-overrides((:)),)
    } else {
      let (a, b, overrides) = args
      (a, b, normalize-overrides(overrides))
    }
  }

  let input-connections = get-connections(input).map(normalize)
  let output-connections = get-connections(output).map(normalize)
  let control-connections = get-connections(control).map(normalize)
  let mechanism-connections = get-connections(mechanism).map(normalize)
  let block-connections = connections
    .filter(((k, v, ..)) => {
      k in blocks.keys() and v in blocks.keys()
    })
    .map(args => {
      assert(args.len() in range(2, 5 + 1))
      let (a, b, ..args) = args
      (a, b, ..extract-type-label-overrides(args))
    })

  let input-sizes = state("input-sizes", (:))
  context for (k, v) in input.pairs() {
    let size = measure(v)
    input-sizes.update(x => x + ((k): size))
  }

  let output-sizes = state("output-sizes", (:))
  context for (k, v) in output.pairs() {
    let size = measure(v)
    output-sizes.update(x => x + ((k): size))
  }

  let control-sizes = state("control-sizes", (:))
  context for (k, v) in control.pairs() {
    let width = estimate-min-width(v)
    let height = measure(v, width: width).height
    control-sizes.update(x => x + ((k): (width: width, height: height)))
  }

  let mechanism-sizes = state("mechanism-sizes", (:))
  context for (k, v) in mechanism.pairs() {
    // let width = estimate-min-width(v)
    // let height = measure(v, width: width).height
    // mechanism-sizes.update(x => x + ((k): (width: width, height: height)))
    let size = measure(v)
    mechanism-sizes.update(x => x + ((k): size))
  }

  let block-sizes = state("block-sizes", ())
  context for (k, v, ..args) in block-connections {
    let (_, label, _) = extract-type-label-overrides(args)
    if label == none { continue }
    let width = estimate-min-width(label)
    // let height = measure(v, width: width).height
    // mechanism-sizes.update(x => x + ((k): (width: width, height: height)))
    // let size = measure(v)
    block-sizes.update(x => x + ((label, width),))
  }

  let get-offset(label-min-size-list, side, i, stroke, output: false) = {
    assert(label-min-size-list.len() != 0)
    // let label-min-size-list = label-min-size-list.rev()
    let total = label-min-size-list.len()
    if total == 1 { return 0pt }
    // -side / 2 + (i + 1) * side / 4
    let line-stroke-thickness = stroke.thickness
    let label-padding = label-sep.to-absolute()
    let need-space = (
      label-min-size-list.slice(0, -1).sum()
        + line-stroke-thickness * total
        + label-padding * total
    )
    // Make sure each line + label are readable and don't overlap.
    let readable-space = label-padding * (total - 1)
    if will-fit(label-min-size-list, side) {
      // CSS's space-evenly
      let even-spacing = (side - need-space) / (total + 1)
      let left-start = -side / 2 // Start coordinates at left side.
      let offset = (
        (even-spacing + line-stroke-thickness + label-padding) * i
          + label-min-size-list.slice(0, i).sum(default: 0pt)
          + even-spacing
          + line-stroke-thickness / 2
      )
      left-start + offset
    } else {
      let need-space = (
        label-min-size-list.slice(1, -1).sum(default: 0pt)
          + line-stroke-thickness * total
          + label-padding * total
      )
      // CSS's space-evenly
      let even-spacing = (side - need-space) / (total + 1)
      let left-start = -side / 2 // Start coordinates at left side.
      let offset = (
        (even-spacing + line-stroke-thickness + label-padding) * i
          + label-min-size-list.slice(1, i).sum(default: 0pt)
          + even-spacing
          + line-stroke-thickness / 2
      )
      let value = left-start + offset
      if output { -value } else { value }
    }
  }

  let get-offset-simple(total, side, i, stroke, output: false) = {
    if total == 1 { return 0 }
    // -side / 2 + (i + 1) * side / 4
    let line-stroke-thickness = stroke.thickness
    let label-padding = label-sep.to-absolute()
    let need-space = (
      +line-stroke-thickness * total + label-padding * total
    )
    // Make sure each line + label are readable and don't overlap.
    let readable-space = label-padding * (total - 1)
    // CSS's space-evenly
    let even-spacing = (side - need-space) / (total + 1)
    let left-start = -side / 2 // Start coordinates at left side.
    let offset = (
      (even-spacing + line-stroke-thickness + label-padding) * i
        + even-spacing
        + line-stroke-thickness / 2
    )
    left-start + offset
  }

  let get-label-side(label-min-size-list, side, i) = {
    assert(label-min-size-list.len() != 0)
    let total = label-min-size-list.len()
    if total == 1 { return left }
    if will-fit(label-min-size-list, side) {
      ((left,) * total).at(i)
    } else {
      (right, ..(left,) * (total - 1)).at(i)
    }
  }

  context diagram({
    let block-info = blocks
      .pairs()
      .enumerate()
      .map(((i, (k, body))) => (
        k,
        (
          body: body,
          coords: (i, i),
          attached: (input: (), output: (), control: (), mechanism: ()),
        ),
      ))
      .to-dict()
    let block-coords = range(blocks.len()).enumerate()
    let data = block-info.pairs().map(((k, inf)) => (inf.coords, k, inf.body))
    for (coords, name, body) in data {
      node(coords, name: label(name), node-styling[#body])
    }

    let labeled-offsets = ()

    let input-info = input
      .pairs()
      .enumerate()
      .map(((y, (k, body))) => {
        let x = -4
        let occurrences = input-connections
          .fold((:), (acc, (k, ..)) => acc + ((k): acc.at(k, default: 0) + 1))
          .at(k, default: 0)
        let block-names = input-connections
          .filter(((kk, ..)) => kk == k)
          .map(((_, v, _)) => v)
        let coords = if occurrences == 0 {
          (x, y)
        } else if occurrences > 1 {
          // let blocks-ordered = blocks.keys().filter(x => x in block-names)
          let block-coords = blocks
            .keys()
            .enumerate()
            .filter(((_, name)) => name in block-names)
            .map(((i, _)) => i)
          // let avg = block-coords.sum() / occurrences
          // (x, avg)
          let first = block-coords.first()
          (x, first)
        } else {
          let block-name = block-names.last()
          let block-index = blocks.keys().position(x => x == block-name)
          (x, block-index)
        }
        (
          k,
          (
            body: body,
            size: input-sizes.get().at(k),
            coords: coords,
            occurrences: occurrences,
            index: y,
            blocks: block-names,
            shift: 0,
          ),
        )
      })
      .to-dict()

    let data = input-info.pairs().map(((k, inf)) => (inf.coords, k, inf.body))
    for (coords, name, body) in data {
      node(coords, name: label(name), width: 1pt, height: 1pt, stroke: none)
    }

    let output-info = output
      .pairs()
      .enumerate()
      .map(((y, (k, body))) => {
        let x = blocks.len() + 2
        let occurrences = output-connections
          .fold((:), (acc, (k, ..)) => acc + ((k): acc.at(k, default: 0) + 1))
          .at(k, default: 0)
        // if occurrences != 1 { return (-1, y) }
        let block-names = output-connections
          .filter(((kk, ..)) => kk == k)
          .map(((_, v, _)) => v)
        let coords = if occurrences == 0 {
          (x, y)
        } else if occurrences > 1 {
          // let blocks-ordered = blocks.keys().filter(x => x in block-names)
          let block-coords = blocks
            .keys()
            .enumerate()
            .filter(((_, name)) => name in block-names)
            .map(((i, _)) => i)
          // let avg = block-coords.sum() / occurrences
          // return (-1, avg)
          let first = block-coords.first()
          (x, first)
        } else {
          let block-name = output-connections
            .filter(((kk, ..)) => kk == k)
            .last()
            .at(1)
          let block-index = blocks.keys().position(x => x == block-name)
          (x, block-index)
        }
        (
          k,
          (
            body: body,
            size: output-sizes.get().at(k),
            coords: coords,
            occurrences: occurrences,
            index: y,
            blocks: block-names,
            shift: 0,
          ),
        )
      })
      .to-dict()

    let data = output-info.pairs().map(((k, inf)) => (inf.coords, k, inf.body))
    for (coords, name, body) in data {
      node(coords, name: label(name), width: 1pt, height: 1pt, stroke: none)
    }

    let control-info = control
      .pairs()
      .enumerate()
      .map(((x, (k, body))) => {
        // Define a way to get good figure-center + not-in-one-spot coordinates.
        // Each control must have its own level of splitting to be readable.
        let y = -1.5 - control.len()
        let occurrences = control-connections
          .fold((:), (acc, (k, ..)) => acc + ((k): acc.at(k, default: 0) + 1))
          .at(k, default: 0)
        // if occurrences != 1 { return (-1, y) }
        let block-names = control-connections
          .filter(((kk, ..)) => kk == k)
          .map(((_, v, _)) => v)
        let coords = (x + 1, y)
        // let coords = if occurrences == 0 {
        //   (x, y)
        // } else if occurrences > 1 {
        //   // let blocks-ordered = blocks.keys().filter(x => x in block-names)
        //   let block-coords = blocks
        //     .keys()
        //     .enumerate()
        //     .filter(((_, name)) => name in block-names)
        //     .map(((i, _)) => i)
        //   // let avg = block-coords.sum() / occurrences
        //   // return (-1, avg)
        //   let first = block-coords.first()
        //   (x, first)
        // } else {
        //   let block-name = control-connections
        //     .filter(((kk, _)) => kk == k)
        //     .last()
        //     .last()
        //   let block-index = blocks.keys().position(x => x == block-name)
        //   (x, block-index)
        // }
        (
          k,
          (
            body: body,
            size: control-sizes.get().at(k),
            coords: coords,
            occurrences: occurrences,
            index: x,
            blocks: block-names,
            shift: 0,
          ),
        )
      })
      .to-dict()

    let data = control-info.pairs().map(((k, v)) => (v.coords, k, v.body))
    for (coords, name, body) in data {
      node(coords, name: label(name), width: 1pt, height: 1pt, stroke: none)
    }

    let mechanism-info = mechanism
      .pairs()
      .enumerate()
      .map(((x, (k, body))) => {
        // Define a way to get good figure-center + not-in-one-spot coordinates.
        // Each mechanism must have its own level of splitting to be readable.
        let y = blocks.len() + mechanism.len()
        let occurrences = mechanism-connections
          .fold((:), (acc, (k, ..)) => acc + ((k): acc.at(k, default: 0) + 1))
          .at(k, default: 0)
        // if occurrences != 1 { return (-1, y) }
        let block-names = mechanism-connections
          .filter(((kk, ..)) => kk == k)
          .map(((_, v, _)) => v)
        let coords = (x + 1, y)
        // let coords = if occurrences == 0 {
        //   (x, y)
        // } else if occurrences > 1 {
        //   // let blocks-ordered = blocks.keys().filter(x => x in block-names)
        //   let block-coords = blocks
        //     .keys()
        //     .enumerate()
        //     .filter(((_, name)) => name in block-names)
        //     .map(((i, _)) => i)
        //   // let avg = block-coords.sum() / occurrences
        //   // return (-1, avg)
        //   let first = block-coords.first()
        //   (x, first)
        // } else {
        //   let block-name = mechanism-connections
        //     .filter(((kk, _)) => kk == k)
        //     .last()
        //     .last()
        //   let block-index = blocks.keys().position(x => x == block-name)
        //   (x, block-index)
        // }
        (
          k,
          (
            body: body,
            size: mechanism-sizes.get().at(k),
            coords: coords,
            occurrences: occurrences,
            index: x,
            blocks: block-names,
            shift: none,
          ),
        )
      })
      .to-dict()

    let data = mechanism-info.pairs().map(((k, v)) => (v.coords, k, v.body))
    for (coords, name, body) in data {
      node(coords, name: label(name), width: 1pt, height: 1pt, stroke: none)
    }

    let get-start-label-pos(
      left,
      right,
      width,
      offset: 0pt,
      opposite: false,
    ) = {
      let (x1, y1) = left
      let (x2, y2) = right
      assert(x1 != none)
      assert(x2 != none)
      assert(y1 != none)
      // assert(y2 != none)
      let (x1, x2) = (x1, x2).map(x => (x * (W + spacing.first())).pt())
      let (y1, y2) = (y1, y2).map(x => (x * (H + spacing.first())).pt())
      let (x2, y2) = (x2 - W.pt() / 2, y2 - H.pt() / 2)
      let distance = (
        calc.sqrt(calc.pow((x1 - x2), 2) + calc.pow((y1 - y2), 2)) * 1pt
      )
      let length = (width + offset).to-absolute()
      if opposite { length = distance - length }
      length / (distance)
    }

    // From input to block.
    for (from, to, overrides) in input-connections.rev() {
      let info = input-info.at(from)
      let occurrences = info.occurrences
      let all = input-info
        .pairs()
        .filter(((_, info)) => to in info.blocks)
        .map(((k, info)) => (k, info.size.height))
        .rev()
      assert(all != ())
      let i = all.position(((k, _)) => k == from)
      all = all.map(((_, size)) => size)
      let coords = (label(from),)
      let the-label = [#info.body]
      let all-overrides = input-connections
        .filter(((f, ..)) => f == from)
        .map(x => x.last())
      let any(field) = (overrides, ..all-overrides)
        .filter(x => field in x)
        .map(x => x.at(field))
        .first(default: none)
      assert(not overrides.detached, message: "Detached is not supported")
      _ = overrides.remove("detached")
      let label-pos = any("label-pos")
      if "label-pos" in overrides { _ = overrides.remove("label-pos") }
      let auto-shift = get-offset(all, H, i, input-stroke)
      let shift = any("shift")
      if shift != none {
        if type(shift) == function { shift = shift(auto-shift) }
        shift = if type(shift) != array { shift.to-absolute() } else {
          shift.map(x => x.to-absolute())
        }
      }
      if "shift" in overrides { _ = overrides.remove("shift") }
      let settings = (
        stroke: input-stroke,
        shift: override-or(shift, auto-shift),
        label-side: get-label-side(all, H, i),
        label-pos: override-or(label-pos, get-start-label-pos(
          info.coords,
          block-info.at(to).coords,
          info.size.width,
          offset: 2em,
        )),
      )
      if occurrences > 1 {
        settings += (label-pos: 20%)
        if to != info.blocks.first() {
          the-label = none
          coords += ("r", ((), "|-", to))
        }
      }
      if type(settings.shift) == array {
        block-info.at(to).attached.input.push(settings.shift.last())
      } else {
        block-info.at(to).attached.input.push(settings.shift)
      }
      coords.push(label(to))
      edge(..coords, ..settings + overrides, the-label)
    }

    // From block to output.
    for (to, from, overrides) in output-connections {
      let info = output-info.at(to)
      let occurrences = info.occurrences
      let all = output-info
        .pairs()
        // .filter(((_, info)) => info.blocks.first() == from)
        .filter(((_, info)) => from in info.blocks)
        .map(((k, info)) => (k, info.size.height))
      assert(all != ())
      let i = all.position(((k, _)) => k == to)
      all = all.map(((_, size)) => size)
      let coords = (label(from),)
      let the-label = [#info.body]
      // Gather all info for outputs that are placed on the same level as the
      // `from` block.
      let in-one-spot = output-info
        .pairs()
        .filter(((_, info)) => from in info.blocks)
        .to-dict()
      let shift = if in-one-spot.len() == 1 { 0pt } else {
        i = in-one-spot.pairs().position(((k, _)) => k == to)
        all = in-one-spot.values().map(info => info.size.height)
        -get-offset(all, H, i, output-stroke)
      }
      if in-one-spot.len() > 1 {
        for (key, info) in in-one-spot {
          output-info.at(key).shift = shift
        }
      }
      if occurrences > 1 and from != info.blocks.first() {
        coords += ((rel: (-1, 0), to: (from, "-|", to)), ((), "|-", to))
        // coords += ("r", ((), "|-", to))
        shift = -output-info.at(to).shift
        the-label = none
      }
      coords.push(label(to))
      let all-overrides = output-connections
        .filter(((to_, ..)) => to_ == to)
        .map(x => x.last())
      let any(field) = (overrides, ..all-overrides)
        .filter(x => field in x)
        .map(x => x.at(field))
        .first(default: none)
      assert(not overrides.detached, message: "Detached is not supported")
      _ = overrides.remove("detached")
      let label-pos = any("label-pos")
      if "label-pos" in overrides { _ = overrides.remove("label-pos") }
      let auto-shift = shift
      let shift = any("shift")
      if shift != none {
        if type(shift) == function { shift = shift(auto-shift) }
        shift = if type(shift) != array { shift.to-absolute() } else {
          shift.map(x => x.to-absolute())
        }
      }
      if "shift" in overrides { _ = overrides.remove("shift") }
      let settings = (
        stroke: output-stroke,
        shift: override-or(shift, auto-shift),
        label-side: get-label-side(all, H, i),
        label-pos: override-or(label-pos, get-start-label-pos(
          block-info.at(from).coords,
          info.coords,
          info.size.width,
          offset: 2em,
          opposite: true,
        )),
      )
      if type(settings.shift) == array {
        block-info.at(from).attached.output.push(settings.shift.first())
      } else {
        block-info.at(from).attached.output.push(settings.shift)
      }
      edge(..coords, ..settings + overrides, the-label)
    }

    // From control to block.
    for (from, to, overrides) in control-connections {
      let info = control-info.at(from)
      let occurrences = info.occurrences
      let all = control-info.pairs().filter(((_, info)) => to in info.blocks)
      assert(all != ())
      let i = all.position(((k, _)) => k == from)
      let coords = (label(from),)
      let the-label = block(width: info.size.width)[#info.body]
      // let the-label = [#info.body]
      let all-overrides = control-connections
        .filter(((f, ..)) => f == from)
        .map(x => x.last())
      let any(field) = (overrides, ..all-overrides)
        .filter(x => field in x)
        .map(x => x.at(field))
        .first(default: none)
      assert(not overrides.detached, message: "Detached is not supported")
      _ = overrides.remove("detached")
      let label-pos = any("label-pos")
      if "label-pos" in overrides { _ = overrides.remove("label-pos") }
      let auto-shift = get-offset-simple(all.len(), W, i, control-stroke)
      let shift = any("shift")
      if shift != none {
        if type(shift) == function { shift = shift(auto-shift) }
        shift = if type(shift) != array { shift.to-absolute() } else {
          shift.map(x => x.to-absolute())
        }
      }
      if "shift" in overrides { _ = overrides.remove("shift") }
      let settings = (
        stroke: control-stroke,
        shift: override-or(shift, auto-shift),
        label-side: left,
        label-pos: override-or(label-pos, get-start-label-pos(
          block-info.at(to).coords,
          info.coords,
          info.size.height,
          offset: 1.5em,
        )),
      )
      if occurrences > 1 {
        // settings += (label-pos: 10%)
        if to == info.blocks.first() {
          for (key, info) in control-info {
            control-info.at(key).shift = settings.shift
          }
        } else {
          the-label = none
        }
      }
      // Block is to the left.
      if block-info.at(to).coords.first() < info.coords.first() {
        coords += ((rel: (0, info.index + 1.5)), ((), "-|", to))
        // Shift is only inherited after it is initially set by first block.
        if control-info.at(from).shift != none {
          settings.shift = control-info.at(from).shift
        }
      }
      // Block is to the right.
      if info.coords.first() < block-info.at(to).coords.first() {
        coords += ((rel: (0, info.index + 1.5)), ((), "-|", to))
        if control-info.at(from).shift != none {
          settings.shift = control-info.at(from).shift
        }
      }
      // Block is right above.
      if block-info.at(to).coords.first() == info.coords.first() {
        if control-info.at(from).shift != none {
          settings.shift = control-info.at(from).shift
          if type(settings.shift) != array { settings.shift *= -1 } else {
            settings.shift = settings.shift.map(x => -1 * x)
          }
        }
      }
      coords.push(label(to))
      if type(settings.shift) == array {
        block-info.at(to).attached.control.push(settings.shift.last())
      } else {
        block-info.at(to).attached.control.push(settings.shift)
      }
      edge(..coords, ..settings + overrides, the-label)
    }

    // From mechanism to block.
    for (from, to, overrides) in mechanism-connections {
      let info = mechanism-info.at(from)
      let occurrences = info.occurrences
      let all = mechanism-info.pairs().filter(((_, info)) => to in info.blocks)
      assert(all != ())
      let i = all.position(((k, _)) => k == from)
      let coords = (label(from),)
      let the-label = [#info.body]
      // let the-label = block(width: info.size.width)[#info.body]
      let stroke = mechanism-stroke.at(info.index, default: edge-stroke)
      let all-overrides = control-connections
        .filter(((f, ..)) => f == from)
        .map(x => x.last())
      let any(field) = (overrides, ..all-overrides)
        .filter(x => field in x)
        .map(x => x.at(field))
        .first(default: none)
      assert(not overrides.detached, message: "Detached is not supported")
      _ = overrides.remove("detached")
      let label-pos = any("label-pos")
      if "label-pos" in overrides { _ = overrides.remove("label-pos") }
      let auto-shift = get-offset-simple(all.len(), W, i, stroke)
      let shift = any("shift")
      if shift != none {
        if type(shift) == function { shift = shift(auto-shift) }
        shift = if type(shift) != array { shift.to-absolute() } else {
          shift.map(x => x.to-absolute())
        }
      }
      if "shift" in overrides { _ = overrides.remove("shift") }
      let settings = (
        stroke: stroke,
        shift: override-or(shift, auto-shift),
        label-side: right,
        label-pos: override-or(label-pos, get-start-label-pos(
          info.coords,
          block-info.at(to).coords,
          info.size.height,
          offset: 5em,
        )),
      )
      if occurrences > 1 {
        if to == info.blocks.first() {
          for (key, info) in mechanism-info {
            mechanism-info.at(key).shift = settings.shift
          }
        } else {
          the-label = none
        }
      }
      // Block is to the left.
      if block-info.at(to).coords.first() < info.coords.first() {
        coords += ((rel: (0, -(info.index + 1))), ((), "-|", to))
        // Shift is only inherited after it is initially set by first block.
        if mechanism-info.at(from).shift != none {
          settings.shift = mechanism-info.at(from).shift
        }
      }
      // Block is to the right.
      if info.coords.first() < block-info.at(to).coords.first() {
        coords += ((rel: (0, -(info.index + 1))), ((), "-|", to))
        if mechanism-info.at(from).shift != none {
          settings.shift = mechanism-info.at(from).shift
        }
      }
      // Block is right above.
      if block-info.at(to).coords.first() == info.coords.first() {
        if mechanism-info.at(from).shift != none {
          settings.shift = mechanism-info.at(from).shift
          if type(settings.shift) != array { settings.shift *= -1 } else {
            settings.shift = settings.shift.map(x => -1 * x)
          }
        }
      }
      coords.push(label(to))
      if type(settings.shift) == array {
        block-info.at(to).attached.mechanism.push(settings.shift.last())
      } else {
        block-info.at(to).attached.mechanism.push(settings.shift)
      }
      edge(..coords, ..settings + overrides, the-label)
    }

    // Since same-offset is an issue, the easiest way to work around it is to
    // handle the between-block connections in specific order, i.e., in stages.
    // 1. Handle self/loop connections (put them on the corners)
    // 2. Handle adjacent same from-to-type connections, i.e., input type
    // 3. Handle the rest one-by-one
    // 3.1. Use same from/to offset if the label exists (compare content/str labels)
    //      This means the from/to offset must be preserved, but the other one can be adapted to free space.
    // 3.2. Use remaining biggest gaps between occupied offsets for the rest.

    // From block to block (self/loop).
    let self-connections = block-connections.filter(((from, to, ..)) => (
      from == to
    ))
    let block-info-copy = block-info
    for (
      index,
      (from, to, type, label, overrides),
    ) in self-connections.enumerate() {
      assert(type in (TYPE.INPUT, TYPE.CONTROL))

      let settings = (:)

      // Needed for correct spacing between connections.
      let same = self-connections
        .enumerate()
        .filter(x => x.last().at(2) == type)
      let i = same.position(x => x.first() == index)

      let side = if type == TYPE.INPUT { H } else { W }
      let attached-type = if type == TYPE.INPUT { "input" } else { "control" }

      let all-overrides = block-connections
        .filter(((.., label_, _)) => label_ == label)
        .map(x => x.last())
      let any(field) = all-overrides
        .filter(x => field in x)
        .map(x => x.at(field))
        .first(default: none)

      let occupied-to-offsets = block-info-copy
        .at(to)
        .attached
        .at(attached-type)
      let occupied-from-offsets = block-info-copy.at(from).attached.output
      let from-bounds = (
        min: -H / 2 + edge-stroke.thickness * 2,
        max: occupied-from-offsets.sorted().last(default: H / 2),
      )
      let to-bounds = (
        min: -side / 2 + edge-stroke.thickness * 2,
        max: -occupied-to-offsets
          .sorted()
          .map(x => x + edge-stroke.thickness * 2)
          .last(default: side / 2),
      )
      let from-rel-length = (from-bounds.max - from-bounds.min) / H
      let to-rel-length = (to-bounds.max - to-bounds.min) / side
      let min-rel-length = calc.min(from-rel-length, to-rel-length)
      // Make them proportionally equal.
      from-bounds.max = min-rel-length * H + from-bounds.min
      to-bounds.max = min-rel-length * side + to-bounds.min
      let rel-to-abs(rel, side, min) = min + side * rel
      // Evenly spaced.
      let rel-step = min-rel-length / (same.len() + 1)

      let auto-shift = (
        rel-to-abs(rel-step * (i + 1), H, from-bounds.min),
        rel-to-abs(rel-step * (i + 1), side, to-bounds.min),
      )
      let shift = any("shift")
      if shift != none {
        if std.type(shift) == function { shift = shift(auto-shift) }
        shift = if std.type(shift) != array { shift.to-absolute() } else {
          shift.map(x => x.to-absolute())
        }
      }
      if "shift" in overrides { _ = overrides.remove("shift") }
      settings.shift = override-or(shift, auto-shift)
      if std.type(settings.shift) != array {
        settings.shift = (settings.shift,) * 2
      }

      if type == TYPE.INPUT { settings.shift = settings.shift.map(x => -x) }
      let coords = ()
      coords.push(std.label(from))
      // Units are coordinates. 1 should always equal as length between blocks.
      // Which means 0.5 should be half of that distance.
      let rel-step = 0.5 / (same.len() + 1)
      let rel-pos = rel-step * (i + 1)
      coords += if type == TYPE.CONTROL {
        let first = coords.first()
        let a = (rel: (rel-to-abs(rel-pos, 0.5, 0.4), 0), to: first)
        let b = (rel: (0, rel-to-abs(rel-pos, -0.5, -0.5)), to: a)
        let c = (rel: (-rel-to-abs(rel-pos, 0.5, 0.4), 0), to: b)
        (a, b, c)
      } else {
        let first = coords.first()
        let a = (rel: (rel-to-abs(rel-pos, 0.2, 0.36), 0), to: first)
        let b = (rel: (0, rel-to-abs(rel-pos, 0.2, 0.5)), to: a)
        let c = (rel: (-rel-to-abs(rel-pos * 2, 0.2, 0.75), 0), to: b)
        let d = (rel: (0, -rel-to-abs(rel-pos, 0.2, 0.5)), to: c)
        (a, b, c, d)
      }
      coords.push(std.label(to))
      block-info.at(from).attached.output.push(settings.shift.first())
      block-info.at(to).attached.at(attached-type).push(settings.shift.last())
      labeled-offsets.push((label, settings.shift.first()))
      if label == none {
        edge(..coords, ..settings)
        continue
      }

      let min-width = block-sizes.get().find(x => x.first() == label).last()
      // label = block(width: min-width, stroke: 1pt, label)
      if overrides.min-width or all-overrides.any(x => x.min-width) {
        label = block(width: min-width, label)
      }

      if all-overrides.any(x => not x.detached) {
        if any("label-pos") != none { settings.label-pos = any("label-pos") }
        if any("label-side") != none { settings.label-side = any("label-side") }
        edge(..coords, ..settings, label)
        continue
      }
      edge(..coords, ..settings)

      let label-pos = if any("label-pos") != none {
        if std.type(any("label-pos")) != function { any("label-pos") } else {
          any("label-pos")(coords, settings.shift)
        }
      }
      let label-side = if any("label-side") != none { any("label-side") }
      let label-anchor = if any("label-anchor") != none { any("label-anchor") }

      let (coords, anchor) = if type == TYPE.CONTROL {
        (
          (
            (rel: (-2em, -settings.shift.first()), to: coords.at(1)),
            (rel: (0.15, -0.15)),
          ),
          "south-west",
        )
      } else {
        (
          (
            (rel: (-0.1, 0), to: coords.at(2)),
            (rel: (-0.1, 0.15)),
          ),
          "north-east",
        )
      }
      zigzag(
        ..override-or(label-pos, coords),
        label-anchor: override-or(label-anchor, anchor),
        label-side: override-or(label-side, auto),
        label,
      )
    }

    // From block to block (adjacent input type connections).
    let adjacent-connections = block-connections.filter((
      (from, to, type, ..),
    ) => {
      if type != TYPE.INPUT { return false }
      let from-index = block-info.keys().position(x => x == from)
      let to-index = block-info.keys().position(x => x == to)
      from-index - to-index == -1
    })
    let block-info-copy = block-info
    for (
      index,
      (from, to, type, label, overrides),
    ) in adjacent-connections.enumerate() {
      // Identical connections (but different labels).
      let from-to-type-match = ((k, v, t, ..)) => {
        k == from and v == to and t == type
      }
      let same = adjacent-connections.filter(from-to-type-match)
      let same-indexed = adjacent-connections
        .enumerate()
        .filter(x => from-to-type-match(x.last()))
      let same-count = same.len()
      let settings = (:)
      // if same-count > 1 { settings += (stroke: aqua) }

      let side = H
      let i = same-indexed.position(((i, ..)) => i == index)
      let occupied-from-offsets = block-info-copy.at(from).attached.output
      let occupied-to-offsets = block-info-copy.at(to).attached.input

      let all-overrides = block-connections
        .filter(((.., label_, _)) => label_ == label)
        .map(x => x.last())
      let any(field) = all-overrides
        .filter(x => field in x)
        .map(x => x.at(field))
        .first(default: none)

      // TODO: Handle self/loop connections?
      let points = (
        -side / 2 + edge-stroke.thickness * 2,
        ..occupied-from-offsets.sorted(),
        side / 2 - edge-stroke.thickness * 2,
      )
      let gaps = points
        .windows(2)
        .map(((a, b)) => (b - a, a, b))
        .sorted(key: x => x.first())
      let biggest-gap = gaps.last()
      let (_, a, b) = biggest-gap
      let from-bounds = (min: -a, max: -b)
      // Ideally, if there is a lot of unused space, it should move the
      // existing inputs for the block, so that all inputs are distributed
      // equally.
      // Maybe do a second iteration, after all edges are defined, and just
      // re-distribute offsets?
      let to-bounds = (
        min: -side / 2 + edge-stroke.thickness * 2,
        max: occupied-to-offsets
          .sorted()
          .map(x => x + edge-stroke.thickness * 2)
          .first(default: side / 2),
      )
      let from-rel-length = (from-bounds.max - from-bounds.min) / H
      let to-rel-length = (to-bounds.max - to-bounds.min) / side
      // Evenly spaced.
      let ratio = (i + 1) / (same.len() + 1)

      let auto-shift = (
        -(from-bounds.min + side * from-rel-length * ratio),
        to-bounds.min + side * to-rel-length * ratio,
      )
      let shift = any("shift")
      if shift != none {
        if std.type(shift) == function { shift = shift(auto-shift) }
        shift = if std.type(shift) != array { shift.to-absolute() } else {
          shift.map(x => x.to-absolute())
        }
      }
      if "shift" in overrides { _ = overrides.remove("shift") }
      settings.shift = override-or(shift, auto-shift)
      if std.type(settings.shift) != array {
        settings.shift = (settings.shift,) * 2
      }

      let coords = ()
      coords.push(std.label(from))
      // Units are coordinates. 1 should always equal as length between blocks.
      // Which means 0.5 should be half of that distance.
      let rel-step = 0.5 / (same.len() + 1)
      let rel-pos = rel-step * (same.len() - i - 1)
      let min = if same-count == 1 { 0.5 } else { 0.44 }
      let first = coords.first()
      let a = (rel: (min + 0.4 * rel-pos, 0), to: first)
      let b = (a, "|-", to)
      coords += (a, b)
      coords.push(std.label(to))
      block-info.at(from).attached.output.push(settings.shift.first())
      block-info.at(to).attached.input.push(settings.shift.last())
      labeled-offsets.push((label, settings.shift.first()))
      if label == none {
        edge(..coords, ..settings)
        continue
      }

      let min-width = block-sizes.get().find(x => x.first() == label).last()
      // label = block(width: min-width, stroke: 1pt, label)
      if overrides.min-width or all-overrides.any(x => x.min-width) {
        label = block(width: min-width, label)
      }

      if all-overrides.any(x => not x.detached) {
        if any("label-pos") != none { settings.label-pos = any("label-pos") }
        if any("label-side") != none { settings.label-side = any("label-side") }
        edge(..coords, ..settings, label)
        continue
      }
      edge(..coords, ..settings)

      let label-pos = if any("label-pos") != none {
        if std.type(any("label-pos")) != function { any("label-pos") } else {
          any("label-pos")(coords, settings.shift)
        }
      }
      let label-side = if any("label-side") != none { any("label-side") }
      let label-anchor = if any("label-anchor") != none { any("label-anchor") }

      zigzag(
        ..override-or(label-pos, (
          (rel: (0, -(0.95 - (1 / (same.len() + 1)) * (i))), to: coords.at(2)),
          (rel: (0.2, -0.3)),
        )),
        label-anchor: override-or(label-anchor, "south-west"),
        label-side: override-or(label-side, auto),
        label,
      )
    }

    // TODO: use labeled-offsets in adjacent-connections as well.

    /// Finds widest gap on the specified side with given used offsets, and
    /// returns the center of said gap.
    let find-free-offset(used-offsets, side) = {
      let offsets = (-side / 2, ..used-offsets, side / 2).sorted()
      offsets
        .windows(2)
        .map(((a, b)) => (b - a, (a + b) / 2))
        .sorted(key: x => x.first())
        .last()
        .last()
    }

    // From block to block (adjacent input type connections).
    let other-connections = block-connections.filter((
      (from, to, type, ..),
    ) => {
      if from == to { return false }
      if type != TYPE.INPUT { return true }
      let from-index = block-info.keys().position(x => x == from)
      let to-index = block-info.keys().position(x => x == to)
      from-index - to-index != -1
    })

    for (
      index,
      (from, to, type, label, overrides),
    ) in other-connections.enumerate() {
      // Identical connections (but different labels).
      let from-to-type-match = ((k, v, t, ..)) => {
        k == from and v == to and t == type
      }
      let same = other-connections.filter(from-to-type-match)
      let same-indexed = other-connections
        .enumerate()
        .filter(x => from-to-type-match(x.last()))
      let same-count = same.len()

      let from-index = block-info.keys().position(x => x == from)
      let to-index = block-info.keys().position(x => x == to)
      let direction = if from-index < to-index { ltr } else { rtl }

      let side = if type == TYPE.INPUT { H } else { W }
      let attached-type = if type == TYPE.INPUT { "input" } else { "control" }

      let settings = (:)
      // if same-count > 1 { settings += (stroke: aqua) }

      let i = same-indexed.position(((i, ..)) => i == index)
      let occupied-from-offsets = block-info-copy.at(from).attached.output
      let occupied-to-offsets = block-info-copy.at(to).attached.input
      // TODO: Handle self/loop connections?
      let points = (
        -side / 2 + edge-stroke.thickness * 2,
        ..occupied-from-offsets.sorted(),
        side / 2 - edge-stroke.thickness * 2,
      )
      let gaps = points
        .windows(2)
        .map(((a, b)) => (b - a, a, b))
        .sorted(key: x => x.first())
      let biggest-gap = gaps.last()
      let (_, a, b) = biggest-gap
      let from-bounds = (min: -a, max: -b)
      // Ideally, if there is a lot of unused space, it should move the
      // existing inputs for the block, so that all inputs are distributed
      // equally.
      // Maybe do a second iteration, after all edges are defined, and just
      // re-distribute offsets?
      let to-bounds = (
        min: -side / 2 + edge-stroke.thickness * 2,
        max: occupied-to-offsets
          .sorted()
          .map(x => x + edge-stroke.thickness * 2)
          .first(default: side / 2),
      )
      let from-rel-length = (from-bounds.max - from-bounds.min) / H
      let to-rel-length = (to-bounds.max - to-bounds.min) / side
      // Evenly spaced.
      let ratio = (i + 1) / (same.len() + 1)
      settings.shift = (
        -(from-bounds.min + side * from-rel-length * ratio),
        to-bounds.min + side * to-rel-length * ratio,
      )

      let all-overrides = block-connections
        .filter(((.., label_, _)) => label_ == label)
        .map(x => x.last())
      let any(field) = all-overrides
        .filter(x => field in x)
        .map(x => x.at(field))
        .first(default: none)


      let coords = ()
      coords.push(std.label(from))
      // Units are coordinates. 1 should always equal as length between blocks.
      // Which means 0.5 should be half of that distance.
      let rel-step = 0.5 / (same.len() + 1)
      let rel-pos = rel-step * (same.len() - i - 1)
      let min = if same-count == 1 { 0.5 } else { 0.44 }

      let found = labeled-offsets.find(((label_, offset)) => (
        label_ == label
      ))
      let from-offset = if found != none { found.last() } else {
        find-free-offset(block-info.at(from).attached.output, H)
      }
      let to-offset = find-free-offset(
        block-info.at(to).attached.at(attached-type),
        side,
      )
      let auto-shift = (from-offset, to-offset)
      let shift = any("shift")
      if shift != none {
        if std.type(shift) == function { shift = shift(auto-shift) }
        shift = if std.type(shift) != array { shift.to-absolute() } else {
          shift.map(x => x.to-absolute())
        }
      }
      if "shift" in overrides { _ = overrides.remove("shift") }
      settings.shift = override-or(shift, auto-shift)
      if std.type(settings.shift) != array {
        settings.shift = (settings.shift,) * 2
      }

      let first = coords.first()
      coords += if direction == ltr {
        if type == TYPE.INPUT {
          let a = (rel: (0.4, 0), to: first)
          let b = (a, "|-", to)
          (a, b)
        } else {
          let a = (first, "-|", to)
          (a,)
        }
      } else {
        if type == TYPE.INPUT {
          let a = (rel: (0.4, 0), to: first)
          let b = (rel: (0, 0.53), to: a)
          let c = (rel: (-0.5, 0), to: (b, "-|", to))
          let d = (rel: (-0.5, 0), to: to)
          (a, b, c, d)
        } else {
          let a = (rel: (0.6, 0), to: first)
          let b = (rel: (0, -0.9), to: (a, "|-", to))
          let c = (b, "-|", to)
          (a, b, c)
        }
      }

      coords.push(std.label(to))
      block-info.at(from).attached.output.push(settings.shift.first())
      block-info.at(to).attached.at(attached-type).push(settings.shift.last())
      labeled-offsets.push((label, settings.shift.first()))
      if label == none or found != none {
        edge(..coords, ..settings)
        continue
      }

      let min-width = block-sizes.get().find(x => x.first() == label).last()
      // label = block(width: min-width, stroke: 1pt, label)
      if overrides.min-width or all-overrides.any(x => x.min-width) {
        label = block(width: min-width, label)
      }

      if all-overrides.any(x => not x.detached) {
        if any("label-pos") != none { settings.label-pos = any("label-pos") }
        if any("label-side") != none { settings.label-side = any("label-side") }
        edge(..coords, ..settings, label)
        continue
      }
      edge(..coords, ..settings)

      let label-pos = if any("label-pos") != none {
        if std.type(any("label-pos")) != function { any("label-pos") } else {
          any("label-pos")(coords, settings.shift)
        }
      }
      let label-side = if any("label-side") != none { any("label-side") }
      let label-anchor = if any("label-anchor") != none { any("label-anchor") }

      let (coords, anchor) = if type == TYPE.INPUT {
        if direction == ltr {
          (
            (
              (rel: (2em, -settings.shift.last()), to: coords.at(2)),
              (rel: (-0.1, 0.15)),
            ),
            "north-east",
          )
        } else {
          (
            (
              (rel: (-0.1, 0), to: coords.at(2)),
              (rel: (-0.1, 0.15)),
            ),
            "north-east",
          )
        }
      } else {
        if direction == ltr {
          // let length = (side + spacing.last()) * (to-index - from-index)
          let length = (
            (side + spacing.last()) * (to-index - from-index)
              - side / 4
              - spacing.last() * 2
          )
          // panic(from, to)
          (
            (
              (rel: (-length, -settings.shift.first()), to: coords.at(1)),
              (rel: (0.3, -0.15)),
            ),
            "south-west",
          )
        } else {
          (
            (
              (rel: (-2em, 0pt), to: coords.at(2)),
              (rel: (0.1, -0.4)),
            ),
            "south-west",
          )
        }
      }
      zigzag(
        ..override-or(label-pos, coords),
        label-anchor: override-or(label-anchor, anchor),
        label-side: override-or(label-side, auto),
        label,
      )
    }
  })
}
// Looks like each block-info must also contain a state of attached connections.
// This way after all 4 type connections are done, the remaining one can attach
// on an empty/better shift, to make connections still readable.
// Algorithm to neatly shift input -> output block connections.
// The labels are probably all should be drawn with zig-zag, to make a readable
// default, which can be overridden to a more prettier version.
// When adding overrides, make sure that they will not update the state by
// separating edge drawing and main positioning/settings logic.
