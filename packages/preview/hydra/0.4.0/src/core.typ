#import "/src/util.typ"

/// Returns the current text direction.
///
/// This function is contextual.
///
/// -> direction
#let get-text-dir() = util.auto-or(text.dir, () => util.text-direction(text.lang))

/// Returns the current page binding.
///
/// This function is contextual.
///
/// -> alignment
#let get-page-binding() = util.auto-or(page.binding, () => util.page-binding(get-text-dir()))

/// Returns the current top margin.
///
/// This function is contextual.
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
  margin.length.to-absolute() + (min * margin.ratio)
}

/// Get the last anchor location. Panics if the last anchor was not on the page of this context.
///
/// This function is contextual.
///
/// - ctx (context): The context from which to start.
/// -> location
#let locate-last-anchor(ctx) = {
  let starting-locs = query(selector(ctx.anchor).before(here()))

  let message = (
    "No `anchor()` found while searching from outside the page header, did you forget to set",
    "`paper`/`page-size` or `top-margin`?",
  ).join(" ")

  assert.ne(starting-locs.len(), 0, message: message)

  let anchor = starting-locs.last().location()

  // NOTE: this check ensures that get rules are done within the same page as the queries
  // ideally those would be done within the context of the anchor, such that a change in text
  // direction between anchor and query does not cause any issues
  assert.eq(anchor.page(), here().page(),
    message: "`anchor()` must be on every page before the first use of `hydra`"
  )

  anchor
}

/// Get the element candidates for the given context.
///
/// This function is contextual.
///
/// - ctx (context): The context for which to get the candidates.
/// -> candidates
#let get-candidates(ctx) = {
  let look-behind = selector(ctx.primary.target).before(ctx.anchor-loc)
  let look-ahead = selector(ctx.primary.target).after(ctx.anchor-loc)

  let prev-ancestor = none
  let next-ancestor = none

  if ctx.ancestors != none {
    let prev = query(selector(ctx.ancestors.target).before(ctx.anchor-loc))
    let next = query(selector(ctx.ancestors.target).after(ctx.anchor-loc))

    if ctx.ancestors.filter != none {
      prev = prev.filter(x => (ctx.ancestors.filter)(ctx, x))
      next = next.filter(x => (ctx.ancestors.filter)(ctx, x))
    }

    if prev != () {
      prev-ancestor = prev.last()
      look-behind = look-behind.after(prev-ancestor.location())
    }

    if next != () {
      next-ancestor = next.first()
      look-ahead = look-ahead.before(next-ancestor.location())
    }
  }

  let prev = query(look-behind)
  let next = query(look-ahead)

  if ctx.primary.filter != none {
    prev = prev.filter(x => (ctx.primary.filter)(ctx, x))
    next = next.filter(x => (ctx.primary.filter)(ctx, x))
  }

  let prev = if prev != () { prev.last() }
  let next = if next != () { next.first() }

  (
    primary: (prev: prev, next: next),
    ancestor: (prev: prev-ancestor, next: next-ancestor),
  )
}

/// Checks if the current context is on a starting page, i.e. if the next candidates are on top of
/// this context's page.
///
/// This function is contextual.
///
/// - ctx (context): The context in which the visibility of the next candidates should be checked.
/// - candidates (candidates): The candidates for this context.
/// -> bool
#let is-on-starting-page(ctx, candidates) = {
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

/// Checks if the previous primary candidate is still visible.
///
/// This function is contextual.
///
/// - ctx (context): The context in which the visibility of the previous primary candidate should be
///   checked.
/// - candidates (candidates): The candidates for this context.
/// -> bool
#let is-active-visible(ctx, candidates) = {
  // depending on the reading direction and binding combination the leading page is either on an odd
  // or even number, if it is leading it means the previous page is visible
  let cases = (
    left: (
      ltr: calc.odd,
      rtl: calc.even,
    ),
    right: (
      ltr: calc.even,
      rtl: calc.odd,
    ),
  )

  let is-leading-page = (cases.at(repr(ctx.binding)).at(repr(ctx.dir)))(here().page())
  let active-on-prev-page = candidates.primary.prev.location().page() == here().page() - 1

  is-leading-page and active-on-prev-page
}

/// Check if showing the active element would be redudnant in the current context.
///
/// This function is contextual.
///
/// - ctx (context): The context in which the redundancy of the previous primary candidate should be
///   checked.
/// - candidates (candidates): The candidates for this context.
/// -> bool
#let is-active-redundant(ctx, candidates) = {
  let active-visible = (
    ctx.book and candidates.primary.prev != none and is-active-visible(ctx, candidates)
  )
  let starting-page = is-on-starting-page(ctx, candidates)

  active-visible or starting-page
}

/// Display a heading's numbering and body.
///
/// - ctx (context): The context in which the element was found.
/// - candidate (content): The heading to display, panics if this is not a heading.
/// -> content
#let display(ctx, candidate) = {
  util.assert.element("candidate", candidate, heading,
    message: "Use a custom `display` function for elements other than headings",
  )

  if candidate.has("numbering") and candidate.numbering != none {
    numbering(candidate.numbering, ..counter(heading).at(candidate.location()))
    [ ]
  }

  candidate.body
}

/// Execute the core logic to find and display elements for the current context.
///
/// This function is contextual.
///
/// - ctx (context): The context for which to find and display the element.
/// -> content
#let execute(ctx) = {
  ctx.anchor-loc = if ctx.anchor != none and here().position().y >= get-top-margin() {
    locate-last-anchor(ctx)
  } else {
    here()
  }

  let candidates = get-candidates(ctx)
  let prev-eligible = candidates.primary.prev != none and (ctx.prev-filter)(ctx, candidates)
  let next-eligible = candidates.primary.next != none and (ctx.next-filter)(ctx, candidates)
  let active-redundant = is-active-redundant(ctx, candidates)

  if prev-eligible and not active-redundant {
    (ctx.display)(ctx, candidates.primary.prev)
  } else if next-eligible and not ctx.skip-starting {
    (ctx.display)(ctx, candidates.primary.next)
  }
}
