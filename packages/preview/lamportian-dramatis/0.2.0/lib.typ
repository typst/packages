// lamportian-dramatis -- Lamport diagrams for replicated systems: one timeline per replica, local
// events as dots on that timeline, and arrows for the messages that carry events from one replica
// to another.  The axis the timelines run along is logical time, in the sense of Lamport clocks;
// `orientation` says which way it points, and the replicas stack across it.
//
// Pre-1.0: nothing here is a stable API until 1.0.0.  Argument names, defaults and the shape of
// what these helpers return are all still open, and may break between 0.x releases.
//
// Columns are *solved*, not authored.  You list each replica's local events in order and name the
// messages; the layout puts every event in the earliest column that keeps it after its predecessor
// on the same replica and after the send of every message it receives.  So a diagram stays correct
// while you insert events -- nothing needs re-padding -- and a receive that would land before its
// own send is a causal cycle, which fails compilation instead of drawing a backwards arrow.
//
// The `///` comments below are the reference for each function; README.md is the tutorial.

#import "@preview/cetz:0.5.2"

/// Lane colours, cycled over `replicas` in order.  Override per replica with
/// `(id: "Shore", color: red)`.
#let default-palette = (
  rgb("#1f6feb"),
  rgb("#a16207"),
  rgb("#ea580c"),
  rgb("#15803d"),
  rgb("#7c3aed"),
)

/// Which side of a timeline a label sits on.  `above` and `below` are `top` and `bottom` under names
/// that read better for a diagram of one horizontal line per replica, and they are those same values,
/// so either spelling works wherever a side is asked for.  `left` and `right` are re-exported for the
/// vertical orientations, so one import line covers every side a diagram may ask for.
#let above = top
#let below = bottom
#let left = left
#let right = right

/// Which way logical time runs.  `rightwards` and `leftwards` lay the timelines out horizontally and
/// stack the replicas top to bottom; `downwards` and `upwards` lay them out vertically and stack the
/// replicas left to right.  `horizontal` and `vertical` are the two that need no thinking about, and
/// are `rightwards` and `downwards` under a shorter name.  Plain strings work everywhere an
/// orientation is asked for, so `orientation: "vertical"` needs no import.
#let rightwards = "rightwards"
#let leftwards = "leftwards"
#let downwards = "downwards"
#let upwards = "upwards"
#let horizontal = rightwards
#let vertical = downwards

/// What each orientation means to the drawing.  `time` is the unit direction of increasing logical
/// time and `lane` that of increasing replica index, both in canvas coordinates; `sides` are the two
/// sides a label may sit on, the one towards lane 0 first, and `default-side` is whichever of those
/// two a label sits on when nothing else has a say.  `along` names the dimension of a label that runs
/// along the timelines, which is what a ratio displacement is taken against, and `name-anchor` puts a
/// replica's own name just off the start of its lane.
///
/// `col-gap` and `row-gap` are this orientation's default spacings, and they are not the same numbers
/// for all four.  What a gap has to make room for is text, and text runs across the page whichever way
/// the diagram does: the wider default belongs to whichever axis lies horizontally, so turning a
/// diagram on its side turns the two over with it.
///
/// `first-displacement` is how far a lane's opening label slides off its own dot, as a ratio of the
/// label's extent along the timeline.  A horizontal lane wants the nudge: its replica name sits
/// immediately to the label's left, and centring the label on the first dot reads as if the name and
/// the label belonged together.  A vertical lane does not: the name sits before the lane *in time*
/// and the label beside it, so the two were never in danger of reading as one -- and a fifth of a
/// line's height would be too small to see even if they were.
#let _orientations = (
  rightwards: (
    first-displacement: 20%,
    col-gap: 2.0,
    row-gap: 1.5,
    time: (1, 0),
    lane: (0, -1),
    sides: (top, bottom),
    default-side: top,
    along: "width",
    name-anchor: "east",
  ),
  leftwards: (
    first-displacement: 20%,
    col-gap: 2.0,
    row-gap: 1.5,
    time: (-1, 0),
    lane: (0, -1),
    sides: (top, bottom),
    default-side: top,
    along: "width",
    name-anchor: "west",
  ),
  downwards: (
    first-displacement: 0%,
    col-gap: 1.5,
    row-gap: 2.4,
    time: (0, -1),
    lane: (1, 0),
    sides: (left, right),
    default-side: right,
    along: "height",
    name-anchor: "south",
  ),
  upwards: (
    first-displacement: 0%,
    col-gap: 1.5,
    row-gap: 2.4,
    time: (0, 1),
    lane: (1, 0),
    sides: (left, right),
    default-side: right,
    along: "height",
    name-anchor: "north",
  ),
)

/// The canonical name of an orientation: the two shorthands resolve to the direction they stand for,
/// and anything else is a misspelling worth failing on.
#let _orientation(value) = {
  let name = if value == "horizontal" { rightwards } else if value == "vertical" { downwards } else {
    value
  }
  assert(
    type(name) == str and name in _orientations,
    message: "lamport-diagram: `orientation` must be one of `horizontal`, `vertical`, `rightwards`, "
      + "`leftwards`, `downwards` or `upwards`",
  )
  name
}

/// CeTZ's drawing commands, re-exported so that an `overlays` body can reach them without the caller
/// pinning a second dependency: `#import "@preview/lamportian-dramatis:0.2.0": draw` and then
/// `#import draw: *`.  It is the same module the diagram draws itself with, hence the same version.
#let draw = cetz.draw

/// The layers of a diagram, bottom to top, and the keys `overlays` takes.  A drawing given for a
/// layer is appended to that layer's own drawing pass -- after everything the diagram draws there,
/// before anything in any later pass.  `background` and `foreground` are not passes of the diagram:
/// they are bookends, one before the first and one after the last.
///
/// They are plain strings, so `overlays: (marks: ..)` needs no import; the bindings are for naming a
/// layer where a string would read worse, and `layers` for walking the stack.
#let background = "background"
#let arrows = "arrows"
#let backdrops = "backdrops"
#let timelines = "timelines"
#let marks = "marks"
#let labels = "labels"
#let foreground = "foreground"
#let layers = (background, arrows, backdrops, timelines, marks, labels, foreground)

/// Every side a label may be asked to sit on, in any orientation.  Which two of them are legal is the
/// diagram's business, since only there is the orientation known.
#let _sides = (top, bottom, left, right)

