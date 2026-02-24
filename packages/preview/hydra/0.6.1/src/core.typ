#import "/src/util.typ"

/// #property(requires-context: true)
/// Returns the current top margin.
///
/// -> length
#let get-top-margin() = {
  let margin = page.margin
  if type(margin) == dictionary {
    margin = if "top" in margin {
      margin.top
    } else if "y" in margin {
      margin.y
    } else {
      panic(util.fmt("Margin did not contain `top` or `y` key: `{}`", margin))
    }
  }

  let inf = float("inf") * 1mm
  let width = util.auto-or(page.width, () => inf)
  let height = util.auto-or(page.height, () => inf)
  let min = calc.min(width, height)

  // if both were auto, we fallback to a4 margins
  if min == inf {
    min = 210.0mm
  }

  // `+ 0%` forces this to be a relative length
  margin = util.auto-or(margin, () => (2.5 / 21) * min) + 0%
  margin.length.to-absolute() + (height * margin.ratio)
}

/// #property(requires-context: true)
/// Get the last anchor location.
///
/// Panics if the last @cmd:anchor was not on the page of this context.
///
/// -> location
#let locate-last-anchor(
  /// The context from which to start.
  ///
  /// -> hydra-context
  ctx,
) = {
  let starting-locs = query(selector(ctx.anchor).before(here()))

  assert.ne(
    starting-locs.len(),
    0,
    message: "No `anchor()` found while searching from outside the page header",
  )

  let anchor = starting-locs.last().location()

  // NOTE: this check ensures that get rules are done within the same page as
  // the queries ideally those would be done within the context of the anchor,
  // such that a change in text direction between anchor and query does not
  // cause any issues
  assert.eq(
    anchor.page(),
    here().page(),
    message: "`anchor()` must be on every page before the first use of `hydra`"
  )

  anchor
}

/// #property(requires-context: true)
/// Get the element candidates for the given context.
///
/// -> candidates
#let get-candidates(
  /// The context for which to get the @type:candidates.
  ///
  /// -> hydra-context
  ctx,
  /// Whether the search should be scoped by the first ancestor element in this
  /// direction.
  ///
  /// -> bool
  scope-prev: true,
  /// Whether the search should be scoped by the first ancestor element in this
  /// direction.
  ///
  /// -> bool
  scope-next: true,
) = {
  let look-prev = selector(ctx.primary.target).before(ctx.anchor-loc)
  let look-next = selector(ctx.primary.target).after(ctx.anchor-loc)
  let look-last = look-next

  let prev-ancestor = none
  let next-ancestor = none

  if ctx.ancestors != none {
    let prev-ancestors = query(selector(ctx.ancestors.target).before(ctx.anchor-loc))
    let next-ancestors = query(selector(ctx.ancestors.target).after(ctx.anchor-loc))

    if ctx.ancestors.filter != none {
      prev-ancestors = prev-ancestors.filter(x => (ctx.ancestors.filter)(ctx, x))
      next-ancestors = next-ancestors.filter(x => (ctx.ancestors.filter)(ctx, x))
    }

    if scope-prev and prev-ancestors != () {
      prev-ancestor = prev-ancestors.last()
      look-prev = look-prev.after(prev-ancestor.location())
    }

    if scope-next and next-ancestors != () {
      next-ancestor = next-ancestors.first()
      look-next = look-next.before(next-ancestor.location())
    }
  }

  let prev-targets = query(look-prev)
  let next-targets = query(look-next)
  let last-targets = query(look-last)

  if ctx.primary.filter != none {
    prev-targets = prev-targets.filter(x => (ctx.primary.filter)(ctx, x))
    next-targets = next-targets.filter(x => (ctx.primary.filter)(ctx, x))
    last-targets = last-targets.filter(x => (ctx.primary.filter)(ctx, x))
  }
  next-targets = next-targets.filter(x => x.location().page() == ctx.anchor-loc.page())
  last-targets = last-targets.filter(x => x.location().page() == ctx.anchor-loc.page())

  let prev = if prev-targets != () { prev-targets.last() }
  let next = if next-targets != () { next-targets.first() }
  let last = if last-targets != () { last-targets.last() }

  (
    primary: (prev: prev, next: next, last: last),
    ancestor: (prev: prev-ancestor, next: next-ancestor),
  )
}

