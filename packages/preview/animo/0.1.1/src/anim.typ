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

// The operations that change only how already-rendered content is displayed,
// and that address a tag.
#let continuous-kinds = ("reveal", "hide", "move", "scale")

// The operations that address the slide as a whole rather than a tag.
#let slide-kinds = ("pan",)

// The operations that change what typst has to lay out, and that address a tag.
#let structural-kinds = ("replace", "remove", "apply", "reset")

// Every kind of operation a step may hold.
#let op-kinds = continuous-kinds + slide-kinds + structural-kinds

// Check that a tag name is one.
//
// A primitive addresses a tag and nothing else, so this is about a tag's name.
// The name a site declares is checked by `check-name` in `site.typ`, which also keeps it
// out of animo's own label namespace.
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
// Typst has no time literal of its own, so `2s` does not parse, and one unit across the
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

// Check how long an operation takes, which is a number of seconds or the deck's own.
//
// `auto` is the deck's `primitive-duration:`, which is `--animo-primitive-duration` on
// `:root`, and it stays `auto` rather than becoming the number that property holds.
// That number lives in a stylesheet the resolver cannot read.
// Carrying `auto` through to the browser keeps a duration that is unset apart from one that
// is as long as the deck's own primitive, so a change of the deck's tempo reaches the
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
// A record rather than two arguments, because the Web Animations API takes a delay and a
// duration in one object, and because a boundary compares the pair rather than one of them.
#let timing-of(kind, delay, duration) = (
  delay: check-seconds(kind, "delay", delay),
  duration: check-duration(kind, duration),
)

// Check the two ways of saying where something goes, which `move` and `pan` share.
//
// Each axis takes one of them: `x` and `y` put it at a distance from an anchor, `dx` and
// `dy` shift it from wherever it already is, and the two on one axis are refused because
// they are measured from different places.
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
    // Checked for the message; the value itself is kept as it was written.
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

// Continuous primitives: they change how already-rendered content is displayed.

// Every primitive takes `delay:`, which holds it back within the step it is in, and
// `duration:`, which says how long it then takes.
// Each becomes the Web Animations API effect's own delay and duration in the browser, so
// the step keeps one clock, and both say nothing in the paged outputs, which have no clock
// to measure on.

#let reveal(name, delay: 0, duration: auto) = (
  kind: "reveal",
  name: check-tag-name("reveal", name),
  timing: timing-of("reveal", delay, duration),
)

#let hide(name, delay: 0, duration: auto) = (
  kind: "hide",
  name: check-tag-name("hide", name),
  timing: timing-of("hide", delay, duration),
)

// Move an element, saying where it goes in the two ways `pan` says it, one per axis.
//
// `x` and `y` put the element's own anchor at a distance from another anchor, which is the
// canvas origin or, with `relto`, the named tag; `dx` and `dy` shift it from wherever it
// already is. An axis the call says nothing about stays where it is, unless `relto` asks
// for the tag, in which case that axis goes to the anchor as well.
//
// The anchor of a tag is the corner of its wrapper as the body laid it out, so it excludes
// the tag's own display state: an absolute `move` is idempotent, and a `move(relto: ..)` is
// unaffected by whatever moved the tag it is relative to.
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

// Scale an element about its own centre, isotropically with `f` or per axis with `fx`/`fy`.
//
// The factor is *set* rather than multiplied into what is already there, so a factor can be
// read on its own: `scale("a", f: 1)` restores the element whatever came before it, and
// successive growth is the product, which is a multiplication written once.
// An axis the call does not mention keeps the factor it had.
//
// `f` together with either of the others is refused rather than resolved by a precedence
// rule, because a call that gives both says two different things.
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
// Each axis is resolved on its own, which is what lets one call mix the two ways of saying
// where the viewport goes:
// `x` puts it at a distance from an anchor, and `dx` moves it from wherever it already is.
// The anchor is the tag named by `relto`, placed where the body of a fresh slide starts,
// or the canvas origin when there is no `relto`.
// An axis given neither stays where it is, unless `relto` asks for the tag,
// in which case that axis goes to the anchor itself.
// Positive values move the viewport right and down, so the content moves left and up.
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

