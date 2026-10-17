// SPDX-FileCopyrightText: 2026 Toon Verstraelen <Toon.Verstraelen@UGent.be>
// SPDX-License-Identifier: Apache-2.0

// The timeline vocabulary, meant to be star-imported inside the `animation` argument
// of a slide, where shadowing the built-in `hide`, `move` and `scale` is harmless.
//
// Every primitive returns a plain description and performs no action itself.
// `sub` groups the operations that happen together in one subslide step, and validates them.
// That validation catches the mistake the star import makes possible.
// `import ..: *` falls through to the standard library for every name this module does
// not define, so `rotate("b", 45deg)` would quietly call `std.rotate` and return content.

#import "site.typ": describe
#import "transition.typ": (
  check-region-transition, check-slide-transition, cover, crossfade,
  is-transition, morph, push, uncover, wipe,
)

// The operations that change only how already-rendered content is displayed,
// and that address a tag.
#let continuous-kinds = ("reveal", "hide", "move", "scale")

// The operations that address the slide as a whole rather than a tag.
#let slide-kinds = ("pan",)

// The operations that change what typst has to lay out, and that address a tag.
#let structural-kinds = ("replace", "remove", "apply", "reset")

// Every kind of operation a step may hold.
#let op-kinds = continuous-kinds + slide-kinds + structural-kinds

// Check that a value is a valid tag name.
//
// A primitive addresses a tag and nothing else, so this is about a tag's name.
// The name a site declares is checked by `check-name` in `site.typ`, which also keeps it
// out of the label namespace that animo reserves.
#let check-tag-name(kind, name) = {
  assert(
    type(name) == str,
    message: kind
      + " takes the name of a tag as a string, got "
      + describe(name),
  )
  name
}

// Check that an offset is a length, and not a ratio of something it cannot know.
#let check-length(kind, axis, value) = {
  assert(
    type(value) == length,
    message: kind + " takes " + axis + " as a length, got " + describe(value),
  )
  value
}

// A scale factor as a plain number, whether it was written as a number or as a ratio.
//
// One form has to win, because the browser and the paged renderer both take a number,
// and neither of them can be handed a ratio of a ratio.
#let check-factor(axis, value) = {
  if type(value) == ratio {
    value / 100%
  } else if type(value) in (int, float) {
    float(value)
  } else {
    panic(
      "scale takes " + axis + " as a number or a ratio, got " + describe(value),
    )
  }
}

// Check a number of seconds, which is the unit of every time an author writes.
//
// Typst has no time literal, so `2s` does not parse, and one unit across the
// whole package keeps two numbers on one call comparable.
// A negative number is refused, because an operation cannot start before the step it is
// written in, and a step cannot be entered before the one it follows.
#let check-seconds(what, which, value) = {
  assert(
    type(value) in (int, float),
    message: what
      + " takes "
      + which
      + " as a number of seconds, got "
      + describe(value),
  )
  assert(
    value >= 0,
    message: what
      + " takes "
      + which
      + " as a number of seconds that is not negative, got "
      + repr(value),
  )
  float(value)
}

// Check how long an operation takes, which is a number of seconds or `auto`.
//
// `auto` is the deck's `primitive-duration:`, which is `--animo-primitive-duration` on
// `:root`, and it stays `auto` rather than becoming the number that property holds.
// That number lives in a stylesheet the resolver cannot read.
// Carrying `auto` through to the browser keeps a duration that is unset apart from one that
// is as long as the `primitive-duration:` of the deck, so a change of the deck's tempo reaches the
// operations that stated no duration and leaves the ones that did alone.
#let check-duration(what, value) = {
  if value == auto { auto } else { check-seconds(what, "duration", value) }
}

// The timing of an operation that says nothing about when it happens or how long it takes.
//
// The runtime reads a missing field as this one, so an operation at the default adds
// nothing to the emitted plan.
#let default-timing = (delay: 0.0, duration: auto)

// When one operation happens within its step and how long it then takes, as the record
// that travels to the browser.
//
// The timing is a record rather than two arguments, because the Web Animations API takes a
// delay and a duration in one object, and because a boundary compares the pair rather than
// one of them.
#let timing-of(kind, delay, duration) = (
  delay: check-seconds(kind, "delay", delay),
  duration: check-duration(kind, duration),
)