/// Reads the optional text size of a point's own label, which must be a length -- `size: 0.8em`
/// spares the caller a `#text(0.8em)[...]` wrapper around the label.
#let _point-size(args) = {
  let size = args.named().at("size", default: none)
  assert(
    size == none or type(size) == length,
    message: "lamport-diagram: `size` must be a length, as in `size: 0.8em`",
  )
  size
}

/// Whether a value can serve as a label displacement: `auto` to inherit one, `0` or `0%` to sit
/// centred, a ratio of the label's own width, or an exact length.
#let _is-displacement(value) = value == auto or value == 0 or type(value) in (length, ratio)

/// A local event on a replica's timeline.  Its body is the label -- content or a plain string -- and
/// `position` puts that label on one side of the timeline: `above` or `below` on a horizontal diagram,
/// `left` or `right` on a vertical one, with `size` setting its text size.  Both fall back on the
/// lane's own defaults -- see `replica` -- and then on the orientation's default side, at the
/// diagram's text size.  A side the orientation has no room for is dropped and ignored.
///
/// `displacement` slides the label along the timeline, out of being centred on its own dot: a ratio is
/// taken against the label's own extent along that timeline -- its width when the timelines are rows,
/// its height when they are columns -- so `+50%` leaves the label's trailing edge over the dot and
/// `-50%` its leading edge, while a length is an exact offset and `0` (or `0%`) centres it.  Left to
/// itself it is `auto`: the lane's default, and failing that centred -- except for a lane's opening
/// event, which is nudged forward in time by the orientation's `first-displacement` so it does not crowd
/// the replica name just before it.  The dot itself never moves -- it is the event's place in time,
/// which the layout solves for.
///
/// `width` wraps the label to a fixed width instead of letting it run along the timeline on one line,
/// which is what keeps a long label from crowding its neighbours.  It must be named: a bare length is
/// read as a `displacement`, since that is the far commoner one to reach for.  The box is centred on
/// the mark like any other label, and its contents are left to the caller -- wrap the body in
/// `align(center, ..)` if centred lines read better than the ragged right edge.
///
/// `halo` is how far the label's backdrop reaches past the label's own box -- the same idea as the
/// disc under a mark, and what lets a label sit over an arrow crossing its lane without the arrow
/// crowding the glyphs.  `auto` takes `_label-halo`, a length sets an exact reach, and `none` drops
/// the backdrop altogether, for a label that should let whatever is behind it show through.
///
/// Arguments are told apart by type, so they may come in any order and every one of them is
/// optional: `event(below, +50%)[Event1]` and `event(+50%, below, "Event1")` are the same event.
/// For the common case of a label and nothing else, bare content or a bare string in an `events`
/// array is shorthand, so `[Event1]`, `"Event1"` and `event[Event1]` are the same event too.
#let event(..args) = {
  for key in args.named().keys() {
    assert(
      key in ("position", "displacement", "body", "size", "width", "halo", "id"),
      message: "lamport-diagram: event has no `" + key + "` parameter",
    )
  }
  let width = args.named().at("width", default: none)
  assert(
    width == none or type(width) == length,
    message: "lamport-diagram: event `width` must be a length, as in `width: 2.5cm`",
  )
  let halo = args.named().at("halo", default: auto)
  assert(
    halo == auto or halo == none or type(halo) == length,
    message: "lamport-diagram: event `halo` must be `auto`, `none` or a length, as in `halo: 2mm`",
  )
  let id = args.named().at("id", default: none)
  assert(
    id == none or type(id) == str,
    message: "lamport-diagram: event `id` must be a string, as in `id: \"diverged\"`",
  )
  let position = args.named().at("position", default: auto)
  let displacement = args.named().at("displacement", default: auto)
  let body = args.named().at("body", default: none)
  let given = ()
  for arg in args.pos() {
    let slot = if type(arg) == alignment {
      "position"
    } else if type(arg) in (length, ratio) {
      "displacement"
    } else if type(arg) == int {
      // Zero is the one displacement that carries no unit and still says what it means; any other
      // bare number is a missing unit, not a label.
      assert(
        arg == 0,
        message: "lamport-diagram: an event displacement needs a unit -- `0`, `0%`, `+50%` or `2mm`",
      )
      "displacement"
    } else {
      "body"
    }
    assert(
      not (slot in given),
      message: "lamport-diagram: event was given two " + slot + " arguments",
    )
    given.push(slot)
    if slot == "position" {
      position = arg
    } else if slot == "displacement" {
      displacement = arg
    } else {
      body = arg
    }
  }
  // Which sides are legal depends on the orientation, which only the diagram knows, so the check
  // that narrows these four to two -- and warns about the ones it drops -- happens there.
  assert(
    position == auto or position in _sides,
    message: "lamport-diagram: event `position` must be `above`, `below`, `left` or `right`",
  )
  assert(
    _is-displacement(displacement),
    message: "lamport-diagram: event `displacement` must be a ratio, a length or `0`",
  )
  (
    kind: "event",
    id: id,
    body: body,
    at: position,
    size: _point-size(args),
    width: width,
    halo: halo,
    label-displacement: displacement,
  )
}

/// Reads the optional timeline label of a `send`/`recv`, which may be given either positionally
/// (including as a trailing content block) or as `body`, and rejects misspelled named arguments --
/// which a `..args` sink would otherwise swallow in silence.
#let _point-body(args, fn, allowed) = {
  let positional = args.pos()
  assert(
    positional.len() <= 1,
    message: "lamport-diagram: " + fn + " takes a message name and at most one label",
  )
  for key in args.named().keys() {
    assert(key in allowed, message: "lamport-diagram: " + fn + " has no `" + key + "` parameter")
  }
  if positional.len() == 1 { positional.at(0) } else { args.named().at("body", default: none) }
}

/// The point where the message `name` leaves this replica.  An optional label for the point goes
/// positionally -- `send("push")[pushed]` -- or as `body`, with `size` setting its text size; `label`
/// instead labels the arrow itself, and keeps its own styling.  `delay` is the minimum number of
/// columns the matching `recv` is pushed forward: `0` (the default) leaves the two in one column,
/// where the receive's own `displacement` is what leans the arrow forward, and `1` or more buys the
/// message a whole column of flight.
///
/// `displacement` nudges the point off the column it is solved into, exactly as it does on a `recv`,
/// except that it defaults to `none` -- a send sits on its own column unless you say otherwise, since
/// it is the receive that leans a message forward.  Reach for it to tilt an arrow away from whatever a
/// straight run across the lanes would otherwise cross, or to separate two sends the solver put in
/// one column.
#let send(name, ..args) = {
  let displacement = args.named().at("displacement", default: none)
  assert(
    displacement == none or type(displacement) in (length, ratio),
    message: "lamport-diagram: send `displacement` must be `none`, a length or a ratio",
  )
  (
    kind: "send",
    name: name,
    body: _point-body(args, "send", ("body", "size", "label", "at", "delay", "displacement")),
    size: _point-size(args),
    label: args.named().at("label", default: none),
    at: args.named().at("at", default: auto),
    delay: args.named().at("delay", default: 0),
    displacement: displacement,
  )
}

