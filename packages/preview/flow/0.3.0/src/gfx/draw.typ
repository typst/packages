// cetz.draw but with extra utilities which are not needed when not drawing on a canvas

#import "maybe-stub.typ": cetz
#import cetz.draw: *

#import "../palette.typ": *

// Only uses the x component of the given coordinate.
#let hori(coord) = (coord, "|-", ())
// Only uses the y component of the given coordinate.
#let vert(coord) = (coord, "-|", ())

// Convert from Typst alignment to cetz directions.
#let to-anchor(it) = {
  if it == top {
    "north"
  } else if it == bottom {
    "south"
  } else if it == left {
    "west"
  } else if it == right {
    "east"
  }
}

// Returns a point according to the given value
// on the edge of the given object.
// `object` needs to be a string, the name of a drawn element.
#let lerp-edge(object, edge, value) = {
  // decide what bounds to use
  let ys = if edge.y == none {
    (top, bottom)
  } else {
    (edge.y,) * 2
  }
  let xs = if edge.x == none {
    (left, right)
  } else {
    (edge.x,) * 2
  }

  let point = xs.zip(ys).map(
    ((x, y)) => object +
    "." + to-anchor(y) +
    "-" + to-anchor(x)
  )
  point.insert(1, value)
  point
}
#let over(object, value) = lerp-edge(object, top, value)
#let under(object, value) = lerp-edge(object, bottom, value)
#let right-to(object, value) = lerp-edge(object, right, value)
#let left-to(object, value) = lerp-edge(object, left, value)

// Instruction to the `trans` function that a certain tree part has to be handled differently.
// The `queue` is the tree part to be placed under the modifier,
// the `cfg` specifies additional arguments for the `trans` function.
#let _modifier(queue, cfg) = (queue: queue, cfg: cfg)
#let _is-modifier(part) = (
  type(part) == dictionary and
  "queue" in part and
  "cfg" in part
)

// Create a new branch. After all coordinates in this branch have been processed,
// return to the node before it.
// At the end of a branch, an arrow mark is always drawn.
#let br(arrow: true, ..args) = _modifier(args.pos(), (branch: true, arrow: arrow))

// Branches out to each given argument.
#let all(..args) = {
  let parts = args.pos()
  let br = br.with(..args.named())

  if parts.len() == 0 {
    panic("can't draw to all over nothing")
  } else if parts.len() == 1 {
    br(parts.at(0), ..args.named())
  } else {
    br(
      all(..parts.slice(0, -1), ..args.named()),
      parts.last(),
      ..args.named(),
    )
  }
}

// Label the edges created in this call.
// The label is:
//
// - Only drawn once, after all edges and states have been drawn.
// - Placed in the center of all states in this call.
#let tag(
  ..args,
  tag: none,
  offset: (0, 0),
) = _modifier(
  args.pos(),
  (
    tag: tag,
    offset: offset,
    content-args: args.named(),
  ),
)

// Style all edges inside this call.
// Use named arguments for doing so, just like any other cetz element.
// Styles can be stacked and will be merged.
// Note that they are merged shallowly:
// If there are multiple styles with the same key,
// the deeper one will override the entire value, and
// NOT be merged with the previous value.
//
// The function is suffixed with `d`
// to avoid shadowing the builtin Typst `style` function.
#let styled(..args) = _modifier(args.pos(), (styles: args.named()))

// shallowly replaces () with last
#let _make-concrete(coord, last) = if type(coord) == array {
  if coord.len() == 0 {
    last
  } else {
    coord.map(_make-concrete)
  }
} else if type(coord) == dictionary {
  for (key, p) in coord {
    coord.insert(key, _make-concrete(last))
  }
  if "rel" in coord and "to" not in coord {
    coord.to = last;
  }
  coord
} else {
  coord
}