// Structural primitives: they change what typst has to lay out, and so start a new epoch.
//
// The content state of a tag is two slots that do not know about each other:
// what is laid out (the body, a replacement, or nothing) and the wrappers around it.
// `replace` and `remove` set the first and keep the second, `apply` appends to the second
// and so wraps whatever the first holds, including a later replacement,
// and `reset` sets both back to the body as written.

// On a structural operation a delay holds back the crossfade of the region it changes and
// a duration says how long that crossfade takes, and the epoch boundary lasts until the
// last of them has finished.

#let replace(name, body, delay: 0, duration: auto) = {
  assert(
    type(body) == content,
    message: "replace takes its replacement as content, got " + describe(body),
  )
  (
    kind: "replace",
    name: check-tag-name("replace", name),
    body: body,
    timing: timing-of("replace", delay, duration),
  )
}

#let remove(name, delay: 0, duration: auto) = (
  kind: "remove",
  name: check-tag-name("remove", name),
  timing: timing-of("remove", delay, duration),
)

// Named style properties are refused rather than guessed at:
// animo does not inspect content, so it cannot know which `set` rule a property belongs to.
#let apply(name, delay: 0, duration: auto, ..fns) = {
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
  )
}

#let reset(name, delay: 0, duration: auto) = (
  kind: "reset",
  name: check-tag-name("reset", name),
  timing: timing-of("reset", delay, duration),
)

// Check that a value is an operation of one of the primitives above.
//
// The message has to name the star import, because the failure it produces is a value that
// looks like nothing in particular, several lines away from the call that made it.
#let check-op(value, position) = {
  let ok = (
    type(value) == dictionary and value.at("kind", default: none) in op-kinds
  )
  if not ok {
    panic(
      "argument "
        + str(position)
        + " of sub is not an animo operation, but "
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
// `sub` for the state its step brings about, and `#slide` for the initial state,
// which has no `sub` of its own.
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
// Both belong to a step, and two of animo's calls carry each:
// `sub` for the step it is written on, and `#slide` for the slide it is written on,
// whose initial state has no `sub` of its own.
// `which` names the call, for the reason `check-handout` takes the same argument,
// and `what` names the keyword, because the two are refused in the same words.
#let check-gap(which, what, value) = {
  if value == none { none } else { check-seconds(which, what, value) }
}

// `sub(..ops)` groups the operations that happen together in one subslide step.
//
// It returns a one-element array, never a bare dictionary,
// because a code block joins arrays and *merges* dictionaries,
// so a timeline of bare dictionaries would silently collapse into one step.
//
// `handout: auto` asks for a handout page at the final state of the slide and at no other,
// which is the page the handout shows anyway.
// `true` adds a page that the handout would otherwise lose, and `false` takes one away.
//
// `wait:` and `hold:` are each a number of seconds, or `none` for a presenter click.
// `wait:` is the delay before this step is entered and `hold:` the delay before the step
// after it is, so the two name the gaps on either side of this step, and one gap is named
// by at most one of them (see `check-gaps` in `plan.typ`).
// Both are measured from the moment the step they are timed against was triggered rather
// than from the moment that step's motion finished.
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

// Check that a timeline is one, and hand back its steps.
//
// The `animation` argument is a code block of `sub(..)` calls, which joins into an array.
// Everything else is a mistake with a recognisable shape, so each gets its own message.
#let check-timeline(animation) = {
  if animation == none {
    // A code block that joined nothing, which is a timeline with no steps.
    ()
  } else if (
    type(animation) == dictionary
      and animation.at("kind", default: none) == "sub"
  ) {
    panic(
      "the animation argument received the inside of a sub(..) call; "
        + "sub returns its step as a one-element array, so pass the call itself",
    )
  } else if type(animation) != array {
    panic(
      "the animation argument takes a code block of sub(..) calls, got "
        + describe(animation)
        + "; a content block is the slide body, not its timeline",
    )
  } else {
    for (position, step) in animation.enumerate(start: 1) {
      assert(
        type(step) == dictionary and step.at("kind", default: none) == "sub",
        message: "step "
          + str(position)
          + " of the animation argument is not a sub(..) call, but "
          + describe(step),
      )
    }
    animation
  }
}