/// The point where the message `name` is applied on this replica.  An optional label for the point
/// goes positionally -- `recv("pull")[`DeleteFile1` is now duplicated]` -- or as `body`, with `size`
/// setting its text size.  Exactly one `send` and one `recv` must exist for each name.
///
/// `displacement` nudges the point off the column it is solved into, in either direction: `1cm` by
/// default, which is how far past its `send` in time the point lands whenever nothing on its own
/// replica pushes it further, and enough to lean the arrow forward.  `none` leaves it on its column,
/// drawing an arrow straight across the lanes when the receiving replica has nothing else competing
/// for that column.  A ratio
/// (`50%`) is taken against the column gap.  The nudge is a drawing offset the column solver knows
/// nothing about, so a negative one wide enough to put a receive visually behind its own send does not
/// trip the causal-cycle check.
#let recv(name, ..args) = {
  let displacement = args.named().at("displacement", default: 1cm)
  assert(
    displacement == none or type(displacement) in (length, ratio),
    message: "lamport-diagram: recv `displacement` must be `none`, a length or a ratio",
  )
  (
    kind: "recv",
    name: name,
    body: _point-body(args, "recv", ("body", "size", "at", "displacement")),
    size: _point-size(args),
    at: args.named().at("at", default: auto),
    displacement: displacement,
  )
}

/// One end of a two-way exchange named `name`.  In one round trip each side gives the other the
/// events it lacks, so both ends come out of the exchange holding the same events.  This is what the
/// product actually does -- a READ followed by as many SYNC requests as the two sides need -- and a
/// `send`/`recv` pair is the one-way message that the protocol allows but the clients never use on
/// its own.
///
/// Exactly two `sync` points must carry the same name, and they must sit on two different replicas.
/// The pair is drawn as one arrow with a head at each end, and the two ends share a column: neither
/// side can finish the exchange before the other one starts it.  Holding the same events is not the
/// same as holding the same state, so each end takes its own label.
///
/// An optional label for the point goes positionally -- `sync("push")[rolled back]` -- or as `body`,
/// with `size` setting its text size; `label` instead labels the arrow itself, and `at` forces the
/// side the point's label sits on.  `displacement` nudges this end off the shared column, which tilts
/// the arrow away from whatever a straight run across the lanes would otherwise cross; it is a
/// drawing offset
/// and says nothing about the order.
#let sync(name, ..args) = {
  let displacement = args.named().at("displacement", default: none)
  assert(
    displacement == none or type(displacement) in (length, ratio),
    message: "lamport-diagram: sync `displacement` must be `none`, a length or a ratio",
  )
  (
    kind: "sync",
    name: name,
    body: _point-body(args, "sync", ("body", "size", "at", "displacement", "label")),
    size: _point-size(args),
    label: args.named().at("label", default: none),
    at: args.named().at("at", default: auto),
    displacement: displacement,
  )
}

/// How much of its column each named `gap` size spans, as a fraction of the column gap.  Even `large`
/// stops short of the marks in the neighbouring columns.
#let _gap-spans = (small: 0.35, medium: 0.6, large: 0.85)

/// Elided time: a stretch of dotted timeline standing for events the diagram does not show, taking
/// one column of its own.  The size is how much of that column the dots span -- `"small"`,
/// `"medium"` (the default) or `"large"`, or a length or a ratio of the column gap for an exact span,
/// which past a full column runs into the neighbouring marks.  Usable bare or called, so `gap`,
/// `gap()` and `gap("medium")` are the same thing.
#let gap(..args) = {
  let positional = args.pos()
  assert(positional.len() <= 1, message: "lamport-diagram: gap takes at most one size")
  for key in args.named().keys() {
    assert(key == "size", message: "lamport-diagram: gap has no `" + key + "` parameter")
  }
  let size = if positional.len() == 1 {
    positional.at(0)
  } else {
    args.named().at("size", default: "medium")
  }
  assert(
    (type(size) == str and size in _gap-spans) or type(size) in (length, ratio),
    message: "lamport-diagram: gap size must be \"small\", \"medium\", \"large\", a length or a ratio",
  )
  (kind: "gap", body: none, at: auto, span: size)
}

/// Spacing to convey idle time passing: `n` columns of ordinary timeline, with nothing drawn on them.
/// The specific semantics are for the author to explain.  The solver counts them, so the next event on
/// this lane lands `n` columns later.  `gap` is the sibling that *shows* the stretch with dots, for
/// time the diagram elides; this one shows nothing, because nothing happened.
///
/// Usable bare or called, so `idle`, `idle()` and `idle(2)` are the same thing: two columns is enough
/// for the stretch to read as a pause rather than as the ordinary spacing between two events.
#let idle(..args) = {
  let positional = args.pos()
  assert(positional.len() <= 1, message: "lamport-diagram: idle takes at most one column count")
  for key in args.named().keys() {
    assert(key == "n", message: "lamport-diagram: idle has no `" + key + "` parameter")
  }
  let n = if positional.len() == 1 {
    positional.at(0)
  } else {
    args.named().at("n", default: 2)
  }
  assert(
    type(n) == int and n >= 1,
    message: "lamport-diagram: idle takes a whole number of columns, at least 1",
  )
  (kind: "idle", body: none, at: auto, advance: n)
}

#let _item(it) = {
  // A bare `gap` or `idle` reaches here as the function itself; calling it yields exactly what
  // `gap()` or `idle()` would.
  let d = if type(it) == function {
    it()
  } else if type(it) == dictionary and "kind" in it {
    it
  } else {
    (kind: "event", body: it)
  }
  (
    kind: d.kind,
    body: d.at("body", default: none),
    size: d.at("size", default: none),
    width: d.at("width", default: none),
    halo: d.at("halo", default: auto),
    label: d.at("label", default: none),
    name: d.at("name", default: none),
    // What an overlay addresses this point by.  A send, recv or sync is known by the message name
    // that pairs its two ends; an event has no such name, so it takes one of its own or none at all.
    id: d.at("id", default: d.at("name", default: none)),
    at: d.at("at", default: auto),
    // How many columns this item takes before the next one on its lane may start.  Everything takes
    // one; `idle` is what takes more.
    advance: d.at("advance", default: 1),
    delay: d.at("delay", default: 0),
    displacement: d.at("displacement", default: none),
    label-displacement: d.at("label-displacement", default: auto),
    span: d.at("span", default: "medium"),
  )
}

