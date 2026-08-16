// lamportian-dramatis -- Lamport diagrams for replicated systems: one horizontal timeline per
// replica, local events as dots on that timeline, and arrows for the messages that carry events
// from one replica to another.  The horizontal axis is logical time, in the sense of Lamport
// clocks.
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

/// Which side of a timeline a label sits on.  These are `top` and `bottom` under names that read
/// better for a diagram of one horizontal line per replica, and they are those same values, so either
/// spelling works wherever a side is asked for.
#let above = top
#let below = bottom

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
/// `position` puts that label `above` or `below` the timeline, `size` sets its text size.  Both fall
/// back on the lane's own defaults -- see `replica` -- and then on `above` at the diagram's text size.
///
/// `displacement` slides the label along the timeline, out of being centred on its own dot: a ratio is
/// taken against the label's own width, so `+50%` leaves the label's left edge over the dot and `-50%`
/// its right edge, while a length is an exact offset and `0` (or `0%`) centres it.  Left to itself it
/// is `auto`: the lane's default, and failing that centred -- except for a lane's opening event, which
/// is nudged right by `_first-event-displacement` so its label does not crowd the replica name to its
/// left.  The dot itself never moves -- it is the event's place in time, which the layout solves for.
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
/// Arguments are told apart by type, so they may come in any order and every one of them is optional:
/// `event(below, +50%)[AddFile1]` and `event(+50%, below, "AddFile1")` are the same event.  For the
/// common case of a label and nothing else, bare content or a bare string in an `events` array is
/// shorthand, so `[AddFile1]`, `"AddFile1"` and `event[AddFile1]` are the same event too.
#let event(..args) = {
  for key in args.named().keys() {
    assert(
      key in ("position", "displacement", "body", "size", "width", "halo"),
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
  assert(
    position == auto or position == above or position == below,
    message: "lamport-diagram: event `position` must be `above` or `below`",
  )
  assert(
    _is-displacement(displacement),
    message: "lamport-diagram: event `displacement` must be a ratio, a length or `0`",
  )
  (
    kind: "event",
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
/// it is the receive that leans a message forward.  Reach for it to tilt an arrow away from whatever
/// a vertical line would otherwise run through, or to separate two sends the solver put in one column.
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
/// default, which is how far right of its `send` the point lands whenever nothing on its own replica
/// pushes it further, and enough to lean the arrow forward.  `none` leaves it on its column, drawing a
/// vertical arrow when the receiving replica has nothing else competing for that column.  A ratio
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
/// the arrow away from whatever the vertical line would otherwise run through; it is a drawing offset
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
  (kind: "gap", body: none, at: top, span: size)
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
  (kind: "idle", body: none, at: top, advance: n)
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

/// How far right of its dot a lane's opening label sits by default.  A first label is the one with the
/// replica name immediately to its left, and centring it there reads as if the name and the label
/// belonged together; a fifth of its width is enough to break that reading.
#let _first-event-displacement = 20%

/// How far a label's backdrop reaches past the label's own box by default, in canvas centimetres.
/// It matches the reach of the disc under a mark, so a label and a dot break an arrow behind them by
/// the same amount and the two read as sitting on one plane.
#let _label-halo = 0.07

/// Settles each event against the defaults of the lane it sits on, and then the diagram's own: an
/// argument given on the event itself always wins, and only a lane's opening event takes
/// `first-displacement`.  Items that are not events pass through -- a message label's side is the
/// drawing's business, since it has an arrow to stay clear of, not a lane default's.
#let _resolve-defaults(row, lane) = {
  row.enumerate().map(((ii, it)) => {
    if it.kind != "event" {
      (..it, label-displacement: 0%)
    } else {
      let inherited = if ii == 0 { lane.first-displacement } else { lane.displacement }
      let fallback = if ii == 0 { _first-event-displacement } else { 0% }
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

/// A replica lane, and the defaults the local events on it fall back on.  `name` is the id that the
/// `events` dictionary keys on; `label` is what the diagram prints for the lane and `color` is its
/// colour, either of which may also be given positionally -- colours are told apart by type.
///
/// The rest are defaults for this lane's events, each still overridable event by event: `position`
/// (`above` or `below`, positional too) is the side of the timeline their labels sit on, `size` their
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
    position == auto or position == above or position == below,
    message: "lamport-diagram: replica `position` must be `above` or `below`",
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

/// A Lamport diagram of `replicas` exchanging `events`.
///
/// `replicas` fixes the row order, top to bottom.  Each entry is an id string, a `replica` -- which
/// also carries that lane's event defaults -- or a bare dictionary of the same fields.  `events` maps
/// each replica id to that replica's local history in order: bare content or a bare string for a
/// local event, or `event`, `send`, `recv` and `gap`.
///
/// With a `caption` the result is a `figure`; without one it is the bare drawing.  `col-gap` and
/// `row-gap` are canvas centimetres and are the knobs for a diagram that reads too cramped or too
/// sparse.
#let lamport-diagram(
  caption: none,
  replicas: (),
  events: (:),
  col-gap: 2.0,
  row-gap: 1.5,
  text-size: 0.62em,
  dot: 0.095,
  message-stroke: 0.9pt + luma(110),
) = {
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

  let rows = lanes.map(lane => _resolve-defaults(events.at(lane.id).map(_item), lane))
  let msgs = _messages(rows)
  let exchanges = _exchanges(rows)
  for name in exchanges.keys() {
    assert(
      not (name in msgs),
      message: "lamport-diagram: '" + name + "' names both a sync and a send/recv message",
    )
  }
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
  let x-of = c => c * col-gap
  let y-of = r => -r * row-gap
  let lane-start = -0.18

  // Label sides for send/recv points default to the side the arrow does *not* occupy, so a vertical
  // arrow never runs through its own endpoint labels.
  let side-of = (it, ri) => {
    if it.at != auto {
      it.at
    } else if it.kind == "send" {
      if msgs.at(it.name).recv.at(0) > ri { top } else { bottom }
    } else if it.kind == "recv" {
      if msgs.at(it.name).send.at(0) < ri { bottom } else { top }
    } else if it.kind == "sync" {
      // The other end of the exchange is the one this replica's arrow runs towards.
      let other = exchanges.at(it.name).ends.filter(((r, i)) => r != ri).at(0)
      if other.at(0) > ri { top } else { bottom }
    } else {
      top
    }
  }

  // Replica names get a vertical strip of their own, left of every event label.  Without this a
  // first-column label overhangs the start of its timeline and reads as sitting above the replica
  // name rather than above its own dot, even though the two never touch.  Needs the laid-out width of
  // each label, hence `context`; canvas units are centimetres, fixed by `length: 1cm` below.
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
    let x-at = (ri, ii) => x-of(cols.at(ri).at(ii)) + offset-of(rows.at(ri).at(ii))
    // A label is centred on its mark until displaced.  A ratio slides it by that much of its own
    // width, which is what makes `+50%` line its left edge up with the mark it belongs to.
    let label-offset-of = it => if type(it.label-displacement) == ratio {
      it.label-displacement / 100% * measure(label-of(it)).width / 1cm
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

    let left-reach = lane-start
    let right-reach = x-of(ncols - 1)
    for (ri, row) in rows.enumerate() {
      for (ii, it) in row.enumerate() {
        let x = x-at(ri, ii)
        right-reach = calc.max(right-reach, x)
        if it.body != none {
          let half-width = measure(label-of(it)).width / 1cm / 2
          left-reach = calc.min(left-reach, x + label-offset-of(it) - half-width)
        }
      }
    }
    let name-x = left-reach - 0.3
    let lane-end = right-reach + col-gap * 0.55

    cetz.canvas(length: 1cm, {
      import cetz.draw: *

      // Arrows are laid down first, so every timeline, mark and label is drawn over them.  An arrow
      // that crosses a lane it has no endpoint on then reads as passing behind that lane's own marks,
      // instead of striking through them.
      for (_, m) in msgs {
        let (sr, si) = m.send
        let (rr, rii) = m.recv
        let (sx, sy) = (x-at(sr, si), y-of(sr))
        let (rx, ry) = (x-at(rr, rii), y-of(rr))
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
        let (ax, ay) = (x-at(ar, ai), y-of(ar))
        let (bx, by) = (x-at(br, bi), y-of(br))
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

      // The timeline of a lane, as the runs the line is drawn in: each `gap` column interrupts the
      // solid line with a dotted span of its own.  The backdrop and the line itself walk these same
      // runs, which is what keeps the two from drifting apart.
      let runs-of = ri => {
        let runs = ()
        let cursor = lane-start
        for (ii, it) in rows.at(ri).enumerate() {
          if it.kind == "gap" {
            let gx = x-at(ri, ii)
            let half = span-of(it) / 2
            runs.push((cursor, gx - half, false))
            runs.push((gx - half, gx + half, true))
            cursor = gx + half
          }
        }
        runs.push((cursor, lane-end, false))
        runs
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
        let y = y-of(ri)
        for (from, to, _) in runs-of(ri) {
          line((from, y), (to, y), stroke: halo)
        }
        for (ii, it) in rows.at(ri).enumerate() {
          let r = mark-radius(it)
          if r != none {
            circle((x-at(ri, ii), y), radius: r + halo-reach, fill: halo-paint, stroke: none)
          }
        }
      }

      // Layer 2: the timelines, their marks and their labels.
      for (ri, lane) in lanes.enumerate() {
        let y = y-of(ri)
        let solid = lane.color + 1.1pt
        let elided = (paint: lane.color, thickness: 1.1pt, dash: "dotted")

        // The timeline is drawn as solid runs interrupted by the dotted span of each `gap` column,
        // rather than as one line with markers on top, so an elided stretch reads as elided.  The
        // last run is the one that carries the arrowhead.
        let runs = runs-of(ri)
        for (ii, (from, to, is-elided)) in runs.enumerate() {
          line(
            (from, y),
            (to, y),
            stroke: if is-elided { elided } else { solid },
            mark: if ii == runs.len() - 1 {
              (end: "stealth", fill: lane.color, scale: 0.9)
            },
          )
        }

        content(
          (name-x, y),
          anchor: "east",
          text(fill: lane.color, weight: "medium", lane.label),
        )

        for (ii, it) in rows.at(ri).enumerate() {
          let x = x-at(ri, ii)
          // Hollow marks a point where the replica touches the network, solid a purely local step, and
          // a send is drawn smaller than the receive it feeds so the two ends of a message stay
          // tellable apart on their own, without tracing the arrow between them.
          if it.kind == "send" {
            circle((x, y), radius: mark-radius(it), fill: white, stroke: lane.color + 1pt)
          } else if it.kind in ("recv", "sync") {
            circle((x, y), radius: mark-radius(it), fill: white, stroke: lane.color + 1.1pt)
          } else if it.kind == "event" {
            circle((x, y), radius: mark-radius(it), fill: lane.color, stroke: none)
          }
          if it.body != none {
            let side = side-of(it, ri)
            // A label gets the same backdrop a mark does, for the same reason: the arrows are already
            // drawn, and one crossing this lane has to break around the label rather than run through
            // its glyphs.  `halo: none` drops it, for a label meant to let what is behind show through.
            let halo-pad = label-halo-of(it)
            content(
              (x + label-offset-of(it), y + if side == bottom { -0.3 } else { 0.3 }),
              anchor: if side == bottom { "north" } else { "south" },
              frame: if halo-pad == none { none } else { "rect" },
              fill: white,
              stroke: none,
              padding: if halo-pad == none { 0 } else { halo-pad },
              text(fill: lane.color, label-of(it)),
            )
          }
        }
      }
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