// Check the two ways of saying where something goes, which `move` and `pan` share.
//
// Each axis takes one of the two ways.
// `x` and `y` put the subject at a distance from an anchor,
// and `dx` and `dy` shift the subject from wherever it already is.
// Both ways on one axis are refused, because they are measured from different places.
// A call that says none of the five would leave its subject where it is, which is a step
// the author did not mean to write.
#let check-position(kind, subject, x, y, dx, dy, relto) = {
  for (absolute, relative, a, d) in (("x", "dx", x, dx), ("y", "dy", y, dy)) {
    assert(
      a == none or d == none,
      message: kind
        + " takes either "
        + absolute
        + " or "
        + relative
        + ", not both: "
        + absolute
        + " is measured from the anchor and "
        + relative
        + " from where "
        + subject
        + " already is",
    )
  }
  for (axis, value) in (("x", x), ("y", y), ("dx", dx), ("dy", dy)) {
    // The value is checked for the message, and kept as it was written.
    if value != none { let _ = check-length(kind, axis, value) }
  }
  assert(
    relto == none or type(relto) == str,
    message: kind
      + " takes relto as the name of a tag as a string, got "
      + describe(relto),
  )
  assert(
    (x, y, dx, dy, relto).any(value => value != none),
    message: kind
      + " takes at least one of x, y, dx, dy or relto, "
      + "and without any of them it would leave "
      + subject
      + " where it is",
  )
}

// The continuous primitives change how already-rendered content is displayed.

// Every primitive takes `delay:`, which holds it back within the step it is in, and
// `duration:`, which says how long it then takes.
// In the browser, the two become the delay and the duration of the Web Animations API effect,
// so the step keeps one clock.
// Both say nothing in the paged outputs, which have no clock to measure on.

/// Fade a tag in. A tag whose first display operation is `reveal` starts hidden, and keeps
/// its space while it is.
///
/// - name (str): The name of the tag.
/// - delay (int, float): Seconds this operation is held back inside its subslide.
/// - duration (auto, int, float): Seconds it then takes. `auto` is the
///   `primitive-duration:` of the deck.
/// -> dictionary
#let reveal(name, delay: 0, duration: auto) = (
  kind: "reveal",
  name: check-tag-name("reveal", name),
  timing: timing-of("reveal", delay, duration),
)

/// Fade a tag out. It keeps its space.
///
/// - name (str): The name of the tag.
/// - delay (int, float): Seconds this operation is held back inside its subslide.
/// - duration (auto, int, float): Seconds it then takes. `auto` is the
///   `primitive-duration:` of the deck.
/// -> dictionary
#let hide(name, delay: 0, duration: auto) = (
  kind: "hide",
  name: check-tag-name("hide", name),
  timing: timing-of("hide", delay, duration),
)

// Move an element, saying where it goes in the two ways `pan` says it, one per axis.
//
// `x` and `y` put the anchor of the moved tag at a distance from another anchor,
// which is the canvas origin or, with `relto`, the named tag.
// `dx` and `dy` shift the element from wherever it already is.
// An axis the call says nothing about stays where it is, unless `relto` asks for the tag,
// in which case that axis goes to the anchor as well.
//
// The anchor of a tag is the corner of its wrapper as the body laid it out,
// so the anchor excludes the display state of that tag.
// An absolute `move` is therefore idempotent,
// and a `move(relto: ..)` is unaffected by whatever moved the tag it is relative to.
/// Move a tag, per axis to a position with `x` and `y` or by an offset with `dx` and `dy`.
///
/// - name (str): The name of the tag.
/// - x (none, length): Where the anchor goes horizontally, measured from the canvas
///   origin or from the tag `relto` names.
/// - y (none, length): The same, vertically.
/// - dx (none, length): How far it moves horizontally from where it is.
/// - dy (none, length): The same, vertically.
/// - relto (none, str): The tag whose anchor `x` and `y` are measured from.
/// - delay (int, float): Seconds this operation is held back inside its subslide.
/// - duration (auto, int, float): Seconds it then takes. `auto` is the
///   `primitive-duration:` of the deck.
/// -> dictionary
#let move(
  name,
  x: none,
  y: none,
  dx: none,
  dy: none,
  relto: none,
  delay: 0,
  duration: auto,
) = {
  let name = check-tag-name("move", name)
  check-position("move", "the element", x, y, dx, dy, relto)
  (
    kind: "move",
    name: name,
    x: x,
    y: y,
    dx: dx,
    dy: dy,
    relto: relto,
    timing: timing-of("move", delay, duration),
  )
}