/// How far a label's backdrop reaches past the label's own box by default, in canvas centimetres.
/// It matches the reach of the disc under a mark, so a label and a dot break an arrow behind them by
/// the same amount and the two read as sitting on one plane.
#let _label-halo = 0.07

/// Settles each event against the defaults of the lane it sits on, and then the diagram's own: an
/// argument given on the event itself always wins, and only a lane's opening event takes
/// `first-displacement`.  Items that are not events pass through -- a message label's side is the
/// drawing's business, since it has an arrow to stay clear of, not a lane default's.
#let _resolve-defaults(row, lane, first-displacement) = {
  row.enumerate().map(((ii, it)) => {
    if it.kind != "event" {
      (..it, label-displacement: 0%)
    } else {
      let inherited = if ii == 0 { lane.first-displacement } else { lane.displacement }
      let fallback = if ii == 0 { first-displacement } else { 0% }
      (
        ..it,
        at: if it.at == auto { lane.position } else { it.at },
        size: if it.size == none { lane.size } else { it.size },
        label-displacement: if it.label-displacement != auto {
          it.label-displacement
        } else if inherited == auto {
          fallback
        } else {
          inherited
        },
      )
    }
  })
}

/// Drops every side that the orientation has no room for -- `above` on a vertical diagram, `left` on
/// a horizontal one -- back to `auto`, so it falls through to the orientation's own default.  A
/// misplacement is not worth failing on: a diagram that flips from horizontal to vertical would
/// otherwise stop compiling on the first lane that named a side, which is the one edit the
/// orientation exists to make easy.
///
/// It passes in silence, which is not the ideal.  The ideal is a compiler warning, and Typst gives
/// user code no way to raise one; the alternative -- printing the complaint into the document -- puts
/// it in front of the reader rather than the author, which is worse than saying nothing.
#let _sanitise-sides(lanes, rows, orientation) = {
  let legal = _orientations.at(orientation).sides
  let out-lanes = ()
  for lane in lanes {
    if lane.position != auto and not legal.contains(lane.position) {
      out-lanes.push((..lane, position: auto))
    } else {
      out-lanes.push(lane)
    }
  }
  let out-rows = ()
  for row in rows {
    out-rows.push(row.map(it => if it.at != auto and not legal.contains(it.at) {
      (..it, at: auto)
    } else {
      it
    }))
  }
  (lanes: out-lanes, rows: out-rows)
}

/// A replica lane, and the defaults the local events on it fall back on.  `name` is the id that the
/// `events` dictionary keys on; `label` is what the diagram prints for the lane and `color` is its
/// colour, either of which may also be given positionally -- colours are told apart by type.
///
/// The rest are defaults for this lane's events, each still overridable event by event: `position`
/// (`above`/`below` on a horizontal diagram, `left`/`right` on a vertical one, positional too) is the
/// side of the timeline their labels sit on, `size` their
/// text size, `displacement` how far they slide off their own dot, and `first-displacement` the same
/// for the lane's opening event, the one that would otherwise crowd the replica name.  None of these
/// reach a `send` or `recv` label: those keep their own arguments, and their side is chosen to stay
/// clear of the message arrow.
#let replica(name, ..defaults) = {
  assert(
    type(name) == str,
    message: "lamport-diagram: a replica's name is the id its `events` are keyed on",
  )
  for key in defaults.named().keys() {
    assert(
      key in ("label", "color", "position", "size", "displacement", "first-displacement"),
      message: "lamport-diagram: replica has no `" + key + "` parameter",
    )
  }
  let position = defaults.named().at("position", default: auto)
  let lane-color = defaults.named().at("color", default: auto)
  let lane-label = defaults.named().at("label", default: auto)
  for arg in defaults.pos() {
    if type(arg) == alignment {
      position = arg
    } else if type(arg) == color {
      lane-color = arg
    } else {
      panic(
        "lamport-diagram: a replica takes only a side or a colour positionally -- give `label`, "
          + "`size`, `displacement` and `first-displacement` by name",
      )
    }
  }
  let displacement = defaults.named().at("displacement", default: auto)
  let first-displacement = defaults.named().at("first-displacement", default: auto)
  assert(
    position == auto or position in _sides,
    message: "lamport-diagram: replica `position` must be `above`, `below`, `left` or `right`",
  )
  assert(
    _is-displacement(displacement) and _is-displacement(first-displacement),
    message: "lamport-diagram: replica displacements must be a ratio, a length or `0`",
  )
  (
    id: name,
    label: lane-label,
    color: lane-color,
    position: position,
    size: _point-size(defaults),
    displacement: displacement,
    first-displacement: first-displacement,
  )
}

#let _replica(spec, index) = {
  let d = if type(spec) == dictionary { spec } else { (id: spec) }
  let id = d.at("id")
  let label = d.at("label", default: auto)
  let lane-color = d.at("color", default: auto)
  (
    id: id,
    label: if label == auto { id } else { label },
    color: if lane-color == auto {
      default-palette.at(calc.rem(index, default-palette.len()))
    } else {
      lane-color
    },
    position: d.at("position", default: auto),
    size: d.at("size", default: none),
    displacement: d.at("displacement", default: auto),
    first-displacement: d.at("first-displacement", default: auto),
  )
}

/// Pairs the two ends of every `sync`, as `name => (ends: ((row, i), (row, i)), label)`.  An arrow
/// label may be given on either end; the first one given wins.
#let _exchanges(rows) = {
  let exchanges = (:)
  for (ri, row) in rows.enumerate() {
    for (ii, it) in row.enumerate() {
      if it.kind == "sync" {
        assert(type(it.name) == str, message: "lamport-diagram: every sync needs a name")
        let x = exchanges.at(it.name, default: (ends: (), label: none))
        exchanges.insert(
          it.name,
          (
            ends: x.ends + ((ri, ii),),
            label: if x.label == none { it.label } else { x.label },
          ),
        )
      }
    }
  }
  for (name, x) in exchanges {
    assert(
      x.ends.len() == 2,
      message: "lamport-diagram: sync '"
        + name
        + "' has "
        + str(x.ends.len())
        + " ends -- a two-way exchange needs exactly two, one on each replica",
    )
    assert(
      x.ends.at(0).at(0) != x.ends.at(1).at(0),
      message: "lamport-diagram: sync '" + name + "' has both ends on the same replica",
    )
  }
  exchanges
}

