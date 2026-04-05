#import "/src/util.typ"

// get the adjacent headings
#let get-adjacent-from(ctx, sel, filter) = {
  if ctx.loc.position().y >= ctx.top-margin {
    let starting-locs = query(selector(<hydra-anchor>).before(ctx.loc), ctx.loc)
    assert.ne(starting-locs.len(), 0,
      message: "No `hydra-anchor()` found while searching from outside the page header",
    )

    ctx.loc = starting-locs.last().location()
  }

  let prev = query(sel.before(ctx.loc), ctx.loc).filter(x => filter(ctx, x))
  let next = query(sel.after(ctx.loc), ctx.loc).filter(x => filter(ctx, x))

  let prev = if prev != () { prev.last() }
  let next = if next != () { next.first() }

  (prev, next, ctx.loc)
}

// check if the next heading is on the current page
#let is-redundant(ctx, prev, next) = {
  let is-next-on-top = (
    next.location().page() == ctx.loc.page()
      and next.location().position().y <= ctx.top-margin
  )

  let is-prev-visible = (
    ctx.is-book
      and calc.odd(ctx.loc.page()) and prev.location().page() == ctx.loc.page() - 1
  )

  is-next-on-top or is-prev-visible
}

// display the heading as closely as it occured at the given loc
#let display(ctx, element) = {
  util.assert-element(element, heading,
    message: "Use a custom `display` function for elements other than headings",
  )

  if element.has("numbering") and element.numbering != none {
    numbering(element.numbering, ..counter(heading).at(element.location()))
    [ ]
  }

  element.body
}
