// SAPIANS slide dynamics: pauses, subslide visibility, handout mode.
//
// Portions adapted from touying (MIT, © touying contributors) and inspired by
// minideck/polylux.
//
// Architecture (minideck): one state holds a tuple `(steps, pause-index)` so
// that every update is a PURE function of the previous value and can be
// emitted without a surrounding `context`. A slide is rendered once, the
// driver then reads how many steps that first rendering asked for and repeats
// the rendering for the remaining steps (`_slide-auto`).
//
// Convergence rule (learned the hard way, see the module docs in
// docs/ if you extend this): slide BODIES may WRITE `_steps` but must never
// READ it. Reading the step total from inside a rendered subslide makes the
// document oscillate between "1 step" and "n steps" and Typst gives up after
// five attempts. Bodies read `_subslide` and `_handout` only; the total is
// read exclusively by `stepped-slide`, outside the rendered content.

// ---------------------------------------------------------------------------
// Subslide specifications (adapted from touying/src/utils.typ, itself adapted
// from polylux; MIT).
// ---------------------------------------------------------------------------

/// Parse a subslide specification string such as `"-2, 4, 6-8, 10-"` into a
/// list of integers and `(beginning:, until:)` dictionaries.
/// -> array
#let _parse-subslide-indices(
  /// The comma-separated specification. -> str
  s,
) = {
  let parts = s.split(",").map(p => p.trim())
  let parse-part(part) = {
    let match-until = part.match(regex("^-([[:digit:]]+)$"))
    let match-beginning = part.match(regex("^([[:digit:]]+)-$"))
    let match-range = part.match(regex("^([[:digit:]]+)-([[:digit:]]+)$"))
    let match-single = part.match(regex("^([[:digit:]]+)$"))
    if match-until != none {
      (until: int(match-until.captures.first()))
    } else if match-beginning != none {
      (beginning: int(match-beginning.captures.first()))
    } else if match-range != none {
      (
        beginning: int(match-range.captures.first()),
        until: int(match-range.captures.last()),
      )
    } else if match-single != none {
      int(match-single.captures.first())
    } else {
      panic("failed to parse visible subslide index: " + part)
    }
  }
  parts.map(parse-part)
}

/// Check whether a subslide index is visible under a visibility
/// specification. `check-visible(3, "2-")` is `true`.
/// -> bool
#let check-visible(
  /// The subslide being rendered, 1-based. -> int
  idx,

  /// Which subslides the content belongs to. A single integer selects one
  /// subslide, an array selects several, a string spells out ranges
  /// (`"-2, 4, 6-8, 10-"`) and may start with `!` to negate them, and a
  /// dictionary bounds the range with `beginning` and/or `until`.
  /// -> int | array | str | dictionary
  spec,
) = {
  if type(spec) == int {
    idx == spec
  } else if type(spec) == array {
    spec.any(s => check-visible(idx, s))
  } else if type(spec) == str {
    if spec.starts-with("!") {
      not check-visible(idx, spec.slice(1))
    } else {
      check-visible(idx, _parse-subslide-indices(spec))
    }
  } else if type(spec) == content and spec.has("text") {
    check-visible(idx, _parse-subslide-indices(spec.text))
  } else if type(spec) == dictionary {
    if spec.at("kind", default: none) == "not" {
      not check-visible(idx, spec.inner)
    } else {
      let lower-okay = if "beginning" in spec { spec.beginning <= idx } else {
        true
      }
      let upper-okay = if "until" in spec { spec.until >= idx } else { true }
      lower-okay and upper-okay
    }
  } else {
    panic(
      "a subslide specification must be an integer, an array of integers, a "
        + "string or a dictionary, got: "
        + repr(spec),
    )
  }
}

