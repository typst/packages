#import "/src/util.typ"

/// Create a custom selector for @cmd:hydra.
///
/// -> hydra-selector
#let custom(
  /// The primary element to search for.
  ///
  /// -> queryable
  element,
  /// The filter to apply to the element.
  ///
  /// Signature: #lambda("hydra-context", "candidates", ret: bool)
  ///
  /// -> function
  filter: none,
  /// The ancestor elements, this should match all of its ancestors.
  ///
  /// -> queryable
  ancestors: none,
  /// The filter applied to the ancestors.
  ///
  /// Signature: #lambda("hydra-context", "candidates", ret: bool)
  ///
  /// -> function
  ancestors-filter: none,
) = {
  util.assert.types("element", element, function, selector, label)
  util.assert.types("filter", filter, function, none)
  util.assert.types("ancestors", ancestors, function, selector, label, none)
  util.assert.types("ancestors-filter", ancestors-filter, function, none)

  util.assert.queryable("element", element)

  if ancestors != none {
    util.assert.queryable("ancestors", ancestors)
  }

  if ancestors == none and ancestors-filter != none {
    panic("`ancestor` must be set if `ancestor-filter` is set")
  }

  (
    primary: (target: element, filter: filter),
    ancestors: if ancestors != none { (target: ancestors, filter: ancestors-filter) },
  )
}

/// Create a heading selector for a given range of levels.
///
/// -> hydra-selector
#let by-level(
  /// The inclusive minimum level to consider as the primary heading.
  ///
  /// -> int | none
  min: none,
  /// The inclusive maximum level to consider as the primary heading.
  ///
  /// -> int | none
  max: none,
  /// The exact level to consider as the primary element.
  ///
  /// -> int | none
  ..exact,
) = {
  let (named, pos) = (exact.named(), exact.pos())
  assert.eq(
    named.len(), 0,
    message: util.fmt("Unexected named arguments: `{}`", named),
  )
  assert(
    pos.len() <= 1,
    message: util.fmt("Unexpected positional arguments: `{}`", pos),
  )

  exact = pos.at(0, default: none)

  util.assert.types("min", min, int, none)
  util.assert.types("max", max, int, none)
  util.assert.types("exact", exact, int, none)

  if min == none and max == none and exact == none {
    panic("Use `heading` directly if you have no `min`, `max` or `exact` level bound")
  }

  if exact != none and (min != none or max != none) {
    panic("Can only use `min` and `max`, or `exact` bound, not both")
  }

  if exact == none and (min == max) {
    exact = min
    min = none
    max = none
  }

  let (primary, primary-filter) = if exact != none {
    (heading.where(level: exact), none)
  } else if min != none and max != none {
    (heading, (ctx, e) => min <= e.level and e.level <= max)
  } else if min != none {
    (heading, (ctx, e) => min <= e.level)
  } else if max != none {
    (heading, (ctx, e) => e.level <= max)
  }

  let (ancestors, ancestors-filter) = if exact != none {
    (heading, (ctx, e) => e.level < exact)
  } else  if min != none and min > 1 {
    (heading, (ctx, e) => e.level < min)
  } else {
    (none, none)
  }

  custom(
    primary,
    filter: primary-filter,
    ancestors: heading,
    ancestors-filter: ancestors-filter,
  )
}

/// Turn various values into a @type:hydra-selector.
///
/// *This function is considered unstable, it may change at any time or
/// disappear entirely.*
///
/// -> hydra-selector
#let sanitize(
  /// The name to use in the assertion message.
  ///
  /// -> str
  name,
  /// The selector to sanitize.
  ///
  /// -> queryable | full-selector | int
  sel,
  /// The assertion message to use.
  ///
  /// -> str | auto
  message: auto,
) = {
  let message = util.or-default(check: auto, message, () => util.fmt(
    "`{}` must be a `selector`, a level, or a custom hydra-selector, was {}", name, sel,
  ))

  if type(sel) == selector {
    let parts = repr(sel).split(".")

    // NOTE: because `repr(math.equation) == equation` we add it to the scope
    // NOTE: No, I don't like this either
    let func = eval(if parts.len() == 1 {
      parts.first()
    } else {
      parts.slice(0, -1).join(".")
    }, scope: (equation: math.equation))

    if func == heading {
      let fields = (:)
      if parts.len() > 1 {
        let args = parts.remove(-1)
        for arg in args.trim("where").trim(regex("\(|\)"), repeat: false).split(",") {
          let (name, val) = arg.split(":").map(str.trim)
          fields.insert(name, eval(val))
        }
      }

      assert.eq(fields.len(), 1, message: message)
      assert("level" in fields, message: message)
      by-level(fields.level)
    } else {
      custom(sel)
    }
  } else if type(sel) == int {
    by-level(sel)
  } else if type(sel) == function {
    custom(sel)
  } else if type(sel) == dictionary and "primary" in sel and "ancestors" in sel {
    sel
  } else {
    panic(message)
  }
}
