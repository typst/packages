#let update-parent-context(parent-ctx, ctx) = {
  let last-anchor = if parent-ctx.last-anchor != ctx.last-anchor {
    (
      ..parent-ctx.last-anchor,
      drew: true,
    )
  } else {
    parent-ctx.last-anchor
  }
  (
    ..parent-ctx,
    last-anchor: last-anchor,
    hooks: ctx.hooks,
    hooks-links: ctx.hooks-links,
    links: ctx.links,
  )
}

/// Set the last anchor in the context to the given anchor and save it if needed
#let set-last-anchor(ctx, anchor) = {
  if ctx.last-anchor.type == "link" {
    if anchor.type == "fragment" and anchor.empty {
      ctx.last-anchor.ignore-to-margins = true
    }
    let drew = ctx.last-anchor.at("drew", default: false)
    if not drew {
      ctx.links.push(ctx.last-anchor)
    }
    ctx.last-anchor.drew = true
  }
  (..ctx, last-anchor: anchor)
}