// Scale an element about its centre, isotropically with `f` or per axis with `fx`/`fy`.
//
// The factor is *set* rather than multiplied into what is already there,
// so a factor can be read on its own.
// `scale("a", f: 1)` restores the element whatever came before it,
// and successive growth is the product, which is a multiplication written once.
// An axis the call does not mention keeps the factor it had.
//
// `f` together with either of the others is refused rather than resolved by a precedence
// rule, because a call that gives both says two different things.
/// Set the scale factor of a tag about its centre. The factor is set, not multiplied.
///
/// - name (str): The name of the tag.
/// - f (none, int, float, ratio): The factor of both axes.
/// - fx (none, int, float, ratio): The factor of the horizontal axis.
/// - fy (none, int, float, ratio): The factor of the vertical axis.
/// - delay (int, float): Seconds this operation is held back inside its subslide.
/// - duration (auto, int, float): Seconds it then takes. `auto` is the
///   `primitive-duration:` of the deck.
/// -> dictionary
#let scale(name, f: none, fx: none, fy: none, delay: 0, duration: auto) = {
  let name = check-tag-name("scale", name)
  assert(
    f == none or (fx == none and fy == none),
    message: "scale takes either f or fx and fy, not both: "
      + "f is the factor of both axes at once",
  )
  assert(
    (f, fx, fy).any(value => value != none),
    message: "scale takes at least one of f, fx or fy, "
      + "and without any of them it would leave the element the size it is",
  )
  let along(axis, value) = if value != none { check-factor(axis, value) }
  (
    kind: "scale",
    name: name,
    fx: along("fx", if f == none { fx } else { f }),
    fy: along("fy", if f == none { fy } else { f }),
    timing: timing-of("scale", delay, duration),
  )
}

// The slide primitive, which addresses the viewport rather than a tag.
//
// Each axis is resolved on its own, so one call can mix the two ways of saying where the
// viewport goes.
// `x` puts the viewport at a distance from an anchor,
// and `dx` moves the viewport from wherever it already is.
// The anchor is the tag named by `relto`, placed where the body of a fresh slide starts,
// or the canvas origin when there is no `relto`.
// An axis given neither stays where it is, unless `relto` asks for the tag,
// in which case that axis goes to the anchor itself.
// Positive values move the viewport right and down, so the content moves left and up.
/// Move the viewport over the canvas, per axis to a position with `x` and `y` or by an offset
/// with `dx` and `dy`. Positive values move the viewport right and down.
///
/// - x (none, length): Where the anchor goes horizontally, measured from the canvas
///   origin or from the tag `relto` names.
/// - y (none, length): The same, vertically.
/// - dx (none, length): How far it moves horizontally from where it is.
/// - dy (none, length): The same, vertically.
/// - relto (none, str): The tag whose anchor `x` and `y` are measured from.
/// - delay (int, float): Seconds this operation is held back inside its subslide.
/// - duration (auto, int, float): Seconds it then takes. `auto` is the
///   `primitive-duration:` of the deck.
/// -> dictionary
#let pan(
  x: none,
  y: none,
  dx: none,
  dy: none,
  relto: none,
  delay: 0,
  duration: auto,
) = {
  check-position("pan", "the viewport", x, y, dx, dy, relto)
  (
    kind: "pan",
    x: x,
    y: y,
    dx: dx,
    dy: dy,
    relto: relto,
    timing: timing-of("pan", delay, duration),
  )
}

// The structural primitives change what typst has to lay out, and so start a new epoch.
//
// The content state of a tag is two slots that do not know about each other:
// what is laid out (the body, a replacement, or nothing) and the wrappers around it.
// `replace` and `remove` set the first and keep the second, `apply` appends to the second
// and so wraps whatever the first holds, including a later replacement,
// and `reset` sets both back to the body as written.