/// #property(requires-context: true)
/// Checks if the current @type:hydra-context is on a starting page, i.e. if the
/// next candidates are on top of this @type:hydra-context's page.
///
/// -> bool
#let is-on-starting-page(
  /// The context in which the visibility of the next @type:candidates should
  /// be checked.
  ///
  /// -> hydra-context
  ctx,
  /// The candidates for this @type:hydra-context.
  ///
  /// -> candidates
  candidates,
) = {
  let next = if candidates.primary.next != none { candidates.primary.next.location() }
  let next-ancestor = if candidates.ancestor.next != none { candidates.ancestor.next.location() }

  let next-starting = if next != none {
    next.page() == here().page() and next.position().y <= get-top-margin()
  } else {
    false
  }

  let next-ancestor-starting = if next-ancestor != none {
    next-ancestor.page() == here().page() and next-ancestor.position().y <= get-top-margin()
  } else {
    false
  }

  next-starting or next-ancestor-starting
}

/// #property(requires-context: true)
/// Checks if the previous primary candidate is still visible.
///
/// -> bool
#let is-active-visible(
  /// The context in which the visibility of the previous primary candidate
  /// should be checked.
  ///
  /// -> hydra-context
  ctx,
  /// The candidates for this context.
  ///
  /// -> candidates
  candidates,
) = {
  let is-leading-page = calc.odd(here().page())
  let active-on-prev-page = candidates.primary.prev.location().page() == here().page() - 1

  is-leading-page and active-on-prev-page
}

/// #property(requires-context: true)
/// Check if showing the active element would be redundant in the given context.
///
/// -> bool
#let is-active-redundant(
  /// The context in which the redundancy of the previous primary candidate
  /// should be checked.
  ///
  /// -> hydra-context
  ctx,
  /// The candidates for this context.
  ///
  /// -> candidates
  candidates,
) = {
  let active-visible = (
    ctx.book
    and candidates.primary.prev != none
    and is-active-visible(ctx, candidates)
  )
  let starting-page = is-on-starting-page(ctx, candidates)

  active-visible or starting-page
}

/// Display a heading's numbering and body, this is the default implementation
/// of @cmd:hydra.display.
///
/// This will panic if it doens't receive a #builtin("heading") as its
/// @type:candidates.
///
/// -> content
#let display(
  /// The context in which the element was found.
  ///
  /// -> hydra-context
  ctx,
  /// The heading to display.
  ///
  /// -> content
  candidate,
) = {
  util.assert.element(
    "candidate",
    candidate,
    heading,
    message: "Use a custom `display` function for elements other than headings",
  )

  if candidate.has("numbering") and candidate.numbering != none {
    numbering(candidate.numbering, ..counter(heading).at(candidate.location()))
    [ ]
  }

  candidate.body
}

/// #property(requires-context: true)
/// Execute the core logic to find and display elements for the given context.
/// The `anchor-loc` of the context will be augmented using the current typst
/// context.
///
/// -> content
#let execute(
  /// The context for which to find and display the element.
  ///
  /// -> hydra-context
  ctx,
) = {
  ctx.anchor-loc = if ctx.anchor != none and here().position().y > get-top-margin() {
    locate-last-anchor(ctx)
  } else {
    here()
  }

  let candidates = get-candidates(ctx)
  let prev-eligible = candidates.primary.prev != none and (ctx.prev-filter)(ctx, candidates)
  let next-eligible = candidates.primary.next != none and (ctx.next-filter)(ctx, candidates)
  let last-eligible = candidates.primary.last != none and (ctx.next-filter)(ctx, candidates)
  let active-redundant = is-active-redundant(ctx, candidates)

  if active-redundant and ctx.skip-starting {
    return
  }

  if ctx.use-last and last-eligible {
    (ctx.display)(ctx, candidates.primary.last)
  } else if prev-eligible and not active-redundant {
    (ctx.display)(ctx, candidates.primary.prev)
  } else if next-eligible {
    (ctx.display)(ctx, candidates.primary.next)
  }
}