/// Pairs every `send` with its `recv`, as `name => (send: (row, i), recv: (row, i), delay: int)`.
#let _messages(rows) = {
  let msgs = (:)
  for (ri, row) in rows.enumerate() {
    for (ii, it) in row.enumerate() {
      if it.kind in ("send", "recv") {
        assert(
          type(it.name) == str,
          message: "lamport-diagram: every send/recv needs a message name",
        )
        let m = msgs.at(it.name, default: (send: none, recv: none, delay: 0, label: none))
        assert(
          m.at(it.kind) == none,
          message: "lamport-diagram: message '" + it.name + "' has more than one " + it.kind,
        )
        msgs.insert(
          it.name,
          if it.kind == "send" {
            (..m, send: (ri, ii), delay: it.delay, label: it.label)
          } else {
            (..m, recv: (ri, ii))
          },
        )
      }
    }
  }
  for (name, m) in msgs {
    assert(m.send != none, message: "lamport-diagram: message '" + name + "' is received, never sent")
    assert(m.recv != none, message: "lamport-diagram: message '" + name + "' is sent, never received")
  }
  msgs
}

/// Longest-path column assignment: the earliest column for each event that respects per-replica
/// order, message causality, and the shared column of every two-way exchange.  Relaxes the constraint
/// graph to a fixpoint, which is bounded by the event count unless the message edges close a cycle.
///
/// An exchange constrains its two ends in both directions at once, so the relaxation lifts the
/// earlier end to the later one and then stops.  A `send`/`recv` pair with a `delay` in both
/// directions is a real cycle, and that still fails.
#let _columns(rows, msgs, exchanges) = {
  let cols = rows.map(row => row.map(_ => 0))
  let bound = rows.map(row => row.len()).sum(default: 0) + 1
  let changed = true
  let round = 0
  while changed and round < bound {
    changed = false
    round += 1
    for (ri, row) in rows.enumerate() {
      for ii in range(1, row.len()) {
        let earliest = cols.at(ri).at(ii - 1) + row.at(ii - 1).advance
        if cols.at(ri).at(ii) < earliest {
          cols.at(ri).at(ii) = earliest
          changed = true
        }
      }
    }
    for (_, m) in msgs {
      let (sr, si) = m.send
      let (rr, rii) = m.recv
      if cols.at(rr).at(rii) < cols.at(sr).at(si) + m.delay {
        cols.at(rr).at(rii) = cols.at(sr).at(si) + m.delay
        changed = true
      }
    }
    for (_, x) in exchanges {
      let (ar, ai) = x.ends.at(0)
      let (br, bi) = x.ends.at(1)
      let shared = calc.max(cols.at(ar).at(ai), cols.at(br).at(bi))
      if cols.at(ar).at(ai) < shared {
        cols.at(ar).at(ai) = shared
        changed = true
      }
      if cols.at(br).at(bi) < shared {
        cols.at(br).at(bi) = shared
        changed = true
      }
    }
  }
  assert(
    not changed,
    message: "lamport-diagram: messages form a causal cycle -- some receive precedes its own send",
  )
  cols
}

/// The ids an overlay may address a lane's points by, checked for collisions.  A `send`, `recv` or
/// `sync` is known by the message name that pairs its ends; an `event` by the `id` it was given, and
/// most events are given none.  Two points on one lane sharing an id would make `mark("A", "x")`
/// answer with whichever came first, silently, so it fails instead.
#let _check-ids(lanes, rows) = {
  for (ri, row) in rows.enumerate() {
    let seen = (:)
    for it in row {
      if it.id != none {
        assert(
          not (it.id in seen),
          message: "lamport-diagram: replica '"
            + lanes.at(ri).id
            + "' has two points called '"
            + it.id
            + "' -- an overlay could not tell them apart",
        )
        seen.insert(it.id, true)
      }
    }
  }
}

/// Whatever `overlays` was given, as a dictionary from layer to drawing.  A body or a function on its
/// own means the `foreground`, that being what a caller who has not thought about depth wants.
#let _overlays(overlays) = {
  if overlays == none {
    (:)
  } else if type(overlays) == dictionary {
    for key in overlays.keys() {
      assert(
        key in layers,
        message: "lamport-diagram: '" + key + "' is not a layer -- " + layers.join(", "),
      )
    }
    overlays
  } else {
    (foreground: overlays)
  }
}