// On a structural operation, a delay holds back the transition of the region the operation
// changes, and a duration says how long that transition takes.
// The epoch boundary lasts until the last of these transitions has finished.
// A duration of zero is a hard cut of the region.
//
// The `transition:` argument says how the region that the operation changes crosses the
// boundary.
// `auto` is the crossfade, and a transition function names one (see `transition.typ`).
// `transition:` is an argument of the operation rather than of `sub`, so that one step can
// carry one region with one transition and another region with another.

/// Lay out `body` at the tag instead of what is there, keeping the wrappers `apply` put
/// around it. The region around the tag is redrawn.
///
/// - name (str): The name of the tag.
/// - body (content): The replacement.
/// - delay (int, float): Seconds the transition of the region is held back inside its
///   subslide.
/// - duration (auto, int, float): Seconds the transition of the region takes. `auto` is the
///   `primitive-duration:` of the deck, and `0` is a hard cut.
/// - transition (auto, array): How the region crosses the boundary. `auto` and
///   `crossfade()` are the crossfade, and `morph()` moves what the two versions share.
/// -> dictionary
#let replace(name, body, delay: 0, duration: auto, transition: auto) = {
  assert(
    type(body) == content,
    message: "replace takes its replacement as content, got " + describe(body),
  )
  (
    kind: "replace",
    name: check-tag-name("replace", name),
    body: body,
    timing: timing-of("replace", delay, duration),
    transition: check-region-transition("replace", transition),
  )
}

/// Lay out nothing at the tag, keeping the wrappers. A tag whose first content operation is
/// `reset` starts removed.
///
/// - name (str): The name of the tag.
/// - delay (int, float): Seconds the transition of the region is held back inside its
///   subslide.
/// - duration (auto, int, float): Seconds the transition of the region takes. `auto` is the
///   `primitive-duration:` of the deck, and `0` is a hard cut.
/// - transition (auto, array): How the region crosses the boundary. `auto` and
///   `crossfade()` are the crossfade, and `morph()` moves what the two versions share.
/// -> dictionary
#let remove(name, delay: 0, duration: auto, transition: auto) = (
  kind: "remove",
  name: check-tag-name("remove", name),
  timing: timing-of("remove", delay, duration),
  transition: check-region-transition("remove", transition),
)

// Named style properties are refused rather than guessed at, because animo does not
// inspect content and therefore cannot know which `set` rule a property belongs to.
/// Wrap what is laid out at the tag in each function, the last one outermost.
///
/// - name (str): The name of the tag.
/// - delay (int, float): Seconds the transition of the region is held back inside its
///   subslide.
/// - duration (auto, int, float): Seconds the transition of the region takes. `auto` is the
///   `primitive-duration:` of the deck, and `0` is a hard cut.
/// - transition (auto, array): How the region crosses the boundary. `auto` and
///   `crossfade()` are the crossfade, and `morph()` moves what the two versions share.
/// - fns (function): The functions, such as `text.with(fill: red)` or `strong`.
/// -> dictionary
#let apply(name, delay: 0, duration: auto, transition: auto, ..fns) = {
  let name = check-tag-name("apply", name)
  assert(
    fns.named().len() == 0,
    message: "apply takes functions only, got the named arguments "
      + repr(fns.named().keys())
      + "; wrap them in a function, such as text.with(fill: red)",
  )
  assert(
    fns.pos().len() > 0,
    message: "apply takes at least one function to wrap the tag "
      + name
      + " in",
  )
  for (position, fn) in fns.pos().enumerate(start: 1) {
    assert(
      type(fn) == function,
      message: "argument "
        + str(position)
        + " of apply on the tag "
        + name
        + " is not a function, but "
        + describe(fn),
    )
  }
  (
    kind: "apply",
    name: name,
    fns: fns.pos(),
    timing: timing-of("apply", delay, duration),
    transition: check-region-transition("apply", transition),
  )
}

/// Lay out the tag as the body wrote it, with every wrapper dropped.
///
/// - name (str): The name of the tag.
/// - delay (int, float): Seconds the transition of the region is held back inside its
///   subslide.
/// - duration (auto, int, float): Seconds the transition of the region takes. `auto` is the
///   `primitive-duration:` of the deck, and `0` is a hard cut.
/// - transition (auto, array): How the region crosses the boundary. `auto` and
///   `crossfade()` are the crossfade, and `morph()` moves what the two versions share.
/// -> dictionary
#let reset(name, delay: 0, duration: auto, transition: auto) = (
  kind: "reset",
  name: check-tag-name("reset", name),
  timing: timing-of("reset", delay, duration),
  transition: check-region-transition("reset", transition),
)