// Creates an edge denoting transition away from a starting state,
// branching out arbitrarily.
// The syntax for branching is inspired by the IUPAC nomenclature of organic chemistry:
// https://en.wikipedia.org/wiki/IUPAC_nomenclature_of_organic_chemistry
//
// At least, one starting state and a target state are needed.
// Afterwards, any number of branches can follow, and the default one is automatically entered.
// A branch is a sequence, where each element can be a coordinate or another branch.
// Coordinates can be specified in place.
// Branches are specified via the `br` function.
//
// Essentially, you can think of branches like save and restore points.
// Anytime you type `br(`, the current position in the tree is stored on a stack.
// Continuing to type more coordinates or branches after do not modify this stored entry.
// Typing a closing `)` of a `br` call pops the last position from the stack and
// continues from there.
// This can nest arbitrarily often.
#let trans(from, ..args, default-mark: (symbol: ">")) = {
  // ...one day, when typst has proper types, this will be hopefully much cleaner
  if args.pos().len() == 0 {
    panic("need at least one target state to transition to")
  }

  // essentially an "inverse" depth first search
  // we already have the tree and the search we want to follow
  // we just need to repeat it along the plan

  // basically manual recursion. each array entry is a stack frame
  // each stack frame is a dictionary with fields:
  // - `queue` for the coords/branches to next run through
  // - `cfg` for modifier options (see above functions calling _modifier)
  // - (optional) `arrow` if to draw an arrowhead at the end of this frame
  let depth = ((queue: args.pos().rev(), cfg: (:)),)
  let last = from

  // optimization: instead of going through the whole depth
  // each edge to get the current style,
  // just combine it at each new `styled` modifier and push it onto here,
  // popping when the `styled` frame ends
  let styles-depth = ()

  // collecting them while drawing edges so we can draw them all on the edges
  // each tag is a dictionary with fields:
  // - `pos` for where to draw the tag
  // - `display` for what to show at `pos`
  let tags = ()

  while depth.len() != 0 {
    let frame = depth.last()
    let queue = frame.queue

    // has this frame has been fully processed?
    if queue.len() == 0 {
      let frame = depth.pop()

      // if this was the end of a section to be tagged, note where to draw it
      if "tag" in frame.cfg {
        tags.push((
          pos: (
            to: (frame.last, 50%, last),
            rel: frame.cfg.offset,
          ),
          display: frame.cfg.tag,
          content-args: frame.cfg.content-args,
        ))
      }

      // if there are styles that end here, remove them
      if "styles" in frame.cfg {
        let _ = styles-depth.pop()
      }

      // if we should reset due to branching, do so
      if frame.cfg.at("branch", default: false) {
        last = frame.last
      }

      continue
    }

    let part = queue.pop()
    depth.last().queue = queue

    let arrow = frame.cfg.at("arrow", default: true)
    let maybe-arrowhead = if (
      queue.len() == 0
      and arrow != false
    ) {
      // oh that means we want to draw an arrowhead
      // though if this is a modifier, that information needs to be propagated instead

      if (
        _is-modifier(part)
        and "arrow" not in part.cfg
      ) {
        part.cfg.arrow = arrow
      }

      if arrow == true {
        arrow = default-mark
      }
      (mark: (end: arrow))
    }

    if _is-modifier(part) {
      // advance in depth
      // can just make it a new frame

      // the queue is popped at the back to receive the next one
      // so it is reversed here so it's in the right order again
      part.queue = part.queue.rev()

      // some modifiers (e.g. branch, tag) need the last node,
      // so store that one, too
      part.last = last

      // if this is a style modifier, store the style
      if "styles" in part.cfg {
        let next-styles = (
          styles-depth.at(-1, default: (:))
          + part.cfg.styles
        )
        styles-depth.push(next-styles)
      }

      depth.push(part)

      continue
    }

    let current = part
    line(
      last,
      current,
      ..styles-depth.at(-1, default: (:)),
      ..maybe-arrowhead,
    )

    last = current
  }

  // draw all tags we collected
  // they're drawn afterwards so they're always visible over the edges
  for (pos, display, content-args) in tags {
    content(
      pos,
      box(
        fill: bg,
        inset: 0.25em,
        radius: 0.1em,
        display,
      ),
      ..content-args,
    )
  }
}