/// The highest subslide index a specification requires, i.e. how many steps
/// a slide containing it must have.
/// -> int
#let last-required-subslide(
  /// The specification, in any of the forms `check-visible` accepts.
  /// -> int | array | str | dictionary
  spec,
) = {
  if type(spec) == int {
    spec
  } else if type(spec) == array {
    if spec.len() == 0 { 0 } else {
      calc.max(..spec.map(s => last-required-subslide(s)))
    }
  } else if type(spec) == str {
    if spec.starts-with("!") {
      // A negation never introduces new subslides, it only reuses them.
      0
    } else {
      last-required-subslide(_parse-subslide-indices(spec))
    }
  } else if type(spec) == content and spec.has("text") {
    last-required-subslide(_parse-subslide-indices(spec.text))
  } else if type(spec) == dictionary {
    if spec.at("kind", default: none) == "not" {
      0
    } else {
      let last = 0
      if "beginning" in spec { last = calc.max(last, spec.beginning) }
      if "until" in spec { last = calc.max(last, spec.until) }
      last
    }
  } else {
    panic(
      "a subslide specification must be an integer, an array of integers, a "
        + "string or a dictionary, got: "
        + repr(spec),
    )
  }
}

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

/// `(steps, pause-index)` for the slide currently being rendered: how many
/// subslides the slide has asked for so far, and how many pauses have been
/// seen. Both live in a single state so that updates stay pure functions of
/// the previous value (minideck), which keeps layout convergence stable.
#let _steps = state("sapians-steps", (1, 0))

/// The 1-based index of the subslide currently being rendered.
#let _subslide = state("sapians-subslide", 1)

/// The step total of the slide being repeated, resolved by a context that
/// emits nothing (see `stepped-slide`).
#let _resolved-steps = state("sapians-resolved-steps", 1)

/// Whether the document is compiled in handout mode.
#let _handout = state("sapians-handout", false)

/// Logical slide number: one per slide, no matter how many subslides it is
/// rendered as. `counter(page)` is deliberately left untouched, so the two
/// diverge exactly the way pdfpc expects.
#let logical-slide = counter("sapians-logical-slide")

/// Pure state update: make sure the current slide has at least `n` steps.
/// Emit it anywhere inside a slide — it renders nothing and needs no
/// `context`, which is what keeps layout convergence stable.
/// -> content
#let update-steps(
  /// The number of steps the slide must have at least. -> int
  n,
) = _steps.update(((steps, pauses)) => (
  calc.max(steps, n),
  pauses,
))

/// Pure state update: advance the pause cursor by one and make sure the
/// slide has at least one more step than the new cursor value. The building
/// block behind pause-driven steps, kept public for custom families.
/// -> content
#let update-by-pause() = _steps.update(((steps, pauses)) => (
  calc.max(steps, pauses + 2),
  pauses + 1,
))

/// Resolve the handout flag. `--input handout=true` on the command line
/// turns handout mode on whatever the document says; `auto` leaves the
/// decision entirely to the command line.
/// -> bool
#let resolve-handout(
  /// The engine's `handout` argument. -> bool | auto
  handout,
) = {
  if handout == auto {
    sys.inputs.at("handout", default: none) == "true"
  } else {
    handout == true or sys.inputs.at("handout", default: none) == "true"
  }
}

// ---------------------------------------------------------------------------
// Pauses inside slot arrays
// ---------------------------------------------------------------------------

/// Sentinel value placed between the items of a slot array (`definitions:`,
/// `steps:`, `points:`, `items:`) to split the slide into steps.
///
/// ```typ
/// #slide-definition(definitions: (a, b, pause, c))
/// ```
#let pause = (sapians-dynamic: "pause")

/// Whether `item` is the `pause` sentinel.
/// -> bool
#let is-pause(
  /// The array entry to test. -> any
  item,
) = item == pause

/// Split an array at every `pause` sentinel into cumulative groups: the first
/// group holds the items before the first pause, the second one those items
/// plus the items up to the second pause, and so on. The last group is the
/// full array without the sentinels.
///
/// Example: `split-at-pauses((a, b, pause, c))` is `((a, b), (a, b, c))`.
/// -> array
#let split-at-pauses(
  /// The slot array, with or without `pause` sentinels. -> array
  arr,
) = {
  let groups = ()
  let acc = ()
  for item in arr {
    if is-pause(item) {
      groups.push(acc)
    } else {
      acc.push(item)
    }
  }
  groups.push(acc)
  groups
}

/// Strip the `pause` sentinels out of an array and report, for every surviving
/// item, the subslide it appears on.
///
/// Returns `(items: array, levels: array, steps: int)` where `levels.at(i)`
/// is the 1-based subslide index from which `items.at(i)` is visible, and
/// `steps` is the number of subslides the array requires.
/// -> dictionary
#let pause-levels(
  /// The slot array, with or without `pause` sentinels. -> array
  arr,
) = {
  let items = ()
  let levels = ()
  let level = 1
  for item in arr {
    if is-pause(item) {
      level += 1
    } else {
      items.push(item)
      levels.push(level)
    }
  }
  (items: items, levels: levels, steps: level)
}