// The kind of a timeline entry, which is a one-element array holding a record, or `none`
// for anything else.
#let entry-kind(value) = {
  if (
    type(value) == array
      and value.len() == 1
      and type(value.first()) == dictionary
  ) {
    value.first().at("kind", default: none)
  }
}

// Check that a value is an operation of one of the primitives above.
//
// The message has to name the star import, because the failure it produces is a value that
// looks like nothing in particular, several lines away from the call that made it.
// A transition and an `init` are values of animo that belong elsewhere, so each gets
// a message that says where.
#let check-op(value, position) = {
  let where = "argument " + str(position) + " of sub"
  if is-transition(value) {
    panic(
      where
        + " is a transition, which sub does not take; the transition into a slide is "
        + "the first argument of init, as in init(push()), and the one of a region is "
        + "the transition: of the structural primitive that changes it",
    )
  }
  if entry-kind(value) == "init" {
    panic(
      where
        + " is an init(..) call, which comes before the first sub rather than inside one",
    )
  }
  let ok = (
    type(value) == dictionary and value.at("kind", default: none) in op-kinds
  )
  if not ok {
    panic(
      where
        + " is not an animo operation, but "
        + describe(value)
        + "; `import anim: *` leaves every name animo does not define bound to the "
        + "standard library, so a primitive that does not exist, such as `rotate`, "
        + "quietly returns content instead of an operation",
    )
  }
  value
}

// Check that a handout flag is one of the three values it takes.
//
// The flag belongs to a state, and two of animo's calls carry one:
// `sub` for the state its step brings about, and `init` for the initial state,
// which has no `sub`.
// `which` names the call, because the two are written in different places and a reader
// of the message is looking at one of them.
#let check-handout(which, value) = {
  assert(
    value == auto or type(value) == bool,
    message: "the handout argument of "
      + which
      + " takes auto, true or false, got "
      + describe(value),
  )
  value
}

// Check that a `wait:` or a `hold:` is one of the values it takes.
//
// Both belong to a state, and two of animo's calls carry each:
// `sub` for the state its step brings about, and `init` for the initial state.
// `which` names the call, for the reason `check-handout` takes the same argument,
// and `what` names the keyword, because the two are refused in the same words.
#let check-gap(which, what, value) = {
  if value == none { none } else { check-seconds(which, what, value) }
}

// `sub(..ops)` groups the operations that happen together in one subslide step.
//
// `sub` returns a one-element array, never a bare dictionary,
// because a code block joins arrays and *merges* dictionaries,
// so a timeline of bare dictionaries would silently collapse into one step.
//
// `handout: auto` asks for a handout page at the final state of the slide and at no other,
// which is the page the handout shows anyway.
// `true` adds a page that the handout would otherwise lose, and `false` takes one away.
//
// `wait:` and `hold:` name the gaps on either side of this step, and one gap is named by at
// most one of them (see `check-gaps` in `plan.typ`).
// Both are measured from the moment the step they are timed against was triggered rather
// than from the moment that step's motion finished.

/// One subslide: the operations that happen together in one step of the presenter.
///
/// - wait (none, int, float): Seconds before this subslide is entered, measured from the
///   moment the previous state came up, or `none` for a presenter click.
/// - hold (none, int, float): Seconds before the state after this one is entered, measured
///   from the moment this one came up, or `none` for a presenter click.
/// - handout (auto, bool): Whether the handout keeps this state. `auto` keeps it only when it
///   is the last state of the slide.
/// - ops (dictionary): The operations, which are calls of the primitives of this module.
/// -> array
#let sub(wait: none, hold: none, handout: auto, ..ops) = {
  assert(
    ops.named().len() == 0,
    message: "sub takes no named argument besides wait, hold and handout, got "
      + repr(ops.named().keys()),
  )
  let handout = check-handout("sub", handout)
  let wait = check-gap("sub", "wait", wait)
  let hold = check-gap("sub", "hold", hold)
  (
    (
      kind: "sub",
      wait: wait,
      hold: hold,
      handout: handout,
      ops: ops.pos().enumerate(start: 1).map(((i, op)) => check-op(op, i)),
    ),
  )
}