/// A Lamport diagram of `replicas` exchanging `events`.
///
/// `replicas` fixes the lane order -- top to bottom in a horizontal diagram, left to right in a
/// vertical one.  Each entry is an id string, a `replica` -- which also carries that lane's event
/// defaults -- or a bare dictionary of the same fields.  `events` maps each replica id to that
/// replica's local history in order: bare content or a bare string for a local event, or `event`,
/// `send`, `recv` and `gap`.
///
/// `orientation` says which way logical time runs: `horizontal` (`rightwards`) or `leftwards` lay the
/// timelines out as rows and stack the replicas downwards, so a label sits `above` or `below` its
/// lane and `above` by default; `vertical` (`downwards`) or `upwards` lay them out as columns and
/// stack the replicas rightwards, so a label sits `left` or `right` of its lane and `right` by
/// default.  A side the orientation has no room for is dropped back to that default and otherwise
/// ignored.
///
/// With a `caption` the result is a `figure`; without one it is the bare drawing.  `col-gap` is the
/// spacing between two columns of logical time and `row-gap` that between two lanes, both in canvas
/// centimetres, and they are the knobs for a diagram that reads too cramped or too sparse.
#let lamport-diagram(
  caption: none,
  replicas: (),
  events: (:),
  orientation: horizontal,
  overlays: none,
  col-gap: none,
  row-gap: none,
  text-size: 0.62em,
  dot: 0.095,
  message-stroke: 0.9pt + luma(110),
) = {
  let orientation = _orientation(orientation)
  let axes = _orientations.at(orientation)
  // Left to itself, a gap takes the value that suits the way this diagram runs; see `_orientations`.
  for (name, value) in (("col-gap", col-gap), ("row-gap", row-gap)) {
    assert(
      value == none or type(value) in (int, float),
      message: "lamport-diagram: `" + name + "` is a number of canvas centimetres, or `none` for the "
        + "one that suits the orientation",
    )
  }
  let col-gap = if col-gap == none { axes.col-gap } else { col-gap }
  let row-gap = if row-gap == none { axes.row-gap } else { row-gap }
  let (near-side, far-side) = axes.sides
  let lanes = replicas.enumerate().map(((i, spec)) => _replica(spec, i))
  for lane in lanes {
    assert(
      lane.id in events,
      message: "lamport-diagram: replica '" + lane.id + "' has no entry in `events`",
    )
  }
  for id in events.keys() {
    assert(
      lanes.any(lane => lane.id == id),
      message: "lamport-diagram: `events` mentions '" + id + "', which is not in `replicas`",
    )
  }

  // Sides are narrowed to the two this orientation has room for *before* the lane defaults settle,
  // so a dropped side falls through the same way an unstated one does.
  let checked = _sanitise-sides(lanes, lanes.map(lane => events.at(lane.id).map(_item)), orientation)
  let lanes = checked.lanes
  let rows = checked.rows.enumerate().map(((ri, row)) => _resolve-defaults(row, lanes.at(ri), axes.first-displacement))
  let msgs = _messages(rows)
  let exchanges = _exchanges(rows)
  for name in exchanges.keys() {
    assert(
      not (name in msgs),
      message: "lamport-diagram: '" + name + "' names both a sync and a send/recv message",
    )
  }
  _check-ids(lanes, rows)
  let given-layers = _overlays(overlays)
  let cols = _columns(rows, msgs, exchanges)
  // An item that takes several columns counts every one of them, so a trailing `idle` still
  // stretches the drawing.
  let ncols = cols
    .enumerate()
    .map(((ri, row)) => (
      row.enumerate().fold(0, (a, (ii, c)) => calc.max(a, c + rows.at(ri).at(ii).advance))
    ))
    .fold(1, calc.max)

  let send-dot = dot * 0.7
  // The two axes of the drawing, both in canvas centimetres: `t` runs along the timelines and `r`
  // across them.  Everything below is written in those terms and only `point` knows which way round
  // they are on the page, so the four orientations share one body of drawing code.
  let t-of = c => c * col-gap
  let point = (t, r) => (
    t * axes.time.at(0) + r * row-gap * axes.lane.at(0),
    t * axes.time.at(1) + r * row-gap * axes.lane.at(1),
  )
  let lane-start = -0.18

  // A label sits a fixed step off its lane, on whichever of the two sides it was given; both the step
  // and the anchor are in page terms, since a side is.
  let side-step = 0.3
  let side-offset = side => if side == top {
    (0, side-step)
  } else if side == bottom {
    (0, -side-step)
  } else if side == left {
    (-side-step, 0)
  } else {
    (side-step, 0)
  }
  let side-anchor = side => if side == top {
    "south"
  } else if side == bottom {
    "north"
  } else if side == left {
    "east"
  } else {
    "west"
  }

  // Label sides for send/recv points default to the side the arrow does *not* occupy, so an arrow
  // running straight across the lanes never runs through its own endpoint labels.  `near-side` is the
  // one towards the first replica and `far-side` the one away from it -- `above`/`below` on a
  // horizontal diagram, `left`/`right` on a vertical one.  A point with no arrow to dodge falls back
  // on the orientation's own default side instead.
  let side-of = (it, ri) => {
    // The lane this item's arrow runs towards, if it has one.
    let other = if it.kind == "send" {
      msgs.at(it.name).recv.at(0)
    } else if it.kind == "recv" {
      msgs.at(it.name).send.at(0)
    } else if it.kind == "sync" {
      exchanges.at(it.name).ends.filter(((r, i)) => r != ri).at(0).at(0)
    } else {
      none
    }
    if it.at != auto {
      it.at
    } else if other == none {
      axes.default-side
    } else if other > ri {
      near-side
    } else {
      far-side
    }
  }

  // Replica names get a strip of their own, before the start of every lane and clear of every event
  // label.  Without this a first-column label overhangs the start of its timeline and reads as
  // belonging to the replica name rather than to its own dot, even though the two never touch.  Needs
  // the laid-out size of each label, hence `context`; canvas units are centimetres, fixed by
  // `length: 1cm` below.
  let drawing = context {
    // A point's own text size, and any displacement or gap span given as a length, resolve here
    // against the diagram's text size -- `0.8em` means 0.8 of *this* diagram's em, not the caller's.
    // A `width` boxes the label so it wraps instead of running along the timeline.  The box is what
    // `measure` then reports, so a ratio displacement is taken against the boxed width, not the
    // width the label would have had on one line.
    let label-of = it => {
      let sized = if it.size == none { it.body } else { text(size: it.size, it.body) }
      if it.width == none { sized } else { box(width: it.width, sized) }
    }
    let span-of = it => if type(it.span) == str {
      _gap-spans.at(it.span) * col-gap
    } else if type(it.span) == ratio {
      it.span / 100% * col-gap
    } else {
      it.span.to-absolute() / 1cm
    }
    // Whole columns come from the solver, which has no way to express the sub-column lean of a
    // message arrow, so a receive's displacement rides on top of its column as a drawing offset.
    let offset-of = it => if type(it.displacement) == length {
      it.displacement.to-absolute() / 1cm
    } else if type(it.displacement) == ratio {
      it.displacement / 100% * col-gap
    } else {
      0.0
    }
    let t-at = (ri, ii) => t-of(cols.at(ri).at(ii)) + offset-of(rows.at(ri).at(ii))
    let at = (ri, ii) => point(t-at(ri, ii), ri)
    // How much of a label runs along its timeline: its width when the timelines are rows, its height
    // when they are columns.  This is what a ratio displacement slides the label by, and what the
    // replica names have to stay clear of.
    let extent-of = it => measure(label-of(it)).at(axes.along) / 1cm
    // A label is centred on its mark until displaced.  A ratio slides it by that much of its own
    // extent along the timeline, which is what makes `+50%` line its trailing edge up with the mark it
    // belongs to.
    let label-offset-of = it => if type(it.label-displacement) == ratio {
      it.label-displacement / 100% * extent-of(it)
    } else if type(it.label-displacement) == length {
      it.label-displacement.to-absolute() / 1cm
    } else {
      0.0
    }
    // How far this label's backdrop reaches past its own box, or `none` for no backdrop at all.  A
    // length given here resolves against the diagram's text size, like every other one.
    let label-halo-of = it => if it.halo == none {
      none
    } else if it.halo == auto {
      _label-halo
    } else {
      it.halo.to-absolute() / 1cm
    }

    // Both reaches are in time, not on the page: how far back the earliest label runs and how far
    // forward the last mark does.
    let back-reach = lane-start
    let fore-reach = t-of(ncols - 1)
    for (ri, row) in rows.enumerate() {
      for (ii, it) in row.enumerate() {
        let t = t-at(ri, ii)
        fore-reach = calc.max(fore-reach, t)
        if it.body != none {
          back-reach = calc.min(back-reach, t + label-offset-of(it) - extent-of(it) / 2)
        }
      }
    }
    let name-t = back-reach - 0.3
    let lane-end = fore-reach + col-gap * 0.55

    // What a drawing given for a layer is handed.  It answers in the diagram's own axes -- times
    // along the lanes, lanes across them -- wherever there is a choice, so that a drawing written
    // against it survives a change of orientation; `mark` and `point` are the two that come back as
    // page coordinates, those being what CeTZ draws with.
    let lane-of = value => if type(value) == str {
      let i = lanes.position(l => l.id == value)
      assert(
        i != none,
        message: "lamport-diagram: overlays name replica '" + value + "', which is not in `replicas`",
      )
      i
    } else {
      assert(
        type(value) in (int, float),
        message: "lamport-diagram: a lane is a replica id or a number of lanes from the first",
      )
      value
    }
    // An id names a point for as long as the diagram keeps it; an index is 1-based over everything
    // the lane holds, `gap` and `idle` included, and counts from the end when negative.
    let index-of = (replica, key) => {
      let ri = lane-of(replica)
      assert(
        type(ri) == int,
        message: "lamport-diagram: a point belongs to a replica, so name one rather than a lane",
      )
      let row = rows.at(ri)
      let ii = if type(key) == str {
        let found = row.position(it => it.id == key)
        assert(
          found != none,
          message: "lamport-diagram: replica '"
            + lanes.at(ri).id
            + "' has no point called '"
            + key
            + "' -- an event takes one with `id:`, and a send, recv or sync is known by its name",
        )
        found
      } else if type(key) == int {
        assert(key != 0, message: "lamport-diagram: a point's index counts from 1, or -1 from the end")
        let n = row.len()
        let idx = if key > 0 { key - 1 } else { n + key }
        assert(
          idx >= 0 and idx < n,
          message: "lamport-diagram: replica '"
            + lanes.at(ri).id
            + "' holds "
            + str(n)
            + " points, so "
            + str(key)
            + " names none of them",
        )
        idx
      } else {
        panic("lamport-diagram: a point is named by an id or by an index")
      }
      (ri, ii)
    }
    // The radius of the mark an item draws, and `none` for the items that draw none.  The backdrop
    // and the mark itself both need it, and they have to agree or the ring goes lopsided.
    let mark-radius = it => if it.kind == "send" {
      send-dot
    } else if it.kind in ("recv", "sync", "event") {
      dot
    } else {
      none
    }

    // Everything it takes to draw one mark, as arguments ready to spread into `circle`.  Hollow says
    // the replica touches the network here and solid says a purely local step, and a send is drawn
    // smaller than the receive it feeds so the two ends of a message stay tellable apart on their own.
    //
    // The diagram draws its marks from this and so does `mark-args`, which is the point of its being
    // one function: an overlay restating a mark cannot fall out of step with the mark it restates.
    let mark-args-of = (ri, ii) => {
      let it = rows.at(ri).at(ii)
      let radius = mark-radius(it)
      if radius == none {
        none
      } else if it.kind == "send" {
        arguments(at(ri, ii), radius: radius, fill: white, stroke: lanes.at(ri).color + 1pt)
      } else if it.kind in ("recv", "sync") {
        arguments(at(ri, ii), radius: radius, fill: white, stroke: lanes.at(ri).color + 1.1pt)
      } else {
        arguments(at(ri, ii), radius: radius, fill: lanes.at(ri).color, stroke: none)
      }
    }

    let locator = (
      mark: (replica, key) => {
        let (ri, ii) = index-of(replica, key)
        at(ri, ii)
      },
      column: (replica, key) => {
        let (ri, ii) = index-of(replica, key)
        cols.at(ri).at(ii)
      },
      point: (time, lane) => point(t-of(time), lane-of(lane)),
      mark-args: (replica, key) => {
        let (ri, ii) = index-of(replica, key)
        mark-args-of(ri, ii)
      },
      color-of: replica => {
        let ri = lane-of(replica)
        assert(
          type(ri) == int and ri >= 0 and ri < lanes.len(),
          message: "lamport-diagram: a colour belongs to a replica, so name one rather than a lane "
            + "between two of them",
        )
        lanes.at(ri).color
      },
      span: (lane-start / col-gap, lane-end / col-gap),
      replicas: lanes.map(l => l.id),
      ncols: ncols,
      orientation: orientation,
      col-gap: col-gap,
      row-gap: row-gap,
      dot: dot,
    )
    // A layer's drawing, ready to splice into the pass it belongs to.
    let layer-of = name => {
      let given = given-layers.at(name, default: none)
      if given == none {
        ()
      } else if type(given) == function {
        given(locator)
      } else {
        given
      }
    }

    cetz.canvas(length: 1cm, {
      import cetz.draw: *

      // Beneath every pass the diagram draws for itself.
      layer-of(background)

      // Arrows are laid down first, so every timeline, mark and label is drawn over them.  An arrow
      // that crosses a lane it has no endpoint on then reads as passing behind that lane's own marks,
      // instead of striking through them.
      for (_, m) in msgs {
        let (sr, si) = m.send
        let (rr, rii) = m.recv
        let (sx, sy) = at(sr, si)
        let (rx, ry) = at(rr, rii)
        let (dx, dy) = (rx - sx, ry - sy)
        let len = calc.sqrt(dx * dx + dy * dy)
        // Clearance is per-endpoint: the smaller send mark would otherwise be left orbited by a gap.
        let leave = send-dot + 0.05
        let land = dot + 0.07
        let from = (sx + dx / len * leave, sy + dy / len * leave)
        let to = (rx - dx / len * land, ry - dy / len * land)
        line(
          from,
          to,
          stroke: message-stroke,
          mark: (end: "stealth", fill: message-stroke.paint, scale: 0.85),
        )
        if m.label != none {
          // Offset perpendicular to travel so the label clears the shaft it belongs to.
          let mid = ((from.at(0) + to.at(0)) / 2, (from.at(1) + to.at(1)) / 2)
          content(
            (mid.at(0) - dy / len * 0.26, mid.at(1) + dx / len * 0.26),
            frame: "rect",
            fill: white,
            stroke: none,
            padding: 0.03,
            text(fill: message-stroke.paint, m.label),
          )
        }
      }

      // A two-way exchange is one shaft with a head at each end: both replicas give and take in the
      // same round trip, so neither end of it is the sender.  Both ends carry the same mark, hence one
      // clearance for the two of them.
      for (_, x) in exchanges {
        let ((ar, ai), (br, bi)) = x.ends
        let (ax, ay) = at(ar, ai)
        let (bx, by) = at(br, bi)
        let (dx, dy) = (bx - ax, by - ay)
        let len = calc.sqrt(dx * dx + dy * dy)
        let clear = dot + 0.07
        let from = (ax + dx / len * clear, ay + dy / len * clear)
        let to = (bx - dx / len * clear, by - dy / len * clear)
        line(
          from,
          to,
          stroke: message-stroke,
          mark: (start: "stealth", end: "stealth", fill: message-stroke.paint, scale: 0.85),
        )
        if x.label != none {
          let mid = ((from.at(0) + to.at(0)) / 2, (from.at(1) + to.at(1)) / 2)
          content(
            (mid.at(0) - dy / len * 0.26, mid.at(1) + dx / len * 0.26),
            frame: "rect",
            fill: white,
            stroke: none,
            padding: 0.03,
            text(fill: message-stroke.paint, x.label),
          )
        }
      }
      layer-of(arrows)

      // The timeline of a lane, as the runs the line is drawn in: each `gap` column interrupts the
      // solid line with a dotted span of its own.  The backdrop and the line itself walk these same
      // runs, which is what keeps the two from drifting apart.
      let runs-of = ri => {
        let runs = ()
        let cursor = lane-start
        for (ii, it) in rows.at(ri).enumerate() {
          if it.kind == "gap" {
            let gt = t-at(ri, ii)
            let half = span-of(it) / 2
            runs.push((cursor, gt - half, false))
            runs.push((gt - half, gt + half, true))
            cursor = gt + half
          }
        }
        runs.push((cursor, lane-end, false))
        runs
      }

      // A lane occupies a strip, not just a line, and the whole strip has to erase what runs behind
      // it: an arrow crossing a lane it has no endpoint on must read as passing *under* that lane,
      // marks included.  A dot is wider than the line's own halo, so without a disc of its own it
      // would poke out of the backdrop and the arrow would appear to run through it.  The reach past
      // each mark is the clearance an arrow landing on one already leaves, so a passing arrow is
      // erased over exactly the annulus a landing arrow stops short of.
      //
      // The halo stays slightly transparent, so the erasure reads as depth rather than as a hard gap.
      // Where a disc overlaps the line's halo the two compound and erase a little harder, which is
      // right: a mark should read as more solidly in front than the line it sits on.
      let halo-paint = white.transparentize(12%)
      let halo = (paint: halo-paint, thickness: 5pt, cap: "round")
      let halo-reach = 0.07

      // Layer 1: every lane's backdrop, over the arrows and under everything else.  It is laid for
      // all lanes before any lane's line, so no lane's backdrop can eat a neighbour's timeline.  It
      // is solid even under an elided stretch: white on white shows nothing, and the dots drawn over
      // it still say the stretch is elided.
      for (ri, _) in lanes.enumerate() {
        for (from, to, _) in runs-of(ri) {
          line(point(from, ri), point(to, ri), stroke: halo)
        }
        for (ii, it) in rows.at(ri).enumerate() {
          let r = mark-radius(it)
          if r != none {
            circle(at(ri, ii), radius: r + halo-reach, fill: halo-paint, stroke: none)
          }
        }
      }
      layer-of(backdrops)

      // The timelines and the replica names.  Every lane's line is laid before any mark, so a lower
      // lane can no longer paint over an upper lane's label where the two overlap.
      for (ri, lane) in lanes.enumerate() {
        let solid = lane.color + 1.1pt
        let elided = (paint: lane.color, thickness: 1.1pt, dash: "dotted")

        // The timeline is drawn as solid runs interrupted by the dotted span of each `gap` column,
        // rather than as one line with markers on top, so an elided stretch reads as elided.  The
        // last run is the one that carries the arrowhead.
        let runs = runs-of(ri)
        for (ii, (from, to, is-elided)) in runs.enumerate() {
          line(
            point(from, ri),
            point(to, ri),
            stroke: if is-elided { elided } else { solid },
            mark: if ii == runs.len() - 1 {
              (end: "stealth", fill: lane.color, scale: 0.9)
            },
          )
        }

        content(
          point(name-t, ri),
          anchor: axes.name-anchor,
          text(fill: lane.color, weight: "medium", lane.label),
        )
      }
      layer-of(timelines)

      // The marks, each drawn from the spec `mark-args` hands to an overlay.
      for (ri, _) in lanes.enumerate() {
        for (ii, _) in rows.at(ri).enumerate() {
          let spec = mark-args-of(ri, ii)
          if spec != none {
            circle(..spec)
          }
        }
      }
      layer-of(marks)

      // The labels, last of the diagram's own passes.
      for (ri, lane) in lanes.enumerate() {
        for (ii, it) in rows.at(ri).enumerate() {
          if it.body != none {
            let side = side-of(it, ri)
            // A label gets the same backdrop a mark does, for the same reason: the arrows are already
            // drawn, and one crossing this lane has to break around the label rather than run through
            // its glyphs.  `halo: none` drops it, for a label meant to let what is behind show through.
            let halo-pad = label-halo-of(it)
            // The displacement slides the label along the timeline; the side then steps it off the
            // lane, which is a page direction and so does not turn with the orientation.
            let base = point(t-at(ri, ii) + label-offset-of(it), ri)
            let step = side-offset(side)
            content(
              (base.at(0) + step.at(0), base.at(1) + step.at(1)),
              anchor: side-anchor(side),
              frame: if halo-pad == none { none } else { "rect" },
              fill: white,
              stroke: none,
              padding: if halo-pad == none { 0 } else { halo-pad },
              text(fill: lane.color, label-of(it)),
            )
          }
        }
      }
      layer-of(labels)

      // Over everything, that pass included.
      layer-of(foreground)
    })
  }

  // `figure` stays outside the `context` above so that a `<label>` written after the call attaches
  // to the figure itself, and `@`-references number with the document's other figures.
  let body = block(width: 100%, {
    set text(size: text-size)
    align(center, drawing)
  })

  if caption == none { body } else { figure(body, caption: caption, kind: image, supplement: auto) }
}