// ---------------------------------------------------------------------------
// Visibility
// ---------------------------------------------------------------------------

/// Show `body` from subslide `level` on, keeping its layout box on the
/// earlier subslides. Level 1 short-circuits to plain content, so static
/// slides never pay for a `context`.
/// -> content
#let reveal-at(
  /// First subslide on which the body is visible, 1-based. -> int
  level,

  /// The content to reveal. -> content
  body,

  /// How to hide the body before `level`; `hide` keeps its box, pass
  /// `_ => none` to drop it from the layout. -> function
  hider: hide,
) = {
  if level <= 1 {
    body
  } else {
    context {
      if _handout.get() or _subslide.get() >= level { body } else {
        hider(body)
      }
    }
  }
}

/// Uncover `body` on the subslides matched by `spec`, keeping its layout box
/// on the others. The step count of the enclosing slide grows automatically,
/// so `#uncover("3-")[..]` inside a slide body turns it into a three-step
/// slide.
/// -> content
#let uncover(
  /// Which subslides show the body, in any of the forms `check-visible`
  /// accepts. -> int | array | str | dictionary
  spec,

  /// The content to uncover. -> content
  body,

  /// How to hide the body elsewhere. -> function
  hider: hide,
) = {
  // Pure update: no `context` needed, so this is safe anywhere.
  update-steps(last-required-subslide(spec))
  context {
    if _handout.get() or check-visible(_subslide.get(), spec) {
      body
    } else {
      hider(body)
    }
  }
}

/// Like `uncover`, but the body is removed from the layout on the subslides
/// where it is not visible.
/// -> content
#let only(
  /// Which subslides show the body. -> int | array | str | dictionary
  spec,

  /// The content to show. -> content
  body,
) = uncover(spec, body, hider: _ => none)

// ---------------------------------------------------------------------------
// The step driver
// ---------------------------------------------------------------------------

/// Emit one subslide: reset the per-slide state, publish the current
/// subslide index, then render.
/// -> content
#let _emit(
  /// The subslide index, 1-based. -> int
  idx,

  /// The slide renderer. -> function
  render,
) = {
  _steps.update((1, 0))
  _subslide.update(idx)
  render(idx)
}

/// Render a slide as a sequence of subslides.
///
/// `render` is called with the 1-based subslide index and must return the
/// complete slide content (i.e. it calls `slide()`, which emits the page).
///
/// With `steps: auto` the slide is rendered once, and the number of steps that
/// first rendering asked for (through `uncover`, `only` or `update-steps`)
/// decides how often it is repeated — the minideck `_slide-auto` trick. Pass
/// an integer to `steps` to pin the count.
///
/// In handout mode a single page is emitted with every step revealed, which
/// is exactly the last subslide for pause-driven content.
/// -> content
#let stepped-slide(
  /// Number of subslides, or `auto` to take the number the first rendering
  /// asked for. -> auto | int
  steps: auto,

  /// Called with the 1-based subslide index; must return the whole slide,
  /// page included. -> function
  render,
) = {
  assert(
    steps == auto or (type(steps) == int and steps >= 1),
    message: "`steps` must be `auto` or a positive integer, got " + repr(steps),
  )
  logical-slide.step()
  _emit(1, render)
  // polylux: the repetitions must not add their headings to the outline a
  // second time. The `set` only reaches the repetitions below.
  set heading(outlined: false)
  // Reading and generating must happen in two different contexts. A context
  // that emits pages does not keep a stable position relative to the state
  // updates inside those pages — `slide()` builds pages with the `page`
  // element, and the driver then observes the step total flipping between 1
  // and n forever ("did not converge within five attempts"). The context below
  // emits nothing, so its position is fixed and the total it stores is stable;
  // the generating context only reads that resolved number.
  if steps == auto {
    context _resolved-steps.update(_steps.get().first())
  } else {
    _resolved-steps.update(steps)
  }
  context {
    if not _handout.get() {
      for idx in range(2, _resolved-steps.get() + 1) {
        _emit(idx, render)
      }
    }
  }
}