// The `init` of a timeline that writes none, which states nothing.
#let no-init = (
  kind: "init",
  transition: auto,
  duration: auto,
  wait: none,
  hold: none,
  handout: auto,
)

// `init(..)` is about the initial state, state 0, which has no `sub`.
//
// It adds no state, so the subslides after it keep their numbers, and it returns a
// one-element array for the reason `sub` does.
// `duration:` belongs to the transition into the slide, because no primitive causes that
// change, and `wait:` takes the place of a delay there.
// A duration of zero is a hard cut, whatever the transition.

/// The initial state of the slide, which is the slide as the body declares it: how it is
/// entered, the gaps on either side of it and whether the handout keeps it.
///
/// Written at most once, before the first `sub`.
///
/// - transition (array): How the slide is entered, such as `push(direction: btt)`.
///   Without it, the slide takes the transition of the deck.
/// - duration (auto, int, float): Seconds the transition into the slide takes.
///   `auto` is the `transition-duration:` of the deck, and `0` is a hard cut.
/// - wait (none, int, float): Seconds before the slide is entered, measured from the moment
///   the last state of the previous slide came up, or `none` for a presenter click.
/// - hold (none, int, float): Seconds before the first subslide is entered, measured from
///   the moment the initial state came up, or `none` for a presenter click.
/// - handout (auto, bool): Whether the handout keeps the initial state. `auto` keeps it only
///   when the slide has no `sub`.
/// -> array
#let init(
  ..transition,
  duration: auto,
  wait: none,
  hold: none,
  handout: auto,
) = {
  assert(
    transition.named().len() == 0,
    message: "init takes no named argument besides duration, wait, hold and handout, got "
      + repr(transition.named().keys()),
  )
  let given = transition.pos()
  assert(
    given.len() <= 1,
    message: "init takes at most one transition, got " + str(given.len()),
  )
  (
    (
      ..no-init,
      transition: if given.len() == 0 { auto } else {
        check-slide-transition("init", "its first argument", given.first())
      },
      duration: check-duration("init", duration),
      wait: check-gap("init", "wait", wait),
      hold: check-gap("init", "hold", hold),
      handout: check-handout("init", handout),
    ),
  )
}

// Check that a value is a valid timeline, and hand back its `init` and its steps.
//
// The `animation` argument is a code block of an optional `init(..)` call followed by
// `sub(..)` calls, which joins into an array.
// Everything else is a mistake with a recognisable shape, so each gets a separate message.
// `init` is refused anywhere but first, so that what it says never depends on where it was
// written.
#let check-timeline(animation) = {
  if animation == none {
    // A code block that joined nothing is a timeline with no steps.
    return (init: no-init, steps: ())
  }
  if (
    type(animation) == dictionary
      and animation.at("kind", default: none) == "sub"
  ) {
    panic(
      "the animation argument received the inside of a sub(..) call; "
        + "sub returns its step as a one-element array, so pass the call itself",
    )
  }
  if type(animation) != array {
    panic(
      "the animation argument takes a code block of an optional init(..) call and "
        + "sub(..) calls, got "
        + describe(animation)
        + "; a content block is the slide body, not its timeline",
    )
  }
  let init = no-init
  let steps = ()
  for (position, entry) in animation.enumerate(start: 1) {
    let kind = if type(entry) == dictionary { entry.at("kind", default: none) }
    let where = "entry " + str(position) + " of the animation argument"
    if kind == "init" {
      assert(
        steps.len() == 0,
        message: where
          + " is an init(..) call after a sub(..) call; init comes first",
      )
      assert(
        position == 1,
        message: where
          + " is a second init(..) call; a timeline holds at most one",
      )
      init = entry
    } else if kind == "transition" {
      panic(
        where
          + " is a transition on its own; the transition into the slide is the first "
          + "argument of init, as in init(push())",
      )
    } else {
      assert(
        kind == "sub",
        message: where + " is not a sub(..) call, but " + describe(entry),
      )
      steps.push(entry)
    }
  }
  (init: init, steps: steps)
}
